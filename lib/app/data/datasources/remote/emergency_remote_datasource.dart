import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// POST /api/v1/emergency
class EmergencyRemoteDatasource {
  final Map<String, String> _auth;

  EmergencyRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  Future<void> send(String deviceId) async {
    final result = await ApiClientFactory.instance.post<Map<String, dynamic>>(
      ApiEndpoints.emergency,
      {'device_id': deviceId},
      headers: _auth,
    );

    if (!result.isOk) {
      throw Exception('긴급 알림 전송 실패 (${result.statusCode})');
    }
  }
}
