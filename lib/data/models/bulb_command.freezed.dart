// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulb_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BulbCommand {

 bool? get on; int? get r; int? get g; int? get b; int? get c; int? get w; int? get temp; int? get dimming; int? get sceneId; int? get speed;
/// Create a copy of BulbCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulbCommandCopyWith<BulbCommand> get copyWith => _$BulbCommandCopyWithImpl<BulbCommand>(this as BulbCommand, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulbCommand&&(identical(other.on, on) || other.on == on)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.w, w) || other.w == w)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.speed, speed) || other.speed == speed));
}


@override
int get hashCode => Object.hash(runtimeType,on,r,g,b,c,w,temp,dimming,sceneId,speed);

@override
String toString() {
  return 'BulbCommand(on: $on, r: $r, g: $g, b: $b, c: $c, w: $w, temp: $temp, dimming: $dimming, sceneId: $sceneId, speed: $speed)';
}


}

/// @nodoc
abstract mixin class $BulbCommandCopyWith<$Res>  {
  factory $BulbCommandCopyWith(BulbCommand value, $Res Function(BulbCommand) _then) = _$BulbCommandCopyWithImpl;
@useResult
$Res call({
 bool? on, int? r, int? g, int? b, int? c, int? w, int? temp, int? dimming, int? sceneId, int? speed
});




}
/// @nodoc
class _$BulbCommandCopyWithImpl<$Res>
    implements $BulbCommandCopyWith<$Res> {
  _$BulbCommandCopyWithImpl(this._self, this._then);

  final BulbCommand _self;
  final $Res Function(BulbCommand) _then;

/// Create a copy of BulbCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? on = freezed,Object? r = freezed,Object? g = freezed,Object? b = freezed,Object? c = freezed,Object? w = freezed,Object? temp = freezed,Object? dimming = freezed,Object? sceneId = freezed,Object? speed = freezed,}) {
  return _then(_self.copyWith(
on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool?,r: freezed == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int?,g: freezed == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int?,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int?,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as int?,w: freezed == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as int?,temp: freezed == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int?,dimming: freezed == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BulbCommand].
extension BulbCommandPatterns on BulbCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulbCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulbCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulbCommand value)  $default,){
final _that = this;
switch (_that) {
case _BulbCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulbCommand value)?  $default,){
final _that = this;
switch (_that) {
case _BulbCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulbCommand() when $default != null:
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed)  $default,) {final _that = this;
switch (_that) {
case _BulbCommand():
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? on,  int? r,  int? g,  int? b,  int? c,  int? w,  int? temp,  int? dimming,  int? sceneId,  int? speed)?  $default,) {final _that = this;
switch (_that) {
case _BulbCommand() when $default != null:
return $default(_that.on,_that.r,_that.g,_that.b,_that.c,_that.w,_that.temp,_that.dimming,_that.sceneId,_that.speed);case _:
  return null;

}
}

}

/// @nodoc


class _BulbCommand extends BulbCommand {
  const _BulbCommand({this.on, this.r, this.g, this.b, this.c, this.w, this.temp, this.dimming, this.sceneId, this.speed}): super._();
  

@override final  bool? on;
@override final  int? r;
@override final  int? g;
@override final  int? b;
@override final  int? c;
@override final  int? w;
@override final  int? temp;
@override final  int? dimming;
@override final  int? sceneId;
@override final  int? speed;

/// Create a copy of BulbCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulbCommandCopyWith<_BulbCommand> get copyWith => __$BulbCommandCopyWithImpl<_BulbCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulbCommand&&(identical(other.on, on) || other.on == on)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.c, c) || other.c == c)&&(identical(other.w, w) || other.w == w)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.dimming, dimming) || other.dimming == dimming)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.speed, speed) || other.speed == speed));
}


@override
int get hashCode => Object.hash(runtimeType,on,r,g,b,c,w,temp,dimming,sceneId,speed);

@override
String toString() {
  return 'BulbCommand(on: $on, r: $r, g: $g, b: $b, c: $c, w: $w, temp: $temp, dimming: $dimming, sceneId: $sceneId, speed: $speed)';
}


}

/// @nodoc
abstract mixin class _$BulbCommandCopyWith<$Res> implements $BulbCommandCopyWith<$Res> {
  factory _$BulbCommandCopyWith(_BulbCommand value, $Res Function(_BulbCommand) _then) = __$BulbCommandCopyWithImpl;
@override @useResult
$Res call({
 bool? on, int? r, int? g, int? b, int? c, int? w, int? temp, int? dimming, int? sceneId, int? speed
});




}
/// @nodoc
class __$BulbCommandCopyWithImpl<$Res>
    implements _$BulbCommandCopyWith<$Res> {
  __$BulbCommandCopyWithImpl(this._self, this._then);

  final _BulbCommand _self;
  final $Res Function(_BulbCommand) _then;

/// Create a copy of BulbCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? on = freezed,Object? r = freezed,Object? g = freezed,Object? b = freezed,Object? c = freezed,Object? w = freezed,Object? temp = freezed,Object? dimming = freezed,Object? sceneId = freezed,Object? speed = freezed,}) {
  return _then(_BulbCommand(
on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool?,r: freezed == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int?,g: freezed == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int?,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int?,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as int?,w: freezed == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as int?,temp: freezed == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int?,dimming: freezed == dimming ? _self.dimming : dimming // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
