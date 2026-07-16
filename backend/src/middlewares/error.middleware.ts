import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { ApiError } from '../utils/api-error';
import { logger } from '../config/logger';
import { ERROR_CODES } from '../constants/status-codes';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const correlationId = req.correlationId || 'unknown';

  if (err instanceof ApiError) {
    logger.warn(`ApiError: ${err.message}`, {
      correlationId,
      statusCode: err.statusCode,
      errors: err.errors,
      path: req.path,
      method: req.method,
    });

    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors.length > 0 ? err.errors : undefined,
      correlationId,
    });
    return;
  }

  if (err instanceof ZodError) {
    const errors = err.errors.map((e) => `${e.path.join('.')}: ${e.message}`);
    logger.warn(`Validation Error: ${errors.join(', ')}`, {
      correlationId,
      path: req.path,
    });

    res.status(ERROR_CODES.UNPROCESSABLE_ENTITY).json({
      success: false,
      message: 'Validation failed',
      errors,
      correlationId,
    });
    return;
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    logger.error(`Database Error: ${err.code}`, {
      correlationId,
      meta: err.meta,
      path: req.path,
    });

    if (err.code === 'P2002') {
      const target = (err.meta?.target as string[])?.join(', ') || 'field';
      res.status(ERROR_CODES.CONFLICT).json({
        success: false,
        message: `Duplicate value for ${target}`,
        correlationId,
      });
      return;
    }

    if (err.code === 'P2025') {
      res.status(ERROR_CODES.NOT_FOUND).json({
        success: false,
        message: 'Record not found',
        correlationId,
      });
      return;
    }

    res.status(ERROR_CODES.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Database error occurred',
      correlationId,
    });
    return;
  }

  if (err instanceof Prisma.PrismaClientValidationError) {
    logger.error(`Prisma Validation Error`, {
      correlationId,
      path: req.path,
    });

    res.status(ERROR_CODES.UNPROCESSABLE_ENTITY).json({
      success: false,
      message: 'Invalid data provided',
      correlationId,
    });
    return;
  }

  logger.error(`Unhandled Error: ${err.message}`, {
    correlationId,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  res.status(ERROR_CODES.INTERNAL_SERVER_ERROR).json({
    success: false,
    message: 'Internal server error',
    correlationId,
  });
}
