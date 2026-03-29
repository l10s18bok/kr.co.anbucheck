import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 사용자 등록/삭제 원격 저장소
class UserRemoteDatasource {
  /// DELETE /api/v1/users/me — 계정 및 관련 데이터 전체 삭제 (모드 변경 시)
  Future<void> deleteMe(String deviceToken) async {
    final result = await ApiClientFactory.instance.delete<void>(
      '${ApiEndpoints.users}/me',
      headers: {'Authorization': 'Bearer $deviceToken'},
    );
    if (!result.isOk && result.statusCode != 204) {
      throw Exception('계정 삭제 실패 (${result.statusCode})');
    }
  }

  /// POST /api/v1/users
  Future<Map<String, dynamic>> register({
    required String role,
    required String deviceId,
    required String fcmToken,
    required String platform,
    String osVersion = '',
  }) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.users,
      {
        'role': role,
        'device': {
          'device_id': deviceId,
          'fcm_token': fcmToken,
          'platform': platform,
          'os_version': osVersion,
        },
      },
    );
    if (!result.isOk) {
      throw Exception('사용자 등록 실패 (${result.statusCode}): ${result.bodyString}');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }
}
