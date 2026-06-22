export enum UserRole {
  USER = 'USER',
  ADMIN = 'ADMIN',
  SUPER_ADMIN = 'SUPER_ADMIN',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  BANNED = 'BANNED',
  DELETED = 'DELETED',
}

export enum KycStatus {
  PENDING = 'PENDING',
  SUBMITTED = 'SUBMITTED',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export enum TransactionType {
  DEPOSIT = 'DEPOSIT',
  WITHDRAWAL = 'WITHDRAWAL',
  REFUND = 'REFUND',
  BONUS = 'BONUS',
  CASHBACK = 'CASHBACK',
  REFERRAL_BONUS = 'REFERRAL_BONUS',
  MATCH_FEE = 'MATCH_FEE',
  MATCH_WINNING = 'MATCH_WINNING',
  LOTTERY_PURCHASE = 'LOTTERY_PURCHASE',
  LOTTERY_WINNING = 'LOTTERY_WINNING',
  ADMIN_CREDIT = 'ADMIN_CREDIT',
  ADMIN_DEBIT = 'ADMIN_DEBIT',
}

export enum TransactionStatus {
  PENDING = 'PENDING',
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED',
  REFUNDED = 'REFUNDED',
}

export enum MatchStatus {
  WAITING = 'WAITING',
  READY = 'READY',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
  TIMEOUT = 'TIMEOUT',
}

export enum MatchType {
  PUBLIC = 'PUBLIC',
  PRIVATE = 'PRIVATE',
  TOURNAMENT = 'TOURNAMENT',
}

export enum TournamentStatus {
  UPCOMING = 'UPCOMING',
  REGISTRATION_OPEN = 'REGISTRATION_OPEN',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

export enum LotteryStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  DRAWING = 'DRAWING',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

export enum TicketStatus {
  ACTIVE = 'ACTIVE',
  WON = 'WON',
  LOST = 'LOST',
  REFUNDED = 'REFUNDED',
}

export enum NotificationType {
  PUSH = 'PUSH',
  EMAIL = 'EMAIL',
  SMS = 'SMS',
  IN_APP = 'IN_APP',
}

export enum NotificationCategory {
  REWARD = 'REWARD',
  MATCH_INVITE = 'MATCH_INVITE',
  MATCH_RESULT = 'MATCH_RESULT',
  WALLET = 'WALLET',
  LOTTERY = 'LOTTERY',
  SYSTEM = 'SYSTEM',
  SOCIAL = 'SOCIAL',
}

export enum FriendStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  BLOCKED = 'BLOCKED',
}

export enum SupportTicketStatus {
  OPEN = 'OPEN',
  IN_PROGRESS = 'IN_PROGRESS',
  RESOLVED = 'RESOLVED',
  CLOSED = 'CLOSED',
}

export enum TicketPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT',
}

export enum AuditAction {
  CREATE = 'CREATE',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE',
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  BAN = 'BAN',
  UNBAN = 'UNBAN',
  KYC_APPROVE = 'KYC_APPROVE',
  KYC_REJECT = 'KYC_REJECT',
  WALLET_CREDIT = 'WALLET_CREDIT',
  WALLET_DEBIT = 'WALLET_DEBIT',
  SETTINGS_CHANGE = 'SETTINGS_CHANGE',
}

export enum DevicePlatform {
  ANDROID = 'ANDROID',
  IOS = 'IOS',
  WEB = 'WEB',
}

export enum Language {
  EN = 'EN',
  HI = 'HI',
  TA = 'TA',
  TE = 'TE',
  KN = 'KN',
  ML = 'ML',
  MR = 'MR',
  GU = 'GU',
  BN = 'BN',
}

export enum Theme {
  LIGHT = 'LIGHT',
  DARK = 'DARK',
  SYSTEM = 'SYSTEM',
}

export enum PaymentGateway {
  RAZORPAY = 'RAZORPAY',
  PAYTM = 'PAYTM',
  PHONEPE = 'PHONEPE',
  STRIPE = 'STRIPE',
  MANUAL = 'MANUAL',
}
