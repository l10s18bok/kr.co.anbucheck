import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';

/// POST /api/v1/heartbeat
class HeartbeatRemoteDatasource {
  final Map<String, String> _auth;

  HeartbeatRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  Future<HeartbeatResponse> send(HeartbeatRequest request) async {
    final result = await ApiClientFactory.instance.post<Map<String, dynamic>>(
      ApiEndpoints.heartbeat,
      request.toJson(),
      headers: _auth,
    );

    if (!result.isOk || result.body == null) {
      throw Exception('heartbeat 전송 실패 (${result.statusCode})');
    }

    return HeartbeatResponse.fromJson(result.body!);
  }
}
