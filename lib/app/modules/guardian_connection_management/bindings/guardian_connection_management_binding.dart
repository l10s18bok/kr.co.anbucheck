import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/controllers/guardian_connection_management_controller.dart';

class GuardianConnectionManagementBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GuardianSubjectService>()) {
      Get.put(GuardianSubjectService(), permanent: true);
    }
    Get.lazyPut<GuardianConnectionManagementController>(
      () => GuardianConnectionManagementController(),
    );
  }
}
