import 'dart:async';

import 'package:bifold/bifold.dart';
import 'package:flutter/foundation.dart';
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
      posture.value = switch (info.pose) {
        FoldPose.closed => FoldPosture.folded,
        FoldPose.partiallyOpen => FoldPosture.halfOpen,
        FoldPose.fullyOpen => FoldPosture.open,
        FoldPose.unknown => FoldPosture.unknown,
      };
      isFoldable.value = info.isFoldable;
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

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
