export const MESSAGES = {
  // Auth
  REGISTER_SUCCESS: 'Registration successful. Please verify your email.',
  LOGIN_SUCCESS: 'Login successful.',
  LOGOUT_SUCCESS: 'Logout successful.',
  TOKEN_REFRESH_SUCCESS: 'Token refreshed successfully.',
  EMAIL_VERIFIED: 'Email verified successfully.',
  OTP_SENT: 'OTP sent successfully.',
  OTP_VERIFIED: 'OTP verified successfully.',
  OTP_EXPIRED: 'OTP has expired. Please request a new one.',
  OTP_INVALID: 'Invalid OTP. Please try again.',
  OTP_MAX_ATTEMPTS: 'Maximum OTP attempts exceeded. Please try again later.',
  PASSWORD_RESET_SENT: 'Password reset link sent to your email.',
  PASSWORD_RESET_SUCCESS: 'Password reset successfully.',
  PASSWORD_CHANGED: 'Password changed successfully.',
  BIOMETRIC_KEY_REGISTERED: 'Biometric key registered successfully.',

  // User
  PROFILE_FETCHED: 'Profile fetched successfully.',
  PROFILE_UPDATED: 'Profile updated successfully.',
  KYC_SUBMITTED: 'KYC documents submitted successfully.',
  KYC_APPROVED: 'KYC verified successfully.',
  KYC_REJECTED: 'KYC verification rejected.',
  BANK_ADDED: 'Bank account added successfully.',
  BANK_UPDATED: 'Bank account updated successfully.',
  BANK_DELETED: 'Bank account removed successfully.',
  UPI_ADDED: 'UPI account added successfully.',
  UPI_DELETED: 'UPI account removed successfully.',

  // Wallet
  WALLET_FETCHED: 'Wallet details fetched successfully.',
  DEPOSIT_SUCCESS: 'Money added to wallet successfully.',
  WITHDRAWAL_SUCCESS: 'Withdrawal request submitted successfully.',
  WITHDRAWAL_OTP_SENT: 'Withdrawal OTP sent to registered email/phone.',
  TRANSACTION_HISTORY: 'Transaction history fetched successfully.',
  INSUFFICIENT_BALANCE: 'Insufficient wallet balance.',
  WITHDRAWAL_LIMIT: 'Withdrawal amount exceeds the allowed limit.',

  // Rewards
  REWARD_CLAIMED: 'Reward claimed successfully.',
  DAILY_REWARD_CLAIMED: 'Daily reward claimed successfully.',
  DAILY_REWARD_ALREADY_CLAIMED: 'Daily reward already claimed today.',
  REFERRAL_BONUS_CREDITED: 'Referral bonus credited to your wallet.',

  // Carrom
  MATCH_CREATED: 'Match created successfully.',
  ROOM_JOINED: 'Joined room successfully.',
  ROOM_LEFT: 'Left room successfully.',
  MATCH_STARTED: 'Match started! Good luck!',
  MATCH_COMPLETED: 'Match completed.',
  MATCH_CANCELLED: 'Match cancelled.',
  PLAYER_READY: 'Player is ready.',
  INVALID_MOVE: 'Invalid move.',
  NOT_YOUR_TURN: 'It is not your turn.',

  // Lottery
  TICKET_PURCHASED: 'Lottery ticket purchased successfully.',
  LOTTERY_RESULTS: 'Lottery results fetched successfully.',
  JACKPOT_AMOUNT: 'Current jackpot amount fetched successfully.',
  TICKET_LIMIT_REACHED: 'Maximum ticket limit reached for this lottery.',

  // Social
  FRIEND_REQUEST_SENT: 'Friend request sent.',
  FRIEND_REQUEST_ACCEPTED: 'Friend request accepted.',
  FRIEND_REQUEST_REJECTED: 'Friend request rejected.',
  FRIEND_REMOVED: 'Friend removed successfully.',
  USER_BLOCKED: 'User blocked successfully.',
  USER_UNBLOCKED: 'User unblocked successfully.',
  REPORT_SUBMITTED: 'Report submitted successfully.',

  // Support
  TICKET_CREATED: 'Support ticket created successfully.',
  TICKET_RESPONSE_ADDED: 'Response added to ticket.',
  FEEDBACK_SUBMITTED: 'Feedback submitted. Thank you!',

  // Settings
  SETTINGS_UPDATED: 'Settings updated successfully.',
  TWO_FACTOR_ENABLED: 'Two-factor authentication enabled.',
  TWO_FACTOR_DISABLED: 'Two-factor authentication disabled.',

  // Admin
  USER_BANNED: 'User banned successfully.',
  USER_UNBANNED: 'User unbanned successfully.',
  TOURNAMENT_CREATED: 'Tournament created successfully.',
  TOURNAMENT_UPDATED: 'Tournament updated successfully.',
  LOTTERY_CREATED: 'Lottery draw created successfully.',
  PUSH_SENT: 'Push notification sent successfully.',

  // Errors
  UNAUTHORIZED: 'Unauthorized access. Please login.',
  FORBIDDEN: 'You do not have permission to perform this action.',
  NOT_FOUND: 'Resource not found.',
  VALIDATION_ERROR: 'Validation error.',
  INTERNAL_ERROR: 'Internal server error. Please try again later.',
  EMAIL_EXISTS: 'An account with this email already exists.',
  PHONE_EXISTS: 'An account with this phone number already exists.',
  USERNAME_EXISTS: 'This username is already taken.',
  INVALID_CREDENTIALS: 'Invalid email or password.',
  ACCOUNT_BANNED: 'Your account has been banned. Contact support.',
  ACCOUNT_INACTIVE: 'Your account is inactive.',
  SESSION_EXPIRED: 'Session expired. Please login again.',
  INVALID_REFRESH_TOKEN: 'Invalid refresh token.',
  DEVICE_NOT_VERIFIED: 'Device not verified.',
  EMAIL_NOT_VERIFIED: 'Please verify your email first.',
  PHONE_NOT_VERIFIED: 'Please verify your phone number first.',
  KYC_NOT_COMPLETED: 'KYC verification not completed.',
  KYC_ALREADY_SUBMITTED: 'KYC documents already submitted.',
  INVALID_FILE_TYPE: 'Invalid file type.',
  FILE_TOO_LARGE: 'File size exceeds the maximum limit.',
  RATE_LIMIT_EXCEEDED: 'Too many requests. Please try again later.',

  // Home / Dashboard
  DASHBOARD_FETCHED: 'Dashboard data fetched successfully.',
  BANNERS_FETCHED: 'Promo banners fetched successfully.',
  EVENTS_FETCHED: 'Events fetched successfully.',
  NEWS_FETCHED: 'News fetched successfully.',
  GAMES_FETCHED: 'Games fetched successfully.',
} as const;
