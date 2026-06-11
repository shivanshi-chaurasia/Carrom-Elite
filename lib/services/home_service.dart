import '../models/home_models.dart';
import 'api_service.dart';

class HomeService {
  HomeService(this.api);

  final ApiService api;

  Future<HomeDashboardModel> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return HomeDashboardModel.mock();

    // when backend is ready:
    // final res = await api.get(ApiEndpoints.homeDashboard);
    // return HomeDashboardModel.fromJson(Map<String, dynamic>.from(res));
  }

  Future<List<GameCardModel>> fetchFeaturedGames() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return HomeDashboardModel.mock().featuredGames;
  }

  Future<List<TournamentBannerModel>> fetchTournaments() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return HomeDashboardModel.mock().tournaments;
  }

  Future<List<LotteryHighlightModel>> fetchLotteryHighlights() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return HomeDashboardModel.mock().lotteryHighlights;
  }

  Future<List<RewardModel>> fetchDailyRewards() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return HomeDashboardModel.mock().dailyRewards;
  }

  Future<void> quickMatch({required int entryFee, required String mode}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    print('mock quick match $mode $entryFee');
  }
}
