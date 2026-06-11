import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/create_password_screen.dart';
import 'screens/auth/success_screen.dart';
import 'screens/permissions/storage_permission_screen.dart';
import 'screens/permissions/notification_permission_screen.dart';
import 'screens/permissions/microphone_permission_screen.dart';
import 'screens/permissions/camera_permission_screen.dart';
import 'screens/onboarding/verify_mobile_screen.dart';
import 'screens/onboarding/verify_email_screen.dart';
import 'screens/onboarding/referral_code_screen.dart';
import 'screens/onboarding/verify_device_screen.dart';
import 'screens/onboarding/biometric_setup_screen.dart';
import 'screens/profile/upload_profile_photo_screen.dart';
import 'screens/profile/selfie_verification_screen.dart';
import 'screens/profile/notification_settings_screen.dart';
import 'screens/profile/password_change_screen.dart';
import 'screens/profile/bank_details_screen.dart';
import 'screens/profile/kyc_verification_screen.dart';
import 'screens/profile/upload_documents_screen.dart';
import 'screens/home/daily_rewards_screen.dart';
import 'screens/home/event_popup_screen.dart';
import 'screens/home/featured_games_screen.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/home/lottery_highlights_screen.dart';
import 'screens/home/promotional_banner_details_screen.dart';
import 'screens/home/quick_match_entry_screen.dart';
import 'screens/home/tournament_banner_screen.dart';
import 'screens/tournament/tournament_details_screen.dart';
import 'screens/tournament/tournament_bracket_screen.dart';
import 'screens/tournament/tournament_winner_screen.dart';
import 'screens/game/carrom_home_screen.dart';
import 'screens/game/carrom_lobby_screen.dart';
import 'screens/game/carrom_match_screen.dart';
import 'screens/game/carrom_result_screen.dart';
import 'screens/lottery/lottery_home_screen.dart';
import 'screens/lottery/lottery_detail_screen.dart';
import 'screens/lottery/lottery_result_screen.dart';
import 'screens/lottery/ticket_history_screen.dart';
import 'screens/wallet/wallet_dashboard_screen.dart';
import 'screens/wallet/add_money_screen.dart';
import 'screens/wallet/withdraw_screen.dart';
import 'screens/wallet/transaction_history_screen.dart';
import 'screens/profile/profile_dashboard_screen.dart';
import 'screens/rewards/rewards_center_screen.dart';
import 'screens/rewards/vip_membership_screen.dart';
import 'screens/rewards/coin_conversion_screen.dart';
import 'screens/social/referral_program_screen.dart';
import 'screens/social/friends_list_screen.dart';
import 'screens/social/chat_screen.dart';
import 'screens/social/community_feed_screen.dart';
import 'widgets/common/mobile_screening_wrapper.dart';

// Phase 9 screens
import 'screens/settings/settings_dashboard_screen.dart';
import 'screens/settings/notification_center_screen.dart';
import 'screens/settings/sound_graphics_settings_screen.dart';
import 'screens/settings/two_factor_setup_screen.dart';
import 'screens/support/help_center_screen.dart';
import 'screens/support/raise_ticket_screen.dart';
import 'screens/support/live_chat_screen.dart';

// Additional Screen Bundle imports
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/game/practice_mode_screen.dart';
import 'screens/game/match_selection_screen.dart';
import 'screens/game/team_match_screen.dart';
import 'screens/game/spectator_mode_screen.dart';
import 'screens/game/match_statistics_screen.dart';
import 'screens/game/match_replay_screen.dart';
import 'screens/social/leaderboard_screen.dart';
import 'screens/rewards/daily_missions_screen.dart';
import 'screens/rewards/achievement_rewards_screen.dart';
import 'screens/lottery/buy_lottery_ticket_screen.dart';
import 'screens/lottery/active_lottery_screen.dart';
import 'screens/lottery/jackpot_lottery_screen.dart';
import 'screens/lottery/winner_announcement_screen.dart';
import 'screens/wallet/reward_claim_screen.dart';
import 'screens/wallet/bonus_wallet_screen.dart';
import 'screens/wallet/cashback_screen.dart';
import 'screens/wallet/gst_invoice_screen.dart';
import 'screens/support/faq_screen.dart';
import 'screens/support/contact_support_screen.dart';
import 'screens/support/ticket_history_screen.dart' as support_ticket;
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/account_settings_screen.dart';
import 'screens/profile/privacy_settings_screen.dart';
import 'screens/profile/linked_devices_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/social_login_screen.dart';
import 'screens/lottery/number_selection_screen.dart';
import 'screens/lottery/previous_winners_screen.dart';
import 'screens/wallet/withdrawal_otp_screen.dart';

