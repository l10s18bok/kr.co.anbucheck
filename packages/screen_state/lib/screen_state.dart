import 'dart:io';
import 'package:flutter/services.dart';

/// Android `PowerManager.isInteractive()` 조회 전용 경량 플러그인.
///
/// WorkManager 콜백(백그라운드 isolate)에서도 호출 가능하도록 `FlutterPlugin`
/// 인터페이스로 구현되어 `GeneratedPluginRegistrant`가 자동 등록한다.
class ScreenState {
  static const _channel = MethodChannel('kr.co.anbucheck/screen_state');

  /// 기기가 interactive 상태인지 반환.
  ///
  /// interactive = true: 깨어있고 사용자 상호작용 가능 (일반 화면 켜짐 + 잠금화면 포함).
  /// interactive = false: Doze/Sleep, AOD(Ambient Display) 상태.
  ///
  /// Android 외 플랫폼은 `true` 반환 (이 프로젝트에선 iOS가 heartbeat 전송을
  /// 하지 않으므로 호출되지 않지만 안전한 기본값).
  ///
  /// 호출 실패 시 `true` 반환 — 판정 실패로 인한 false positive(정상인데 의심)보다
  /// 기존 걸음수 단독 판정에 결과를 맡기는 쪽이 보호자 부담이 적다.
  static Future<bool> isInteractive() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _channel.invokeMethod<bool>('isInteractive');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }
}
