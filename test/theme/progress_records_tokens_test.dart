import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('Classic preserves progress and report structural recipes', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final scheme = theme.colorScheme;
      final surfaces = theme.surfaceTokens;
      final shapes = theme.shapeTokens;

      expect(
        surfaces.exerciseProgressHero,
        scheme.surfaceContainerHighest.withValues(alpha: 0.36),
      );
      expect(
        surfaces.exerciseProgressStat,
        scheme.surface.withValues(alpha: 0.72),
      );
      expect(
        surfaces.exerciseProgressSelector,
        scheme.surface.withValues(alpha: 0.72),
      );
      expect(surfaces.exerciseProgressTooltip, scheme.surfaceContainerHighest);
      expect(
        surfaces.workoutMetricStat,
        scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      );
      expect(
        surfaces.workoutMetricChart,
        scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      );
      expect(surfaces.workoutMetricTooltip, scheme.surfaceContainerHighest);
      expect(
        surfaces.workoutMetricRange,
        scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      );
      expect(
        surfaces.workoutMetricDetails,
        scheme.surfaceContainerHighest.withValues(alpha: 0.38),
      );
      expect(
        surfaces.workoutMetricInsight,
        scheme.surfaceContainerHighest.withValues(alpha: 0.42),
      );

      expect(
        shapes.exerciseProgressHero,
        const BorderRadius.all(Radius.circular(18)),
      );
      expect(
        shapes.exerciseProgressStat,
        const BorderRadius.all(Radius.circular(14)),
      );
      expect(
        shapes.exerciseProgressSelector,
        const BorderRadius.all(Radius.circular(14)),
      );
      expect(
        shapes.exerciseProgressAddTile,
        const BorderRadius.all(Radius.circular(12)),
      );
      expect(
        shapes.exerciseProgressTooltip,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(
        shapes.workoutMetricStat,
        const BorderRadius.all(Radius.circular(16)),
      );
      expect(
        shapes.workoutMetricChart,
        const BorderRadius.all(Radius.circular(18)),
      );
      expect(
        shapes.workoutMetricTooltip,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(
        shapes.workoutMetricRange,
        const BorderRadius.all(Radius.circular(14)),
      );
      expect(
        shapes.workoutMetricRangeOption,
        const BorderRadius.all(Radius.circular(11)),
      );
      expect(
        shapes.workoutMetricDetails,
        const BorderRadius.all(Radius.circular(14)),
      );
      expect(
        shapes.workoutMetricInsight,
        const BorderRadius.all(Radius.circular(14)),
      );
    }
  });

  test('progress and report recipes remain independently overrideable', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic);
    final targetSurfaces = base.surfaceTokens.copyWith(
      exerciseProgressHero: Colors.orange,
      workoutMetricChart: Colors.cyan,
    );
    final targetShapes = base.shapeTokens.copyWith(
      exerciseProgressHero: const BorderRadius.all(Radius.circular(30)),
      workoutMetricRange: const BorderRadius.all(Radius.circular(6)),
    );

    expect(targetSurfaces.exerciseProgressHero, Colors.orange);
    expect(targetSurfaces.workoutMetricChart, Colors.cyan);
    expect(
      targetShapes.exerciseProgressHero,
      const BorderRadius.all(Radius.circular(30)),
    );
    expect(
      targetShapes.workoutMetricRange,
      const BorderRadius.all(Radius.circular(6)),
    );

    final midpointSurfaces = base.surfaceTokens.lerp(targetSurfaces, 0.5);
    final midpointShapes = base.shapeTokens.lerp(targetShapes, 0.5);
    expect(
      midpointSurfaces.exerciseProgressHero,
      Color.lerp(base.surfaceTokens.exerciseProgressHero, Colors.orange, 0.5),
    );
    expect(
      midpointSurfaces.workoutMetricChart,
      Color.lerp(base.surfaceTokens.workoutMetricChart, Colors.cyan, 0.5),
    );
    expect(
      midpointShapes.exerciseProgressHero,
      BorderRadius.lerp(
        base.shapeTokens.exerciseProgressHero,
        const BorderRadius.all(Radius.circular(30)),
        0.5,
      ),
    );
    expect(
      midpointShapes.workoutMetricRange,
      BorderRadius.lerp(
        base.shapeTokens.workoutMetricRange,
        const BorderRadius.all(Radius.circular(6)),
        0.5,
      ),
    );
  });
}
