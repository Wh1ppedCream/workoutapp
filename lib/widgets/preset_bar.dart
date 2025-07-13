// File: lib/widgets/preset_bar.dart

import 'package:flutter/material.dart';
import 'generic_bar.dart';

/// A colored preset bar with label and overflow menu.
class PresetBar extends StatelessWidget {
  /// The display name. If null, defaults to "Preset {index}".
  final String? label;

  /// The color accent for this preset.
  final Color color;

  /// The index used when [label] is null.
  final int index;

  /// Called when the user taps the bar.
  final VoidCallback? onTap;

  /// Called when the user selects an overflow menu item.
  final ValueChanged<String>? onMenuSelected;

final bool isAutomatic;

  /// Creates a [PresetBar].
  const PresetBar({
    super.key,
    this.label,
    required this.color,
    required this.index,
    this.onTap,
    this.onMenuSelected,
    this.isAutomatic = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = (label?.trim().isNotEmpty ?? false)
        ? label!
        : 'Preset ${index + 1}';

    // Build the trailing row: optional “A” badge + menu
    Widget trailing = Row(children: [
      if (isAutomatic)
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: _AutomaticBadge(),
        ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: color),
        onSelected: onMenuSelected,
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit',   child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
          PopupMenuItem(value: 'rename', child: Text('Rename')),
        ],
      ),
    ]);

    return GenericBar(
      label: title,
      color: color,
      onTap: onTap,
      trailing: trailing,
    );
  }
}

class _AutomaticBadge extends StatelessWidget {
  const _AutomaticBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16, height: 16,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}