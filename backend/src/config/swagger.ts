import swaggerJsdoc from 'swagger-jsdoc';
import { config } from './index';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Carrom & Lottery API',
      version: '1.0.0',
      description: 'Production-grade API for Carrom + Lottery mobile gaming application',
      contact: {
        name: 'API Support',
        email: 'support@carromlottery.com',
      },
      license: {
        name: 'Private',
      },
    },
    servers: [
      {
        url: `http://localhost:${config.port}${config.apiPrefix}`,
        description: 'Development server',
      },
      {
        url: 'https://api.carromlottery.com/v1',
        description: 'Production server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your JWT access token',
        },
        deviceAuth: {
          type: 'apiKey',
          in: 'header',
          name: 'x-device-id',
          description: 'Device identifier for device verification',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
            errors: { type: 'array', items: { type: 'string' } },
            correlationId: { type: 'string' },
          },
        },
        Pagination: {
          type: 'object',
          properties: {
            page: { type: 'integer', example: 1 },
            limit: { type: 'integer', example: 20 },
            totalItems: { type: 'integer', example: 100 },
            totalPages: { type: 'integer', example: 5 },
            hasNextPage: { type: 'boolean', example: true },
            hasPrevPage: { type: 'boolean', example: false },
          },
        },
        ApiResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            message: { type: 'string' },
            data: { type: 'object' },
            meta: { $ref: '#/components/schemas/Pagination' },
            correlationId: { type: 'string' },
          },
        },
      },
      responses: {
        Unauthorized: {
          description: 'Unauthorized - Invalid or missing token',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
            },
          },
        },
        Forbidden: {
          description: 'Forbidden - Insufficient permissions',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
            },
          },
        },
        NotFound: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
            },
          },
        },
        ValidationError: {
          description: 'Validation error',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
            },
          },
        },
      },
    },
    security: [{ bearerAuth: [] }],
    tags: [
      { name: 'Auth', description: 'Authentication endpoints' },
      { name: 'User', description: 'User profile management' },
      { name: 'Wallet', description: 'Wallet and transactions' },
      { name: 'KYC', description: 'KYC verification' },
      { name: 'Rewards', description: 'Rewards and achievements' },
      { name: 'Carrom', description: 'Carrom game matches' },
      { name: 'Tournament', description: 'Tournament management' },
      { name: 'Lottery', description: 'Lottery system' },
      { name: 'Social', description: 'Social features' },
      { name: 'Notifications', description: 'Push notifications' },
      { name: 'Support', description: 'Support tickets' },
      { name: 'Settings', description: 'User settings' },
      { name: 'Home', description: 'Home dashboard and content' },
      { name: 'Admin', description: 'Admin management' },
      { name: 'Super Admin', description: 'Super admin controls' },
    ],
  },
  apis: ['./src/api/v1/**/*.routes.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);
