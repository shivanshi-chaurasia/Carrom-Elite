import { RequestUser } from './response.interface';

declare global {
  namespace Express {
    interface Request {
      user?: RequestUser;
      correlationId?: string;
      deviceId?: string;
      requestStartTime?: number;
    }
  }
}

export {};
