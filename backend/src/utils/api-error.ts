import { ERROR_CODES } from '../constants/status-codes';

export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly errors: string[];
  public readonly isOperational: boolean;

  constructor(
    statusCode: number,
    message: string,
    errors: string[] = [],
    isOperational = true,
  ) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = isOperational;
    Object.setPrototypeOf(this, ApiError.prototype);
  }

  static badRequest(message: string, errors?: string[]): ApiError {
    return new ApiError(ERROR_CODES.BAD_REQUEST, message, errors);
  }

  static unauthorized(message: string = 'Unauthorized'): ApiError {
    return new ApiError(ERROR_CODES.UNAUTHORIZED, message);
  }

  static forbidden(message: string = 'Forbidden'): ApiError {
    return new ApiError(ERROR_CODES.FORBIDDEN, message);
  }

  static notFound(message: string = 'Resource not found'): ApiError {
    return new ApiError(ERROR_CODES.NOT_FOUND, message);
  }

  static conflict(message: string): ApiError {
    return new ApiError(ERROR_CODES.CONFLICT, message);
  }

  static validation(errors: string[]): ApiError {
    return new ApiError(ERROR_CODES.UNPROCESSABLE_ENTITY, 'Validation failed', errors);
  }

  static tooManyRequests(message: string = 'Too many requests'): ApiError {
    return new ApiError(ERROR_CODES.TOO_MANY_REQUESTS, message);
  }

  static internal(message: string = 'Internal server error'): ApiError {
    return new ApiError(ERROR_CODES.INTERNAL_SERVER_ERROR, message, [], false);
  }
}
