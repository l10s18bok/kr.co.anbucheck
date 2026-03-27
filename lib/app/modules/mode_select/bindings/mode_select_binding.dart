import 'package:get/get.dart';
import 'package:anbucheck/app/modules/mode_select/controllers/mode_select_controller.dart';

class ModeSelectBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModeSelectController>(
      () => ModeSelectController(),
    );
  }
}
