import jwt from 'jsonwebtoken';
import { JwtPayload } from '../interfaces/response.interface';

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_EXPIRES_IN = '7d';

export class JwtService {
  generateToken(userId: string): string {
    const payload: JwtPayload = { userId };
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
  }

  verifyToken(token: string): JwtPayload {
    return jwt.verify(token, JWT_SECRET) as JwtPayload;
  }
}

export const jwtService = new JwtService();
