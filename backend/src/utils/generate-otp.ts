// @ts-ignore
import otpGenerator from 'otp-generator';
import { config } from '../config';

interface OtpResult {
  otp: string;
  expiry: Date;
  hash: string;
}

export function generateOtp(): OtpResult {
  const otp = otpGenerator.generate(config.otp.length, {
    digits: true,
    lowerCaseAlphabets: false,
    upperCaseAlphabets: false,
    specialChars: false,
  });

  const expiry = new Date(Date.now() + config.otp.expiryMinutes * 60 * 1000);

  const hash = Buffer.from(`${otp}:${expiry.getTime()}`).toString('base64');

  return { otp, expiry, hash };
}

export function verifyOtp(otp: string, hash: string): boolean {
  try {
    const decoded = Buffer.from(hash, 'base64').toString('utf-8');
    const [storedOtp, expiryTime] = decoded.split(':');

    if (storedOtp !== otp) return false;
    if (Date.now() > parseInt(expiryTime, 10)) return false;

    return true;
  } catch {
    return false;
  }
}
