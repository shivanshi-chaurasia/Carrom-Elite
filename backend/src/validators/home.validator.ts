import { z } from 'zod';

export const dashboardQuerySchema = z.object({
  includeMatches: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeTournaments: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeLotteries: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeRewards: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeGames: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeBanners: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeEvents: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  includeNews: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
});

export const bannersQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(50).optional().default(10),
});

export const eventsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(50).optional().default(10),
  upcoming: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
});

export const newsQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(50).optional().default(10),
});

export const gamesQuerySchema = z.object({
  category: z.string().optional(),
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(50).optional().default(20),
});
