import 'package:freezed_annotation/freezed_annotation.dart';

part 'bulb_state.freezed.dart';

@freezed
abstract class BulbState with _$BulbState {
  const BulbState._();

  const factory BulbState({
    @Default(false) bool on,
    int? r,
    int? g,
    int? b,
    int? c,
    int? w,
    int? temp,
    int? dimming,
    int? sceneId,
    int? speed,
    int? rssi,
  }) = _BulbState;

  factory BulbState.fromMap(
    Map<String, dynamic> result, {
    BulbState? previous,
  }) {
    final base = previous ?? const BulbState();
    return BulbState(
      on: result.containsKey('state')
          ? (result['state'] as bool? ?? false)
          : base.on,
      r: result.containsKey('r') ? result['r'] as int? : base.r,
      g: result.containsKey('g') ? result['g'] as int? : base.g,
      b: result.containsKey('b') ? result['b'] as int? : base.b,
      c: result.containsKey('c') ? result['c'] as int? : base.c,
      w: result.containsKey('w') ? result['w'] as int? : base.w,
      temp: result.containsKey('temp') ? result['temp'] as int? : base.temp,
      dimming: result.containsKey('dimming')
          ? result['dimming'] as int?
          : base.dimming,
      sceneId: result.containsKey('sceneId')
          ? result['sceneId'] as int?
          : base.sceneId,
      speed: result.containsKey('speed') ? result['speed'] as int? : base.speed,
      rssi: result.containsKey('rssi') ? result['rssi'] as int? : base.rssi,
    );
  }
}
