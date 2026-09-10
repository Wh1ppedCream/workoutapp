import 'package:flutter/material.dart';

import 'app_theme_family.dart';
import 'classic_theme.dart';

/// Cached theme lookup boundary for all theme families.
///
/// Only Classic is registered today. New families should be added here after
/// they can render a complete light and dark theme without changing callers.
abstract final class AppThemeFactory {
  static final ThemeData _classicLight = ClassicThemeDefinition.light();
  static final ThemeData _classicDark = ClassicThemeDefinition.dark();

  static ThemeData light(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => _classicLight,
  };

  static ThemeData dark(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => _classicDark,
  };
}
