import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraViewController extends GetxController {
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

  // Face detector
  late final FaceDetector _faceDetector;
  Timer? _detectionTimer;
  bool _isProcessingFrame = false;

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

      // Use front camera for entrance station
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isInitialized(true);
      recognitionStatus('Camera ready - position your face');
      _startDetection();
    } catch (e) {
      errorMessage('Camera initialization failed: ${e.toString()}');
    }
  }

  void _startDetection() {
    if (!isInitialized.value) return;

    isDetecting(true);
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 500), // Detection every 500ms
      (_) => _processFrame(),
    );
  }

  Future<void> _processFrame() async {
    if (_isProcessingFrame || !isInitialized.value) return;
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    try {
      _isProcessingFrame = true;

      final image = await cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      final detectedFaces = await _faceDetector.processImage(inputImage);
      faces.assignAll(detectedFaces);

      if (detectedFaces.isNotEmpty) {
        recognitionStatus('Face detected - analyzing...');
        // TODO: Implement face recognition logic
        recognitionConfidence(0.85); // Placeholder

        // Simulate successful recognition for demo
        Future.delayed(const Duration(seconds: 2), () {
          if (recognitionConfidence.value > 0.8) {
            _proceedToAttendance();
          }
        });
      } else {
        recognitionStatus('Position face in frame');
        recognitionConfidence(0.0);
      }

      // Clean up temp file
      await File(image.path).delete();
    } catch (e) {
      print('Frame processing error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _proceedToAttendance() {
    // Stop detection
    _stopDetection();

    // Navigate to success with dummy data
    Get.toNamed(
      '/success',
      arguments: {
        'employeeName': 'John Doe',
        'department': 'IT Department',
        'action': 'check_in',
        'time': DateTime.now().toString().split(' ')[1].substring(0, 8),
        'confidence': recognitionConfidence.value,
        'status': 'ontime',
      },
    );
  }

  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    isDetecting(false);
    faces.clear();
  }

  void manualEntry() {
    Get.snackbar(
      'Manual Entry',
      'Manual entry feature coming soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void openSettings() {
    Get.snackbar(
      'Settings',
      'Settings feature coming soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void goBack() {
    _stopDetection();
    Get.back();
  }

  @override
  void onClose() {
    _stopDetection();
    _faceDetector.close();
    cameraController?.dispose();
    super.onClose();
  }
}
