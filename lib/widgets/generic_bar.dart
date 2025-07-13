// File: lib/widgets/generic_bar.dart

import 'package:flutter/material.dart';

/// A tappable bar with a colored border & optional trailing widget.
/// You can adjust its overall size by passing [scale].
class GenericBar extends StatelessWidget {
  /// The main text label.
  final String label;

  /// The accent color (used for border, text, splash).
  final Color color;

  /// Called on tap. If null, the bar isn’t tappable.
  final VoidCallback? onTap;

  /// An optional widget displayed at the trailing end.
  final Widget? trailing;

  /// Uniform scale factor for all dimensions (padding, radius, border width, font size).
  final double scale;

  const GenericBar({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.trailing,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // base constants × scale
    final borderRadius = BorderRadius.circular(8 * scale);
    final horizontalPadding = 12 * scale;
    final verticalPadding = 16 * scale;
    final borderWidth = 1 * scale;

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: borderWidth),
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
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
