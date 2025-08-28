// lib/app/ui/pages/home/controllers/home.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/providers/models/dashboard_stats.dart';
import '../../../app/data/providers/repositories/attendanxe_repository.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/company_service.dart';
import '../../../app/services/offline_sync_service.dart';

class HomeController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();

  // Get services - handle cases where they might not be initialized yet
  CompanyService? get _companyService {
    try {
      return Get.find<CompanyService>();
    } catch (e) {
      return null;
    }
  }

  OfflineSyncService? get _syncService {
    try {
      return Get.find<OfflineSyncService>();
    } catch (e) {
      return null;
    }
  }

  // Reactive variables
  final Rxn<DashboardStats> _dashboardStats = Rxn<DashboardStats>();
  final RxBool _isLoadingStats = false.obs;
  final RxString _currentTime = ''.obs;

  // Getters
  DashboardStats? get dashboardStats => _dashboardStats.value;
  bool get isLoadingStats => _isLoadingStats.value;
  String get currentTime => _currentTime.value;
  bool get isOnline => _syncService?.isOnline ?? true;
  int get queueCount => _syncService?.queueCount ?? 0;
  String get companyName =>
      _companyService?.companyDisplayName ?? 'Unknown Company';

  @override
  void onInit() {
    super.onInit();
    _startTimeUpdater();
    _loadDashboardStats();
    _startStatsRefresh();
  }

  // Start time updater
  void _startTimeUpdater() {
    _updateCurrentTime();

    // Update every second
    Stream.periodic(Duration(seconds: 1)).listen((_) {
      _updateCurrentTime();
    });
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    _currentTime.value =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Start periodic stats refresh
  void _startStatsRefresh() {
    // Refresh every 30 seconds
    Stream.periodic(Duration(seconds: 30)).listen((_) {
      _loadDashboardStats();
    });
  }

  // Load dashboard statistics
  Future<void> _loadDashboardStats() async {
    if (_companyService?.isInitialized != true) return;

    try {
      _isLoadingStats.value = true;
      final stats = await _repository.getDashboardStats();
      if (stats != null) {
        _dashboardStats.value = stats;
      }
    } catch (e) {
      print('Failed to load dashboard stats: $e');
      // Could show error to user here
    } finally {
      _isLoadingStats.value = false;
    }
  }

  // Navigate to camera
  void navigateToCamera() {
    Get.toNamed('/camera');
  }

  // Manual sync
  Future<void> syncNow() async {
    await _syncService?.syncNow();
    // Refresh stats after sync
    await _loadDashboardStats();
  }

  // Navigate to settings
  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    try {
      Get.find<AuthService>().clearToken();
      Get.find<CompanyService>().clearContext();
      Get.offAllNamed('/admin-login');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
