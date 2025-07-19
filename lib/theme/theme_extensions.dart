// lib/theme/theme_extensions.dart

import 'package:flutter/material.dart';
import '/theme/app_colors.dart';

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  ColorScheme get cs => Theme.of(this).colorScheme;
}
