// lib/presentation/manual-entry/controllers/manual_entry.controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/providers/repositories/attendanxe_repository.dart';

class ManualEntryController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();
  final TextEditingController searchController = TextEditingController();

  // Observable variables
  var allEmployees = <Map<String, dynamic>>[].obs;
  var filteredEmployees = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var isSearching = false.obs;

  // Debounce timer for search
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      isLoading(true);

      // Load all employees from API
      final employees = await _repository.getUsers();
      allEmployees.assignAll(employees);

      // Initially show recent employees or empty
      filteredEmployees.clear();

      print('Loaded ${employees.length} employees');
    } catch (e) {
      print('Error loading employees: $e');
      Get.snackbar(
        'Error',
        'Failed to load employee list',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    // Cancel previous timer
    _searchTimer?.cancel();

    if (query.length < 2) {
      filteredEmployees.clear();
      isSearching(false);
      return;
    }

    isSearching(true);

    // Debounce search for better UX
    _searchTimer = Timer(Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final searchTerm = query.toLowerCase().trim();

    final results = allEmployees.where((employee) {
      final name = (employee['name'] ?? '').toString().toLowerCase();
      final department = (employee['department'] ?? '')
          .toString()
          .toLowerCase();
      final position = (employee['position'] ?? '').toString().toLowerCase();
      final email = (employee['email'] ?? '').toString().toLowerCase();

      return name.contains(searchTerm) ||
          department.contains(searchTerm) ||
          position.contains(searchTerm) ||
          email.contains(searchTerm);
    }).toList();

    // Sort by relevance (name matches first, then department)
    results.sort((a, b) {
      final aName = (a['name'] ?? '').toString().toLowerCase();
      final bName = (b['name'] ?? '').toString().toLowerCase();

      final aNameMatch = aName.startsWith(searchTerm);
      final bNameMatch = bName.startsWith(searchTerm);

      if (aNameMatch && !bNameMatch) return -1;
      if (!aNameMatch && bNameMatch) return 1;

      return aName.compareTo(bName);
    });

    filteredEmployees.assignAll(results);
    isSearching(false);

    print('Search "$query" found ${results.length} results');
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredEmployees.clear();
    isSearching(false);
    _searchTimer?.cancel();
  }

  void selectEmployee(Map<String, dynamic> employee) {
    print('Selected employee: ${employee['name']}');

    // Show confirmation dialog
    _showConfirmationDialog(employee);
  }

  void _showConfirmationDialog(Map<String, dynamic> employee) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Employee avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF26a69a), Color(0xFF009688)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  employee['name'].toString().isNotEmpty
                      ? employee['name'].toString()[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              employee['name'] ?? 'Unknown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              employee['department'] ?? 'Unknown Department',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if ((employee['position'] ?? '').toString().isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                employee['position'].toString(),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, color: Colors.teal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Check In',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processManualAttendance(employee);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF26a69a),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _processManualAttendance(Map<String, dynamic> employee) async {
    try {
      // Show loading
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing attendance...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Close loading dialog
      Get.back();

      // Navigate to success screen
      Get.offNamed(
        '/success',
        arguments: {
          'employeeName': employee['name'] ?? 'Unknown',
          'department': employee['department'] ?? 'Unknown Department',
          'position': employee['position'] ?? '',
          'action': 'check_in',
          'time': DateTime.now().toString().split(' ')[1].substring(0, 8),
          'confidence': 1.0, // Manual entry = 100% confidence
          'status': _getAttendanceStatus(),
          'autoConfirm': false,
          'imageUrl': '',
        },
      );

      print('Manual attendance processed for: ${employee['name']}');
    } catch (e) {
      // Close loading dialog
      Get.back();

      print('Manual attendance error: $e');
      Get.snackbar(
        'Error',
        'Failed to process attendance. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getAttendanceStatus() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Define work start time (8:00 AM)
    final workStart = 8;
    final lateThreshold = 8.5; // 8:30 AM
    final veryLateThreshold = 9; // 9:00 AM

    final currentTime = hour + (minute / 60.0);

    if (currentTime <= workStart) {
      return 'early';
    } else if (currentTime <= lateThreshold) {
      return 'ontime';
    } else if (currentTime <= veryLateThreshold) {
      return 'late';
    } else {
      return 'very_late';
    }
  }

  // Navigation methods
  void goBack() {
    Get.back();
  }

  void goToCamera() {
    Get.back(); // Go back to camera
  }

  void goHome() {
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
