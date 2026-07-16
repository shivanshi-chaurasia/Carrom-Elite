import rateLimit from 'express-rate-limit';
import { config } from '../config';
import { ERROR_CODES } from '../constants/status-codes';

export const generalRateLimiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.maxRequests,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests. Please try again later.',
  },
  statusCode: ERROR_CODES.TOO_MANY_REQUESTS,
});

export const authRateLimiter = rateLimit({
  windowMs: config.rateLimit.authWindowMs,
  max: config.rateLimit.authMaxRequests,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again later.',
  },
  statusCode: ERROR_CODES.TOO_MANY_REQUESTS,
  skipSuccessfulRequests: false,
});

export const otpRateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many OTP requests. Please wait before trying again.',
  },
  statusCode: ERROR_CODES.TOO_MANY_REQUESTS,
});

export const apiKeyRateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Rate limit exceeded for API key.',
  },
  statusCode: ERROR_CODES.TOO_MANY_REQUESTS,
});
