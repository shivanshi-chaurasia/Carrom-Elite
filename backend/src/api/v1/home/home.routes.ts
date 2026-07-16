import { Router } from 'express';
import { homeController } from './home.controller';
import { authenticate } from '../../../middlewares/auth.middleware';
import { validate } from '../../../middlewares/validate.middleware';
import {
  dashboardQuerySchema,
  bannersQuerySchema,
  eventsQuerySchema,
  newsQuerySchema,
  gamesQuerySchema,
} from '../../../validators/home.validator';

const router = Router();

/**
 * @swagger
 * /home/dashboard:
 *   get:
 *     summary: Get home dashboard with aggregated data
 *     tags: [Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: includeMatches
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include active matches
 *       - in: query
 *         name: includeTournaments
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include active tournaments
 *       - in: query
 *         name: includeLotteries
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include active lotteries
 *       - in: query
 *         name: includeRewards
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include recent rewards
 *       - in: query
 *         name: includeGames
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include available games
 *       - in: query
 *         name: includeBanners
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include promo banners
 *       - in: query
 *         name: includeEvents
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include events
 *       - in: query
 *         name: includeNews
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Include news
 *     responses:
 *       200:
 *         description: Dashboard data fetched successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     player:
 *                       type: object
 *                     wallet:
 *                       type: object
 *                     activeMatches:
 *                       type: array
 *                       items:
 *                         type: object
 *                     activeTournaments:
 *                       type: array
 *                       items:
 *                         type: object
 *                     activeLotteries:
 *                       type: array
 *                       items:
 *                         type: object
 *                     recentRewards:
 *                       type: array
 *                       items:
 *                         type: object
 *                     games:
 *                       type: array
 *                       items:
 *                         type: object
 *                     banners:
 *                       type: array
 *                       items:
 *                         type: object
 *                     events:
 *                       type: array
 *                       items:
 *                         type: object
 *                     news:
 *                       type: array
 *                       items:
 *                         type: object
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 */
router.get(
  '/dashboard',
  authenticate,
  validate({ query: dashboardQuerySchema }),
  homeController.getDashboard,
);

/**
 * @swagger
 * /home/banners:
 *   get:
 *     summary: Get active promo banners
 *     tags: [Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: Banners fetched successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/PromoBanner'
 *                 meta:
 *                   $ref: '#/components/schemas/Pagination'
 */
router.get(
  '/banners',
  authenticate,
  validate({ query: bannersQuerySchema }),
  homeController.getBanners,
);

/**
 * @swagger
 * /home/events:
 *   get:
 *     summary: Get active events
 *     tags: [Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *       - in: query
 *         name: upcoming
 *         schema:
 *           type: string
 *           enum: [true, false]
 *         description: Filter to upcoming events only
 *     responses:
 *       200:
 *         description: Events fetched successfully
 */
router.get(
  '/events',
  authenticate,
  validate({ query: eventsQuerySchema }),
  homeController.getEvents,
);

/**
 * @swagger
 * /home/news:
 *   get:
 *     summary: Get latest news
 *     tags: [Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: News fetched successfully
 */
router.get(
  '/news',
  authenticate,
  validate({ query: newsQuerySchema }),
  homeController.getNews,
);

/**
 * @swagger
 * /home/games:
 *   get:
 *     summary: Get available games
 *     tags: [Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: Filter by game category
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Games fetched successfully
 */
router.get(
  '/games',
  authenticate,
  validate({ query: gamesQuerySchema }),
  homeController.getGames,
);

export default router;
