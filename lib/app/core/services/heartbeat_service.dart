import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/sensor_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/heartbeat_remote_datasource.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';

/// 센서 변화 임계값 (가속도/자이로 — 걸음수 0일 때만 사용)
const _accelThreshold = 5.0;  // m/s²
const _gyroThreshold  = 0.3;  // rad/s

/// Heartbeat 수집 → suspicious 판정 → 서버 전송 (오프라인 시 큐 저장)
class HeartbeatService {
  final _sensorDs     = SensorLocalDatasource();
  final _heartbeatDs  = HeartbeatLocalDatasource();
  final _tokenDs      = TokenLocalDatasource();
  final _battery      = Battery();
  final _connectivity = Connectivity();

  /// heartbeat 1회 실행
  /// [manual] 대상자가 직접 버튼을 눌러 전송한 경우 true
  Future<void> execute({bool manual = false}) async {
    final deviceId    = await _tokenDs.getDeviceId();
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceId == null || deviceToken == null) return;

    final timestamp    = DateTime.now().toUtc().toIso8601String();
    final batteryLevel = await _getBatteryLevel();

    // 수동 보고는 버튼을 직접 눌렀다는 행위 자체가 활동 증거 → suspicious 강제 false
    int? stepsDelta;
    bool suspicious = false;
    if (!manual) {
      stepsDelta = await _getStepsDelta();
      if (stepsDelta != null && stepsDelta > 0) {
        // 걸음수 변화 있음 → 즉시 정상 판정
        suspicious = false;
      } else {
        // 걸음수 변화 없거나 권한 거부 → 가속도/자이로로 보완 판정
        final sensor = await _collectSensor();
        suspicious = await _calcSuspicious(sensor);
        if (sensor != null) {
          await _sensorDs.saveSnapshot(
            accelX: sensor.accelX, accelY: sensor.accelY, accelZ: sensor.accelZ,
            gyroX:  sensor.gyroX,  gyroY:  sensor.gyroY,  gyroZ:  sensor.gyroZ,
          );
        }
      }
      // 현재 걸음수 저장 (다음 주기 비교용)
      await _saveCurrentSteps();
    }

    // suspicious=true → 대상자에게 로컬 알림 즉시 발송 (서버 왕복 불필요)
    if (suspicious) {
      await _showWellbeingCheckNotification();
    }

    final request = HeartbeatRequest(
      deviceId:     deviceId,
      timestamp:    timestamp,
      manual:       manual,
      stepsDelta:   stepsDelta,
      suspicious:   suspicious,
      batteryLevel: batteryLevel,
    );

