import 'package:get/get.dart';
import '../../../services/offline_sync_service.dart';
import '../attendance_api.dart';
import '../models/attendance_response.dart';
import '../models/dashboard_stats.dart';

class AttendanceRepository {
  final AttendanceApi _api = AttendanceApi();
  final OfflineSyncService _syncService = Get.find();

  Future<AttendanceResponse?> checkIn(List<double> faceEmbedding) async {
    try {
      final response = await _api.checkInPublic(faceEmbedding: faceEmbedding);

      if (response.isOk && response.body != null) {
        return AttendanceResponse.fromJson(response.body!);
      } else {
        throw Exception('Check-in failed: ${response.statusText}');
      }
    } catch (e) {
      // Fallback to offline queue
      await _syncService.queueCheckIn(faceEmbedding);
      throw Exception('Check-in queued offline: ${e.toString()}');
    }
  }

  Future<AttendanceResponse?> checkOut(List<double> faceEmbedding) async {
    try {
      final response = await _api.checkOutPublic(faceEmbedding: faceEmbedding);

      if (response.isOk && response.body != null) {
        return AttendanceResponse.fromJson(response.body!);
      } else {
        throw Exception('Check-out failed: ${response.statusText}');
      }
    } catch (e) {
      // Fallback to offline queue
      await _syncService.queueCheckOut(faceEmbedding);
      throw Exception('Check-out queued offline: ${e.toString()}');
    }
  }

  Future<DashboardStats?> getDashboardStats() async {
    try {
      final response = await _api.getDashboardStats();

      if (response.isOk && response.body != null) {
        return DashboardStats.fromJson(response.body!);
      }
      return null;
    } catch (e) {
      print('Failed to get dashboard stats: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers({String? search}) async {
    try {
      final response = await _api.getUsers(search: search);

      if (response.isOk && response.body != null) {
        final data = response.body!['data'] as List?;
        return data?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (e) {
      print('Failed to get users: $e');
      return [];
    }
  }
}
