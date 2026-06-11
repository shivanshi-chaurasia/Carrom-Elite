class WalletDetailsModel {
  final num deposit;
  final num winnings;
  final num bonus;

  WalletDetailsModel({required this.deposit, required this.winnings, required this.bonus});

  num get total => deposit + winnings + bonus;

  factory WalletDetailsModel.fromJson(Map<String, dynamic> json) => WalletDetailsModel(
        deposit: num.tryParse('${json['deposit'] ?? 0}') ?? 0,
        winnings: num.tryParse('${json['winnings'] ?? 0}') ?? 0,
        bonus: num.tryParse('${json['bonus'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'deposit': deposit,
        'winnings': winnings,
        'bonus': bonus,
      };

  factory WalletDetailsModel.mock() => WalletDetailsModel(deposit: 1200, winnings: 840, bonus: 150);
}

class TransactionModel {
  final String id;
  final num amount;
  final String type; // deposit, withdraw, win, entry, bonus, referral
  final String status; // pending, completed, failed
  final String gateway; // UPI, Card, NetBanking, Wallet
  final String time;
  final String description;
  final num gstPaid;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.gateway,
    required this.time,
    required this.description,
    required this.gstPaid,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id']?.toString() ?? '',
        amount: num.tryParse('${json['amount'] ?? 0}') ?? 0,
        type: json['type']?.toString() ?? 'deposit',
        status: json['status']?.toString() ?? 'completed',
        gateway: json['gateway']?.toString() ?? 'UPI',
        time: json['time']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        gstPaid: num.tryParse('${json['gstPaid'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'status': status,
        'gateway': gateway,
        'time': time,
        'description': description,
        'gstPaid': gstPaid,
      };

  static List<TransactionModel> mockList() {
    return [
      TransactionModel(
        id: 'tx_10092',
        amount: 500,
        type: 'deposit',
        status: 'completed',
        gateway: 'UPI',
        time: 'Today, 11:20 AM',
        description: 'Deposited to play wallet',
        gstPaid: 90, // 18% GST standard
      ),
      TransactionModel(
        id: 'tx_10091',
        amount: 90,
        type: 'win',
        status: 'completed',
        gateway: 'Wallet',
        time: 'Yesterday, 08:30 PM',
        description: 'Winnings from Carrom 1v1',
        gstPaid: 0,
      ),
      TransactionModel(
        id: 'tx_10090',
        amount: 250,
        type: 'withdraw',
        status: 'completed',
        gateway: 'UPI',
        time: '08 June, 02:45 PM',
        description: 'Withdrawn to bank account',
        gstPaid: 0,
      ),
      TransactionModel(
        id: 'tx_10089',
        amount: 50,
        type: 'entry',
        status: 'completed',
        gateway: 'Wallet',
        time: '08 June, 02:10 PM',
        description: 'Entry fee for Carrom 1v1',
        gstPaid: 0,
      ),
      TransactionModel(
        id: 'tx_10088',
        amount: 100,
        type: 'referral',
        status: 'completed',
        gateway: 'Wallet',
        time: '06 June, 12:00 PM',
        description: 'Referral reward for inviting friend',
        gstPaid: 0,
      ),
    ];
  }
}

class ReferralModel {
  final String code;
  final num totalEarned;
  final int referralsCount;

  ReferralModel({required this.code, required this.totalEarned, required this.referralsCount});

  factory ReferralModel.fromJson(Map<String, dynamic> json) => ReferralModel(
        code: json['code']?.toString() ?? '',
        totalEarned: num.tryParse('${json['totalEarned'] ?? 0}') ?? 0,
        referralsCount: int.tryParse('${json['referralsCount'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'totalEarned': totalEarned,
        'referralsCount': referralsCount,
      };

  factory ReferralModel.mock() => ReferralModel(code: 'SHIV99A', totalEarned: 350, referralsCount: 4);
}
