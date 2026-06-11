import '../models/profile_models.dart';
import 'api_service.dart';

class ProfileService {
  ProfileService(this.api);

  final ApiService api;

  Future<BankDetailsModel> fetchBankDetails() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return BankDetailsModel.mock();
  }

  Future<void> saveBankDetails(BankDetailsModel details) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    print('saving bank details: ${details.toJson()}');
  }

  Future<KycModel> fetchKycStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return KycModel.mock();
  }

  Future<void> submitKyc({
    required String aadhaarFront,
    required String aadhaarBack,
    required String pan,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    print('submitting KYC: front=$aadhaarFront, back=$aadhaarBack, pan=$pan');
  }

  Future<NotificationSettingsModel> fetchNotificationSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return NotificationSettingsModel.mock();
  }

  Future<void> saveNotificationSettings(NotificationSettingsModel settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    print('saving notification settings: ${settings.toJson()}');
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    print('updating password');
  }
}
