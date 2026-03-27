import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/network/api_client.dart';
import 'package:{{project_name}}/app/core/network/api_endpoints.dart';
import 'package:{{project_name}}/app/core/network/api_response.dart';
import 'package:{{project_name}}/app/core/utils/extensions.dart';

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
