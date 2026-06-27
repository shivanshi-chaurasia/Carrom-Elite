import bcrypt from 'bcryptjs';
import { config } from '../../../config';
import { ApiError } from '../../../utils/api-error';
import { MESSAGES } from '../../../constants/messages';
import { jwtService } from '../../../services/jwt.service';
import { otpService } from '../../../services/otp.service';
import { emailService } from '../../../services/email.service';
import {
  userRepository,
  sessionRepository,
  deviceRepository,
} from '../../../repositories/auth.repository';
import {
  RegisterDto,
  LoginDto,
  AuthResponseDto,
  toAuthResponseDto,
  AuthTokensDto,
} from '../../../dto/auth.dto';
import { generateReferralCode } from '../../../utils/generate-token';

export class AuthService {
  async register(dto: RegisterDto): Promise<AuthTokensDto> {
    const existingEmail = await userRepository.findByEmail(dto.email);
    if (existingEmail) {
      throw ApiError.conflict(MESSAGES.EMAIL_EXISTS);
    }

    if (dto.username) {
      const existingUsername = await userRepository.findByUsername(dto.username);
      if (existingUsername) {
        throw ApiError.conflict(MESSAGES.USERNAME_EXISTS);
      }
    }

    if (dto.phone) {
      const existingPhone = await userRepository.findByPhone(dto.phone);
      if (existingPhone) {
        throw ApiError.conflict(MESSAGES.PHONE_EXISTS);
      }
    }

    const hashedPassword = await bcrypt.hash(
      dto.password,
      config.bcrypt.saltRounds,
    );

    let referredBy: string | undefined;
    if (dto.referralCode) {
      const referrer = await userRepository.findByReferralCode(
        dto.referralCode,
      );
      if (referrer) {
        referredBy = referrer.id;
      }
    }

    const referralCode = generateReferralCode(config.referral.codeLength);

    const createData: any = {
      username: dto.username,
      email: dto.email,
      password: hashedPassword,
      phone: dto.phone,
      referralCode,
    };
    if (referredBy) {
      createData.referrer = { connect: { id: referredBy } };
    }
    const user = await userRepository.createUser(createData);

    const accessToken = jwtService.generateAccessToken(user.id);
    const refreshToken = jwtService.generateRefreshToken(user.id);

    await this._createSession(user.id, accessToken, refreshToken, dto.deviceId, dto.platform);

    try {
      await emailService.sendWelcomeEmail(user.email, user.username);
      const { otp } = await otpService.generateAndStoreOtp(
        user.email,
        'email_verification',
      );
      await emailService.sendOtpEmail(user.email, otp);
    } catch (error) {
      // Non-blocking: queue these in production
    }

    return {
      ...toAuthResponseDto(user, accessToken),
      refreshToken,
    };
  }

  async login(dto: LoginDto): Promise<AuthTokensDto> {
    const user = await userRepository.findByEmailOrPhone(
      dto.email,
      dto.phone,
    );
    if (!user) {
      throw ApiError.unauthorized(MESSAGES.INVALID_CREDENTIALS);
    }

    if (user.status === 'BANNED') {
      throw ApiError.forbidden(MESSAGES.ACCOUNT_BANNED);
    }

    if (user.status === 'INACTIVE') {
      throw ApiError.forbidden(MESSAGES.ACCOUNT_INACTIVE);
    }

    const isPasswordValid = await bcrypt.compare(
      dto.password,
      user.password,
    );
    if (!isPasswordValid) {
      throw ApiError.unauthorized(MESSAGES.INVALID_CREDENTIALS);
    }

    await userRepository.updateLastLogin(user.id);

    const accessToken = jwtService.generateAccessToken(user.id);
    const refreshToken = jwtService.generateRefreshToken(user.id);

    await this._createSession(user.id, accessToken, refreshToken, dto.deviceId, dto.platform);

    return {
      ...toAuthResponseDto(user, accessToken),
      refreshToken,
    };
  }

