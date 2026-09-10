import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';

void main() {
  test('keeps standard Material recipes at their framework defaults', () {
    final themes = [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ];

    for (final theme in themes) {
      expect(theme.useMaterial3, isTrue);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.visualDensity, VisualDensity.standard);
      expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
      expect(
        theme.bottomNavigationBarTheme.backgroundColor,
        theme.colorScheme.surface,
      );
      expect(theme.appBarTheme.backgroundColor, isNull);
      expect(theme.appBarTheme.toolbarHeight, isNull);
      expect(theme.bottomSheetTheme.backgroundColor, isNull);
      expect(theme.bottomSheetTheme.modalBackgroundColor, isNull);
      expect(theme.bottomSheetTheme.elevation, isNull);
      expect(theme.dialogTheme.backgroundColor, isNull);
      expect(theme.dialogTheme.elevation, isNull);
      expect(theme.dividerTheme.color, isNull);
      expect(theme.dividerTheme.space, isNull);
      expect(theme.floatingActionButtonTheme.backgroundColor, isNull);
      expect(theme.floatingActionButtonTheme.foregroundColor, isNull);
    }
  });
}
