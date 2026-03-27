import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 앱 버전 체크 원격 저장소
class VersionRemoteDatasource {
  /// GET /api/v1/app/version-check
  /// 서버 응답 실패 시 null 반환 — 앱은 계속 정상 진행
  Future<Map<String, dynamic>?> checkVersion(
    String platform,
    String currentVersion,
  ) async {
    try {
      final result = await ApiClientFactory.instance.get<dynamic>(
        ApiEndpoints.versionCheck,
        query: {'platform': platform, 'current_version': currentVersion},
      );
      if (!result.isOk) return null;
      return Map<String, dynamic>.from(result.body as Map);
    } catch (_) {
      return null;
    }
  }
}
