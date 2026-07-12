import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/data/models/bulb_command.dart';
import 'package:lampo/data/models/bulb_state.dart';

void main() {
  group('BulbState', () {
    test('parses from map correctly', () {
      final state = BulbState.fromMap({
        'state': true,
        'r': 255,
        'g': 0,
        'b': 0,
        'dimming': 80,
        'sceneId': 1,
      });
      expect(state.on, true);
      expect(state.r, 255);
      expect(state.dimming, 80);
      expect(state.sceneId, 1);
    });

    test('merges from map into previous state', () {
      final previous = BulbState(on: true, r: 255, g: 128, b: 0, dimming: 50);
      final merged = BulbState.fromMap({
        'state': true,
        'dimming': 80,
      }, previous: previous);
      expect(merged.on, true);
      expect(merged.dimming, 80);
      expect(merged.r, 255);
      expect(merged.g, 128);
    });

    test('fromMap without previous starts from empty state', () {
      final state = BulbState.fromMap({
        'state': false,
        'dimming': 30,
      });
      expect(state.on, false);
      expect(state.dimming, 30);
      expect(state.r, isNull);
    });

    test('copyWith produces a new instance with updated fields', () {
      const original = BulbState(on: true, dimming: 50, r: 100);
      final updated = original.copyWith(dimming: 75);
      expect(updated.on, true);
      expect(updated.dimming, 75);
      expect(updated.r, 100);
    });

    test('equality works correctly', () {
      const a = BulbState(on: true, dimming: 50);
      const b = BulbState(on: true, dimming: 50);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('BulbState.merge', () {
    test('merges command into state', () {
      const state = BulbState(on: true, r: 100, g: 200, b: 50, dimming: 75);
      final merged = state.merge(const BulbCommand(dimming: 50));
      expect(merged.on, true);
      expect(merged.dimming, 50);
      expect(merged.r, 100);
      expect(merged.g, 200);
    });

    test('merge with toggle command', () {
      const state = BulbState(on: true, dimming: 50);
      final merged = state.merge(const BulbCommand(on: false));
      expect(merged.on, false);
      expect(merged.dimming, 50);
    });
  });

  group('BulbCommand', () {
    test('converts to setPilot params', () {
      const command = BulbCommand(on: true, r: 100, g: 200, b: 50, dimming: 75);
      final params = command.toSetPilotParams();
      expect(params['state'], true);
      expect(params['r'], 100);
      expect(params['dimming'], 75);
    });

    test('only includes non-null fields in params', () {
      const command = BulbCommand(dimming: 50);
      final params = command.toSetPilotParams();
      expect(params['dimming'], 50);
      expect(params.containsKey('state'), isFalse);
      expect(params.containsKey('r'), isFalse);
    });

    test('scene command includes sceneId and speed', () {
      const command = BulbCommand(on: true, sceneId: 1, speed: 50);
      final params = command.toSetPilotParams();
      expect(params['state'], true);
      expect(params['sceneId'], 1);
      expect(params['speed'], 50);
    });
  });
}
