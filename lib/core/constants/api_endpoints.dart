class ApiEndpoints {
  static const baseUrl = 'http://localhost:8080/api/v1';

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';
  static const sendOtp = '/auth/send-otp';
  static const verifyEmail = '/auth/verify-email';
  static const verifyPhone = '/auth/verify-phone';
  static const verifyOtp = '/auth/verify-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const biometricRegister = '/auth/biometric/register';
  static const biometricLogin = '/auth/biometric/login';

  // Home
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
