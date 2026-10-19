// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponse<T> _$ApiResponseFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_ApiResponse', json, ($checkedConvert) {
  final val = _ApiResponse<T>(
    data: $checkedConvert(
      'data',
      (v) => _$nullableGenericFromJson(v, fromJsonT),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseToJson<T>(
  _ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'data': _$nullableGenericToJson(instance.data, toJsonT)};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

_ApiListResponse<T> _$ApiListResponseFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_ApiListResponse', json, ($checkedConvert) {
  final val = _ApiListResponse<T>(
    errCode: $checkedConvert('errCode', (v) => v as String? ?? ''),
    errNo: $checkedConvert('errNo', (v) => v as String? ?? ''),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)?.map(fromJsonT).toList() ?? const [],
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiListResponseToJson<T>(
  _ApiListResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'errCode': instance.errCode,
  'errNo': instance.errNo,
  'data': instance.data.map(toJsonT).toList(),
};

_DynamicResponse _$DynamicResponseFromJson(Map json) =>
    $checkedCreate('_DynamicResponse', json, ($checkedConvert) {
      final val = _DynamicResponse(
        code: $checkedConvert('code', (v) => v as String),
        msg: $checkedConvert('msg', (v) => v as String),
        result: $checkedConvert('result', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$DynamicResponseToJson(_DynamicResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'result': instance.result,
    };
