import { getRedisClient } from '../config/redis';
import { config } from '../config';
import { generateOtp, verifyOtp } from '../utils/generate-otp';
import { ApiError } from '../utils/api-error';

export class OtpService {
  private get otpPrefix(): string {
    return 'otp';
  }

  private get cooldownPrefix(): string {
    return 'otp_cooldown';
  }

  private get attemptPrefix(): string {
    return 'otp_attempts';
  }

  async generateAndStoreOtp(
    identifier: string,
    purpose: string,
  ): Promise<{ otp: string; expiry: Date }> {
    const cooldownKey = `${this.cooldownPrefix}:${purpose}:${identifier}`;
    const cooldownExists = await getRedisClient().get(cooldownKey);

    if (cooldownExists) {
      const ttl = await getRedisClient().ttl(cooldownKey);
      throw ApiError.badRequest(
        `Please wait ${ttl} seconds before requesting a new OTP`,
      );
    }

    const { otp, expiry, hash } = generateOtp();

    const otpKey = `${this.otpPrefix}:${purpose}:${identifier}`;
    await getRedisClient().setex(otpKey, config.otp.expiryMinutes * 60, hash);

    const cooldownSeconds = config.otp.resendCooldownSeconds;
    await getRedisClient().setex(cooldownKey, cooldownSeconds, '1');

    return { otp, expiry };
  }

  async verifyOtp(
    identifier: string,
    purpose: string,
    otp: string,
  ): Promise<boolean> {
    const attemptKey = `${this.attemptPrefix}:${purpose}:${identifier}`;
    const attempts = await getRedisClient().incr(attemptKey);

    if (attempts === 1) {
      await getRedisClient().expire(
        attemptKey,
        config.otp.expiryMinutes * 60,
      );
    }

    if (attempts > config.otp.maxAttempts) {
      throw ApiError.badRequest('Maximum OTP attempts exceeded');
    }

    const otpKey = `${this.otpPrefix}:${purpose}:${identifier}`;
    const storedHash = await getRedisClient().get(otpKey);

    if (!storedHash) {
      throw ApiError.badRequest('OTP has expired');
    }

    const isValid = verifyOtp(otp, storedHash);

    if (isValid) {
      await getRedisClient().del(otpKey);
      await getRedisClient().del(attemptKey);
    }

    return isValid;
  }

  async deleteOtp(identifier: string, purpose: string): Promise<void> {
    const otpKey = `${this.otpPrefix}:${purpose}:${identifier}`;
    await getRedisClient().del(otpKey);
  }
}

export const otpService = new OtpService();
