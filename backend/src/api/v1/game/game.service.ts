import { prisma } from '../../../config/database';
import { GameRepository } from '../../../repositories/game.repository';
import { QueueManager } from '../../../matchmaking/queue-manager';
import { GameStateMachine } from '../../../game-engine/game-state';
import { TurnTimer } from '../../../game-engine/timer';
import { MoveValidator } from '../../../game-engine/move-validator';
import { ApiError } from '../../../utils/api-error';
import { getIo } from '../../../socket';
import { MatchStatus } from '@prisma/client';

export class GameService {
  static async joinQueue(userId: string, entryFee: number) {
    const wallet = await prisma.wallet.findFirst({ where: { userId } });
    if (!wallet || wallet.balance.toNumber() < entryFee) {
      throw ApiError.badRequest('Insufficient balance');
    }

    const added = await QueueManager.addToQueue(userId, entryFee);
    if (!added) {
      throw ApiError.conflict('Already in queue');
    }

    const queueSize = await QueueManager.getQueueSize(entryFee);
    return { message: 'Joined queue successfully', queueSize };
  }

  static async leaveQueue(userId: string) {
    const status = await QueueManager.isUserInQueue(userId);
    if (!status.inQueue) {
      throw ApiError.badRequest('Not in queue');
    }

    await QueueManager.removeFromQueue(userId, status.entryFee!);
    return { message: 'Left queue successfully' };
  }

  static async getQueueStatus(userId: string) {
    const status = await QueueManager.isUserInQueue(userId);
    const size = status.inQueue ? await QueueManager.getQueueSize(status.entryFee) : 0;
    return { inQueue: status.inQueue, entryFee: status.entryFee, queueSize: size };
  }

  static async createPrivateMatch(userId: string, entryFee: number = 0, maxPlayers: number = 2) {
    const roomCode = Math.random().toString(36).substring(2, 8).toUpperCase();

    const room = await prisma.room.create({
      data: {
        code: roomCode,
        type: 'CLASSIC' as any,
        matchType: 'PRIVATE' as any,
        isPrivate: true,
        isActive: true,
        ownerId: userId,
        maxPlayers,
      },
    });

    const match = await GameRepository.createMatch({
      roomId: room.id,
      type: 'PRIVATE',
      entryFee,
      prizePool: 0,
      maxPlayers,
    });

    await GameRepository.addPlayerToMatch(match.id, userId);

    return {
      matchId: match.id,
      roomCode,
      entryFee,
      maxPlayers,
    };
  }

  static async joinPrivateMatch(userId: string, roomCode: string) {
    const room = await prisma.room.findUnique({ where: { code: roomCode } });
    if (!room || !room.isActive) {
      throw ApiError.notFound('Room not found or inactive');
    }

    const match = await prisma.match.findFirst({
      where: { roomId: room.id, status: 'WAITING' },
      include: { players: true },
    });

    if (!match) {
      throw ApiError.notFound('No active match in this room');
    }

    if (match.players.length >= match.maxPlayers) {
      throw ApiError.badRequest('Room is full');
    }

    if (match.players.some(p => p.userId === userId)) {
      throw ApiError.conflict('Already in this match');
    }

    const wallet = await prisma.wallet.findFirst({ where: { userId } });
    const entryFeeAmt = match.entryFee.toNumber();
    if (entryFeeAmt > 0 && (!wallet || wallet.balance.toNumber() < entryFeeAmt)) {
      throw ApiError.badRequest('Insufficient balance');
    }

    await GameRepository.addPlayerToMatch(match.id, userId);

    const updatedMatch = await prisma.match.findUnique({
      where: { id: match.id },
      include: { players: { include: { user: { select: { id: true, username: true, avatar: true } } } } },
    });

    const allPlayers = updatedMatch!.players;
    if (allPlayers.length >= match.maxPlayers) {
      await this.startMatch(match.id);
    }

    return updatedMatch;
  }

