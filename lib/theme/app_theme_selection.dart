import 'package:flutter/material.dart';

import 'app_theme_family.dart';

/// The persisted appearance choice, independent of the visual definition.
@immutable
class AppThemeSelection {
  const AppThemeSelection({required this.family, required this.mode});

  final AppThemeFamily family;
  final ThemeMode mode;

  @override
  bool operator ==(Object other) =>
      other is AppThemeSelection &&
      other.family == family &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(family, mode);
}
