import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/fold_state_service.dart';

/// iPhone Duo 전용 — 본문 오른쪽 끝 버튼이 오른쪽 시스템 영역(시간·Wi‑Fi)에 가려지지 않게 더할 여백.
///
/// AppBar는 `primary`일 때 내부를 SafeArea로 감싸 헤더 아이콘이 안전 영역 안쪽에 놓이지만, 본문은
/// 안전 영역을 지키지 않아 본문 줄의 오른쪽 끝 버튼(알림 `?`, 연결관리 `+`)이 그 아래에 가려진다.
/// 폴더블 iPhone에서만 그 쪽 안전 영역 폭을 더하고, 그 외(일반 iPhone·안드로이드)는 0이라 동작이 같다.
///
/// 안전 영역 폭 그대로면 버튼이 헤더 아이콘보다 살짝 안쪽이라 6만 덜 민다(시뮬레이터 실측 보정).
/// ⚠️ `isFoldable`(Rx)을 읽으므로 Obx 안에서 호출한다.
double duoRightInset(BuildContext context) {
  if (!Platform.isIOS || !Get.isRegistered<FoldStateService>()) return 0.0;
  if (!Get.find<FoldStateService>().isFoldable.value) return 0.0;
  return (MediaQuery.paddingOf(context).right - 6).clamp(0.0, double.infinity);
}
