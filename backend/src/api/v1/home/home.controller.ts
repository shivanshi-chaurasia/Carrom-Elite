import { Request, Response } from 'express';
import { asyncHandler } from '../../../utils/async-handler';
import { sendSuccess } from '../../../utils/api-response';
import { homeService } from './home.service';
import { MESSAGES } from '../../../constants/messages';

export class HomeController {
  getDashboard = asyncHandler(async (req: Request, res: Response) => {
    const dashboard = await homeService.getDashboard(req.user!.id);
    sendSuccess(res, dashboard, MESSAGES.DASHBOARD_FETCHED, undefined, req.correlationId);
  });

  getBanners = asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const page = parseInt(query.page, 10) || 1;
    const limit = parseInt(query.limit, 10) || 10;
    const result = await homeService.getBanners(page, limit);
    sendSuccess(res, result.data, MESSAGES.BANNERS_FETCHED, undefined, req.correlationId, result.meta);
  });

  getEvents = asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const page = parseInt(query.page, 10) || 1;
    const limit = parseInt(query.limit, 10) || 10;
    const upcoming = query.upcoming === 'true';
    const result = await homeService.getEvents(page, limit, upcoming);
    sendSuccess(res, result.data, MESSAGES.EVENTS_FETCHED, undefined, req.correlationId, result.meta);
  });

  getNews = asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const page = parseInt(query.page, 10) || 1;
    const limit = parseInt(query.limit, 10) || 10;
    const result = await homeService.getNews(page, limit);
    sendSuccess(res, result.data, MESSAGES.NEWS_FETCHED, undefined, req.correlationId, result.meta);
  });

  getGames = asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const category = query.category;
    const page = parseInt(query.page, 10) || 1;
    const limit = parseInt(query.limit, 10) || 20;
    const result = await homeService.getGames(category, page, limit);
    sendSuccess(res, result.data, MESSAGES.GAMES_FETCHED, undefined, req.correlationId, result.meta);
  });
}

export const homeController = new HomeController();
