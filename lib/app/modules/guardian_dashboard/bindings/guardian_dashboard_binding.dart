import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';

class GuardianDashboardBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GuardianSubjectService>()) {
      Get.put(GuardianSubjectService(), permanent: true);
    }
    Get.lazyPut<GuardianDashboardController>(
      () => GuardianDashboardController(),
    );
  }
}
