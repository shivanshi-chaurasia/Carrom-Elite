export interface PlayerSummaryDto {
  id: string;
  username: string;
  avatar: string | null;
  email: string;
  phone: string | null;
  role: string;
  status: string;
  isKycCompleted: boolean;
  totalMatches: number;
  totalWins: number;
  winRate: number;
  currentRank: number | null;
}

export interface WalletSummaryDto {
  balance: number;
  bonusBalance: number;
  cashbackBalance: number;
  totalDeposited: number;
  totalWinnings: number;
}

export interface MatchSummaryDto {
  id: string;
  type: string;
  status: string;
  entryFee: number;
  prizePool: number;
  maxPlayers: number;
  playerCount: number;
  startedAt: Date | null;
  createdAt: Date;
}

export interface TournamentSummaryDto {
  id: string;
  name: string;
  entryFee: number;
  prizePool: number;
  maxParticipants: number;
  registeredCount: number;
  status: string;
  startTime: Date;
}

export interface LotterySummaryDto {
  id: string;
  name: string;
  ticketPrice: number;
  jackpotAmount: number;
  totalTickets: number;
  soldTickets: number;
  status: string;
  drawTime: Date;
}

export interface RewardSummaryDto {
  id: string;
  type: string;
  coins: number;
  description: string | null;
  claimedAt: Date;
}

export interface GameDto {
  id: string;
  name: string;
  description: string | null;
  image: string | null;
  category: string | null;
  sortOrder: number;
}

export interface PromoBannerDto {
  id: string;
  title: string;
  description: string | null;
  image: string | null;
  link: string | null;
  linkType: string | null;
  sortOrder: number;
}

export interface EventDto {
  id: string;
  title: string;
  description: string | null;
  image: string | null;
  startDate: Date;
  endDate: Date | null;
  location: string | null;
}

export interface NewsDto {
  id: string;
  title: string;
  summary: string | null;
  image: string | null;
  source: string | null;
  publishedAt: Date | null;
}

export interface HomeDashboardDto {
  player: PlayerSummaryDto;
  wallet: WalletSummaryDto;
  activeMatches: MatchSummaryDto[];
  activeTournaments: TournamentSummaryDto[];
  activeLotteries: LotterySummaryDto[];
  recentRewards: RewardSummaryDto[];
  games: GameDto[];
  banners: PromoBannerDto[];
  events: EventDto[];
  news: NewsDto[];
}

export function toPlayerSummaryDto(user: any): PlayerSummaryDto {
  return {
    id: user.id,
    username: user.username,
    avatar: user.avatar,
    email: user.email,
    phone: user.phone,
    role: user.role,
    status: user.status,
    isKycCompleted: user.isKycCompleted,
    totalMatches: user.leaderboardEntries?.[0]?.totalMatches ?? 0,
    totalWins: user.leaderboardEntries?.[0]?.totalWins ?? 0,
    winRate: user.leaderboardEntries?.[0]?.winRate ?? 0,
    currentRank: user.leaderboardEntries?.[0]?.rank ?? null,
  };
}

export function toWalletSummaryDto(wallet: any): WalletSummaryDto {
  return {
    balance: Number(wallet.balance),
    bonusBalance: Number(wallet.bonusBalance),
    cashbackBalance: Number(wallet.cashbackBalance),
    totalDeposited: Number(wallet.totalDeposited),
    totalWinnings: Number(wallet.totalWinnings),
  };
}

export function toMatchSummaryDto(match: any): MatchSummaryDto {
  return {
    id: match.id,
    type: match.type,
    status: match.status,
    entryFee: Number(match.entryFee),
    prizePool: Number(match.prizePool),
    maxPlayers: match.maxPlayers,
    playerCount: match.players?.length ?? 0,
    startedAt: match.startedAt,
    createdAt: match.createdAt,
  };
}

export function toTournamentSummaryDto(tournament: any): TournamentSummaryDto {
  return {
    id: tournament.id,
    name: tournament.name,
    entryFee: Number(tournament.entryFee),
    prizePool: Number(tournament.prizePool),
    maxParticipants: tournament.maxParticipants,
    registeredCount: tournament.registrations?.length ?? 0,
    status: tournament.status,
    startTime: tournament.startTime,
  };
}

export function toLotterySummaryDto(lottery: any): LotterySummaryDto {
  return {
    id: lottery.id,
    name: lottery.name,
    ticketPrice: Number(lottery.ticketPrice),
    jackpotAmount: Number(lottery.jackpotAmount),
    totalTickets: lottery.totalTickets,
    soldTickets: lottery.soldTickets,
    status: lottery.status,
    drawTime: lottery.drawTime,
  };
}

export function toRewardSummaryDto(reward: any): RewardSummaryDto {
  return {
    id: reward.id,
    type: reward.type,
    coins: reward.coins,
    description: reward.description,
    claimedAt: reward.claimedAt,
  };
}

export function toGameDto(game: any): GameDto {
  return {
    id: game.id,
    name: game.name,
    description: game.description,
    image: game.image,
    category: game.category,
    sortOrder: game.sortOrder,
  };
}

export function toPromoBannerDto(banner: any): PromoBannerDto {
  return {
    id: banner.id,
    title: banner.title,
    description: banner.description,
    image: banner.image,
    link: banner.link,
    linkType: banner.linkType,
    sortOrder: banner.sortOrder,
  };
}

export function toEventDto(event: any): EventDto {
  return {
    id: event.id,
    title: event.title,
    description: event.description,
    image: event.image,
    startDate: event.startDate,
    endDate: event.endDate,
    location: event.location,
  };
}

export function toNewsDto(news: any): NewsDto {
  return {
    id: news.id,
    title: news.title,
    summary: news.summary,
    image: news.image,
    source: news.source,
    publishedAt: news.publishedAt,
  };
}
