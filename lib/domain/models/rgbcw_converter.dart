import 'dart:math';

class RgbcwResult {
  final int r;
  final int g;
  final int b;
  final int warmWhite;

  const RgbcwResult({
    required this.r,
    required this.g,
    required this.b,
    required this.warmWhite,
  });
}

class RgbcwConverter {
  const RgbcwConverter._();

  static const double _epsilon = 1.0e-5;
  static const int cwMax = 128;

  static final double _angle = (pi * 2) / 3;
  static final List<({double x, double y})> _basis = [
    (x: cos(0.0), y: sin(0.0)),
    (x: cos(_angle), y: sin(_angle)),
    (x: cos(_angle * 2), y: sin(_angle * 2)),
  ];

  static RgbcwResult rgb2rgbcw(int r, int g, int b) {
    final nr = r / 255;
    final ng = g / 255;
    final nb = b / 255;

    var hueX = _basis[0].x * nr + _basis[1].x * ng + _basis[2].x * nb;
    var hueY = _basis[0].y * nr + _basis[1].y * ng + _basis[2].y * nb;

    var saturation = sqrt(hueX * hueX + hueY * hueY);
    if (saturation > _epsilon) {
      hueX = hueX / saturation;
      hueY = hueY / saturation;
    }

    return _trapezoid(hueX, hueY, saturation, nr, ng, nb);
  }

  static RgbcwResult _trapezoid(
    double hueX,
    double hueY,
    double saturation,
    double nr,
    double ng,
    double nb,
  ) {
    List<double> rgb;

    if (saturation <= _epsilon) {
      rgb = [0, 0, 0];
    } else {
      final maxAngle = cos((pi * 2 / 3) - _epsilon);
      final mask = <int>[];
      for (final v in _basis) {
        mask.add((hueX * v.x + hueY * v.y) > maxAngle ? 1 : 0);
      }
      final count = mask.fold(0, (a, b) => a + b);

      if (count == 1) {
        rgb = mask.map((m) => m.toDouble()).toList();
      } else {
        final subBasis = <({double x, double y})>[];
        for (var i = 0; i < 3; i++) {
          if (mask[i] == 1) subBasis.add(_basis[i]);
        }

        final abX = subBasis[1].y;
        final abY = -subBasis[1].x;

        final coeff0 = (hueX * abX + hueY * abY) /
            (subBasis[0].x * abX + subBasis[0].y * abY);

        final interX = subBasis[0].x * (-coeff0) + hueX;
        final interY = subBasis[0].y * (-coeff0) + hueY;

        final coeff1 = interX * subBasis[1].x + interY * subBasis[1].y;

        final maxCoeff = max(coeff0, coeff1);
        final scaledCoeff0 = coeff0 / maxCoeff;
        final scaledCoeff1 = coeff1 / maxCoeff;

        final coeffs = [scaledCoeff0, scaledCoeff1];
        rgb = [];
        var j = 0;
        for (var i = 0; i < 3; i++) {
          if (mask[i] == 1) {
            rgb.add(min(coeffs[j], 1.0));
            j++;
          } else {
            rgb.add(0.0);
          }
        }
      }
    }

    double cw;
    if (saturation >= 0.5) {
      cw = 1 - ((saturation - 0.5) * 2);
    } else {
      cw = 1;
      rgb = rgb.map((v) => v * saturation * 2).toList();
    }

    final outR = (rgb[0] * 255).toInt();
    final outG = (rgb[1] * 255).toInt();
    final outB = (rgb[2] * 255).toInt();
    final outW = max(0, (cw * cwMax).toInt());

    return RgbcwResult(r: outR, g: outG, b: outB, warmWhite: outW);
  }
}
