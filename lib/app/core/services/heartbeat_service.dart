import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
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
  /// 동일 isolate 내 중복 실행 방지 (execute + sendPending 공유)
  static bool _busy = false;

  final _sensorDs     = SensorLocalDatasource();
  final _heartbeatDs  = HeartbeatLocalDatasource();
  final _tokenDs      = TokenLocalDatasource();
  final _battery      = Battery();

  /// heartbeat 1회 실행
  /// [manual] 대상자가 직접 버튼을 눌러 전송한 경우 true
  Future<void> execute({bool manual = false}) async {
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

      await _executeInternal(deviceId: deviceId, deviceToken: deviceToken, manual: manual);
    } finally {
      _busy = false;
    }
  }

  Future<void> _executeInternal({
    required String deviceId,
    required String deviceToken,
    bool manual = false,
  }) async {

    // 동일 예약시각에 대한 중복 전송 방어 (날짜+예약시각 조합)
    // manual=true는 무조건 전송 (suspicious 알림 응답, 수동 보고)
    await getReloadedPrefs();
    final now = DateTime.now();
    final (schedHour, schedMinute) = await _tokenDs.getHeartbeatSchedule();
    if (!manual) {
      final scheduledKey = '${formatYmd(now)}_${formatHm(schedHour, schedMinute)}';
      final lastKey = await _tokenDs.getLastScheduledKey();
      if (lastKey == scheduledKey) {
        debugPrint('[HeartbeatService] 이미 전송 완료 — 스킵 ($scheduledKey)');
        return;
      }
    }

    final timestamp    = now.toUtc().toIso8601String();
    final batteryLevel = await _getBatteryLevel();

    // 수동 보고는 버튼을 직접 눌렀다는 행위 자체가 활동 증거 → suspicious 강제 false
    int? stepsDelta;
    bool suspicious = false;
    if (!manual) {
      stepsDelta = await _getStepsDelta();
      debugPrint('[HeartbeatService] stepsDelta=$stepsDelta');
      if (stepsDelta != null && stepsDelta > 0) {
        // 걸음수 변화 있음 → 즉시 정상 판정
        suspicious = false;
      } else {
        // 걸음수 변화 없거나 권한 거부 → 가속도/자이로로 보완 판정
        final sensor = await _collectSensor();
        debugPrint('[HeartbeatService] sensor=${sensor != null ? 'accel(${sensor.accelX.toStringAsFixed(2)},${sensor.accelY.toStringAsFixed(2)},${sensor.accelZ.toStringAsFixed(2)}) gyro(${sensor.gyroX.toStringAsFixed(2)},${sensor.gyroY.toStringAsFixed(2)},${sensor.gyroZ.toStringAsFixed(2)})' : 'null'}');
        suspicious = await _calcSuspicious(sensor);
        debugPrint('[HeartbeatService] suspicious=$suspicious');
        if (sensor != null) {
          await _sensorDs.saveSnapshot(
            accelX: sensor.accelX, accelY: sensor.accelY, accelZ: sensor.accelZ,
            gyroX:  sensor.gyroX,  gyroY:  sensor.gyroY,  gyroZ:  sensor.gyroZ,
          );
        }
      }
      // 걸음수 저장은 _getStepsDelta() 내에서 처리 완료
    }

    final request = HeartbeatRequest(
      deviceId:     deviceId,
      timestamp:    timestamp,
      manual:       manual,
      stepsDelta:   stepsDelta,
      suspicious:   suspicious,
      batteryLevel: batteryLevel,
    );

    await _sendOrSavePending(request, deviceToken, schedHour, schedMinute);
  }

  /// 센서 기준값만 로컬에 저장 (서버 전송 없음)
  /// 최초 설치 직후 보호자 미연결 상태에서 호출
  Future<void> saveSensorBaseline() async {
    // 걸음수 기준점 저장
    try {
      final current = await Pedometer.stepCountStream.first
          .timeout(const Duration(seconds: 2));
      await _sensorDs.saveLastSteps(current.steps.toInt());
    } catch (_) {}

    // 가속도/자이로 기준점 저장
    final sensor = await _collectSensor();
    if (sensor != null) {
      await _sensorDs.saveSnapshot(
        accelX: sensor.accelX, accelY: sensor.accelY, accelZ: sensor.accelZ,
        gyroX: sensor.gyroX, gyroY: sensor.gyroY, gyroZ: sensor.gyroZ,
      );
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
          // 전송 실패 — 내일 데드맨 알림은 반드시 예약되어 있어야 안전망 유지
          await LocalAlarmService.schedule(schedHour, schedMinute, forceNextDay: true);
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

  /// 이전 heartbeat 이후 걸음수 증가량 조회 + 현재 걸음수 저장
  /// 권한 거부 또는 조회 실패 시 null 반환
  Future<int?> _getStepsDelta() async {
    try {
      final current = await Pedometer.stepCountStream.first
          .timeout(const Duration(seconds: 2));
      final currentSteps = current.steps.toInt();
      final prevSteps = await _sensorDs.getLastSteps();

      // 현재 걸음수 저장 (다음 주기 비교용) — 스트림 중복 구독 방지
      await _sensorDs.saveLastSteps(currentSteps);

      if (prevSteps == null) {
        // 첫 heartbeat — 기준점 저장 완료, 0 반환
        return 0;
      }
      final delta = currentSteps - prevSteps;
      return delta > 0 ? delta : 0;
    } catch (_) {
      return null;
    }
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
    if (prev['accel_x'] == null) {
      // 첫 heartbeat — 기준점 저장 후 정상 판정
      await _sensorDs.saveSnapshot(
        accelX: current.accelX, accelY: current.accelY, accelZ: current.accelZ,
        gyroX: current.gyroX, gyroY: current.gyroY, gyroZ: current.gyroZ,
      );
      return false;
    }

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
