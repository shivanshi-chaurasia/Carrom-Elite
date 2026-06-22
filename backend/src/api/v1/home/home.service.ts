import { prisma } from '../../../config/database';
import { ApiError } from '../../../utils/api-error';
import {
  HomeDashboardDto,
  toPlayerSummaryDto,
  toWalletSummaryDto,
  toMatchSummaryDto,
  toTournamentSummaryDto,
  toLotterySummaryDto,
  toRewardSummaryDto,
  toGameDto,
  toPromoBannerDto,
  toEventDto,
  toNewsDto,
  PromoBannerDto,
  EventDto,
  NewsDto,
  GameDto,
} from '../../../dto/home.dto';
import { getPaginationParams, getPaginationMeta, getPrismaPagination } from '../../../utils/pagination';
import { PaginationMeta } from '../../../interfaces/response.interface';

export class HomeService {
  async getDashboard(userId: string): Promise<HomeDashboardDto> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        wallets: true,
        leaderboardEntries: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    const wallet = user.wallets[0];
    if (!wallet) {
      throw ApiError.notFound('Wallet not found');
    }

    const activeMatches = await prisma.match.findMany({
      where: {
        players: { some: { userId } },
        status: { in: ['WAITING', 'READY', 'IN_PROGRESS'] },
      },
      include: { players: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    const activeTournaments = await prisma.tournament.findMany({
      where: {
        registrations: { some: { userId, isActive: true } },
        status: { in: ['UPCOMING', 'REGISTRATION_OPEN', 'IN_PROGRESS'] },
      },
      include: { registrations: true },
      orderBy: { startTime: 'asc' },
      take: 5,
    });

    const activeLotteries = await prisma.lottery.findMany({
      where: {
        status: 'ACTIVE',
        drawTime: { gt: new Date() },
      },
      orderBy: { drawTime: 'asc' },
      take: 5,
    });

    const recentRewards = await prisma.reward.findMany({
      where: { userId },
      orderBy: { claimedAt: 'desc' },
      take: 10,
    });

    const games = await prisma.game.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });

    const banners = await prisma.promoBanner.findMany({
      where: {
        isActive: true,
        OR: [
          { startsAt: null },
          { startsAt: { lte: new Date() } },
        ],
        AND: [
          { OR: [{ expiresAt: null }, { expiresAt: { gte: new Date() } }] },
        ],
      },
      orderBy: { sortOrder: 'asc' },
    });

    const events = await prisma.event.findMany({
      where: {
        isActive: true,
        endDate: { gte: new Date() },
      },
      orderBy: { startDate: 'asc' },
      take: 5,
    });

    const news = await prisma.news.findMany({
      where: { isActive: true },
      orderBy: { publishedAt: 'desc' },
      take: 5,
    });

    return {
      player: toPlayerSummaryDto(user),
      wallet: toWalletSummaryDto(wallet),
      activeMatches: activeMatches.map(toMatchSummaryDto),
      activeTournaments: activeTournaments.map(toTournamentSummaryDto),
      activeLotteries: activeLotteries.map(toLotterySummaryDto),
      recentRewards: recentRewards.map(toRewardSummaryDto),
      games: games.map(toGameDto),
      banners: banners.map(toPromoBannerDto),
      events: events.map(toEventDto),
      news: news.map(toNewsDto),
    };
  }

  async getBanners(
    page: number,
    limit: number,
  ): Promise<{ data: PromoBannerDto[]; meta: PaginationMeta }> {
    const where = {
      isActive: true,
      OR: [{ startsAt: null }, { startsAt: { lte: new Date() } }],
      AND: [{ OR: [{ expiresAt: null }, { expiresAt: { gte: new Date() } }] }],
    };

    const [banners, total] = await Promise.all([
      prisma.promoBanner.findMany({
        where,
        orderBy: { sortOrder: 'asc' },
        ...getPrismaPagination(page, limit),
      }),
      prisma.promoBanner.count({ where }),
    ]);

    return {
      data: banners.map(toPromoBannerDto),
      meta: getPaginationMeta(total, page, limit),
    };
  }

  async getEvents(
    page: number,
    limit: number,
    upcoming: boolean,
  ): Promise<{ data: EventDto[]; meta: PaginationMeta }> {
    const where: any = { isActive: true };
    if (upcoming) {
      where.endDate = { gte: new Date() };
    }

    const [events, total] = await Promise.all([
      prisma.event.findMany({
        where,
        orderBy: { startDate: 'asc' },
        ...getPrismaPagination(page, limit),
      }),
      prisma.event.count({ where }),
    ]);

    return {
      data: events.map(toEventDto),
      meta: getPaginationMeta(total, page, limit),
    };
  }

  async getNews(
    page: number,
    limit: number,
  ): Promise<{ data: NewsDto[]; meta: PaginationMeta }> {
    const where = { isActive: true };

    const [newsItems, total] = await Promise.all([
      prisma.news.findMany({
        where,
        orderBy: { publishedAt: 'desc' },
        ...getPrismaPagination(page, limit),
      }),
      prisma.news.count({ where }),
    ]);

    return {
      data: newsItems.map(toNewsDto),
      meta: getPaginationMeta(total, page, limit),
    };
  }

  async getGames(
    category?: string,
    page?: number,
    limit?: number,
  ): Promise<{ data: GameDto[]; meta: PaginationMeta }> {
    const where: any = { isActive: true };
    if (category) {
      where.category = category;
    }

    const { page: p, limit: l } = getPaginationParams({ page, limit });

    const [games, total] = await Promise.all([
      prisma.game.findMany({
        where,
        orderBy: { sortOrder: 'asc' },
        ...getPrismaPagination(p, l),
      }),
      prisma.game.count({ where }),
    ]);

    return {
      data: games.map(toGameDto),
      meta: getPaginationMeta(total, p, l),
    };
  }
}

export const homeService = new HomeService();
