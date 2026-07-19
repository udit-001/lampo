import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/domain/models/bulb_type.dart';
import 'package:lampo/domain/models/scene.dart';

void main() {
  group('WizScene.scenesForClass', () {
    test('RGB gets all scenes', () {
      final scenes = WizScene.scenesForClass(BulbClass.rgb);
      expect(scenes.length, WizScene.all.length);
    });

    test('TW gets a filtered subset', () {
      final scenes = WizScene.scenesForClass(BulbClass.tw);
      expect(scenes.length, lessThan(WizScene.all.length));
      expect(scenes.length, greaterThan(0));
      for (final s in scenes) {
        expect(s.id, inInclusiveRange(1, 1000));
      }
      expect(scenes.any((s) => s.id == 6), true, reason: 'Cozy should be in TW');
      expect(scenes.any((s) => s.id == 1), false, reason: 'Ocean should not be in TW');
      expect(scenes.any((s) => s.id == 4), false, reason: 'Party should not be in TW');
    });

    test('DW gets a smaller subset', () {
      final scenes = WizScene.scenesForClass(BulbClass.dw);
      expect(scenes.length, lessThan(WizScene.scenesForClass(BulbClass.tw).length));
      expect(scenes.any((s) => s.id == 9), true, reason: 'Wake-up should be in DW');
      expect(scenes.any((s) => s.id == 14), true, reason: 'Night light should be in DW');
    });

    test('SOCKET gets no scenes', () {
      final scenes = WizScene.scenesForClass(BulbClass.socket);
      expect(scenes, isEmpty);
    });

    test('FANTW gets all scenes (like RGB)', () {
      final scenes = WizScene.scenesForClass(BulbClass.fanTw);
      expect(scenes.length, WizScene.all.length);
    });

    test('FANDIM gets DW subset', () {
      final scenes = WizScene.scenesForClass(BulbClass.fanDim);
      expect(scenes.length, WizScene.scenesForClass(BulbClass.dw).length);
    });

    test('TW scenes include newly added Dim-to-warm (40)', () {
      final scenes = WizScene.scenesForClass(BulbClass.tw);
      expect(scenes.any((s) => s.id == 40), true);
    });

    test('DW scenes do not include Club (26)', () {
      final scenes = WizScene.scenesForClass(BulbClass.dw);
      expect(scenes.any((s) => s.id == 26), false);
    });
  });
}
