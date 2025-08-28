// lib/app/data/providers/company_api.dart
import 'package:get/get.dart';

import '../../services/auth_service.dart';

class CompanyApi extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://dev.upsen.id/api/';
    httpClient.timeout = Duration(seconds: 30);

    // Add authorization header if needed
    httpClient.addRequestModifier<Object?>((request) {
      // Add bearer token if available
      final token = Get.find<AuthService>().token;
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  Future<Response> getCompany() async {
    return get('company');
  }
}
