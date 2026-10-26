import 'dart:async';

import 'package:bifold/bifold.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 폴더블(iPhone Duo·Android 폴더블) 접힘 상태 — 앱 전체가 보는 **단일 래퍼**.
///
/// `bifold` 패키지(게시된 지 한 달 안팎의 신생 패키지, 실기기 미검증)를 이 파일 안에만
/// 가두어 둔다. 앱의 다른 코드는 [FoldStateService.posture]만 보게 해서, 패키지가 바뀌거나
/// 교체(예: `foldable`)돼도 이 파일만 고치면 된다.
///
/// ⚠️ **폰·비폴더블에서는 항상 [FoldPosture.unknown]이다** — 이 값으로 동작이 바뀌는 코드는
/// `unknown`일 때 지금과 같은 동작을 해야 한다. 어떤 예외도 앱 시작을 막으면 안 되므로
/// 구독·변환 전부 try/catch로 감싸고 실패하면 unknown으로 둔다.
///
/// 레이아웃(분할 여부)은 이 값이 아니라 **창 폭(≥600dp)** 으로 정한다(Apple 지침: 레이아웃
/// 판단은 size class, 힌지 상태는 효과·보조 판단용). 이 값은 "접혀 있으면 요약 숨김" 같은
/// 제품 판단과 접기/펴기 복원 용도다.
enum FoldPosture {
  /// 폴더블이 아니거나 아직 모름.
  unknown,

  /// 접힘(외부 화면).
  folded,

  /// 중간(반쯤 열림 — 안쪽 화면에 접힌 선이 있음).
  halfOpen,

  /// 완전히 펼침.
  open,
}

class FoldStateService extends GetxService {
  /// 현재 접힘 상태.
  final posture = FoldPosture.unknown.obs;

  /// 폴더블 기기인가(폰이면 false).
  final isFoldable = false.obs;

  StreamSubscription<FoldInfo>? _sub;

  /// 구독을 시작한다. 실패해도 예외를 던지지 않는다.
  FoldStateService start() {
    try {
      _sub = Bifold.stream.listen(
        _onInfo,
        onError: (Object e) => debugPrint('[FoldState] stream error: $e'),
      );
    } catch (e) {
      debugPrint('[FoldState] start failed: $e');
    }
    return this;
  }

  void _onInfo(FoldInfo info) {
    try {
      // 자세 값이 오면 그대로, `unknown`이면 힌지 각도로 판정한다(안드로이드 에뮬레이터는 각도 0/90/180이
      // 오는데 pose는 항상 unknown이다 — 2026-10-26 Fold8Foldable 로그). 각도는 가끔 null로 끼어
      // 들어오므로 null은 무시하고 마지막 유효 각도를 유지한다.
      final angle = info.hingeAngleDegrees;
      if (angle != null) _lastAngle = angle;
      posture.value = switch (info.pose) {
        FoldPose.closed => FoldPosture.folded,
        FoldPose.partiallyOpen => FoldPosture.halfOpen,
        FoldPose.fullyOpen => FoldPosture.open,
        FoldPose.unknown => _postureFromAngle(_lastAngle),
      };
      final wasFoldable = isFoldable.value;
      isFoldable.value = info.isFoldable;
      if (info.isFoldable != wasFoldable) _applyOrientationPolicy(info.isFoldable);
      // 시뮬레이터에서 실제로 어떤 값이 오는지 확인하기 위한 로그(릴리스에서는 debugPrint가 꺼짐).
      debugPrint(
        '[FoldState] pose=${info.pose.name} → ${posture.value.name} '
        'foldable=${info.isFoldable} display=${info.display.name} '
        'angle=${info.hingeAngleDegrees} regions=${info.regions.length}',
      );
    } catch (e) {
      posture.value = FoldPosture.unknown;
      debugPrint('[FoldState] map failed: $e');
    }
  }

  /// 마지막으로 받은 유효 힌지 각도(null은 덮어쓰지 않는다).
  double? _lastAngle;

  /// 힌지 각도 → 접힘 상태. 구간은 AVD의 posture 정의(0-30 접힘 / 30-150 반접힘 / 150-180 펼침)와 같다.
  /// 각도가 아직 없으면 unknown(폰·비폴더블과 같은 동작).
  ///
  /// **반접힘(30~150°)에서는 직전 끝점(접힘/펼침)을 그대로 유지한다.** 접힘→펼치는 중에는 150°를 넘을 때까지
  /// 접힘 판정, 펼침→접는 중에는 30° 이하가 될 때까지 펼침 판정이라 중간에 분할 화면이 깜빡이지 않는다
  /// (창 크기는 OS가 정하고 앱은 따라 그릴 뿐 — 앱이 정하는 건 이 판정으로 켜지는 분할·요약 숨김뿐).
  /// 끝점을 한 번도 못 본 채 반접힘이면 halfOpen 그대로.
  FoldPosture _postureFromAngle(double? angle) {
    if (angle == null) return FoldPosture.unknown;
    if (angle <= 30) return _lastEndpoint = FoldPosture.folded;
    if (angle >= 150) return _lastEndpoint = FoldPosture.open;
    return _lastEndpoint ?? FoldPosture.halfOpen;
  }

  /// 각도 경로에서 마지막으로 확정된 끝점(folded 또는 open).
  FoldPosture? _lastEndpoint;

  /// iOS 방향 정책 — 폰은 세로 고정 그대로, 폴더블은 모든 방향 허용.
  /// 접힌(세로 외부 화면) 채로 시작한 뒤 펼치면 안쪽 화면이 가로라, 세로 전용이면 앱이
  /// 90도 눕혀 그려진다(2026-10-19 Duo 시뮬레이터 실측). 펼친 채 시작하면 발생하지 않는다.
  /// Android도 폴더블이면 접힌 좁은 화면에서도 모든 방향 허용(2026-10-26). 비폴더블 Android는
  /// 창 폭 기준(app.dart `_syncAndroidOrientation`)이 그대로 맡으므로 여기서 건드리지 않는다.
  void _applyOrientationPolicy(bool foldable) {
    if (Platform.isAndroid && !foldable) return;
    SystemChrome.setPreferredOrientations(
      foldable ? DeviceOrientation.values : const [DeviceOrientation.portraitUp],
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
