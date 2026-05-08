import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pedometer_2/pedometer_2.dart' as p2;
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
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

  /// Google Fit Local Recording API 구독 선점 (Android 전용).
  ///
  /// Android 재설치 후 getStepCount가 최초 호출되는 시점에 구독이 생성된다.
  /// heartbeat 전송 조건(isScheduleInFuture)에 막혀 당일 heartbeat가 나가지
  /// 않으면 구독이 생성되지 않아 다음날 steps_delta = 0이 전송된다.
  /// onInit에서 이 메서드를 호출해 구독을 미리 확보한다.
  ///
  /// getStepCount는 로컬 쿼리라 오버헤드가 거의 없으며 매 onInit 호출이 허용된다.
  static Future<void> warmUpStepSubscription() async {
    if (!Platform.isAndroid) return;
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      await p2.Pedometer()
          .getStepCount(from: midnight, to: now)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

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
    final (schedHour, schedMinute) = await _tokenDs.getHeartbeatSchedule();
    try {
      await HeartbeatRemoteDatasource(deviceToken).send(_fromJson(payload));
      await _heartbeatDs.clearPending();

      final now = DateTime.now();
      await _tokenDs.saveLastHeartbeatDate(formatYmd(now));
      await _tokenDs.saveLastHeartbeatTime(formatHm(now.hour, now.minute));

      // 오늘의 scheduledKey도 갱신해 _executeInternal 중복 전송 가드가 작동하도록 함
      final scheduledKey = '${formatYmd(now)}_${formatHm(schedHour, schedMinute)}';
      await _tokenDs.saveLastScheduledKey(scheduledKey);

      await _onHeartbeatSent(schedHour, schedMinute);
    } catch (_) {
      // pending 전송 자체는 실패 — 큐는 그대로 남겨 다음 fire에서 재시도.
      // 단 schedule은 반드시 재등록 — oneOff fire-and-not-rescheduled 차단.
      try {
        await _rescheduleNextDay(schedHour, schedMinute);
      } catch (_) {}
    }
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
    // manual=true 요청은 reqKey가 null이라 race 재검사를 건너뛴다 (수동 보고는 무조건 전송).
    final reqKey = request.scheduledKey;
    for (var attempt = 1; attempt <= 3; attempt++) {
      // retry 진행 중 다른 isolate가 같은 scheduledKey로 성공했으면 즉시 중단.
      // 락 TTL(30초) < retry 최대 시간(75~105초, attempt 3 timeout 30초 포함)이라
      // retry 도중 락이 자연 만료되어 다른 진입자(다른 worker / 포그라운드 진입)가
      // 새 락으로 성공할 수 있다. 본 worker가 retry를 끝까지 진행해 attempt 3 실패
      // 분기에서 misleading "전송 실패" 알림을 띄우는 race를 차단한다.
      if (reqKey != null) {
        await getReloadedPrefs();
        if (await _tokenDs.getLastScheduledKey() == reqKey) {
          return;
        }
      }
      try {
        await remote.send(request);
        debugPrint('[HeartbeatService] API 전송 성공 (시도 $attempt)');
        break;
      } catch (e) {
        debugPrint('[HeartbeatService] API 전송 실패 (시도 $attempt): $e');
        if (attempt == 3) {
          // 실패 분기 진입 직전 마지막 재검사 — attempt 3 자체가 30초 timeout일 수
          // 있어 그 사이에도 다른 isolate가 성공했을 수 있다. 이미 성공이면
          // savePending과 알림 모두 스킵해 misleading 안내를 막는다.
          if (reqKey != null) {
            await getReloadedPrefs();
            if (await _tokenDs.getLastScheduledKey() == reqKey) {
              return;
            }
          }
          await _heartbeatDs.savePending(request.toJson());
          if (!request.manual) await LocalAlarmService.notifySendFailed();
          // oneOff fire-and-not-rescheduled 차단 — pending 큐가 다음 fire에서 회복할 수
          // 있도록 schedule을 반드시 재등록한다. notifySendFailed 알림은 유지(다음 성공
          // 시 _onHeartbeatSent의 cancelSendFailed가 정리).
          await _rescheduleNextDay(schedHour, schedMinute);
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

    await _onHeartbeatSent(schedHour, schedMinute);
  }

  /// 다음 정시 재예약 — **모든 종료 경로 공통** (전송 성공 / retry 3회 실패 / pending 실패).
  ///
  /// oneOff은 fire-and-forget이라 매 fire마다 schedule 재등록이 없으면 다음 날 트리거가
  /// 사라진다. 전송 실패 분기까지 포함해 호출함으로써 oneOff 영구 누락(periodic까지
  /// cancel된 경우 영구 미전송)을 차단한다.
  ///   - iOS 로컬 안전망 알림 → 내일로 재예약
  ///   - Android WorkManager (one-off + periodic) → 내일자로 재등록
  ///
  /// **Race 가드**: 사용자가 G+S 비활성화/탈퇴 직후 워커 isolate에서 마지막 heartbeat가
  /// 종료되며 이 함수가 호출되는 경우, 비활성화 의도와 정반대로 schedule을 재등록하는
  /// race가 가능했다(disableSubjectFeature/deleteAccount의 cancel과 인터리브). SharedPreferences를
  /// reload해 최신 role/isAlsoSubject를 다시 확인하고, heartbeat 책임이 해제된 상태면
  /// 조용히 스킵한다. 워커 callback 진입 가드(`heartbeatWorkerCallback`의 line 33)와 동일
  /// 조건으로 일관성 유지.
  Future<void> _rescheduleNextDay(int schedHour, int schedMinute) async {
    await getReloadedPrefs();
    final role = await _tokenDs.getUserRole();
    final isAlsoSubject = await _tokenDs.getIsAlsoSubject();
    if (role != 'subject' && !isAlsoSubject) {
      debugPrint(
          '[HeartbeatService] _rescheduleNextDay 스킵 — heartbeat 책임 해제됨 '
          '(role=$role, isAlsoSubject=$isAlsoSubject)');
      return;
    }
    await LocalAlarmService.schedule(schedHour, schedMinute, forceNextDay: true);
    if (Platform.isAndroid) {
      await HeartbeatWorkerService.schedule(schedHour, schedMinute);
    }
  }

  /// 전송 성공 직후 housekeeping (자동/수동/pending 큐 모든 성공 경로 공통):
  ///   - 다음 정시 재예약 (`_rescheduleNextDay`)
  ///   - Android 전송 실패 알림 → 잔존 알림 제거 (성공 경로 한정)
  ///
  /// 실패 경로는 `_rescheduleNextDay`만 직접 호출하며 `cancelSendFailed`는 부르지 않는다
  /// (방금 띄운 `notifySendFailed` 알림을 즉시 지우면 사용자에게 안내가 도달하지 않음).
  Future<void> _onHeartbeatSent(int schedHour, int schedMinute) async {
    await _rescheduleNextDay(schedHour, schedMinute);
    await LocalAlarmService.cancelSendFailed();
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