class AppRoutes {
  // Home & Dashboard
  static const home = '/';
  static const featuredGames = '/featured-games';
  static const tournamentBanners = '/tournament-banners';
  static const lotteryHighlights = '/lottery-highlights';
  static const dailyRewards = '/daily-rewards';
  static const promoDetails = '/promo-details';
  static const quickMatch = '/quick-match';
  static const eventPopup = '/event-popup';
  
  // Tournaments Flow
  static const permTournamentDetails = '/tournament-details/:id';
  static const permTournamentBracket = '/tournament-bracket/:id';
  static const permTournamentWinner = '/tournament-winner/:id';
  
  // Carrom Game Flow
  static const carromHome = '/carrom-home';
  static const carromLobby = '/carrom-lobby';
  static const carromMatch = '/carrom-match';
  static const carromResult = '/carrom-result';
  
  // Lottery Flow
  static const lotteryHome = '/lottery-home';
  static const lotteryDetail = '/lottery-detail/:id';
  static const lotteryResults = '/lottery-results';
  static const lotteryTickets = '/lottery-tickets';
  
  // Wallet Flow
  static const walletDashboard = '/wallet-dashboard';
  static const addMoney = '/add-money';
  static const withdraw = '/withdraw';
  static const transactionHistory = '/transaction-history';

  // Profile, Rewards & Social Flow
  static const profile = '/profile';
  static const rewardsCenter = '/rewards-center';
  static const vipMembership = '/vip-membership';
  static const coinConversion = '/coin-conversion';
  static const referralProgram = '/referral-program';
  static const friendsList = '/friends';
  static const chat = '/chat/:friendId';
  static const communityFeed = '/community';

  // Auth Flow
  static const login = '/login';
  static const signUp = '/signup';
  static const otpVerify = '/otp-verify';
  static const createPassword = '/create-password';
  static const authSuccess = '/auth-success';

  // Permissions Flow
  static const permStorage = '/perm-storage';
  static const permNotification = '/perm-notification';
  static const permMicrophone = '/perm-microphone';
  static const permCamera = '/perm-camera';

  // Onboarding flow
  static const verifyMobile = '/verify-mobile';
  static const verifyEmail = '/verify-email';
  static const referralCode = '/referral-code';
  static const verifyDevice = '/verify-device';
  static const biometricSetup = '/biometric-setup';

  // Profile & KYC Flow
  static const profilePhoto = '/profile-photo';
  static const selfieVerify = '/selfie-verify';
  static const notifSettings = '/notif-settings';
  static const securitySettings = '/security-settings';
  static const bankDetails = '/bank-details';
  static const kycVerify = '/kyc-verify';
  static const uploadDocs = '/upload-docs';

  // Phase 9 Flow
  static const settingsDashboard = '/settings-dashboard';
  static const notificationCenter = '/notification-center';
  static const soundGraphics = '/sound-graphics';
  static const twoFactorSetup = '/two-factor-setup';
  static const helpCenter = '/help-center';
  static const raiseTicket = '/raise-ticket';
  static const liveChat = '/live-chat';

