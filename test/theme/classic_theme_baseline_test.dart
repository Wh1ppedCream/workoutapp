import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/classic_theme_baseline.dart';
import 'package:env_test/theme/classic_theme_tokens.dart';
import 'package:env_test/theme/theme_extensions.dart';

void main() {
  group('Classic theme baseline', () {
    test('keeps a unique inventory of stable reference surfaces', () {
      expect(
        ClassicThemeBaseline.surfaceIds.toSet(),
        hasLength(ClassicThemeBaseline.surfaceIds.length),
      );
      expect(ClassicThemeBaseline.containsSurface('exercise_catalog'), isTrue);
      expect(ClassicThemeBaseline.containsSurface('not_a_surface'), isFalse);
    });

    test('covers the permanent Classic light and dark variants', () {
      expect(AppThemeFamily.classic.supports(Brightness.light), isTrue);
      expect(AppThemeFamily.classic.supports(Brightness.dark), isTrue);
    });

    test('keeps light anatomy readable through a named Classic token', () {
      expect(ClassicThemeTokens.lightHeatmapLow, const Color(0xFF9E9E9E));
    });

    test('guards the extracted Classic recipes against visual drift', () {
      for (final theme in [
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        expect(
          ClassicThemeBaseline.usesFrameworkMaterialRecipes(theme),
          isTrue,
        );
        expect(
          theme.shapeTokens.settingsAction,
          ClassicThemeBaseline.settingsActionShape,
        );
        expect(
          theme.shapeTokens.settingsPanel,
          ClassicThemeBaseline.settingsPanelShape,
        );
        expect(
          theme.shapeTokens.settingsInput,
          ClassicThemeBaseline.settingsInputShape,
        );
        expect(
          theme.shapeTokens.settingsField,
          ClassicThemeBaseline.settingsFieldShape,
        );
        expect(
          theme.shapeTokens.settingsPicker,
          ClassicThemeBaseline.settingsPickerShape,
        );
        expect(
          theme.shapeTokens.settingsIcon,
          ClassicThemeBaseline.settingsIconShape,
        );
        expect(
          theme.shapeTokens.settingsTitleCard,
          ClassicThemeBaseline.settingsTitleCardShape,
        );
        expect(
          theme.shapeTokens.profileTile,
          ClassicThemeBaseline.profileTileShape,
        );
        expect(theme.shapeTokens.hero, ClassicThemeBaseline.heroShape);
        expect(
          theme.shapeTokens.actionBar,
          ClassicThemeBaseline.actionBarShape,
        );
        expect(
          theme.shapeTokens.dialogChoice,
          ClassicThemeBaseline.dialogChoiceShape,
        );
        expect(theme.motionTokens.quick, ClassicThemeBaseline.quickMotion);
        expect(
          theme.semanticColors.ongoingSessionAction,
          ClassicThemeBaseline.ongoingSessionAction,
        );
        expect(
          theme.semanticColors.ongoingSessionExit,
          ClassicThemeBaseline.ongoingSessionExit,
        );
        expect(
          theme.semanticColors.databaseHealthy,
          ClassicThemeBaseline.databaseHealthy,
        );
        expect(
          theme.semanticColors.databaseWarning,
          ClassicThemeBaseline.databaseWarning,
        );
      }
    });
  });
}
