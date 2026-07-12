// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulb.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Bulb {

 InternetAddress get ip; int get port; String? get mac; String? get model; String? get firmware; BulbState? get state; String? get alias; bool get isOnline; String? get lastSeenIp; DateTime? get lastSeen;
/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulbCopyWith<Bulb> get copyWith => _$BulbCopyWithImpl<Bulb>(this as Bulb, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bulb&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.port, port) || other.port == port)&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&(identical(other.state, state) || other.state == state)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenIp, lastSeenIp) || other.lastSeenIp == lastSeenIp)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}


@override
int get hashCode => Object.hash(runtimeType,ip,port,mac,model,firmware,state,alias,isOnline,lastSeenIp,lastSeen);

@override
String toString() {
  return 'Bulb(ip: $ip, port: $port, mac: $mac, model: $model, firmware: $firmware, state: $state, alias: $alias, isOnline: $isOnline, lastSeenIp: $lastSeenIp, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class $BulbCopyWith<$Res>  {
  factory $BulbCopyWith(Bulb value, $Res Function(Bulb) _then) = _$BulbCopyWithImpl;
@useResult
$Res call({
 InternetAddress ip, int port, String? mac, String? model, String? firmware, BulbState? state, String? alias, bool isOnline, String? lastSeenIp, DateTime? lastSeen
});


$BulbStateCopyWith<$Res>? get state;

}
/// @nodoc
class _$BulbCopyWithImpl<$Res>
    implements $BulbCopyWith<$Res> {
  _$BulbCopyWithImpl(this._self, this._then);

  final Bulb _self;
  final $Res Function(Bulb) _then;

/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? port = null,Object? mac = freezed,Object? model = freezed,Object? firmware = freezed,Object? state = freezed,Object? alias = freezed,Object? isOnline = null,Object? lastSeenIp = freezed,Object? lastSeen = freezed,}) {
  return _then(_self.copyWith(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as InternetAddress,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,mac: freezed == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as BulbState?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenIp: freezed == lastSeenIp ? _self.lastSeenIp : lastSeenIp // ignore: cast_nullable_to_non_nullable
as String?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BulbStateCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $BulbStateCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [Bulb].
extension BulbPatterns on Bulb {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bulb value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bulb() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bulb value)  $default,){
final _that = this;
switch (_that) {
case _Bulb():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bulb value)?  $default,){
final _that = this;
switch (_that) {
case _Bulb() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InternetAddress ip,  int port,  String? mac,  String? model,  String? firmware,  BulbState? state,  String? alias,  bool isOnline,  String? lastSeenIp,  DateTime? lastSeen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bulb() when $default != null:
return $default(_that.ip,_that.port,_that.mac,_that.model,_that.firmware,_that.state,_that.alias,_that.isOnline,_that.lastSeenIp,_that.lastSeen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InternetAddress ip,  int port,  String? mac,  String? model,  String? firmware,  BulbState? state,  String? alias,  bool isOnline,  String? lastSeenIp,  DateTime? lastSeen)  $default,) {final _that = this;
switch (_that) {
case _Bulb():
return $default(_that.ip,_that.port,_that.mac,_that.model,_that.firmware,_that.state,_that.alias,_that.isOnline,_that.lastSeenIp,_that.lastSeen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InternetAddress ip,  int port,  String? mac,  String? model,  String? firmware,  BulbState? state,  String? alias,  bool isOnline,  String? lastSeenIp,  DateTime? lastSeen)?  $default,) {final _that = this;
switch (_that) {
case _Bulb() when $default != null:
return $default(_that.ip,_that.port,_that.mac,_that.model,_that.firmware,_that.state,_that.alias,_that.isOnline,_that.lastSeenIp,_that.lastSeen);case _:
  return null;

}
}

}

/// @nodoc


class _Bulb extends Bulb {
  const _Bulb({required this.ip, this.port = 38899, this.mac, this.model, this.firmware, this.state, this.alias, this.isOnline = true, this.lastSeenIp, this.lastSeen}): super._();
  

@override final  InternetAddress ip;
@override@JsonKey() final  int port;
@override final  String? mac;
@override final  String? model;
@override final  String? firmware;
@override final  BulbState? state;
@override final  String? alias;
@override@JsonKey() final  bool isOnline;
@override final  String? lastSeenIp;
@override final  DateTime? lastSeen;

/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulbCopyWith<_Bulb> get copyWith => __$BulbCopyWithImpl<_Bulb>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bulb&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.port, port) || other.port == port)&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&(identical(other.state, state) || other.state == state)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenIp, lastSeenIp) || other.lastSeenIp == lastSeenIp)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}


@override
int get hashCode => Object.hash(runtimeType,ip,port,mac,model,firmware,state,alias,isOnline,lastSeenIp,lastSeen);

@override
String toString() {
  return 'Bulb(ip: $ip, port: $port, mac: $mac, model: $model, firmware: $firmware, state: $state, alias: $alias, isOnline: $isOnline, lastSeenIp: $lastSeenIp, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class _$BulbCopyWith<$Res> implements $BulbCopyWith<$Res> {
  factory _$BulbCopyWith(_Bulb value, $Res Function(_Bulb) _then) = __$BulbCopyWithImpl;
@override @useResult
$Res call({
 InternetAddress ip, int port, String? mac, String? model, String? firmware, BulbState? state, String? alias, bool isOnline, String? lastSeenIp, DateTime? lastSeen
});


@override $BulbStateCopyWith<$Res>? get state;

}
/// @nodoc
class __$BulbCopyWithImpl<$Res>
    implements _$BulbCopyWith<$Res> {
  __$BulbCopyWithImpl(this._self, this._then);

  final _Bulb _self;
  final $Res Function(_Bulb) _then;

/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? port = null,Object? mac = freezed,Object? model = freezed,Object? firmware = freezed,Object? state = freezed,Object? alias = freezed,Object? isOnline = null,Object? lastSeenIp = freezed,Object? lastSeen = freezed,}) {
  return _then(_Bulb(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as InternetAddress,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,mac: freezed == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as BulbState?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenIp: freezed == lastSeenIp ? _self.lastSeenIp : lastSeenIp // ignore: cast_nullable_to_non_nullable
as String?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Bulb
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BulbStateCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $BulbStateCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}

// dart format on
