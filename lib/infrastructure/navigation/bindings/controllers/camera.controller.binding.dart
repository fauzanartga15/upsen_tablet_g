import 'package:get/get.dart';

import '../../../../presentation/camera/controllers/camera_view.controller.dart';

class CameraControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraViewController>(() => CameraViewController());
  }
}
