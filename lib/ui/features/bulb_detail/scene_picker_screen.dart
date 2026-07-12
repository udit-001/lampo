import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../domain/models/scene.dart';
import '../../core/bulb_colors.dart';

enum SceneFilter { static_, animated }

const _categoryLabels = {
  SceneCategory.everyday: 'Everyday',
  SceneCategory.mood: 'Mood',
  SceneCategory.dynamic: 'Dynamic',
  SceneCategory.seasonal: 'Seasonal',
  SceneCategory.nature: 'Nature',
  SceneCategory.utility: 'Utility',
};

class ScenePickerScreen extends StatelessWidget {
  final int? currentSceneId;

  const ScenePickerScreen({super.key, this.currentSceneId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Scene'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Static'),
              Tab(text: 'Animated'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SceneList(filter: SceneFilter.static_, currentSceneId: currentSceneId),
            _SceneList(filter: SceneFilter.animated, currentSceneId: currentSceneId),
          ],
        ),
      ),
    );
  }
}

class _SceneList extends StatelessWidget {
  final SceneFilter filter;
  final int? currentSceneId;

  const _SceneList({required this.filter, this.currentSceneId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = SceneCategory.values;

    final items = <Widget>[];

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final scenes = _filteredScenes(WizScene.byCategory(category));
      if (scenes.isEmpty) continue;

      items.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16, i == 0 ? 16 : 12, 16, 8),
          child: Text(
            _categoryLabels[category]!.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );

      for (var j = 0; j < scenes.length; j++) {
        final scene = scenes[j];
        final isSelected = currentSceneId == scene.id;
        final showDivider = j < scenes.length - 1;

        items.add(_SceneRow(
          scene: scene,
          isSelected: isSelected,
          showDivider: showDivider,
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: items,
    );
  }

  List<WizScene> _filteredScenes(List<WizScene> scenes) {
    switch (filter) {
      case SceneFilter.static_:
        return scenes.where((s) => !s.isDynamic).toList();
      case SceneFilter.animated:
        return scenes.where((s) => s.isDynamic).toList();
    }
  }
}

class _SceneRow extends StatelessWidget {
  final WizScene scene;
  final bool isSelected;
  final bool showDivider;

  const _SceneRow({
    required this.scene,
    required this.isSelected,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = BulbColors.sceneColor(scene.id);
    final isDynamic = scene.isDynamic;

    return InkWell(
      onTap: () => Navigator.pop(context, scene.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 72),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withAlpha(15) : null,
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(80),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDynamic ? BulbColors.dynamicSceneGradient : null,
                color: isDynamic ? null : color,
              ),
              child: isDynamic
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        scene.icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      scene.icon,
                      size: 22,
                      color: BulbColors.iconColorFor(color),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                scene.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.circle_check_big, size: 20, color: theme.colorScheme.primary)
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
