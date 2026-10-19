// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResponse<T> {

 T? get data;
/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResponseCopyWith<T, ApiResponse<T>> get copyWith => _$ApiResponseCopyWithImpl<T, ApiResponse<T>>(this as ApiResponse<T>, _$identity);

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as ApiResponse<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResponse<T>&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiResponse<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as ApiResponse<T>;
  return 'ApiResponse<$T>(data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $ApiResponseCopyWith<T,$Res>  {
  factory $ApiResponseCopyWith(ApiResponse<T> value, $Res Function(ApiResponse<T>) _then) = _$ApiResponseCopyWithImpl;
@useResult
$Res call({
 T? data
});




}
/// @nodoc
class _$ApiResponseCopyWithImpl<T,$Res>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._self, this._then);

  final ApiResponse<T> _self;
  final $Res Function(ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,}) {
  return _then(ApiResponse(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiResponse].
extension ApiResponsePatterns<T> on ApiResponse<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResponse<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResponse<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResponse<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data)  $default,) {final _that = this;
switch (_that) {
case _ApiResponse():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data)?  $default,) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiResponse<T> implements ApiResponse<T> {
  const _ApiResponse({this.data});
  factory _ApiResponse.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResponseFromJson(json,fromJsonT);

@override final  T? data;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResponseCopyWith<T, _ApiResponse<T>> get copyWith => __$ApiResponseCopyWithImpl<T, _ApiResponse<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResponseToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResponse<T>&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data));
}

@override
String toString() {
    return 'ApiResponse<$T>(data: $data)';
}


}

