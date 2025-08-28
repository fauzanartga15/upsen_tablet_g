import 'package:get/get.dart';

import '../../../../presentation/manual-entry/controllers/manual_entry.controller.dart';

class ManualEntryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualEntryController>(
      () => ManualEntryController(),
    );
  }
}
