import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_destination_tokens.dart';
import 'package:env_test/theme/tokens/app_expressive_train_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/widgets/app_expressive_destination_theme.dart';

void main() {
  testWidgets(
    'Progress destination scope preserves chart and health data colors',
    (tester) async {
      for (final theme in <ThemeData>[
        ExpressiveThemeDefinition.light(),
        ExpressiveThemeDefinition.dark(),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const AppExpressiveDestinationTheme(
              family: AppExpressiveDestinationFamily.progress,
              child: Text('progress-destination-scope'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scopedTheme = Theme.of(
          tester.element(find.text('progress-destination-scope')),
        );
        final expectedProgressColors = theme.extension<AppProgressColors>()!;
        final expectedDataColors = theme
            .extension<AppDataVisualizationTokens>()!;
        final actualProgressColors = scopedTheme
            .extension<AppProgressColors>()!;
        final actualDataColors = scopedTheme
            .extension<AppDataVisualizationTokens>()!;

        expect(
          scopedTheme.extension<AppExpressiveDestinationTokens>()!.family,
          AppExpressiveDestinationFamily.progress,
        );
        expect(
          actualProgressColors.healthIncrease,
          expectedProgressColors.healthIncrease,
        );
        expect(
          actualProgressColors.healthDecrease,
          expectedProgressColors.healthDecrease,
        );
        expect(
          actualProgressColors.estimatedOneRm,
          expectedProgressColors.estimatedOneRm,
        );
        expect(
          actualDataColors.primarySeries,
          expectedDataColors.primarySeries,
        );
        expect(
          actualDataColors.secondarySeries,
          expectedDataColors.secondarySeries,
        );
        expect(scopedTheme.colorScheme, theme.colorScheme);
      }
    },
  );

  test(
    'Expressive Progress roles use neutral surfaces and asymmetric shapes',
    () {
      for (final theme in <ThemeData>[
        ExpressiveThemeDefinition.light(),
        ExpressiveThemeDefinition.dark(),
      ]) {
        final surfaces = theme.surfaceTokens;
        final shapes = theme.shapeTokens;
        final scheme = theme.colorScheme;

        expect(surfaces.workoutMetricStat, scheme.surfaceContainer);
        expect(surfaces.workoutMetricChart, scheme.surfaceContainerLow);
        expect(surfaces.workoutMetricTooltip, scheme.surfaceContainerHigh);
        expect(surfaces.workoutMetricRange, scheme.surfaceContainerLow);
        expect(surfaces.workoutMetricDetails, scheme.surfaceContainer);
        expect(surfaces.workoutMetricInsight, scheme.surfaceContainerLow);
        expect(surfaces.exerciseProgressHero, scheme.surfaceContainer);
        expect(surfaces.exerciseProgressStat, scheme.surfaceContainerLow);
        expect(surfaces.exerciseProgressSelector, scheme.surfaceContainer);
        expect(surfaces.exerciseProgressTooltip, scheme.surfaceContainerHigh);

        expect(shapes.workoutMetricChart, ExpressiveTrainShapes.focusHero);
        expect(shapes.exerciseProgressHero, ExpressiveTrainShapes.focusHero);
        expect(shapes.healthTrendCard, ExpressiveTrainShapes.section);
        expect(shapes.workoutMetricRange, ExpressiveTrainShapes.compactControl);
        final destination = AppExpressiveDestinationTokens.forFamily(
          AppExpressiveDestinationFamily.progress,
          theme.brightness,
        );
        expect(theme.extension<AppProgressColors>()!.healthCard,
            destination.surfaceAccent);
        if (theme.brightness == Brightness.dark) {
          expect(destination.surfaceAccent, const Color(0xFF572C43));
        }
        expect(
          _contrastRatio(destination.onSurfaceAccent, destination.surfaceAccent),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          theme.extension<AppExpressiveTrainTokens>()!.pageCanvas,
          theme.brightness == Brightness.light
              ? const Color(0xFFFFF4E9)
              : const Color(0xFF19121F),
        );

        final data = theme.extension<AppDataVisualizationTokens>()!;
        final expectedData = AppDataVisualizationTokens.fromBrightness(
          theme.brightness,
        );
        expect(data.primarySeries, expectedData.primarySeries);
        expect(data.secondarySeries, expectedData.secondarySeries);
        expect(data.positive, expectedData.positive);
        expect(data.negative, expectedData.negative);
        expect(data.grid, expectedData.grid);
        expect(data.selection, expectedData.selection);
      }
    },
  );

  test('Classic and Neo Progress roles retain their family recipes', () {
    for (final family in AppThemeFamily.values) {
      for (final theme in <ThemeData>[
        AppThemeFactory.light(family),
        AppThemeFactory.dark(family),
      ]) {
        if (family == AppThemeFamily.classic) {
          expect(theme.shapeTokens, AppShapeTokens.classic);
          expect(
            theme.extension<AppProgressColors>()!.healthCard,
            theme.cardColor,
          );
          expect(
            theme.surfaceTokens.workoutMetricStat,
            AppSurfaceTokens.fromColorScheme(theme.colorScheme)
                .workoutMetricStat,
          );
        } else {
          final dark = theme.brightness == Brightness.dark;
          final expectedSurface = dark ? const Color(0xFF272727) : Colors.white;
          final expectedSecondary = dark
              ? const Color(0xFF333333)
              : const Color(0xFFF1E9D7);
          expect(theme.surfaceTokens.workoutMetricStat, expectedSurface);
          expect(theme.surfaceTokens.workoutMetricChart, expectedSecondary);
          expect(
            theme.shapeTokens.workoutMetricChart,
            BorderRadius.circular(8),
          );
          expect(theme.shapeTokens.healthTrendCard, BorderRadius.circular(8));
          expect(
            theme.extension<AppProgressColors>()!.healthCard,
            dark ? const Color(0xFF55F0EA) : const Color(0xFF64DDE0),
          );
        }
      }
    }
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final brighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (brighter + 0.05) / (darker + 0.05);
}
