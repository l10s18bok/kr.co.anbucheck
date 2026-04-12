import 'dart:io';
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

      final prefs = await getReloadedPrefs();

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      debugPrint('[HeartbeatWorker] role=$role, isAlsoSubject=$isAlsoSubject');
      if (role != 'subject' && !isAlsoSubject) return true;

      // 예약시각 2분 전 이상이면 스킵 (Android/iOS 공통)
      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      debugPrint('[HeartbeatWorker] 현재: ${now.hour}:${now.minute}:${now.second}, 예약: $hour:$minute');
      if (now.isBefore(scheduled.subtract(const Duration(minutes: 2)))) {
        debugPrint('[HeartbeatWorker] 예약시각 이전 — 스킵');
        return true;
      }

      // iOS: 반복 실행 방지 (30초 쿨다운)
      if (Platform.isIOS) {
        final lastExecMs = prefs.getInt('_ios_worker_last_exec_ms') ?? 0;
        final elapsed = now.millisecondsSinceEpoch - lastExecMs;
        if (elapsed < 30000) {
          debugPrint('[HeartbeatWorker] iOS: 최근 실행됨 — 스킵 (${elapsed}ms 전)');
          return true;
        }
        await prefs.setInt('_ios_worker_last_exec_ms', now.millisecondsSinceEpoch);
      }

      // deviceId/deviceToken 검증은 HeartbeatService.execute() 내부에서 처리
      debugPrint('[HeartbeatWorker] heartbeat 전송 시작');
      await HeartbeatService().execute();
      debugPrint('[HeartbeatWorker] heartbeat 전송 완료');

      if (Platform.isAndroid) {
        // Android: periodic 안전망 취소 후 다음 날 재예약
        await Workmanager().cancelByUniqueName(HeartbeatWorkerService._androidPeriodicName);
        debugPrint('[HeartbeatWorker] Android periodic 안전망 취소');
      }

      // 다음 날 동일 시각 재예약
      await HeartbeatWorkerService.scheduleNextDay();
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스
/// Android: registerOneOffTask + registerPeriodicTask (WorkManager)
/// iOS: registerProcessingTask (BGProcessingTask) — registerOneOffTask는
///      beginBackgroundTask를 사용하여 즉시 실행되므로 사용하지 않음
///      (flutter_workmanager PR #511 참고)
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _uniqueName = 'heartbeat_scheduled';

  // Android 전용: periodic 안전망
  static const _androidPeriodicName = 'heartbeat_periodic_android';

  /// Workmanager 초기화 (main()에서 1회 호출)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 시각에 맞춰 태스크 예약
  /// Android: registerOneOffTask + registerPeriodicTask (WorkManager 안전망)
  /// iOS: registerProcessingTask (BGProcessingTask, earliestBeginDate 존중)
  static Future<void> schedule(int hour, int minute) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final delay = scheduled.difference(now);

    if (Platform.isIOS) {
      // iOS: registerProcessingTask → BGProcessingTaskRequest
      // earliestBeginDate를 존중하여 지정 시각 근처에 실행
      // 기존 태스크를 명시적으로 취소 후 재등록 (replace 정책 미지원)
      await Workmanager().cancelByUniqueName(_uniqueName);
      await Workmanager().registerProcessingTask(
        _uniqueName,
        _taskName,
        initialDelay: delay,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } else {
      // Android: registerOneOffTask → WorkManager OneTimeWorkRequest
      await Workmanager().registerOneOffTask(
        _uniqueName,
        _taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      // Android 전용: periodic 안전망 (1시간 주기)
      await Workmanager().registerPeriodicTask(
        _androidPeriodicName,
        _taskName,
        frequency: const Duration(hours: 1),
        initialDelay: delay,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }

    debugPrint('[HeartbeatWorker] 예약: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (${delay.inHours}시간 ${delay.inMinutes % 60}분 후) [${Platform.isIOS ? "BGProcessingTask" : "WorkManager"}]');
  }

  /// 다음 날 동일 시각 재예약 (콜백 내에서 호출)
  static Future<void> scheduleNextDay() async {
    try {
      final (hour, minute) = await TokenLocalDatasource().getHeartbeatSchedule();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day, hour, minute)
          .add(const Duration(days: 1));
      final delay = tomorrow.difference(now);

      if (Platform.isIOS) {
        await Workmanager().cancelByUniqueName(_uniqueName);
        await Workmanager().registerProcessingTask(
          _uniqueName,
          _taskName,
          initialDelay: delay,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } else {
        await Workmanager().registerOneOffTask(
          _uniqueName,
          _taskName,
          initialDelay: delay,
          existingWorkPolicy: ExistingWorkPolicy.keep,
          constraints: Constraints(networkType: NetworkType.connected),
        );
        // Android 전용: periodic 안전망 재등록
        await Workmanager().registerPeriodicTask(
          _androidPeriodicName,
          _taskName,
          frequency: const Duration(hours: 1),
          initialDelay: delay,
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      }
    } catch (_) {}
  }

  /// 예약 취소
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName(_androidPeriodicName);
    }
  }
}
