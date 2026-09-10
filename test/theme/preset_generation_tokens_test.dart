import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('preset generation owns its route-specific presentation recipes', () {
    final source =
        File(
          'lib/screens/exercise/preset_generation_qa.dart',
        ).readAsStringSync();

    for (final role in [
      'context.generationTokens',
      'generation.introGradientStart',
      'generation.introGradientEnd',
      'generation.introBorder',
      'generation.introIconFill',
      'generation.summarySurface',
      'generation.summaryBorder',
      'generation.sectionSurface',
      'generation.sectionBorder',
      'generation.fieldFill',
      'generation.fieldBorder',
      'generation.choiceSelectedSurface',
      'generation.choiceUnselectedSurface',
      'generation.actionBarSurface',
      'generation.badge',
    ]) {
      expect(source, contains(role), reason: role);
    }

    for (final legacyStyle in [
      'scheme.primaryContainer.withValues(alpha: 0.46)',
      'scheme.surfaceContainerHighest.withValues(alpha: 0.58)',
      'BorderRadius.circular(26)',
      'BorderRadius.circular(18)',
      'BorderRadius.circular(24)',
      'BorderRadius.circular(999)',
    ]) {
      expect(source, isNot(contains(legacyStyle)), reason: legacyStyle);
    }

    expect(source, contains('Colors.transparent'));
  });

  test('Classic preserves the scheme-driven generation recipes', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final scheme = theme.colorScheme;
      final generation = theme.generationTokens;

      expect(generation.accent, scheme.primary);
      expect(
        generation.introGradientStart,
        scheme.primaryContainer.withValues(alpha: 0.46),
      );
      expect(
        generation.introGradientEnd,
        scheme.surfaceContainerHighest.withValues(alpha: 0.58),
      );
      expect(generation.introBorder, scheme.primary.withValues(alpha: 0.18));
      expect(generation.introShape, BorderRadius.circular(26));
      expect(generation.introIconShape, BorderRadius.circular(18));
      expect(generation.summaryPillShape, BorderRadius.circular(16));
      expect(generation.sectionShape, BorderRadius.circular(24));
      expect(generation.fieldShape, BorderRadius.circular(18));
      expect(generation.choiceShape, BorderRadius.circular(18));
      expect(generation.badgeShape, BorderRadius.circular(999));
      expect(
        generation.actionBarSurface,
        scheme.surface.withValues(alpha: 0.96),
      );
      expect(generation.badge, scheme.error);
      expect(generation.onBadge, scheme.onError);
    }
  });

  test('generation recipes copy and interpolate independently', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic).generationTokens;
    final target = base.copyWith(
      accent: Colors.orange,
      summarySurface: Colors.black,
      introShape: BorderRadius.circular(30),
      badge: Colors.red,
    );
    final midpoint = base.lerp(target, 0.5);

    expect(base.copyWith().accent, base.accent);
    expect(target.summarySurface, Colors.black);
    expect(midpoint.accent, Color.lerp(base.accent, Colors.orange, 0.5));
    expect(
      midpoint.introShape,
      BorderRadius.lerp(base.introShape, BorderRadius.circular(30), 0.5),
    );
    expect(midpoint.badge, Color.lerp(base.badge, Colors.red, 0.5));
  });
}
