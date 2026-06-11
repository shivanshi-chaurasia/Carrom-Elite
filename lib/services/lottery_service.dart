import 'dart:math';
import '../models/lottery_models.dart';
import 'api_service.dart';

class LotteryService {
  LotteryService(this.api);

  final ApiService api;

  // cached tickets for live verification
  final List<LotteryTicketModel> _ticketsCache = LotteryTicketModel.mockHistory();

  Future<List<LotteryModel>> fetchActiveLotteries() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return LotteryModel.mockList();
  }

  Future<List<LotteryTicketModel>> fetchTicketHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // return reversed so newest is first
    return _ticketsCache.reversed.toList();
  }

  Future<List<LotteryDrawResultModel>> fetchDrawResults() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return LotteryDrawResultModel.mockResults();
  }

  Future<bool> buyTicket({required String lotteryId, required List<int> numbers}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    
    // determine title
    var lotTitle = 'Mega Jackpot';
    if (lotteryId.contains('8pm')) {
      lotTitle = '8 PM Mega Jackpot';
    } else if (lotteryId.contains('weekend')) {
      lotTitle = 'Weekend Bumper Draw';
    } else if (lotteryId.contains('micro')) {
      lotTitle = 'Quick Spin Draw';
    }

    var randId = 't_${10000 + Random().nextInt(90000)}';
    
    var newTicket = LotteryTicketModel(
      ticketId: randId,
      lotteryId: lotteryId,
      lotteryTitle: lotTitle,
      selectedNumbers: numbers,
      purchaseTime: 'Just now',
      status: 'active',
      prizeWon: 0,
    );

    _ticketsCache.add(newTicket);
    print('bought ticket $randId for $lotteryId with numbers $numbers');
    return true;
  }
}
