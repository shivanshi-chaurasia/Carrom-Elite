import { z } from 'zod';
import type { ValidationSchemas } from '../middlewares/validate.middleware';

export const depositSchema: ValidationSchemas = {
  body: z.object({
    amount: z.number().positive().min(1).max(100000),
    paymentGateway: z.enum(['RAZORPAY', 'PAYTM', 'PHONEPE', 'STRIPE']),
    paymentId: z.string().min(1),
  }),
};

export const withdrawSchema: ValidationSchemas = {
  body: z.object({
    amount: z.number().positive().min(1).max(50000),
    accountType: z.enum(['BANK', 'UPI']),
    accountId: z.string().uuid(),
    otp: z.string().length(6),
  }),
};

export const transferSchema: ValidationSchemas = {
  body: z.object({
    toUserId: z.string().uuid(),
    amount: z.number().positive().min(1).max(10000),
  }),
};

export const transactionHistorySchema: ValidationSchemas = {
  query: z.object({
    page: z.string().regex(/^\d+$/).optional().default('1'),
    limit: z.string().regex(/^\d+$/).optional().default('20'),
    type: z.string().optional(),
    status: z.string().optional(),
    startDate: z.string().datetime().optional(),
    endDate: z.string().datetime().optional(),
  }),
};
