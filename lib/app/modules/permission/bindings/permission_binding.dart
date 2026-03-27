import 'package:get/get.dart';
import 'package:anbucheck/app/modules/permission/controllers/permission_controller.dart';

class PermissionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionController>(
      () => PermissionController(),
    );
  }
}
