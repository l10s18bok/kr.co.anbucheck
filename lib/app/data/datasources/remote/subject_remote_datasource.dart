import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 대상자 관련 원격 저장소 (보호자용)
class SubjectRemoteDatasource {
  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// GET /api/v1/subjects — 연결된 대상자 목록
  Future<Map<String, dynamic>> getSubjects(String deviceToken) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.subjects,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('대상자 목록 조회 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// POST /api/v1/subjects/link — 초대 코드로 대상자 연결
  Future<Map<String, dynamic>> linkSubject(
    String deviceToken,
    String inviteCode,
  ) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.subjectsLink,
      {'invite_code': inviteCode},
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('대상자 연결 실패 (${result.statusCode}): ${result.bodyString}');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// DELETE /api/v1/subjects/{guardian_id}/unlink — 대상자 연결 해제
  Future<void> unlinkSubject(String deviceToken, int guardianId) async {
    final result = await ApiClientFactory.instance.delete<dynamic>(
      ApiEndpoints.subjectUnlink(guardianId),
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('대상자 연결 해제 실패 (${result.statusCode})');
    }
  }

  /// PUT /api/v1/alerts/clear-all — 특정 대상자의 활성 경고 전부 해제
  Future<void> clearAllAlerts(String deviceToken, int subjectUserId) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.alertsClearAll,
      {'subject_user_id': subjectUserId},
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('경고 클리어 실패 (${result.statusCode})');
    }
  }
}
