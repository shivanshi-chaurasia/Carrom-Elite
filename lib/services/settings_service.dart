import 'package:shared_preferences/shared_preferences.dart';
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

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Load user game preferences
  Future<Map<String, dynamic>> loadPreferences() async {
    final p = await _prefs;
    final sfx = p.getDouble(sfxVolumeKey) ?? 0.8;
    final music = p.getDouble(musicVolumeKey) ?? 0.5;
    final haptics = p.getBool(hapticsEnabledKey) ?? true;
    final graphics = p.getString(graphicsQualityKey) ?? 'High';

    return {
      'sfx': sfx,
      'music': music,
      'haptics': haptics,
      'graphics': graphics,
    };
  }

  // Save game preferences
  Future<void> savePreference(String key, dynamic value) async {
    final p = await _prefs;
    if (value is double) {
      await p.setDouble(key, value);
    } else if (value is int) {
      await p.setInt(key, value);
    } else if (value is bool) {
      await p.setBool(key, value);
    } else {
      await p.setString(key, value.toString());
    }
  }

  // Check 2FA status
  Future<bool> isTwoFactorEnabled() async {
    final p = await _prefs;
    return p.getBool(tfaEnabledKey) ?? false;
  }

  // Set 2FA status
  Future<void> setTwoFactorEnabled(bool enabled) async {
    final p = await _prefs;
    await p.setBool(tfaEnabledKey, enabled);
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
    String? screenshotPath,
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
      screenshotUrl: screenshotPath != null ? 'file://$screenshotPath' : null,
    );

    return newTicket;
  }
}
