import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_generation_tokens.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';

void main() {
  group('AppThemeFactory', () {
    test('returns cached complete Classic variants', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      expect(
        identical(light, AppThemeFactory.light(AppThemeFamily.classic)),
        isTrue,
      );
      expect(
        identical(dark, AppThemeFactory.dark(AppThemeFamily.classic)),
        isTrue,
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.extension<AppFlowTokens>(), isNotNull);
      expect(dark.extension<AppFlowTokens>(), isNotNull);
      expect(light.extension<AppGenerationTokens>(), isNotNull);
      expect(dark.extension<AppGenerationTokens>(), isNotNull);
      expect(light.extension<AppNutritionTokens>(), isNotNull);
      expect(dark.extension<AppNutritionTokens>(), isNotNull);
    });

    test('preserves the reviewed Classic heatmap values', () {
      final lightData =
          AppThemeFactory.light(
            AppThemeFamily.classic,
          ).extension<AppDataVisualizationTokens>();
      final darkData =
          AppThemeFactory.dark(
            AppThemeFamily.classic,
          ).extension<AppDataVisualizationTokens>();

      expect(lightData?.heatmapLow, const Color(0xFF9E9E9E));
      expect(darkData?.heatmapLow, const Color(0xFFA1A1A1));
      expect(lightData?.grid, const Color.fromARGB(102, 43, 42, 42));
      expect(darkData?.grid, const Color(0x66FFFFFF));
      expect(lightData?.tertiarySeries, const Color(0xFF9C27B0));
      expect(darkData?.tertiarySeries, const Color(0xFF9C27B0));
      expect(lightData?.carbohydrateSeries, const Color(0xFFFF8C00));
      expect(darkData?.carbohydrateSeries, const Color(0xFFFFA726));
      expect(lightData?.proteinRing, const Color(0xFF9C27B0));
      expect(darkData?.proteinRing, const Color(0xFFB53CCA));
      expect(lightData?.fatRing, const Color(0xFFFF8C00));
      expect(darkData?.fatRing, const Color(0xFFFFA726));
      expect(lightData?.paginationActive, const Color(0xFF9C27B0));
      expect(darkData?.paginationInactive, const Color(0xFF757575));
    });

    test('preserves the reviewed Classic divider values', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      expect(
        light.extension<AppSurfaceTokens>()?.divider,
        const Color(0xFFBDBDBD),
      );
      expect(
        dark.extension<AppSurfaceTokens>()?.divider,
        const Color(0xFF616161),
      );
    });

    test('preserves the reachable Train2 role values', () {
      for (final theme in [
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        expect(theme.shapeTokens.trainTab, BorderRadius.circular(20));
        expect(theme.semanticColors.trainProfileAvatar, Colors.lightGreen);
        expect(theme.semanticColors.onTrainProfileAvatar, Colors.white);
        expect(theme.semanticColors.trainOptimizedAction, Colors.green);
        expect(
          theme.dataVisualizationTokens.tertiarySeries,
          const Color(0xFF9C27B0),
        );
      }
    });

    test('centralizes Classic bottom navigation colors', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      expect(
        light.bottomNavigationBarTheme.backgroundColor,
        light.colorScheme.surface,
      );
      expect(
        light.bottomNavigationBarTheme.selectedItemColor,
        light.colorScheme.primary,
      );
      expect(
        light.bottomNavigationBarTheme.unselectedItemColor,
        light.colorScheme.onSurface.withValues(alpha: 0.6),
      );
      expect(
        light.bottomNavigationBarTheme.type,
        BottomNavigationBarType.fixed,
      );
      expect(
        dark.bottomNavigationBarTheme.backgroundColor,
        dark.colorScheme.surface,
      );
      expect(
        dark.bottomNavigationBarTheme.selectedItemColor,
        dark.colorScheme.primary,
      );
      expect(
        dark.bottomNavigationBarTheme.unselectedItemColor,
        dark.colorScheme.onSurface.withValues(alpha: 0.6),
      );
      expect(dark.bottomNavigationBarTheme.type, BottomNavigationBarType.fixed);
    });

    test('does not globally override standard Material recipes', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      expect(light.appBarTheme.backgroundColor, isNull);
      expect(dark.appBarTheme.backgroundColor, isNull);
      expect(light.bottomSheetTheme.backgroundColor, isNull);
      expect(dark.bottomSheetTheme.backgroundColor, isNull);
      expect(light.dialogTheme.backgroundColor, isNull);
      expect(dark.dialogTheme.backgroundColor, isNull);
      expect(light.dividerTheme.space, isNull);
      expect(dark.dividerTheme.space, isNull);
      expect(light.floatingActionButtonTheme.backgroundColor, isNull);
      expect(dark.floatingActionButtonTheme.backgroundColor, isNull);
    });

    test('preserves the reviewed Classic domain action colors', () {
      final light =
          AppThemeFactory.light(
            AppThemeFamily.classic,
          ).extension<AppSemanticColors>();
      final dark =
          AppThemeFactory.dark(
            AppThemeFamily.classic,
          ).extension<AppSemanticColors>();

      expect(light?.measurementContainer, const Color(0xFFB2DFDB));
      expect(light?.onMeasurementContainer, const Color(0xFF00695C));
      expect(dark?.measurementContainer, const Color(0xFF004D40));
      expect(dark?.onMeasurementContainer, const Color(0xFFE0F2F1));
      expect(light?.nutritionContainer, const Color(0xFFFFE0B2));
      expect(light?.onNutritionContainer, const Color(0xFFEF6C00));
      expect(dark?.nutritionContainer, const Color(0xFFF57C00));
      expect(dark?.onNutritionContainer, const Color(0xFFFFF3E0));
      expect(light?.workoutContainer, const Color(0xFFC8E6C9));
      expect(light?.onWorkoutContainer, const Color(0xFF2E7D32));
      expect(dark?.workoutContainer, const Color(0xFF2E7D32));
      expect(dark?.onWorkoutContainer, const Color(0xFFE8F5E9));
      expect(light?.primaryAction, const Color(0xFF6200EE));
      expect(light?.onPrimaryAction, Colors.white);
      expect(dark?.primaryAction, const Color(0xFF3700B3));
      expect(dark?.onPrimaryAction, Colors.black);
      expect(light?.strongContent, Colors.black);
      expect(light?.mutedContent, const Color(0xFF757575));
      expect(dark?.strongContent, const Color(0xFFE0E0E0));
      expect(dark?.mutedContent, const Color(0xFFBDBDBD));
      expect(light?.automaticPlanBadge, const Color(0xFF4EDA41));
      expect(light?.onAutomaticPlanBadge, Colors.white);
      expect(dark?.automaticPlanBadge, const Color(0xFF4EDA41));
      expect(dark?.onAutomaticPlanBadge, Colors.blueGrey);
      expect(light?.workoutAction, const Color(0xFF4CAF50));
      expect(light?.onWorkoutAction, Colors.white);
      expect(dark?.workoutAction, const Color(0xFF81C784));
      expect(dark?.onWorkoutAction, Colors.black);
      expect(light?.startWorkoutAction, const Color(0xFF388E3C));
      expect(light?.onStartWorkoutAction, Colors.white);
      expect(dark?.startWorkoutAction, const Color(0xFF388E3C));
      expect(dark?.onStartWorkoutAction, Colors.white);
      expect(light?.completionAccent, const Color(0xFF7CFF8B));
      expect(dark?.completionAccent, const Color(0xFF7CFF8B));
      expect(light?.drawerHeaderForeground, Colors.white);
      expect(dark?.drawerHeaderForeground, Colors.white);
      expect(light?.ongoingSessionAction, Colors.green);
      expect(dark?.ongoingSessionAction, Colors.green);
      expect(light?.ongoingSessionExit, Colors.red);
      expect(dark?.ongoingSessionExit, Colors.red);
      expect(light?.databaseHealthy, Colors.green);
      expect(dark?.databaseHealthy, Colors.green);
      expect(light?.databaseWarning, Colors.orange);
      expect(dark?.databaseWarning, Colors.orange);
    });

    test('preserves the reviewed Classic compatibility recipes', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      for (final theme in [light, dark]) {
        expect(
          theme.shapeTokens.settingsAction,
          const BorderRadius.all(Radius.circular(15)),
        );
        expect(
          theme.shapeTokens.metric,
          const BorderRadius.all(Radius.circular(14)),
        );
        expect(
          theme.shapeTokens.workoutSection,
          const BorderRadius.all(Radius.circular(10)),
        );
        expect(
          theme.shapeTokens.planCard,
          const BorderRadius.all(Radius.circular(18)),
        );
        expect(
          theme.shapeTokens.flowControl,
          const BorderRadius.all(Radius.circular(20)),
        );
        expect(
          theme.shapeTokens.flowIcon,
          const BorderRadius.all(Radius.circular(13)),
        );
        expect(
          theme.shapeTokens.recordBadge,
          const BorderRadius.all(Radius.circular(7)),
        );
        expect(
          theme.shapeTokens.recordBadgeCompact,
          const BorderRadius.all(Radius.circular(5)),
        );
        expect(
          theme.shapeTokens.settingsPanel,
          const BorderRadius.all(Radius.circular(22)),
        );
        expect(
          theme.shapeTokens.settingsInput,
          const BorderRadius.all(Radius.circular(14)),
        );
        expect(
          theme.shapeTokens.settingsField,
          const BorderRadius.all(Radius.circular(16)),
        );
        expect(
          theme.shapeTokens.settingsPicker,
          const BorderRadius.all(Radius.circular(20)),
        );
        expect(
          theme.shapeTokens.settingsIcon,
          const BorderRadius.all(Radius.circular(13)),
        );
        expect(
          theme.shapeTokens.settingsTitleCard,
          const BorderRadius.all(Radius.circular(24)),
        );
        expect(
          theme.shapeTokens.profileTile,
          const BorderRadius.all(Radius.circular(18)),
        );
        expect(
          theme.shapeTokens.hero,
          const BorderRadius.all(Radius.circular(28)),
        );
        expect(
          theme.shapeTokens.actionBar,
          const BorderRadius.all(Radius.circular(24)),
        );
        expect(
          theme.shapeTokens.dialogChoice,
          const BorderRadius.all(Radius.circular(14)),
        );
        expect(
          theme.surfaceTokens.planCard,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        );
        expect(
          theme.surfaceTokens.flowControl,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        );
        expect(
          theme.surfaceTokens.planFilter,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        );
        expect(
          theme.surfaceTokens.planDuration,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        );
        expect(
          theme.surfaceTokens.planGroup,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        );
        expect(
          theme.surfaceTokens.metricChip,
          theme.colorScheme.surfaceContainerHighest,
        );
        expect(
          theme.surfaceTokens.planActionBar,
          theme.colorScheme.surface.withValues(alpha: 0.96),
        );
        expect(
          theme.surfaceTokens.optimizedAction,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
        );
        expect(
          theme.surfaceTokens.settingsHero,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.54),
        );
        expect(
          theme.surfaceTokens.settingsSection,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        );
        expect(
          theme.surfaceTokens.settingsInput,
          theme.colorScheme.surface.withValues(alpha: 0.44),
        );
        expect(
          theme.surfaceTokens.settingsSaveBar,
          theme.colorScheme.surface.withValues(alpha: 0.96),
        );
        expect(
          theme.surfaceTokens.dialogChoice,
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        );
        expect(theme.motionTokens.quick, const Duration(milliseconds: 180));
      }
    });

    test('preserves the reviewed Classic info-card and records values', () {
      final light = AppThemeFactory.light(AppThemeFamily.classic);
      final dark = AppThemeFactory.dark(AppThemeFamily.classic);

      expect(light.surfaceTokens.card, Colors.white);
      expect(dark.surfaceTokens.card, const Color(0xFF222222));
      expect(light.surfaceTokens.subtleOutline, const Color(0xFFE0E0E0));
      expect(dark.surfaceTokens.subtleOutline, const Color(0xFF616161));
      expect(light.effectTokens.cardShadow, const Color(0x22000000));
      expect(dark.effectTokens.cardShadow, const Color(0x66000000));
      expect(light.effectTokens.cardShadowBlur, 4);
      expect(dark.effectTokens.cardShadowBlur, 4);
      expect(light.effectTokens.cardShadowOffset, const Offset(0, 2));
      expect(dark.effectTokens.cardShadowOffset, const Offset(0, 2));
      expect(light.effectTokens.feedbackElevation, 6);
      expect(dark.effectTokens.feedbackElevation, 6);
      expect(
        light.dataVisualizationTokens.recordTodayContainer,
        const Color(0x33388E3C),
      );
      expect(
        dark.dataVisualizationTokens.recordTodayContainer,
        const Color(0x2281C784),
      );
      expect(
        light.dataVisualizationTokens.recordTodayBorder,
        const Color(0xFF388E3C),
      );
      expect(
        dark.dataVisualizationTokens.onRecordTodayContainer,
        const Color(0xFF81C784),
      );
      for (final data in [
        light.dataVisualizationTokens,
        dark.dataVisualizationTokens,
      ]) {
        expect(data.sessionExercises, const Color(0xFF64B5F6));
        expect(data.sessionSets, const Color(0xFF81C784));
        expect(data.sessionDuration, const Color(0xFFFFD54F));
        expect(data.sessionVolume, const Color(0xFFF48FB1));
        expect(data.recordMonthly, const Color(0xFF81C784));
        expect(data.recordAllTime, const Color(0xFFFFC857));
        expect(data.firstRecord, Colors.white);
      }
    });

    test('preserves the reviewed Classic flow and nutrition values', () {
      final lightFlow =
          AppThemeFactory.light(AppThemeFamily.classic).flowTokens;
      final darkFlow = AppThemeFactory.dark(AppThemeFamily.classic).flowTokens;
      final lightNutrition =
          AppThemeFactory.light(AppThemeFamily.classic).nutritionTokens;
      final darkNutrition =
          AppThemeFactory.dark(AppThemeFamily.classic).nutritionTokens;

      expect(lightFlow.canvas, const Color(0xFFFFFFFF));
      expect(darkFlow.canvas, const Color(0xFF121212));
      expect(lightFlow.nodeBackground, const Color(0xFFFFFFFF));
      expect(darkFlow.nodeBackground, const Color(0xFF1E1E1E));
      expect(lightFlow.nodeBorder, const Color.fromARGB(255, 93, 188, 226));
      expect(darkFlow.nodeBorder, const Color.fromARGB(255, 34, 55, 245));
      expect(lightFlow.nodeText, const Color(0xFF333333));
      expect(darkFlow.nodeText, const Color(0xFFE0E0E0));
      expect(lightFlow.success, const Color(0xFF2E7D32));
      expect(darkFlow.success, const Color(0xFF66BB6A));
      expect(lightFlow.failure, const Color(0xFFC62828));
      expect(darkFlow.failure, const Color(0xFFEF5350));
      expect(lightFlow.action, Colors.deepPurple);
      expect(darkFlow.action, Colors.deepPurple);
      expect(lightFlow.onAction, Colors.white);
      expect(darkFlow.onAction, Colors.white);
      expect(lightFlow.loopback, const Color(0xFF757575));
      expect(darkFlow.loopback, const Color(0xFF757575));

      expect(lightNutrition.pantryLogSurface, const Color(0xFFFFF9C4));
      expect(darkNutrition.pantryLogSurface, const Color(0xFF4E4E1A));
      expect(lightNutrition.addMealSurface, const Color(0xFFC8E6C9));
      expect(darkNutrition.addMealSurface, const Color(0xFF2E4E2E));
      expect(lightNutrition.planMealSurface, const Color(0xFFBBDEFB));
      expect(darkNutrition.planMealSurface, const Color(0xFF1A2E4E));
      expect(
        lightNutrition.textDetailsBorder,
        const Color.fromARGB(255, 223, 223, 223),
      );
      expect(
        darkNutrition.textDetailsBorder,
        const Color.fromARGB(255, 100, 100, 100),
      );
    });
  });
}
