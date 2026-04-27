import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:anbucheck/app/modules/safety_home/controllers/guardian_safety_code_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_base_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/subject_home_controller.dart';

/// 안전 홈 페이지 바인딩
///
/// `Get.arguments['role']`에 따라 자식 컨트롤러를 등록한다.
/// 페이지는 `GetView<SafetyHomeBaseController>`이므로 다형성으로 자식 인스턴스를 받는다.
///
/// **role 누락 처리**:
/// - dev 빌드: `assert`로 즉시 crash → 호출처 수정 강제
/// - release 빌드: loud log + S로 fallthrough (보호자 모드 페이지에서 S 컨트롤러가
///   등록되면 Dashboard 위임이 깨지지만, 적어도 S Drawer 분기로 비교적 가시적인
///   사용자 영향이 발생해 조기 발견 가능)
///
/// 호출 예:
/// ```
/// Get.toNamed(AppRoutes.safetyHome, arguments: {'role': HomeRole.subject});
/// Get.toNamed(AppRoutes.safetyHome, arguments: {
///   'role': HomeRole.guardianSubject,
///   'deviceData': {...},  // 선택, 중복 API 호출 방지
/// });
/// ```
class SafetyHomeBinding implements Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final role = args is Map ? args['role'] as HomeRole? : null;

    assert(role != null,
        'AppRoutes.safetyHome requires a HomeRole argument. '
        'Pass arguments: {"role": HomeRole.subject | HomeRole.guardianSubject}');

    if (role == null) {
      debugPrint(
          '[SafetyHomeBinding] WARN: role argument missing — defaulting to '
          'HomeRole.subject. This indicates a buggy navigation call.');
    }

    final resolved = role ?? HomeRole.subject;
    if (resolved == HomeRole.subject) {
      Get.lazyPut<SafetyHomeBaseController>(() => SubjectHomeController());
    } else {
      Get.lazyPut<SafetyHomeBaseController>(
          () => GuardianSafetyCodeController());
    }
  }
}
