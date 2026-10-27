import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;

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

/// 살아 있는(pane Navigator를 가진) 대시보드 셸이 스택에 있는가.
bool get splitShellAlive => _SplitShellState._owner.value != null;

/// 지금 pane Navigator를 쥔 셸의 식별 토큰(없으면 null). 대시보드가 새로 만들어졌는지(소유자가 바뀌었는지)
/// 비교하는 데만 쓴다 — [WideRouteNormalizer]가 "옛 셸이 아니라 새 셸의 Navigator"를 기다릴 때.
Object? get splitShellOwner => _SplitShellState._owner.value;

class _SplitShellState extends State<SplitShell> {
  static const int _paneId = 1;

  /// pane Navigator의 GlobalKey(`Get.nestedKey`)는 앱 전체에서 하나뿐이라, 대시보드 셸이
  /// 스택에 둘 이상 살아 있으면(예: 대시보드 위에 push된 화면이 offNamed로 교체되며 새 대시보드가
  /// 생기는 경우) 중복 키 예외가 난다. 한 번에 하나의 셸만 Navigator를 가진다.
  static final Rxn<Object> _owner = Rxn<Object>();

  void _claimIfFree() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _owner.value == null) _owner.value = this;
    });
  }

  bool _wasSplit = false;

  Future<void> _openPaneAsFullPage() async {
    if (!mounted || Get.currentRoute != AppRoutes.guardianDashboard) return;
    Route<dynamic>? top;
    for (final r in SplitPaneState.stack.reversed) {
      if ((r.settings.name ?? '/') != '/') {
        top = r;
        break;
      }
    }
    final name = top?.settings.name;
    if (top == null || name == null) return;
    final args = top.settings.arguments;
    Get.nestedKey(_paneId)?.currentState?.popUntil((r) => r.isFirst);
    await Get.toNamed(name, arguments: args);
  }

  final _hasRight = false.obs;
  late final _PaneObserver _observer = _PaneObserver(_syncDepth);

  void _syncDepth() {
    final nav = Get.nestedKey(_paneId)?.currentState;
    final open = nav?.canPop() ?? false;
    if (_hasRight.value != open) _hasRight.value = open;
  }

  @override
  void initState() {
    super.initState();
    _claimIfFree();
  }

  @override
  void dispose() {
    if (_owner.value == this) {
      AppNav.paneId = null;
      // dispose는 트리가 잠긴(finalizeTree) 중에 불리는데, 여기서 Rx를 바꾸면 그것을 보는 Obx(다른
      // 셸의 build)가 markNeedsBuild를 불러 "widget tree was locked" 예외가 난다(Duo 접힘에서
      // 90도 회전 중 대시보드↔연결 화면이 교체될 때 발생). 프레임 뒤로 미룬다.
      final self = this;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_owner.value == self) _owner.value = null;
      });
    }
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
    // pane 안 페이지가 읽을 arguments(`Get.arguments`는 루트 라우트 값이라 여기선 안 맞는다).
    AppNav.paneArguments = s.arguments;
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
      final foldable = Get.isRegistered<FoldStateService>() &&
          Get.find<FoldStateService>().isFoldable.value;
      final isOwner = _owner.value == this;
      if (_owner.value == null) _claimIfFree();
      // 폰(폴더블도 아니고 폭 <600dp)은 분할이 불가능하므로 Navigator를 아예 두지 않는다.
      final needNavigator = isOwner && (foldable || size.width >= kLargeScreenBreakpoint);
      // 분할은 **짧은 변**이 600dp 이상일 때만(안드로이드 sw600 기준). 폭만 보면 접힌 화면을 가로로
      // 돌렸을 때(Fold8 접힘 789×499, Duo 접힘 678×466) 폭이 600을 넘어 분할이 켜진다. 접힘 자세 값은
      // 안드로이드에서 unknown/halfOpen으로 와 믿을 수 없다(2026-10-26 Fold8 에뮬레이터). 펼친 화면은
      // 짧은 변이 739(Fold8)·669(Duo)로 600을 넘는다.
      final capable =
          size.shortestSide >= kLargeScreenBreakpoint && !folded && isOwner;
      final split = capable && _hasRight.value;
      // 글래스는 안드로이드 가로 화면에서만 — 세로 화면은 제외한다. 각도 값이 아니라 참/거짓 하나만 관찰해
      // (180° 완전히 펼침이면 false) 각도가 바뀔 때마다 다시 빌드되지 않게 한다.
      final landscape = size.width > size.height;
      final halfOpen = Platform.isAndroid &&
          landscape &&
          Get.isRegistered<FoldStateService>() &&
          Get.find<FoldStateService>().splitGlass.value;      // 빌드 중 상태 변경을 피하려고 값만 대입(Rx 아님).
      if (isOwner) AppNav.paneId = capable ? _paneId : null;

      // 분할 중에 접으면 대시보드만 남지 않고, 오른쪽 pane에서 보던 화면을 전체 화면으로 연다
      // (접힌 화면은 하단 탭이 고른 화면 하나만 보여 준다). 다시 펼치면 WideRouteNormalizer가
      // 그 페이지를 오른쪽 pane으로 되돌린다. 접힘 시작·분할이 아니던 접힘은 건드리지 않는다.
      final foldedFromSplit = _wasSplit && !capable && isOwner;
      _wasSplit = split;
      if (foldedFromSplit) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _openPaneAsFullPage());
      }

      final leftW = split ? size.width / 2 : size.width;
      final rightW = split ? size.width / 2 : 0.0;

      MediaQueryData paneMq(double w) =>
          mq.copyWith(size: Size(w, size.height));

      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: leftW,
            child: SplitLeftScope(
              split: split,
              // 분할 중 왼쪽(대시보드)의 버튼이 아닌 곳을 탭하면 분할을 풀고 전폭 대시보드로 돌아간다
              // (홈 탭과 같은 동작 — pane 스택을 비우면 탭 강조도 홈으로 돌아온다).
              // 버튼·탭바·카드 슬라이드는 자기 제스처가 먼저 이겨 이 탭은 발생하지 않는다.
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: split
                    ? () => Get.nestedKey(_paneId)?.currentState
                        ?.popUntil((r) => r.isFirst)
                    : null,
                // 글래스가 덮인 동안은 왼쪽 대시보드의 애니메이션을 멈춘다 — 아래가 움직이면 블러를 매 프레임
                // 다시 계산해야 해서 접고 펴는 순간 부하가 커진다(데이터 갱신은 그대로, 애니메이션만 정지).
                child: TickerMode(
                  enabled: !halfOpen,
                  child: MediaQuery(data: paneMq(leftW), child: widget.child),
                ),
              ),
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
                      child: needNavigator
                          ? Navigator(
                              key: Get.nestedKey(_paneId),
                              initialRoute: '/',
                              observers: [_observer],
                              onGenerateRoute: _onGenerateRoute,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
      // 접힌 데서 펼치는 중(접힘 판정 + 힌지 90° 이상)의 덮개는 화면 종류와 무관하게 앱 전체에 깔아야 해서
      // [FoldUnfoldOverlay]가 맡는다(여기에는 분할 중 왼쪽 덮개만 남긴다).
      if (!split) return row;
      // 두 pane 사이 경계선 — 펼친 화면의 힌지(접힌 선) 위치. 에뮬레이터·일부 기기는 접힌 선을
      // 그리지 않아 분할이 어디서 나뉘는지 보이지 않는다. 폭을 차지하지 않도록 겹쳐 그린다.
      return Stack(
        children: [
          row,
          // 두 pane 톤 구분 — 배경이 같아 한 화면처럼 보이므로 **왼쪽(대시보드)만** 살짝 다르게
          // 덮는다(라이트: 어둡게, 다크: 밝게 → 상대적으로 오른쪽이 라이트에서 밝고 다크에서 어둡다). 페이지 Scaffold 배경이 명시돼 있어 뒤가 아니라 위에
          // 얹고, 터치는 막지 않는다. 분할일 때만 그려서 폰·전폭 화면에는 영향이 없다.
          Positioned(
            left: 0,
            width: leftW,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: halfOpen
                    // 덜 펼친(160° 미만) 상태 — 최대 세기 블러 덮개(_FoldBlur). 그 외에는 블러 없음(최소).
                    ? const _FoldBlur()
                    : ColoredBox(
                        color: AppColors.isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.09),
                      ),
              ),
            ),
          ),
          Positioned(
            left: leftW - 1.5,
            top: 0,
            bottom: 0,
            width: 3,
            child: IgnorePointer(
              child: ColoredBox(
                color: AppColors.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// 덜 펼친 폴더블 화면 위에 얹는 블러 덮개 — 어둡힘 없이 블러만.
///
/// 위치에 따라 부드럽게 커진다: 안쪽(힌지 쪽, 오른쪽)은 블러 0(최소), 바깥쪽(왼쪽 끝)은 [_maxSigma](최대).
/// 왼쪽부터 폭이 줄어드는 블러 층 [_layers]개를 겹쳐 쌓아, 바깥으로 갈수록 겹친 층이 많아 더 흐려진다
/// (겹친 블러는 제곱합의 제곱근으로 합쳐진다). 층 하나의 세기가 작아서 띠로 나눌 때 같은 큰 계단이 생기지
/// 않는다. 각도에 따라 세기가 변하지는 않고, 이 위젯이 그려지는 구간(덜 펼친 각도)에서만 켜진다.
class _FoldBlur extends StatelessWidget {
  const _FoldBlur();

  /// 블러 세기(전체에 같은 값, 다이얼로그는 14).
  static const double _sigma = 8;

  /// 맨 바깥의 반투명 면 불투명도(0~1). 클수록 뒤가 덜 비친다.
  static const double _maxOpacity = 0.60;

  @override
  Widget build(BuildContext context) {
    final veil = AppColors.isDark ? const Color(0xFF24262B) : Colors.white;
    // 렌더링을 줄이려고 **블러는 한 번만** 건다(블러 층을 쌓으면 층 수만큼 매 프레임 블러를 다시 계산한다).
    // 바깥은 거칠고 안쪽은 맑은 느낌은 위의 반투명 면 그라데이션이 맡는다 — 바깥으로 갈수록 불투명해져
    // 같은 블러도 더 뿌옇게 보인다. 불투명도(= 투명도를 낮추는 면)는 안쪽 0(완전히 비침) → 바깥 최대.
    // 어둡게가 아니라 다이얼로그 글래스와 같은 흰(다크는 짙은 회색) 반투명 면이다.
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma, tileMode: TileMode.mirror),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              veil.withValues(alpha: _maxOpacity),
              veil.withValues(alpha: 0),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
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
