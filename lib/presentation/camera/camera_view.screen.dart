// lib/presentation/camera/camera_view.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

import '../../infrastructure/theme/app-theme.dart';
import 'controllers/camera_view.controller.dart';

class CameraViewScreen extends GetView<CameraViewController> {
  const CameraViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            _buildCameraPreview(context),

            // Face detection overlay
            _buildFaceOverlay(),

            // Recognition status overlay
            _buildRecognitionStatus(isTablet),

            // Action buttons
            _buildActionButtons(isTablet),

            // Header
            _buildHeader(isTablet),

            // Confidence progress
            _buildConfidenceProgress(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Obx(() {
      if (!controller.isInitialized.value ||
          controller.cameraController == null) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.upsenTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: AppTheme.upsenTeal,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please allow camera permission',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (controller.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(controller.cameraController!),
      );
    });
  }

  Widget _buildFaceOverlay() {
    return Positioned.fill(
      child: Obx(() {
        if (controller.faces.isEmpty) return const SizedBox.shrink();

        return CustomPaint(
          painter: AttendanceFaceOverlayPainter(
            faces: controller.faces,
            confidence: controller.recognitionConfidence.value,
            detectedUser: controller.detectedUser.value,
          ),
        );
      }),
    );
  }

  Widget _buildConfidenceProgress(bool isTablet) {
    return Positioned(
      top: isTablet ? 100 : 80,
      left: 20,
      right: 20,
      child: Obx(() {
        if (controller.recognitionConfidence.value == 0) {
          return SizedBox.shrink();
        }

        final confidence = controller.recognitionConfidence.value;
        final isHigh = confidence >= 0.90;
        final isMedium = confidence >= 0.75;

        return Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color:
                  (isHigh
                          ? Colors.green
                          : isMedium
                          ? Colors.orange
                          : Colors.red)
                      .withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              // Confidence percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recognition Confidence',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isHigh
                          ? Colors.green
                          : isMedium
                          ? Colors.orange
                          : Colors.red,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 12 : 8),

              // Progress bar
              Container(
                height: isTablet ? 8 : 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
                ),
                child: FractionallySizedBox(
                  widthFactor: confidence,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHigh
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : isMedium
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 4 : 3),
                    ),
                  ),
                ),
              ),

              // Threshold indicators
              if (confidence > 0) ...[
                SizedBox(height: isTablet ? 8 : 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThresholdIndicator(
                      'Auto: 90%',
                      confidence >= 0.90,
                      isTablet,
                    ),
                    _buildThresholdIndicator(
                      'Confirm: 75%',
                      confidence >= 0.75,
                      isTablet,
                    ),
                    _buildThresholdIndicator(
                      'Manual: <75%',
                      confidence < 0.75,
                      isTablet,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildThresholdIndicator(String label, bool isActive, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 6,
        vertical: isTablet ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.upsenTeal.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
        border: Border.all(
          color: isActive ? AppTheme.upsenTeal : Colors.grey.shade600,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.upsenTeal : Colors.grey.shade400,
          fontSize: isTablet ? 10 : 8,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRecognitionStatus(bool isTablet) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: isTablet ? 180 : 160,
      child: Obx(() {
        final user = controller.detectedUser.value;
        final status = controller.recognitionStatus.value;

        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: AppTheme.upsenTeal.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // User info if detected
              if (user != null) ...[
                Row(
                  children: [
                    // User avatar
                    Container(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.upsenTeal, width: 2),
                      ),
                      child: ClipOval(
                        child: user.imageUrl != null
                            ? Image.network(
                                user.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultAvatar(user.name, isTablet),
                              )
                            : _buildDefaultAvatar(user.name, isTablet),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),

                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.department,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                          if (user.position.isNotEmpty)
                            Text(
                              user.position,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: isTablet ? 12 : 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
              ],

              // Status text
              Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              // Attempts counter if active
              if (controller.isDetecting.value &&
                  controller.recognitionAttempts.value > 0) ...[
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  'Attempt ${controller.recognitionAttempts.value} of 3',
                  style: TextStyle(
                    color: AppTheme.upsenTeal,
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultAvatar(String name, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.upsenGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: isTablet ? 40 : 30,
      child: Row(
        children: [
          Expanded(
            child: AppTheme.gradientButton(
              text: 'Manual Entry',
              icon: Icons.edit,
              onPressed: controller.goToManualEntry,
              isSecondary: true,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Obx(
              () => AppTheme.gradientButton(
                text: controller.isProcessing.value
                    ? 'Processing...'
                    : 'Settings',
                icon: controller.isProcessing.value ? null : Icons.settings,
                onPressed: controller.isProcessing.value
                    ? () {}
                    : controller.openSettings,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Positioned(
      top: isTablet ? 20 : 10,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
              onPressed: controller.goBack,
            ),
            Expanded(
              child: Text(
                'Face Recognition Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Status indicator
            Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isTablet ? 12 : 10,
                    height: isTablet ? 12 : 10,
                    decoration: BoxDecoration(
                      color: controller.isDetecting.value
                          ? Colors.green
                          : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    controller.isDetecting.value ? 'ACTIVE' : 'PAUSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FIXED Face Overlay Painter
class AttendanceFaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final double confidence;
  final DetectedUser? detectedUser;

  AttendanceFaceOverlayPainter({
    required this.faces,
    required this.confidence,
    this.detectedUser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    print("🎨 Painting ${faces.length} faces on canvas ${size}");

    for (final face in faces) {
      final rect = face.boundingBox;
      print("🎨 Drawing face at: $rect");

      _drawFaceRect(canvas, rect, size);
      _drawConfidenceIndicator(canvas, rect, size);
    }
  }

  void _drawFaceRect(Canvas canvas, Rect rect, Size size) {
    final isHighConfidence = confidence >= 0.90;
    final isMedium = confidence >= 0.75;

    Color rectColor;
    if (isHighConfidence) {
      rectColor = Colors.green;
    } else if (isMedium) {
      rectColor = Colors.orange;
    } else {
      rectColor = AppTheme.upsenTeal;
    }

    // Face rectangle
    final Paint facePaint = Paint()
      ..color = rectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw rounded rectangle
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, facePaint);

    // Draw corner indicators
    _drawCornerIndicators(canvas, rect, rectColor);
  }

  void _drawCornerIndicators(Canvas canvas, Rect rect, Color color) {
    final Paint cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
  }

  void _drawConfidenceIndicator(Canvas canvas, Rect rect, Size size) {
    if (confidence == 0) return;

    final isHighConfidence = confidence >= 0.90;
    final isMedium = confidence >= 0.75;

    Color bgColor;

    if (isHighConfidence) {
      bgColor = Colors.green;
    } else if (isMedium) {
      bgColor = Colors.orange;
    } else {
      bgColor = Colors.red;
    }

    // Background for indicator
    final indicatorRect = Rect.fromLTWH(rect.left, rect.top - 35, 120, 30);

    final Paint bgPaint = Paint()..color = bgColor.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(indicatorRect, const Radius.circular(8)),
      bgPaint,
    );

    // Confidence text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 8, rect.top - 28));

    // Status text
    String statusText;
    if (isHighConfidence) {
      statusText = 'AUTO';
    } else if (isMedium) {
      statusText = 'CONFIRM';
    } else {
      statusText = 'SCANNING';
    }

    final statusPainter = TextPainter(
      text: TextSpan(
        text: statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    statusPainter.layout();
    statusPainter.paint(canvas, Offset(rect.left + 60, rect.top - 26));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
