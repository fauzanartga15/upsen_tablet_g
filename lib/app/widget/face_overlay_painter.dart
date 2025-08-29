import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../infrastructure/theme/app-theme.dart';
import '../data/providers/models/detect_user.dart';

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final double confidence;
  final DetectedUser? detectedUser;
  final Size imageSize; // ADD: Image size from camera
  final Size screenSize; // ADD: Screen/widget size

  FaceOverlayPainter({
    required this.faces,
    required this.confidence,
    this.detectedUser,
    required this.imageSize, // ADD: Required parameter
    required this.screenSize, // ADD: Required parameter
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty || imageSize.width == 0 || imageSize.height == 0) return;

    print("🎨 Painting ${faces.length} faces on canvas $size");
    print("🎨 Image size: $imageSize, Screen size: $screenSize");

    for (final face in faces) {
      final rect = face.boundingBox;
      print("🎨 Original face rect: $rect");

      // FIXED: Transform coordinates from image space to screen space
      final transformedRect = _transformRect(rect, imageSize, size);
      print("🎨 Transformed face rect: $transformedRect");

      _drawFaceRect(canvas, transformedRect, size);
      _drawConfidenceIndicator(canvas, transformedRect, size);
    }
  }

  // FIXED: Coordinate transformation method with proper camera preview handling
  Rect _transformRect(Rect originalRect, Size imageSize, Size canvasSize) {
    print("🔧 Transform Debug:");
    print("   Original rect: $originalRect");
    print("   Image size: $imageSize");
    print("   Canvas size: $canvasSize");

    Size actualImageSize = imageSize;
    Rect actualRect = originalRect;

    // Check if image is landscape but preview is portrait (or vice versa)
    bool imageIsLandscape = imageSize.width > imageSize.height;
    bool canvasIsPortrait = canvasSize.height > canvasSize.width;

    if (imageIsLandscape && canvasIsPortrait) {
      // Need to rotate coordinates 90 degrees
      actualImageSize = Size(imageSize.height, imageSize.width);
      actualRect = Rect.fromLTRB(
        originalRect.top, // left = original top
        imageSize.width - originalRect.right, // top = width - original right
        originalRect.bottom, // right = original bottom
        imageSize.width - originalRect.left, // bottom = width - original left
      );
      print("   Rotated rect: $actualRect");
      print("   Rotated image size: $actualImageSize");
    }

    // Now calculate scale to fit the preview
    final scaleX = canvasSize.width / actualImageSize.width;
    final scaleY = canvasSize.height / actualImageSize.height;

    // Camera preview typically uses ScaleType.CENTER_CROP equivalent
    // Use the larger scale to fill the preview area
    final scale = math.max(scaleX, scaleY);

    // Calculate how the scaled image is positioned in the canvas
    final scaledImageWidth = actualImageSize.width * scale;
    final scaledImageHeight = actualImageSize.height * scale;

    final offsetX = (canvasSize.width - scaledImageWidth) / 2;
    final offsetY = (canvasSize.height - scaledImageHeight) / 2;

    print("   Scale: $scale (scaleX: $scaleX, scaleY: $scaleY)");
    print("   Offset: ($offsetX, $offsetY)");

    // Transform the rectangle
    final transformedRect = Rect.fromLTWH(
      actualRect.left * scale + offsetX,
      actualRect.top * scale + offsetY,
      actualRect.width * scale,
      actualRect.height * scale,
    );

    print("   Final transformed rect: $transformedRect");
    return transformedRect;
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

    // Face rectangle with glow effect
    final Paint facePaint = Paint()
      ..color = rectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Add glow effect
    final Paint glowPaint = Paint()
      ..color = rectColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);

    // Draw glow first
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, facePaint);

    // Draw corner indicators
    _drawCornerIndicators(canvas, rect, rectColor);
  }

  void _drawCornerIndicators(Canvas canvas, Rect rect, Color color) {
    final Paint cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

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

    // Background for indicator - position above the face rect
    final indicatorWidth = 120.0;
    final indicatorHeight = 35.0;
    final indicatorRect = Rect.fromLTWH(
      rect.left.clamp(0, size.width - indicatorWidth),
      (rect.top - indicatorHeight - 5).clamp(0, size.height - indicatorHeight),
      indicatorWidth,
      indicatorHeight,
    );

    final Paint bgPaint = Paint()..color = bgColor.withValues(alpha: 0.9);
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
    textPainter.paint(
      canvas,
      Offset(indicatorRect.left + 8, indicatorRect.top + 8),
    );

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
    statusPainter.paint(
      canvas,
      Offset(indicatorRect.left + 60, indicatorRect.top + 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
