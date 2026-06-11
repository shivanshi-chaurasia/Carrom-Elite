class ApiEndpoints {
  static const baseUrl = 'https://api.carrompro.example.com/api/v1';

  static const refreshToken = '/auth/refresh';
  static const homeDashboard = '/home/dashboard';
  static const featuredGames = '/home/featured-games';
  static const tournamentBanners = '/home/tournaments';
  static const lotteryHighlights = '/home/lottery-highlights';
  static const dailyRewards = '/rewards/daily';
  static const quickMatch = '/matches/quick';
  static const eventPopups = '/home/events';
  
  // Tournaments
  static const tournamentDetails = '/tournaments';
  static const tournamentRegister = '/tournaments/register';
  static const tournamentBracket = '/tournaments/bracket';
  static const tournamentLeaderboard = '/tournaments/leaderboard';

  // Settings & Support
  static const notifications = '/settings/notifications';
  static const tickets = '/support/tickets';
  static const faq = '/support/faq';
  static const setup2FA = '/settings/2fa/setup';
  static const verify2FA = '/settings/2fa/verify';
}

