import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../data/models/bulb.dart';
import '../../../domain/models/scene.dart';
import 'bulb_colors.dart';

class BulbColorSwatch extends StatelessWidget {
  final Bulb bulb;
  final double size;

  const BulbColorSwatch({
    super.key,
    required this.bulb,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = bulb.state;
    final isOnline = bulb.isOnline;

    if (!isOnline) {
      return _hollowCircle(size, theme);
    }

    if (state == null || !state.on) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.lightbulb_off, size: size * 0.55, color: theme.colorScheme.onSurfaceVariant),
      );
    }

    final color = BulbColors.fromState(state);
    final scene = state.sceneId != null && state.sceneId! > 0
        ? WizScene.fromId(state.sceneId!)
        : null;

    if (scene?.isDynamic == true) {
      return _gradientSwatch(size, theme);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        LucideIcons.lightbulb,
        size: size * 0.5,
        color: BulbColors.iconColorFor(color),
      ),
    );
  }

  Widget _gradientSwatch(double size, ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: BulbColors.dynamicSceneGradient,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(60),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.lightbulb,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _hollowCircle(double size, ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.onSurfaceVariant, width: 2),
      ),
      child: Icon(LucideIcons.lightbulb_off, size: size * 0.45, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
