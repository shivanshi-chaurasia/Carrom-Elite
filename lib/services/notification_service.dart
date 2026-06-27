import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  FirebaseMessaging? get _messaging {
    if (kIsWeb) return null;
    return FirebaseMessaging.instance;
  }

  Future<String?> init() async {
    if (kIsWeb) return null;
    await _messaging!.requestPermission();
    return _messaging!.getToken();
  }
}
