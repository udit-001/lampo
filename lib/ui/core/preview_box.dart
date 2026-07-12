import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../data/models/bulb_state.dart';
import '../../../domain/models/scene.dart';
import 'bulb_colors.dart';

class PreviewBox extends StatelessWidget {
  final BulbState state;
  final bool isOnline;
  final bool commandFailed;
  final VoidCallback? onTap;

  const PreviewBox({
    super.key,
    required this.state,
    this.isOnline = true,
    this.commandFailed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOn = isOnline && state.on;
    final bgColor = isOn ? BulbColors.fromState(state) : theme.colorScheme.surfaceContainerHigh;
    final scene = state.sceneId != null && state.sceneId! > 0
        ? WizScene.fromId(state.sceneId!)
        : null;
    final isDynamicScene = isOn && scene?.isDynamic == true;

    return Semantics(
      label: !isOnline
          ? 'Bulb offline'
          : isOn
              ? 'On \u2014 tap to turn off'
              : 'Off \u2014 tap to turn on',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: isDynamicScene
                ? Colors.black.withAlpha(100)
                : bgColor,
            borderRadius: BorderRadius.circular(20),
            border: !isOnline
                ? Border.all(color: theme.colorScheme.outline, width: 2)
                : null,
            gradient: isDynamicScene ? BulbColors.dynamicSceneGradient : null,
            boxShadow: isOn
                ? [BoxShadow(
                    color: bgColor.withAlpha(100),
                    blurRadius: 35,
                    spreadRadius: 3,
                  )]
                : null,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isOn)
                  Icon(
                    LucideIcons.lightbulb_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                else
                  Icon(
                    LucideIcons.lightbulb,
                    size: 48,
                    color: isDynamicScene
                        ? Colors.white
                        : BulbColors.iconColorFor(bgColor),
                  ),
                if (commandFailed)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.onErrorContainer, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.triangle_alert, size: 14, color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 4),
                          Text(
                            'Command failed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
