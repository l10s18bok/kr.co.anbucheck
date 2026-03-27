import 'package:shared_preferences/shared_preferences.dart';

/// 이전 heartbeat 센서 스냅샷 저장 (가속도 + 자이로)
/// 다음 heartbeat 시 비교하여 폰 위치 변화 여부 판단
class SensorLocalDatasource {
  static const _keyAccelX = 'sensor_accel_x';
  static const _keyAccelY = 'sensor_accel_y';
  static const _keyAccelZ = 'sensor_accel_z';
  static const _keyGyroX = 'sensor_gyro_x';
  static const _keyGyroY = 'sensor_gyro_y';
  static const _keyGyroZ = 'sensor_gyro_z';
  static const _keySavedAt = 'sensor_saved_at';

  Future<Map<String, double?>> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'accel_x': prefs.getDouble(_keyAccelX),
      'accel_y': prefs.getDouble(_keyAccelY),
      'accel_z': prefs.getDouble(_keyAccelZ),
      'gyro_x': prefs.getDouble(_keyGyroX),
      'gyro_y': prefs.getDouble(_keyGyroY),
      'gyro_z': prefs.getDouble(_keyGyroZ),
    };
  }

  Future<void> saveSnapshot({
    required double accelX,
    required double accelY,
    required double accelZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAccelX, accelX);
    await prefs.setDouble(_keyAccelY, accelY);
    await prefs.setDouble(_keyAccelZ, accelZ);
    await prefs.setDouble(_keyGyroX, gyroX);
    await prefs.setDouble(_keyGyroY, gyroY);
    await prefs.setDouble(_keyGyroZ, gyroZ);
    await prefs.setString(_keySavedAt, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSavedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keySavedAt);
    return str != null ? DateTime.parse(str) : null;
  }
}
