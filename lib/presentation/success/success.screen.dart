// lib/presentation/success/success.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/theme/app-theme.dart';
import 'controllers/success.controller.dart';

class SuccessScreen extends GetView<SuccessController> {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Column(
              children: [
                // Header with close button
                _buildHeader(isTablet),

                // Main success content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success animation
                      _buildSuccessAnimation(isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Employee card
                      _buildEmployeeCard(isTablet),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Attendance details
                      _buildAttendanceDetails(isTablet),

                      SizedBox(height: isTablet ? 40 : 32),

                      // Action buttons
                      _buildActionButtons(isTablet),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance Confirmed',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        IconButton(
          onPressed: controller.goHome,
          icon: Icon(
            Icons.close,
            size: isTablet ? 28 : 24,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAnimation(bool isTablet) {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        transform: Matrix4.identity()..scale(controller.animationScale.value),
        child: Container(
          width: isTablet ? 120 : 100,
          height: isTablet ? 120 : 100,
          decoration: BoxDecoration(
            gradient: AppTheme.upsenGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow,
          ),
          child: Icon(
            controller.getStatusIcon(),
            color: Colors.white,
            size: isTablet ? 60 : 50,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(bool isTablet) {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()
          ..translate(0.0, controller.cardSlideOffset.value),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: AppTheme.glassmorphismDecoration.copyWith(
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              // Employee photo
              Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 100 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.upsenTeal, width: 3),
                ),
                child: ClipOval(
                  child: controller.imageUrl.value.isNotEmpty
                      ? Image.network(
                          controller.imageUrl.value,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultEmployeeAvatar(isTablet),
                        )
                      : _buildDefaultEmployeeAvatar(isTablet),
                ),
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // Employee name
              Text(
                controller.employeeName.value,
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 8 : 6),

              // Department and position
              Text(
                controller.department.value,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              if (controller.position.value.isNotEmpty) ...[
                SizedBox(height: isTablet ? 4 : 3),
                Text(
                  controller.position.value,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: isTablet ? 16 : 12),

              // Confidence indicator
              if (controller.confidence.value > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                    border: Border.all(
                      color: _getConfidenceColor().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.confidence.value >= 0.90
                            ? Icons.verified
                            : Icons.check_circle_outline,
                        color: _getConfidenceColor(),
                        size: isTablet ? 18 : 16,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        '${(controller.confidence.value * 100).toStringAsFixed(0)}% Match${controller.autoConfirm.value ? " (Auto)" : ""}',
                        style: TextStyle(
                          color: _getConfidenceColor(),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultEmployeeAvatar(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.upsenGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          controller.employeeName.value.isNotEmpty
              ? controller.employeeName.value[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 36 : 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceDetails(bool isTablet) {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, controller.detailsSlideOffset.value),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: AppTheme.glassmorphismDecoration.copyWith(
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              // Action type
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 10 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.upsenGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getActionIcon(),
                          color: Colors.white,
                          size: isTablet ? 20 : 18,
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          controller.getActionText(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // Time and status details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Time',
                      controller.formattedTime,
                      Icons.access_time,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: _buildDetailItem(
                      'Status',
                      controller.getStatusText(),
                      controller.getStatusIcon(),
                      isTablet,
                      color: controller.getStatusColor(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Date
              _buildDetailItem(
                'Date',
                controller.formattedDate,
                Icons.calendar_today,
                isTablet,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    bool isTablet, {
    Color? color,
    bool fullWidth = false,
  }) {
    final itemColor = color ?? AppTheme.upsenTeal;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: itemColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(color: itemColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: itemColor, size: isTablet ? 24 : 20),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            value,
            style: TextStyle(
              color: itemColor,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: AppTheme.gradientButton(
            text: 'New Entry',
            icon: Icons.add_circle_outline,
            onPressed: controller.startNewEntry,
            isSecondary: true,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          flex: 2,
          child: AppTheme.gradientButton(
            text: 'Back to Home',
            icon: Icons.home,
            onPressed: controller.goHome,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    final confidence = controller.confidence.value;
    if (confidence >= 0.90) return AppTheme.success;
    if (confidence >= 0.75) return AppTheme.warning;
    return AppTheme.upsenTeal;
  }
}
