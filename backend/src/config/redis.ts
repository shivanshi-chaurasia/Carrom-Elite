import Redis from 'ioredis';
import { config } from './index';
import { logger } from './logger';

let redis: Redis | null = null;

export function getRedisClient(): Redis {
  if (!redis) {
    redis = new Redis({
      host: config.redis.host,
      port: config.redis.port,
      password: config.redis.password,
      db: config.redis.db,
      maxRetriesPerRequest: 3,
      retryStrategy(times: number) {
        const delay = Math.min(times * 100, 3000);
        logger.warn(`Redis reconnecting in ${delay}ms (attempt ${times})`);
        return delay;
      },
      enableReadyCheck: true,
      lazyConnect: false,
    });

    redis.on('connect', () => {
      logger.info('Redis connecting...');
    });

    redis.on('ready', () => {
      logger.info('Redis connected successfully');
    });

    redis.on('error', (error) => {
      logger.error('Redis error:', error);
    });

    redis.on('close', () => {
      logger.warn('Redis connection closed');
    });

    redis.on('reconnecting', (delay: any) => {
      logger.info(`Redis reconnecting in ${delay}ms`);
    });
  }
  return redis;
}

export async function connectRedis(): Promise<void> {
  try {
    const client = getRedisClient();
    await client.ping();
    logger.info('Redis connection verified');
  } catch (error) {
    logger.error('Failed to connect to Redis:', error);
    throw error;
  }
}

export async function disconnectRedis(): Promise<void> {
  if (redis) {
    await redis.quit();
    redis = null;
    logger.info('Redis disconnected');
  }
}
