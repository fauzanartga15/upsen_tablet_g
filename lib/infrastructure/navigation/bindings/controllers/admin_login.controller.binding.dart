import 'package:get/get.dart';

import '../../../../presentation/admin-login/controllers/admin_login.controller.dart';

class AdminLoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminLoginController>(
      () => AdminLoginController(),
    );
  }
}
