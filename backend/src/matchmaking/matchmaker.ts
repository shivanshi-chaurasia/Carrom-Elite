import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../config/database';
import { QueueManager } from './queue-manager';
import { GameRepository } from '../repositories/game.repository';
import { GameService } from '../api/v1/game/game.service';
import { getIo } from '../socket';
import { logger } from '../config/logger';
import { QueueEntryData } from './types';

const MATCHMAKING_INTERVAL_MS = 3000;
const MATCHMAKING_LOCK_KEY = 'matchmaking:lock:global';
const MATCHMAKING_LOCK_TTL = 10;

export class Matchmaker {
  private intervalId: ReturnType<typeof setInterval> | null = null;
  private running = false;

  start(): void {
    if (this.running) return;
    this.running = true;

    this.intervalId = setInterval(() => this.tick(), MATCHMAKING_INTERVAL_MS);
    logger.info('Matchmaker started');
  }

  stop(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    this.running = false;
    logger.info('Matchmaker stopped');
  }

  private async tick(): Promise<void> {
    const redis = (await import('../config/redis')).getRedisClient();
    const lockAcquired = await redis.setnx(MATCHMAKING_LOCK_KEY, Date.now().toString());
    if (!lockAcquired) return;

    await redis.expire(MATCHMAKING_LOCK_KEY, MATCHMAKING_LOCK_TTL);

    try {
      const entryFees = [10, 25, 50, 99, 0];

      for (const fee of entryFees) {
        const players = await QueueManager.findMatch(fee, 2);
        if (!players || players.length < 2) continue;

        await this.createMatch(players);
        break;
      }
    } catch (error) {
      logger.error('Matchmaker tick error:', error);
    } finally {
      await redis.del(MATCHMAKING_LOCK_KEY);
    }
  }

  private async createMatch(players: QueueEntryData[]): Promise<void> {
    try {
      const room = await prisma.room.create({
        data: {
          code: uuidv4().substring(0, 8).toUpperCase(),
          type: 'CLASSIC' as any,
          matchType: 'PUBLIC' as any,
          isActive: true,
          ownerId: players[0].userId,
          maxPlayers: players.length,
        },
      });

      const entryFee = players[0].entryFee;
      const totalPrize = entryFee * players.length;

      const match = await GameRepository.createMatch({
        roomId: room.id,
        type: 'PUBLIC',
        entryFee,
        prizePool: totalPrize,
        maxPlayers: players.length,
      });

      for (const player of players) {
        await GameRepository.addPlayerToMatch(match.id, player.userId);
      }

      const io = getIo();
      for (const player of players) {
        io.to(`user:${player.userId}`).emit('match:found', {
          matchId: match.id,
          entryFee,
          prizePool: totalPrize,
          opponentIds: players.filter(p => p.userId !== player.userId).map(p => p.userId),
        });
      }

      setTimeout(async () => {
        try {
          const currentMatch = await GameRepository.getMatchById(match.id);
          if (currentMatch && currentMatch.status === 'WAITING') {
            const allPlayersStillActive = await this.arePlayersStillActive(players);
            if (allPlayersStillActive) {
              await GameService.startMatch(match.id);
            } else {
              await GameRepository.updateMatchStatus(match.id, 'CANCELLED' as any);
              for (const player of players) {
                if (entryFee > 0) {
                  try {
                    await GameRepository.refundEntryFee(player.userId, entryFee, match.id);
                  } catch { }
                }
                io.to(`user:${player.userId}`).emit('match:cancelled', { matchId: match.id, reason: 'Player disconnected' });
              }
            }
          }
        } catch (error) {
          logger.error(`Auto-start match ${match.id} error:`, error);
        }
      }, 5000);

      logger.info(`Match created: ${match.id} (fee: ${entryFee}, players: ${players.length})`);
    } catch (error) {
      logger.error('Match creation error:', error);
    }
  }

  private async arePlayersStillActive(players: QueueEntryData[]): Promise<boolean> {
    const redis = (await import('../config/redis')).getRedisClient();

    for (const player of players) {
      const isOnline = await redis.sismember('online:users', player.userId);
      if (!isOnline) return false;
    }

    return true;
  }
}
