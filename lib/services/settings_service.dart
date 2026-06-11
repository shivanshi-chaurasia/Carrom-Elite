import 'dart:io';
import '../models/settings_models.dart';
import 'api_service.dart';
import 'storage_service.dart';

class SettingsService {
  SettingsService(this.api, this.storage);

  final ApiService api;
  final StorageService storage;

  static const sfxVolumeKey = 'sfx_volume';
  static const musicVolumeKey = 'music_volume';
  static const hapticsEnabledKey = 'haptics_enabled';
  static const graphicsQualityKey = 'graphics_quality';
  static const tfaEnabledKey = 'tfa_enabled';

  // Load user game preferences
  Future<Map<String, dynamic>> loadPreferences() async {
    // try reading local cache, use defaults if empty
    final sfx = await storage.readVal('settings', sfxVolumeKey) as double? ?? 0.8;
    final music = await storage.readVal('settings', musicVolumeKey) as double? ?? 0.5;
    final haptics = await storage.readVal('settings', hapticsEnabledKey) as bool? ?? true;
    final graphics = await storage.readVal('settings', graphicsQualityKey) as String? ?? 'High';

    return {
      'sfx': sfx,
      'music': music,
      'haptics': haptics,
      'graphics': graphics,
    };
  }

  // Save game preferences
  Future<void> savePreference(String key, dynamic value) async {
    await storage.cacheVal('settings', key, value);
  }

  // Check 2FA status
  Future<bool> isTwoFactorEnabled() async {
    final tfa = await storage.readVal('settings', tfaEnabledKey) as bool? ?? false;
    return tfa;
  }

  // Set 2FA status
  Future<void> setTwoFactorEnabled(bool enabled) async {
    await storage.cacheVal('settings', tfaEnabledKey, enabled);
  }

  // Fetch all notifications from notification center
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return NotificationModel.mocks();
  }

  // Fetch FAQ list
  Future<List<FaqModel>> fetchFAQs() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return FaqModel.mocks();
  }

  // Fetch open/closed support tickets
  Future<List<SupportTicketModel>> fetchTickets() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return SupportTicketModel.mocks();
  }

  // Raise new support ticket
  Future<SupportTicketModel> createTicket({
    required String subject,
    required String category,
    required String description,
    File? screenshot,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    
    // Simulate API response
    final newTicket = SupportTicketModel(
      id: 'TKT-${100 + (900 * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000)}',
      subject: subject,
      category: category,
      description: description,
      status: 'open',
      createdAt: DateTime.now(),
      screenshotUrl: screenshot != null ? 'file://${screenshot.path}' : null,
    );

    return newTicket;
  }
}
