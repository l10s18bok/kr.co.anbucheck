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
      // 백그라운드 isolate timezone 초기화
      tz.initializeTimeZones();
      try {
        final localTzName = await FlutterTimezone.getLocalTimezone();
        tzlib.setLocalLocation(tzlib.getLocation(localTzName));
      } catch (_) {
        tzlib.setLocalLocation(tzlib.getLocation('Asia/Seoul'));
      }

      ApiClientFactory.init(type: HttpClientType.dio);

      // 백그라운드 isolate의 SharedPreferences 캐시를 디스크와 동기화
      // 메인 isolate에서 막 저장한 스케줄/역할 값을 stale 없이 읽기 위함
      await getReloadedPrefs();

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      debugPrint('[HeartbeatWorker] role=$role, isAlsoSubject=$isAlsoSubject');
      if (role != 'subject' && !isAlsoSubject) return true;

      // 예약시각 2분 전 이상이면 스킵
      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      debugPrint('[HeartbeatWorker] 현재: ${now.hour}:${now.minute}:${now.second}, 예약: $hour:$minute');
      if (now.isBefore(scheduled.subtract(const Duration(minutes: 2)))) {
        debugPrint('[HeartbeatWorker] 예약시각 이전 — 스킵');
        return true;
      }

      debugPrint('[HeartbeatWorker] heartbeat 전송 시작');
      await HeartbeatService().execute();
      debugPrint('[HeartbeatWorker] heartbeat 전송 완료');

      // 오늘 periodic 안전망 취소 — 다음 날은 scheduleNextDay에서 재등록
      await Workmanager().cancelByUniqueName(HeartbeatWorkerService._androidPeriodicName);
      debugPrint('[HeartbeatWorker] Android periodic 안전망 취소');

      // 다음 날 동일 시각 재예약
      await HeartbeatWorkerService.scheduleNextDay();
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스 (Android 전용)
///
/// 2계층 예약:
///   · one-off: 예약 시각에 한 번 정확히 실행 (primary)
///   · periodic: 15분 주기 안전망 (WorkManager 최소 간격) — Doze/OEM 절전으로
///     one-off가 지연/미실행되는 경우 maintenance window에 따라잡기 실행
///
/// 전송 성공 시 콜백에서 periodic을 즉시 취소해 오늘 남은 시간의 재발화를 막고,
/// `scheduleNextDay`에서 다음 날용 one-off + periodic을 함께 재등록한다.
/// 중복 전송 race는 HeartbeatService의 선(先)점유 dedup으로 구조적으로 차단된다.
///
/// iOS는 이 서비스를 호출하지 않는다 — iOS G+S는 LocalAlarmService 데드맨 알림 +
/// 앱 열기 자동 전송만으로 동작하며, BGTaskScheduler를 사용하지 않는다.
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _uniqueName = 'heartbeat_scheduled';
  static const _androidPeriodicName = 'heartbeat_periodic_android';

  /// Workmanager 초기화 (main()에서 1회 호출, Android에서만)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 시각에 맞춰 태스크 예약 (one-off + periodic 안전망)
  static Future<void> schedule(int hour, int minute) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final delay = scheduled.difference(now);

    await Workmanager().registerOneOffTask(
      _uniqueName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
    await Workmanager().registerPeriodicTask(
      _androidPeriodicName,
      _taskName,
      frequency: const Duration(minutes: 15),
      initialDelay: delay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint('[HeartbeatWorker] 예약: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (${delay.inHours}시간 ${delay.inMinutes % 60}분 후)');
  }

  /// 다음 날 동일 시각 재예약 (콜백 내에서 호출)
  static Future<void> scheduleNextDay() async {
    try {
      final (hour, minute) = await TokenLocalDatasource().getHeartbeatSchedule();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day, hour, minute)
          .add(const Duration(days: 1));
      final delay = tomorrow.difference(now);

      await Workmanager().registerOneOffTask(
        _uniqueName,
        _taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      await Workmanager().registerPeriodicTask(
        _androidPeriodicName,
        _taskName,
        frequency: const Duration(minutes: 15),
        initialDelay: delay,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {}
  }

  /// 예약 취소
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
    await Workmanager().cancelByUniqueName(_androidPeriodicName);
  }
}
