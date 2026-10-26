import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/fold_state_service.dart';
import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'package:anbucheck/app/core/utils/layout_breakpoints.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 좁은 화면(폰·접힘)에서 연 보호자 페이지를 펼쳤을 때 분할 화면으로 바꿔 준다.
///
/// 접힌 상태에서는 탭이 전폭 페이지(연결·알림·설정…)로 열린다. 그대로 펼치면 폭이 넓은데도
/// 하단 탭바가 달린 그 페이지가 전체 화면으로 남아, 분할 화면(왼쪽 대시보드 + 오른쪽 그 페이지)과
/// 어긋난다. 폭이 600dp 미만 → 이상으로 **넘어가는 순간**에만 현재 최상위 보호자 페이지를
/// 대시보드 위로 정리하고 그 페이지를 오른쪽 pane에 연다.
///
/// - 대시보드·안전 홈·그 외 화면은 건드리지 않는다.
/// - 폰은 폭이 600dp를 넘지 않아 발동하지 않는다.
class WideRouteNormalizer extends StatefulWidget {
  const WideRouteNormalizer({super.key, required this.child});

  final Widget child;

  @override
  State<WideRouteNormalizer> createState() => _WideRouteNormalizerState();
}

class _WideRouteNormalizerState extends State<WideRouteNormalizer> {
  /// pane에서 열 수 있는 보호자 페이지.
  static const _paneRoutes = {
    AppRoutes.guardianConnectionManagement,
    AppRoutes.guardianNotifications,
    AppRoutes.guardianSettings,
    AppRoutes.guardianAddSubject,
    AppRoutes.guardianNotificationSettings,
    AppRoutes.guardianEmergencyMap,
  };

  /// 직전 빌드에서 분할이 가능했는가 — [SplitShell]의 `capable`과 같은 조건(짧은 변 ≥600dp이고 접힘 아님).
  /// 폭만 보면 안 된다: 안드로이드 에뮬레이터는 반접힘(90°)에서 창이 먼저 커지는데 그때 판정은 아직
  /// "접힘"(끝점 유지)이라 정리가 건너뛰어지고, 완전히 펼쳐져(180°) 접힘이 풀릴 때는 폭이 이미 넓어서
  /// 다시 발동하지 않았다(접힌 채 연 Connections가 전체 화면으로 남음, 2026-10-26).
  bool? _wasCapable;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // 서비스가 없으면(테스트 등) Obx가 관찰할 Rx가 없어 예외를 던지므로 Obx를 쓰지 않는다.
    if (!Get.isRegistered<FoldStateService>()) return _track(size, false);
    final svc = Get.find<FoldStateService>();
    return Obx(() => _track(size, svc.posture.value == FoldPosture.folded));
  }

  Widget _track(Size size, bool folded) {
    final capable = size.shortestSide >= kLargeScreenBreakpoint && !folded;
    final becameCapable = _wasCapable == false && capable;
    _wasCapable = capable;
    if (becameCapable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _normalize());
    }
    return widget.child;
  }

  Future<void> _normalize() async {
    // 접힌 채 가로로 돌려 폭이 600dp를 넘은 경우는 분할이 되지 않는다(SplitShell은 접힘이면 전폭).
    // 이때 정리하면 대시보드가 잠깐 끼어들었다 같은 페이지로 돌아오는 깜빡임·교체 예외만 생긴다.
    if (Get.isRegistered<FoldStateService>() &&
        Get.find<FoldStateService>().posture.value == FoldPosture.folded) {
      return;
    }
    final route = Get.currentRoute;
    if (!_paneRoutes.contains(route)) return;
    final args = Get.arguments;
    Get.offAllNamed(AppRoutes.guardianDashboard);
    await AppNav.pushFromLaunch(route, arguments: args);
  }
}
