import { prisma } from '../config/database';
import { MatchStatus } from '@prisma/client';

export class GameRepository {
  static async createMatch(data: {
    roomId: string;
    type: string;
    entryFee: number;
    prizePool: number;
    maxPlayers: number;
  }) {
    return prisma.match.create({
      data: {
        roomId: data.roomId,
        type: data.type as any,
        entryFee: data.entryFee,
        prizePool: data.prizePool,
        maxPlayers: data.maxPlayers,
        status: 'WAITING' as MatchStatus,
      },
    });
  }

  static async getMatchById(matchId: string) {
    return prisma.match.findUnique({
      where: { id: matchId },
      include: {
        players: { include: { user: { select: { id: true, username: true, avatar: true } } } },
        room: true,
      },
    });
  }

  static async updateMatchStatus(matchId: string, status: MatchStatus, extra?: Record<string, unknown>) {
    return prisma.match.update({
      where: { id: matchId },
      data: {
        status,
        ...(status === 'IN_PROGRESS' ? { startedAt: new Date() } : {}),
        ...(status === 'COMPLETED' || status === 'CANCELLED' || status === 'TIMEOUT' ? { completedAt: new Date() } : {}),
        ...extra,
      },
    });
  }

  static async addPlayerToMatch(matchId: string, userId: string) {
    return prisma.matchPlayer.create({
      data: { matchId, userId },
    });
  }

  static async getMatchPlayers(matchId: string) {
    return prisma.matchPlayer.findMany({
      where: { matchId },
      include: { user: { select: { id: true, username: true, avatar: true } } },
    });
  }

  static async deductEntryFee(userId: string, amount: number, matchId: string) {
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findFirst({ where: { userId } });
      if (!wallet) throw new Error('Wallet not found');
      if (wallet.balance.toNumber() < amount) throw new Error('Insufficient balance');

      const balanceBefore = wallet.balance;
      const balanceAfter = balanceBefore.toNumber() - amount;

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: { decrement: amount } },
      });

      await tx.transaction.create({
        data: {
          walletId: wallet.id,
          userId,
          type: 'MATCH_FEE' as any,
          amount: -amount,
          status: 'SUCCESS' as any,
          balanceBefore,
          balanceAfter,
          description: `Entry fee for match ${matchId}`,
        },
      });
    });
  }

  static async creditWinnings(userId: string, amount: number, matchId: string) {
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findFirst({ where: { userId } });
      if (!wallet) throw new Error('Wallet not found');

      const balanceBefore = wallet.balance;
      const balanceAfter = balanceBefore.toNumber() + amount;

      await tx.wallet.update({
        where: { id: wallet.id },
        data: {
          balance: { increment: amount },
          totalWinnings: { increment: amount },
        },
      });

      await tx.transaction.create({
        data: {
          walletId: wallet.id,
          userId,
          type: 'MATCH_WINNING' as any,
          amount,
          status: 'SUCCESS' as any,
          balanceBefore,
          balanceAfter,
          description: `Winnings from match ${matchId}`,
        },
      });
    });
  }

  static async refundEntryFee(userId: string, amount: number, matchId: string) {
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findFirst({ where: { userId } });
      if (!wallet) throw new Error('Wallet not found');

      const balanceBefore = wallet.balance;
      const balanceAfter = balanceBefore.toNumber() + amount;

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: { increment: amount } },
      });

      await tx.transaction.create({
        data: {
          walletId: wallet.id,
          userId,
          type: 'REFUND' as any,
          amount,
          status: 'SUCCESS' as any,
          balanceBefore,
          balanceAfter,
          description: `Refund for cancelled match ${matchId}`,
        },
      });
    });
  }

  static async saveGameState(matchId: string, gameState: Record<string, unknown>, turnData: Record<string, unknown>) {
    return prisma.match.update({
      where: { id: matchId },
      data: {
        gameState: JSON.parse(JSON.stringify(gameState)),
        turnData: JSON.parse(JSON.stringify(turnData)),
      },
    });
  }

  static async recordMove(data: {
    matchId: string;
    userId: string;
    turnNumber: number;
    moveType: string;
    moveData: Record<string, unknown>;
  }) {
    return prisma.gameMove.create({
      data: {
        matchId: data.matchId,
        userId: data.userId,
        turnNumber: data.turnNumber,
        moveType: data.moveType,
        moveData: JSON.parse(JSON.stringify(data.moveData)),
      },
    });
  }

  static async getMoves(matchId: string, limit?: number) {
    return prisma.gameMove.findMany({
      where: { matchId },
      orderBy: { turnNumber: 'asc' },
      ...(limit ? { take: limit } : {}),
    });
  }

  static async finishMatch(
    matchId: string,
    winnerId: string,
    winnerPrize: number,
    gameState: Record<string, unknown>,
    duration: number,
  ) {
    return prisma.match.update({
      where: { id: matchId },
      data: {
        status: 'COMPLETED' as MatchStatus,
        winnerId,
        winnerPrize,
        completedAt: new Date(),
        duration,
        gameState: JSON.parse(JSON.stringify(gameState)),
      },
    });
  }

  static async getActiveMatchesForUser(userId: string) {
    return prisma.matchPlayer.findMany({
      where: {
        userId,
        match: { status: { in: ['WAITING', 'READY', 'IN_PROGRESS' as MatchStatus] } },
      },
      include: { match: { include: { players: true } } },
    });
  }
}
