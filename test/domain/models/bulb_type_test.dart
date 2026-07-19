import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/domain/models/bulb_type.dart';

void main() {
  group('BulbTypeDetector', () {
    group('detectFromModuleName', () {
      test('detects RGB from ESP01_SHRGB_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_SHRGB_31'),
            BulbClass.rgb);
      });

      test('detects RGB from ESP03_SHPKW_31 (contains RGB in identifier)', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP03_SHRGB1C_31'),
            BulbClass.rgb);
      });

      test('detects TW from ESP01_SHTW_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_SHTW_31'),
            BulbClass.tw);
      });

      test('detects DW from ESP01_SHDW_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_SHDW_31'),
            BulbClass.dw);
      });

      test('detects SOCKET from ESP01_SOCKET_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_SOCKET_31'),
            BulbClass.socket);
      });

      test('detects FANDIM from ESP01_FANDIM_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_FANDIM_31'),
            BulbClass.fanDim);
      });

      test('detects FANTW from ESP01_DDTW1C_31', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_DDTW1C_31'),
            BulbClass.fanTw);
      });

      test('defaults to RGB for null module name', () {
        expect(BulbTypeDetector.detectFromModuleName(null), BulbClass.rgb);
      });

      test('defaults to RGB for empty module name', () {
        expect(BulbTypeDetector.detectFromModuleName(''), BulbClass.rgb);
      });

      test('defaults to RGB for single-part name', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01'),
            BulbClass.rgb);
      });

      test('defaults to DW for unknown identifier', () {
        expect(BulbTypeDetector.detectFromModuleName('ESP01_UNKNOWN_31'),
            BulbClass.dw);
      });
    });

    group('featuresFor', () {
      test('RGB has color, colorTemp, brightness, effect', () {
        final f = BulbTypeDetector.featuresFor(BulbClass.rgb);
        expect(f.color, true);
        expect(f.colorTemp, true);
        expect(f.brightness, true);
        expect(f.effect, true);
      });

      test('TW has colorTemp but no color', () {
        final f = BulbTypeDetector.featuresFor(BulbClass.tw);
        expect(f.color, false);
        expect(f.colorTemp, true);
        expect(f.brightness, true);
      });

      test('DW has brightness only', () {
        final f = BulbTypeDetector.featuresFor(BulbClass.dw);
        expect(f.color, false);
        expect(f.colorTemp, false);
        expect(f.brightness, true);
      });

      test('SOCKET has nothing except on/off', () {
        final f = BulbTypeDetector.featuresFor(BulbClass.socket);
        expect(f.color, false);
        expect(f.colorTemp, false);
        expect(f.brightness, false);
        expect(f.effect, false);
      });
    });
  });
}
