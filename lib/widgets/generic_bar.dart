import 'package:flutter/material.dart';

/// A tappable bar with a colored border & optional trailing widget.
/// This is the base building-block for things that look like your current PresetBar.
class GenericBar extends StatelessWidget {
  /// The main text label.
  final String label;

  /// The accent color (used for border, text, splash).
  final Color color;

  /// Called on tap. If null, the bar is not tappable.
  final VoidCallback? onTap;

  /// An optional widget displayed at the trailing end (e.g. menu button).
  final Widget? trailing;

  const GenericBar({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
