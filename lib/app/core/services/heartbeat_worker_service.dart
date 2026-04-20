import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:workmanager/workmanager.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// WorkManager 백그라운드 콜백 (top-level 함수 필수)
@pragma('vm:entry-point')
void heartbeatWorkerCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      tz.initializeTimeZones();
      try {
        final localTzName = await FlutterTimezone.getLocalTimezone();
        tzlib.setLocalLocation(tzlib.getLocation(localTzName));
      } catch (_) {
        tzlib.setLocalLocation(tzlib.getLocation('Asia/Seoul'));
      }

      ApiClientFactory.init(type: HttpClientType.dio);
      await getReloadedPrefs();

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      debugPrint('[HeartbeatWorker] task=$taskName role=$role, isAlsoSubject=$isAlsoSubject');
      if (role != 'subject' && !isAlsoSubject) return true;

      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      debugPrint(
        '[HeartbeatWorker] 현재: ${now.hour}:${now.minute}:${now.second}, 예약: $hour:$minute',
      );
      if (now.isBefore(scheduled)) {
        debugPrint('[HeartbeatWorker] 예약시각 이전 — 스킵');
        return true;
      }

      final today = formatYmd(now);
      final lastDate = await tokenDs.getLastHeartbeatDate();
      if (lastDate == today) {
        debugPrint('[HeartbeatWorker] 오늘 이미 전송 완료 — 스킵');
        return true;
      }

      debugPrint('[HeartbeatWorker] heartbeat 전송 시도');
      await HeartbeatService().execute();
      debugPrint('[HeartbeatWorker] heartbeat 전송 완료');

      // 전송 성공 시 one-off만 내일로 재등록 (periodic은 그대로 폴링 유지)
      await HeartbeatWorkerService.rescheduleOneOffForNextDay(hour, minute);
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스 (Android 전용)
///
/// 2계층 실행 구조:
///   - one-off: 예약시각에 1회 fire. 메인 전송 담당. 전송 성공 후 콜백에서
///     rescheduleOneOffForNextDay()로 내일 예약시각에 재등록.
///   - periodic 1시간: 안전망 폴링. one-off이 OEM 배터리 절약/Doze 등으로 누락될
///     때 최대 1시간 내 백업 발화. 첫 fire 후 재등록하지 않고 그대로 둔다
///     (flutter_workmanager의 UPDATE는 initialDelay를 무시하고, REPLACE는 자기자신을
///     취소하는 이슈가 있어 건드리면 오히려 폴링이 깨진다).
///
/// ─── 동시 발화(race) 방지 — 4계층 방어 ───
///
/// Doze maintenance window 특성상 one-off과 periodic이 같은 window에서 거의 동시에
/// fire되는 race가 실측된다. 이 race는 아래 4계층으로 순차 차단된다:
///
/// 1) 콜백 레벨 — heartbeatWorkerCallback
///    `lastHeartbeatDate == today`면 즉시 스킵. 같은 날 두 번째 이상 진입 차단.
///
/// 2) Service 레벨 — HeartbeatService._executeInternal
///    `lastScheduledKey == 현재 scheduledKey`면 스킵. 성공 마커로 `_sendOrSavePending`
///    에서 API 전송 성공 후 save. 당일 재전송을 막는다.
///
/// 3) Lock 레벨 — HeartbeatLockDatasource.tryAcquire (주 방어선)
///    SQLite UNIQUE INSERT 기반 cross-isolate 원자 락. WorkManager는 워커마다 새
///    isolate를 생성하므로 SharedPreferences reload→check→save는 CAS가 아니다.
///    SQLite UNIQUE는 Android WAL로 cross-isolate writer를 직렬화해 하나만 INSERT
///    성공, 나머지는 UniqueConstraintError로 즉시 실패. TTL 30초 초과 stale 락은
///    tryAcquire 진입 시 자동 정리되어 crashed isolate가 남긴 락도 이어받는다.
///
/// 4) 서버 레벨 — POST /api/v1/heartbeat
///    `(device_id, scheduled_key)` idempotency로 HTTP retry 중복 전송을 차단한다.
///    dio connectionError 같이 응답 유실로 클라가 재시도해도 서버는 같은 key의
///    두 번째 요청은 부수효과(Push/alert) 없이 200 OK만 반환.
///
/// iOS는 이 서비스를 호출하지 않는다 — iOS G+S는 LocalAlarmService의
/// 오늘의 안부 확인 메시지 로컬 알림 + 앱 열기 자동 전송만으로 동작하며,
/// BGTaskScheduler를 사용하지 않는다.
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _periodicName = 'heartbeat_periodic';
  static const _oneOffName = 'heartbeat_scheduled';

  static const _pollFrequency = Duration(hours: 1);

  /// Workmanager 초기화 (main()에서 1회 호출, Android에서만)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 등록 (one-off + periodic 1시간 동시 등록)
  static Future<void> schedule(int hour, int minute) async {
    final delay = _computeNextDelay(hour, minute);

    // one-off: 정확히 예약시각에 1회 fire
    await Workmanager().cancelByUniqueName(_oneOffName);
    await Workmanager().registerOneOffTask(
      _oneOffName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // periodic 1시간: 안전망 폴링. one-off과 동일 시각에 첫 fire.
    // Doze maintenance window에서 함께 집계돼 동시 fire되더라도
    // HeartbeatLockDatasource(SQLite UNIQUE CAS)가 race를 원자적으로 차단한다.
    await Workmanager().registerPeriodicTask(
      _periodicName,
      _taskName,
      frequency: _pollFrequency,
      initialDelay: delay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint(
      '[HeartbeatWorker] 예약 등록: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} '
      '(one-off + periodic 모두 ${delay.inHours}h ${delay.inMinutes % 60}m 후 첫 fire)',
    );
  }

  /// 콜백 내부에서 전송 성공 후 호출 — one-off만 내일 예약시각으로 재등록.
  /// periodic은 손대지 않는다 (UPDATE는 무시되고 REPLACE는 자기자신 취소 위험).
  static Future<void> rescheduleOneOffForNextDay(int hour, int minute) async {
    try {
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(const Duration(days: 1));
      final delay = tomorrow.difference(now);

      await Workmanager().cancelByUniqueName(_oneOffName);
      await Workmanager().registerOneOffTask(
        _oneOffName,
        _taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      debugPrint(
        '[HeartbeatWorker] one-off 내일로 재등록: ${delay.inHours}시간 ${delay.inMinutes % 60}분 후 fire',
      );
    } catch (e) {
      debugPrint('[HeartbeatWorker] one-off 재등록 실패: $e');
    }
  }

  /// 다음 예약시각까지의 delay 계산 (이미 지났으면 내일)
  static Duration _computeNextDelay(int hour, int minute) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }

  /// 예약 취소 (one-off + periodic 모두)
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_oneOffName);
    await Workmanager().cancelByUniqueName(_periodicName);
  }
}
