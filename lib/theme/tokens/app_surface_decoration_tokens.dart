import 'package:flutter/material.dart';

/// Semantic surface roles understood by shared Tonos surface renderers.
enum AppSurfaceDecorationRole {
  panel,
  panelRaised,
  card,
  compactCard,
  input,
  sheet,
  media,
  mediaPlaceholder,
}

/// Selects the depth mechanism for a semantic surface.
enum AppSurfaceDepth { none, materialElevation, explicitShadow }

/// Outline and depth policy for one semantic surface role.
@immutable
class AppSurfaceDecoration {
  const AppSurfaceDecoration({
    this.outlined = false,
    this.depth = AppSurfaceDepth.none,
  });

  static const flat = AppSurfaceDecoration();
  static const outlinedOnly = AppSurfaceDecoration(outlined: true);
  static const compactShadow = AppSurfaceDecoration(
    depth: AppSurfaceDepth.explicitShadow,
  );
  static const outlinedCompactShadow = AppSurfaceDecoration(
    outlined: true,
    depth: AppSurfaceDepth.explicitShadow,
  );

  final bool outlined;
  final AppSurfaceDepth depth;

  AppSurfaceDecoration copyWith({bool? outlined, AppSurfaceDepth? depth}) {
    return AppSurfaceDecoration(
      outlined: outlined ?? this.outlined,
      depth: depth ?? this.depth,
    );
  }

  static AppSurfaceDecoration lerp(
    AppSurfaceDecoration a,
    AppSurfaceDecoration b,
    double t,
  ) {
    // Booleans and enum depth mechanisms cannot be interpolated meaningfully.
    return t < 0.5 ? a : b;
  }

  @override
  bool operator ==(Object other) {
    return other is AppSurfaceDecoration &&
        other.outlined == outlined &&
        other.depth == depth;
  }

  @override
  int get hashCode => Object.hash(outlined, depth);
}

/// Theme-owned outline and depth recipes for custom Tonos surfaces.
@immutable
class AppSurfaceDecorationTokens
    extends ThemeExtension<AppSurfaceDecorationTokens> {
  const AppSurfaceDecorationTokens({
    required this.panel,
    required this.panelRaised,
    required this.card,
    required this.compactCard,
    required this.input,
    required this.sheet,
    required this.media,
    required this.mediaPlaceholder,
  });

  /// The unchanged decoration policy used by the Classic family.
  static const classic = AppSurfaceDecorationTokens(
    panel: AppSurfaceDecoration.flat,
    panelRaised: AppSurfaceDecoration.flat,
    card: AppSurfaceDecoration(depth: AppSurfaceDepth.materialElevation),
    compactCard: AppSurfaceDecoration.compactShadow,
    input: AppSurfaceDecoration.outlinedOnly,
    sheet: AppSurfaceDecoration(depth: AppSurfaceDepth.materialElevation),
    media: AppSurfaceDecoration.flat,
    mediaPlaceholder: AppSurfaceDecoration.flat,
  );

  final AppSurfaceDecoration panel;
  final AppSurfaceDecoration panelRaised;
  final AppSurfaceDecoration card;
  final AppSurfaceDecoration compactCard;
  final AppSurfaceDecoration input;
  final AppSurfaceDecoration sheet;
  final AppSurfaceDecoration media;
  final AppSurfaceDecoration mediaPlaceholder;

  AppSurfaceDecoration forRole(AppSurfaceDecorationRole role) => switch (role) {
    AppSurfaceDecorationRole.panel => panel,
    AppSurfaceDecorationRole.panelRaised => panelRaised,
    AppSurfaceDecorationRole.card => card,
    AppSurfaceDecorationRole.compactCard => compactCard,
    AppSurfaceDecorationRole.input => input,
    AppSurfaceDecorationRole.sheet => sheet,
    AppSurfaceDecorationRole.media => media,
    AppSurfaceDecorationRole.mediaPlaceholder => mediaPlaceholder,
  };

  @override
  AppSurfaceDecorationTokens copyWith({
    AppSurfaceDecoration? panel,
    AppSurfaceDecoration? panelRaised,
    AppSurfaceDecoration? card,
    AppSurfaceDecoration? compactCard,
    AppSurfaceDecoration? input,
    AppSurfaceDecoration? sheet,
    AppSurfaceDecoration? media,
    AppSurfaceDecoration? mediaPlaceholder,
  }) {
    return AppSurfaceDecorationTokens(
      panel: panel ?? this.panel,
      panelRaised: panelRaised ?? this.panelRaised,
      card: card ?? this.card,
      compactCard: compactCard ?? this.compactCard,
      input: input ?? this.input,
      sheet: sheet ?? this.sheet,
      media: media ?? this.media,
      mediaPlaceholder: mediaPlaceholder ?? this.mediaPlaceholder,
    );
  }

  @override
  AppSurfaceDecorationTokens lerp(
    covariant ThemeExtension<AppSurfaceDecorationTokens>? other,
    double t,
  ) {
    if (other is! AppSurfaceDecorationTokens) return this;
    return AppSurfaceDecorationTokens(
      panel: AppSurfaceDecoration.lerp(panel, other.panel, t),
      panelRaised: AppSurfaceDecoration.lerp(panelRaised, other.panelRaised, t),
      card: AppSurfaceDecoration.lerp(card, other.card, t),
      compactCard: AppSurfaceDecoration.lerp(compactCard, other.compactCard, t),
      input: AppSurfaceDecoration.lerp(input, other.input, t),
      sheet: AppSurfaceDecoration.lerp(sheet, other.sheet, t),
      media: AppSurfaceDecoration.lerp(media, other.media, t),
      mediaPlaceholder: AppSurfaceDecoration.lerp(
        mediaPlaceholder,
        other.mediaPlaceholder,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSurfaceDecorationTokens &&
        other.panel == panel &&
        other.panelRaised == panelRaised &&
        other.card == card &&
        other.compactCard == compactCard &&
        other.input == input &&
        other.sheet == sheet &&
        other.media == media &&
        other.mediaPlaceholder == mediaPlaceholder;
  }

  @override
  int get hashCode => Object.hash(
    panel,
    panelRaised,
    card,
    compactCard,
    input,
    sheet,
    media,
    mediaPlaceholder,
  );
}