  static async startMatch(matchId: string) {
    const match = await GameRepository.getMatchById(matchId);
    if (!match) throw ApiError.notFound('Match not found');
    if (match.status !== 'WAITING') throw ApiError.badRequest('Match already started');

    const entryFee = match.entryFee.toNumber();

    if (entryFee > 0) {
      for (const player of match.players) {
        try {
          await GameRepository.deductEntryFee(player.userId, entryFee, matchId);
        } catch {
          await GameRepository.updateMatchStatus(matchId, 'CANCELLED' as MatchStatus);
          for (const p of match.players) {
            if (p.userId !== player.userId) {
              await GameRepository.refundEntryFee(p.userId, entryFee, matchId);
            }
          }
          throw ApiError.badRequest(`Player ${player.user.username} has insufficient balance`);
        }
      }
    }

    const prizePool = entryFee * match.players.length;
    await GameRepository.updateMatchStatus(matchId, 'IN_PROGRESS' as MatchStatus, {
      prizePool: entryFee > 0 ? prizePool : 0,
    });

    const playerIds = match.players.map(p => p.userId);
    const stateMachine = new GameStateMachine(playerIds);
    const serialized = stateMachine.getSerializableState();

    await GameRepository.saveGameState(matchId, serialized, {
      currentTurnUserId: stateMachine.getState().currentTurnUserId,
      turnNumber: stateMachine.getState().turnNumber,
      turnStartTime: stateMachine.getState().turnStartTime,
      turnTimeLimit: stateMachine.getState().turnTimeLimit,
    });

    await TurnTimer.setTurnTimer(
      matchId,
      stateMachine.getState().currentTurnUserId!,
      stateMachine.getState().turnNumber,
      stateMachine.getState().turnTimeLimit,
    );
    await TurnTimer.setCurrentTurn(matchId, stateMachine.getState().currentTurnUserId!);

    const io = getIo();
    io.to(`match:${matchId}`).emit('match:started', {
      matchId,
      playerIds,
      gameState: serialized,
    });

    return { message: 'Match started', matchId };
  }

  static async submitMove(userId: string, matchId: string, moveData: any) {
    const match = await GameRepository.getMatchById(matchId);
    if (!match) throw ApiError.notFound('Match not found');
    if (match.status !== 'IN_PROGRESS') throw ApiError.badRequest('Match is not in progress');

    const player = match.players.find(p => p.userId === userId);
    if (!player) throw ApiError.forbidden('You are not a player in this match');

    if (!match.gameState) throw ApiError.badRequest('Game state not initialized');

    const rawGameState = match.gameState as Record<string, unknown>;
    const playerIds = match.players.map(p => p.userId);
    const stateMachine = GameStateMachine.fromSerializedState(rawGameState, playerIds);

    const turnTimer = await TurnTimer.getTurnTimer(matchId);
    const isTimeout = turnTimer && Date.now() - turnTimer.startedAt > turnTimer.timeLimitMs;

    if (isTimeout) {
      stateMachine.applyTimeout(userId);
      await this.handleTurnTimeout(matchId, userId, stateMachine);
      return { message: 'Turn timed out', gameState: stateMachine.getSerializableState() };
    }

    const input = { matchId, userId, moveType: 'STRIKE' as const, moveData, timestamp: Date.now() };

    const validation = stateMachine.validateMove(input as any);
    if (!validation.valid) {
      const moveValidation = MoveValidator.validateStrikeMove(moveData, stateMachine.getState().coins, userId);
      if (!moveValidation.valid) {
        throw ApiError.badRequest(moveValidation.error || validation.error!);
      }
      throw ApiError.badRequest(validation.error!);
    }

    const coinValidation = MoveValidator.validateCoinProximity(moveData, stateMachine.getState().coins);
    if (!coinValidation.valid) {
      throw ApiError.badRequest(coinValidation.error!);
    }

    stateMachine.applyMove(input as any);

    await GameRepository.recordMove({
      matchId,
      userId,
      turnNumber: stateMachine.getState().turnNumber - 1,
      moveType: moveData.isFoul ? 'FOUL' : 'STRIKE',
      moveData: {
        aimAngle: moveData.aimAngle,
        force: moveData.force,
        strikerPosition: moveData.strikerPosition,
        pocketedCoinIds: moveData.pocketedCoinIds,
        isFoul: moveData.isFoul,
      },
    });

    const serializedState = stateMachine.getSerializableState();

    if (stateMachine.isComplete()) {
      await this.finishMatch(matchId, stateMachine);
      return { message: 'Match completed', gameState: serializedState, isComplete: true };
    }

    await GameRepository.saveGameState(matchId, serializedState, {
      currentTurnUserId: stateMachine.getState().currentTurnUserId,
      turnNumber: stateMachine.getState().turnNumber,
      turnStartTime: stateMachine.getState().turnStartTime,
      turnTimeLimit: stateMachine.getState().turnTimeLimit,
    });

    const nextPlayer = stateMachine.getState().currentTurnUserId;
    await TurnTimer.setTurnTimer(matchId, nextPlayer!, stateMachine.getState().turnNumber, stateMachine.getState().turnTimeLimit);
    await TurnTimer.setCurrentTurn(matchId, nextPlayer!);

    const io = getIo();
    io.to(`match:${matchId}`).emit('match:move-accepted', {
      userId,
      turnNumber: stateMachine.getState().turnNumber - 1,
      moveData,
      gameState: serializedState,
      nextTurnUserId: nextPlayer,
    });

    return { message: 'Move accepted', gameState: serializedState };
  }

