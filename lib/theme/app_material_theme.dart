import 'package:flutter/material.dart';

/// Builds the shared Material baseline used by every theme family.
///
/// `ThemeData.from` remains the source of ordinary Material component
/// recipes. This boundary only adds the app-owned bottom-navigation recipe;
/// ordinary app bars, sheets, dialogs, dividers, FABs, and other Material
/// defaults remain framework-owned so Classic does not drift from its
/// pre-theme behavior.
abstract final class AppMaterialTheme {
  static ThemeData fromColorScheme({required ColorScheme colorScheme}) {
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
