import { Worker, Job } from 'bullmq';
import { config } from '../config';
import { logger } from '../config/logger';
import { Matchmaker } from '../matchmaking/matchmaker';
import { QueueManager } from '../matchmaking/queue-manager';
import { getRedisClient } from '../config/redis';

const matchmaker = new Matchmaker();

export async function startMatchmakingWorker(): Promise<void> {
  try {
    const connection = getRedisClient() as any;

    const worker = new Worker(
      'matchmaking',
      async (job: Job) => {
        const { type, entryFee, userId } = job.data;

        switch (type) {
          case 'process-queue':
            matchmaker.start();
            break;

          case 'remove-from-queue':
            if (userId && entryFee !== undefined) {
              await QueueManager.removeFromQueue(userId, entryFee);
            }
            break;

          case 'cleanup-stale':
            const cleaned = await QueueManager.cleanupStaleEntries();
            logger.info(`Cleaned ${cleaned} stale queue entries`);
            break;

          default:
            logger.warn(`Unknown matchmaking job type: ${type}`);
        }
      },
      {
        connection,
        prefix: config.bullmq.prefix,
        concurrency: 1,
      },
    );

    worker.on('completed', (job: Job) => {
      logger.debug(`Matchmaking job ${job.id} completed: ${job.name}`);
    });

    worker.on('failed', (job: Job | undefined, error: Error) => {
      logger.error(`Matchmaking job ${job?.id} failed:`, error);
    });

    logger.info('Matchmaking worker started');
  } catch (error) {
    logger.error('Failed to start matchmaking worker:', error);
  }
}

export function getMatchmaker(): Matchmaker {
  return matchmaker;
}
