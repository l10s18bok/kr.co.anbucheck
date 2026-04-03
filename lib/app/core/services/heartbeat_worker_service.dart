import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:workmanager/workmanager.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
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

      ApiClientFactory.init(type: HttpClientType.getConnect);

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      if (role != 'subject') return true;

      // 예약시각 이전이면 실행하지 않음 (iOS 조기 실행 방어)
      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      if (now.isBefore(scheduled)) {
        debugPrint('[HeartbeatWorker] 예약시각 이전 — 스킵 (현재: ${now.hour}:${now.minute}, 예약: $hour:$minute)');
        return true;
      }

      // 오늘 이미 전송했으면 스킵 (하루 1회 제한)
      final lastDate = await tokenDs.getLastHeartbeatDate();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      if (lastDate == today) {
        debugPrint('[HeartbeatWorker] 오늘 이미 전송 완료 — 스킵');
        return true;
      }

      await HeartbeatService().execute();

      // 다음 날 동일 시각 재예약
      await HeartbeatWorkerService.scheduleNextDay();
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스
/// Android: WorkManager, iOS: BGTaskScheduler + Background Fetch
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _uniqueName = 'heartbeat_scheduled';
  static const _periodicUniqueName = 'heartbeat_periodic';

  /// Workmanager 초기화 (main()에서 1회 호출)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 시각에 맞춰 one-off 태스크 예약 + periodic 태스크 등록
  /// one-off: 정확한 시각 지정 (Android WorkManager / iOS BGProcessingTask)
  /// periodic: iOS Background Fetch (BGAppRefreshTask) 보조 — OS가 적절한 시점에 실행
  static Future<void> schedule(int hour, int minute) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final delay = scheduled.difference(now);

    // 1차: one-off (정확한 시각)
    await Workmanager().registerOneOffTask(
      _uniqueName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // 2차 보조: periodic (iOS Background Fetch 안전망)
    // 콜백 내 1시간 쿨다운으로 중복 전송 방지
    await Workmanager().registerPeriodicTask(
      _periodicUniqueName,
      _taskName,
      frequency: const Duration(hours: 1),
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
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {}
  }

  /// 예약 취소 (one-off + periodic 모두)
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
    await Workmanager().cancelByUniqueName(_periodicUniqueName);
  }
}
