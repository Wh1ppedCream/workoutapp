import 'package:flutter/material.dart';

/// Stable product identities for the app's visual theme families.
///
/// Display names and descriptions belong in localization resources. These
/// codes are storage and contract values and must not be renamed casually.
enum AppThemeFamily {
  /// The current Tonos appearance, supported permanently in light and dark.
  classic(
    code: 'classic',
    supportedBrightnesses: <Brightness>{Brightness.light, Brightness.dark},
  ),

  /// The development-only Neo-Brutalism appearance.
  neoBrutalism(
    code: 'neo_brutalism',
    supportedBrightnesses: <Brightness>{Brightness.light, Brightness.dark},
  );

  const AppThemeFamily({
    required this.code,
    required this.supportedBrightnesses,
  });

  final String code;
  final Set<Brightness> supportedBrightnesses;

  bool supports(Brightness brightness) =>
      supportedBrightnesses.contains(brightness);

  /// Returns null for unknown values so callers can apply a safe fallback.
  static AppThemeFamily? fromCode(String? code) {
    for (final family in AppThemeFamily.values) {
      if (family.code == code) return family;
    }
    return null;
  }
}
