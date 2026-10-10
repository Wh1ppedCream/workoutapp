import 'package:material_ui/material_ui.dart';

/// Candidate-only chromatic roles for the unapproved Expressive destinations.
///
/// These are presentation surfaces and foreground pairings. Success, error,
/// workout status, plan identity, chart series, and heatmap colors retain their
/// existing semantic/data owners.
enum AppExpressiveDestinationFamily {
  catalog,
  progress,
  logbook,
  profile,
  analytics,
  dashboard,
  nutrition,
}

@immutable
class AppExpressiveDestinationTokens
    extends ThemeExtension<AppExpressiveDestinationTokens> {
  const AppExpressiveDestinationTokens({
    required this.family,
    required this.pageCanvas,
    required this.surfacePrimary,
    required this.onSurfacePrimary,
    required this.surfaceSecondary,
    required this.onSurfaceSecondary,
    required this.surfaceTertiary,
    required this.onSurfaceTertiary,
    required this.surfaceAccent,
    required this.onSurfaceAccent,
    required this.surfaceSelected,
    required this.onSurfaceSelected,
    required this.actionPrimary,
    required this.onActionPrimary,
    required this.outlineAccent,
    required this.supportingForeground,
  });

  final AppExpressiveDestinationFamily family;

  /// Destination canvas role, applied only by a destination-owned widget.
  final Color pageCanvas;

  /// Focal surface and its readable foreground.
  final Color surfacePrimary;
  final Color onSurfacePrimary;

  /// Secondary chromatic surface and its readable foreground.
  final Color surfaceSecondary;
  final Color onSurfaceSecondary;

  /// Warm or complementary surface and its readable foreground.
  final Color surfaceTertiary;
  final Color onSurfaceTertiary;

  /// A distinct cool or destination-support surface.
  final Color surfaceAccent;
  final Color onSurfaceAccent;

  /// Clear selected-state treatment for destination-owned controls.
  final Color surfaceSelected;
  final Color onSurfaceSelected;

  /// Destination primary action treatment.
  final Color actionPrimary;
  final Color onActionPrimary;

  /// Accent for outlines and small emphasis marks.
  final Color outlineAccent;

  /// Supporting copy on the destination canvas.
  final Color supportingForeground;

  static AppExpressiveDestinationTokens forFamily(
    AppExpressiveDestinationFamily family,
    Brightness brightness,
  ) => switch ((family, brightness)) {
    (AppExpressiveDestinationFamily.catalog, Brightness.light) => _catalogLight,
    (AppExpressiveDestinationFamily.catalog, Brightness.dark) => _catalogDark,
    (AppExpressiveDestinationFamily.progress, Brightness.light) =>
      _progressLight,
    (AppExpressiveDestinationFamily.progress, Brightness.dark) => _progressDark,
    (AppExpressiveDestinationFamily.logbook, Brightness.light) => _logbookLight,
    (AppExpressiveDestinationFamily.logbook, Brightness.dark) => _logbookDark,
    (AppExpressiveDestinationFamily.profile, Brightness.light) => _profileLight,
    (AppExpressiveDestinationFamily.profile, Brightness.dark) => _profileDark,
    (AppExpressiveDestinationFamily.analytics, Brightness.light) =>
      _analyticsLight,
    (AppExpressiveDestinationFamily.analytics, Brightness.dark) =>
      _analyticsDark,
    (AppExpressiveDestinationFamily.dashboard, Brightness.light) =>
      _dashboardLight,
    (AppExpressiveDestinationFamily.dashboard, Brightness.dark) =>
      _dashboardDark,
    (AppExpressiveDestinationFamily.nutrition, Brightness.light) =>
      _nutritionLight,
    (AppExpressiveDestinationFamily.nutrition, Brightness.dark) =>
      _nutritionDark,
  };

  static const _catalogLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.catalog,
    pageCanvas: Color(0xFFFFF4E9),
    surfacePrimary: Color(0xFF532471),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFBDE9DD),
    onSurfaceSecondary: Color(0xFF153B35),
    surfaceTertiary: Color(0xFFFFD8B5),
    onSurfaceTertiary: Color(0xFF49260F),
    surfaceAccent: Color(0xFFC4DFFF),
    onSurfaceAccent: Color(0xFF18344E),
    surfaceSelected: Color(0xFFD7B8F1),
    onSurfaceSelected: Color(0xFF361346),
    actionPrimary: Color(0xFF532471),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF6B328A),
    supportingForeground: Color(0xFF4B3C51),
  );

  static const _catalogDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.catalog,
    pageCanvas: Color(0xFF19121F),
    surfacePrimary: Color(0xFF4A275E),
    onSurfacePrimary: Color(0xFFFFF7FF),
    surfaceSecondary: Color(0xFF17483F),
    onSurfaceSecondary: Color(0xFFC7F1E5),
    surfaceTertiary: Color(0xFF55321E),
    onSurfaceTertiary: Color(0xFFFFE0BD),
    surfaceAccent: Color(0xFF1F3E59),
    onSurfaceAccent: Color(0xFFD3E8FF),
    surfaceSelected: Color(0xFF482F60),
    onSurfaceSelected: Color(0xFFE8CEFF),
    actionPrimary: Color(0xFFDCC0FF),
    onActionPrimary: Color(0xFF321447),
    outlineAccent: Color(0xFFCF9FEF),
    supportingForeground: Color(0xFFE3D5E9),
  );

  static const _progressLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.progress,
    pageCanvas: Color(0xFFFFF4E9),
    surfacePrimary: Color(0xFF4E2868),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFC4E3FF),
    onSurfaceSecondary: Color(0xFF19364F),
    surfaceTertiary: Color(0xFFBCEBDD),
    onSurfaceTertiary: Color(0xFF153B35),
    surfaceAccent: Color(0xFFFFDDC1),
    onSurfaceAccent: Color(0xFF4A2B17),
    surfaceSelected: Color(0xFFD8BDF2),
    onSurfaceSelected: Color(0xFF37174B),
    actionPrimary: Color(0xFF4E2868),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF674080),
    supportingForeground: Color(0xFF46394D),
  );

  static const _progressDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.progress,
    pageCanvas: Color(0xFF19121F),
    surfacePrimary: Color(0xFF432552),
    onSurfacePrimary: Color(0xFFFFF7FF),
    surfaceSecondary: Color(0xFF1D3850),
    onSurfaceSecondary: Color(0xFFD3E8FF),
    surfaceTertiary: Color(0xFF173F38),
    onSurfaceTertiary: Color(0xFFC7F1E5),
    surfaceAccent: Color(0xFF572C43),
    onSurfaceAccent: Color(0xFFFFE0BD),
    surfaceSelected: Color(0xFF462D5B),
    onSurfaceSelected: Color(0xFFE8CEFF),
    actionPrimary: Color(0xFFDCC0FF),
    onActionPrimary: Color(0xFF321447),
    outlineAccent: Color(0xFFC99BEA),
    supportingForeground: Color(0xFFE3D5E9),
  );

  static const _logbookLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.logbook,
    pageCanvas: Color(0xFFFFF4E9),
    surfacePrimary: Color(0xFF502367),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF2D1E0),
    onSurfaceSecondary: Color(0xFF482537),
    surfaceTertiary: Color(0xFFFFD8B8),
    onSurfaceTertiary: Color(0xFF49260F),
    surfaceAccent: Color(0xFFC6E2FA),
    onSurfaceAccent: Color(0xFF18344E),
    surfaceSelected: Color(0xFFE4C9F1),
    onSurfaceSelected: Color(0xFF3B194C),
    actionPrimary: Color(0xFF502367),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF6B328A),
    supportingForeground: Color(0xFF4B3B4A),
  );

  static const _logbookDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.logbook,
    pageCanvas: Color(0xFF19121F),
    surfacePrimary: Color(0xFF492653),
    onSurfacePrimary: Color(0xFFFFF7FF),
    surfaceSecondary: Color(0xFF482936),
    onSurfaceSecondary: Color(0xFFFFD9E9),
    surfaceTertiary: Color(0xFF55321E),
    onSurfaceTertiary: Color(0xFFFFE0BD),
    surfaceAccent: Color(0xFF1D3B52),
    onSurfaceAccent: Color(0xFFD3E8FF),
    surfaceSelected: Color(0xFF4B2D59),
    onSurfaceSelected: Color(0xFFF0D5FF),
    actionPrimary: Color(0xFFDCC0FF),
    onActionPrimary: Color(0xFF321447),
    outlineAccent: Color(0xFFD49AC0),
    supportingForeground: Color(0xFFE3D5E9),
  );

  static const _profileLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.profile,
    pageCanvas: Color(0xFFFFF4E9),
    surfacePrimary: Color(0xFF51246B),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFBDE9DD),
    onSurfaceSecondary: Color(0xFF153B35),
    surfaceTertiary: Color(0xFFDED0F3),
    onSurfaceTertiary: Color(0xFF352047),
    surfaceAccent: Color(0xFFC4DFFF),
    onSurfaceAccent: Color(0xFF18344E),
    surfaceSelected: Color(0xFFD4B7EE),
    onSurfaceSelected: Color(0xFF361346),
    actionPrimary: Color(0xFF51246B),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF6B328A),
    supportingForeground: Color(0xFF4B3C51),
  );

  static const _profileDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.profile,
    pageCanvas: Color(0xFF19121F),
    surfacePrimary: Color(0xFF492653),
    onSurfacePrimary: Color(0xFFFFF7FF),
    surfaceSecondary: Color(0xFF17483F),
    onSurfaceSecondary: Color(0xFFC7F1E5),
    surfaceTertiary: Color(0xFF382A4A),
    onSurfaceTertiary: Color(0xFFE8D6FF),
    surfaceAccent: Color(0xFF1F3E59),
    onSurfaceAccent: Color(0xFFD3E8FF),
    surfaceSelected: Color(0xFF482F60),
    onSurfaceSelected: Color(0xFFE8CEFF),
    actionPrimary: Color(0xFFDCC0FF),
    onActionPrimary: Color(0xFF321447),
    outlineAccent: Color(0xFFCF9FEF),
    supportingForeground: Color(0xFFE3D5E9),
  );

  static const _analyticsLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.analytics,
    pageCanvas: Color(0xFFF3F7F2),
    surfacePrimary: Color(0xFF284E48),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFFFD9A8),
    onSurfaceSecondary: Color(0xFF422B08),
    surfaceTertiary: Color(0xFFD8C8F0),
    onSurfaceTertiary: Color(0xFF302042),
    surfaceAccent: Color(0xFFBFE6E5),
    onSurfaceAccent: Color(0xFF103B3B),
    surfaceSelected: Color(0xFFC7E7D2),
    onSurfaceSelected: Color(0xFF173C2B),
    actionPrimary: Color(0xFF284E48),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF346D63),
    supportingForeground: Color(0xFF354A43),
  );

  static const _analyticsDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.analytics,
    pageCanvas: Color(0xFF131B19),
    surfacePrimary: Color(0xFF21463F),
    onSurfacePrimary: Color(0xFFF3FFFA),
    surfaceSecondary: Color(0xFF53391F),
    onSurfaceSecondary: Color(0xFFFFE4BC),
    surfaceTertiary: Color(0xFF3E3155),
    onSurfaceTertiary: Color(0xFFE9DBFF),
    surfaceAccent: Color(0xFF1B4143),
    onSurfaceAccent: Color(0xFFD0F4F2),
    surfaceSelected: Color(0xFF285342),
    onSurfaceSelected: Color(0xFFD3F5DF),
    actionPrimary: Color(0xFFB6E7D6),
    onActionPrimary: Color(0xFF103A31),
    outlineAccent: Color(0xFF87CBB9),
    supportingForeground: Color(0xFFD2E1DA),
  );

  static const _dashboardLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.dashboard,
    pageCanvas: Color(0xFFF4F1FA),
    surfacePrimary: Color(0xFF4E2868),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFFFD9B3),
    onSurfaceSecondary: Color(0xFF49260F),
    surfaceTertiary: Color(0xFFDFD1F0),
    onSurfaceTertiary: Color(0xFF352046),
    surfaceAccent: Color(0xFFBDE9DD),
    onSurfaceAccent: Color(0xFF153B35),
    surfaceSelected: Color(0xFFD7B8F1),
    onSurfaceSelected: Color(0xFF361346),
    actionPrimary: Color(0xFF4E2868),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF6B328A),
    supportingForeground: Color(0xFF4B3C51),
  );

  static const _dashboardDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.dashboard,
    pageCanvas: Color(0xFF19151F),
    surfacePrimary: Color(0xFF432552),
    onSurfacePrimary: Color(0xFFFFF7FF),
    surfaceSecondary: Color(0xFF55321E),
    onSurfaceSecondary: Color(0xFFFFE0BD),
    surfaceTertiary: Color(0xFF463152),
    onSurfaceTertiary: Color(0xFFF0DCFF),
    surfaceAccent: Color(0xFF17483F),
    onSurfaceAccent: Color(0xFFC7F1E5),
    surfaceSelected: Color(0xFF482F60),
    onSurfaceSelected: Color(0xFFE8CEFF),
    actionPrimary: Color(0xFFDCC0FF),
    onActionPrimary: Color(0xFF321447),
    outlineAccent: Color(0xFFCF9FEF),
    supportingForeground: Color(0xFFE3D5E9),
  );

  static const _nutritionLight = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.nutrition,
    pageCanvas: Color(0xFFFFF2E7),
    surfacePrimary: Color(0xFF642A4E),
    onSurfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFB8E7D4),
    onSurfaceSecondary: Color(0xFF153A32),
    surfaceTertiary: Color(0xFFFFD5A6),
    onSurfaceTertiary: Color(0xFF49270D),
    surfaceAccent: Color(0xFFC6DFFF),
    onSurfaceAccent: Color(0xFF18344E),
    surfaceSelected: Color(0xFFE6BFDA),
    onSurfaceSelected: Color(0xFF48243B),
    actionPrimary: Color(0xFF532471),
    onActionPrimary: Color(0xFFFFFFFF),
    outlineAccent: Color(0xFF78405F),
    supportingForeground: Color(0xFF4B3944),
  );

  static const _nutritionDark = AppExpressiveDestinationTokens(
    family: AppExpressiveDestinationFamily.nutrition,
    pageCanvas: Color(0xFF1B141A),
    surfacePrimary: Color(0xFF582744),
    onSurfacePrimary: Color(0xFFFFF7FB),
    surfaceSecondary: Color(0xFF16463D),
    onSurfaceSecondary: Color(0xFFC8F0E1),
    surfaceTertiary: Color(0xFF57371F),
    onSurfaceTertiary: Color(0xFFFFE3C2),
    surfaceAccent: Color(0xFF203D58),
    onSurfaceAccent: Color(0xFFD3E8FF),
    surfaceSelected: Color(0xFF553149),
    onSurfaceSelected: Color(0xFFFFD8ED),
    actionPrimary: Color(0xFFE2C7FF),
    onActionPrimary: Color(0xFF35164A),
    outlineAccent: Color(0xFFD29BBB),
    supportingForeground: Color(0xFFE6D4DE),
  );

  @override
  AppExpressiveDestinationTokens copyWith({
    AppExpressiveDestinationFamily? family,
    Color? pageCanvas,
    Color? surfacePrimary,
    Color? onSurfacePrimary,
    Color? surfaceSecondary,
    Color? onSurfaceSecondary,
    Color? surfaceTertiary,
    Color? onSurfaceTertiary,
    Color? surfaceAccent,
    Color? onSurfaceAccent,
    Color? surfaceSelected,
    Color? onSurfaceSelected,
    Color? actionPrimary,
    Color? onActionPrimary,
    Color? outlineAccent,
    Color? supportingForeground,
  }) {
    return AppExpressiveDestinationTokens(
      family: family ?? this.family,
      pageCanvas: pageCanvas ?? this.pageCanvas,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      onSurfacePrimary: onSurfacePrimary ?? this.onSurfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      onSurfaceTertiary: onSurfaceTertiary ?? this.onSurfaceTertiary,
      surfaceAccent: surfaceAccent ?? this.surfaceAccent,
      onSurfaceAccent: onSurfaceAccent ?? this.onSurfaceAccent,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      onSurfaceSelected: onSurfaceSelected ?? this.onSurfaceSelected,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      onActionPrimary: onActionPrimary ?? this.onActionPrimary,
      outlineAccent: outlineAccent ?? this.outlineAccent,
      supportingForeground: supportingForeground ?? this.supportingForeground,
    );
  }

  @override
  AppExpressiveDestinationTokens lerp(
    covariant ThemeExtension<AppExpressiveDestinationTokens>? other,
    double t,
  ) {
    if (other is! AppExpressiveDestinationTokens) return this;
    return AppExpressiveDestinationTokens(
      family: t < 0.5 ? family : other.family,
      pageCanvas: Color.lerp(pageCanvas, other.pageCanvas, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      onSurfacePrimary: Color.lerp(
        onSurfacePrimary,
        other.onSurfacePrimary,
        t,
      )!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      onSurfaceSecondary: Color.lerp(
        onSurfaceSecondary,
        other.onSurfaceSecondary,
        t,
      )!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      onSurfaceTertiary: Color.lerp(
        onSurfaceTertiary,
        other.onSurfaceTertiary,
        t,
      )!,
      surfaceAccent: Color.lerp(surfaceAccent, other.surfaceAccent, t)!,
      onSurfaceAccent: Color.lerp(onSurfaceAccent, other.onSurfaceAccent, t)!,
      surfaceSelected: Color.lerp(surfaceSelected, other.surfaceSelected, t)!,
      onSurfaceSelected: Color.lerp(
        onSurfaceSelected,
        other.onSurfaceSelected,
        t,
      )!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      onActionPrimary: Color.lerp(onActionPrimary, other.onActionPrimary, t)!,
      outlineAccent: Color.lerp(outlineAccent, other.outlineAccent, t)!,
      supportingForeground: Color.lerp(
        supportingForeground,
        other.supportingForeground,
        t,
      )!,
    );
  }
}
