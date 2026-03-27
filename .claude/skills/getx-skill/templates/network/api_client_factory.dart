import 'package:{{project_name}}/app/core/network/api_client.dart';
import 'package:{{project_name}}/app/core/network/api_connect.dart';
import 'package:{{project_name}}/app/core/network/dio_connect.dart';

enum HttpClientType { getConnect, dio }

/// ApiClient 싱글톤 팩토리
/// 앱 시작 시 한번 init하면, 이후 ApiClientFactory.instance로 접근
class ApiClientFactory {
  ApiClientFactory._();

  static ApiClient? _instance;

  /// 초기화 (main.dart에서 호출)
  static void init({HttpClientType type = HttpClientType.getConnect}) {
    _instance?.dispose();
    switch (type) {
      case HttpClientType.getConnect:
        _instance = GetConnectClient();
        break;
      case HttpClientType.dio:
        _instance = DioClient();
        break;
    }
  }

  /// 현재 ApiClient 인스턴스
  static ApiClient get instance {
    assert(_instance != null, 'ApiClientFactory.init()을 먼저 호출하세요.');
    return _instance!;
  }
}
