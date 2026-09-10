import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  test('C1 catalog and media owners use focused surface roles', () {
    final catalogSource =
        File(
          'lib/screens/exercise/exercise_catalog_page.dart',
        ).readAsStringSync();
    final overviewSource =
        File('lib/screens/catalog_page.dart').readAsStringSync();
    final exerciseMediaSource =
        File('lib/widgets/exercise_media_thumbnail.dart').readAsStringSync();
    final sharedMediaSource =
        File(
          'lib/widgets/shared_entity_media_thumbnail.dart',
        ).readAsStringSync();
    final anatomySource =
        File('lib/screens/exercise/muscle_filter_page.dart').readAsStringSync();

    expect(catalogSource, contains('surfaces.catalogSelection'));
    expect(catalogSource, contains('surfaces.catalogOutline'));
    expect(overviewSource, contains('surfaces.catalogUsage'));
    expect(overviewSource, contains('surfaces.catalogOutline'));
    expect(exerciseMediaSource, contains('surfaces.mediaPlaceholder'));
    expect(exerciseMediaSource, contains('surfaces.mediaOutline'));
    expect(exerciseMediaSource, contains('surfaces.media.withValues'));
    expect(sharedMediaSource, contains('surfaces.mediaFrame'));
    expect(sharedMediaSource, contains('surfaces.media.withValues'));
    expect(anatomySource, contains('SharedEntityMediaThumbnail'));

    expect(exerciseMediaSource, contains('_buildHeatmapFallback'));
    expect(exerciseMediaSource, contains('_retryThumbnail'));
    expect(exerciseMediaSource, contains('_recoverFromMissingFile'));
    expect(sharedMediaSource, contains('fallbackBuilder'));
    expect(sharedMediaSource, contains('_retry'));
    expect(sharedMediaSource, contains('_recoverFromMissingFile'));

    expect(
      exerciseMediaSource,
      isNot(contains('surfaceContainerHighest')),
      reason: 'The exercise media frame must use its semantic owner.',
    );
    expect(
      sharedMediaSource,
      isNot(contains('surfaceContainerHigh')),
      reason: 'The shared media frame must use its semantic owner.',
    );
    expect(
      exerciseMediaSource,
      isNot(contains('colorScheme.outlineVariant')),
      reason: 'Exercise media outlines must use the media role.',
    );
    expect(
      sharedMediaSource,
      isNot(contains('colorScheme.outlineVariant')),
      reason: 'Shared media outlines must use the media role.',
    );
  });

  test('C1 surface roles preserve the existing Classic recipes', () {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      final surfaces = theme.surfaceTokens;
      final scheme = theme.colorScheme;

      expect(
        surfaces.catalogSelection,
        scheme.primaryContainer.withValues(alpha: 0.45),
      );
      expect(
        surfaces.catalogUsage,
        scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      );
      expect(surfaces.mediaFrame, scheme.surfaceContainerHigh);
      expect(surfaces.mediaPlaceholder, scheme.surfaceContainerHighest);
      expect(surfaces.mediaOutline, scheme.outlineVariant);
    }
  });

  test('C1 surface roles copy and interpolate independently', () {
    final base = AppThemeFactory.light(AppThemeFamily.classic).surfaceTokens;
    final target = base.copyWith(
      catalogSelection: const Color(0xFF112233),
      catalogUsage: const Color(0xFF223344),
      catalogOutline: const Color(0xFF2A3B4C),
      mediaFrame: const Color(0xFF334455),
      mediaPlaceholder: const Color(0xFF445566),
      mediaOutline: const Color(0xFF556677),
    );
    final midpoint = base.lerp(target, 0.5);

    expect(base.copyWith().catalogSelection, base.catalogSelection);
    expect(base.copyWith().catalogUsage, base.catalogUsage);
    expect(base.copyWith().catalogOutline, base.catalogOutline);
    expect(base.copyWith().mediaFrame, base.mediaFrame);
    expect(base.copyWith().mediaPlaceholder, base.mediaPlaceholder);
    expect(base.copyWith().mediaOutline, base.mediaOutline);
    expect(
      midpoint.catalogSelection,
      Color.lerp(base.catalogSelection, target.catalogSelection, 0.5),
    );
    expect(
      midpoint.catalogUsage,
      Color.lerp(base.catalogUsage, target.catalogUsage, 0.5),
    );
    expect(
      midpoint.catalogOutline,
      Color.lerp(base.catalogOutline, target.catalogOutline, 0.5),
    );
    expect(
      midpoint.mediaFrame,
      Color.lerp(base.mediaFrame, target.mediaFrame, 0.5),
    );
    expect(
      midpoint.mediaPlaceholder,
      Color.lerp(base.mediaPlaceholder, target.mediaPlaceholder, 0.5),
    );
    expect(
      midpoint.mediaOutline,
      Color.lerp(base.mediaOutline, target.mediaOutline, 0.5),
    );
  });
}
