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
      1: Color(0xFF92CFD4),
      2: Color(0xFF7B79B2),
      3: Color(0xFFFEB63F),
      4: Color(0xFFFDEB29),
      5: Color(0xFFE4AA08),
      6: Color(0xFFFCE383),
      7: Color(0xFFC6E155),
      8: Color(0xFF0C7DC1),
      9: Color(0xFFFDCD48),
      10: Color(0xFF575757),
      11: Color(0xFFFEF9CF),
      12: Color(0xFFEBF7FF),
      13: Color(0xFFC4E8F9),
      14: Color(0xFF8D8D8D),
      15: Color(0xFFE9FBFE),
      16: Color(0xFFFFCFFF),
      17: Color(0xFFFFF8D3),
      18: Color(0xFF88C9FF),
      19: Color(0xFFFFA6EE),
      20: Color(0xFFC4FFC4),
      21: Color(0xFFEBA15E),
      22: Color(0xFFFFD700),
      23: Color(0xFF358CD3),
      24: Color(0xFF13AE13),
      25: Color(0xFFE5FFC4),
      26: Color(0xFFFFE98A),
      27: Color(0xFF4BC24B),
      28: Color(0xFFFFE34D),
      29: Color(0xFFFEF9CF),
      30: Color(0xFFD9F0FC),
      31: Color(0xFFFAF6CE),
      32: Color(0xFFFDF9CF),
      33: Color(0xFFFFED4A),
      34: Color(0xFFFEFFE3),
      35: Color(0xFFE3F3FD),
      36: Color(0xFFD8F0FF),
      40: Color(0xFFFFBB07),
      1000: Color(0xFF9C27B0),
    };
    return sceneColors[sceneId] ?? Colors.amber;
  }

  static const List<Color> _fallbackGradientColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF6B6B),
  ];

  static const Map<int, List<Color>> _sceneGradientColors = {
    1: [Color(0xFF92CFD4), Color(0xFF227EC0), Color(0xFF757DB8), Color(0xFF92CFD4)],
    4: [Color(0xFFFDEB29), Color(0xFFEB56A5), Color(0xFFB8E1FF), Color(0xFFE64049), Color(0xFFFDEB29)],
    5: [Color(0xFFE4AA08), Color(0xFFDB8A42), Color(0xFFE53F21), Color(0xFFE4AA08)],
    7: [Color(0xFFC6E155), Color(0xFF94D15B), Color(0xFFFFF25B), Color(0xFFC6E155)],
    23: [Color(0xFF358CD3), Color(0xFF229BFF), Color(0xFF7EC5FF), Color(0xFF358CD3)],
    24: [Color(0xFF13AE13), Color(0xFF74C51D), Color(0xFFFDEB29), Color(0xFF13AE13)],
    25: [Color(0xFFE5FFC4), Color(0xFF7DFB7D), Color(0xFFDEFFFF), Color(0xFFE5FFC4)],
    26: [Color(0xFFFFE98A), Color(0xFFF49756), Color(0xFFD49467), Color(0xFFFFE98A)],
    27: [Color(0xFF4BC24B), Color(0xFF88C87E), Color(0xFFFFD4E3), Color(0xFFFF3B3B), Color(0xFF4BC24B)],
    28: [Color(0xFFFFE34D), Color(0xFFFF8858), Color(0xFFFFA940), Color(0xFFFFE34D)],
    29: [Color(0xFFFEF9CF), Color(0xFFFCE383), Color(0xFFFFF8D3), Color(0xFFFDDC0D), Color(0xFFFEF9CF)],
    30: [Color(0xFFD9F0FC), Color(0xFFFFEB6F), Color(0xFFFDDC0D), Color(0xFFFAF6CE), Color(0xFFD9F0FC)],
    31: [Color(0xFFFAF6CE), Color(0xFFFDF9CF), Color(0xFFFFE632), Color(0xFFFFE844), Color(0xFFFAF6CE)],
    32: [Color(0xFFFDF9CF), Color(0xFFFFE632), Color(0xFFFFE844), Color(0xFFFFED74), Color(0xFFFDF9CF)],
    33: [Color(0xFFFFED4A), Color(0xFFFFBB56), Color(0xFF6FE5FF), Color(0xFFFD94FF), Color(0xFFFFED4A)],
    36: [Color(0xFFD8F0FF), Color(0xFFA0DBFF), Color(0xFFD8F0FF)],
  };

  static SweepGradient sceneGradient(int sceneId) {
    final colors = _sceneGradientColors[sceneId] ?? _fallbackGradientColors;
    return SweepGradient(colors: colors);
  }

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
