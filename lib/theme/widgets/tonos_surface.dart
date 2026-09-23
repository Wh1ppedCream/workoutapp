import 'package:flutter/material.dart';

import '../theme_extensions.dart';
import '../tokens/app_surface_decoration_tokens.dart';

/// Semantic surface recipes used by custom Tonos structures.
enum TonosSurfaceVariant {
  panel,
  panelRaised,
  card,
  compactCard,
  input,
  media,
  mediaPlaceholder,
}

/// A theme-driven surface for UI that is more specific than a Material card.
///
/// The variant selects colors, geometry, clipping, and depth from the active
/// theme. Feature widgets provide content and behavior without supplying raw
/// visual values.
class TonosSurface extends StatelessWidget {
  const TonosSurface({
    super.key,
    required this.child,
    this.variant = TonosSurfaceVariant.panel,
    this.color,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.borderRadius,
    this.outlined,
    this.clipBehavior,
    this.shape,
    this.elevation,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final TonosSurfaceVariant variant;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// Overrides the variant's theme-owned radius for a specific production
  /// composition while keeping color, outline, and depth centralized here.
  final BorderRadiusGeometry? borderRadius;

  /// Overrides the variant's default outline policy when provided.
  final bool? outlined;

  /// Overrides the variant's default clipping policy when provided.
  final Clip? clipBehavior;

  /// Preserves an explicit production shape across the Neo surface boundary.
  final ShapeBorder? shape;

  /// Preserves an explicit production elevation across the Neo surface
  /// boundary.
  final double? elevation;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;
    final decoration = context.surfaceDecorationTokens.forRole(
      _decorationRoleForVariant(variant),
    );

    final Color backgroundColor;
    final BorderRadiusGeometry resolvedBorderRadius;
    final Clip defaultClipBehavior;

    switch (variant) {
      case TonosSurfaceVariant.panel:
        backgroundColor = color ?? surfaces.panel;
        resolvedBorderRadius = borderRadius ?? shapes.control;
        defaultClipBehavior = Clip.none;
      case TonosSurfaceVariant.panelRaised:
        backgroundColor = color ?? surfaces.panelRaised;
        resolvedBorderRadius = borderRadius ?? shapes.control;
        defaultClipBehavior = Clip.none;
      case TonosSurfaceVariant.card:
        backgroundColor = color ?? surfaces.card;
        resolvedBorderRadius = borderRadius ?? shapes.card;
        defaultClipBehavior = Clip.none;
      case TonosSurfaceVariant.compactCard:
        backgroundColor = color ?? surfaces.card;
        resolvedBorderRadius = borderRadius ?? shapes.control;
        defaultClipBehavior = Clip.none;
      case TonosSurfaceVariant.input:
        backgroundColor = color ?? surfaces.input;
        resolvedBorderRadius = borderRadius ?? shapes.control;
        defaultClipBehavior = Clip.none;
      case TonosSurfaceVariant.media:
        backgroundColor = color ?? surfaces.media;
        resolvedBorderRadius = borderRadius ?? shapes.card;
        defaultClipBehavior = Clip.antiAlias;
      case TonosSurfaceVariant.mediaPlaceholder:
        backgroundColor = color ?? surfaces.mediaPlaceholder;
        resolvedBorderRadius = borderRadius ?? shapes.card;
        defaultClipBehavior = Clip.antiAlias;
    }

    final elevation = switch (decoration.depth) {
      AppSurfaceDepth.materialElevation => effects.cardElevation,
      AppSurfaceDepth.none || AppSurfaceDepth.explicitShadow => 0.0,
    };
    final resolvedElevation = this.elevation ?? elevation;
    final shadowOffset = switch (variant) {
      TonosSurfaceVariant.panelRaised => effects.raisedPanelShadowOffset,
      _ => effects.cardShadowOffset,
    };
    final shadow = switch (decoration.depth) {
      AppSurfaceDepth.explicitShadow => BoxShadow(
        color: effects.cardShadow,
        blurRadius: effects.cardShadowBlur,
        offset: shadowOffset,
      ),
      AppSurfaceDepth.none || AppSurfaceDepth.materialElevation => null,
    };
    final visibleShadow =
        shadow != null && _hasVisibleShadow(shadow) ? shadow : null;
    final outlineColor =
        variant == TonosSurfaceVariant.input
            ? surfaces.neutralOutline
            : tonosOutlineForSurface(context, backgroundColor);

    final shape = RoundedRectangleBorder(
      borderRadius: resolvedBorderRadius,
      side:
          (outlined ?? decoration.outlined)
              ? BorderSide(color: outlineColor, width: shapes.outlineWidth)
              : BorderSide.none,
    );
    final resolvedShape = _resolveSurfaceShape(
      customShape: this.shape,
      fallback: shape,
      outline: shape.side,
    );
    final shadowBorderRadius =
        resolvedShape is RoundedRectangleBorder
            ? resolvedShape.borderRadius
            : resolvedBorderRadius;
    final effectiveClipBehavior = clipBehavior ?? defaultClipBehavior;

    Widget contents = Padding(padding: padding, child: child);
    if (onTap != null) {
      contents = InkWell(
        onTap: onTap,
        customBorder: resolvedShape,
        child: contents,
      );
    }

    Widget surface = Material(
      color: backgroundColor,
      elevation: resolvedElevation,
      shadowColor: effects.shadowColor,
      shape: resolvedShape,
      clipBehavior: effectiveClipBehavior,
      child: contents,
    );
    if (semanticLabel != null) {
      surface = Semantics(
        container: true,
        label: semanticLabel,
        child: surface,
      );
    }
    if (visibleShadow != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shadowBorderRadius,
          boxShadow: [visibleShadow],
        ),
        child: surface,
      );
    }

    return Container(margin: margin, child: surface);
  }
}

ShapeBorder _resolveSurfaceShape({
  required ShapeBorder? customShape,
  required RoundedRectangleBorder fallback,
  required BorderSide outline,
}) {
  if (customShape is RoundedRectangleBorder &&
      outline != BorderSide.none &&
      customShape.side == BorderSide.none) {
    return customShape.copyWith(side: outline);
  }
  return customShape ?? fallback;
}

AppSurfaceDecorationRole _decorationRoleForVariant(
  TonosSurfaceVariant variant,
) => switch (variant) {
  TonosSurfaceVariant.panel => AppSurfaceDecorationRole.panel,
  TonosSurfaceVariant.panelRaised => AppSurfaceDecorationRole.panelRaised,
  TonosSurfaceVariant.card => AppSurfaceDecorationRole.card,
  TonosSurfaceVariant.compactCard => AppSurfaceDecorationRole.compactCard,
  TonosSurfaceVariant.input => AppSurfaceDecorationRole.input,
  TonosSurfaceVariant.media => AppSurfaceDecorationRole.media,
  TonosSurfaceVariant.mediaPlaceholder =>
    AppSurfaceDecorationRole.mediaPlaceholder,
};

bool _hasVisibleShadow(BoxShadow shadow) {
  return shadow.color.a > 0 &&
      (shadow.blurRadius > 0 ||
          shadow.spreadRadius != 0 ||
          shadow.offset != Offset.zero);
}
