import 'package:get/get.dart';
import 'package:anbucheck/app/core/network/api_client.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/network/api_response.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// GetConnect 기반 ApiClient 구현체 (컴포지션 방식)
class GetConnectClient extends ApiClient {
  final _connect = _InternalGetConnect();

  /// GetConnect Response → 공통 ApiResult 변환
  ApiResult<T> _toApiResult<T>(Response<T> response) {
    return ApiResult<T>(
      statusCode: response.statusCode,
      body: response.body,
      bodyString: response.bodyString,
      isOk: response.isOk,
    );
  }

  @override
  Future<ApiResult<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doGet<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> post<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doPost<T>(
      url,
      body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doPut<T>(
      url,
      body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doDelete<T>(
      url,
      body: body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  void dispose() {
    _connect.dispose();
  }
}

/// 401 응답 시 로컬 데이터 초기화 + 모드 선택 화면 이동
/// 중복 호출 방지를 위한 플래그
bool _handlingUnauthorized = false;

Future<void> _handleUnauthorized() async {
  if (_handlingUnauthorized) return;
  _handlingUnauthorized = true;
  try {
    await HeartbeatWorkerService.cancel();
    await LocalAlarmService.cancel();
    await TokenLocalDatasource().clear();
    Get.offAllNamed(AppRoutes.modeSelect);
    Get.snackbar('', '계정 정보가 만료되었습니다. 다시 등록해 주세요.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3));
  } finally {
    _handlingUnauthorized = false;
  }
}

/// 내부 GetConnect 래퍼 (시그니처 충돌 방지)
class _InternalGetConnect extends GetConnect {
  dynamic _reqBody;

  _InternalGetConnect() {
    baseUrl = ApiEndpoints.baseUrl;
    timeout = ApiEndpoints.timeout;

    httpClient.addRequestModifier<dynamic>((request) {
      '************** Request **************'.printLog();
      'uri: ${request.url}'.printLog();
      'method: ${request.method}'.printLog();
      'headers:'.printLog();
      request.headers.forEach((key, v) => ' $key: $v'.printLog());
      'Request Body:'.printLog();
      if (_reqBody is Map) {
        _reqBody?.forEach((key, v) => ' $key: $v'.printLog());
      } else {
        _reqBody.toString().split('\n').forEach((l) => l.printLog());
      }
      '*************************************'.printLog();
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      '************** Response **************'.printLog();
      'uri: ${response.request!.url}'.printLog();
      'statusCode: ${response.statusCode}'.printLog();
      'Response Body:'.printLog();
      response.bodyString
          .toString()
          .split('\n')
          .forEach((l) => l.printLog());
      '*************************************'.printLog();

      // 401: 서버에서 계정 삭제됨 → 로컬 초기화 + 모드 선택 화면 이동
      if (response.statusCode == 401) {
        _handleUnauthorized();
      }

      return response;
    });
  }

  Future<Response<T>> doGet<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = query;
    return get<T>(url,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doPost<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = body;
    return post<T>(url, body,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doPut<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = body;
    return put<T>(url, body,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doDelete<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    if (query == null && body != null) {
      _reqBody = body;
      return httpClient.request<T>(
        url,
        'delete',
        body: body,
        headers: headers ?? {},
        contentType: contentType,
      )..whenComplete(() => _reqBody = null);
    }
    _reqBody = query;
    return delete<T>(url,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }
}
