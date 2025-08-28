// lib/app/services/face_recognition_service.dart - Updated with proper GetX service pattern
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService extends GetxService {
  static const String modelPath = 'assets/models/mobile_face_net.tflite';
  static const int inputSize = 112;
  static const int embeddingSize = 192;

  Interpreter? _interpreter;
  final RxBool _isModelLoaded = false.obs;

  bool get isModelLoaded => _isModelLoaded.value;

  // Proper GetxService initialization
  static Future<FaceRecognitionService> init() async {
    final service = FaceRecognitionService();
    await service._loadModel();
    return service;
  }

  Future<bool> _loadModel() async {
    try {
      print("Loading MobileFaceNet model from $modelPath...");

      _interpreter = await Interpreter.fromAsset(modelPath);

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      print("Model loaded successfully!");
      print("Input shape: $inputShape");
      print("Output shape: $outputShape");

      _isModelLoaded.value = true;
      return true;
    } catch (e) {
      print("Error loading model: $e");
      _isModelLoaded.value = false;
      return false;
    }
  }

  // Generate face embedding
  Future<List<double>?> generateEmbedding(Uint8List imageBytes) async {
    if (!_isModelLoaded.value) {
      print("Model not loaded");
      return null;
    }

    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final preprocessed = _preprocessImage(image);
      if (preprocessed == null) return null;

      final output = List.filled(
        1 * embeddingSize,
        0.0,
      ).reshape([1, embeddingSize]);
      _interpreter!.run(preprocessed, output);

      final embedding = List<double>.from(output[0]);
      return _normalizeEmbedding(embedding);
    } catch (e) {
      print("Error generating embedding: $e");
      return null;
    }
  }

  List<List<List<List<double>>>>? _preprocessImage(img.Image image) {
    try {
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );

      return List.generate(
        1,
        (b) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) => List.generate(3, (c) {
              final pixel = resized.getPixel(x, y);
              double value;

              switch (c) {
                case 0:
                  value = pixel.r.toDouble();
                  break;
                case 1:
                  value = pixel.g.toDouble();
                  break;
                case 2:
                  value = pixel.b.toDouble();
                  break;
                default:
                  value = 0.0;
              }

              return (value - 127.5) / 127.5;
            }),
          ),
        ),
      );
    } catch (e) {
      print("Error preprocessing image: $e");
      return null;
    }
  }

  List<double> _normalizeEmbedding(List<double> embedding) {
    double norm = 0.0;
    for (double value in embedding) {
      norm += value * value;
    }
    norm = math.sqrt(norm);

    if (norm == 0.0) return embedding;
    return embedding.map((value) => value / norm).toList();
  }

  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    final similarity = dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
    return similarity.clamp(-1.0, 1.0);
  }

  double similarityToPercentage(double similarity) {
    return ((similarity + 1.0) / 2.0 * 100.0).clamp(0.0, 100.0);
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }
}
