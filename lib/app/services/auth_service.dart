// lib/app/services/auth_service.dart - Supporting service
import 'package:get/get.dart';

class AuthService extends GetxService {
  final RxString _token = ''.obs;
  final RxBool _isLoggedIn = false.obs;

  String get token => _token.value;
  bool get isLoggedIn => _isLoggedIn.value;

  void setToken(String token) {
    _token.value = token;
    _isLoggedIn.value = token.isNotEmpty;
  }

  void clearToken() {
    _token.value = '';
    _isLoggedIn.value = false;
  }
}
