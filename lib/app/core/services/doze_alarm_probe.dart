import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Doze 관통 알람 **실측 프로브** (Phase 1 — 실험 전용, 프로덕션 동작 아님).
///
/// `AlarmManager.setAndAllowWhileIdle`은 Doze 유지보수 창을 기다리지 않고 발화한다.
/// 우리 heartbeat 지연(예약시각 +2.5~3시간)의 원인이 통째로 창 대기이므로, 이게 되면
/// 편차가 10~60배 줄어든다. 다만 **알람이 뜨는 것과 전송이 되는 것은 별개**다 —
/// 상세한 측정 의도는 `DozeAlarmProbeReceiver`(Kotlin) 주석에 있다.
///
/// ⚠️ 이 프로브는 **기존 3계층을 대체하지 않는다.** 결과가 좋아도 4번째 계층으로
/// 병렬 추가할 뿐이며, 특히 periodic 15분 폴링을 약화시키는 근거로 쓰면 안 된다
/// (PRD-FrontEnd §2.2 폴링 불변 규칙).
///
/// 채널은 `MainActivity`에 있어 **포그라운드에서만** 동작한다. 그것으로 충분하다 —
/// 네이티브 리시버가 발화할 때마다 스스로 다음 날로 재무장하므로 1회 무장이면 된다.
/// 백그라운드 isolate(WorkManager worker)에서 호출되면 조용히 무시된다.
class DozeAlarmProbe {
  static const _channel = MethodChannel('anbucheck/doze_alarm_probe');

  /// 매일 [hour]:[minute]에 발화하도록 무장. 실패해도 절대 throw하지 않는다 —
  /// 실험용 부가 기능이 heartbeat 예약 경로를 막아서는 안 된다.
  static Future<void> arm(int hour, int minute) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('arm', {'hour': hour, 'minute': minute});
      debugPrint('[DozeAlarmProbe] armed $hour:$minute');
    } catch (e) {
      // 백그라운드 isolate에는 MainActivity가 없어 MissingPluginException이 정상이다.
      debugPrint('[DozeAlarmProbe] arm 스킵: $e');
    }
  }

  /// 테스트용 단발 — [minutes]분 뒤 1회.
  static Future<void> armInMinutes(int minutes) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('armInMinutes', {'minutes': minutes});
    } catch (_) {}
  }

  static Future<void> cancel() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('cancel');
    } catch (_) {}
  }
}
