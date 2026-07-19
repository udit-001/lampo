import 'scene.dart';

class BulbLimits {
  const BulbLimits._();

  static const int minBrightness = 1;
  static const int maxBrightness = 100;

  static const int minSpeed = 10;
  static const int maxSpeed = 200;

  static const int minTemp = 1000;
  static const int maxTemp = 10000;

  static const int minTempUi = 2200;
  static const int maxTempUi = 6500;

  static const int minChannel = 0;
  static const int maxChannel = 255;

  static bool isValidSceneId(int id) => WizScene.fromId(id) != null;
}
