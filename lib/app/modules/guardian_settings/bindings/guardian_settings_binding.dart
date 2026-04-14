import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/modules/guardian_settings/controllers/guardian_settings_controller.dart';

class GuardianSettingsBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GuardianSubjectService>()) {
      Get.put(GuardianSubjectService(), permanent: true);
    }
    // 설정 페이지의 G+S 버튼이 Dashboard 컨트롤러의 상태/메서드를 참조하므로
    // Dashboard에서 진입하지 않고 바로 설정으로 온 경우를 대비해 보장 등록
    if (!Get.isRegistered<GuardianDashboardController>()) {
      Get.put<GuardianDashboardController>(
        GuardianDashboardController(),
        permanent: true,
      );
    }
    Get.lazyPut<GuardianSettingsController>(
      () => GuardianSettingsController(),
    );
  }
}
