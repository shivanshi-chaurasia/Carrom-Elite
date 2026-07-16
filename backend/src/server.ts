import app from './app';
import { config } from './config';
import { logger } from './config/logger';
import { connectDatabase, disconnectDatabase } from './config/database';
import { connectRedis, disconnectRedis } from './config/redis';
import { configureCloudinary } from './config/cloudinary';
import { initializeFirebase } from './config/firebase';
import { createServer } from 'http';
import { initializeSocket } from './socket';
import { initializeJobQueues, shutdownJobQueues } from './jobs';

let httpServer: ReturnType<typeof createServer>;

async function bootstrap(): Promise<void> {
  try {
    // Connect to PostgreSQL
    await connectDatabase();

    // Connect to Redis
    await connectRedis();

    // Configure Cloudinary
    configureCloudinary();

    // Initialize Firebase
    initializeFirebase();

    // Create HTTP server
    httpServer = createServer(app);

    // Initialize Socket.IO
    initializeSocket(httpServer);

    // Initialize job queues and matchmaker
    await initializeJobQueues();

    // Start server
    httpServer.listen(config.port, config.host, () => {
      logger.info(`========================================`);
      logger.info(`  Carrom & Lottery API Server`);
      logger.info(`  Environment: ${config.env}`);
      logger.info(`  Port: ${config.port}`);
      logger.info(`  Host: ${config.host}`);
      logger.info(`  API: http://${config.host}:${config.port}${config.apiPrefix}`);
      logger.info(`  Docs: http://${config.host}:${config.port}/api-docs`);
      logger.info(`========================================`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
async function shutdown(signal: string): Promise<void> {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);

  // Stop accepting new connections
  if (httpServer) {
    httpServer.close(async () => {
      logger.info('HTTP server closed');

      // Shutdown job queues
      await shutdownJobQueues();

      // Disconnect database
      await disconnectDatabase();

      // Disconnect Redis
      await disconnectRedis();

      logger.info('Graceful shutdown completed');
      process.exit(0);
    });

    // Force close after 30s
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 30000);
  }
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  shutdown('UNCAUGHT_EXCEPTION');
});

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Rejection:', reason);
  shutdown('UNHANDLED_REJECTION');
});

// Shutdown signals
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Start server
bootstrap();
