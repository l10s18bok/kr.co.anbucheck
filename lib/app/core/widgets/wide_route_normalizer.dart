import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/fold_state_service.dart';
import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'package:anbucheck/app/core/utils/layout_breakpoints.dart';
import 'package:anbucheck/app/core/widgets/split_shell.dart';
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
    final oldOwner = splitShellOwner;
    Get.offAllNamed(AppRoutes.guardianDashboard);
    // 새 대시보드 셸의 오른쪽 Navigator가 준비될 때까지 기다린다. `AppNav.paneId`는 **옛 셸**이 이미
    // 1로 켜 둔 값이라 pushFromLaunch의 "paneId가 null이면 기다림"이 작동하지 않고, 새 셸이 Navigator를
    // 만들기 전에 pane으로 열려다 조용히 무시돼 대시보드만 남았다(접힌 가로 설정 → 펼침, 2026-10-26).
    // 옛 셸이 사라지는 전환(약 300ms)이 끝난 뒤의 Navigator만 새 셸 것이라 최소 대기를 둔다.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // 400ms로도 느린 기기·에뮬레이터는 옛 셸이 아직 남아 있어 그 Navigator를 새 것으로 착각하고 열었다가
    // 사라져 대시보드만 남는다. 그래서 pane Navigator를 쥔 **셸이 바뀐 것**(새 셸이 소유자가 됨)까지 확인한다.
    for (var i = 0; i < 100; i++) {
      final id = AppNav.paneId;
      final owner = splitShellOwner;
      if (id != null &&
          Get.currentRoute == AppRoutes.guardianDashboard &&
          owner != null &&
          owner != oldOwner &&
          Get.nestedKey(id)?.currentState != null) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await AppNav.pushFromLaunch(route, arguments: args);
  }
}
