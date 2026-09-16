import 'package:flutter/material.dart';

import 'app_theme_family.dart';
import 'classic_theme.dart';
import 'neo_brutalism_theme.dart';

/// Cached theme lookup boundary for all theme families.
///
/// Each registered family must render complete cached light and dark variants
/// without requiring feature widgets to know which family is active.
abstract final class AppThemeFactory {
  static final ThemeData _classicLight = ClassicThemeDefinition.light();
  static final ThemeData _classicDark = ClassicThemeDefinition.dark();
  static final ThemeData _neoBrutalismLight =
      NeoBrutalismThemeDefinition.light();
  static final ThemeData _neoBrutalismDark = NeoBrutalismThemeDefinition.dark();

  static ThemeData light(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => _classicLight,
    AppThemeFamily.neoBrutalism => _neoBrutalismLight,
  };

  static ThemeData dark(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => _classicDark,
    AppThemeFamily.neoBrutalism => _neoBrutalismDark,
  };
}
