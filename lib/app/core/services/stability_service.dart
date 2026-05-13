import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 안부 확인 안정성 관련 OS 설정(배터리 사용 제한, 자동 권한 회수) 상태 추적.
/// Android 전용 — iOS는 항상 true(설정 불필요)로 보고하여 위젯이 자동 숨김.
class StabilityService extends GetxService {
  static const _channel = MethodChannel('anbucheck/hibernation');

  /// 배터리 최적화 제외(=사용 제한 해제) 여부.
  /// true → 제한 없음 상태(OK), false → 사용자 조치 필요.
  final batteryUnrestricted = true.obs;

  Future<void> refresh() async {
    if (!Platform.isAndroid) {
      batteryUnrestricted.value = true;
      return;
    }
    try {
      final result = await _channel.invokeMethod<bool>('isBatteryUnrestricted');
      batteryUnrestricted.value = result ?? true;
    } catch (_) {
      batteryUnrestricted.value = true;
    }
  }

  Future<void> openBatterySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('openBatterySettings');
    } catch (_) {}
  }

  Future<void> openAutoRevokeSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('openAutoRevokeSettings');
    } catch (_) {}
  }
}
