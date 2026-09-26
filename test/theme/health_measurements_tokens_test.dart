import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('Classic preserves health trend card and entry geometry', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      expect(theme.progressColors.healthCard, theme.cardColor);
      expect(
        theme.shapeTokens.healthTrendCard,
        const BorderRadius.all(Radius.circular(18)),
      );
      expect(
        theme.shapeTokens.healthTrendEntry,
        const BorderRadius.all(Radius.circular(14)),
      );
    }
  });

  test('health trend geometry remains independently overrideable', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic);
    final target = base.shapeTokens.copyWith(
      healthTrendCard: const BorderRadius.all(Radius.circular(26)),
      healthTrendEntry: const BorderRadius.all(Radius.circular(8)),
    );

    expect(target.healthTrendCard, const BorderRadius.all(Radius.circular(26)));
    expect(target.healthTrendEntry, const BorderRadius.all(Radius.circular(8)));

    final midpoint = base.shapeTokens.lerp(target, 0.5);
    expect(
      midpoint.healthTrendCard,
      BorderRadius.lerp(
        base.shapeTokens.healthTrendCard,
        const BorderRadius.all(Radius.circular(26)),
        0.5,
      ),
    );
    expect(
      midpoint.healthTrendEntry,
      BorderRadius.lerp(
        base.shapeTokens.healthTrendEntry,
        const BorderRadius.all(Radius.circular(8)),
        0.5,
      ),
    );
  });

  testWidgets('Neo health delta colors contrast with bright health cards', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      late Color increase;
      late Color decrease;
      late Color surface;

      await tester.pumpWidget(
        MaterialApp(
          theme:
              brightness == Brightness.light
                  ? NeoBrutalismThemeDefinition.light()
                  : NeoBrutalismThemeDefinition.dark(),
          home: Builder(
            builder: (context) {
              surface = context.surfaceTokens.catalogSelection;
              increase = tonosHealthIncreaseForSurface(context, surface);
              decrease = tonosHealthDecreaseForSurface(context, surface);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(_contrastRatio(increase, surface), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(decrease, surface), greaterThanOrEqualTo(4.5));
      expect(
        increase,
        isNot(
          brightness == Brightness.light
              ? NeoBrutalismThemeDefinition.light()
                  .progressColors
                  .healthIncrease
              : NeoBrutalismThemeDefinition.dark()
                  .progressColors
                  .healthIncrease,
        ),
      );
      expect(
        decrease,
        isNot(
          brightness == Brightness.light
              ? NeoBrutalismThemeDefinition.light()
                  .progressColors
                  .healthDecrease
              : NeoBrutalismThemeDefinition.dark()
                  .progressColors
                  .healthDecrease,
        ),
      );
    }
  });

  testWidgets('Classic health delta colors preserve progress roles', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      late Color increase;
      late Color decrease;
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(AppThemeFamily.classic)
              : AppThemeFactory.dark(AppThemeFamily.classic);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final surface = context.progressColors.healthCard;
              increase = tonosHealthIncreaseForSurface(context, surface);
              decrease = tonosHealthDecreaseForSurface(context, surface);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(increase, theme.progressColors.healthIncrease);
      expect(decrease, theme.progressColors.healthDecrease);
    }
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
