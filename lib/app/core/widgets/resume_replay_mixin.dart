import 'package:flutter/widgets.dart';

/// 앱이 백그라운드(paused)에 있다가 포그라운드로 돌아왔을 때 [replayOnResume]을 호출한다.
///
/// 진입 연출(막대 차트·카드 슬라이드 등)을 복귀 때도 다시 보여주기 위한 공용 훅이다.
/// 알림 센터를 내리거나 권한 팝업이 뜨는 정도의 inactive→resumed 전환에서는
/// 호출하지 않는다 — 실제로 paused를 거친 복귀만 대상이다.
///
/// 사용: `with WidgetsBindingObserver, ResumeReplayMixin` (이 순서) 후 [replayOnResume] 구현.
mixin ResumeReplayMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool _wasPaused = false;

  /// 복귀 시 연출을 처음부터 다시 재생한다.
  void replayOnResume();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      if (mounted) replayOnResume();
    }
  }
}
