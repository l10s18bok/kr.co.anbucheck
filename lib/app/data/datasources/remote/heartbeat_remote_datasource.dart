import 'dart:convert';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';

/// POST /api/v1/heartbeat
class HeartbeatRemoteDatasource {
  final Map<String, String> _auth;

  HeartbeatRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  Future<HeartbeatResponse> send(HeartbeatRequest request) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.heartbeat,
      request.toJson(),
      headers: _auth,
    );

    if (!result.isOk) {
      throw Exception('heartbeat 전송 실패 (${result.statusCode})');
    }

    final body = result.body;
    final Map<String, dynamic> json;
    if (body is Map<String, dynamic>) {
      json = body;
    } else if (body is String) {
      json = jsonDecode(body) as Map<String, dynamic>;
    } else {
      throw Exception('heartbeat 응답 파싱 실패: ${body.runtimeType}');
    }

    return HeartbeatResponse.fromJson(json);
  }
}