    final results = await _connectivity.checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      await _sendOrSavePending(request, deviceToken);
    } else {
      await _heartbeatDs.savePending(request.toJson());
    }
  }

  /// 보류 중인 heartbeat 재전송 (네트워크 복구 시 호출)
  Future<void> sendPending(String deviceToken) async {
    final payload = await _heartbeatDs.getPending();
    if (payload == null) return;

    // pending의 timestamp가 오늘 날짜가 아니면 stale → 버림
    // (백그라운드에서 이미 처리된 경우 cross-isolate 캐시 문제 없이 걸러냄)
    final pendingTs = DateTime.tryParse(payload['timestamp'] as String? ?? '');
    final now = DateTime.now();
    if (pendingTs == null || pendingTs.toLocal().day != now.day ||
        pendingTs.toLocal().month != now.month ||
        pendingTs.toLocal().year != now.year) {
      await _heartbeatDs.clearPending();
      return;
    }

    try {
      await HeartbeatRemoteDatasource(deviceToken).send(_fromJson(payload));
      await _heartbeatDs.clearPending();

      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await _tokenDs.saveLastHeartbeatDate(today);
      await _tokenDs.saveLastHeartbeatTime(timeStr);

      final (hour, minute) = await _tokenDs.getHeartbeatSchedule();
      await LocalAlarmService.schedule(hour, minute);
    } catch (_) {}
  }

  // ── private ──────────────────────────────────────────────

  Future<void> _sendOrSavePending(HeartbeatRequest request, String deviceToken) async {
    try {
      await HeartbeatRemoteDatasource(deviceToken).send(request);
      // 전송 성공 시 stale pending 제거 (앱 재실행 시 중복 전송 방지)
      await _heartbeatDs.clearPending();

      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await _tokenDs.saveLastHeartbeatDate(today);
      await _tokenDs.saveLastHeartbeatTime(timeStr);

      // 로컬 안전망 알림 재예약 (heartbeat 시각 + 10분, 매일 반복)
      final (hour, minute) = await _tokenDs.getHeartbeatSchedule();
      await LocalAlarmService.schedule(hour, minute);
    } catch (_) {
      await _heartbeatDs.savePending(request.toJson());
    }
  }

  Future<int?> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return null;
    }
  }

  /// 이전 heartbeat 이후 걸음수 증가량 조회
  /// 권한 거부 또는 조회 실패 시 null 반환
  Future<int?> _getStepsDelta() async {
    try {
      final current = await Pedometer.stepCountStream.first
          .timeout(const Duration(seconds: 2));
      final prevSteps = await _sensorDs.getLastSteps();
      if (prevSteps == null) return null; // 첫 heartbeat
      final delta = current.steps.toInt() - prevSteps;
      return delta > 0 ? delta : 0;
    } catch (_) {
      return null;
    }
  }

  /// 현재 누적 걸음수 저장 (다음 주기 비교용)
  Future<void> _saveCurrentSteps() async {
    try {
      final current = await Pedometer.stepCountStream.first
          .timeout(const Duration(seconds: 2));
      await _sensorDs.saveLastSteps(current.steps.toInt());
    } catch (_) {}
  }

  /// 센서 스냅샷 1회 수집 (500ms 타임아웃, 실패 시 null)
  Future<_SensorSnapshot?> _collectSensor() async {
    try {
      final accel = await accelerometerEventStream().first
          .timeout(const Duration(milliseconds: 500));
      final gyro = await gyroscopeEventStream().first
          .timeout(const Duration(milliseconds: 500));
      return _SensorSnapshot(
        accelX: accel.x, accelY: accel.y, accelZ: accel.z,
        gyroX:  gyro.x,  gyroY:  gyro.y,  gyroZ:  gyro.z,
      );
    } catch (_) {
      return null;
    }
  }

  /// 이전 스냅샷과 비교하여 suspicious 판정
  Future<bool> _calcSuspicious(_SensorSnapshot? current) async {
    if (current == null) return false;

    final prev = await _sensorDs.getSnapshot();
    if (prev['accel_x'] == null) return false; // 이전 값 없음 → 첫 heartbeat

    final accelDelta = sqrt(
      pow((current.accelX - (prev['accel_x'] ?? 0)), 2) +
      pow((current.accelY - (prev['accel_y'] ?? 0)), 2) +
      pow((current.accelZ - (prev['accel_z'] ?? 0)), 2),
    );

    final gyroDelta = sqrt(
      pow((current.gyroX - (prev['gyro_x'] ?? 0)), 2) +
      pow((current.gyroY - (prev['gyro_y'] ?? 0)), 2) +
      pow((current.gyroZ - (prev['gyro_z'] ?? 0)), 2),
    );

    return accelDelta < _accelThreshold && gyroDelta < _gyroThreshold;
  }

  /// suspicious=true 판정 시 대상자에게 로컬 알림 즉시 발송
  /// 서버 왕복 없이 즉각 표시 — 네트워크 없어도 동작
  Future<void> _showWellbeingCheckNotification() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.show(
        0x57656C6C, // 고정 ID ('Well' hex) — 중복 발송 시 덮어씀
        '💛 안부 확인',
        '잘 지내고 계시죠? 이 메시지 알림을 한 번 터치해 주세요.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'anbu_alerts',
            '안부 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        payload: 'wellbeing_check',
      );
    } catch (_) {}
  }

  HeartbeatRequest _fromJson(Map<String, dynamic> json) =>
      HeartbeatRequest(
        deviceId:     json['device_id'] as String,
        timestamp:    json['timestamp'] as String,
        manual:       (json['manual'] as bool?) ?? false,
        stepsDelta:   json['steps_delta'] as int?,
        suspicious:   json['suspicious'] as bool,
        batteryLevel: json['battery_level'] as int?,
      );
}

class _SensorSnapshot {
  final double accelX, accelY, accelZ;
  final double gyroX,  gyroY,  gyroZ;

  const _SensorSnapshot({
    required this.accelX, required this.accelY, required this.accelZ,
    required this.gyroX,  required this.gyroY,  required this.gyroZ,
  });
}
