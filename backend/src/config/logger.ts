import winston from 'winston';
import path from 'path';
import fs from 'fs';
import { config } from './index';

const logDir = path.resolve(config.logging.filePath);
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
);

const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.printf(({ timestamp, level, message, correlationId, ...meta }) => {
    const correlation = correlationId ? ` [${correlationId}]` : '';
    const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
    return `${timestamp} ${level}${correlation}: ${message}${metaStr}`;
  }),
);

export const logger = winston.createLogger({
  level: config.logging.level,
  format: logFormat,
  defaultMeta: { service: 'carrom-lottery-api' },
  transports: [
    new winston.transports.File({
      filename: path.join(logDir, 'error.log'),
      level: 'error',
      maxsize: 10 * 1024 * 1024,
      maxFiles: config.logging.maxFiles,
    }),
    new winston.transports.File({
      filename: path.join(logDir, 'combined.log'),
      maxsize: 10 * 1024 * 1024,
      maxFiles: config.logging.maxFiles,
    }),
    new winston.transports.File({
      filename: path.join(logDir, 'http.log'),
      level: 'http',
      maxsize: 10 * 1024 * 1024,
      maxFiles: config.logging.maxFiles,
    }),
    new winston.transports.File({
      filename: path.join(logDir, 'debug.log'),
      level: 'debug',
      maxsize: 10 * 1024 * 1024,
      maxFiles: 10,
    }),
  ],
});

if (config.env !== 'production') {
  logger.add(
    new winston.transports.Console({
      format: consoleFormat,
      level: 'debug',
    }),
  );
}

export class LoggerStream {
  write(message: string) {
    logger.http(message.trim());
  }
}