  static async handleDisconnect(userId: string, matchId: string) {
    const match = await GameRepository.getMatchById(matchId);
    if (!match || match.status !== 'IN_PROGRESS') return;

    if (!match.gameState) return;

    const rawGameState = match.gameState as Record<string, unknown>;
    const playerIds = match.players.map(p => p.userId);
    const stateMachine = GameStateMachine.fromSerializedState(rawGameState, playerIds);
    stateMachine.applyDisconnect(userId);

    if (stateMachine.isComplete()) {
      await this.finishMatch(matchId, stateMachine);
    }
  }

  static async surrender(userId: string, matchId: string) {
    const match = await GameRepository.getMatchById(matchId);
    if (!match) throw ApiError.notFound('Match not found');
    if (match.status !== 'IN_PROGRESS') throw ApiError.badRequest('Match is not in progress');

    const player = match.players.find(p => p.userId === userId);
    if (!player) throw ApiError.forbidden('You are not a player in this match');

    if (!match.gameState) throw ApiError.badRequest('Game state not initialized');

    const rawGameState = match.gameState as Record<string, unknown>;
    const playerIds = match.players.map(p => p.userId);
    const stateMachine = GameStateMachine.fromSerializedState(rawGameState, playerIds);
    stateMachine.applySurrender(userId);

    await this.finishMatch(matchId, stateMachine);
    return { message: 'Match surrendered', gameState: stateMachine.getSerializableState() };
  }

  static async getMatchDetails(matchId: string, userId: string) {
    const match = await GameRepository.getMatchById(matchId);
    if (!match) throw ApiError.notFound('Match not found');

    const isPlayer = match.players.some(p => p.userId === userId);
    if (!isPlayer) {
      const { gameState, turnData, ...sanitized } = match;
      return sanitized;
    }

    return match;
  }

  static async getMatchHistory(userId: string, page: number = 1, limit: number = 20) {
    const [matches, total] = await Promise.all([
      prisma.matchPlayer.findMany({
        where: { userId, match: { status: 'COMPLETED' as MatchStatus } },
        include: {
          match: {
            include: {
              players: { include: { user: { select: { id: true, username: true, avatar: true } } } },
            },
          },
        },
        orderBy: { match: { completedAt: 'desc' } },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.matchPlayer.count({
        where: { userId, match: { status: 'COMPLETED' as MatchStatus } },
      }),
    ]);

    return {
      matches: matches.map(mp => mp.match),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit), totalItems: total, hasNextPage: page * limit < total, hasPrevPage: page > 1 },
    };
  }

  static async getActiveMatches(userId: string) {
    return GameRepository.getActiveMatchesForUser(userId);
  }

  private static async handleTurnTimeout(matchId: string, userId: string, stateMachine: GameStateMachine) {
    const serializedState = stateMachine.getSerializableState();

    if (stateMachine.isComplete()) {
      await this.finishMatch(matchId, stateMachine);
      return;
    }

    await GameRepository.saveGameState(matchId, serializedState, {
      currentTurnUserId: stateMachine.getState().currentTurnUserId,
      turnNumber: stateMachine.getState().turnNumber,
      turnStartTime: stateMachine.getState().turnStartTime,
    });

    const nextPlayer = stateMachine.getState().currentTurnUserId;
    await TurnTimer.setTurnTimer(matchId, nextPlayer!, stateMachine.getState().turnNumber, stateMachine.getState().turnTimeLimit);
    await TurnTimer.setCurrentTurn(matchId, nextPlayer!);

    const io = getIo();
    io.to(`match:${matchId}`).emit('match:timeout', {
      userId,
      gameState: serializedState,
      nextTurnUserId: nextPlayer,
    });
  }

  private static async finishMatch(matchId: string, stateMachine: GameStateMachine) {
    const winner = stateMachine.getWinner();
    if (!winner) return;

    const match = await GameRepository.getMatchById(matchId);
    if (!match) return;

    const entryFee = match.entryFee.toNumber();
    const totalPrize = entryFee * match.players.length;
    const winnerPrize = Math.floor(totalPrize * 0.9);
    const duration = Math.floor((Date.now() - new Date(match.startedAt || match.createdAt).getTime()) / 1000);

    await GameRepository.finishMatch(matchId, winner.userId, winnerPrize, stateMachine.getSerializableState() as Record<string, unknown>, duration);

    await TurnTimer.clearTurnTimer(matchId);
    await TurnTimer.clearCurrentTurn(matchId);

    await GameRepository.saveGameState(matchId, stateMachine.getSerializableState() as Record<string, unknown>, {});

    if (entryFee > 0) {
      await GameRepository.creditWinnings(winner.userId, winnerPrize, matchId);
    }

    const io = getIo();
    io.to(`match:${matchId}`).emit('match:completed', {
      matchId,
      winnerId: winner.userId,
      winReason: winner.reason,
      scores: winner.scores,
      winnerPrize: entryFee > 0 ? winnerPrize : 0,
      duration,
    });
  }
}
