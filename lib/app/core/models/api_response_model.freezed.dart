// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object?) fromJsonT,
) {
  return _ApiResponse<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$ApiResponse<T> {
  T? get data => throw _privateConstructorUsedError;

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiResponseCopyWith<T, ApiResponse<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiResponseCopyWith<T, $Res> {
  factory $ApiResponseCopyWith(
    ApiResponse<T> value,
    $Res Function(ApiResponse<T>) then,
  ) = _$ApiResponseCopyWithImpl<T, $Res, ApiResponse<T>>;
  @useResult
  $Res call({T? data});
}

/// @nodoc
class _$ApiResponseCopyWithImpl<T, $Res, $Val extends ApiResponse<T>>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _value.copyWith(
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as T?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiResponseImplCopyWith<T, $Res>
    implements $ApiResponseCopyWith<T, $Res> {
  factory _$$ApiResponseImplCopyWith(
    _$ApiResponseImpl<T> value,
    $Res Function(_$ApiResponseImpl<T>) then,
  ) = __$$ApiResponseImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data});
}

/// @nodoc
class __$$ApiResponseImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$ApiResponseImpl<T>>
    implements _$$ApiResponseImplCopyWith<T, $Res> {
  __$$ApiResponseImplCopyWithImpl(
    _$ApiResponseImpl<T> _value,
    $Res Function(_$ApiResponseImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed}) {
    return _then(
      _$ApiResponseImpl<T>(
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as T?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$ApiResponseImpl<T> implements _ApiResponse<T> {
  const _$ApiResponseImpl({this.data});

  factory _$ApiResponseImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$ApiResponseImplFromJson(json, fromJsonT);

  @override
  final T? data;

  @override
  String toString() {
    return 'ApiResponse<$T>(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiResponseImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiResponseImplCopyWith<T, _$ApiResponseImpl<T>> get copyWith =>
      __$$ApiResponseImplCopyWithImpl<T, _$ApiResponseImpl<T>>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$ApiResponseImplToJson<T>(this, toJsonT);
  }
}

abstract class _ApiResponse<T> implements ApiResponse<T> {
  const factory _ApiResponse({final T? data}) = _$ApiResponseImpl<T>;

  factory _ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$ApiResponseImpl<T>.fromJson;

  @override
  T? get data;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiResponseImplCopyWith<T, _$ApiResponseImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiListResponse<T> _$ApiListResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object?) fromJsonT,
) {
  return _ApiListResponse<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$ApiListResponse<T> {
  String get errCode => throw _privateConstructorUsedError;
  String get errNo => throw _privateConstructorUsedError;
  List<T> get data => throw _privateConstructorUsedError;

  /// Serializes this ApiListResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ApiListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiListResponseCopyWith<T, ApiListResponse<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiListResponseCopyWith<T, $Res> {
  factory $ApiListResponseCopyWith(
    ApiListResponse<T> value,
    $Res Function(ApiListResponse<T>) then,
  ) = _$ApiListResponseCopyWithImpl<T, $Res, ApiListResponse<T>>;
  @useResult
  $Res call({String errCode, String errNo, List<T> data});
}

/// @nodoc
class _$ApiListResponseCopyWithImpl<T, $Res, $Val extends ApiListResponse<T>>
    implements $ApiListResponseCopyWith<T, $Res> {
  _$ApiListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errCode = null,
    Object? errNo = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            errCode: null == errCode
                ? _value.errCode
                : errCode // ignore: cast_nullable_to_non_nullable
                      as String,
            errNo: null == errNo
                ? _value.errNo
                : errNo // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<T>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiListResponseImplCopyWith<T, $Res>
    implements $ApiListResponseCopyWith<T, $Res> {
  factory _$$ApiListResponseImplCopyWith(
    _$ApiListResponseImpl<T> value,
    $Res Function(_$ApiListResponseImpl<T>) then,
  ) = __$$ApiListResponseImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({String errCode, String errNo, List<T> data});
}

/// @nodoc
class __$$ApiListResponseImplCopyWithImpl<T, $Res>
    extends _$ApiListResponseCopyWithImpl<T, $Res, _$ApiListResponseImpl<T>>
    implements _$$ApiListResponseImplCopyWith<T, $Res> {
  __$$ApiListResponseImplCopyWithImpl(
    _$ApiListResponseImpl<T> _value,
    $Res Function(_$ApiListResponseImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errCode = null,
    Object? errNo = null,
    Object? data = null,
  }) {
    return _then(
      _$ApiListResponseImpl<T>(
        errCode: null == errCode
            ? _value.errCode
            : errCode // ignore: cast_nullable_to_non_nullable
                  as String,
        errNo: null == errNo
            ? _value.errNo
            : errNo // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<T>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$ApiListResponseImpl<T> implements _ApiListResponse<T> {
  const _$ApiListResponseImpl({
    this.errCode = '',
    this.errNo = '',
    final List<T> data = const [],
  }) : _data = data;

  factory _$ApiListResponseImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$ApiListResponseImplFromJson(json, fromJsonT);

  @override
  @JsonKey()
  final String errCode;
  @override
  @JsonKey()
  final String errNo;
  final List<T> _data;
  @override
  @JsonKey()
  List<T> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'ApiListResponse<$T>(errCode: $errCode, errNo: $errNo, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiListResponseImpl<T> &&
            (identical(other.errCode, errCode) || other.errCode == errCode) &&
            (identical(other.errNo, errNo) || other.errNo == errNo) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    errCode,
    errNo,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of ApiListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiListResponseImplCopyWith<T, _$ApiListResponseImpl<T>> get copyWith =>
      __$$ApiListResponseImplCopyWithImpl<T, _$ApiListResponseImpl<T>>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$ApiListResponseImplToJson<T>(this, toJsonT);
  }
}

abstract class _ApiListResponse<T> implements ApiListResponse<T> {
  const factory _ApiListResponse({
    final String errCode,
    final String errNo,
    final List<T> data,
  }) = _$ApiListResponseImpl<T>;

  factory _ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$ApiListResponseImpl<T>.fromJson;

  @override
  String get errCode;
  @override
  String get errNo;
  @override
  List<T> get data;

  /// Create a copy of ApiListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiListResponseImplCopyWith<T, _$ApiListResponseImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

DynamicResponse _$DynamicResponseFromJson(Map<String, dynamic> json) {
  return _DynamicResponse.fromJson(json);
}

/// @nodoc
mixin _$DynamicResponse {
  String get code => throw _privateConstructorUsedError;
  String get msg => throw _privateConstructorUsedError;
  dynamic get result => throw _privateConstructorUsedError;

  /// Serializes this DynamicResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DynamicResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DynamicResponseCopyWith<DynamicResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DynamicResponseCopyWith<$Res> {
  factory $DynamicResponseCopyWith(
    DynamicResponse value,
    $Res Function(DynamicResponse) then,
  ) = _$DynamicResponseCopyWithImpl<$Res, DynamicResponse>;
  @useResult
  $Res call({String code, String msg, dynamic result});
}

/// @nodoc
class _$DynamicResponseCopyWithImpl<$Res, $Val extends DynamicResponse>
    implements $DynamicResponseCopyWith<$Res> {
  _$DynamicResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DynamicResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? msg = null,
    Object? result = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            msg: null == msg
                ? _value.msg
                : msg // ignore: cast_nullable_to_non_nullable
                      as String,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DynamicResponseImplCopyWith<$Res>
    implements $DynamicResponseCopyWith<$Res> {
  factory _$$DynamicResponseImplCopyWith(
    _$DynamicResponseImpl value,
    $Res Function(_$DynamicResponseImpl) then,
  ) = __$$DynamicResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String msg, dynamic result});
}

/// @nodoc
class __$$DynamicResponseImplCopyWithImpl<$Res>
    extends _$DynamicResponseCopyWithImpl<$Res, _$DynamicResponseImpl>
    implements _$$DynamicResponseImplCopyWith<$Res> {
  __$$DynamicResponseImplCopyWithImpl(
    _$DynamicResponseImpl _value,
    $Res Function(_$DynamicResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DynamicResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? msg = null,
    Object? result = freezed,
  }) {
    return _then(
      _$DynamicResponseImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        msg: null == msg
            ? _value.msg
            : msg // ignore: cast_nullable_to_non_nullable
                  as String,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DynamicResponseImpl implements _DynamicResponse {
  const _$DynamicResponseImpl({
    required this.code,
    required this.msg,
    required this.result,
  });

  factory _$DynamicResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DynamicResponseImplFromJson(json);

  @override
  final String code;
  @override
  final String msg;
  @override
  final dynamic result;

  @override
  String toString() {
    return 'DynamicResponse(code: $code, msg: $msg, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DynamicResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.msg, msg) || other.msg == msg) &&
            const DeepCollectionEquality().equals(other.result, result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    msg,
    const DeepCollectionEquality().hash(result),
  );

  /// Create a copy of DynamicResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DynamicResponseImplCopyWith<_$DynamicResponseImpl> get copyWith =>
      __$$DynamicResponseImplCopyWithImpl<_$DynamicResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DynamicResponseImplToJson(this);
  }
}

abstract class _DynamicResponse implements DynamicResponse {
  const factory _DynamicResponse({
    required final String code,
    required final String msg,
    required final dynamic result,
  }) = _$DynamicResponseImpl;

  factory _DynamicResponse.fromJson(Map<String, dynamic> json) =
      _$DynamicResponseImpl.fromJson;

  @override
  String get code;
  @override
  String get msg;
  @override
  dynamic get result;

  /// Create a copy of DynamicResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DynamicResponseImplCopyWith<_$DynamicResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
