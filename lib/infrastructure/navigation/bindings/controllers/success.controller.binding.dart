import 'package:get/get.dart';

import '../../../../presentation/success/controllers/success.controller.dart';

class SuccessControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuccessController>(
      () => SuccessController(),
    );
  }
}
