// lib/presentation/success/controllers/success.controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/theme/app-theme.dart';

class SuccessController extends GetxController
    with GetTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _scaleAnimationController;
  late AnimationController _slideAnimationController;

  // Observable variables
  var employeeName = ''.obs;
  var department = ''.obs;
  var position = ''.obs;
  var action = ''.obs;
  var time = ''.obs;
  var confidence = 0.0.obs;
  var status = ''.obs;
  var autoConfirm = false.obs;
  var imageUrl = ''.obs;

  // Animation observables
  var animationScale = 0.0.obs;
  var cardSlideOffset = 100.0.obs;
  var detailsSlideOffset = 100.0.obs;

  // Computed properties
  String get formattedTime => _formatTime(time.value);
  String get formattedDate => _formatDate(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _loadArguments();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _scaleAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation for success icon
    final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    scaleAnimation.addListener(() {
      animationScale.value = scaleAnimation.value;
    });

    // Slide animations for cards
    final slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    slideAnimation.addListener(() {
      cardSlideOffset.value = slideAnimation.value;
      detailsSlideOffset.value = slideAnimation.value * 1.5; // Staggered effect
    });
  }

  void _loadArguments() {
    final args = Get.arguments ?? {};

    employeeName.value = args['employeeName'] ?? 'Unknown Employee';
    department.value = args['department'] ?? 'Unknown Department';
    position.value = args['position'] ?? '';
    action.value = args['action'] ?? 'check_in';
    time.value = args['time'] ?? DateTime.now().toString();
    confidence.value = (args['confidence'] ?? 0.0).toDouble();
    status.value = args['status'] ?? 'ontime';
    autoConfirm.value = args['autoConfirm'] ?? false;
    imageUrl.value = args['imageUrl'] ?? '';

    print('Success screen loaded for: ${employeeName.value}');
    print('Action: ${action.value}, Confidence: ${confidence.value}');
  }

  void _startAnimationSequence() async {
    // Start scale animation immediately
    _scaleAnimationController.forward();

    // Start slide animation after a short delay
    await Future.delayed(Duration(milliseconds: 200));
    _slideAnimationController.forward();

    // Auto-redirect after 5 seconds for high confidence
    if (confidence.value >= 0.90 || autoConfirm.value) {
      _startAutoRedirectTimer();
    }
  }

  void _startAutoRedirectTimer() {
    Timer(Duration(seconds: 5), () {
      if (Get.currentRoute.contains('success')) {
        goHome();
      }
    });
  }

  // Action methods
  void startNewEntry() {
    Get.back(); // Go back to camera
  }

  void goHome() {
    Get.offAllNamed('/home');
  }

  // UI Helper methods
  String getActionText() {
    switch (action.value) {
      case 'check_in':
        return 'CHECKED IN';
      case 'check_out':
        return 'CHECKED OUT';
      default:
        return 'ATTENDANCE';
    }
  }

  IconData getActionIcon() {
    switch (action.value) {
      case 'check_in':
        return Icons.login;
      case 'check_out':
        return Icons.logout;
      default:
        return Icons.access_time;
    }
  }

  String getStatusText() {
    switch (status.value) {
      case 'ontime':
        return 'ON TIME';
      case 'late':
        return 'LATE';
      case 'very_late':
        return 'VERY LATE';
      case 'early':
        return 'EARLY';
      default:
        return 'RECORDED';
    }
  }

  IconData getStatusIcon() {
    switch (status.value) {
      case 'ontime':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'very_late':
        return Icons.warning;
      case 'early':
        return Icons.wb_sunny;
      default:
        return Icons.info;
    }
  }

  Color getStatusColor() {
    switch (status.value) {
      case 'ontime':
        return AppTheme.success;
      case 'late':
        return AppTheme.warning;
      case 'very_late':
        return AppTheme.error;
      case 'early':
        return AppTheme.accentCyan;
      default:
        return AppTheme.upsenTeal;
    }
  }

  // Format helpers
  String _formatTime(String timeString) {
    try {
      if (timeString.contains(':')) {
        // If already formatted (HH:mm:ss)
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      } else {
        // Parse full datetime string
        final dateTime = DateTime.parse(timeString);
        return DateFormat('h:mm a').format(dateTime);
      }
    } catch (e) {
      print('Time formatting error: $e');
    }
    return DateFormat('h:mm a').format(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  // Animation getters for different confidence levels
  Color getConfidenceColor() {
    if (confidence.value >= 0.90) return AppTheme.success;
    if (confidence.value >= 0.75) return AppTheme.warning;
    return AppTheme.upsenTeal;
  }

  String getConfidenceText() {
    if (confidence.value >= 0.90) return 'HIGH CONFIDENCE';
    if (confidence.value >= 0.75) return 'MEDIUM CONFIDENCE';
    return 'LOW CONFIDENCE';
  }

  // Success feedback based on action and status
  String getSuccessMessage() {
    final actionText = getActionText();
    final statusText = getStatusText();

    if (autoConfirm.value) {
      return '$actionText automatically • $statusText';
    } else {
      return '$actionText successfully • $statusText';
    }
  }

  // Get appropriate feedback color
  Color getFeedbackColor() {
    if (autoConfirm.value && confidence.value >= 0.90) {
      return AppTheme.success;
    }
    return getStatusColor();
  }

  @override
  void onClose() {
    _scaleAnimationController.dispose();
    _slideAnimationController.dispose();
    super.onClose();
  }
}
