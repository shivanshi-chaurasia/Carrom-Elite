import { getRedisClient } from '../config/redis';

const TURN_TIMER_PREFIX = 'turn:timer:';
const MATCH_TURN_PREFIX = 'match:turn:';

export class TurnTimer {
  static async setTurnTimer(
    matchId: string,
    userId: string,
    turnNumber: number,
    timeLimitMs: number,
  ): Promise<void> {
    const redis = getRedisClient();
    const key = `${TURN_TIMER_PREFIX}${matchId}`;
    await redis.setex(key, Math.ceil(timeLimitMs / 1000), JSON.stringify({
      userId,
      turnNumber,
      startedAt: Date.now(),
      timeLimitMs,
    }));
  }

  static async getTurnTimer(
    matchId: string,
  ): Promise<{ userId: string; turnNumber: number; startedAt: number; timeLimitMs: number } | null> {
    const redis = getRedisClient();
    const key = `${TURN_TIMER_PREFIX}${matchId}`;
    const data = await redis.get(key);
    if (!data) return null;
    return JSON.parse(data);
  }

  static async clearTurnTimer(matchId: string): Promise<void> {
    const redis = getRedisClient();
    await redis.del(`${TURN_TIMER_PREFIX}${matchId}`);
  }

  static async getRemainingTime(matchId: string): Promise<number | null> {
    const timer = await this.getTurnTimer(matchId);
    if (!timer) return null;
    const elapsed = Date.now() - timer.startedAt;
    const remaining = timer.timeLimitMs - elapsed;
    return Math.max(0, remaining);
  }

  static isExpired(timer: { startedAt: number; timeLimitMs: number }): boolean {
    return Date.now() - timer.startedAt >= timer.timeLimitMs;
  }

  static async setCurrentTurn(matchId: string, userId: string): Promise<void> {
    const redis = getRedisClient();
    await redis.set(`${MATCH_TURN_PREFIX}${matchId}`, userId);
  }

  static async getCurrentTurn(matchId: string): Promise<string | null> {
    const redis = getRedisClient();
    return redis.get(`${MATCH_TURN_PREFIX}${matchId}`);
  }

  static async clearCurrentTurn(matchId: string): Promise<void> {
    const redis = getRedisClient();
    await redis.del(`${MATCH_TURN_PREFIX}${matchId}`);
  }
}
