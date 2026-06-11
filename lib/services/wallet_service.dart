import '../models/wallet_models.dart';
import 'api_service.dart';

class WalletService {
  WalletService(this.api);

  final ApiService api;

  // cached local balance state to support real-time updates in dashboard
  WalletDetailsModel _cachedWallet = WalletDetailsModel.mock();

  Future<WalletDetailsModel> fetchBalances() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _cachedWallet;
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return TransactionModel.mockList();
  }

  Future<ReferralModel> fetchReferralInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ReferralModel.mock();
  }

  Future<bool> depositMoney({required num amount, required String method}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    // add deposit amount to cached state
    _cachedWallet = WalletDetailsModel(
      deposit: _cachedWallet.deposit + amount,
      winnings: _cachedWallet.winnings,
      bonus: _cachedWallet.bonus,
    );
    
    print('deposited ₹$amount via $method');
    return true;
  }

  Future<bool> withdrawMoney({required num amount, required String upiId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    if (_cachedWallet.winnings >= amount) {
      _cachedWallet = WalletDetailsModel(
        deposit: _cachedWallet.deposit,
        winnings: _cachedWallet.winnings - amount,
        bonus: _cachedWallet.bonus,
      );
      print('withdrawn ₹$amount to $upiId');
      return true;
    }
    return false;
  }

  Future<bool> addBonusCash(num amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _cachedWallet = WalletDetailsModel(
      deposit: _cachedWallet.deposit,
      winnings: _cachedWallet.winnings,
      bonus: _cachedWallet.bonus + amount,
    );
    print('credited bonus cash ₹$amount');
    return true;
  }
}
