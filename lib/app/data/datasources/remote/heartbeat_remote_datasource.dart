import 'dart:convert';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/data/models/heartbeat_request.dart';

/// heartbeat 전송 실패 — [statusCode]로 실패 **종류**를 구분한다.
///
///   - `null` → 연결 자체 실패(라우트 없음·DNS 실패 등, Dio `connectionError`/`unknown`).
///             수 ms 내 즉시 실패하며, 간격을 두고 재시도해도 같은 결과다.
///   - `408`  → 타임아웃. 망은 붙어 있으나 응답이 없음.
///   - 그 외  → 서버가 반환한 HTTP 오류.
///
/// ⚠️ 이 구분이 필요한 이유: Doze 유지보수 창이 **30초~1분**밖에 안 되므로
/// (`min_deep_maintenance_time=30s`, 실측 창 약 64초), 도달 불가 상태에서 5초·10초
/// 백오프를 쉬는 것은 창 예산만 태우고 성공 확률은 0이다. 창이 만료되면 워커가
/// `onStopJob`으로 즉시 종료되어 그 뒤의 재예약·마커 저장이 통째로 유실된다.
class HeartbeatSendException implements Exception {
  final int? statusCode;
  const HeartbeatSendException(this.statusCode);

  /// 연결 자체가 안 된 경우 — 백오프 없이 즉시 다음 시도로 넘어간다.
  bool get isUnreachable => statusCode == null;

  @override
  String toString() => 'HeartbeatSendException(statusCode: $statusCode)';
}

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
      throw HeartbeatSendException(result.statusCode);
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
