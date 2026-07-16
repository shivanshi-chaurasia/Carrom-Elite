import { z } from 'zod';
import type { ValidationSchemas } from '../middlewares/validate.middleware';

export const joinMatchQueueSchema: ValidationSchemas = {
  body: z.object({
    entryFee: z.number().positive().max(100000),
  }),
};

export const createPrivateMatchSchema: ValidationSchemas = {
  body: z.object({
    entryFee: z.number().positive().max(100000).optional().default(0),
    maxPlayers: z.number().int().min(2).max(4).optional().default(2),
  }),
};

export const joinPrivateMatchSchema: ValidationSchemas = {
  params: z.object({
    roomCode: z.string().min(4).max(20),
  }),
};

export const submitMoveSchema: ValidationSchemas = {
  body: z.object({
    matchId: z.string().uuid(),
    moveData: z.object({
      aimAngle: z.number().min(0).max(360),
      force: z.number().min(0).max(100),
      strikerPosition: z.object({
        x: z.number(),
        y: z.number(),
      }),
      pocketedCoinIds: z.array(z.string()),
      isFoul: z.boolean(),
    }),
  }),
};

export const matchIdParamSchema: ValidationSchemas = {
  params: z.object({
    matchId: z.string().uuid(),
  }),
};

export const surrenderSchema: ValidationSchemas = {
  params: z.object({
    matchId: z.string().uuid(),
  }),
  body: z.object({
    reason: z.string().max(200).optional(),
  }),
};
