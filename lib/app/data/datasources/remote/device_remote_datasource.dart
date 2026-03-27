import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 기기 관련 원격 저장소
class DeviceRemoteDatasource {
  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// PUT /api/v1/devices/fcm-token — FCM 토큰 갱신
  Future<void> updateFcmToken(String deviceToken, String fcmToken) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.devicesFcmToken,
      {'fcm_token': fcmToken},
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('FCM 토큰 갱신 실패 (${result.statusCode})');
    }
  }

  /// GET /api/v1/devices/me — 내 기기 정보 조회 (heartbeat 시각, last_seen)
  Future<Map<String, dynamic>> getMyDevice(String deviceToken) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.devicesMe,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('기기 정보 조회 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// PUT /api/v1/devices/{device_id}/heartbeat-schedule — heartbeat 시각 변경
  /// 서버 PRD는 PATCH이나 PUT으로도 동작하도록 서버에서 처리
  Future<void> updateHeartbeatSchedule(
    String deviceToken,
    String deviceId,
    int hour,
    int minute,
  ) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.heartbeatSchedule(deviceId),
      {'heartbeat_hour': hour, 'heartbeat_minute': minute},
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('heartbeat 시각 변경 실패 (${result.statusCode})');
    }
  }
}
