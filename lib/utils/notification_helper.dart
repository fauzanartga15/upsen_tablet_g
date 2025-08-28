import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../infrastructure/theme/app_theme.dart';

class NotificationHelper {
  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      backgroundColor: AppTheme.success,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showAttendanceSuccess(
    String employeeName,
    String action,
    String time,
  ) {
    final actionText = action == 'check_in' ? 'Check-in' : 'Check-out';
    showSuccess(
      '$employeeName - $actionText recorded at $time',
      title: 'Attendance Recorded',
    );
  }
}
