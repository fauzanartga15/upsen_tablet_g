import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/camera.controller.dart';

class CameraScreen extends GetView<CameraController> {
  const CameraScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CameraScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CameraScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
