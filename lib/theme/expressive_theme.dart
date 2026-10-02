import 'package:material_ui/material_ui.dart';

import 'app_material_theme.dart';
import 'classic_theme.dart';
import 'theme_extensions.dart';
import 'tokens/app_data_visualization_tokens.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_expressive_train_tokens.dart';
import 'tokens/app_flow_tokens.dart';
import 'tokens/app_generation_tokens.dart';
import 'tokens/app_media_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_nutrition_tokens.dart';
import 'tokens/app_progress_colors.dart';
import 'tokens/app_semantic_colors.dart';
import 'tokens/app_settings_presentation_tokens.dart';
import 'tokens/app_shape_tokens.dart';
import 'tokens/app_surface_decoration_tokens.dart';
import 'tokens/app_surface_tokens.dart';
import 'tokens/app_tutorial_tokens.dart';

/// Review-only palette candidates for the non-persisted Expressive preview.
enum ExpressivePaletteTreatment { generated, curated }

/// Cached paired Material recipes for the non-persisted Expressive preview.
///
/// The palette starts from Tonos's existing Deep Purple seed using the SDK's
/// ordinary generated scheme. The Expressive variant name is intentionally not
/// used as a hue promise; the visible Train treatment comes from semantic role
/// assignment and a small neutral-surface curation.
abstract final class ExpressiveThemeDefinition {
  static final ThemeData _generatedLight = _build(
    Brightness.light,
    ExpressivePaletteTreatment.generated,
  );
  static final ThemeData _generatedDark = _build(
    Brightness.dark,
    ExpressivePaletteTreatment.generated,
  );
  static final ThemeData _curatedLight = _build(
    Brightness.light,
    ExpressivePaletteTreatment.curated,
  );
  static final ThemeData _curatedDark = _build(
    Brightness.dark,
    ExpressivePaletteTreatment.curated,
  );
  static final AppProgressColors _classicLightProgress =
      ClassicThemeDefinition.light().extension<AppProgressColors>()!;
  static final AppProgressColors _classicDarkProgress =
      ClassicThemeDefinition.dark().extension<AppProgressColors>()!;

  static ThemeData light({
    ExpressivePaletteTreatment treatment = ExpressivePaletteTreatment.curated,
  }) => switch (treatment) {
    ExpressivePaletteTreatment.generated => _generatedLight,
    ExpressivePaletteTreatment.curated => _curatedLight,
  };

  static ThemeData dark({
    ExpressivePaletteTreatment treatment = ExpressivePaletteTreatment.curated,
  }) => switch (treatment) {
    ExpressivePaletteTreatment.generated => _generatedDark,
    ExpressivePaletteTreatment.curated => _curatedDark,
  };

  static ThemeData _build(
    Brightness brightness,
    ExpressivePaletteTreatment treatment,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );
    final semanticColors = AppSemanticColors.fromColorScheme(colorScheme)
        .copyWith(
          primaryAction: colorScheme.primary,
          onPrimaryAction: colorScheme.onPrimary,
          startWorkoutAction: colorScheme.primary,
          onStartWorkoutAction: colorScheme.onPrimary,
          workoutCompleted: brightness == Brightness.light
              ? const Color(0xFF286F3A)
              : const Color(0xFF5EB171),
          workoutExerciseCompleted: brightness == Brightness.light
              ? const Color(0xFF6D9A73)
              : const Color(0xFF286A3A),
          workoutSetCompleted: brightness == Brightness.light
              ? const Color(0xFF78A87F)
              : const Color(0xFF4B8A56),
        );
    final shapeTokens = AppShapeTokens.classic.copyWith(
      card: BorderRadius.circular(18),
      planCard: BorderRadius.circular(18),
      trainTab: BorderRadius.circular(16),
      trainTabButton: BorderRadius.circular(12),
    );
    final generatedSurfaces = AppSurfaceTokens.fromColorScheme(colorScheme);
    final surfaceTokens = switch (treatment) {
      ExpressivePaletteTreatment.generated => generatedSurfaces.copyWith(
        workoutCardCompleteFill: brightness == Brightness.light ? 0.34 : 0.18,
        workoutSetCompleteFill: brightness == Brightness.light ? 0.92 : 0.72,
      ),
      ExpressivePaletteTreatment.curated => generatedSurfaces.copyWith(
        workoutCardCompleteFill: brightness == Brightness.light ? 0.34 : 0.18,
        workoutSetCompleteFill: brightness == Brightness.light ? 0.92 : 0.72,
        panel: colorScheme.surfaceContainerLow,
        panelRaised: colorScheme.surfaceContainer,
        card: colorScheme.surfaceContainer,
        planCard: colorScheme.surfaceContainerLow,
        planGroup: colorScheme.surfaceContainer,
        sheet: colorScheme.surfaceContainerHigh,
        dialog: colorScheme.surfaceContainerHigh,
        dashboardHero: colorScheme.surfaceContainerLow,
      ),
    };
    final base = AppMaterialTheme.fromColorScheme(colorScheme: colorScheme);
    final classicProgressColors = brightness == Brightness.light
        ? _classicLightProgress
        : _classicDarkProgress;

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeIdentity(
          family: AppThemeFamilyIdentity.expressivePreview,
        ),
        semanticColors,
        brightness == Brightness.light
            ? AppExpressiveTrainTokens.light
            : AppExpressiveTrainTokens.dark,
        shapeTokens,
        surfaceTokens,
        AppSurfaceDecorationTokens.classic,
        AppEffectTokens.classic(brightness),
        AppMotionTokens.classic,
        AppDataVisualizationTokens.fromBrightness(brightness),
        classicProgressColors,
        AppSettingsPresentationTokens.classic,
        AppTutorialTokens.classic,
        AppMediaTokens.classic,
        AppFlowTokens.classic(brightness),
        AppGenerationTokens.fromColorScheme(colorScheme),
        AppNutritionTokens.classic(brightness),
      ],
    );
  }
}
