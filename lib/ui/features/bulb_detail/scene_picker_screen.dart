import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../domain/models/bulb_type.dart';
import '../../../domain/models/scene.dart';
import '../../core/bulb_colors.dart';

enum SceneFilter { static_, animated }

class ScenePickerScreen extends StatelessWidget {
  final int? currentSceneId;
  final BulbClass bulbClass;

  const ScenePickerScreen({
    super.key,
    this.currentSceneId,
    this.bulbClass = BulbClass.rgb,
  });

  @override
  Widget build(BuildContext context) {
    final currentScene = currentSceneId != null
        ? WizScene.fromId(currentSceneId!)
        : null;
    final initialIndex = currentScene?.isDynamic == true ? 1 : 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
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
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _SceneGrid(
              filter: SceneFilter.static_,
              currentSceneId: currentSceneId,
              bulbClass: bulbClass,
            ),
            _SceneGrid(
              filter: SceneFilter.animated,
              currentSceneId: currentSceneId,
              bulbClass: bulbClass,
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneGrid extends StatefulWidget {
  final SceneFilter filter;
  final int? currentSceneId;
  final BulbClass bulbClass;

  const _SceneGrid({
    required this.filter,
    this.currentSceneId,
    required this.bulbClass,
  });

  @override
  State<_SceneGrid> createState() => _SceneGridState();
}

class _SceneGridState extends State<_SceneGrid> {
  final GlobalKey _selectedKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _selectedKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.3);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableScenes = WizScene.scenesForClass(widget.bulbClass);
    final scenes = _filteredScenes(availableScenes);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: scenes.length,
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final isSelected = widget.currentSceneId == scene.id;
        return _SceneTile(
          key: isSelected ? _selectedKey : null,
          scene: scene,
          isSelected: isSelected,
        );
      },
    );
  }

  List<WizScene> _filteredScenes(List<WizScene> scenes) {
    switch (widget.filter) {
      case SceneFilter.static_:
        return scenes.where((s) => !s.isDynamic).toList();
      case SceneFilter.animated:
        return scenes.where((s) => s.isDynamic).toList();
    }
  }
}

class _SceneTile extends StatelessWidget {
  final WizScene scene;
  final bool isSelected;

  const _SceneTile({
    super.key,
    required this.scene,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = BulbColors.sceneColor(scene.id);
    final isDynamic = scene.isDynamic;

    return Semantics(
      label: '${scene.name} scene${isSelected ? ', selected' : ''}',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => Navigator.pop(context, scene.id),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isDynamic ? BulbColors.sceneGradient(scene.id) : null,
                  color: isDynamic ? null : color,
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2.5)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 17.5 : 20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: Colors.black.withAlpha(90)),
                      Center(
                        child: Icon(
                          scene.icon,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.check,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scene.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
