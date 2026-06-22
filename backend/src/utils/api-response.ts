import { Response } from 'express';
import { SUCCESS_CODES } from '../constants/status-codes';
import { ApiResponse, PaginationMeta } from '../interfaces/response.interface';

export function sendSuccess<T>(
  res: Response,
  data?: T,
  message = 'Success',
  statusCode: number = SUCCESS_CODES.OK,
  correlationId?: string,
  meta?: PaginationMeta,
): void {
  const response: ApiResponse<T> = {
    success: true,
    message,
    data,
    meta,
    correlationId,
  };
  res.status(statusCode).json(response);
}

export function sendCreated<T>(
  res: Response,
  data?: T,
  message = 'Created successfully',
  correlationId?: string,
): void {
  sendSuccess(res, data, message, SUCCESS_CODES.CREATED, correlationId);
}

export function sendPaginated<T>(
  res: Response,
  data: T[],
  meta: PaginationMeta,
  message = 'Data fetched successfully',
  correlationId?: string,
): void {
  sendSuccess(res, data, message, SUCCESS_CODES.OK, correlationId, meta);
}

export function sendNoContent(res: Response): void {
  res.status(SUCCESS_CODES.NO_CONTENT).send();
}
