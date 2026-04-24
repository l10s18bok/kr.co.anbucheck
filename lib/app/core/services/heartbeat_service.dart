import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pedometer_2/pedometer_2.dart' as p2;
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/heartbeat_remote_datasource.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';

/// Heartbeat 수집 → suspicious 판정 → 서버 전송 (오프라인 시 큐 저장)
///
/// suspicious 판정 우선순위 (manual 제외 자동 경로):
///   1) steps_delta > 0             → false (걸음 = 활동 증거)
///   2) isInteractiveAtTrigger=true → false (worker fire 시점 화면 깨어있음 =
///                                    사용자가 폰을 깨워 Doze 해제 → 사용 흔적)
///   3) 그 외                       → true  (걸음 없음 + Doze maintenance/
///                                    상태 미상 → 활동 증거 없음)
///   - manual=true → 무조건 false (버튼 탭 자체가 활동 증거)
///
/// [isInteractiveAtTrigger]는 worker 콜백에서 ScreenState.isInteractive()로
/// 조회한 값을 전달한다. 포그라운드 경로(앱 열기 자동 전송·수동 보고)에서는
/// 앱이 포그라운드에 있다는 것 자체가 interactive 상태의 증거이므로 true를
/// 명시 전달한다. null이 들어오는 경로는 기본적으로 존재하지 않아야 하며,
/// 만약 null이 전달되면 걸음수 단독 판정으로 fallback된다.
class HeartbeatService {
  /// 동일 isolate 내 중복 실행 방지 (execute + sendPending 공유)
  static bool _busy = false;

  final _heartbeatDs  = HeartbeatLocalDatasource();
  final _lockDs       = HeartbeatLockDatasource();
  final _tokenDs      = TokenLocalDatasource();
  final _battery      = Battery();

