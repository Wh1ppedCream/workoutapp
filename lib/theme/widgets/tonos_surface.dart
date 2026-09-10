import 'package:flutter/material.dart';

import '../theme_extensions.dart';

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
    this.padding = EdgeInsets.zero,
    this.margin,
    this.outlined,
    this.clipBehavior,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final TonosSurfaceVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// Overrides the variant's default outline policy when provided.
  final bool? outlined;

  /// Overrides the variant's default clipping policy when provided.
  final Clip? clipBehavior;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final effects = context.effectTokens;

    final Color backgroundColor;
    final BorderRadiusGeometry borderRadius;
    final bool defaultOutlined;
    final Clip defaultClipBehavior;
    final double elevation;
    final BoxShadow? shadow;

    switch (variant) {
      case TonosSurfaceVariant.panel:
        backgroundColor = surfaces.panel;
        borderRadius = shapes.control;
        defaultOutlined = false;
        defaultClipBehavior = Clip.none;
        elevation = 0;
        shadow = null;
      case TonosSurfaceVariant.panelRaised:
        backgroundColor = surfaces.panelRaised;
        borderRadius = shapes.control;
        defaultOutlined = false;
        defaultClipBehavior = Clip.none;
        elevation = 0;
        shadow = null;
      case TonosSurfaceVariant.card:
        backgroundColor = surfaces.card;
        borderRadius = shapes.card;
        defaultOutlined = false;
        defaultClipBehavior = Clip.none;
        elevation = effects.cardElevation;
        shadow = null;
      case TonosSurfaceVariant.compactCard:
        backgroundColor = surfaces.card;
        borderRadius = shapes.control;
        defaultOutlined = false;
        defaultClipBehavior = Clip.none;
        elevation = 0;
        shadow = BoxShadow(
          color: effects.cardShadow,
          blurRadius: effects.cardShadowBlur,
          offset: effects.cardShadowOffset,
        );
      case TonosSurfaceVariant.input:
        backgroundColor = surfaces.input;
        borderRadius = shapes.control;
        defaultOutlined = true;
        defaultClipBehavior = Clip.none;
        elevation = 0;
        shadow = null;
      case TonosSurfaceVariant.media:
        backgroundColor = surfaces.media;
        borderRadius = shapes.card;
        defaultOutlined = false;
        defaultClipBehavior = Clip.antiAlias;
        elevation = 0;
        shadow = null;
      case TonosSurfaceVariant.mediaPlaceholder:
        backgroundColor = surfaces.mediaPlaceholder;
        borderRadius = shapes.card;
        defaultOutlined = false;
        defaultClipBehavior = Clip.antiAlias;
        elevation = 0;
        shadow = null;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side:
          (outlined ?? defaultOutlined)
              ? BorderSide(
                color: surfaces.subtleOutline,
                width: shapes.outlineWidth,
              )
              : BorderSide.none,
    );
    final effectiveClipBehavior = clipBehavior ?? defaultClipBehavior;

    Widget contents = Padding(padding: padding, child: child);
    if (onTap != null) {
      contents = InkWell(onTap: onTap, customBorder: shape, child: contents);
    }

    Widget surface = Material(
      color: backgroundColor,
      elevation: elevation,
      shadowColor: effects.shadowColor,
      shape: shape,
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
    if (shadow != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [shadow],
        ),
        child: surface,
      );
    }

    return Container(margin: margin, child: surface);
  }
}
