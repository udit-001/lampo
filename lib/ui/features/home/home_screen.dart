import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../../data/models/bulb.dart';
import '../../../data/repositories/bulb_repository.dart';
import '../../../data/services/wifi_band_service.dart';
import '../../../domain/models/scene.dart';
import '../../../ui/core/bulb_colors.dart';
import 'home_viewmodel.dart';
import '../bulb_detail/bulb_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BulbViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BulbViewModel>();
    final bulbs = viewModel.bulbs;
    final online = bulbs.where((b) => b.isOnline).toList();
    final offline = bulbs.where((b) => !b.isOnline).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lampo'),
        actions: [
          IconButton(
            onPressed: viewModel.isScanning ? null : () => viewModel.scan(),
            icon: viewModel.isScanning && bulbs.isNotEmpty
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(LucideIcons.radar),
          ),
        ],
      ),
      body: viewModel.isInitializing
          ? _loadingState(context)
          : viewModel.scanError != null && bulbs.isEmpty
              ? _errorState(context, viewModel)
              : bulbs.isEmpty
                  ? _emptyState(context, viewModel)
                  : _bulbList(context, viewModel, online, offline),
    );
  }

  Widget _loadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text('Loading\u2026', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, BulbViewModel viewModel) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wifi_off, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Scan failed', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            viewModel.scanError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => viewModel.scan(),
            icon: const Icon(LucideIcons.radar),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, BulbViewModel viewModel) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (viewModel.isScanning)
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Icon(LucideIcons.lightbulb_off, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            viewModel.isScanning ? 'Scanning for bulbs...' : 'No bulbs found',
            style: theme.textTheme.titleMedium,
          ),
          if (!viewModel.isScanning) ...[
            if (viewModel.wifiBand == WifiBand.ghz5) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.wifi, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '5GHz Wi\u2011Fi detected \u2014 WiZ bulbs need 2.4GHz',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => viewModel.scan(),
              icon: const Icon(LucideIcons.radar),
              label: const Text('Scan for bulbs'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bulbList(
    BuildContext context,
    BulbViewModel viewModel,
    List<Bulb> online,
    List<Bulb> offline,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: online.length + (offline.isEmpty ? 0 : 1) + offline.length,
      itemBuilder: (context, index) {
        if (index < online.length) {
          final bulb = online[index];
          return _BulbRow(
            bulb: bulb,
            showDivider: index < online.length - 1 || offline.isNotEmpty,
            onTap: () => _openDetail(context, bulb),
            onToggle: () {
              HapticFeedback.lightImpact();
              viewModel.toggle(bulb);
            },
          );
        }
        final adjustedIndex = index - online.length;
        if (adjustedIndex == 0 && offline.isNotEmpty) {
          return _SectionHeader(
            label: 'Offline',
            count: offline.length,
            showTopSpacing: online.isNotEmpty,
          );
        }
        final bulb = offline[adjustedIndex - (offline.isNotEmpty ? 1 : 0)];
        return _BulbRow(
          bulb: bulb,
          showDivider: adjustedIndex - (offline.isNotEmpty ? 1 : 0) < offline.length - 1,
          onTap: () => _openDetail(context, bulb),
          onToggle: bulb.isOnline
              ? () {
                  HapticFeedback.lightImpact();
                  viewModel.toggle(bulb);
                }
              : null,
        );
      },
    );
  }

  void _openDetail(BuildContext context, Bulb bulb) {
    final repository = context.read<BulbRepository>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BulbDetailScreen(bulb: bulb, repository: repository),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool showTopSpacing;

  const _SectionHeader({
    required this.label,
    required this.count,
    this.showTopSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, showTopSpacing ? 12 : 0, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulbRow extends StatelessWidget {
  final Bulb bulb;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  const _BulbRow({
    required this.bulb,
    required this.showDivider,
    required this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = bulb.state;
    final isOn = bulb.isOnline && state != null && state.on;
    final isOffline = !bulb.isOnline;

    Widget circle;
    if (isOffline) {
      circle = CustomPaint(
        size: const Size(44, 44),
        painter: _DashedCirclePainter(
          color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
          strokeWidth: 2,
        ),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            LucideIcons.lightbulb_off,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
        ),
      );
    } else if (!isOn) {
      circle = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.lightbulb_off,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      final scene = state.sceneId != null && state.sceneId! > 0
          ? WizScene.fromId(state.sceneId!)
          : null;
      final isDynamic = scene?.isDynamic == true;
      final color = BulbColors.fromState(state);

      if (isDynamic) {
        circle = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BulbColors.dynamicSceneGradient,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(60),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.lightbulb,
              size: 22,
              color: Colors.white,
            ),
          ),
        );
      } else {
        circle = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            LucideIcons.lightbulb,
            size: 22,
            color: BulbColors.iconColorFor(color),
          ),
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(80),
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              circle,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bulb.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isOffline
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(bulb),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: onToggle != null ? (_) => onToggle!() : null,
              ),
              Icon(
                LucideIcons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Bulb bulb) {
    if (!bulb.isOnline) {
      return 'Offline \u00b7 last seen ${_lastSeenLabel(bulb.lastSeen)}';
    }

    final parts = <String>[];
    final state = bulb.state;
    if (state != null) {
      if (state.sceneId != null && state.sceneId! > 0) {
        parts.add(WizScene.fromId(state.sceneId!)?.name ?? 'Scene ${state.sceneId}');
      }
      if (state.dimming != null) {
        parts.add('${state.dimming}%');
      }
    }
    return parts.isEmpty ? 'On' : parts.join(' \u00b7 ');
  }

  String _lastSeenLabel(DateTime? lastSeen) {
    if (lastSeen == null) return 'unknown';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const dashCount = 16;
    const dashArc = 2 * 3.14159265 / dashCount * 0.5;
    final gapArc = 2 * 3.14159265 / dashCount - dashArc;

    var startAngle = -3.14159265 / 2;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashArc,
        false,
        paint,
      );
      startAngle += dashArc + gapArc;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}
