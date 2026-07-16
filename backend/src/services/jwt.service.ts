import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { JwtPayload } from '../interfaces/response.interface';

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET!;
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET!;
const RESET_SECRET = process.env.JWT_RESET_SECRET || crypto.randomBytes(32).toString('hex');

const ACCESS_EXPIRES_IN = process.env.JWT_ACCESS_EXPIRES_IN || '15m';
const REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '7d';
const RESET_EXPIRES_IN = process.env.JWT_RESET_EXPIRES_IN || '15m';

export class JwtService {
  generateAccessToken(userId: string): string {
    const payload: JwtPayload = { userId };
    return jwt.sign(payload, ACCESS_SECRET, { expiresIn: ACCESS_EXPIRES_IN });
  }

  generateRefreshToken(userId: string): string {
    const payload: JwtPayload = { userId };
    return jwt.sign(payload, REFRESH_SECRET, { expiresIn: REFRESH_EXPIRES_IN });
  }

  generateResetToken(userId: string): string {
    const payload: JwtPayload = { userId };
    return jwt.sign(payload, RESET_SECRET, { expiresIn: RESET_EXPIRES_IN });
  }

  verifyAccessToken(token: string): JwtPayload {
    return jwt.verify(token, ACCESS_SECRET) as JwtPayload;
  }

  verifyRefreshToken(token: string): JwtPayload {
    return jwt.verify(token, REFRESH_SECRET) as JwtPayload;
  }

  verifyResetToken(token: string): JwtPayload {
    return jwt.verify(token, RESET_SECRET) as JwtPayload;
  }
}

export const jwtService = new JwtService();
