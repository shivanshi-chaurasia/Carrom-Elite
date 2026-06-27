import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from '../../../middlewares/auth.middleware';
import { validate } from '../../../middlewares/validate.middleware';
import { authRateLimiter, otpRateLimiter } from '../../../middlewares/rate-limit.middleware';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  logoutSchema,
  verifyEmailSchema,
  verifyPhoneSchema,
  verifyOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  sendOtpSchema,
  biometricLoginSchema,
  registerBiometricSchema,
} from '../../../validators/auth.validator';

const router = Router();

router.post('/register', authRateLimiter, validate({ body: registerSchema }), authController.register);
router.post('/login', authRateLimiter, validate({ body: loginSchema }), authController.login);
router.post('/refresh', validate({ body: refreshTokenSchema }), authController.refreshToken);
router.post('/logout', validate({ body: logoutSchema }), authController.logout);

router.post('/send-otp', otpRateLimiter, validate({ body: sendOtpSchema }), authController.sendOtp);
router.post('/verify-email', validate({ body: verifyEmailSchema }), authController.verifyEmail);
router.post('/verify-phone', validate({ body: verifyPhoneSchema }), authController.verifyPhone);
router.post('/verify-otp', validate({ body: verifyOtpSchema }), authController.verifyOtp);

router.post('/forgot-password', authRateLimiter, validate({ body: forgotPasswordSchema }), authController.forgotPassword);
router.post('/reset-password', validate({ body: resetPasswordSchema }), authController.resetPassword);

router.post('/biometric/register', authenticate, validate({ body: registerBiometricSchema }), authController.registerBiometric);
router.post('/biometric/login', validate({ body: biometricLoginSchema }), authController.biometricLogin);

export default router;