  /// heartbeat 1회 실행
  /// [manual] 대상자가 직접 버튼을 눌러 전송한 경우 true
  /// [isInteractiveAtTrigger] worker fire 시점의 PowerManager.isInteractive() 값.
  ///   Android worker 콜백에서만 실제 값을 전달하며, 포그라운드 호출부는 true를 명시 전달.
  Future<void> execute({bool manual = false, bool? isInteractiveAtTrigger}) async {
    if (_busy) return;
    _busy = true;
    try {
      final deviceId    = await _tokenDs.getDeviceId();
      final deviceToken = await _tokenDs.getDeviceToken();
      if (deviceId == null || deviceToken == null) return;

      // 보류 큐가 있으면 먼저 전송
      final pending = await _heartbeatDs.getPending();
      if (pending != null) {
        await _sendPendingInternal(deviceToken);
      }

      await _executeInternal(
        deviceId: deviceId,
        deviceToken: deviceToken,
        manual: manual,
        isInteractiveAtTrigger: isInteractiveAtTrigger,
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _executeInternal({
    required String deviceId,
    required String deviceToken,
    bool manual = false,
    bool? isInteractiveAtTrigger,
  }) async {
    // 동일 예약시각에 대한 중복 전송 방어 (날짜+예약시각 조합)
    // manual=true는 무조건 전송 (suspicious 알림 응답, 수동 보고)
    //
    // 책임 분리 구조:
    //   - lastScheduledKey: 성공 마커. API 전송 성공 + lastHeartbeatDate 저장 후에만 save.
    //     당일 재전송 차단 전용 (SharedPreferences).
    //   - HeartbeatLockDatasource: cross-isolate mutual exclusion 락 (SQLite UNIQUE).
    //     WorkManager는 워커마다 새 isolate를 생성하므로 SharedPreferences 기반
    //     reload→check→save 패턴은 CAS가 아니어서 두 isolate가 같은 ms에 진입하면
    //     둘 다 통과하는 race window가 존재했다. SQLite UNIQUE INSERT는 cross-isolate
    //     원자 연산이라 하나만 성공하고 나머지는 UniqueConstraintError로 즉시 실패한다.
    await getReloadedPrefs();
    final now = DateTime.now();
    final (schedHour, schedMinute) = await _tokenDs.getHeartbeatSchedule();
    final scheduledKey = '${formatYmd(now)}_${formatHm(schedHour, schedMinute)}';

    bool lockAcquired = false;
    if (!manual) {
      final lastKey = await _tokenDs.getLastScheduledKey();
      if (lastKey == scheduledKey) {
        debugPrint('[HeartbeatService] 이미 전송 완료 — 스킵 ($scheduledKey)');
        return;
      }

      // SQLite UNIQUE INSERT로 락 획득. 다른 isolate가 이미 잡고 있으면 false 반환.
      // TTL 30초 초과한 stale 락은 tryAcquire 내부에서 일괄 삭제되므로 crashed
      // isolate가 남긴 락도 새 진입자가 이어받을 수 있다.
      lockAcquired = await _lockDs.tryAcquire(scheduledKey);
      if (!lockAcquired) return;
    }

    try {
      final timestamp    = now.toUtc().toIso8601String();
      final batteryLevel = await _getBatteryLevel();
      final stepsDelta   = await _getStepsDelta();

      // suspicious 판정 (manual 제외 자동 경로):
      //   1) steps > 0                     → false (걸음 = 활동 증거)
      //   2) isInteractiveAtTrigger=true   → false (화면 깨어있는 상태에서 fire
      //                                      = 사용자가 폰을 깨워 Doze 해제)
      //   3) 그 외                         → true  (걸음 없음 + Doze maintenance/
      //                                      미상)
      bool suspicious;
      if (manual) {
        suspicious = false;
      } else if (stepsDelta != null && stepsDelta > 0) {
        suspicious = false;
      } else if (isInteractiveAtTrigger == true) {
        suspicious = false;
      } else {
        suspicious = true;
      }

      debugPrint(
        '[HeartbeatService] suspicious 판정: steps=$stepsDelta '
        'isInteractive=${isInteractiveAtTrigger ?? 'null'} manual=$manual → suspicious=$suspicious',
      );

      final request = HeartbeatRequest(
        deviceId:     deviceId,
        timestamp:    timestamp,
        manual:       manual,
        stepsDelta:   stepsDelta,
        suspicious:   suspicious,
        batteryLevel: batteryLevel,
        // 자동 heartbeat만 key 전송 — 수동 보고는 서버 dedup 우회.
        scheduledKey: manual ? null : scheduledKey,
      );

      await _sendOrSavePending(request, deviceToken, schedHour, schedMinute);
    } finally {
      if (lockAcquired) {
        await _lockDs.release(scheduledKey);
      }
    }
  }

  /// 보류 중인 heartbeat 재전송 (네트워크 복구 시 호출)
  Future<void> sendPending(String deviceToken) async {
    if (_busy) return;
    _busy = true;
    try {
      await _sendPendingInternal(deviceToken);
    } finally {
      _busy = false;
    }
  }

  Future<void> _sendPendingInternal(String deviceToken) async {
    final payload = await _heartbeatDs.getPending();
    if (payload == null) return;
    try {
      await HeartbeatRemoteDatasource(deviceToken).send(_fromJson(payload));
      await _heartbeatDs.clearPending();

      final now = DateTime.now();
      await _tokenDs.saveLastHeartbeatDate(formatYmd(now));
      await _tokenDs.saveLastHeartbeatTime(formatHm(now.hour, now.minute));

      // 오늘의 scheduledKey도 갱신해 _executeInternal 중복 전송 가드가 작동하도록 함
      final (schedHour, schedMinute) = await _tokenDs.getHeartbeatSchedule();
      final scheduledKey = '${formatYmd(now)}_${formatHm(schedHour, schedMinute)}';
      await _tokenDs.saveLastScheduledKey(scheduledKey);
    } catch (_) {}
  }

  // ── private ──────────────────────────────────────────────

  Future<void> _sendOrSavePending(
    HeartbeatRequest request,
    String deviceToken,
    int schedHour,
    int schedMinute,
  ) async {
    // WorkManager가 NetworkType.connected constraint를 만족시킨 상태에서 호출되므로
    // connectivity_plus 사전 체크 없이 Dio 3회 retry로 바로 전송 시도한다.
    // Doze 상태에서 connectivity_plus가 "오프라인"으로 오판하는 케이스가 확인되어
    // 사전 체크를 제거했다 — 실제 전송은 WorkManager가 보장한 네트워크 위에서 수행.
    final remote = HeartbeatRemoteDatasource(deviceToken);
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await remote.send(request);
        debugPrint('[HeartbeatService] API 전송 성공 (시도 $attempt)');
        break;
      } catch (e) {
        debugPrint('[HeartbeatService] API 전송 실패 (시도 $attempt): $e');
        if (attempt == 3) {
          await _heartbeatDs.savePending(request.toJson());
          if (!request.manual) await LocalAlarmService.notifySendFailed();
          return;
        }
        await Future.delayed(Duration(seconds: attempt * 5));
      }
    }

    // 전송 성공 — 이후 작업 실패가 pending 큐를 오염시키지 않도록 분리
    await _heartbeatDs.clearPending();

    final now = DateTime.now();
    final today = formatYmd(now);
    await _tokenDs.saveLastHeartbeatDate(today);
    await _tokenDs.saveLastHeartbeatTime(formatHm(now.hour, now.minute));

    // 날짜+예약시각 키 저장 (중복 전송 방지)
    final scheduledKey = '${today}_${formatHm(schedHour, schedMinute)}';
    await _tokenDs.saveLastScheduledKey(scheduledKey);

    // iOS 로컬 안전망 알림: 오늘 전송 성공 → 내일로 재예약
    await LocalAlarmService.schedule(schedHour, schedMinute, forceNextDay: true);
  }

  Future<int?> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return null;
    }
  }

  /// 오늘 자정 ~ 현재 시각의 걸음수 조회 (iOS/Android 공통).
  ///
  /// pedometer_2의 getStepCount(from, to):
  ///   - iOS: CMPedometer.queryPedometerData (M-coprocessor 누적, 7일 보관)
  ///   - Android: Google Fit Local Recording API
  ///
  /// 자동/수동 모두 실제 걸음수를 전송한다. 서버는 `manual=true`일 때
  /// 활동 정보 알림(`message_key=steps`) 생성을 건너뛰므로, 수동 보고 시에도
  /// 이중 알림이 발생하지 않고 일별 걸음수 이력은 정확히 반영된다.
  Future<int?> _getStepsDelta() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      if (!now.isAfter(midnight)) return 0;

      final steps = await p2.Pedometer().getStepCount(from: midnight, to: now)
          .timeout(const Duration(seconds: 3));
      debugPrint('[HeartbeatService] getStepCount $midnight~$now steps=$steps');
      return steps;
    } catch (e) {
      debugPrint('[HeartbeatService] getStepCount 실패: $e');
      return null;
    }
  }

  HeartbeatRequest _fromJson(Map<String, dynamic> json) =>
      HeartbeatRequest(
        deviceId:     json['device_id'] as String,
        timestamp:    json['timestamp'] as String,
        manual:       (json['manual'] as bool?) ?? false,
        stepsDelta:   json['steps_delta'] as int?,
        suspicious:   json['suspicious'] as bool,
        batteryLevel: json['battery_level'] as int?,
        scheduledKey: json['scheduled_key'] as String?,
      );
}
