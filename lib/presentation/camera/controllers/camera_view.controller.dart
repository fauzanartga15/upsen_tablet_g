// lib/presentation/camera/controllers/camera_view.controller.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../app/data/providers/models/detect_user.dart';
import '../../../app/data/providers/repositories/attendanxe_repository.dart';
import '../../../app/services/face_recognition_service.dart';
import '../../../app/services/offline_sync_service.dart';

class CameraViewController extends GetxController {
  // Services
  final FaceRecognitionService _faceRecognitionService = Get.find();
  final OfflineSyncService _syncService = Get.find();
  final AttendanceRepository _repository = AttendanceRepository();

  // Camera variables
  CameraController? cameraController;
  var isInitialized = false.obs;
  var isDetecting = false.obs;
  var errorMessage = ''.obs;

  // Face detection
  var faces = <Face>[].obs;
  var recognitionStatus = 'Position face in frame'.obs;
  var recognitionConfidence = 0.0.obs;
  var isProcessing = false.obs;
  var detectedUser = Rxn<DetectedUser>();

  // Face detector
  late final FaceDetector _faceDetector;
  Timer? _detectionTimer;
  Timer? _recognitionTimer;
  bool _isProcessingFrame = false;
  bool _isProcessingRecognition = false;

  // Recognition state
  var recognitionAttempts = 0.obs;
  static const int maxAttempts = 3;
  static const double autoThreshold = 0.90;
  static const double confirmThreshold = 0.75;

