import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_models.dart';
import 'service_providers.dart';

final walletDetailsProvider =
    AsyncNotifierProvider<WalletDetailsNotifier, WalletDetailsModel>(WalletDetailsNotifier.new);

class WalletDetailsNotifier extends AsyncNotifier<WalletDetailsModel> {
  @override
  Future<WalletDetailsModel> build() async {
    return ref.watch(walletServiceProvider).fetchBalances();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(walletServiceProvider).fetchBalances());
  }

  Future<bool> deposit(num amount, String method) async {
    state = const AsyncLoading();
    var ok = await ref.read(walletServiceProvider).depositMoney(amount: amount, method: method);
    state = await AsyncValue.guard(() => ref.read(walletServiceProvider).fetchBalances());
    return ok;
  }

  Future<bool> withdraw(num amount, String upiId) async {
    state = const AsyncLoading();
    var ok = await ref.read(walletServiceProvider).withdrawMoney(amount: amount, upiId: upiId);
    state = await AsyncValue.guard(() => ref.read(walletServiceProvider).fetchBalances());
    return ok;
  }

  Future<bool> awardBonus(num amount) async {
    state = const AsyncLoading();
    var ok = await ref.read(walletServiceProvider).addBonusCash(amount);
    state = await AsyncValue.guard(() => ref.read(walletServiceProvider).fetchBalances());
    return ok;
  }
}

final transactionHistoryProvider = FutureProvider<List<TransactionModel>>((ref) {
  return ref.watch(walletServiceProvider).fetchTransactions();
});

final referralInfoProvider = FutureProvider<ReferralModel>((ref) {
  return ref.watch(walletServiceProvider).fetchReferralInfo();
});
