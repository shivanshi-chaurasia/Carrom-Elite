import { Request, Response } from 'express';
import { asyncHandler } from '../../../utils/async-handler';
import { sendSuccess, sendCreated } from '../../../utils/api-response';
import { authService } from './auth.service';
import { MESSAGES } from '../../../constants/messages';

export class AuthController {
  register = asyncHandler(async (req: Request, res: Response) => {
    const result = await authService.register(req.body);
    sendCreated(res, result, MESSAGES.REGISTER_SUCCESS, req.correlationId);
  });

  login = asyncHandler(async (req: Request, res: Response) => {
    const result = await authService.login(req.body);
    sendSuccess(res, result, MESSAGES.LOGIN_SUCCESS, undefined, req.correlationId);
  });

  sendOtp = asyncHandler(async (req: Request, res: Response) => {
    const { email, phone, purpose } = req.body;
    const identifier = email || phone!;
    const type = email ? 'email' : 'phone';
    await authService.sendOtp(identifier, purpose, type);
    sendSuccess(res, null, MESSAGES.OTP_SENT, undefined, req.correlationId);
  });

  verifyEmail = asyncHandler(async (req: Request, res: Response) => {
    const { email, otp } = req.body;
    await authService.verifyEmail(email, otp);
    sendSuccess(res, null, MESSAGES.EMAIL_VERIFIED, undefined, req.correlationId);
  });

  verifyPhone = asyncHandler(async (req: Request, res: Response) => {
    const { phone, otp } = req.body;
    await authService.verifyPhone(phone, otp);
    sendSuccess(res, null, MESSAGES.OTP_VERIFIED, undefined, req.correlationId);
  });

  verifyOtp = asyncHandler(async (req: Request, res: Response) => {
    const { email, phone, otp, purpose } = req.body;
    const identifier = email || phone!;
    const isValid = await authService.verifyOtp(identifier, purpose, otp);
    sendSuccess(res, { verified: isValid }, isValid ? MESSAGES.OTP_VERIFIED : MESSAGES.OTP_INVALID, undefined, req.correlationId);
  });

  forgotPassword = asyncHandler(async (req: Request, res: Response) => {
    const { email } = req.body;
    await authService.forgotPassword(email);
    sendSuccess(res, null, MESSAGES.PASSWORD_RESET_SENT, undefined, req.correlationId);
  });

  resetPassword = asyncHandler(async (req: Request, res: Response) => {
    const { token, password } = req.body;
    await authService.resetPassword(token, password);
    sendSuccess(res, null, MESSAGES.PASSWORD_RESET_SUCCESS, undefined, req.correlationId);
  });

  registerBiometric = asyncHandler(async (req: Request, res: Response) => {
    const { password, deviceId } = req.body;
    await authService.registerBiometric(req.user!.id, password, deviceId);
    sendSuccess(res, null, MESSAGES.BIOMETRIC_KEY_REGISTERED, undefined, req.correlationId);
  });

  biometricLogin = asyncHandler(async (req: Request, res: Response) => {
    const { biometricKey, deviceId, platform, fcmToken } = req.body;
    const result = await authService.biometricLogin(biometricKey, deviceId, platform, fcmToken);
    sendSuccess(res, result, MESSAGES.LOGIN_SUCCESS, undefined, req.correlationId);
  });
}

export const authController = new AuthController();
