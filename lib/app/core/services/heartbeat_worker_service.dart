import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      ApiClientFactory.init(type: HttpClientType.dio);

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      print('[HeartbeatWorker] role=$role, isAlsoSubject=$isAlsoSubject');
      if (role != 'subject' && !isAlsoSubject) return true;

      // 예약시각 2분 전 이상이면 스킵 (Android/iOS 공통)
      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      print('[HeartbeatWorker] 현재: ${now.hour}:${now.minute}:${now.second}, 예약: $hour:$minute');
      if (now.isBefore(scheduled.subtract(const Duration(minutes: 2)))) {
        print('[HeartbeatWorker] 예약시각 이전 — 스킵');
        return true;
      }

      // iOS: 반복 실행 방지 (30초 쿨다운)
      if (Platform.isIOS) {
        final lastExecMs = prefs.getInt('_ios_worker_last_exec_ms') ?? 0;
        final elapsed = now.millisecondsSinceEpoch - lastExecMs;
        if (elapsed < 30000) {
          print('[HeartbeatWorker] iOS: 최근 실행됨 — 스킵 (${elapsed}ms 전)');
          return true;
        }
        await prefs.setInt('_ios_worker_last_exec_ms', now.millisecondsSinceEpoch);
      }

      final deviceId = await tokenDs.getDeviceId();
      final deviceToken = await tokenDs.getDeviceToken();
      print('[HeartbeatWorker] deviceId=$deviceId, deviceToken=${deviceToken != null ? '${deviceToken.substring(0, 10)}...' : 'null'}');
      if (deviceId == null || deviceToken == null) {
        print('[HeartbeatWorker] deviceId 또는 deviceToken이 null — 전송 불가');
        return true;
      }

      // DNS 안정화 대기 (셀룰러 네트워크 백그라운드 실행 시 DNS 지연 방어)
      await Future.delayed(const Duration(seconds: 10));
      print('[HeartbeatWorker] heartbeat 전송 시작');
      await HeartbeatService().execute();
      print('[HeartbeatWorker] heartbeat 전송 완료');

      if (Platform.isAndroid) {
        // Android: periodic 안전망 취소 후 다음 날 재예약
        await Workmanager().cancelByUniqueName(HeartbeatWorkerService._androidPeriodicName);
        print('[HeartbeatWorker] Android periodic 안전망 취소');
      }

      // 다음 날 동일 시각 재예약
      await HeartbeatWorkerService.scheduleNextDay();
    } catch (e) {
      print('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스
/// Android: one-off + periodic (WorkManager)
/// iOS: one-off만 (BGProcessingTask) — periodic 미사용 (즉시 반복 실행 버그 방어)
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _uniqueName = 'heartbeat_scheduled';

  // Android 전용: periodic 안전망
  static const _androidPeriodicName = 'heartbeat_periodic_android';

  // iOS 전용: 동일 시각 재등록 방지용 키
  static const _iosScheduledHourKey = '_ios_wm_scheduled_hour';
  static const _iosScheduledMinuteKey = '_ios_wm_scheduled_minute';

  /// Workmanager 초기화 (main()에서 1회 호출)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 시각에 맞춰 태스크 예약
  /// Android: one-off + periodic (WorkManager 안전망)
  /// iOS: one-off만 — 동일 시각이면 재등록 스킵 (BGTask 즉시 실행 방지)
  static Future<void> schedule(int hour, int minute) async {
    // iOS: 동일 시각이면 재등록 스킵 (BGTask가 등록 시 즉시 실행되는 문제 방어)
    if (Platform.isIOS) {
      final prefs = await SharedPreferences.getInstance();
      final lastH = prefs.getInt(_iosScheduledHourKey);
      final lastM = prefs.getInt(_iosScheduledMinuteKey);
      if (lastH == hour && lastM == minute) {
        debugPrint('[HeartbeatWorker] iOS: 동일 스케줄($hour:$minute) — 재등록 스킵');
        return;
      }
    }

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final delay = scheduled.difference(now);

    // one-off (Android/iOS 공통)
    await Workmanager().registerOneOffTask(
      _uniqueName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    if (Platform.isAndroid) {
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

    if (Platform.isIOS) {
      // iOS: 등록된 시각 저장 (재등록 방지)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_iosScheduledHourKey, hour);
      await prefs.setInt(_iosScheduledMinuteKey, minute);
    }

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

      if (Platform.isAndroid) {
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
    if (Platform.isIOS) {
      // iOS: 저장된 스케줄 초기화 (다음 schedule()이 실행되도록)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_iosScheduledHourKey);
      await prefs.remove(_iosScheduledMinuteKey);
    }
  }
}
