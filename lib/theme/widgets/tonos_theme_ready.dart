import 'package:flutter/material.dart';

import '../theme_extensions.dart';
import 'tonos_surface.dart';

/// Keeps legacy cards compatible with both theme families while their feature
/// layouts are still evolving. Classic retains the Material card recipe;
/// Neo gets a semantic Tonos surface without requiring a final redesign.
class TonosThemeReadyCard extends StatelessWidget {
  const TonosThemeReadyCard({
    super.key,
    required this.child,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.variant = TonosSurfaceVariant.card,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final TonosSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    if (!context.surfaceDecorationTokens.card.outlined) {
      return Card(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    return TonosSurface(
      variant: variant,
      color: color,
      margin: margin,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
