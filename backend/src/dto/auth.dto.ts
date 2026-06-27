import { User } from '@prisma/client';

export interface RegisterDto {
  username: string;
  email: string;
  password: string;
  phone?: string;
  referralCode?: string;
  deviceId: string;
  platform: 'ANDROID' | 'IOS' | 'WEB';
  fcmToken?: string;
}

export interface LoginDto {
  email?: string;
  phone?: string;
  password: string;
  deviceId: string;
  platform: 'ANDROID' | 'IOS' | 'WEB';
  fcmToken?: string;
}

export interface AuthResponseDto {
  user: {
    id: string;
    username: string;
    email: string;
    phone: string | null;
    role: string;
    avatar: string | null;
    referralCode: string | null;
    isEmailVerified: boolean;
    isPhoneVerified: boolean;
    isKycCompleted: boolean;
    isBiometricEnabled: boolean;
  };
  token: string;
}

export interface AuthTokensDto extends AuthResponseDto {
  refreshToken: string;
}

export function toAuthResponseDto(user: User, token: string): AuthResponseDto {
  return {
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      phone: user.phone,
      role: user.role,
      avatar: user.avatar,
      referralCode: user.referralCode,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      isKycCompleted: user.isKycCompleted,
      isBiometricEnabled: user.isBiometricEnabled,
    },
    token,
  };
}
