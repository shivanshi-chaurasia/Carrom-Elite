import { EventEmitter } from 'events';
import { logger } from '../config/logger';

const eventEmitter = new EventEmitter();
eventEmitter.setMaxListeners(50);

export enum AppEvents {
  USER_REGISTERED = 'user.registered',
  USER_LOGGED_IN = 'user.logged_in',
  USER_LOGGED_OUT = 'user.logged_out',
  EMAIL_VERIFIED = 'email.verified',
  KYC_SUBMITTED = 'kyc.submitted',
  KYC_APPROVED = 'kyc.approved',
  KYC_REJECTED = 'kyc.rejected',
  DEPOSIT_SUCCESS = 'deposit.success',
  WITHDRAWAL_REQUESTED = 'withdrawal.requested',
  WITHDRAWAL_SUCCESS = 'withdrawal.success',
  MATCH_CREATED = 'match.created',
  MATCH_COMPLETED = 'match.completed',
  LOTTERY_PURCHASED = 'lottery.purchased',
  LOTTERY_DRAWN = 'lottery.drawn',
  REWARD_CLAIMED = 'reward.claimed',
  REFERRAL_BONUS = 'referral.bonus',
  FRIEND_REQUEST = 'friend.request',
  TICKET_CREATED = 'ticket.created',
}

export function registerEventListener(
  event: AppEvents,
  listener: (...args: unknown[]) => void,
): void {
  eventEmitter.on(event, listener);
  logger.debug(`Listener registered for event: ${event}`);
}

export function emitEvent(event: AppEvents, ...args: unknown[]): void {
  eventEmitter.emit(event, ...args);
  logger.debug(`Event emitted: ${event}`);
}

export default eventEmitter;
