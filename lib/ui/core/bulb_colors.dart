import 'package:flutter/material.dart';

import '../../../data/models/bulb_state.dart';

class BulbColors {
  BulbColors._();

  static Color fromState(BulbState state, {Color fallback = Colors.amber}) {
    if (state.r != null && state.g != null && state.b != null) {
      return Color.fromARGB(255, state.r!, state.g!, state.b!);
    }
    if (state.temp != null) {
      return kelvinToColor(state.temp!);
    }
    if (state.sceneId != null && state.sceneId! > 0) {
      return sceneColor(state.sceneId!);
    }
    return fallback;
  }

  static Color kelvinToColor(int kelvin) {
    if (kelvin < 3000) return const Color(0xFFFF9B5A);
    if (kelvin < 4000) return const Color(0xFFFFC58F);
    if (kelvin < 5000) return const Color(0xFFFFE4C4);
    if (kelvin < 6000) return const Color(0xFFFDF5E6);
    return const Color(0xFFE0F0FF);
  }

  static Color sceneColor(int sceneId) {
    const sceneColors = {
      1: Color(0xFF006994),
      4: Color(0xFFE91E63),
      5: Color(0xFFFF5722),
      7: Color(0xFF2E7D32),
      23: Color(0xFF1A237E),
      24: Color(0xFF4CAF50),
      25: Color(0xFF8BC34A),
      27: Color(0xFFD32F2F),
      28: Color(0xFF7B1FA2),
      29: Color(0xFFFF8F00),
      30: Color(0xFFFFD700),
      31: Color(0xFFE91E63),
      32: Color(0xFF5D4037),
      33: Color(0xFFFFD700),
    };
    return sceneColors[sceneId] ?? Colors.amber;
  }

  static const List<Color> dynamicSceneColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF6B6B),
  ];

  static const SweepGradient dynamicSceneGradient = SweepGradient(
    colors: dynamicSceneColors,
  );

  static const List<Color> kelvinGradientColors = [
    Color(0xFFFF9B5A),
    Color(0xFFFFC58F),
    Color(0xFFFFE4C4),
    Color(0xFFFDF5E6),
    Color(0xFFE0F0FF),
  ];

  static const LinearGradient kelvinGradient = LinearGradient(
    colors: kelvinGradientColors,
  );

  static Color iconColorFor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Colors.black.withAlpha(140)
        : Colors.white.withAlpha(217);
  }
}
