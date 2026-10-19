import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/fold_state_service.dart';
import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'package:anbucheck/app/core/utils/layout_breakpoints.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 오른쪽 pane 안의 위젯인지 알려 주는 표식 — pane 안 페이지는 하단 탭바를 그리지 않는다.
class PaneScope extends InheritedWidget {
  const PaneScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaneScope>() != null;

  @override
  bool updateShouldNotify(PaneScope oldWidget) => false;
}

/// 분할 중 왼쪽(대시보드) pane임을 알려 주는 표식 — 폭이 절반으로 줄고 높이는 그대로라
/// 폴더블 접힘과 같은 컴팩트 배치가 필요하다. [split]이 true일 때만 의미가 있다.
class SplitLeftScope extends InheritedWidget {
  const SplitLeftScope({super.key, required this.split, required super.child});

  final bool split;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SplitLeftScope>()?.split ?? false;

  @override
  bool updateShouldNotify(SplitLeftScope old) => old.split != split;
}

/// 분할 화면 셸 — 폭 ≥600dp이고 접힘이 아닐 때, 왼쪽에 [child](대시보드)를 두고
/// 오른쪽에 전용 Navigator를 둔다. 기기 판별이 아니라 폭 + 접힘 상태로만 결정한다.
///
/// - 처음엔 [child]가 전폭. 오른쪽에 페이지가 열리면(스택 2개 이상) 1:1로 나뉜다.
/// - 접히거나 폭이 줄면 [child] 단독으로 돌아가고, 오른쪽 Navigator는 화면 밖(Offstage)에
///   **보관**되어 다시 펼 때 스택이 그대로 복원된다.
/// - 분할 가능 상태에서는 [AppNav.paneId]가 켜져 화면 이동이 오른쪽 pane으로 향한다.
class SplitShell extends StatefulWidget {
  const SplitShell({super.key, required this.child});

  final Widget child;

  @override
  State<SplitShell> createState() => _SplitShellState();
}

class _SplitShellState extends State<SplitShell> {
  static const int _paneId = 1;

  final _hasRight = false.obs;
  late final _PaneObserver _observer = _PaneObserver(_syncDepth);

  void _syncDepth() {
    final nav = Get.nestedKey(_paneId)?.currentState;
    final open = nav?.canPop() ?? false;
    if (_hasRight.value != open) _hasRight.value = open;
  }

  @override
  void dispose() {
    AppNav.paneId = null;
    super.dispose();
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings s) {
    if (s.name == '/') {
      return PageRouteBuilder<void>(
        settings: s,
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    final page = AppPages.pages.firstWhereOrNull((p) => p.name == s.name);
    if (page == null) return null;
    return GetPageRoute<dynamic>(
      settings: s,
      page: page.page,
      binding: page.binding,
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    return Obx(() {
      final folded =
          Get.isRegistered<FoldStateService>() &&
          Get.find<FoldStateService>().posture.value == FoldPosture.folded;
      final capable = size.width >= kLargeScreenBreakpoint && !folded;
      final split = capable && _hasRight.value;
      // 빌드 중 상태 변경을 피하려고 값만 대입(Rx 아님).
      AppNav.paneId = capable ? _paneId : null;

      final leftW = split ? size.width / 2 : size.width;
      final rightW = split ? size.width / 2 : 0.0;

      MediaQueryData paneMq(double w) =>
          mq.copyWith(size: Size(w, size.height));

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftW,
            child: SplitLeftScope(
              split: split,
              child: MediaQuery(data: paneMq(leftW), child: widget.child),
            ),
          ),
          // 접혀 있어도 Navigator는 트리에 유지(Offstage) — 스택 보관.
          SizedBox(
            width: rightW,
            child: ClipRect(
              child: Offstage(
                offstage: !split,
                child: TickerMode(
                  enabled: split,
                  child: PaneScope(
                    child: MediaQuery(
                      data: paneMq(rightW == 0 ? size.width / 2 : rightW),
                      child: Navigator(
                        key: Get.nestedKey(_paneId),
                        initialRoute: '/',
                        observers: [_observer],
                        onGenerateRoute: _onGenerateRoute,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// 오른쪽 pane의 현재 화면 → 하단 탭 인덱스. 왼쪽 탭바가 pane 쪽 탭을 강조하는 데 쓴다.
class SplitPaneState {
  SplitPaneState._();

  /// pane 스택(맨 아래는 빈 시작 화면).
  static final stack = <Route<dynamic>>[].obs;

  /// 오른쪽 pane의 탭 인덱스(1 연결 · 2 알림 · 3 설정). pane이 비어 있으면 null.
  static int? get tab {
    if (stack.isEmpty) return null;
    final s = stack.last.settings;
    switch (s.name) {
      case AppRoutes.guardianConnectionManagement:
      case AppRoutes.guardianAddSubject:
        return 1;
      case AppRoutes.guardianNotifications:
      case AppRoutes.guardianEmergencyMap:
        return 2;
      case AppRoutes.guardianSettings:
        return 3;
      case AppRoutes.guardianNotificationSettings:
        // 설정 탭에서 열면 arguments=3(설정 탭 유지), 알림 탭에서 열면 기본 2.
        return (s.arguments as int?) ?? 2;
    }
    return null;
  }
}

class _PaneObserver extends NavigatorObserver {
  _PaneObserver(this.onChange);
  final VoidCallback onChange;

  // 빌드 중 Rx를 바꾸지 않도록 다음 프레임에 반영.
  void _later(void Function() f) => WidgetsBinding.instance.addPostFrameCallback((_) {
        f();
        onChange();
      });

  @override
  void didPush(Route route, Route? previousRoute) =>
      _later(() => SplitPaneState.stack.add(route));
  @override
  void didPop(Route route, Route? previousRoute) =>
      _later(() => SplitPaneState.stack.remove(route));
  @override
  void didRemove(Route route, Route? previousRoute) =>
      _later(() => SplitPaneState.stack.remove(route));
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _later(() {
        final i = oldRoute == null ? -1 : SplitPaneState.stack.indexOf(oldRoute);
        if (i >= 0 && newRoute != null) {
          SplitPaneState.stack[i] = newRoute;
        } else if (newRoute != null) {
          SplitPaneState.stack.add(newRoute);
        }
      });
}
