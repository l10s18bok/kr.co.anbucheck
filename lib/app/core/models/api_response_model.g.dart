// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseImpl<T> _$$ApiResponseImplFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate(r'_$ApiResponseImpl', json, ($checkedConvert) {
  final val = _$ApiResponseImpl<T>(
    data: $checkedConvert(
      'data',
      (v) => _$nullableGenericFromJson(v, fromJsonT),
    ),
  );
  return val;
});

Map<String, dynamic> _$$ApiResponseImplToJson<T>(
  _$ApiResponseImpl<T> instance,
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

_$ApiListResponseImpl<T> _$$ApiListResponseImplFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate(r'_$ApiListResponseImpl', json, ($checkedConvert) {
  final val = _$ApiListResponseImpl<T>(
    errCode: $checkedConvert('errCode', (v) => v as String? ?? ''),
    errNo: $checkedConvert('errNo', (v) => v as String? ?? ''),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)?.map(fromJsonT).toList() ?? const [],
    ),
  );
  return val;
});

Map<String, dynamic> _$$ApiListResponseImplToJson<T>(
  _$ApiListResponseImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'errCode': instance.errCode,
  'errNo': instance.errNo,
  'data': instance.data.map(toJsonT).toList(),
};

_$DynamicResponseImpl _$$DynamicResponseImplFromJson(Map json) =>
    $checkedCreate(r'_$DynamicResponseImpl', json, ($checkedConvert) {
      final val = _$DynamicResponseImpl(
        code: $checkedConvert('code', (v) => v as String),
        msg: $checkedConvert('msg', (v) => v as String),
        result: $checkedConvert('result', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$$DynamicResponseImplToJson(
  _$DynamicResponseImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'result': instance.result,
};