  // Additional Bundle routes
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const languageSelection = '/language-selection';
  static const practiceMode = '/practice-mode';
  static const matchSelection = '/match-selection';
  static const teamMatch = '/team-match';
  static const spectatorMode = '/spectator-mode';
  static const matchStats = '/match-stats';
  static const matchReplay = '/match-replay';
  static const leaderboard = '/leaderboard';
  static const dailyMissions = '/daily-missions';
  static const achievementRewards = '/achievement-rewards';
  static const buyLotteryTicket = '/buy-lottery';
  static const activeLottery = '/active-lottery';
  static const jackpotLottery = '/jackpot-lottery';
  static const winnerAnnouncement = '/winner-announcement';
  static const rewardClaim = '/reward-claim';
  static const bonusWallet = '/bonus-wallet';
  static const cashback = '/cashback';
  static const gstInvoice = '/gst-invoice';
  static const faq = '/faq';
  static const contactSupport = '/contact-support';
  static const ticketHistory = '/ticket-history';
  static const editProfile = '/edit-profile';
  static const accountSettings = '/account-settings';
  static const privacySettings = '/privacy-settings';
  static const linkedDevices = '/linked-devices';
  static const forgotPassword = '/forgot-password';
  static const socialLogin = '/social-login';
  static const lotteryNumberSelect = '/lottery-number-select';
  static const previousWinners = '/previous-winners';
  static const withdrawalOtp = '/withdrawal-otp';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Dashboard Routes
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (ctx, state) => _fade(state, const HomeDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.featuredGames,
      pageBuilder: (ctx, state) => _fade(state, const FeaturedGamesScreen()),
    ),
    GoRoute(
      path: AppRoutes.tournamentBanners,
      pageBuilder: (ctx, state) => _fade(state, const TournamentBannerScreen()),
    ),
    GoRoute(
      path: AppRoutes.lotteryHighlights,
      pageBuilder: (ctx, state) => _fade(state, const LotteryHighlightsScreen()),
    ),
    GoRoute(
      path: AppRoutes.dailyRewards,
      pageBuilder: (ctx, state) => _fade(state, const DailyRewardsScreen()),
    ),
    GoRoute(
      path: AppRoutes.promoDetails,
      pageBuilder: (ctx, state) => _fade(state, const PromotionalBannerDetailsScreen()),
    ),
    GoRoute(
      path: AppRoutes.quickMatch,
      pageBuilder: (ctx, state) => _fade(state, const QuickMatchEntryScreen()),
    ),
    GoRoute(
      path: AppRoutes.eventPopup,
      pageBuilder: (ctx, state) => _fade(state, const EventPopupScreen()),
    ),
    GoRoute(
      path: AppRoutes.permTournamentDetails,
      pageBuilder: (ctx, state) => _fade(
        state,
        TournamentDetailsScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.permTournamentBracket,
      pageBuilder: (ctx, state) => _fade(
        state,
        TournamentBracketScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.permTournamentWinner,
      pageBuilder: (ctx, state) => _fade(
        state,
        TournamentWinnerScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.carromHome,
      pageBuilder: (ctx, state) => _fade(state, const CarromHomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.carromLobby,
      pageBuilder: (ctx, state) => _fade(
        state,
        CarromLobbyScreen(
          fee: state.uri.queryParameters['fee'],
          mode: state.uri.queryParameters['mode'],
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.carromMatch,
      pageBuilder: (ctx, state) => _fade(
        state,
        CarromMatchScreen(
          mode: state.uri.queryParameters['mode'],
          matchId: state.uri.queryParameters['matchId'],
          roomCode: state.uri.queryParameters['roomCode'],
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.carromResult,
      pageBuilder: (ctx, state) => _fade(
        state,
        CarromResultScreen(
          winner: state.uri.queryParameters['winner'],
          mode: state.uri.queryParameters['mode'],
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.lotteryHome,
      pageBuilder: (ctx, state) => _fade(state, const LotteryHomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.lotteryDetail,
      pageBuilder: (ctx, state) => _fade(
        state,
        LotteryDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.lotteryResults,
      pageBuilder: (ctx, state) => _fade(state, const LotteryResultScreen()),
    ),
    GoRoute(
      path: AppRoutes.lotteryTickets,
      pageBuilder: (ctx, state) => _fade(state, const TicketHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.walletDashboard,
      pageBuilder: (ctx, state) => _fade(state, const WalletDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.addMoney,
      pageBuilder: (ctx, state) => _fade(state, const AddMoneyScreen()),
    ),
    GoRoute(
      path: AppRoutes.withdraw,
      pageBuilder: (ctx, state) => _fade(state, const WithdrawScreen()),
    ),
    GoRoute(
      path: AppRoutes.transactionHistory,
      pageBuilder: (ctx, state) => _fade(state, const TransactionHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (ctx, state) => _fade(state, const ProfileDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.rewardsCenter,
      pageBuilder: (ctx, state) => _fade(state, const RewardsCenterScreen()),
    ),
    GoRoute(
      path: AppRoutes.vipMembership,
      pageBuilder: (ctx, state) => _fade(state, const VipMembershipScreen()),
    ),
    GoRoute(
      path: AppRoutes.coinConversion,
      pageBuilder: (ctx, state) => _fade(state, const CoinConversionScreen()),
    ),
    GoRoute(
      path: AppRoutes.referralProgram,
      pageBuilder: (ctx, state) => _fade(state, const ReferralProgramScreen()),
    ),
    GoRoute(
      path: AppRoutes.friendsList,
      pageBuilder: (ctx, state) => _fade(state, const FriendsListScreen()),
    ),
    GoRoute(
      path: AppRoutes.chat,
      pageBuilder: (ctx, state) => _fade(
        state,
        ChatScreen(friendId: state.pathParameters['friendId'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.communityFeed,
      pageBuilder: (ctx, state) => _fade(state, const CommunityFeedScreen()),
    ),

    // Auth Routes
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (ctx, state) => _fade(state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      pageBuilder: (ctx, state) => _fade(state, const SignUpScreen()),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      pageBuilder: (ctx, state) => _fade(state, const OtpVerificationScreen()),
    ),
    GoRoute(
      path: AppRoutes.createPassword,
      pageBuilder: (ctx, state) => _fade(state, const CreatePasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.authSuccess,
      pageBuilder: (ctx, state) => _fade(state, const SuccessScreen()),
    ),

    // Permissions Routes
    GoRoute(
      path: AppRoutes.permStorage,
      pageBuilder: (ctx, state) => _fade(state, const StoragePermissionScreen()),
    ),
    GoRoute(
      path: AppRoutes.permNotification,
      pageBuilder: (ctx, state) => _fade(state, const NotificationPermissionScreen()),
    ),
    GoRoute(
      path: AppRoutes.permMicrophone,
      pageBuilder: (ctx, state) => _fade(state, const MicrophonePermissionScreen()),
    ),
    GoRoute(
      path: AppRoutes.permCamera,
      pageBuilder: (ctx, state) => _fade(state, const CameraPermissionScreen()),
    ),

    // Onboarding Routes
    GoRoute(
      path: AppRoutes.verifyMobile,
      pageBuilder: (ctx, state) => _fade(state, const VerifyMobileScreen()),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      pageBuilder: (ctx, state) => _fade(state, const VerifyEmailScreen()),
    ),
    GoRoute(
      path: AppRoutes.referralCode,
      pageBuilder: (ctx, state) => _fade(state, const ReferralCodeScreen()),
    ),
    GoRoute(
      path: AppRoutes.verifyDevice,
      pageBuilder: (ctx, state) => _fade(state, const VerifyDeviceScreen()),
    ),
    GoRoute(
      path: AppRoutes.biometricSetup,
      pageBuilder: (ctx, state) => _fade(state, const BiometricSetupScreen()),
    ),

    // Profile & KYC Routes
    GoRoute(
      path: AppRoutes.profilePhoto,
      pageBuilder: (ctx, state) => _fade(state, const UploadProfilePhotoScreen()),
    ),
    GoRoute(
      path: AppRoutes.selfieVerify,
      pageBuilder: (ctx, state) => _fade(state, const SelfieVerificationScreen()),
    ),
    GoRoute(
      path: AppRoutes.notifSettings,
      pageBuilder: (ctx, state) => _fade(state, const NotificationSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.securitySettings,
      pageBuilder: (ctx, state) => _fade(state, const PasswordChangeScreen()),
    ),
    GoRoute(
      path: AppRoutes.bankDetails,
      pageBuilder: (ctx, state) => _fade(state, const BankDetailsScreen()),
    ),
    GoRoute(
      path: AppRoutes.kycVerify,
      pageBuilder: (ctx, state) => _fade(state, const KycVerificationScreen()),
    ),
    GoRoute(
      path: AppRoutes.uploadDocs,
      pageBuilder: (ctx, state) => _fade(state, const UploadDocumentsScreen()),
    ),

    // Phase 9 Settings & Support Routes
    GoRoute(
      path: AppRoutes.settingsDashboard,
      pageBuilder: (ctx, state) => _fade(state, const SettingsDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.notificationCenter,
      pageBuilder: (ctx, state) => _fade(state, const NotificationCenterScreen()),
    ),
    GoRoute(
      path: AppRoutes.soundGraphics,
      pageBuilder: (ctx, state) => _fade(state, const SoundGraphicsSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.twoFactorSetup,
      pageBuilder: (ctx, state) => _fade(state, const TwoFactorSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpCenter,
      pageBuilder: (ctx, state) => _fade(state, const HelpCenterScreen()),
    ),
    GoRoute(
      path: AppRoutes.raiseTicket,
      pageBuilder: (ctx, state) => _fade(state, const RaiseTicketScreen()),
    ),
    GoRoute(
      path: AppRoutes.liveChat,
      pageBuilder: (ctx, state) => _fade(state, const LiveChatScreen()),
    ),
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (ctx, state) => _fade(state, const SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (ctx, state) => _fade(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (ctx, state) => _fade(state, const WelcomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.languageSelection,
      pageBuilder: (ctx, state) => _fade(state, const LanguageSelectionScreen()),
    ),
    GoRoute(
      path: AppRoutes.practiceMode,
      pageBuilder: (ctx, state) => _fade(state, const PracticeModeScreen()),
    ),
    GoRoute(
      path: AppRoutes.matchSelection,
      pageBuilder: (ctx, state) => _fade(state, const MatchSelectionScreen()),
    ),
    GoRoute(
      path: AppRoutes.teamMatch,
      pageBuilder: (ctx, state) => _fade(state, const TeamMatchScreen()),
    ),
    GoRoute(
      path: AppRoutes.spectatorMode,
      pageBuilder: (ctx, state) => _fade(state, const SpectatorModeScreen()),
    ),
    GoRoute(
      path: AppRoutes.matchStats,
      pageBuilder: (ctx, state) => _fade(state, const MatchStatisticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.matchReplay,
      pageBuilder: (ctx, state) => _fade(state, const MatchReplayScreen()),
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      pageBuilder: (ctx, state) => _fade(state, const LeaderboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.dailyMissions,
      pageBuilder: (ctx, state) => _fade(state, const DailyMissionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.achievementRewards,
      pageBuilder: (ctx, state) => _fade(state, const AchievementRewardsScreen()),
    ),
    GoRoute(
      path: AppRoutes.buyLotteryTicket,
      pageBuilder: (ctx, state) => _fade(state, const BuyLotteryTicketScreen()),
    ),
    GoRoute(
      path: AppRoutes.activeLottery,
      pageBuilder: (ctx, state) => _fade(state, const ActiveLotteryScreen()),
    ),
    GoRoute(
      path: AppRoutes.jackpotLottery,
      pageBuilder: (ctx, state) => _fade(state, const JackpotLotteryScreen()),
    ),
    GoRoute(
      path: AppRoutes.winnerAnnouncement,
      pageBuilder: (ctx, state) => _fade(state, const WinnerAnnouncementScreen()),
    ),
    GoRoute(
      path: AppRoutes.rewardClaim,
      pageBuilder: (ctx, state) => _fade(state, const RewardClaimScreen()),
    ),
    GoRoute(
      path: AppRoutes.bonusWallet,
      pageBuilder: (ctx, state) => _fade(state, const BonusWalletScreen()),
    ),
    GoRoute(
      path: AppRoutes.cashback,
      pageBuilder: (ctx, state) => _fade(state, const CashbackScreen()),
    ),
    GoRoute(
      path: AppRoutes.gstInvoice,
      pageBuilder: (ctx, state) => _fade(state, const GSTInvoiceScreen()),
    ),
    GoRoute(
      path: AppRoutes.faq,
      pageBuilder: (ctx, state) => _fade(state, const FaqScreen()),
    ),
    GoRoute(
      path: AppRoutes.contactSupport,
      pageBuilder: (ctx, state) => _fade(state, const ContactSupportScreen()),
    ),
    GoRoute(
      path: AppRoutes.ticketHistory,
      pageBuilder: (ctx, state) => _fade(state, const support_ticket.TicketHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (ctx, state) => _fade(state, const EditProfileScreen()),
    ),
    GoRoute(
      path: AppRoutes.accountSettings,
      pageBuilder: (ctx, state) => _fade(state, const AccountSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.privacySettings,
      pageBuilder: (ctx, state) => _fade(state, const PrivacySettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.linkedDevices,
      pageBuilder: (ctx, state) => _fade(state, const LinkedDevicesScreen()),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      pageBuilder: (ctx, state) => _fade(state, const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.socialLogin,
      pageBuilder: (ctx, state) => _fade(state, const SocialLoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.lotteryNumberSelect,
      pageBuilder: (ctx, state) => _fade(state, const NumberSelectionScreen()),
    ),
    GoRoute(
      path: AppRoutes.previousWinners,
      pageBuilder: (ctx, state) => _fade(state, const PreviousWinnersScreen()),
    ),
    GoRoute(
      path: AppRoutes.withdrawalOtp,
      pageBuilder: (ctx, state) {
        final amountStr = state.uri.queryParameters['amount'] ?? '0';
        final upiId = state.uri.queryParameters['upi'] ?? '';
        final amount = double.tryParse(amountStr) ?? 0.0;
        return _fade(state, WithdrawalOtpScreen(withdrawAmount: amount, upiId: upiId));
      },
    ),
  ],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (ctx, anim, sec, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.04, .02),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

class CarromLotteryApp extends StatelessWidget {
  const CarromLotteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Carrom Lottery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      builder: (context, child) => MobileScreeningWrapper(child: child!),
    );
  }
}
