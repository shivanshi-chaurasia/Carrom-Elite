import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._secure);

  final FlutterSecureStorage _secure;

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  Future<String?> accessToken() => _secure.read(key: accessTokenKey);
  Future<String?> refreshToken() => _secure.read(key: refreshTokenKey);

  Future<void> saveTokens(String access, String refresh) async {
    await _secure.write(key: accessTokenKey, value: access);
    await _secure.write(key: refreshTokenKey, value: refresh);
  }

  Future<void> clearTokens() async {
    await _secure.delete(key: accessTokenKey);
    await _secure.delete(key: refreshTokenKey);
  }

  Future<void> cacheVal(String boxName, String key, dynamic val) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
    await Hive.box(boxName).put(key, val);
  }

  Future<dynamic> readVal(String boxName, String key) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
    return Hive.box(boxName).get(key);
  }

  Future<void> saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }
}
