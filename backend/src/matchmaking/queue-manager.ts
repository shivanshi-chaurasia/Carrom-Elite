import { getRedisClient } from '../config/redis';
import { QueueEntryData } from './types';

const QUEUE_PREFIX = 'matchmaking:queue:';
const USER_IN_QUEUE_PREFIX = 'matchmaking:user:';
const QUEUE_LOCK_PREFIX = 'matchmaking:lock:';
const QUEUE_VERSION_KEY = 'matchmaking:queue:version';

export class QueueManager {
  static async addToQueue(
    userId: string,
    entryFee: number,
    rating?: number,
  ): Promise<boolean> {
    const redis = getRedisClient();
    const queueKey = `${QUEUE_PREFIX}${entryFee}`;
    const userKey = `${USER_IN_QUEUE_PREFIX}${userId}`;

    const alreadyInQueue = await redis.get(userKey);
    if (alreadyInQueue) {
      return false;
    }

    const entry: QueueEntryData = {
      userId,
      entryFee,
      joinedAt: Date.now(),
      rating: rating || 1500,
    };

    await redis.multi()
      .zadd(queueKey, entry.joinedAt, JSON.stringify(entry))
      .setex(userKey, 900, entryFee.toString())
      .incr(QUEUE_VERSION_KEY)
      .exec();

    return true;
  }

  static async removeFromQueue(userId: string, entryFee: number): Promise<boolean> {
    const redis = getRedisClient();
    const queueKey = `${QUEUE_PREFIX}${entryFee}`;
    const userKey = `${USER_IN_QUEUE_PREFIX}${userId}`;

    const entries = await redis.zrangebyscore(queueKey, '-inf', '+inf');
    let removed = false;

    for (const entryStr of entries) {
      try {
        const entry: QueueEntryData = JSON.parse(entryStr);
        if (entry.userId === userId) {
          await redis.zrem(queueKey, entryStr);
          removed = true;
          break;
        }
      } catch { continue; }
    }

    if (removed) {
      await redis.del(userKey);
      await redis.incr(QUEUE_VERSION_KEY);
    }

    return removed;
  }

  static async findMatch(
    entryFee: number,
    minPlayers: number = 2,
  ): Promise<QueueEntryData[] | null> {
    const redis = getRedisClient();
    const queueKey = `${QUEUE_PREFIX}${entryFee}`;

    const count = await redis.zcard(queueKey);
    if (count < minPlayers) return null;

    const entries = await redis.zrangebyscore(queueKey, '-inf', '+inf', 'LIMIT', 0, minPlayers);
    if (entries.length < minPlayers) return null;

    const parsed: QueueEntryData[] = [];
    for (const entryStr of entries) {
      try {
        parsed.push(JSON.parse(entryStr));
      } catch { continue; }
    }

    if (parsed.length < minPlayers) return null;

    const lockKey = `${QUEUE_LOCK_PREFIX}${entryFee}`;
    const lockAcquired = await redis.setnx(lockKey, Date.now().toString());

    if (!lockAcquired) {
      return null;
    }

    await redis.expire(lockKey, 10);

    try {
      const multi = redis.multi();
      for (const entry of parsed) {
        multi.zrem(queueKey, JSON.stringify(entry));
        multi.del(`${USER_IN_QUEUE_PREFIX}${entry.userId}`);
      }
      multi.incr(QUEUE_VERSION_KEY);
      await multi.exec();

      return parsed;
    } catch {
      await redis.del(lockKey);
      return null;
    }
  }

  static async isUserInQueue(userId: string): Promise<{ inQueue: boolean; entryFee?: number }> {
    const redis = getRedisClient();
    const data = await redis.get(`${USER_IN_QUEUE_PREFIX}${userId}`);
    if (!data) return { inQueue: false };
    return { inQueue: true, entryFee: parseInt(data, 10) };
  }

  static async getQueueSize(entryFee?: number): Promise<number> {
    const redis = getRedisClient();
    if (entryFee !== undefined) {
      return redis.zcard(`${QUEUE_PREFIX}${entryFee}`);
    }

    const keys = await redis.keys(`${QUEUE_PREFIX}*`);
    let total = 0;
    for (const key of keys) {
      total += await redis.zcard(key);
    }
    return total;
  }

  static getQueueKey(entryFee: number): string {
    return `${QUEUE_PREFIX}${entryFee}`;
  }

  static async cleanupStaleEntries(maxAgeMs: number = 900000): Promise<number> {
    const redis = getRedisClient();
    const keys = await redis.keys(`${QUEUE_PREFIX}*`);
    let cleaned = 0;
    const cutoff = Date.now() - maxAgeMs;

    for (const key of keys) {
      const entries = await redis.zrangebyscore(key, '-inf', cutoff);
      if (entries.length > 0) {
        await redis.zrem(key, ...entries);
        for (const entryStr of entries) {
          try {
            const entry: QueueEntryData = JSON.parse(entryStr);
            await redis.del(`${USER_IN_QUEUE_PREFIX}${entry.userId}`);
          } catch { continue; }
        }
        cleaned += entries.length;
      }
    }

    return cleaned;
  }
}
