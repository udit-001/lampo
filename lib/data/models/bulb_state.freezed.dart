// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulb_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BulbState {

 bool get on; int? get r; int? get g; int? get b; int? get c; int? get w; int? get temp; int? get dimming; int? get sceneId; int? get speed; int? get rssi;
/// Create a copy of BulbState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulbStateCopyWith<BulbState> get copyWith => _$BulbStateCopyWithImpl<BulbState>(this as BulbState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulbState&&(identical(other.on, on) || other.on == on)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.w, w) || other.w == w)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.rssi, rssi) || other.rssi == rssi));
}


@override
int get hashCode => Object.hash(runtimeType,on,r,g,b,c,w,temp,dimming,sceneId,speed,rssi);

@override
String toString() {
  return 'BulbState(on: $on, r: $r, g: $g, b: $b, c: $c, w: $w, temp: $temp, dimming: $dimming, sceneId: $sceneId, speed: $speed, rssi: $rssi)';
}


}

/// @nodoc
abstract mixin class $BulbStateCopyWith<$Res>  {
  factory $BulbStateCopyWith(BulbState value, $Res Function(BulbState) _then) = _$BulbStateCopyWithImpl;
@useResult
$Res call({
 bool on, int? r, int? g, int? b, int? c, int? w, int? temp, int? dimming, int? sceneId, int? speed, int? rssi
});




}
/// @nodoc
class _$BulbStateCopyWithImpl<$Res>
    implements $BulbStateCopyWith<$Res> {
  _$BulbStateCopyWithImpl(this._self, this._then);

  final BulbState _self;
  final $Res Function(BulbState) _then;

/// Create a copy of BulbState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? on = null,Object? r = freezed,Object? g = freezed,Object? b = freezed,Object? c = freezed,Object? w = freezed,Object? temp = freezed,Object? dimming = freezed,Object? sceneId = freezed,Object? speed = freezed,Object? rssi = freezed,}) {
  return _then(_self.copyWith(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,r: freezed == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int?,g: freezed == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int?,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int?,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as int?,w: freezed == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as int?,temp: freezed == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int?,dimming: freezed == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int?,rssi: freezed == rssi ? _self.rssi : rssi // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BulbState].
extension BulbStatePatterns on BulbState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulbState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulbState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulbState value)  $default,){
final _that = this;
switch (_that) {
case _BulbState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulbState value)?  $default,){
final _that = this;
switch (_that) {
case _BulbState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed,  int? rssi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulbState() when $default != null:
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed,_that.rssi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed,  int? rssi)  $default,) {final _that = this;
switch (_that) {
case _BulbState():
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed,_that.rssi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed,  int? rssi)?  $default,) {final _that = this;
switch (_that) {
case _BulbState() when $default != null:
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed,_that.rssi);case _:
  return null;

}
}

}

/// @nodoc


class _BulbState extends BulbState {
  const _BulbState({this.on = false, this.r, this.g, this.b, this.c, this.w, this.temp, this.dimming, this.sceneId, this.speed, this.rssi}): super._();
  

@override@JsonKey() final  bool on;
@override final  int? r;
@override final  int? g;
@override final  int? b;
@override final  int? c;
@override final  int? w;
@override final  int? temp;
@override final  int? dimming;
@override final  int? sceneId;
@override final  int? speed;
@override final  int? rssi;

/// Create a copy of BulbState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulbStateCopyWith<_BulbState> get copyWith => __$BulbStateCopyWithImpl<_BulbState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulbState&&(identical(other.on, on) || other.on == on)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.w, w) || other.w == w)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.rssi, rssi) || other.rssi == rssi));
}


@override
int get hashCode => Object.hash(runtimeType,on,r,g,b,c,w,temp,dimming,sceneId,speed,rssi);

@override
String toString() {
  return 'BulbState(on: $on, r: $r, g: $g, b: $b, c: $c, w: $w, temp: $temp, dimming: $dimming, sceneId: $sceneId, speed: $speed, rssi: $rssi)';
}


}

/// @nodoc
abstract mixin class _$BulbStateCopyWith<$Res> implements $BulbStateCopyWith<$Res> {
  factory _$BulbStateCopyWith(_BulbState value, $Res Function(_BulbState) _then) = __$BulbStateCopyWithImpl;
@override @useResult
$Res call({
 bool on, int? r, int? g, int? b, int? c, int? w, int? temp, int? dimming, int? sceneId, int? speed, int? rssi
});




}
/// @nodoc
class __$BulbStateCopyWithImpl<$Res>
    implements _$BulbStateCopyWith<$Res> {
  __$BulbStateCopyWithImpl(this._self, this._then);

  final _BulbState _self;
  final $Res Function(_BulbState) _then;

/// Create a copy of BulbState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? on = null,Object? r = freezed,Object? g = freezed,Object? b = freezed,Object? c = freezed,Object? w = freezed,Object? temp = freezed,Object? dimming = freezed,Object? sceneId = freezed,Object? speed = freezed,Object? rssi = freezed,}) {
  return _then(_BulbState(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,r: freezed == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int?,g: freezed == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int?,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int?,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as int?,w: freezed == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as int?,temp: freezed == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int?,dimming: freezed == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int?,rssi: freezed == rssi ? _self.rssi : rssi // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
