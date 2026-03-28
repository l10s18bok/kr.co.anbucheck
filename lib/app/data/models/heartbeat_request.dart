/// 서버 POST /api/v1/heartbeat 전송 payload
class HeartbeatRequest {
  final String deviceId;
  final String timestamp;

  /// 수동 보고 여부 — 대상자가 직접 버튼을 눌러 전송한 경우 true
  final bool manual;

  /// 이전 heartbeat 이후 걸음수 증가량
  /// 권한 거부 또는 조회 실패 시 null
  final int? stepsDelta;

  /// 활동 지표 기반 의심 여부
  /// true  = 활동 감지 안 됨 (걸음수 0 + 가속도/자이로 변화 없음)
  /// false = 활동 확인됨
  final bool suspicious;

  /// 배터리 잔량 (0~100), 조회 실패 시 null
  final int? batteryLevel;

  const HeartbeatRequest({
    required this.deviceId,
    required this.timestamp,
    this.manual = false,
    this.stepsDelta,
    required this.suspicious,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'timestamp': timestamp,
        if (manual) 'manual': true,
        if (stepsDelta != null) 'steps_delta': stepsDelta,
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
