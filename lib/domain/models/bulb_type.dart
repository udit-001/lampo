enum BulbClass {
  rgb,
  tw,
  dw,
  socket,
  fanDim,
  fanTw,
}

class BulbFeatures {
  final bool brightness;
  final bool color;
  final bool colorTemp;
  final bool effect;

  const BulbFeatures({
    required this.brightness,
    required this.color,
    required this.colorTemp,
    required this.effect,
  });

  static const BulbFeatures rgb = BulbFeatures(
    brightness: true,
    color: true,
    colorTemp: true,
    effect: true,
  );

  static const BulbFeatures tw = BulbFeatures(
    brightness: true,
    color: false,
    colorTemp: true,
    effect: true,
  );

  static const BulbFeatures dw = BulbFeatures(
    brightness: true,
    color: false,
    colorTemp: false,
    effect: true,
  );

  static const BulbFeatures socket = BulbFeatures(
    brightness: false,
    color: false,
    colorTemp: false,
    effect: false,
  );

  static const BulbFeatures fanDim = BulbFeatures(
    brightness: true,
    color: false,
    colorTemp: false,
    effect: false,
  );

  static const BulbFeatures fanTw = BulbFeatures(
    brightness: true,
    color: false,
    colorTemp: true,
    effect: true,
  );
}

class BulbTypeDetector {
  const BulbTypeDetector._();

  static BulbClass detectFromModuleName(String? moduleName) {
    if (moduleName == null || moduleName.isEmpty) return BulbClass.rgb;

    final parts = moduleName.split('_');
    if (parts.length < 2) return BulbClass.rgb;

    final identifier = parts[1];

    if (identifier.contains('RGB')) {
      return BulbClass.rgb;
    } else if (identifier.contains('DDTW')) {
      return BulbClass.fanTw;
    } else if (identifier.contains('TW')) {
      return BulbClass.tw;
    } else if (identifier.contains('SOCKET')) {
      return BulbClass.socket;
    } else if (identifier.contains('FANDIM')) {
      return BulbClass.fanDim;
    } else {
      return BulbClass.dw;
    }
  }

  static BulbFeatures featuresFor(BulbClass bulbClass) {
    switch (bulbClass) {
      case BulbClass.rgb:
        return BulbFeatures.rgb;
      case BulbClass.tw:
        return BulbFeatures.tw;
      case BulbClass.dw:
        return BulbFeatures.dw;
      case BulbClass.socket:
        return BulbFeatures.socket;
      case BulbClass.fanDim:
        return BulbFeatures.fanDim;
      case BulbClass.fanTw:
        return BulbFeatures.fanTw;
    }
  }
}
