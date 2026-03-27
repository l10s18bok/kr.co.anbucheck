import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/modules/guardian_settings/controllers/guardian_settings_controller.dart';

class GuardianSettingsBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GuardianSubjectService>()) {
      Get.put(GuardianSubjectService(), permanent: true);
    }
    Get.lazyPut<GuardianSettingsController>(
      () => GuardianSettingsController(),
    );
  }
}
