import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('Classic preserves dashboard and history structural recipes', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final scheme = theme.colorScheme;
      final surfaces = theme.surfaceTokens;
      final shapes = theme.shapeTokens;

      expect(
        surfaces.dashboardHero,
        scheme.surfaceContainerHighest.withValues(alpha: 0.54),
      );
      expect(
        surfaces.dashboardSection,
        scheme.surfaceContainerHighest.withValues(alpha: 0.34),
      );
      expect(
        surfaces.dashboardEditor,
        scheme.surfaceContainerHighest.withValues(alpha: 0.46),
      );
      expect(
        surfaces.dashboardUsage,
        scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      );
      expect(surfaces.historyPeriodSelector, scheme.surfaceContainerHighest);
      expect(
        surfaces.calendarModeSelector,
        scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      );
      expect(surfaces.calendarDayEmpty, scheme.surfaceContainerHighest);
      expect(
        surfaces.historySelectedPeriod,
        scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      );
      expect(
        surfaces.historyDivider,
        scheme.outlineVariant.withValues(alpha: 0.22),
      );

      expect(shapes.dashboardHero, const BorderRadius.all(Radius.circular(22)));
      expect(
        shapes.dashboardSection,
        const BorderRadius.all(Radius.circular(24)),
      );
      expect(
        shapes.dashboardEditor,
        const BorderRadius.all(Radius.circular(20)),
      );
      expect(
        shapes.dashboardAction,
        const BorderRadius.all(Radius.circular(16)),
      );
      expect(
        shapes.dashboardUsage,
        const BorderRadius.all(Radius.circular(13)),
      );
      expect(shapes.dashboardRow, const BorderRadius.all(Radius.circular(14)));
      expect(
        shapes.dashboardFooter,
        const BorderRadius.all(Radius.circular(22)),
      );
      expect(
        shapes.historySelectedPeriod,
        const BorderRadius.all(Radius.circular(18)),
      );
    }
  });

  test('dashboard and history recipes remain independently overrideable', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
    final target = base.copyWith(
      dashboardHero: Colors.orange,
      historySelectedPeriod: Colors.cyan,
      historyDivider: Colors.black,
    );

    expect(target.dashboardHero, Colors.orange);
    expect(target.historySelectedPeriod, Colors.cyan);
    expect(target.historyDivider, Colors.black);
    expect(target.copyWith().dashboardHero, Colors.orange);

    final midpoint = base.lerp(target, 0.5);
    expect(
      midpoint.dashboardHero,
      Color.lerp(base.dashboardHero, Colors.orange, 0.5),
    );
    expect(
      midpoint.historySelectedPeriod,
      Color.lerp(base.historySelectedPeriod, Colors.cyan, 0.5),
    );
    expect(
      midpoint.historyDivider,
      Color.lerp(base.historyDivider, Colors.black, 0.5),
    );
  });
}
