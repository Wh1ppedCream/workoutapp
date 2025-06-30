// File: lib/widgets/preset_bar.dart

import 'package:flutter/material.dart';

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

  /// Creates a [PresetBar].
  const PresetBar({
    super.key,
    this.label,
    required this.color,
    required this.index,
    this.onTap,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final title = (label?.trim().isNotEmpty ?? false)
        ? label!
        : 'Preset ${index + 1}';

    return Material(
      color: color.withValues(alpha: 0.1),
      //need to make colors different for each preset
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: color),
                onSelected: (action) {
                  onMenuSelected?.call(action);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                  PopupMenuItem(value: 'profile_swap', child: Text('Profile Swap')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
