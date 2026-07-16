import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import swaggerUi from 'swagger-ui-express';
import { config } from './config';
import { swaggerSpec } from './config/swagger';
import { logger } from './config/logger';
import { errorHandler } from './middlewares/error.middleware';
import { correlationMiddleware } from './middlewares/correlation.middleware';
import { generalRateLimiter } from './middlewares/rate-limit.middleware';
import routes from './routes';
import { ApiError } from './utils/api-error';

const app: Express = express();

// Security middleware
app.use(helmet());

// CORS
app.use(
  cors({
    origin: config.cors.origin,
    methods: config.cors.methods,
    credentials: config.cors.credentials,
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'x-device-id',
      'x-correlation-id',
      'x-platform',
    ],
    exposedHeaders: ['x-correlation-id'],
  }),
);

// Compression
app.use(compression());

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Correlation ID
app.use(correlationMiddleware);

// Rate limiting
app.use(generalRateLimiter);

// Request logging
app.use((req: Request, _res, next) => {
  logger.http(`${req.method} ${req.path}`, {
    correlationId: req.correlationId,
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  next();
});

// Swagger documentation
if (config.env !== 'production') {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
    explorer: true,
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'Carrom & Lottery API Docs',
  }));
  app.get('/api-docs.json', (_req: Request, res: Response) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
  });
}

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: config.env,
  });
});

// API Routes
app.use('/', routes);

// 404 handler
app.use((_req: Request, _res, next) => {
  next(ApiError.notFound('Route not found'));
});

// Error handler
app.use(errorHandler);

export default app;
