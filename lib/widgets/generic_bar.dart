// File: lib/widgets/generic_bar.dart

import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_surface_decoration_tokens.dart';

/// A tappable bar with a colored border & optional trailing widget.
/// You can adjust its overall size by passing [scale].
class GenericBar extends StatelessWidget {
  /// The main text label.
  final String label;

  /// The accent color (used for border, text, splash).
  final Color? color;

  /// Optional Neo fill that remains separate from the identity accent.
  final Color? fillColor;

  /// Optional foreground override for a filled Neo bar.
  final Color? foregroundColor;

  /// Optional identity rail shown on the leading edge of a filled Neo bar.
  final Color? markerColor;

  /// Called on tap. If null, the bar isn’t tappable.
  final VoidCallback? onTap;

  /// An optional widget displayed at the trailing end.
  final Widget? trailing;

  /// An optional widget displayed before the label.
  final Widget? leading;

  /// Uniform scale factor for all dimensions (padding, radius, border width, font size).
  final double scale;

  const GenericBar({
    super.key,
    required this.label,
    this.color,
    this.fillColor,
    this.foregroundColor,
    this.markerColor,
    this.onTap,
    this.trailing,
    this.leading,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // pick the theme’s accent if none was passed in
    final accent = color ?? context.dataVisualizationTokens.primarySeries;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final effects = context.effectTokens;
    final decoration = context.surfaceDecorationTokens.compactCard;
    final usesInkRecipe = decoration.outlined;
    final foreground =
        usesInkRecipe
            ? foregroundColor ?? context.cs.onPrimaryContainer
            : accent;
    final resolvedFill =
        usesInkRecipe ? fillColor ?? accent : accent.withValues(alpha: 0.1);
    final resolvedBorder = usesInkRecipe ? surfaces.subtleOutline : accent;
    // base constants × scale
    final borderRadius =
        BorderRadius.lerp(BorderRadius.zero, shapes.compact, scale)!;
    final horizontalPadding = 12 * scale;
    final verticalPadding = 16 * scale;
    final borderWidth = shapes.outlineWidth * scale;
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';

    final shadow =
        usesInkRecipe && decoration.depth == AppSurfaceDepth.explicitShadow
            ? BoxShadow(
              color: effects.cardShadow,
              blurRadius: effects.cardShadowBlur,
              offset: effects.cardShadowOffset,
            )
            : null;
    final hasMarker = markerColor != null && usesInkRecipe;
    Widget bar = Material(
      color: resolvedFill,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.2),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: resolvedBorder, width: borderWidth),
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              Padding(
                padding:
                    hasMarker
                        ? EdgeInsets.only(left: 12 * scale)
                        : EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      SizedBox(width: 10 * scale),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        maxLines: usesLocalizedLayout ? 2 : 1,
                        overflow:
                            usesLocalizedLayout ? null : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
              if (hasMarker)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 4 * scale,
                    child: ColoredBox(color: markerColor!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (shadow != null &&
        (shadow.blurRadius > 0 || shadow.offset != Offset.zero)) {
      bar = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [shadow],
        ),
        child: bar,
      );
    }
    return bar;
  }
}
