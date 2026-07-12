import 'package:flutter/widgets.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

enum SceneCategory { everyday, mood, dynamic, seasonal, nature, utility }

class WizScene {
  final int id;
  final String name;
  final IconData icon;
  final SceneCategory category;
  final bool isDynamic;

  const WizScene({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.isDynamic = false,
  });

  static const List<WizScene> all = [
    WizScene(id: 1, name: 'Ocean', icon: LucideIcons.waves, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 2, name: 'Romance', icon: LucideIcons.heart, category: SceneCategory.mood),
    WizScene(id: 3, name: 'Sunset', icon: LucideIcons.sunset, category: SceneCategory.mood),
    WizScene(id: 4, name: 'Party', icon: LucideIcons.party_popper, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 5, name: 'Fireplace', icon: LucideIcons.flame, category: SceneCategory.nature, isDynamic: true),
    WizScene(id: 6, name: 'Cozy', icon: LucideIcons.sofa, category: SceneCategory.everyday),
    WizScene(id: 7, name: 'Forest', icon: LucideIcons.trees, category: SceneCategory.nature, isDynamic: true),
    WizScene(id: 8, name: 'Pastel colors', icon: LucideIcons.palette, category: SceneCategory.mood),
    WizScene(id: 9, name: 'Wake-up', icon: LucideIcons.sunrise, category: SceneCategory.everyday),
    WizScene(id: 10, name: 'Bedtime', icon: LucideIcons.bed, category: SceneCategory.everyday),
    WizScene(id: 11, name: 'Warm white', icon: LucideIcons.lamp, category: SceneCategory.everyday),
    WizScene(id: 12, name: 'Daylight', icon: LucideIcons.sun, category: SceneCategory.everyday),
    WizScene(id: 13, name: 'Cool white', icon: LucideIcons.snowflake, category: SceneCategory.everyday),
    WizScene(id: 14, name: 'Night light', icon: LucideIcons.moon, category: SceneCategory.everyday),
    WizScene(id: 15, name: 'Focus', icon: LucideIcons.target, category: SceneCategory.everyday),
    WizScene(id: 16, name: 'Relax', icon: LucideIcons.coffee, category: SceneCategory.everyday),
    WizScene(id: 17, name: 'True colors', icon: LucideIcons.rainbow, category: SceneCategory.mood),
    WizScene(id: 18, name: 'TV time', icon: LucideIcons.tv, category: SceneCategory.utility),
    WizScene(id: 19, name: 'Plantgrowth', icon: LucideIcons.sprout, category: SceneCategory.nature),
    WizScene(id: 20, name: 'Spring', icon: LucideIcons.flower, category: SceneCategory.seasonal),
    WizScene(id: 21, name: 'Summer', icon: LucideIcons.sun_medium, category: SceneCategory.seasonal),
    WizScene(id: 22, name: 'Fall', icon: LucideIcons.leaf, category: SceneCategory.seasonal),
    WizScene(id: 23, name: 'Deep dive', icon: LucideIcons.cloud_moon, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 24, name: 'Jungle', icon: LucideIcons.leafy_green, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 25, name: 'Mojito', icon: LucideIcons.glass_water, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 27, name: 'Christmas', icon: LucideIcons.tree_pine, category: SceneCategory.seasonal, isDynamic: true),
    WizScene(id: 28, name: 'Halloween', icon: LucideIcons.ghost, category: SceneCategory.seasonal, isDynamic: true),
    WizScene(id: 29, name: 'Candlelight', icon: LucideIcons.flame, category: SceneCategory.nature, isDynamic: true),
    WizScene(id: 30, name: 'Golden white', icon: LucideIcons.star, category: SceneCategory.mood, isDynamic: true),
    WizScene(id: 31, name: 'Pulse', icon: LucideIcons.activity, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 32, name: 'Steampunk', icon: LucideIcons.clock, category: SceneCategory.dynamic, isDynamic: true),
    WizScene(id: 33, name: 'Diwali', icon: LucideIcons.sparkles, category: SceneCategory.seasonal, isDynamic: true),
    WizScene(id: 34, name: 'White', icon: LucideIcons.lightbulb, category: SceneCategory.mood),
    WizScene(id: 35, name: 'Alarm', icon: LucideIcons.alarm_clock, category: SceneCategory.utility),
    WizScene(id: 1000, name: 'Rhythm', icon: LucideIcons.music, category: SceneCategory.utility),
  ];

  static WizScene? fromId(int id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<WizScene> byCategory(SceneCategory category) {
    return all.where((s) => s.category == category).toList();
  }

  static List<WizScene> get dynamicScenes => all.where((s) => s.isDynamic).toList();
}
