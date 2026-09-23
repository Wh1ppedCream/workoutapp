import 'package:flutter/foundation.dart';

import 'app_theme_family.dart';

const String _compileTimeExperimentalThemes = String.fromEnvironment(
  'TONOS_ENABLE_EXPERIMENTAL_THEMES',
);
const String _compileTimeNeoRelease = String.fromEnvironment(
  'TONOS_ENABLE_NEO_RELEASE',
);

class AppThemeCapabilitiesException implements Exception {
  const AppThemeCapabilitiesException(this.message);

  final String message;

  @override
  String toString() => 'AppThemeCapabilitiesException: $message';
}

/// Controls which theme families may be selected by the current build.
///
/// Classic is always available. Internal Neo release candidates require an
/// explicit build opt-in, separate from the development theme switch.
class AppThemeCapabilities {
  const AppThemeCapabilities({
    required this.experimentalThemesEnabled,
    required this.isReleaseMode,
    this.neoReleaseEnabled = false,
  });

  final bool experimentalThemesEnabled;
  final bool isReleaseMode;
  final bool neoReleaseEnabled;

  factory AppThemeCapabilities.fromCompileTime({
    bool? releaseMode,
    bool? debugMode,
  }) {
    final effectiveReleaseMode = releaseMode ?? kReleaseMode;
    final effectiveDebugMode = debugMode ?? kDebugMode;

    return AppThemeCapabilities(
      experimentalThemesEnabled: _parseBooleanSetting(
        'TONOS_ENABLE_EXPERIMENTAL_THEMES',
        _compileTimeExperimentalThemes,
        fallback: effectiveDebugMode,
      ),
      isReleaseMode: effectiveReleaseMode,
      neoReleaseEnabled: _parseBooleanSetting(
        'TONOS_ENABLE_NEO_RELEASE',
        _compileTimeNeoRelease,
        fallback: false,
      ),
    );
  }

  /// Returns true only when the family may be selected in this build.
  bool isAvailable(AppThemeFamily family) => switch (family) {
    AppThemeFamily.classic => true,
    AppThemeFamily.neoBrutalism =>
      isReleaseMode ? neoReleaseEnabled : experimentalThemesEnabled,
  };

  /// Provides the eligible families for settings and Theme Lab.
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

  static bool _parseBooleanSetting(
    String name,
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
        throw AppThemeCapabilitiesException('$name must be true or false.');
    }
  }
}
