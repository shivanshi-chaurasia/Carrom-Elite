import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '8080', 10),
  host: process.env.HOST || '0.0.0.0',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  requestTimeout: parseInt(process.env.REQUEST_TIMEOUT || '30000', 10),

  database: {
    url: process.env.DATABASE_URL!,
  },

  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    username: process.env.REDIS_USERNAME || undefined,
    password: process.env.REDIS_PASSWORD || undefined,
    db: parseInt(process.env.REDIS_DB || '0', 10),
  },

  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET!,
    refreshSecret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET!,
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },

  bcrypt: {
    saltRounds: parseInt(process.env.BCRYPT_SALT_ROUNDS || '12', 10),
  },

  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME!,
    apiKey: process.env.CLOUDINARY_API_KEY!,
    apiSecret: process.env.CLOUDINARY_API_SECRET!,
    folder: process.env.CLOUDINARY_FOLDER || 'carrom-lottery',
  },

  smtp: {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    secure: process.env.SMTP_SECURE === 'true',
    user: process.env.SMTP_USER!,
    pass: process.env.SMTP_PASS!,
    from: process.env.EMAIL_FROM || 'noreply@carromlottery.com',
  },

  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID!,
    privateKey: process.env.FIREBASE_PRIVATE_KEY!,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
    databaseURL: process.env.FIREBASE_DATABASE_URL!,
  },

  otp: {
    length: parseInt(process.env.OTP_LENGTH || '6', 10),
    expiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES || '10', 10),
    resendCooldownSeconds: parseInt(process.env.OTP_RESEND_COOLDOWN_SECONDS || '30', 10),
    maxAttempts: parseInt(process.env.MAX_OTP_ATTEMPTS || '5', 10),
  },

  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '5242880', 10),
    allowedTypes: (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/webp,application/pdf').split(','),
  },

  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
    authWindowMs: parseInt(process.env.AUTH_RATE_LIMIT_WINDOW_MS || '900000', 10),
    authMaxRequests: parseInt(process.env.AUTH_RATE_LIMIT_MAX_REQUESTS || '10', 10),
  },

  cors: {
    origin: (process.env.CORS_ORIGIN || 'http://localhost:3000').split(','),
    methods: process.env.CORS_METHODS || 'GET,POST,PUT,PATCH,DELETE',
    credentials: process.env.CORS_CREDENTIALS === 'true',
  },

  currency: {
    code: process.env.CURRENCY || 'INR',
    minDeposit: parseFloat(process.env.MIN_DEPOSIT || '10'),
    maxDeposit: parseFloat(process.env.MAX_DEPOSIT || '100000'),
    minWithdrawal: parseFloat(process.env.MIN_WITHDRAWAL || '50'),
    maxWithdrawal: parseFloat(process.env.MAX_WITHDRAWAL || '50000'),
  },

  referral: {
    bonusAmount: parseFloat(process.env.REFERRAL_BONUS_AMOUNT || '50'),
    minWithdrawal: parseFloat(process.env.REFERRAL_MIN_WITHDRAWAL || '100'),
    codeLength: parseInt(process.env.REFERRAL_CODE_LENGTH || '8', 10),
  },

  lottery: {
    ticketPrice: parseFloat(process.env.LOTTERY_TICKET_PRICE || '10'),
    maxTicketsPerUser: parseInt(process.env.LOTTERY_MAX_TICKETS_PER_USER || '100', 10),
    drawIntervalMinutes: parseInt(process.env.LOTTERY_DRAW_INTERVAL_MINUTES || '1440', 10),
    jackpotPercentage: parseInt(process.env.LOTTERY_JACKPOT_PERCENTAGE || '50', 10),
  },

  match: {
    timeoutMinutes: parseInt(process.env.MATCH_TIMEOUT_MINUTES || '5', 10),
    maxPlayersPerRoom: parseInt(process.env.MAX_PLAYERS_PER_ROOM || '4', 10),
    minimumEntryFee: parseFloat(process.env.MINIMUM_ENTRY_FEE || '0'),
  },

  rewards: {
    dailyRewardCoins: parseInt(process.env.DAILY_REWARD_COINS || '10', 10),
    weeklyRewardCoins: parseInt(process.env.WEEKLY_REWARD_COINS || '100', 10),
    vipBonusPercentage: parseInt(process.env.VIP_BONUS_PERCENTAGE || '20', 10),
  },

  logging: {
    level: process.env.LOG_LEVEL || 'debug',
    filePath: process.env.LOG_FILE_PATH || './logs',
    maxSize: process.env.LOG_MAX_SIZE || '10m',
    maxFiles: parseInt(process.env.LOG_MAX_FILES || '30', 10),
  },

  bullmq: {
    prefix: process.env.BULLMQ_PREFIX || 'carrom',
    defaultJobs: parseInt(process.env.BULLMQ_DEFAULT_JOBS || '10', 10),
    retryDelay: parseInt(process.env.BULLMQ_RETRY_DELAY || '5000', 10),
    maxRetries: parseInt(process.env.BULLMQ_MAX_RETRIES || '3', 10),
  },
} as const;
