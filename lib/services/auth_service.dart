import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this.api, this.storage);

  final ApiService api;
  final StorageService storage;

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
    String? deviceId,
    String? platform,
  }) async {
    final data = await api.post(ApiEndpoints.register, data: {
      'username': username,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      if (referralCode != null) 'referralCode': referralCode,
      'deviceId': deviceId ?? 'web-${DateTime.now().millisecondsSinceEpoch}',
      'platform': platform ?? (kIsWeb ? 'WEB' : 'ANDROID'),
    });
    final body = Map<String, dynamic>.from(data as Map);
    await storage.saveTokens(body['token'] ?? '', body['refreshToken'] ?? '');
    return body;
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
    String? deviceId,
    String? platform,
  }) async {
    final data = await api.post(ApiEndpoints.login, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
      'deviceId': deviceId ?? 'web-${DateTime.now().millisecondsSinceEpoch}',
      'platform': platform ?? (kIsWeb ? 'WEB' : 'ANDROID'),
    });
    final body = Map<String, dynamic>.from(data as Map);
    await storage.saveTokens(body['token'] ?? '', body['refreshToken'] ?? '');
    return body;
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final refresh = await storage.refreshToken();
    if (refresh == null) throw Exception('No refresh token');
    final data = await api.post(ApiEndpoints.refreshToken, data: {
      'refreshToken': refresh,
    });
    final body = Map<String, dynamic>.from(data as Map);
    await storage.saveTokens(body['token'] ?? '', body['refreshToken'] ?? '');
    return body;
  }

  Future<void> logout() async {
    final refresh = await storage.refreshToken();
    try {
      if (refresh != null) {
        await api.post(ApiEndpoints.logout, data: {'refreshToken': refresh});
      }
    } catch (_) {}
    await storage.clearTokens();
  }

  Future<void> sendOtp({
    String? email,
    String? phone,
    required String purpose,
  }) async {
    await api.post(ApiEndpoints.sendOtp, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'purpose': purpose,
    });
  }

  Future<bool> verifyOtp({
    String? email,
    String? phone,
    required String otp,
    required String purpose,
  }) async {
    final data = await api.post(ApiEndpoints.verifyOtp, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'otp': otp,
      'purpose': purpose,
    });
    final body = Map<String, dynamic>.from(data as Map);
    final result = body['data'] as Map<String, dynamic>?;
    return result?['verified'] == true;
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    await api.post(ApiEndpoints.verifyEmail, data: {
      'email': email,
      'otp': otp,
    });
  }

  Future<void> forgotPassword({required String email}) async {
    await api.post(ApiEndpoints.forgotPassword, data: {
      'email': email,
    });
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await api.post(ApiEndpoints.resetPassword, data: {
      'token': token,
      'password': password,
    });
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.accessToken();
    return token != null && token.isNotEmpty;
  }
}
