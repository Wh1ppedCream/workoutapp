import 'package:flutter/material.dart';

/// Detail-media geometry and overlay effects, separate from anatomy data colors.
@immutable
class AppMediaTokens extends ThemeExtension<AppMediaTokens> {
  const AppMediaTokens({
    this.editorAddSurface = const Color(0xFFEEEEEE),
    this.editorItemSurface = const Color(0xFFE0E0E0),
    this.editorShape = const BorderRadius.all(Radius.circular(12)),
    this.previewShape = const BorderRadius.all(Radius.circular(18)),
    this.overlayShape = const BorderRadius.all(Radius.circular(12)),
    this.viewerShape = const BorderRadius.all(Radius.circular(20)),
    this.overlayOpacity = 0.96,
    this.overlayShadow = const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.30),
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
    ],
  });

  static const classic = AppMediaTokens();
  final Color editorAddSurface;
  final Color editorItemSurface;
  final BorderRadius editorShape;
  final BorderRadius previewShape;
  final BorderRadius overlayShape;
  final BorderRadius viewerShape;
  final double overlayOpacity;
  final List<BoxShadow> overlayShadow;

  @override
  AppMediaTokens copyWith({
    Color? editorAddSurface,
    Color? editorItemSurface,
    BorderRadius? editorShape,
    BorderRadius? previewShape,
    BorderRadius? overlayShape,
    BorderRadius? viewerShape,
    double? overlayOpacity,
    List<BoxShadow>? overlayShadow,
  }) => AppMediaTokens(
    editorAddSurface: editorAddSurface ?? this.editorAddSurface,
    editorItemSurface: editorItemSurface ?? this.editorItemSurface,
    editorShape: editorShape ?? this.editorShape,
    previewShape: previewShape ?? this.previewShape,
    overlayShape: overlayShape ?? this.overlayShape,
    viewerShape: viewerShape ?? this.viewerShape,
    overlayOpacity: overlayOpacity ?? this.overlayOpacity,
    overlayShadow:
        overlayShadow == null
            ? this.overlayShadow
            : List<BoxShadow>.unmodifiable(overlayShadow),
  );

  @override
  AppMediaTokens lerp(covariant AppMediaTokens? other, double t) {
    if (other == null) return this;
    // Preserve exact endpoints, including an empty effects list.
    if (t == 0) return this;
    if (t == 1) return other;
    return AppMediaTokens(
      editorAddSurface:
          Color.lerp(editorAddSurface, other.editorAddSurface, t)!,
      editorItemSurface:
          Color.lerp(editorItemSurface, other.editorItemSurface, t)!,
      editorShape: BorderRadius.lerp(editorShape, other.editorShape, t)!,
      previewShape: BorderRadius.lerp(previewShape, other.previewShape, t)!,
      overlayShape: BorderRadius.lerp(overlayShape, other.overlayShape, t)!,
      viewerShape: BorderRadius.lerp(viewerShape, other.viewerShape, t)!,
      overlayOpacity:
          overlayOpacity + (other.overlayOpacity - overlayOpacity) * t,
      overlayShadow: List<BoxShadow>.unmodifiable(
        BoxShadow.lerpList(overlayShadow, other.overlayShadow, t)!,
      ),
    );
  }
}

/// Fixed image-viewing contrast; these values do not encode app or anatomy state.
abstract final class MediaViewingColors {
  static const backdrop = Colors.black;
  static const barrier = Colors.black87;
  static const indicator = Color.fromRGBO(0, 0, 0, 0.45);
  static const onIndicator = Colors.white;
  static const hint = Colors.white70;
}
