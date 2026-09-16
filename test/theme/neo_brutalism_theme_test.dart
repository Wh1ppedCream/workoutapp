import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_data_visualization_tokens.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_flow_tokens.dart';
import 'package:env_test/theme/tokens/app_generation_tokens.dart';
import 'package:env_test/theme/tokens/app_media_tokens.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/tokens/app_nutrition_tokens.dart';
import 'package:env_test/theme/tokens/app_progress_colors.dart';
import 'package:env_test/theme/tokens/app_semantic_colors.dart';
import 'package:env_test/theme/tokens/app_settings_presentation_tokens.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_decoration_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/tokens/app_tutorial_tokens.dart';

double _contrastRatioForTest(Color foreground, Color background) {
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

Color _compositeTestSurface(Color surface, Color parent) {
  return surface.a < 1 ? Color.alphaBlend(surface, parent) : surface;
}

void main() {
  group('NeoBrutalismThemeDefinition', () {
    test(
      'semantic and navigation foregrounds remain readable in both modes',
      () {
        for (final theme in [
          AppThemeFactory.light(AppThemeFamily.neoBrutalism),
          AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
        ]) {
          final semantic = theme.extension<AppSemanticColors>()!;
          final pairs = <(Color, Color)>[
            (semantic.onMeasurementContainer, semantic.measurementContainer),
            (semantic.onNutritionContainer, semantic.nutritionContainer),
            (semantic.onWorkoutContainer, semantic.workoutContainer),
            (
              theme.bottomNavigationBarTheme.selectedItemColor!,
              theme.bottomNavigationBarTheme.backgroundColor!,
            ),
            (
              theme.tabBarTheme.labelColor!,
              (theme.tabBarTheme.indicator! as BoxDecoration).color!,
            ),
            (
              theme.snackBarTheme.actionTextColor!,
              theme.snackBarTheme.backgroundColor!,
            ),
          ];
          for (final pair in pairs) {
            final first = pair.$1.computeLuminance();
            final second = pair.$2.computeLuminance();
            final contrast =
                first > second
                    ? (first + 0.05) / (second + 0.05)
                    : (second + 0.05) / (first + 0.05);
            expect(
              contrast,
              greaterThanOrEqualTo(4.5),
              reason: '${theme.brightness}: ${pair.$1} on ${pair.$2}',
            );
          }
        }
      },
    );

    test('disabled actions have distinct foreground and fill', () {
      for (final theme in [
        AppThemeFactory.light(AppThemeFamily.neoBrutalism),
        AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
      ]) {
        for (final style in [
          theme.filledButtonTheme.style!,
          theme.elevatedButtonTheme.style!,
        ]) {
          expect(
            style.foregroundColor!.resolve({WidgetState.disabled}),
            isNot(style.foregroundColor!.resolve({})),
          );
          expect(
            style.backgroundColor!.resolve({WidgetState.disabled}),
            isNot(style.backgroundColor!.resolve({})),
          );
        }
      }
    });

    test('factory returns cached complete light and dark variants', () {
      final light = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
      final dark = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);

      expect(
        identical(light, AppThemeFactory.light(AppThemeFamily.neoBrutalism)),
        isTrue,
      );
      expect(
        identical(dark, AppThemeFactory.dark(AppThemeFamily.neoBrutalism)),
        isTrue,
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);

      for (final theme in [light, dark]) {
        expect(theme.extension<AppSemanticColors>(), isNotNull);
        expect(theme.extension<AppProgressColors>(), isNotNull);
        expect(theme.extension<AppTutorialTokens>(), isNotNull);
        expect(theme.extension<AppMediaTokens>(), isNotNull);
        expect(theme.extension<AppShapeTokens>(), isNotNull);
        expect(theme.extension<AppSurfaceDecorationTokens>(), isNotNull);
        expect(theme.extension<AppSettingsPresentationTokens>(), isNotNull);
        expect(theme.extension<AppSurfaceTokens>(), isNotNull);
        expect(theme.extension<AppMotionTokens>(), isNotNull);
        expect(theme.extension<AppEffectTokens>(), isNotNull);
        expect(theme.extension<AppDataVisualizationTokens>(), isNotNull);
        expect(theme.extension<AppFlowTokens>(), isNotNull);
        expect(theme.extension<AppGenerationTokens>(), isNotNull);
        expect(theme.extension<AppNutritionTokens>(), isNotNull);
      }
    });

    test('uses the approved palette and hard-depth recipe', () {
      final light = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
      final dark = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);

      for (final theme in [light, dark]) {
        final isDark = theme.brightness == Brightness.dark;
        expect(
          theme.colorScheme.primary,
          isDark ? const Color(0xFFFFEA61) : const Color(0xFFFFE34D),
        );
        expect(
          theme.colorScheme.secondary,
          isDark ? const Color(0xFFD2A8FF) : const Color(0xFFC4A1FF),
        );
        expect(
          theme.colorScheme.tertiary,
          isDark ? const Color(0xFF55F0EA) : const Color(0xFF64DDE0),
        );
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
        expect(
          theme.semanticColors.completionAccent,
          isDark ? const Color(0xFFB8E67A) : const Color(0xFFA9CD80),
        );
        expect(
          theme.semanticColors.workoutContainer,
          isDark ? const Color(0xFFFFC184) : const Color(0xFFFFD2A3),
        );
        expect(
          theme.semanticColors.positive,
          isDark ? const Color(0xFF8CFF5A) : const Color(0xFF5F9E35),
        );
        expect(
          theme.semanticColors.warning,
          isDark ? const Color(0xFFFF8A3D) : const Color(0xFFFFB36B),
        );
        expect(
          theme.surfaceTokens.planCard,
          isDark ? const Color(0xFF55F0EA) : const Color(0xFF64DDE0),
        );
        expect(
          theme.surfaceTokens.planDuration,
          isDark ? const Color(0xFFFF8A3D) : const Color(0xFFFFB36B),
        );
        expect(
          theme.surfaceTokens.planGroup,
          isDark ? const Color(0xFFFF6BAE) : const Color(0xFFFF92BF),
        );
        expect(
          theme.surfaceTokens.sessionSummary,
          isDark ? const Color(0xFFE0C9FF) : const Color(0xFFDAC8F1),
        );
        expect(
          theme.surfaceTokens.settingsHero,
          isDark ? const Color(0xFFFFEA61) : const Color(0xFFFFE34D),
        );
        expect(
          theme.surfaceTokens.settingsInput,
          isDark ? const Color(0xFFFFE875) : const Color(0xFFFFF0A6),
        );
        expect(
          theme.surfaceTokens.settingsSaveBar,
          isDark ? const Color(0xFFFFEA61) : const Color(0xFFFFE34D),
        );
        expect(theme.shapeTokens.outlineWidth, 2);
        expect(theme.shapeTokens.focusRingWidth, 3);
        expect(theme.effectTokens.cardElevation, 0);
        expect(theme.effectTokens.cardShadowBlur, 0);
        expect(theme.effectTokens.cardShadowOffset, const Offset(3, 3));
        expect(theme.effectTokens.completedSetShadowOffset, const Offset(2, 2));
        expect(theme.effectTokens.raisedPanelShadowOffset, const Offset(4, 4));
        expect(
          theme.effectTokens.primaryActionShadowOffset,
          const Offset(4, 4),
        );
        expect(theme.effectTokens.dialogShadowOffset, const Offset(4, 4));
        expect(theme.effectTokens.noEffectsShadowOpacity, 0);
        expect(
          theme.surfaceDecorationTokens.card.depth,
          AppSurfaceDepth.explicitShadow,
        );
        expect(theme.surfaceDecorationTokens.card.outlined, isTrue);
        expect(theme.settingsPresentationTokens.heroUsesGradient, isFalse);
        expect(theme.settingsPresentationTokens.heroUsesHardShadow, isTrue);
        expect(
          theme.settingsPresentationTokens.sectionUsesAccentForControls,
          isFalse,
        );
        expect(theme.settingsPresentationTokens.sectionHeaderUsesLabel, isTrue);
        expect(
          theme.settingsPresentationTokens.sectionHeaderFill,
          isDark ? const Color(0xFFFF6BAE) : const Color(0xFFFF92BF),
        );
        expect(
          theme.settingsPresentationTokens.sectionHeaderForeground,
          const Color(0xFF161616),
        );
        expect(
          theme.settingsPresentationTokens.saveActionUsesHardShadow,
          isTrue,
        );
      }

      expect(light.scaffoldBackgroundColor, const Color(0xFFFFF8E7));
      expect(dark.scaffoldBackgroundColor, const Color(0xFF171717));
    });

    test('separates dark neutral outlines from colored structural edges', () {
      final dark = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);

      expect(dark.colorScheme.outline, const Color(0xFFFFF8E7));
      expect(
        dark.colorScheme.outlineVariant,
        const Color(0xFFFFF8E7).withValues(alpha: 0.72),
      );
      expect(dark.surfaceTokens.subtleOutline, const Color(0xFF161616));
      expect(dark.surfaceTokens.neutralOutline, const Color(0xFF81776B));
      expect(
        dark.surfaceTokens.divider,
        const Color(0xFF161616).withValues(alpha: 0.3),
      );
      expect(
        (dark.cardTheme.shape! as RoundedRectangleBorder).side.color,
        const Color(0xFF161616),
      );
      expect(dark.textTheme.bodyMedium?.color, const Color(0xFFFFF8E7));
      expect(dark.dataVisualizationTokens.firstRecord, const Color(0xFFFFF8E7));
    });

    test('keeps Neo focus, text, and data-detail roles intentional', () {
      final light = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
      final dark = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);

      expect(
        (light.inputDecorationTheme.enabledBorder! as OutlineInputBorder)
            .borderSide
            .color,
        const Color(0xFF161616),
      );
      expect(
        (dark.inputDecorationTheme.enabledBorder! as OutlineInputBorder)
            .borderSide
            .color,
        const Color(0xFF81776B),
      );
      expect(
        dark.textButtonTheme.style!.side!.resolve(<WidgetState>{}),
        BorderSide.none,
      );
      final focusedTextButtonSide = dark.textButtonTheme.style!.side!.resolve({
        WidgetState.focused,
      });
      expect(focusedTextButtonSide?.color, const Color(0xFFD2A8FF));
      expect(focusedTextButtonSide?.width, 3);
      expect(
        dark.textButtonTheme.style!.side!.resolve({
          WidgetState.disabled,
          WidgetState.focused,
        }),
        BorderSide.none,
      );

      expect(light.textTheme.headlineLarge?.fontWeight, FontWeight.w900);
      expect(light.textTheme.titleMedium?.fontWeight, FontWeight.w800);
      expect(light.textTheme.labelSmall?.fontWeight, FontWeight.w700);
      expect(light.textTheme.bodyMedium?.height, 1.3);

      expect(
        light.dataVisualizationTokens.primarySeries,
        const Color(0xFF64408F),
      );
      expect(
        light.dataVisualizationTokens.heatmapHigh,
        const Color(0xFF006A72),
      );
      expect(light.progressColors.workoutIncrease, const Color(0xFF38651F));
      expect(light.progressColors.workoutDecrease, const Color(0xFF9B284C));
    });

    testWidgets('Neo TextButton focus state is rendered and keyboard active', (
      tester,
    ) async {
      var activations = 0;
      final focusNode = FocusNode(debugLabel: 'enabled text button');
      final disabledFocusNode = FocusNode(debugLabel: 'disabled text button');
      addTearDown(focusNode.dispose);
      addTearDown(disabledFocusNode.dispose);

      Future<void> pumpButton({required bool enabled}) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
            home: Scaffold(
              body: TextButton(
                key: const ValueKey('focus-test-button'),
                focusNode: enabled ? focusNode : disabledFocusNode,
                onPressed: enabled ? () => activations++ : null,
                child: const Text('Action'),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await pumpButton(enabled: true);
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final buttonFinder = find.byKey(const ValueKey('focus-test-button'));
      final materialFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Material),
      );
      expect(materialFinder, findsOneWidget);
      final focusedMaterial = tester.widget<Material>(materialFinder);
      final focusedShape = focusedMaterial.shape;
      expect(focusedShape, isA<OutlinedBorder>());
      final focusedSide = (focusedShape! as OutlinedBorder).side;
      expect(focusedSide.color, const Color(0xFFD2A8FF));
      expect(focusedSide.width, 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activations, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(activations, 2);

      focusNode.unfocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final unfocusedMaterial = tester.widget<Material>(materialFinder);
      final unfocusedShape = unfocusedMaterial.shape;
      expect((unfocusedShape! as OutlinedBorder).side, BorderSide.none);

      await pumpButton(enabled: false);
      disabledFocusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final disabledMaterial = tester.widget<Material>(materialFinder);
      final disabledShape = disabledMaterial.shape;
      expect((disabledShape! as OutlinedBorder).side, BorderSide.none);
      expect(activations, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Neo light focus renders and Classic stays unmodified', (
      tester,
    ) async {
      Future<BorderSide> pumpFocusedButton(ThemeData theme) async {
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: TextButton(
                key: const ValueKey('family-focus-test-button'),
                focusNode: focusNode,
                onPressed: () {},
                child: const Text('Action'),
              ),
            ),
          ),
        );
        focusNode.requestFocus();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byKey(const ValueKey('family-focus-test-button')),
            matching: find.byType(Material),
          ),
        );
        return (material.shape! as OutlinedBorder).side;
      }

      final lightSide = await pumpFocusedButton(
        AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      );
      expect(lightSide.color, const Color(0xFF64408F));
      expect(lightSide.width, 3);

      final classicSide = await pumpFocusedButton(
        AppThemeFactory.light(AppThemeFamily.classic),
      );
      expect(
        classicSide,
        isNot(const BorderSide(color: Color(0xFF64408F), width: 3)),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('surface helpers follow bright and neutral Neo roles', (
      tester,
    ) async {
      final dark = AppThemeFactory.dark(AppThemeFamily.neoBrutalism);
      late Color brightForeground;
      late Color neutralForeground;
      late Color brightOutline;
      late Color neutralOutline;
      late Color brightHeatmapLow;
      late Color neutralHeatmapLow;

      await tester.pumpWidget(
        MaterialApp(
          theme: dark,
          home: Builder(
            builder: (context) {
              brightForeground = tonosForegroundForSurface(
                context,
                context.surfaceTokens.settingsSection,
              );
              neutralForeground = tonosForegroundForSurface(
                context,
                context.surfaceTokens.card,
              );
              brightOutline = tonosOutlineForSurface(
                context,
                context.surfaceTokens.settingsSection,
              );
              neutralOutline = tonosOutlineForSurface(
                context,
                context.surfaceTokens.card,
                neutral: true,
              );
              brightHeatmapLow = tonosHeatmapLowForSurface(
                context,
                context.surfaceTokens.settingsSection,
              );
              neutralHeatmapLow = tonosHeatmapLowForSurface(
                context,
                context.surfaceTokens.card,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(brightForeground, const Color(0xFF161616));
      expect(neutralForeground, const Color(0xFFFFF8E7));
      expect(brightOutline, const Color(0xFF161616));
      expect(neutralOutline, const Color(0xFF81776B));
      expect(brightHeatmapLow, const Color(0xFF4B4740));
      expect(neutralHeatmapLow, dark.dataVisualizationTokens.heatmapLow);
    });

    testWidgets('bright Neo data roles meet minimum contrast in both modes', (
      tester,
    ) async {
      for (final theme in [
        AppThemeFactory.light(AppThemeFamily.neoBrutalism),
        AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
      ]) {
        late List<(Color, Color, Color, Color)> resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                final surfaces = context.surfaceTokens;
                final brightSurfaces = <Color>[
                  surfaces.settingsHero,
                  surfaces.settingsSection,
                  surfaces.settingsInput,
                  surfaces.settingsSaveBar,
                  surfaces.flowControl,
                  surfaces.planCard,
                  surfaces.planActionBar,
                  surfaces.optimizedAction,
                  surfaces.presetFocus,
                  surfaces.planFilter,
                  surfaces.planDuration,
                  surfaces.planGroup,
                  surfaces.metricChip,
                  surfaces.dialogChoice,
                  surfaces.catalogSelection,
                  surfaces.exerciseDetailTimeframe,
                  surfaces.exerciseDetailRecord,
                  surfaces.exerciseDetailState,
                  surfaces.exerciseDetailChart,
                  surfaces.exerciseProgressHero,
                  surfaces.exerciseProgressSelector,
                  surfaces.workoutMetricRange,
                  surfaces.workoutMetricInsight,
                  surfaces.dashboardHero,
                  surfaces.dashboardUsage,
                  surfaces.historyPeriodSelector,
                  surfaces.calendarModeSelector,
                  surfaces.historySelectedPeriod,
                  surfaces.sessionSummary,
                ];
                resolved = [
                  for (final surface in brightSurfaces)
                    (
                      _compositeTestSurface(surface, theme.colorScheme.surface),
                      tonosPrimarySeriesForSurface(context, surface),
                      tonosSecondarySeriesForSurface(context, surface),
                      tonosHeatmapHighForSurface(context, surface),
                    ),
                ];
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        for (final pair in resolved) {
          final background = pair.$1;
          expect(
            _contrastRatioForTest(pair.$2, background),
            greaterThanOrEqualTo(3),
          );
          expect(
            _contrastRatioForTest(pair.$3, background),
            greaterThanOrEqualTo(3),
          );
          expect(
            _contrastRatioForTest(pair.$4, background),
            greaterThanOrEqualTo(3),
          );
        }
      }
    });

    testWidgets('Classic keeps its original data visualization roles', (
      tester,
    ) async {
      final theme = AppThemeFactory.dark(AppThemeFamily.classic);
      late Color primary;
      late Color secondary;
      late Color heatmap;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final surface = context.surfaceTokens.planGroup;
              primary = tonosPrimarySeriesForSurface(context, surface);
              secondary = tonosSecondarySeriesForSurface(context, surface);
              heatmap = tonosHeatmapHighForSurface(context, surface);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(primary, theme.dataVisualizationTokens.primarySeries);
      expect(secondary, theme.dataVisualizationTokens.secondarySeries);
      expect(heatmap, theme.dataVisualizationTokens.heatmapHigh);
    });

    test(
      'defines the material state recipes without conventional elevation',
      () {
        final theme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);

        expect(theme.cardTheme.elevation, 0);
        expect(theme.floatingActionButtonTheme.elevation, 0);
        expect(theme.dialogTheme.elevation, 0);
        expect(theme.bottomSheetTheme.elevation, 0);
        expect(theme.bottomSheetTheme.modalElevation, 0);
        expect(
          theme.bottomNavigationBarTheme.backgroundColor,
          const Color(0xFFFFE34D),
        );
        expect(theme.progressIndicatorTheme.color, const Color(0xFFC4A1FF));
        expect(theme.dividerTheme.thickness, 2);
        expect(theme.inputDecorationTheme.enabledBorder, isNotNull);
        expect(theme.inputDecorationTheme.focusedBorder, isNotNull);
      },
    );
  });
}
