import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/sensor_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/heartbeat_remote_datasource.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';
/// 센서 변화 임계값 (플로우차트 기준)
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

    final timestamp   = DateTime.now().toUtc().toIso8601String();
    final batteryLevel = await _getBatteryLevel();
    final sensor      = await _collectSensor();
    // 수동 보고는 버튼을 직접 눌렀다는 행위 자체가 활동 증거 → suspicious 강제 false
    final suspicious  = manual ? false : await _calcSuspicious(sensor);

    // 센서 스냅샷 저장 (다음 주기 비교용)
    if (sensor != null) {
      await _sensorDs.saveSnapshot(
        accelX: sensor.accelX, accelY: sensor.accelY, accelZ: sensor.accelZ,
        gyroX:  sensor.gyroX,  gyroY:  sensor.gyroY,  gyroZ:  sensor.gyroZ,
      );
    }

    final request = HeartbeatRequest(
      deviceId:     deviceId,
      timestamp:    timestamp,
      manual:       manual,
      accelX:       sensor?.accelX,
      accelY:       sensor?.accelY,
      accelZ:       sensor?.accelZ,
      gyroX:        sensor?.gyroX,
      gyroY:        sensor?.gyroY,
      gyroZ:        sensor?.gyroZ,
      suspicious:   suspicious,
      batteryLevel: batteryLevel,
    );

    // 네트워크 연결 여부 확인
    final results = await _connectivity.checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      await _sendOrQueue(request, deviceToken);
    } else {
      await _heartbeatDs.enqueue(request.toJson());
    }
  }

  /// 오프라인 큐 일괄 전송 (네트워크 복구 시 호출)
  Future<void> flushQueue(String deviceToken) async {
    final queue = await _heartbeatDs.getQueue();
    for (final item in queue) {
      try {
        await HeartbeatRemoteDatasource(deviceToken).send(
          _fromQueueJson(item.payload),
        );
        await _heartbeatDs.dequeue(item.id);
      } catch (_) {
        break; // 실패 시 중단, 다음 기회에 재시도
      }
    }
  }

  // ── private ──────────────────────────────────────────────

  Future<void> _sendOrQueue(HeartbeatRequest request, String deviceToken) async {
    try {
      await HeartbeatRemoteDatasource(deviceToken).send(request);
      // 전송 성공 시 날짜 + 시각 로컬 저장 (홈 화면 상태 표시용)
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await _tokenDs.saveLastHeartbeatDate(today);
      await _tokenDs.saveLastHeartbeatTime(timeStr);
    } catch (_) {
      // 전송 실패 시 큐에 저장
      await _heartbeatDs.enqueue(request.toJson());
    }
  }

  /// 배터리 레벨 조회 (실패 시 null)
  Future<int?> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
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
  /// 이전 값 없으면 false (첫 heartbeat는 정상으로 처리)
  Future<bool> _calcSuspicious(_SensorSnapshot? current) async {
    if (current == null) return false;

    final prev = await _sensorDs.getSnapshot();
    final prevAccelX = prev['accel_x'];
    if (prevAccelX == null) return false; // 이전 값 없음

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

    // 가속도 변화 < 5.0 AND 자이로 변화 < 0.3 → 미사용 의심
    return accelDelta < _accelThreshold && gyroDelta < _gyroThreshold;
  }

  HeartbeatRequest _fromQueueJson(Map<String, dynamic> json) =>
      HeartbeatRequest(
        deviceId:     json['device_id'] as String,
        timestamp:    json['timestamp'] as String,
        manual:       (json['manual'] as bool?) ?? false,
        accelX:       (json['accel_x'] as num?)?.toDouble(),
        accelY:       (json['accel_y'] as num?)?.toDouble(),
        accelZ:       (json['accel_z'] as num?)?.toDouble(),
        gyroX:        (json['gyro_x'] as num?)?.toDouble(),
        gyroY:        (json['gyro_y'] as num?)?.toDouble(),
        gyroZ:        (json['gyro_z'] as num?)?.toDouble(),
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
