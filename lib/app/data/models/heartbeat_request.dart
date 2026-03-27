/// 서버 POST /api/v1/heartbeat 전송 payload
class HeartbeatRequest {
  final String deviceId;
  final String timestamp;

  /// 수동 보고 여부 — 대상자가 직접 버튼을 눌러 전송한 경우 true
  final bool manual;

  /// 센서값 — 이전 스냅샷과 비교 후 채움
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;

  /// 이전 센서값 대비 변화 없음 여부
  /// true  = 폰 미사용 의심
  /// false = 폰 사용 확인
  final bool suspicious;

  /// 배터리 잔량 (0~100), 조회 실패 시 null
  final int? batteryLevel;

  const HeartbeatRequest({
    required this.deviceId,
    required this.timestamp,
    this.manual = false,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    required this.suspicious,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'timestamp': timestamp,
        if (manual) 'manual': true,
        if (accelX != null) 'accel_x': accelX,
        if (accelY != null) 'accel_y': accelY,
        if (accelZ != null) 'accel_z': accelZ,
        if (gyroX != null) 'gyro_x': gyroX,
        if (gyroY != null) 'gyro_y': gyroY,
        if (gyroZ != null) 'gyro_z': gyroZ,
        'suspicious': suspicious,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      };
}

/// 서버 응답 모델
class HeartbeatResponse {
  final String status;
  final String serverTime;
  final int heartbeatHour;
  final int heartbeatMinute;

  const HeartbeatResponse({
    required this.status,
    required this.serverTime,
    required this.heartbeatHour,
    required this.heartbeatMinute,
  });

  factory HeartbeatResponse.fromJson(Map<String, dynamic> json) =>
      HeartbeatResponse(
        status: json['status'] as String,
        serverTime: json['server_time'] as String,
        heartbeatHour: json['heartbeat_hour'] as int,
        heartbeatMinute: json['heartbeat_minute'] as int,
      );
}
