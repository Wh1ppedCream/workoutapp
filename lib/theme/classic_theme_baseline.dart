import 'package:flutter/material.dart';

/// Machine-readable inventory of stable surfaces used to protect Classic.
///
/// This metadata does not render UI. It keeps the reference-screenshot and
/// behavioral baseline consistent while the theme construction is extracted.
abstract final class ClassicThemeBaseline {
  static const int version = 2;

  // These values are copied from the pre-theme Classic recipes and are kept
  // separate from the general-purpose token defaults.
  static const settingsActionShape = BorderRadius.all(Radius.circular(15));
  static const settingsPanelShape = BorderRadius.all(Radius.circular(22));
  static const settingsInputShape = BorderRadius.all(Radius.circular(14));
  static const settingsFieldShape = BorderRadius.all(Radius.circular(16));
  static const settingsPickerShape = BorderRadius.all(Radius.circular(20));
  static const settingsIconShape = BorderRadius.all(Radius.circular(13));
  static const settingsTitleCardShape = BorderRadius.all(Radius.circular(24));
  static const profileTileShape = BorderRadius.all(Radius.circular(18));
  static const heroShape = BorderRadius.all(Radius.circular(28));
  static const actionBarShape = BorderRadius.all(Radius.circular(24));
  static const dialogChoiceShape = BorderRadius.all(Radius.circular(14));
  static const quickMotion = Duration(milliseconds: 180);
  static const Color ongoingSessionAction = Colors.green;
  static const Color ongoingSessionExit = Colors.red;
  static const Color databaseHealthy = Colors.green;
  static const Color databaseWarning = Colors.orange;

  /// Stable identifiers for representative release-accessible surfaces.
  static const List<String> surfaceIds = <String>[
    'main_navigation',
    'appearance_settings',
    'train_home',
    'active_workout',
    'exercise_catalog',
    'exercise_detail',
    'dashboard',
    'progress_measurements',
    'form_screen',
    'dialog',
    'bottom_sheet',
    'empty_state',
    'warning_or_error',
    'media_placeholder',
  ];

  static bool containsSurface(String surfaceId) =>
      surfaceIds.contains(surfaceId);

  /// Returns true when standard Material components remain framework-owned.
  static bool usesFrameworkMaterialRecipes(ThemeData theme) {
    return theme.appBarTheme.backgroundColor == null &&
        theme.appBarTheme.toolbarHeight == null &&
        theme.bottomSheetTheme.backgroundColor == null &&
        theme.bottomSheetTheme.modalBackgroundColor == null &&
        theme.bottomSheetTheme.elevation == null &&
        theme.dialogTheme.backgroundColor == null &&
        theme.dialogTheme.elevation == null &&
        theme.dividerTheme.color == null &&
        theme.dividerTheme.space == null &&
        theme.floatingActionButtonTheme.backgroundColor == null &&
        theme.floatingActionButtonTheme.foregroundColor == null;
  }
}
