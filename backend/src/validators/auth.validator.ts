import { z } from 'zod';

export const registerSchema = z.object({
  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .max(50, 'Username must be at most 50 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),
  email: z.string().email('Invalid email address'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128, 'Password must be at most 128 characters')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
      'Password must contain uppercase, lowercase, number, and special character',
    ),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number')
    .optional(),
  referralCode: z.string().max(20).optional(),
  deviceId: z.string().min(1, 'Device ID is required'),
  platform: z.enum(['ANDROID', 'IOS', 'WEB']),
  fcmToken: z.string().optional(),
});

export const loginSchema = z.object({
  email: z.string().email('Invalid email').optional(),
  phone: z.string().optional(),
  password: z.string().min(1, 'Password is required'),
  deviceId: z.string().min(1, 'Device ID is required'),
  platform: z.enum(['ANDROID', 'IOS', 'WEB']),
  fcmToken: z.string().optional(),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
  deviceId: z.string().optional(),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
  deviceId: z.string().optional(),
});

export const verifyEmailSchema = z.object({
  email: z.string().email('Invalid email'),
  otp: z.string().length(6, 'OTP must be 6 digits'),
});

export const verifyPhoneSchema = z.object({
  phone: z.string().regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number'),
  otp: z.string().length(6, 'OTP must be 6 digits'),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email('Invalid email'),
});

export const resetPasswordSchema = z.object({
  token: z.string().min(1, 'Reset token is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128)
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
      'Password must contain uppercase, lowercase, number, and special character',
    ),
});

export const sendOtpSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().optional(),
  purpose: z.enum(['email_verification', 'phone_verification', 'password_reset', 'withdrawal']),
});

export const verifyOtpSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().optional(),
  otp: z.string().length(6, 'OTP must be 6 digits'),
  purpose: z.enum(['email_verification', 'phone_verification', 'password_reset', 'withdrawal']),
});

export const biometricLoginSchema = z.object({
  biometricKey: z.string().min(1, 'Biometric key is required'),
  deviceId: z.string().min(1, 'Device ID is required'),
  platform: z.enum(['ANDROID', 'IOS', 'WEB']),
  fcmToken: z.string().optional(),
});

export const registerBiometricSchema = z.object({
  password: z.string().min(1, 'Password is required for verification'),
  deviceId: z.string().min(1, 'Device ID is required'),
});
