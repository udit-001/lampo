import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../data/models/bulb.dart';
import '../../../domain/models/bulb_type.dart';
import 'bulb_detail_viewmodel.dart';

class DeviceInfoScreen extends StatefulWidget {
  final Bulb bulb;
  final BulbDetailViewModel viewModel;

  const DeviceInfoScreen({
    super.key,
    required this.bulb,
    required this.viewModel,
  });

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  late TextEditingController _aliasController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.bulb.alias ?? '');
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bulb = widget.viewModel.bulb ?? widget.bulb;
    final state = bulb.state;
    final isOnline = bulb.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameRow(context, theme),
            const SizedBox(height: 24),
            _infoRow(theme, 'IP Address', bulb.ip.address, mono: true),
            if (bulb.mac != null) _infoRow(theme, 'MAC', bulb.mac!, mono: true),
            if (bulb.model != null) _infoRow(theme, 'Model', bulb.model!),
            if (bulb.firmware != null) _infoRow(theme, 'Firmware', bulb.firmware!),
            _infoRow(theme, 'Type', _bulbClassLabel(bulb.bulbClass)),
            _infoRow(theme, 'Kelvin', '${bulb.kelvinMin}K – ${bulb.kelvinMax}K'),
            if (state?.rssi != null) _infoRow(theme, 'RSSI', '${state!.rssi} dBm'),
            _infoRow(theme, 'Status', isOnline ? 'Online' : 'Offline'),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _confirmRemove(context),
              icon: Icon(LucideIcons.trash_2),
              label: const Text('Remove bulb'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameRow(BuildContext context, ThemeData theme) {
    if (_editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _aliasController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Living Room',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _saveAlias(context),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _editing = false;
                    _aliasController.text = widget.bulb.alias ?? '';
                  });
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _saveAlias(context),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => setState(() => _editing = true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.bulb.displayName,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Icon(LucideIcons.pencil, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAlias(BuildContext context) {
    final alias = _aliasController.text.trim();
    widget.viewModel.setAlias(alias);
    Navigator.pop(context);
  }

  String _bulbClassLabel(BulbClass bulbClass) {
    switch (bulbClass) {
      case BulbClass.rgb:
        return 'RGB Tunable';
      case BulbClass.tw:
        return 'Tunable White';
      case BulbClass.dw:
        return 'Dimmable White';
      case BulbClass.socket:
        return 'Smart Socket';
      case BulbClass.fanDim:
        return 'Fan (Dimmable)';
      case BulbClass.fanTw:
        return 'Fan (Tunable White)';
    }
  }

  void _confirmRemove(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    radius: 24,
                    child: Icon(LucideIcons.trash_2, size: 20, color: theme.colorScheme.onErrorContainer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Remove bulb?', style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${widget.bulb.displayName}" will be removed from your saved bulbs. '
                'It will reappear on the next scan if it\'s still on the network.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        widget.viewModel.removeBulb();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
