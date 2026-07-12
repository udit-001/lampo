import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
