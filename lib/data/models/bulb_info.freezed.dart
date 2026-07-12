// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulb_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BulbInfo {

 String get mac; String? get model; String? get firmware;
/// Create a copy of BulbInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulbInfoCopyWith<BulbInfo> get copyWith => _$BulbInfoCopyWithImpl<BulbInfo>(this as BulbInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulbInfo&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware));
}


@override
int get hashCode => Object.hash(runtimeType,mac,model,firmware);

@override
String toString() {
  return 'BulbInfo(mac: $mac, model: $model, firmware: $firmware)';
}


}

/// @nodoc
abstract mixin class $BulbInfoCopyWith<$Res>  {
  factory $BulbInfoCopyWith(BulbInfo value, $Res Function(BulbInfo) _then) = _$BulbInfoCopyWithImpl;
@useResult
$Res call({
 String mac, String? model, String? firmware
});




}
/// @nodoc
class _$BulbInfoCopyWithImpl<$Res>
    implements $BulbInfoCopyWith<$Res> {
  _$BulbInfoCopyWithImpl(this._self, this._then);

  final BulbInfo _self;
  final $Res Function(BulbInfo) _then;

/// Create a copy of BulbInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mac = null,Object? model = freezed,Object? firmware = freezed,}) {
  return _then(_self.copyWith(
mac: null == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BulbInfo].
extension BulbInfoPatterns on BulbInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulbInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulbInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulbInfo value)  $default,){
final _that = this;
switch (_that) {
case _BulbInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulbInfo value)?  $default,){
final _that = this;
switch (_that) {
case _BulbInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mac,  String? model,  String? firmware)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulbInfo() when $default != null:
return $default(_that.mac,_that.model,_that.firmware);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mac,  String? model,  String? firmware)  $default,) {final _that = this;
switch (_that) {
case _BulbInfo():
return $default(_that.mac,_that.model,_that.firmware);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mac,  String? model,  String? firmware)?  $default,) {final _that = this;
switch (_that) {
case _BulbInfo() when $default != null:
return $default(_that.mac,_that.model,_that.firmware);case _:
  return null;

}
}

}

/// @nodoc


class _BulbInfo implements BulbInfo {
  const _BulbInfo({required this.mac, this.model, this.firmware});
  

@override final  String mac;
@override final  String? model;
@override final  String? firmware;

/// Create a copy of BulbInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulbInfoCopyWith<_BulbInfo> get copyWith => __$BulbInfoCopyWithImpl<_BulbInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulbInfo&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware));
}


@override
int get hashCode => Object.hash(runtimeType,mac,model,firmware);

@override
String toString() {
  return 'BulbInfo(mac: $mac, model: $model, firmware: $firmware)';
}


}

/// @nodoc
abstract mixin class _$BulbInfoCopyWith<$Res> implements $BulbInfoCopyWith<$Res> {
  factory _$BulbInfoCopyWith(_BulbInfo value, $Res Function(_BulbInfo) _then) = __$BulbInfoCopyWithImpl;
@override @useResult
$Res call({
 String mac, String? model, String? firmware
});




}
/// @nodoc
class __$BulbInfoCopyWithImpl<$Res>
    implements _$BulbInfoCopyWith<$Res> {
  __$BulbInfoCopyWithImpl(this._self, this._then);

  final _BulbInfo _self;
  final $Res Function(_BulbInfo) _then;

/// Create a copy of BulbInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mac = null,Object? model = freezed,Object? firmware = freezed,}) {
  return _then(_BulbInfo(
mac: null == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
