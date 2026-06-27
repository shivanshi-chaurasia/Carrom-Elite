import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage() : _secure = const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  @override
  Future<String?> read(String key) => _secure.read(key: key);
  @override
  Future<void> write(String key, String value) => _secure.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _secure.delete(key: key);
}

class PrefsTokenStorage implements TokenStorage {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class StorageService {
  StorageService() : _tokens = _createTokenStorage();

  final TokenStorage _tokens;

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  static TokenStorage _createTokenStorage() {
    if (kIsWeb) {
      return PrefsTokenStorage();
    }
    return SecureTokenStorage();
  }

  Future<String?> accessToken() => _tokens.read(accessTokenKey);
  Future<String?> refreshToken() => _tokens.read(refreshTokenKey);

  Future<void> saveTokens(String access, String refresh) async {
    await _tokens.write(accessTokenKey, access);
    await _tokens.write(refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    await _tokens.delete(accessTokenKey);
    await _tokens.delete(refreshTokenKey);
  }

  Future<void> saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }
}
