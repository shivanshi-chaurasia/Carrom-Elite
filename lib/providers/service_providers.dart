import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/home_service.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';
import '../services/tournament_service.dart';
import '../services/carrom_service.dart';
import '../services/lottery_service.dart';
import '../services/wallet_service.dart';
import '../services/settings_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(const FlutterSecureStorage());
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(storageServiceProvider));
});

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(apiServiceProvider));
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(apiServiceProvider));
});

final tournamentServiceProvider = Provider<TournamentService>((ref) {
  return TournamentService(ref.watch(apiServiceProvider));
});

final carromServiceProvider = Provider<CarromService>((ref) {
  return CarromService(ref.watch(apiServiceProvider));
});

final lotteryServiceProvider = Provider<LotteryService>((ref) {
  return LotteryService(ref.watch(apiServiceProvider));
});

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(ref.watch(apiServiceProvider));
});

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
