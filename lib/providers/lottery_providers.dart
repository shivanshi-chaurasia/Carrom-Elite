import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lottery_models.dart';
import 'service_providers.dart';

final activeLotteriesProvider = FutureProvider<List<LotteryModel>>((ref) {
  return ref.watch(lotteryServiceProvider).fetchActiveLotteries();
});

final ticketHistoryProvider = FutureProvider<List<LotteryTicketModel>>((ref) {
  return ref.watch(lotteryServiceProvider).fetchTicketHistory();
});

final lotteryResultsProvider = FutureProvider<List<LotteryDrawResultModel>>((ref) {
  return ref.watch(lotteryServiceProvider).fetchDrawResults();
});
