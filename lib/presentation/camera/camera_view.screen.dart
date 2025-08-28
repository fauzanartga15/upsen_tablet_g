import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../infrastructure/theme/app-theme.dart';
import 'controllers/camera_view.controller.dart';
import 'package:camera/camera.dart';

class CameraViewScreen extends GetView<CameraViewController> {
  const CameraViewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            _buildCameraPreview(),

            // Face detection overlay
            _buildFaceOverlay(),

            // Recognition status
            _buildRecognitionStatus(),

            // Action buttons
            _buildActionButtons(),

            // Header
            _buildHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
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
              CircularProgressIndicator(color: AppTheme.upsenTeal),
              const SizedBox(height: 20),
              const Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (controller.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(
          controller.cameraController!,
        ), // FIXED: Direct CameraPreview usage
      );
    });
  }

  Widget _buildFaceOverlay() {
    return Positioned.fill(
      child: Obx(() {
        if (controller.faces.isEmpty) return const SizedBox.shrink();

        return CustomPaint(
          painter: SimpleFaceOverlayPainter(
            faces: controller.faces,
            confidence: controller.recognitionConfidence.value,
          ),
        );
      }),
    );
  }

  Widget _buildRecognitionStatus() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 200,
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.upsenTeal.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              // Confidence bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  widthFactor: controller.recognitionConfidence.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.warning, AppTheme.success],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status text
              Text(
                controller.recognitionStatus.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Confidence percentage
              if (controller.recognitionConfidence.value > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(controller.recognitionConfidence.value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppTheme.upsenTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 40,
      child: Row(
        children: [
          Expanded(
            child: AppTheme.gradientButton(
              text: 'Manual Entry',
              icon: Icons.edit,
              onPressed: controller.manualEntry,
              isSecondary: true,
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildHeader() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: controller.goBack,
            ),
            const Expanded(
              child: Text(
                'Face Recognition',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Face Overlay Painter (tanpa external dependencies dulu)
class SimpleFaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final double confidence;

  SimpleFaceOverlayPainter({required this.faces, required this.confidence});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    for (final face in faces) {
      final isHighConfidence = confidence > 0.8;

      // Choose colors based on confidence
      final Color rectColor = isHighConfidence
          ? AppTheme.success
          : AppTheme.upsenTeal;

      // Paint for face rectangles
      final Paint facePaint = Paint()
        ..color = rectColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Draw face rectangle with rounded corners
      final rect = face.boundingBox;
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, facePaint);

      // Draw confidence indicator
      if (confidence > 0) {
        _drawConfidenceIndicator(canvas, rect, confidence, isHighConfidence);
      }
    }
  }

  void _drawConfidenceIndicator(
    Canvas canvas,
    Rect faceRect,
    double confidence,
    bool isHigh,
  ) {
    final paint = Paint()
      ..color = (isHigh ? AppTheme.success : AppTheme.warning).withOpacity(0.9);

    final labelHeight = 24.0;
    final labelWidth = 60.0;

    final labelRect = Rect.fromLTWH(
      faceRect.left,
      faceRect.top - labelHeight - 4,
      labelWidth,
      labelHeight,
    );

    // Draw label background
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
      paint,
    );

    // Draw confidence text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        faceRect.left + (labelWidth - textPainter.width) / 2,
        faceRect.top - labelHeight + 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