  @override
  void onInit() {
    super.onInit();
    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: true,
    );
    _faceDetector = FaceDetector(options: options);
    print("✅ Face detector initialized for attendance");
  }

  Future<void> _initializeCamera() async {
    try {
      errorMessage('');
      recognitionStatus('Initializing camera...');

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage('No cameras found');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset
            .high, // Changed from high to medium for better 4:3 ratio
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();

      // Log camera info for debugging
      final previewSize = cameraController!.value.previewSize;
      print("Camera initialized:");
      print("  Resolution: ${cameraController!.resolutionPreset}");
      print("  Preview size: $previewSize");
      print("  Aspect ratio: ${cameraController!.value.aspectRatio}");

      isInitialized(true);
      recognitionStatus('Camera ready - position your face');
      _startDetection();

      print("Camera initialized for 4:3 attendance");
    } catch (e) {
      errorMessage('Camera initialization failed: ${e.toString()}');
      print("Camera error: $e");
    }
  }

  void _startDetection() {
    if (!isInitialized.value) return;

    isDetecting(true);
    recognitionAttempts(0);

    // Face detection every 200ms
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _processFrame(),
    );

    // Face recognition every 1 second
    _recognitionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _processRecognition(),
    );

    print("🔍 Face detection started for attendance");
  }

  Future<void> _processFrame() async {
    if (_isProcessingFrame || !isInitialized.value) return;
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    try {
      _isProcessingFrame = true;

      final image = await cameraController!.takePicture();

      // Get actual image file dimensions for comparison
      final imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      print("Image Analysis:");
      print(
        "  Captured image dimensions: ${decodedImage?.width}x${decodedImage?.height}",
      );
      print("  Camera preview size: ${getPreviewSize}");
      print("  Camera image size: ${getImageSize}");

      final inputImage = InputImage.fromFilePath(image.path);
      final detectedFaces = await _faceDetector.processImage(inputImage);
      faces.assignAll(detectedFaces);

      print("Face Detection Results:");
      print("  Detected ${detectedFaces.length} faces");
      if (detectedFaces.isNotEmpty) {
        print("  Face bounds: ${detectedFaces.first.boundingBox}");
        print("  Image used by ML Kit: ${inputImage.metadata?.size}");
      }

      if (detectedFaces.isNotEmpty) {
        if (recognitionStatus.value.contains('Position')) {
          recognitionStatus('Face detected - analyzing...');
        }
      } else {
        if (!recognitionStatus.value.contains('Position')) {
          recognitionStatus('Position face in frame');
          recognitionConfidence(0.0);
          detectedUser.value = null;
        }
      }

      // Clean up temp file
      await File(image.path).delete();
    } catch (e) {
      print('Frame processing error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _processRecognition() async {
    if (_isProcessingRecognition || !isInitialized.value) return;
    if (faces.isEmpty || !_faceRecognitionService.isModelLoaded) return;

    try {
      _isProcessingRecognition = true;
      recognitionAttempts.value++;

      final image = await cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return;

      // Process first detected face
      final face = faces.first;
      final faceEmbedding = await _extractFaceEmbedding(face, originalImage);

      if (faceEmbedding != null) {
        await _recognizeUser(faceEmbedding);
      }

      // Clean up temp file
      await File(image.path).delete();

      // Check if max attempts reached
      if (recognitionAttempts.value >= maxAttempts) {
        _handleMaxAttemptsReached();
      }
    } catch (e) {
      print('Recognition processing error: $e');
      recognitionStatus('Recognition error - please try again');
    } finally {
      _isProcessingRecognition = false;
    }
  }

  Future<List<double>?> _extractFaceEmbedding(
    Face face,
    img.Image originalImage,
  ) async {
    try {
      // Crop face from original image
      final boundingBox = face.boundingBox;
      final left = boundingBox.left.toInt().clamp(0, originalImage.width - 1);
      final top = boundingBox.top.toInt().clamp(0, originalImage.height - 1);
      final width = (boundingBox.width.toInt()).clamp(
        1,
        originalImage.width - left,
      );
      final height = (boundingBox.height.toInt()).clamp(
        1,
        originalImage.height - top,
      );

      final croppedFace = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      // Resize for model input
      final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);
      final faceBytes = Uint8List.fromList(img.encodeJpg(resizedFace));

      // Generate embedding
      return await _faceRecognitionService.generateEmbedding(faceBytes);
    } catch (e) {
      print('Face embedding extraction error: $e');
      return null;
    }
  }

  Future<void> _recognizeUser(List<double> faceEmbedding) async {
    try {
      // Call attendance API for recognition
      final response = await _repository.checkIn(faceEmbedding);

      if (response != null) {
        // Successful recognition
        final confidence = response.similarity;
        recognitionConfidence(confidence);

        detectedUser.value = DetectedUser(
          id: response.user.id,
          name: response.user.name,
          department: response.user.department ?? 'Unknown Department',
          position: response.user.position ?? 'Employee',
          imageUrl: response.user.imageUrl,
          confidence: confidence,
          action: 'check_in',
          timestamp: DateTime.now(),
        );

        if (confidence >= autoThreshold) {
          // Auto proceed - high confidence
          recognitionStatus('✅ Welcome ${response.user.name}!');
          await Future.delayed(Duration(seconds: 1));
          _proceedToSuccess(autoConfirm: true);
        } else if (confidence >= confirmThreshold) {
          // Require confirmation - medium confidence
          recognitionStatus('Please confirm: ${response.user.name}?');
          _showConfirmationDialog();
        } else {
          // Low confidence - continue trying
          recognitionStatus(
            'Looking for match... (${recognitionAttempts.value}/$maxAttempts)',
          );
        }
      }
    } catch (e) {
      print('User recognition error: $e');

      // If API fails, queue for offline sync
      if (e.toString().contains('queued offline')) {
        recognitionStatus('⏳ Queued for sync - please try manual entry');
        await Future.delayed(Duration(seconds: 2));
        _handleRecognitionFailure();
      } else {
        recognitionStatus('Recognition failed - please try again');
      }
    }
  }

  void _showConfirmationDialog() {
    final user = detectedUser.value;
    if (user == null) return;

    _stopDetection();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.imageUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.imageUrl!),
                onBackgroundImageError: (exception, stackTrace) {},
                child: user.imageUrl == null
                    ? Icon(Icons.person, size: 40)
                    : null,
              ),
            SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(user.department, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 8),
            Text('Confidence: ${(user.confidence * 100).toStringAsFixed(0)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _startDetection(); // Resume detection
            },
            child: Text('Not Me'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _proceedToSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleMaxAttemptsReached() {
    recognitionStatus('Recognition timeout - please try manual entry');
    _stopDetection();

    Future.delayed(Duration(seconds: 3), () {
      _showManualEntryOption();
    });
  }

  void _handleRecognitionFailure() {
    _stopDetection();
    Future.delayed(Duration(seconds: 2), () {
      _showManualEntryOption();
    });
  }

  void _showManualEntryOption() {
    Get.dialog(
      AlertDialog(
        title: Text('Recognition Failed'),
        content: Text(
          'Would you like to try manual entry or restart detection?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _restartDetection();
            },
            child: Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              goToManualEntry();
            },
            child: Text('Manual'),
          ),
        ],
      ),
    );
  }

  void _restartDetection() {
    recognitionAttempts(0);
    recognitionConfidence(0.0);
    detectedUser.value = null;
    recognitionStatus('Position face in frame');
    _startDetection();
  }

  void _proceedToSuccess({bool autoConfirm = false}) {
    final user = detectedUser.value;
    if (user == null) return;

    _stopDetection();

    Get.toNamed(
      '/success',
      arguments: {
        'employeeName': user.name,
        'department': user.department,
        'position': user.position,
        'action': user.action,
        'time': DateTime.now().toString().split(' ')[1].substring(0, 8),
        'confidence': user.confidence,
        'status': _getAttendanceStatus(DateTime.now()),
        'autoConfirm': autoConfirm,
        'imageUrl': user.imageUrl,
      },
    );
  }

  String _getAttendanceStatus(DateTime time) {
    final hour = time.hour;
    if (hour <= 8) return 'ontime';
    if (hour <= 9) return 'late';
    return 'very_late';
  }

  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _recognitionTimer?.cancel();
    _recognitionTimer = null;
    isDetecting(false);
    faces.clear();
  }

  Size get getImageSize {
    if (!isInitialized.value || cameraController == null) return Size.zero;
    final previewSize = cameraController!.value.previewSize;
    if (previewSize == null) return Size.zero;

    // FIXED: Return the actual image size that ML Kit processes
    // This should match the resolution of images taken by takePicture()
    return Size(previewSize.width, previewSize.height);
  }

  Size get getPreviewSize {
    if (!isInitialized.value || cameraController == null) return Size.zero;
    final previewSize = cameraController!.value.previewSize;
    if (previewSize == null) return Size.zero;

    return Size(previewSize.width, previewSize.height);
  }

  Size get getCaptureSize {
    if (!isInitialized.value || cameraController == null) return Size.zero;

    // This might be different from preview size
    // Check camera controller's resolution preset
    final previewSize = cameraController!.value.previewSize;
    if (previewSize == null) return Size.zero;

    // For debugging - let's see what we get
    print("Camera Debug:");
    print("  Preview size: $previewSize");
    print("  Aspect ratio: ${cameraController!.value.aspectRatio}");

    return Size(previewSize.width, previewSize.height);
  }

  void goToManualEntry() {
    _stopDetection();
    Get.toNamed('/manual-entry');
  }

  void openSettings() {
    Get.toNamed('/settings');
  }

  void goBack() {
    _stopDetection();
    Get.back();
  }

  @override
  void onClose() {
    print("🗑️ Disposing camera controller...");
    _stopDetection();
    _faceDetector.close();
    cameraController?.dispose();
    super.onClose();
  }
}
