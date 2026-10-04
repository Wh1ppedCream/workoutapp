import 'package:material_ui/material_ui.dart';

import 'theme_extensions.dart';

/// Presentation colors for the Expressive plan, equipment, and configuration
/// pages. These colors do not own plan identity or status semantics.
@immutable
class AppExpressivePlanningTokens {
  const AppExpressivePlanningTokens({
    required this.pageCanvas,
    required this.planFocalSurface,
    required this.planFocalForeground,
    required this.planSupportSurface,
    required this.planSupportForeground,
    required this.equipmentSurface,
    required this.equipmentForeground,
    required this.configurationSurface,
    required this.configurationForeground,
    required this.actionPrimary,
    required this.actionPrimaryForeground,
    required this.actionSecondary,
    required this.actionSecondaryForeground,
    required this.selectedSurface,
    required this.outline,
    required this.onPage,
  });

  final Color pageCanvas;
  final Color planFocalSurface;
  final Color planFocalForeground;
  final Color planSupportSurface;
  final Color planSupportForeground;
  final Color equipmentSurface;
  final Color equipmentForeground;
  final Color configurationSurface;
  final Color configurationForeground;
  final Color actionPrimary;
  final Color actionPrimaryForeground;
  final Color actionSecondary;
  final Color actionSecondaryForeground;
  final Color selectedSurface;
  final Color outline;
  final Color onPage;

  /// Returns planning tokens only for a theme explicitly marked Expressive.
  static AppExpressivePlanningTokens? maybeOf(BuildContext context) {
    final theme = Theme.of(context);
    if (!theme.usesExpressivePresentation) return null;
    return theme.brightness == Brightness.dark ? dark : light;
  }

  static const light = AppExpressivePlanningTokens(
    pageCanvas: Color(0xFFFFF4E9),
    planFocalSurface: Color(0xFF47205F),
    planFocalForeground: Color(0xFFFFF7FF),
    planSupportSurface: Color(0xFFFFE8D7),
    planSupportForeground: Color(0xFF422B21),
    equipmentSurface: Color(0xFFFFE4B7),
    equipmentForeground: Color(0xFF402A17),
    configurationSurface: Color(0xFFE1D0FF),
    configurationForeground: Color(0xFF342049),
    actionPrimary: Color(0xFF5421A4),
    actionPrimaryForeground: Color(0xFFFFFFFF),
    actionSecondary: Color(0xFFC7EEE2),
    actionSecondaryForeground: Color(0xFF123D35),
    selectedSurface: Color(0xFF54247C),
    outline: Color(0xFF855F8A),
    onPage: Color(0xFF39254A),
  );

  static const dark = AppExpressivePlanningTokens(
    pageCanvas: Color(0xFF19121F),
    planFocalSurface: Color(0xFF30203C),
    planFocalForeground: Color(0xFFF8ECFF),
    planSupportSurface: Color(0xFF33231F),
    planSupportForeground: Color(0xFFF5E8DF),
    equipmentSurface: Color(0xFF45301D),
    equipmentForeground: Color(0xFFF4E5D2),
    configurationSurface: Color(0xFF392A4A),
    configurationForeground: Color(0xFFF1E4FF),
    actionPrimary: Color(0xFFD5B8FF),
    actionPrimaryForeground: Color(0xFF2F1245),
    actionSecondary: Color(0xFF204A43),
    actionSecondaryForeground: Color(0xFFC5F1E4),
    selectedSurface: Color(0xFFE4C4FF),
    outline: Color(0xFFAB91B8),
    onPage: Color(0xFFE2D5EA),
  );
}
