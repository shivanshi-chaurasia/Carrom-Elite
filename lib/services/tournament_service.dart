import '../models/tournament_models.dart';
import 'api_service.dart';

class TournamentService {
  TournamentService(this.api);

  final ApiService api;

  Future<TournamentDetailModel> fetchDetails(String id) async {
    // mock API delay
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return TournamentDetailModel.mock(id);
  }

  Future<List<TournamentBracketNodeModel>> fetchBracket(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return TournamentBracketNodeModel.mockNodes();
  }

  Future<List<TournamentLeaderboardModel>> fetchLeaderboard(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return TournamentLeaderboardModel.mockList();
  }

  Future<bool> registerForTournament(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    print('registered for tournament $id');
    return true;
  }
}
