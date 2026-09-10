import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
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
}
