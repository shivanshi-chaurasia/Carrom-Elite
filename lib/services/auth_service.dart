import 'api_service.dart';

class AuthService {
  AuthService(this.api);

  final ApiService api;

  // auth screens are already in apk; keeping service hooks ready
  Future<void> logout() async {}
}
