import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../data/models/bulb.dart';
import '../../../data/models/bulb_state.dart';
import '../../../data/repositories/bulb_repository.dart';
import '../../../domain/models/scene.dart';
import '../../core/bulb_colors.dart';
import '../../core/preview_box.dart';
import '../../core/section_label.dart';
import 'bulb_detail_viewmodel.dart';
import 'device_info_screen.dart';
import 'scene_picker_screen.dart';

class BulbDetailScreen extends StatefulWidget {
  final Bulb bulb;
  final BulbRepository repository;

  const BulbDetailScreen({
    super.key,
    required this.bulb,
    required this.repository,
  });

  @override
  State<BulbDetailScreen> createState() => _BulbDetailScreenState();
}

class _BulbDetailScreenState extends State<BulbDetailScreen> {
  late BulbDetailViewModel _viewModel;
  late double _brightness;
  late double _temp;
  late double _speed;
  late Color _color;
  Timer? _colorDebounce;

  @override
  void initState() {
    super.initState();
    _viewModel = BulbDetailViewModel(
      repository: widget.repository,
      bulbId: widget.bulb.id,
    );
    _brightness = (_viewModel.state.dimming ?? 50).toDouble();
    _temp = (_viewModel.state.temp ?? 4000).toDouble();
    _speed = (_viewModel.state.speed ?? 50).toDouble();
    _color = BulbColors.fromState(_viewModel.state, fallback: Colors.white);
    _viewModel.refreshState();
  }

  @override
  void dispose() {
    _colorDebounce?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final bulb = _viewModel.bulb ?? widget.bulb;
        final state = _viewModel.state;
        final isOn = bulb.isOnline && state.on;

        return Scaffold(
          appBar: AppBar(
            title: Text(bulb.displayName),
            actions: [
              IconButton(
                icon: Icon(LucideIcons.info),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeviceInfoScreen(
                        bulb: bulb,
                        viewModel: _viewModel,
                      ),
                    ),
                  );
                },
              ),
              Switch(
                value: isOn,
                onChanged: bulb.isOnline
                    ? (_) {
                        HapticFeedback.lightImpact();
                        _viewModel.toggle();
                      }
                    : null,
              ),
            ],
          ),
          body: _viewModel.isLoading && bulb.state == null
              ? _buildLoadingShimmer(context)
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    PreviewBox(
                      state: state,
                      isOnline: bulb.isOnline,
                      commandFailed: _viewModel.commandFailed,
                      onTap: bulb.isOnline
                          ? () {
                              HapticFeedback.lightImpact();
                              _viewModel.toggle();
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildBrightness(context, theme, isOn, state),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildModeToggle(context, theme, isOn),
                    const SizedBox(height: 16),
                    _buildModeControls(context, theme, isOn, state),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightness(BuildContext context, ThemeData theme, bool isOn, BulbState state) {
    if (!_viewModel.isUserInteracting) {
      _brightness = (state.dimming ?? 50).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionLabel(text: 'Brightness'),
            const Spacer(),
            Text(
              '${_brightness.round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _brightness,
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: theme.colorScheme.primary,
          onChanged: isOn
              ? (v) {
                  _viewModel.setSliderDragging(true);
                  setState(() => _brightness = v);
                }
              : null,
          onChangeEnd: (v) {
            _viewModel.setBrightness(v.round());
            _viewModel.setSliderDragging(false);
          },
        ),
      ],
    );
  }

  Widget _buildModeToggle(BuildContext context, ThemeData theme, bool isOn) {
    final modes = [
      (BulbMode.white, 'White'),
      (BulbMode.color, 'Color'),
      (BulbMode.scene, 'Scene'),
    ];

    return Row(
      children: modes.map((mode) {
      final isActive = _viewModel.selectedMode == mode.$1;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: mode != modes.last ? 8 : 0,
          ),
          child: GestureDetector(
            onTap: isOn ? () => _viewModel.setMode(mode.$1) : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  mode.$2,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? theme.colorScheme.surface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
    );
  }

  Widget _buildModeControls(BuildContext context, ThemeData theme, bool isOn, BulbState state) {
    switch (_viewModel.selectedMode) {
      case BulbMode.white:
        return _buildWhiteMode(context, theme, isOn, state);
      case BulbMode.color:
        return _buildColorMode(context, theme, isOn, state);
      case BulbMode.scene:
        return _buildSceneMode(context, theme, isOn, state);
    }
  }

  Widget _buildWhiteMode(BuildContext context, ThemeData theme, bool isOn, BulbState state) {
    if (!_viewModel.isUserInteracting) {
      _temp = (state.temp ?? 4000).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionLabel(text: 'Color Temperature'),
            const Spacer(),
            Text(
              '${_temp.round()}K',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: BulbColors.kelvinGradient,
              ),
            ),
            Slider(
              value: _temp,
              min: 2200,
              max: 6500,
              divisions: 86,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.black26),
              thumbColor: BulbColors.kelvinToColor(_temp.round()),
              onChanged: isOn
                  ? (v) {
                      _viewModel.setSliderDragging(true);
                      setState(() => _temp = v);
                    }
                  : null,
              onChangeEnd: (v) {
                _viewModel.setWhiteTemp(v.round());
                _viewModel.setSliderDragging(false);
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('2200K', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('6500K', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildColorMode(BuildContext context, ThemeData theme, bool isOn, BulbState state) {
    if (!_viewModel.isUserInteracting) {
      _color = BulbColors.fromState(state, fallback: Colors.white);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Color'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            ignoring: !isOn,
            child: Opacity(
              opacity: isOn ? 1.0 : 0.4,
              child: ColorPicker(
                pickerColor: _color,
                onColorChanged: (color) {
                  setState(() => _color = color);
                  _colorDebounce?.cancel();
                  _colorDebounce = Timer(const Duration(milliseconds: 300), () {
                    _viewModel.setColor(
                      (color.r * 255).round().clamp(0, 255),
                      (color.g * 255).round().clamp(0, 255),
                      (color.b * 255).round().clamp(0, 255),
                    );
                  });
                },
                enableAlpha: false,
                pickerAreaHeightPercent: 0.7,
                labelTypes: const [],
                displayThumbColor: false,
                paletteType: PaletteType.hueWheel,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Drag to pick \u2014 applies on release',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }

  Widget _buildSceneMode(BuildContext context, ThemeData theme, bool isOn, BulbState state) {
    final scene = state.sceneId != null && state.sceneId! > 0
        ? WizScene.fromId(state.sceneId!)
        : null;

    if (!_viewModel.isUserInteracting) {
      _speed = (state.speed ?? 50).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Scene'),
        const SizedBox(height: 8),
        InkWell(
          onTap: isOn ? () => _pickScene(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (scene != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(scene.icon, size: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene?.name ?? 'No scene',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to browse all scenes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (scene?.isDynamic == true) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const SectionLabel(text: 'Animation speed'),
              const Spacer(),
              Text(
                '${_speed.round()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Slider(
            value: _speed,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: theme.colorScheme.primary,
            onChanged: isOn
                ? (v) {
                    _viewModel.setSliderDragging(true);
                    setState(() => _speed = v);
                  }
                : null,
            onChangeEnd: (v) {
              _viewModel.setSpeed(v.round());
              _viewModel.setSliderDragging(false);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text('100', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          Text(
            'Controls how fast the scene animates',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickScene(BuildContext context) async {
    final sceneId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => ScenePickerScreen(
          currentSceneId: _viewModel.state.sceneId,
        ),
      ),
    );
    if (sceneId != null && mounted) {
      _viewModel.setScene(sceneId);
    }
  }
}
