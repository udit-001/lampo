import 'package:freezed_annotation/freezed_annotation.dart';

import 'bulb_state.dart';

part 'bulb_command.freezed.dart';

@freezed
abstract class BulbCommand with _$BulbCommand {
  const BulbCommand._();

  const factory BulbCommand({
    bool? on,
    int? r,
    int? g,
    int? b,
    int? c,
    int? w,
    int? temp,
    int? dimming,
    int? sceneId,
    int? speed,
  }) = _BulbCommand;

  Map<String, dynamic> toSetPilotParams() {
    final params = <String, dynamic>{};
    if (on != null) params['state'] = on;
    if (r != null) params['r'] = r;
    if (g != null) params['g'] = g;
    if (b != null) params['b'] = b;
    if (c != null) params['c'] = c;
    if (w != null) params['w'] = w;
    if (temp != null) params['temp'] = temp;
    if (dimming != null) params['dimming'] = dimming;
    if (sceneId != null) params['sceneId'] = sceneId;
    if (speed != null) params['speed'] = speed;
    return params;
  }
}

extension BulbStateMerge on BulbState {
  BulbState merge(BulbCommand command) => BulbState(
        on: command.on ?? on,
        r: command.r ?? r,
        g: command.g ?? g,
        b: command.b ?? b,
        c: command.c ?? c,
        w: command.w ?? w,
        temp: command.temp ?? temp,
        dimming: command.dimming ?? dimming,
        sceneId: command.sceneId ?? sceneId,
        speed: command.speed ?? speed,
      );
}
