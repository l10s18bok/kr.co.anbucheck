import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 긴급 도움 요청 시 첨부되는 사용자 위치.
/// 권한 거부/GPS 실패/타임아웃 어떤 경우에도 긴급 API 호출은 실행되며, 위치는 옵션이다.
class EmergencyLocation {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime? capturedAt;

  const EmergencyLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
        if (capturedAt != null) 'captured_at': capturedAt!.toIso8601String(),
      };
}

/// POST /api/v1/emergency
class EmergencyRemoteDatasource {
  final Map<String, String> _auth;

  EmergencyRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  Future<void> send(String deviceId, {EmergencyLocation? location}) async {
    final body = <String, dynamic>{'device_id': deviceId};
    if (location != null) {
      body['location'] = location.toJson();
    }

    final result = await ApiClientFactory.instance.post<Map<String, dynamic>>(
      ApiEndpoints.emergency,
      body,
      headers: _auth,
    );

    if (!result.isOk) {
      throw Exception('긴급 알림 전송 실패 (${result.statusCode})');
    }
  }
}
