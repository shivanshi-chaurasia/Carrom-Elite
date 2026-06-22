import crypto from 'crypto';

export function generateReferralCode(length: number = 8): string {
  return crypto
    .randomBytes(Math.ceil(length / 2))
    .toString('hex')
    .slice(0, length)
    .toUpperCase();
}

export function generateTransactionReference(): string {
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = crypto.randomBytes(4).toString('hex').toUpperCase();
  return `TXN${timestamp}${random}`;
}

export function generateSessionId(): string {
  return crypto.randomUUID();
}

export function generateBiometricKey(): string {
  return crypto.randomBytes(32).toString('hex');
}
