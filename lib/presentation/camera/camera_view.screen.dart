import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../app/widget/face_overlay_painter.dart';
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
            // Background gradient for areas not covered by camera
            _buildBackgroundGradient(),

            // Camera preview with 4:3 aspect ratio
            _buildCameraPreview(context),

            // Face detection overlay
            _buildFaceOverlay(context),

            // Recognition status overlay
            _buildRecognitionStatus(isTablet),

            // Action buttons
            _buildActionButtons(isTablet),

            // Header
            _buildHeader(isTablet),

            // Confidence progress
            _buildConfidenceProgress(isTablet),

            // Corner decorations
            _buildCornerDecorations(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            AppTheme.upsenTealDark.withValues(alpha: 0.3),
            Colors.black,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Center(
      child: Obx(() {
        if (!controller.isInitialized.value ||
            controller.cameraController == null) {
          return _buildLoadingState();
        }

        return _buildCameraContainer(context);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.upsenTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.upsenTeal.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.upsenTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: AppTheme.upsenTeal,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Initializing Camera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please allow camera permission',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          if (controller.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(height: 12),
                  Text(
                    'Camera Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraContainer(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate 4:3 aspect ratio container size
    final maxWidth = screenSize.width;
    final maxHeight = screenSize.height * 0.85; // Leave space for UI elements

    double containerWidth, containerHeight;

    if (maxWidth / maxHeight > 3 / 4) {
      // Height constrained
      containerHeight = maxHeight;
      containerWidth = containerHeight * (3 / 4);
    } else {
      // Width constrained
      containerWidth = maxWidth;
      containerHeight = containerWidth * (4 / 3);
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.upsenTeal.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.upsenTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Camera preview
            SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width:
                      controller.cameraController!.value.previewSize?.height ??
                      containerWidth,
                  height:
                      controller.cameraController!.value.previewSize?.width ??
                      containerHeight,
                  child: CameraPreview(controller.cameraController!),
                ),
              ),
            ),

            // Scanning animation overlay
            _buildScanningAnimation(),

            // Corner scan indicators
            _buildScanCorners(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return Obx(() {
      if (!controller.isDetecting.value) return SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          child: Stack(
            children: [
              // Animated scanning line
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.upsenTeal,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScanCorners() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: Stack(
          children: [
            // Top-left corner
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.upsenTeal, width: 4),
                    left: BorderSide(color: AppTheme.upsenTeal, width: 4),
                  ),
                ),
              ),
            ),
            // Top-right corner
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.upsenTeal, width: 4),
                    right: BorderSide(color: AppTheme.upsenTeal, width: 4),
                  ),
                ),
              ),
            ),
            // Bottom-left corner
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.upsenTeal, width: 4),
                    left: BorderSide(color: AppTheme.upsenTeal, width: 4),
                  ),
                ),
              ),
            ),
            // Bottom-right corner
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.upsenTeal, width: 4),
                    right: BorderSide(color: AppTheme.upsenTeal, width: 4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceOverlay(BuildContext context) {
    return Center(
      child: Obx(() {
        if (controller.faces.isEmpty) return const SizedBox.shrink();

        final screenSize = MediaQuery.of(context).size;
        final maxWidth = screenSize.width;
        final maxHeight = screenSize.height * 0.75;

        double containerWidth, containerHeight;
        if (maxWidth / maxHeight > 4 / 3) {
          containerHeight = maxHeight;
          containerWidth = containerHeight * (4 / 3);
        } else {
          containerWidth = maxWidth;
          containerHeight = containerWidth * (3 / 4);
        }

        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomPaint(
              painter: FaceOverlayPainter(
                faces: controller.faces,
                confidence: controller.recognitionConfidence.value,
                detectedUser: controller.detectedUser.value,
                imageSize: controller.getImageSize,
                screenSize: Size(containerWidth, containerHeight),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCornerDecorations() {
    return Stack(
      children: [
        // Top corners
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.upsenTeal.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.upsenTeal.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Keep existing methods but update positions for new layout
  Widget _buildConfidenceProgress(bool isTablet) {
    return Positioned(
      top: isTablet ? 120 : 100,
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
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  (isHigh
                          ? Colors.green
                          : isMedium
                          ? Colors.orange
                          : Colors.red)
                      .withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isHigh
                            ? Colors.green
                            : isMedium
                            ? Colors.orange
                            : Colors.red)
                        .withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Confidence percentage with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isHigh
                            ? Icons.check_circle
                            : isMedium
                            ? Icons.warning
                            : Icons.search,
                        color: isHigh
                            ? Colors.green
                            : isMedium
                            ? Colors.orange
                            : Colors.red,
                        size: isTablet ? 24 : 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recognition Confidence',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          (isHigh
                                  ? Colors.green
                                  : isMedium
                                  ? Colors.orange
                                  : Colors.red)
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHigh
                            ? Colors.green
                            : isMedium
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                    child: Text(
                      '${(confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isHigh
                            ? Colors.green
                            : isMedium
                            ? Colors.orange
                            : Colors.red,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),

              // Enhanced progress bar
              Container(
                height: isTablet ? 12 : 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FractionallySizedBox(
                  widthFactor: confidence,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHigh
                            ? [
                                Colors.green.shade300,
                                Colors.green.shade600,
                                Colors.green.shade400,
                              ]
                            : isMedium
                            ? [
                                Colors.orange.shade300,
                                Colors.orange.shade600,
                                Colors.orange.shade400,
                              ]
                            : [
                                Colors.red.shade300,
                                Colors.red.shade600,
                                Colors.red.shade400,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isHigh
                                      ? Colors.green
                                      : isMedium
                                      ? Colors.orange
                                      : Colors.red)
                                  .withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Threshold indicators
              if (confidence > 0) ...[
                SizedBox(height: isTablet ? 12 : 10),
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
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [AppTheme.upsenTeal, AppTheme.upsenTealLight],
              )
            : null,
        color: isActive ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
        border: Border.all(
          color: isActive ? AppTheme.upsenTeal : Colors.grey.shade600,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontSize: isTablet ? 12 : 10,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRecognitionStatus(bool isTablet) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: isTablet ? 200 : 180,
      child: Obx(() {
        final user = controller.detectedUser.value;
        final status = controller.recognitionStatus.value;

        return Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.upsenTeal.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.upsenTeal.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              if (user != null) ...[
                Row(
                  children: [
                    Container(
                      width: isTablet ? 70 : 60,
                      height: isTablet ? 70 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.upsenTeal, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.upsenTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
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
                    SizedBox(width: isTablet ? 20 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.department,
                            style: TextStyle(
                              color: AppTheme.upsenTealLight,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (user.position.isNotEmpty)
                            Text(
                              user.position,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
              ],
              Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.isDetecting.value &&
                  controller.recognitionAttempts.value > 0) ...[
                SizedBox(height: isTablet ? 12 : 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.upsenTeal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.upsenTeal),
                  ),
                  child: Text(
                    'Attempt ${controller.recognitionAttempts.value} of 3',
                    style: TextStyle(
                      color: AppTheme.upsenTeal,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
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
            fontSize: isTablet ? 28 : 24,
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
      bottom: isTablet ? 50 : 40,
      child: Row(
        children: [
          Expanded(
            child: AppTheme.gradientButton(
              text: 'Manual',
              icon: Icons.edit_outlined,
              onPressed: controller.goToManualEntry,
              isSecondary: true,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Obx(
              () => AppTheme.gradientButton(
                text: controller.isProcessing.value
                    ? 'Processing...'
                    : 'Settings',
                icon: controller.isProcessing.value
                    ? null
                    : Icons.settings_outlined,
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
      top: isTablet ? 20 : 15,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.upsenTeal.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.upsenTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.upsenTeal.withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: controller.goBack,
              ),
            ),
            Expanded(
              child: Text(
                'Face Recognition',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      (controller.isDetecting.value
                              ? Colors.green
                              : Colors.orange)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.isDetecting.value
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Row(
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
                        boxShadow: [
                          BoxShadow(
                            color:
                                (controller.isDetecting.value
                                        ? Colors.green
                                        : Colors.orange)
                                    .withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      controller.isDetecting.value ? 'ACTIVE' : 'PAUSED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
