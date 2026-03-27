import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 사용자 등록 원격 저장소
/// POST /api/v1/users
class UserRemoteDatasource {
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
