import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';

List<Color> _values(AppProgressColors colors) => [
  colors.accent,
  colors.estimated,
  colors.estimatedOneRm,
  colors.grid,
  colors.label,
  colors.exerciseIncrease,
  colors.exerciseDecrease,
  colors.neutral,
  colors.workoutIncrease,
  colors.workoutDecrease,
  colors.healthIncrease,
  colors.healthDecrease,
  colors.healthCard,
  colors.healthGrid,
];

void main() {
  test('Classic progress colors preserve legacy recipes in both modes', () {
    for (final theme in [
      ClassicThemeDefinition.light(),
      ClassicThemeDefinition.dark(),
    ]) {
      final colors = theme.extension<AppProgressColors>();
      expect(colors, isNotNull);
      final legacy = ThemeData.from(
        colorScheme: theme.colorScheme,
        useMaterial3: true,
      );
      expect(_values(colors!), [
        legacy.colorScheme.primary,
        legacy.colorScheme.onSurfaceVariant,
        Colors.green.shade400,
        legacy.colorScheme.outlineVariant,
        legacy.colorScheme.onSurfaceVariant,
        Colors.green.shade400,
        legacy.colorScheme.error,
        legacy.colorScheme.onSurfaceVariant,
        Colors.green.shade400,
        Colors.red.shade400,
        Colors.greenAccent.shade400,
        Colors.redAccent.shade100,
        legacy.cardColor,
        legacy.dividerColor,
      ]);
    }
  });

  test('plain themes retain their own health card and grid colors', () {
    final theme = ThemeData(
      cardColor: Colors.orange,
      dividerColor: Colors.teal,
    );
    expect(theme.progressColors.healthCard, Colors.orange);
    expect(theme.progressColors.healthGrid, Colors.teal);
  });

  test(
    'every progress recipe can be copied and interpolated independently',
    () {
      final base = ClassicThemeDefinition.light().progressColors;
      final target = base.copyWith(
        accent: const Color(0xFF123400),
        estimated: const Color(0xFF124400),
        estimatedOneRm: const Color(0xFF124800),
        grid: const Color(0xFF125400),
        label: const Color(0xFF126400),
        exerciseIncrease: const Color(0xFF127400),
        exerciseDecrease: const Color(0xFF128400),
        neutral: const Color(0xFF129400),
        workoutIncrease: const Color(0xFF12a400),
        workoutDecrease: const Color(0xFF12b400),
        healthIncrease: const Color(0xFF12c400),
        healthDecrease: const Color(0xFF12d400),
        healthCard: const Color(0xFF12e400),
        healthGrid: const Color(0xFF12f400),
      );
      expect(_values(base.copyWith()), _values(base));
      expect(_values(base.lerp(null, 0.5)), _values(base));
      final expected = [
        const Color(0xFF123400),
        const Color(0xFF124400),
        const Color(0xFF124800),
        const Color(0xFF125400),
        const Color(0xFF126400),
        const Color(0xFF127400),
        const Color(0xFF128400),
        const Color(0xFF129400),
        const Color(0xFF12a400),
        const Color(0xFF12b400),
        const Color(0xFF12c400),
        const Color(0xFF12d400),
        const Color(0xFF12e400),
        const Color(0xFF12f400),
      ];
      expect(_values(target), expected);
      for (final t in [0.0, 0.5, 1.0]) {
        expect(_values(base.lerp(target, t)), [
          for (var i = 0; i < expected.length; i++)
            Color.lerp(_values(base)[i], expected[i], t)!,
        ]);
      }
    },
  );
}
