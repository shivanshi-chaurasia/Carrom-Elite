import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_models.dart';
import 'service_providers.dart';

final bankDetailsProvider = FutureProvider<BankDetailsModel>((ref) {
  return ref.watch(profileServiceProvider).fetchBankDetails();
});

final kycStatusProvider = FutureProvider<KycModel>((ref) {
  return ref.watch(profileServiceProvider).fetchKycStatus();
});

final notificationSettingsProvider = FutureProvider<NotificationSettingsModel>((ref) {
  return ref.watch(profileServiceProvider).fetchNotificationSettings();
});

final bankDetailsSubmitProvider =
    AsyncNotifierProvider<BankDetailsSubmitNotifier, void>(BankDetailsSubmitNotifier.new);

class BankDetailsSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(BankDetailsModel details) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileServiceProvider).saveBankDetails(details),
    );
  }
}

final kycSubmitProvider =
    AsyncNotifierProvider<KycSubmitNotifier, void>(KycSubmitNotifier.new);

class KycSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String aadhaarFront,
    required String aadhaarBack,
    required String pan,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileServiceProvider).submitKyc(
            aadhaarFront: aadhaarFront,
            aadhaarBack: aadhaarBack,
            pan: pan,
          ),
    );
  }
}

final passwordUpdateProvider =
    AsyncNotifierProvider<PasswordUpdateNotifier, void>(PasswordUpdateNotifier.new);

class PasswordUpdateNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileServiceProvider).updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
    );
  }
}
