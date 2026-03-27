import 'package:dio/dio.dart';
import 'package:{{project_name}}/app/core/network/api_client.dart';
import 'package:{{project_name}}/app/core/network/api_endpoints.dart';
import 'package:{{project_name}}/app/core/network/api_response.dart';
import 'package:{{project_name}}/app/core/utils/extensions.dart';

/// Dio 기반 ApiClient 구현체
class DioClient extends ApiClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.timeout,
      receiveTimeout: ApiEndpoints.timeout,
      contentType: 'application/json',
    ));

    // 로깅 인터셉터
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        '************** Request **************'.printLog();
        'uri: ${options.uri}'.printLog();
        'method: ${options.method}'.printLog();
        'headers:'.printLog();
        options.headers.forEach((key, v) => ' $key: $v'.printLog());
        'Request Body:'.printLog();
        '${options.data}'.printLog();
        '*************************************'.printLog();
        handler.next(options);
      },
      onResponse: (response, handler) {
        '************** Response **************'.printLog();
        'uri: ${response.requestOptions.uri}'.printLog();
        'statusCode: ${response.statusCode}'.printLog();
        'Response Body:'.printLog();
        '${response.data}'.printLog();
        '*************************************'.printLog();
        handler.next(response);
      },
      onError: (error, handler) {
        '************** Error **************'.printLog();
        'uri: ${error.requestOptions.uri}'.printLog();
        'message: ${error.message}'.printLog();
        '*************************************'.printLog();
        handler.next(error);
      },
    ));
  }

  /// Dio Response → 공통 ApiResult 변환
  ApiResult<T> _toApiResult<T>(Response response) {
    final statusCode = response.statusCode ?? 0;
    return ApiResult<T>(
      statusCode: statusCode,
      body: response.data as T?,
      bodyString: response.data is String
          ? response.data
          : response.data?.toString(),
      isOk: statusCode >= 200 && statusCode < 300,
    );
  }

  /// DioException → 공통 ApiResult 변환
  ApiResult<T> _errorToApiResult<T>(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const ApiResult(statusCode: null, isOk: false);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiResult(statusCode: 408, isOk: false);
    }
    if (e.response != null) {
      return _toApiResult<T>(e.response!);
    }
    return const ApiResult(statusCode: null, isOk: false);
  }

  @override
  Future<ApiResult<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: query,
        options: Options(
          headers: headers,
          contentType: contentType,
        ),
      );
      return _toApiResult<T>(response);
    } on DioException catch (e) {
      return _errorToApiResult<T>(e);
    }
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
    try {
      final response = await _dio.post(
        url,
        data: body,
        queryParameters: query,
        options: Options(
          headers: headers,
          contentType: contentType,
        ),
      );
      return _toApiResult<T>(response);
    } on DioException catch (e) {
      return _errorToApiResult<T>(e);
    }
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
    try {
      final response = await _dio.put(
        url,
        data: body,
        queryParameters: query,
        options: Options(
          headers: headers,
          contentType: contentType,
        ),
      );
      return _toApiResult<T>(response);
    } on DioException catch (e) {
      return _errorToApiResult<T>(e);
    }
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
    try {
      final response = await _dio.delete(
        url,
        data: body,
        queryParameters: query,
        options: Options(
          headers: headers,
          contentType: contentType,
        ),
      );
      return _toApiResult<T>(response);
    } on DioException catch (e) {
      return _errorToApiResult<T>(e);
    }
  }

  /// Dio 인스턴스 직접 접근 (고급 설정 필요 시)
  Dio get dio => _dio;

  @override
  void dispose() {
    _dio.close();
  }
}
