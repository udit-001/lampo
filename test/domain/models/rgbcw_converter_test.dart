import 'package:flutter_test/flutter_test.dart';
import 'package:lampo/domain/models/rgbcw_converter.dart';

void main() {
  group('RgbcwConverter', () {
    group('pure saturated colors (w = 0)', () {
      test('pure red (255,0,0) → rgb unchanged, w=0', () {
        final result = RgbcwConverter.rgb2rgbcw(255, 0, 0);
        expect(result.r, 255);
        expect(result.g, 0);
        expect(result.b, 0);
        expect(result.warmWhite, 0);
      });

      test('pure green (0,255,0) → rgb unchanged, w=0', () {
        final result = RgbcwConverter.rgb2rgbcw(0, 255, 0);
        expect(result.r, 0);
        expect(result.g, 255);
        expect(result.b, 0);
        expect(result.warmWhite, 0);
      });

      test('pure blue (0,0,255) → rgb unchanged, w=0', () {
        final result = RgbcwConverter.rgb2rgbcw(0, 0, 255);
        expect(result.r, 0);
        expect(result.g, 0);
        expect(result.b, 255);
        expect(result.warmWhite, 0);
      });
    });

    group('white and near-white (engages warm white LED)', () {
      test('white (255,255,255) → rgb=0, w=128', () {
        final result = RgbcwConverter.rgb2rgbcw(255, 255, 255);
        expect(result.r, 0);
        expect(result.g, 0);
        expect(result.b, 0);
        expect(result.warmWhite, 128);
      });

      test('black (0,0,0) → rgb=0, w=128', () {
        final result = RgbcwConverter.rgb2rgbcw(0, 0, 0);
        expect(result.r, 0);
        expect(result.g, 0);
        expect(result.b, 0);
        expect(result.warmWhite, 128);
      });
    });

    group('partially saturated colors', () {
      test('orange (255,128,0) → high saturation, low warm white', () {
        final result = RgbcwConverter.rgb2rgbcw(255, 128, 0);
        expect(result.r, 255);
        expect(result.g, inInclusiveRange(120, 135));
        expect(result.b, 0);
        expect(result.warmWhite, inInclusiveRange(20, 50));
      });

      test('dim warm color (64,32,0) → lower saturation, more warm white', () {
        final result = RgbcwConverter.rgb2rgbcw(64, 32, 0);
        expect(result.warmWhite, greaterThan(50));
      });

      test('very desaturated (10,10,8) → mostly warm white', () {
        final result = RgbcwConverter.rgb2rgbcw(10, 10, 8);
        expect(result.warmWhite, greaterThan(100));
      });
    });

    group('warm white never exceeds CWMAX (128)', () {
      test('for all gray values', () {
        for (var v = 0; v <= 255; v += 16) {
          final result = RgbcwConverter.rgb2rgbcw(v, v, v);
          expect(result.warmWhite, lessThanOrEqualTo(128),
              reason: 'gray=$v produced w=${result.warmWhite}');
        }
      });
    });

    group('RGB channels never exceed 255', () {
      test('for various colors', () {
        final colors = [
          (255, 0, 0),
          (0, 255, 0),
          (0, 0, 255),
          (255, 255, 0),
          (255, 0, 255),
          (0, 255, 255),
          (128, 64, 32),
          (200, 200, 200),
        ];
        for (final (r, g, b) in colors) {
          final result = RgbcwConverter.rgb2rgbcw(r, g, b);
          expect(result.r, inInclusiveRange(0, 255));
          expect(result.g, inInclusiveRange(0, 255));
          expect(result.b, inInclusiveRange(0, 255));
        }
      });
    });
  });
}
