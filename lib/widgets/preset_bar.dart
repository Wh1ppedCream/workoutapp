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

final VoidCallback? onTap;

  /// Creates a [PresetBar].
  ///
  /// [color] is required; [label] optional; [index] used if label is null.
  const PresetBar({
    super.key,
    this.label,
    required this.color,
    required this.index,
    this.onTap,  
  });

  @override
  Widget build(BuildContext context) {
    // Determine display text
    final title = label?.trim().isNotEmpty == true
        ? label!
        : 'Preset ${index + 1}';

    return Material(
      color: color.withValues(alpha: 0.1),
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
                onSelected: (_) {},
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'schedule', child: Text('Schedule')),
                  PopupMenuItem(value: 'profile_swap', child: Text('Profile Swap')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
