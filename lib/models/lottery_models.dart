class LotteryModel {
  final String id;
  final String title;
  final num jackpot;
  final num ticketPrice;
  final String drawTime;
  final double soldPercent;
  final String status; // active, drawing, finished

  LotteryModel({
    required this.id,
    required this.title,
    required this.jackpot,
    required this.ticketPrice,
    required this.drawTime,
    required this.soldPercent,
    required this.status,
  });

  factory LotteryModel.fromJson(Map<String, dynamic> json) => LotteryModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        jackpot: num.tryParse('${json['jackpot'] ?? 0}') ?? 0,
        ticketPrice: num.tryParse('${json['ticketPrice'] ?? 0}') ?? 0,
        drawTime: json['drawTime']?.toString() ?? '',
        soldPercent: double.tryParse('${json['soldPercent'] ?? 0}') ?? 0,
        status: json['status']?.toString() ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'jackpot': jackpot,
        'ticketPrice': ticketPrice,
        'drawTime': drawTime,
        'soldPercent': soldPercent,
        'status': status,
      };

  static List<LotteryModel> mockList() {
    return [
      LotteryModel(
        id: 'lottery_8pm',
        title: '8 PM Mega Jackpot',
        jackpot: 100000,
        ticketPrice: 20,
        drawTime: '02h 14m',
        soldPercent: .72,
        status: 'active',
      ),
      LotteryModel(
        id: 'lottery_weekend',
        title: 'Weekend Bumper Draw',
        jackpot: 500000,
        ticketPrice: 50,
        drawTime: '1d 08h',
        soldPercent: .48,
        status: 'active',
      ),
      LotteryModel(
        id: 'lottery_micro',
        title: 'Quick Spin Draw',
        jackpot: 15000,
        ticketPrice: 5,
        drawTime: '24m',
        soldPercent: .91,
        status: 'active',
      ),
    ];
  }
}

class LotteryTicketModel {
  final String ticketId;
  final String lotteryId;
  final String lotteryTitle;
  final List<int> selectedNumbers;
  final String purchaseTime;
  final String status; // active, won, lost
  final num prizeWon;

  LotteryTicketModel({
    required this.ticketId,
    required this.lotteryId,
    required this.lotteryTitle,
    required this.selectedNumbers,
    required this.purchaseTime,
    required this.status,
    required this.prizeWon,
  });

  factory LotteryTicketModel.fromJson(Map<String, dynamic> json) => LotteryTicketModel(
        ticketId: json['ticketId']?.toString() ?? '',
        lotteryId: json['lotteryId']?.toString() ?? '',
        lotteryTitle: json['lotteryTitle']?.toString() ?? '',
        selectedNumbers: List<int>.from(json['selectedNumbers'] ?? const []),
        purchaseTime: json['purchaseTime']?.toString() ?? '',
        status: json['status']?.toString() ?? 'active',
        prizeWon: num.tryParse('${json['prizeWon'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'lotteryId': lotteryId,
        'lotteryTitle': lotteryTitle,
        'selectedNumbers': selectedNumbers,
        'purchaseTime': purchaseTime,
        'status': status,
        'prizeWon': prizeWon,
      };

  static List<LotteryTicketModel> mockHistory() {
    return [
      LotteryTicketModel(
        ticketId: 't_88301',
        lotteryId: 'lottery_8pm',
        lotteryTitle: '8 PM Mega Jackpot',
        selectedNumbers: [4, 12, 19, 23, 27, 34],
        purchaseTime: 'Today, 10:15 AM',
        status: 'active',
        prizeWon: 0,
      ),
      LotteryTicketModel(
        ticketId: 't_54192',
        lotteryId: 'lottery_micro',
        lotteryTitle: 'Quick Spin Draw',
        selectedNumbers: [1, 7, 13, 22, 29, 31],
        purchaseTime: 'Yesterday, 04:30 PM',
        status: 'won',
        prizeWon: 250,
      ),
      LotteryTicketModel(
        ticketId: 't_29841',
        lotteryId: 'lottery_8pm',
        lotteryTitle: '8 PM Mega Jackpot',
        selectedNumbers: [3, 9, 14, 21, 28, 30],
        purchaseTime: '08 June, 07:45 PM',
        status: 'lost',
        prizeWon: 0,
      ),
    ];
  }
}

class LotteryDrawResultModel {
  final String drawId;
  final String lotteryTitle;
  final List<int> winningNumbers;
  final num jackpotWon;
  final String drawDate;
  final int winnersCount;

  LotteryDrawResultModel({
    required this.drawId,
    required this.lotteryTitle,
    required this.winningNumbers,
    required this.jackpotWon,
    required this.drawDate,
    required this.winnersCount,
  });

  factory LotteryDrawResultModel.fromJson(Map<String, dynamic> json) => LotteryDrawResultModel(
        drawId: json['drawId']?.toString() ?? '',
        lotteryTitle: json['lotteryTitle']?.toString() ?? '',
        winningNumbers: List<int>.from(json['winningNumbers'] ?? const []),
        jackpotWon: num.tryParse('${json['jackpotWon'] ?? 0}') ?? 0,
        drawDate: json['drawDate']?.toString() ?? '',
        winnersCount: int.tryParse('${json['winnersCount'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'drawId': drawId,
        'lotteryTitle': lotteryTitle,
        'winningNumbers': winningNumbers,
        'jackpotWon': jackpotWon,
        'drawDate': drawDate,
        'winnersCount': winnersCount,
      };

  static List<LotteryDrawResultModel> mockResults() {
    return [
      LotteryDrawResultModel(
        drawId: 'dr_9921',
        lotteryTitle: '8 PM Mega Jackpot',
        winningNumbers: [2, 11, 15, 22, 28, 33],
        jackpotWon: 100000,
        drawDate: '09 June, 08:00 PM',
        winnersCount: 3,
      ),
      LotteryDrawResultModel(
        drawId: 'dr_9920',
        lotteryTitle: 'Quick Spin Draw',
        winningNumbers: [5, 12, 17, 24, 29, 36],
        jackpotWon: 15000,
        drawDate: '09 June, 06:00 PM',
        winnersCount: 12,
      ),
      LotteryDrawResultModel(
        drawId: 'dr_9919',
        lotteryTitle: '8 PM Mega Jackpot',
        winningNumbers: [1, 7, 13, 21, 25, 30],
        jackpotWon: 0,
        drawDate: '08 June, 08:00 PM',
        winnersCount: 0,
      ),
    ];
  }
}
