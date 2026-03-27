import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response_model.freezed.dart';
part 'api_response_model.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    T? data,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class ApiListResponse<T> with _$ApiListResponse<T> {
  const factory ApiListResponse({
    @Default('') String errCode,
    @Default('') String errNo,
    @Default([]) List<T> data,
  }) = _ApiListResponse;

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiListResponseFromJson(json, fromJsonT);
}

@freezed
class DynamicResponse with _$DynamicResponse {
  const factory DynamicResponse({
    required String code,
    required String msg,
    required dynamic result,
  }) = _DynamicResponse;

  factory DynamicResponse.fromJson(Map<String, dynamic> json) =>
      _$DynamicResponseFromJson(json);
}