/// @nodoc
abstract mixin class _$ApiResponseCopyWith<T,$Res> implements $ApiResponseCopyWith<T, $Res> {
  factory _$ApiResponseCopyWith(_ApiResponse<T> value, $Res Function(_ApiResponse<T>) _then) = __$ApiResponseCopyWithImpl;
@override @useResult
$Res call({
 T? data
});




}
/// @nodoc
class __$ApiResponseCopyWithImpl<T,$Res>
    implements _$ApiResponseCopyWith<T, $Res> {
  __$ApiResponseCopyWithImpl(this._self, this._then);

  final _ApiResponse<T> _self;
  final $Res Function(_ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_ApiResponse<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}


/// @nodoc
mixin _$ApiListResponse<T> {

 String get errCode; String get errNo; List<T> get data;
/// Create a copy of ApiListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiListResponseCopyWith<T, ApiListResponse<T>> get copyWith => _$ApiListResponseCopyWithImpl<T, ApiListResponse<T>>(this as ApiListResponse<T>, _$identity);

  /// Serializes this ApiListResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as ApiListResponse<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiListResponse<T>&&(identical(other.errCode, _this.errCode) || other.errCode == _this.errCode)&&(identical(other.errNo, _this.errNo) || other.errNo == _this.errNo)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiListResponse<T>;
  return Object.hash(runtimeType,_this.errCode,_this.errNo,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as ApiListResponse<T>;
  return 'ApiListResponse<$T>(errCode: ${_this.errCode}, errNo: ${_this.errNo}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $ApiListResponseCopyWith<T,$Res>  {
  factory $ApiListResponseCopyWith(ApiListResponse<T> value, $Res Function(ApiListResponse<T>) _then) = _$ApiListResponseCopyWithImpl;
@useResult
$Res call({
 String errCode, String errNo, List<T> data
});




}
/// @nodoc
class _$ApiListResponseCopyWithImpl<T,$Res>
    implements $ApiListResponseCopyWith<T, $Res> {
  _$ApiListResponseCopyWithImpl(this._self, this._then);

  final ApiListResponse<T> _self;
  final $Res Function(ApiListResponse<T>) _then;

/// Create a copy of ApiListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? errCode = null,Object? errNo = null,Object? data = null,}) {
  return _then(ApiListResponse(
errCode: null == errCode ? _self.errCode : errCode // ignore: cast_nullable_to_non_nullable
as String,errNo: null == errNo ? _self.errNo : errNo // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<T>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiListResponse].
extension ApiListResponsePatterns<T> on ApiListResponse<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiListResponse<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiListResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiListResponse<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiListResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiListResponse<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiListResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String errCode,  String errNo,  List<T> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiListResponse() when $default != null:
return $default(_that.errCode,_that.errNo,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String errCode,  String errNo,  List<T> data)  $default,) {final _that = this;
switch (_that) {
case _ApiListResponse():
return $default(_that.errCode,_that.errNo,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String errCode,  String errNo,  List<T> data)?  $default,) {final _that = this;
switch (_that) {
case _ApiListResponse() when $default != null:
return $default(_that.errCode,_that.errNo,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiListResponse<T> implements ApiListResponse<T> {
  const _ApiListResponse({this.errCode = '', this.errNo = '',  List<T> data = const []}): _data = data;
  factory _ApiListResponse.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiListResponseFromJson(json,fromJsonT);

@override@JsonKey() final  String errCode;
@override@JsonKey() final  String errNo;
 final  List<T> _data;
@override@JsonKey() List<T> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of ApiListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiListResponseCopyWith<T, _ApiListResponse<T>> get copyWith => __$ApiListResponseCopyWithImpl<T, _ApiListResponse<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiListResponseToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiListResponse<T>&&(identical(other.errCode, errCode) || other.errCode == errCode)&&(identical(other.errNo, errNo) || other.errNo == errNo)&&const DeepCollectionEquality().equals(other.data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,errCode,errNo,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'ApiListResponse<$T>(errCode: $errCode, errNo: $errNo, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ApiListResponseCopyWith<T,$Res> implements $ApiListResponseCopyWith<T, $Res> {
  factory _$ApiListResponseCopyWith(_ApiListResponse<T> value, $Res Function(_ApiListResponse<T>) _then) = __$ApiListResponseCopyWithImpl;
@override @useResult
$Res call({
 String errCode, String errNo, List<T> data
});




}
/// @nodoc
class __$ApiListResponseCopyWithImpl<T,$Res>
    implements _$ApiListResponseCopyWith<T, $Res> {
  __$ApiListResponseCopyWithImpl(this._self, this._then);

  final _ApiListResponse<T> _self;
  final $Res Function(_ApiListResponse<T>) _then;

/// Create a copy of ApiListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? errCode = null,Object? errNo = null,Object? data = null,}) {
  return _then(_ApiListResponse<T>(
errCode: null == errCode ? _self.errCode : errCode // ignore: cast_nullable_to_non_nullable
as String,errNo: null == errNo ? _self.errNo : errNo // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<T>,
  ));
}


}


/// @nodoc
mixin _$DynamicResponse {

 String get code; String get msg; dynamic get result;
/// Create a copy of DynamicResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicResponseCopyWith<DynamicResponse> get copyWith => _$DynamicResponseCopyWithImpl<DynamicResponse>(this as DynamicResponse, _$identity);

  /// Serializes this DynamicResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DynamicResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicResponse&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.msg, _this.msg) || other.msg == _this.msg)&&const DeepCollectionEquality().equals(other.result, _this.result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DynamicResponse;
  return Object.hash(runtimeType,_this.code,_this.msg,const DeepCollectionEquality().hash(_this.result));
}

@override
String toString() {
  final _this = this as DynamicResponse;
  return 'DynamicResponse(code: ${_this.code}, msg: ${_this.msg}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $DynamicResponseCopyWith<$Res>  {
  factory $DynamicResponseCopyWith(DynamicResponse value, $Res Function(DynamicResponse) _then) = _$DynamicResponseCopyWithImpl;
@useResult
$Res call({
 String code, String msg, dynamic result
});




}
/// @nodoc
class _$DynamicResponseCopyWithImpl<$Res>
    implements $DynamicResponseCopyWith<$Res> {
  _$DynamicResponseCopyWithImpl(this._self, this._then);

  final DynamicResponse _self;
  final $Res Function(DynamicResponse) _then;

/// Create a copy of DynamicResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? msg = null,Object? result = freezed,}) {
  return _then(DynamicResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [DynamicResponse].
extension DynamicResponsePatterns on DynamicResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DynamicResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DynamicResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DynamicResponse value)  $default,){
final _that = this;
switch (_that) {
case _DynamicResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DynamicResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DynamicResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String msg,  dynamic result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DynamicResponse() when $default != null:
return $default(_that.code,_that.msg,_that.result);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String msg,  dynamic result)  $default,) {final _that = this;
switch (_that) {
case _DynamicResponse():
return $default(_that.code,_that.msg,_that.result);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String msg,  dynamic result)?  $default,) {final _that = this;
switch (_that) {
case _DynamicResponse() when $default != null:
return $default(_that.code,_that.msg,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DynamicResponse implements DynamicResponse {
  const _DynamicResponse({required this.code, required this.msg, required this.result});
  factory _DynamicResponse.fromJson(Map<String, dynamic> json) => _$DynamicResponseFromJson(json);

@override final  String code;
@override final  String msg;
@override final  dynamic result;

/// Create a copy of DynamicResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DynamicResponseCopyWith<_DynamicResponse> get copyWith => __$DynamicResponseCopyWithImpl<_DynamicResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DynamicResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DynamicResponse&&(identical(other.code, code) || other.code == code)&&(identical(other.msg, msg) || other.msg == msg)&&const DeepCollectionEquality().equals(other.result, result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,msg,const DeepCollectionEquality().hash(result));
}

@override
String toString() {
    return 'DynamicResponse(code: $code, msg: $msg, result: $result)';
}


}

/// @nodoc
abstract mixin class _$DynamicResponseCopyWith<$Res> implements $DynamicResponseCopyWith<$Res> {
  factory _$DynamicResponseCopyWith(_DynamicResponse value, $Res Function(_DynamicResponse) _then) = __$DynamicResponseCopyWithImpl;
@override @useResult
$Res call({
 String code, String msg, dynamic result
});




}
/// @nodoc
class __$DynamicResponseCopyWithImpl<$Res>
    implements _$DynamicResponseCopyWith<$Res> {
  __$DynamicResponseCopyWithImpl(this._self, this._then);

  final _DynamicResponse _self;
  final $Res Function(_DynamicResponse) _then;

/// Create a copy of DynamicResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? msg = null,Object? result = freezed,}) {
  return _then(_DynamicResponse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
