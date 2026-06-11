import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament_models.dart';
import 'service_providers.dart';

final tournamentDetailsProvider = FutureProvider.family<TournamentDetailModel, String>((ref, id) {
  return ref.watch(tournamentServiceProvider).fetchDetails(id);
});

final tournamentBracketProvider = FutureProvider.family<List<TournamentBracketNodeModel>, String>((ref, id) {
  return ref.watch(tournamentServiceProvider).fetchBracket(id);
});

final tournamentLeaderboardProvider = FutureProvider.family<List<TournamentLeaderboardModel>, String>((ref, id) {
  return ref.watch(tournamentServiceProvider).fetchLeaderboard(id);
});
