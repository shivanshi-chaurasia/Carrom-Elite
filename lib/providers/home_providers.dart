import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/home_models.dart';
import 'service_providers.dart';

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardModel>(
  HomeDashboardNotifier.new,
);

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardModel> {
  @override
  Future<HomeDashboardModel> build() async {
    final service = ref.watch(homeServiceProvider);
    return service.fetchDashboard();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(homeServiceProvider).fetchDashboard());
  }

  void updateWalletAndLevel({required double balance, required int level}) {
    if (state.hasValue) {
      final oldData = state.value!;
      state = AsyncData(oldData.copyWith(
        player: PlayerSummaryModel(
          id: oldData.player.id,
          name: oldData.player.name,
          avatar: oldData.player.avatar,
          level: level,
          winRate: oldData.player.winRate,
        ),
        wallet: WalletSummaryModel(
          deposit: balance * 0.6,
          winnings: balance * 0.4,
          bonus: 0,
        ),
      ));
    }
  }
}

final featuredGamesProvider = FutureProvider<List<GameCardModel>>((ref) {
  return ref.watch(homeServiceProvider).fetchFeaturedGames();
});

final tournamentBannersProvider = FutureProvider<List<TournamentBannerModel>>((ref) {
  return ref.watch(homeServiceProvider).fetchTournaments();
});

final lotteryHighlightsProvider = FutureProvider<List<LotteryHighlightModel>>((ref) {
  return ref.watch(homeServiceProvider).fetchLotteryHighlights();
});

final dailyRewardsProvider = FutureProvider<List<RewardModel>>((ref) {
  return ref.watch(homeServiceProvider).fetchDailyRewards();
});

final quickMatchProvider =
    AsyncNotifierProvider<QuickMatchNotifier, void>(QuickMatchNotifier.new);

class QuickMatchNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> enter({required int entryFee, required String mode}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeServiceProvider).quickMatch(entryFee: entryFee, mode: mode),
    );
  }
}
