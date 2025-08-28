import 'package:get/get.dart';

import '../../../../presentation/camera/controllers/camera.controller.dart';

class CameraControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraController>(
      () => CameraController(),
    );
  }
}
