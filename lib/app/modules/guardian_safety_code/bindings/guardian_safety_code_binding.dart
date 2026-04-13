import 'package:get/get.dart';
import 'package:anbucheck/app/modules/guardian_safety_code/controllers/guardian_safety_code_controller.dart';

class GuardianSafetyCodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuardianSafetyCodeController>(
      () => GuardianSafetyCodeController(),
    );
  }
}
