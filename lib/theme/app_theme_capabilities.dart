import 'package:flutter/foundation.dart';

import 'app_theme_family.dart';

const String _compileTimeExperimentalThemes = String.fromEnvironment(
  'TONOS_ENABLE_EXPERIMENTAL_THEMES',
);

class AppThemeCapabilitiesException implements Exception {
  const AppThemeCapabilitiesException(this.message);

  final String message;

  @override
  String toString() => 'AppThemeCapabilitiesException: $message';
}

/// Controls which theme families may be selected by the current build.
///
/// Classic is always available. Other families are development-only until
/// they have complete definitions and a release approval.
class AppThemeCapabilities {
  const AppThemeCapabilities({
    required this.experimentalThemesEnabled,
    required this.isReleaseMode,
  });

  final bool experimentalThemesEnabled;
  final bool isReleaseMode;

  factory AppThemeCapabilities.fromCompileTime({
    bool? releaseMode,
    bool? debugMode,
  }) {
    final effectiveReleaseMode = releaseMode ?? kReleaseMode;
    final effectiveDebugMode = debugMode ?? kDebugMode;

    return AppThemeCapabilities(
      experimentalThemesEnabled: _parseExperimentalThemesSetting(
        _compileTimeExperimentalThemes,
        fallback: effectiveDebugMode,
      ),
      isReleaseMode: effectiveReleaseMode,
    );
  }

  /// Returns true only when the family may be selected in this build.
  bool isAvailable(AppThemeFamily family) =>
      family == AppThemeFamily.classic ||
      (!isReleaseMode && experimentalThemesEnabled);

  /// Provides the family list that a development Theme Lab may display.
  List<AppThemeFamily> get availableFamilies =>
      List.unmodifiable(AppThemeFamily.values.where(isAvailable));

  /// Resolves an unavailable family to the complete Classic fallback.
  AppThemeFamily resolve(AppThemeFamily family) =>
      isAvailable(family) ? family : AppThemeFamily.classic;

  /// Unknown persisted codes are never selectable by accident.
  bool isCodeAvailable(String? code) {
    final family = AppThemeFamily.fromCode(code);
    return family != null && isAvailable(family);
  }

  static bool _parseExperimentalThemesSetting(
    String value, {
    required bool fallback,
  }) {
    switch (value.trim().toLowerCase()) {
      case '':
        return fallback;
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw const AppThemeCapabilitiesException(
          'TONOS_ENABLE_EXPERIMENTAL_THEMES must be true or false.',
        );
    }
  }
}