  async refreshToken(
    refreshToken: string,
    deviceId?: string,
  ): Promise<AuthTokensDto> {
    let payload;
    try {
      payload = jwtService.verifyRefreshToken(refreshToken);
    } catch {
      throw ApiError.unauthorized(MESSAGES.INVALID_REFRESH_TOKEN);
    }

    const session = await sessionRepository.findByRefreshToken(refreshToken);
    if (!session) {
      throw ApiError.unauthorized(MESSAGES.SESSION_EXPIRED);
    }

    await sessionRepository.revokeSession(session.id);

    const user = await userRepository.findById(payload.userId);
    if (!user) {
      throw ApiError.unauthorized(MESSAGES.INVALID_CREDENTIALS);
    }

    if (user.status !== 'ACTIVE') {
      throw ApiError.forbidden(MESSAGES.ACCOUNT_INACTIVE);
    }

    const newAccessToken = jwtService.generateAccessToken(user.id);
    const newRefreshToken = jwtService.generateRefreshToken(user.id);

    await this._createSession(user.id, newAccessToken, newRefreshToken, deviceId);

    return {
      ...toAuthResponseDto(user, newAccessToken),
      refreshToken: newRefreshToken,
    };
  }

  async logout(refreshToken: string, deviceId?: string): Promise<void> {
    const session = await sessionRepository.findByRefreshToken(refreshToken);
    if (session) {
      await sessionRepository.revokeSession(session.id);
    }

    if (deviceId) {
      const device = await deviceRepository.findByDeviceId(deviceId);
      if (device) {
        await deviceRepository.deactivateDevice(device.id);
      }
    }
  }

  async sendOtp(
    identifier: string,
    purpose: string,
    type: 'email' | 'phone',
  ): Promise<void> {
    const { otp } = await otpService.generateAndStoreOtp(identifier, purpose);

    if (type === 'email') {
      await emailService.sendOtpEmail(identifier, otp);
    }
  }

  async verifyOtp(
    identifier: string,
    purpose: string,
    otp: string,
  ): Promise<boolean> {
    return otpService.verifyOtp(identifier, purpose, otp);
  }

  async verifyEmail(email: string, otp: string): Promise<void> {
    const isValid = await this.verifyOtp(email, 'email_verification', otp);
    if (!isValid) {
      throw ApiError.badRequest(MESSAGES.OTP_INVALID);
    }
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw ApiError.notFound('User not found');
    }
    await userRepository.updateEmailVerified(user.id);
  }

  async verifyPhone(phone: string, otp: string): Promise<void> {
    const isValid = await this.verifyOtp(phone, 'phone_verification', otp);
    if (!isValid) {
      throw ApiError.badRequest(MESSAGES.OTP_INVALID);
    }
    const user = await userRepository.findByPhone(phone);
    if (!user) {
      throw ApiError.notFound('User not found');
    }
    await userRepository.updatePhoneVerified(user.id);
  }

  async forgotPassword(email: string): Promise<void> {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      return;
    }

    const resetToken = jwtService.generateResetToken(user.id);
    await emailService.sendPasswordResetEmail(email, resetToken);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    let payload;
    try {
      payload = jwtService.verifyResetToken(token);
    } catch {
      throw ApiError.badRequest('Invalid or expired reset token');
    }

    const user = await userRepository.findById(payload.userId);
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    const hashedPassword = await bcrypt.hash(
      newPassword,
      config.bcrypt.saltRounds,
    );
    await userRepository.updatePassword(payload.userId, hashedPassword);

    await sessionRepository.revokeAllUserSessions(payload.userId);
  }

  async registerBiometric(
    userId: string,
    password: string,
    _deviceId: string,
  ): Promise<void> {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw ApiError.unauthorized('Invalid password');
    }

    await userRepository.update(userId, { isBiometricEnabled: true } as any);
  }

  async biometricLogin(
    _biometricKey: string,
    deviceId: string,
    _platform: string,
    _fcmToken?: string,
  ): Promise<AuthTokensDto> {
    const device = await deviceRepository.findByDeviceId(deviceId);
    if (!device || !device.isTrusted) {
      throw ApiError.unauthorized(MESSAGES.DEVICE_NOT_VERIFIED);
    }

    const user = await userRepository.findById(device.userId);
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    if (user.status !== 'ACTIVE') {
      throw ApiError.forbidden('Account is not active');
    }

    await userRepository.updateLastLogin(user.id);

    const accessToken = jwtService.generateAccessToken(user.id);
    const refreshToken = jwtService.generateRefreshToken(user.id);

    await this._createSession(user.id, accessToken, refreshToken, deviceId);

    return {
      ...toAuthResponseDto(user, accessToken),
      refreshToken,
    };
  }

  private async _createSession(
    userId: string,
    accessToken: string,
    refreshToken: string,
    deviceId?: string,
    platform?: string,
  ): Promise<void> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await sessionRepository.createSession({
      user: { connect: { id: userId } },
      accessToken,
      refreshToken,
      deviceId: deviceId || null,
      expiresAt,
    } as any);
  }
}

export const authService = new AuthService();
