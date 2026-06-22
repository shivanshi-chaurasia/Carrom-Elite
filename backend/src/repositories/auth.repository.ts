import { Prisma } from '@prisma/client';
import { BaseRepository } from './base.repository';
import { prisma } from '../config/database';

type UserDelegate = typeof prisma.user;
type SessionDelegate = typeof prisma.session;
type DeviceDelegate = typeof prisma.device;

export class UserRepository extends BaseRepository<any, UserDelegate> {
  constructor() {
    super(prisma.user);
  }

  async findByEmail(email: string): Promise<any> {
    return this.delegate.findUnique({ where: { email } });
  }

  async findByPhone(phone: string): Promise<any> {
    return this.delegate.findUnique({ where: { phone } });
  }

  async findByUsername(username: string): Promise<any> {
    return this.delegate.findUnique({ where: { username } });
  }

  async findByReferralCode(code: string): Promise<any> {
    return this.delegate.findUnique({ where: { referralCode: code } });
  }

  async findByEmailOrPhone(email?: string, phone?: string): Promise<any> {
    if (email) {
      const user = await this.findByEmail(email);
      if (user) return user;
    }
    if (phone) {
      const user = await this.findByPhone(phone);
      if (user) return user;
    }
    return null;
  }

  async createUser(data: Prisma.UserCreateInput): Promise<any> {
    return this.create(data);
  }

  async updatePassword(id: string, hashedPassword: string): Promise<any> {
    return this.update(id, { password: hashedPassword });
  }

  async updateEmailVerified(id: string): Promise<any> {
    return this.update(id, { isEmailVerified: true });
  }

  async updatePhoneVerified(id: string): Promise<any> {
    return this.update(id, { isPhoneVerified: true });
  }

  async updateLastLogin(id: string): Promise<any> {
    return this.update(id, { lastLoginAt: new Date() });
  }

  async updateStatus(id: string, status: string): Promise<any> {
    return this.update(id, { status });
  }
}

export class SessionRepository extends BaseRepository<any, SessionDelegate> {
  constructor() {
    super(prisma.session);
  }

  async findActiveByUserId(userId: string): Promise<any[]> {
    return this.delegate.findMany({
      where: {
        userId,
        isRevoked: false,
        expiresAt: { gt: new Date() },
      },
    });
  }

  async findByRefreshToken(refreshToken: string): Promise<any> {
    return this.delegate.findFirst({
      where: {
        refreshToken,
        isRevoked: false,
        expiresAt: { gt: new Date() },
      },
    });
  }

  async revokeSession(id: string): Promise<any> {
    return this.update(id, { isRevoked: true, revokedAt: new Date() });
  }

  async revokeAllUserSessions(userId: string): Promise<number> {
    const result = await this.delegate.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true, revokedAt: new Date() },
    });
    return result.count;
  }

  async createSession(data: Prisma.SessionCreateInput): Promise<any> {
    return this.create(data);
  }

  async cleanupExpiredSessions(): Promise<number> {
    const result = await this.delegate.deleteMany({
      where: { expiresAt: { lt: new Date() } },
    });
    return result.count;
  }
}

export class DeviceRepository extends BaseRepository<any, DeviceDelegate> {
  constructor() {
    super(prisma.device);
  }

  async findByDeviceId(deviceId: string): Promise<any> {
    return this.delegate.findFirst({ where: { deviceId } });
  }

  async findUserDevices(userId: string): Promise<any[]> {
    return this.delegate.findMany({ where: { userId, isActive: true } });
  }

  async registerDevice(data: any): Promise<any> {
    return this.delegate.upsert({
      where: {
        userId_deviceId: {
          userId: data.user.connect?.id || '',
          deviceId: data.deviceId,
        },
      },
      create: data,
      update: { ...data, isActive: true, lastUsedAt: new Date() },
    });
  }

  async updateFcmToken(userId: string, deviceId: string, fcmToken: string): Promise<void> {
    await this.delegate.updateMany({
      where: { userId, deviceId },
      data: { fcmToken },
    });
  }

  async deactivateDevice(id: string): Promise<any> {
    return this.update(id, { isActive: false });
  }
}

export const userRepository = new UserRepository();
export const sessionRepository = new SessionRepository();
export const deviceRepository = new DeviceRepository();
