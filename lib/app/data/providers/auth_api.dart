import 'package:get/get.dart';
import 'api_client.dart';

class AuthApi extends ApiClient {
  Future<Response<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final body = {'email': email, 'password': password};

    return post('login', body);
  }

  Future<Response<Map<String, dynamic>>> logout() async {
    return post('logout', {});
  }

  Future<Response<Map<String, dynamic>>> getCurrentUser() async {
    return get('user');
  }
}
