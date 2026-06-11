import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> init() async {
    await _messaging.requestPermission();
    return _messaging.getToken();
  }
}
