import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/company_service.dart';
import 'api_client.dart';

class AttendanceApi extends ApiClient {
  CompanyService get _company => Get.find();

  Future<Response<Map<String, dynamic>>> checkInPublic({
    required List<double> faceEmbedding,
    DateTime? dateTime,
  }) async {
    final now = dateTime ?? DateTime.now();

    final body = {
      'face_embedding': faceEmbedding,
      'date': DateFormat('yyyy-MM-dd').format(now),
      'time_in': DateFormat('HH:mm:ss').format(now),
    };

    return post('checkin-public', body);
  }

  Future<Response<Map<String, dynamic>>> checkOutPublic({
    required List<double> faceEmbedding,
    DateTime? dateTime,
  }) async {
    final now = dateTime ?? DateTime.now();

    final body = {
      'face_embedding': faceEmbedding,
      'time_out': DateFormat('HH:mm:ss').format(now),
    };

    return post('checkout-public', body);
  }

  Future<Response<Map<String, dynamic>>> getDashboardStats() async {
    if (!_company.isInitialized) {
      throw Exception('Company context not initialized');
    }

    return get(
      'tablet/dashboard-stats/${_company.companyId}/${_company.branchId}',
    );
  }

  Future<Response<Map<String, dynamic>>> syncBatch({
    required List<Map<String, dynamic>> records,
  }) async {
    if (!_company.isInitialized) {
      throw Exception('Company context not initialized');
    }

    final body = {
      'device_id': 'TABLET_${_company.branchId}',
      'sync_timestamp': DateTime.now().toIso8601String(),
      'records': records,
    };

    return post(
      'tablet/sync-batch/${_company.companyId}/${_company.branchId}',
      body,
    );
  }

  Future<Response<Map<String, dynamic>>> getUsers({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      params['name'] = search;
    }
    return get('users', query: params);
  }

  Future<Response<Map<String, dynamic>>> getCompany() async {
    return get('company');
  }
}
