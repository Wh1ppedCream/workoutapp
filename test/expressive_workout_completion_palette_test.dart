import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

Color _blend(Color foreground, Color background) =>
    Color.alphaBlend(foreground, background);

void main() {
  test('Expressive workout completion roles remain distinct and readable', () {
    for (final treatment in ExpressivePaletteTreatment.values) {
      for (final theme in [
        ExpressiveThemeDefinition.light(treatment: treatment),
        ExpressiveThemeDefinition.dark(treatment: treatment),
      ]) {
        final isDark = theme.brightness == Brightness.dark;
        final semantic = theme.semanticColors;
        final surfaces = theme.surfaceTokens;

        expect(
          semantic.workoutCompleted,
          isDark ? const Color(0xFF5EB171) : const Color(0xFF286F3A),
        );
        expect(
          semantic.workoutExerciseCompleted,
          isDark ? const Color(0xFF286A3A) : const Color(0xFF4F9560),
        );
        expect(
          semantic.workoutSetCompleted,
          isDark ? const Color(0xFF83C98F) : const Color(0xFFC2E7C7),
        );
        expect(
          semantic.workoutCompleted,
          isNot(semantic.workoutExerciseCompleted),
        );
        expect(semantic.workoutCompleted, isNot(semantic.workoutSetCompleted));
        expect(
          semantic.workoutExerciseCompleted,
          isNot(semantic.workoutSetCompleted),
        );
        if (!isDark) {
          expect(
            semantic.workoutCompleted.computeLuminance(),
            lessThan(semantic.workoutExerciseCompleted.computeLuminance()),
          );
          expect(
            semantic.workoutExerciseCompleted.computeLuminance(),
            lessThan(semantic.workoutSetCompleted.computeLuminance()),
          );
        }
        expect(surfaces.workoutCardCompleteFill, 0.18);
        expect(surfaces.workoutSetCompleteFill, isDark ? 0.42 : 0.56);

        expect(
          _contrastRatio(
            theme.colorScheme.onSurface,
            semantic.workoutExerciseCompleted,
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'Exercise header text contrast in ${theme.brightness}',
        );

        final completedCard = _blend(
          semantic.workoutExerciseCompleted.withValues(
            alpha: surfaces.workoutCardCompleteFill,
          ),
          theme.colorScheme.surfaceContainerLow,
        );
        expect(
          _contrastRatio(semantic.workoutCompleted, completedCard),
          greaterThanOrEqualTo(4.5),
          reason:
              'Completion label contrast in ${theme.brightness}: '
              '${semantic.workoutCompleted} on $completedCard',
        );
        expect(
          _contrastRatio(
            theme.colorScheme.onPrimary,
            semantic.workoutCompleted,
          ),
          greaterThanOrEqualTo(3),
          reason: 'Checkbox mark contrast in ${theme.brightness}',
        );

        final completedSet = _blend(
          semantic.workoutSetCompleted.withValues(
            alpha: surfaces.workoutSetCompleteFill,
          ),
          theme.colorScheme.surfaceContainer,
        );
        expect(
          _contrastRatio(theme.colorScheme.onSurface, completedSet),
          greaterThanOrEqualTo(4.5),
          reason: 'Set row text contrast in ${theme.brightness}',
        );

        expect(
          semantic.completionAccent,
          AppSemanticColors.fromColorScheme(theme.colorScheme).completionAccent,
          reason: 'The summary completion accent keeps its existing ownership',
        );
      }
    }
  });

  test('Classic and Neo completion palettes remain unchanged', () {
    final classicLight = AppThemeFactory.light(AppThemeFamily.classic);
    final classicDark = AppThemeFactory.dark(AppThemeFamily.classic);
    expect(
      classicLight.semanticColors.workoutCompleted,
      const Color(0xFF123D1A),
    );
    expect(
      classicLight.semanticColors.workoutExerciseCompleted,
      const Color(0xFF70B479),
    );
    expect(
      classicLight.semanticColors.workoutSetCompleted,
      const Color(0xFFB7E5BE),
    );
    expect(classicDark.semanticColors.workoutCompleted, Colors.green);
    expect(classicDark.semanticColors.workoutExerciseCompleted, Colors.green);
    expect(classicDark.semanticColors.workoutSetCompleted, Colors.green);
    expect(classicLight.surfaceTokens.workoutSetCompleteFill, 1);
    expect(classicDark.surfaceTokens.workoutSetCompleteFill, 76 / 255);

    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      final isDark = theme.brightness == Brightness.dark;
      expect(
        theme.semanticColors.workoutCompleted,
        isDark ? const Color(0xFFB8E67A) : const Color(0xFFA9CD80),
      );
      expect(
        theme.semanticColors.workoutExerciseCompleted,
        isDark ? const Color(0xFFA6D466) : const Color(0xFF96B967),
      );
      expect(
        theme.semanticColors.workoutSetCompleted,
        isDark ? const Color(0xFFC5EC91) : const Color(0xFFB9D994),
      );
      expect(theme.surfaceTokens.workoutCardCompleteFill, 1);
      expect(theme.surfaceTokens.workoutSetCompleteFill, 1);
    }
  });
}
