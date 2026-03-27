import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 모드 선택 컨트롤러
/// 모드 선택 → 권한 안내 페이지로 이동
class ModeSelectController extends BaseController {
  /// 대상자 모드 선택 → 권한 안내 페이지 (mode=subject)
  void selectSubjectMode() {
    Get.toNamed(AppRoutes.permission, arguments: {'mode': 'subject'});
  }

  /// 보호자 모드 선택 → 권한 안내 페이지 (mode=guardian)
  void selectGuardianMode() {
    Get.toNamed(AppRoutes.permission, arguments: {'mode': 'guardian'});
  }
}
