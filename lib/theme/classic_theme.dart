import 'package:flutter/material.dart';

import 'app_material_theme.dart';
import 'tokens/app_data_visualization_tokens.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_flow_tokens.dart';
import 'tokens/app_generation_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_nutrition_tokens.dart';
import 'tokens/app_semantic_colors.dart';
import 'tokens/app_shape_tokens.dart';
import 'tokens/app_settings_presentation_tokens.dart';
import 'tokens/app_surface_decoration_tokens.dart';
import 'tokens/app_surface_tokens.dart';
import 'tokens/app_media_tokens.dart';
import 'tokens/app_progress_colors.dart';
import 'tokens/app_tutorial_tokens.dart';

/// The unchanged visual definition of the permanent Classic theme family.
abstract final class ClassicThemeDefinition {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    final semanticColors = AppSemanticColors.fromColorScheme(colorScheme);
    final effectTokens = AppEffectTokens.classic(colorScheme.brightness);
    final surfaceTokens = AppSurfaceTokens.fromColorScheme(
      colorScheme,
    ).copyWith(
      divider: const Color(0xFFBDBDBD),
      subtleOutline: const Color(0xFFE0E0E0),
    );
    final lightBase = AppMaterialTheme.fromColorScheme(
      colorScheme: colorScheme,
    );
    final dataVisualizationTokens = AppDataVisualizationTokens.fromBrightness(
      lightBase.brightness,
    );
    final flowTokens = AppFlowTokens.classic(lightBase.brightness);
    final nutritionTokens = AppNutritionTokens.classic(lightBase.brightness);
    return lightBase.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        semanticColors,
        AppProgressColors.fromTheme(lightBase),
        AppTutorialTokens.classic,
        AppMediaTokens.classic,
        AppShapeTokens.classic,
        AppSurfaceDecorationTokens.classic,
        AppSettingsPresentationTokens.classic,
        surfaceTokens,
        AppMotionTokens.classic,
        effectTokens,
        dataVisualizationTokens,
        flowTokens,
        AppGenerationTokens.classic(colorScheme),
        nutritionTokens,
      ],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.deepPurple,
    );
    final semanticColors = AppSemanticColors.fromColorScheme(colorScheme);
    final effectTokens = AppEffectTokens.classic(colorScheme.brightness);
    final surfaceTokens = AppSurfaceTokens.fromColorScheme(
      colorScheme,
    ).copyWith(
      divider: const Color(0xFF616161),
      subtleOutline: const Color(0xFF616161),
    );
    final darkBase = AppMaterialTheme.fromColorScheme(colorScheme: colorScheme);
    final dataVisualizationTokens = AppDataVisualizationTokens.fromBrightness(
      darkBase.brightness,
    );
    final flowTokens = AppFlowTokens.classic(darkBase.brightness);
    final nutritionTokens = AppNutritionTokens.classic(darkBase.brightness);
    return darkBase.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        semanticColors,
        AppProgressColors.fromTheme(darkBase),
        AppTutorialTokens.classic,
        AppMediaTokens.classic,
        AppShapeTokens.classic,
        AppSurfaceDecorationTokens.classic,
        AppSettingsPresentationTokens.classic,
        surfaceTokens,
        AppMotionTokens.classic,
        effectTokens,
        dataVisualizationTokens,
        flowTokens,
        AppGenerationTokens.classic(colorScheme),
        nutritionTokens,
      ],
    );
  }
}
