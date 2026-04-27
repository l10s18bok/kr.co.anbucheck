import 'package:get/get.dart';

import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_base_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';

/// 보호자 G+S 모드 안전코드 컨트롤러 — UI 전용
///
/// heartbeat 자동 재전송은 [GuardianDashboardController]가 단독 소유하며,
/// 이 컨트롤러는 보고 상태 표시(`lastHeartbeatDate/Time`, `isReportedToday`)를
/// Dashboard의 Rx에서 직접 위임 구독한다.
///
/// **반응성 주의**: 아래 getter 내부의 `.value` 접근(`_dashboard.lastHeartbeatDate`
/// 가 내부적으로 Rx `.value`를 읽음)이 Obx 의존성을 등록한다.
/// **로컬 변수에 캐시하지 말 것** — 캐시하면 Dashboard Rx 변경에 반응하지 않는다.
class GuardianSafetyCodeController extends SafetyHomeBaseController {
  @override
  HomeRole get role => HomeRole.guardianSubject;

  /// Dashboard 컨트롤러는 Dashboard/Settings 바인딩에서 permanent:true로 등록되어
  /// 안전코드 페이지 진입 시점에는 반드시 존재한다.
  GuardianDashboardController get _dashboard =>
      Get.find<GuardianDashboardController>();

  // ── Dashboard에 위임 (캐시 금지) ─────────────────────────────────

  @override
  String get lastHeartbeatDate => _dashboard.lastHeartbeatDate;

  @override
  String get lastHeartbeatTime => _dashboard.lastHeartbeatTime;

  @override
  bool get isReportedToday => _dashboard.isReportedToday;

  // ── Template Method hook (G+S는 Dashboard가 단독 소유) ──────────

  @override
  Future<void> onAfterLoad() async {
    // noop — heartbeat 자동 재전송은 Dashboard가 단독 소유
  }

  @override
  Future<void> onResumedRoleSpecific() async {
    // noop — Dashboard.onResumed에서 처리
  }

  @override
  Future<void> onHeartbeatSent() => _dashboard.reloadHeartbeatState();
}
