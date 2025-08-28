// lib/app/data/providers/api_client.dart
import 'package:get/get.dart';
import '../../services/auth_service.dart';

class ApiClient extends GetConnect {
  static const String _baseUrl = 'https://dev.upsen.id/api/';

  @override
  void onInit() {
    // Fix: Use proper baseUrl assignment
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = Duration(seconds: 30);

    // Request interceptor
    httpClient.addRequestModifier<Object?>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      // Add bearer token if available
      try {
        final authService = Get.find<AuthService>();
        if (authService.token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${authService.token}';
        }
      } catch (e) {
        // Auth service not initialized yet
      }

      return request;
    });

    // Response interceptor for error handling
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        // Token expired, redirect to login
        try {
          Get.find<AuthService>().clearToken();
          Get.offAllNamed('/admin-login');
        } catch (e) {
          // Handle case when services not ready
        }
      }
      return response;
    });

    super.onInit();
  }
}
