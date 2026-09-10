// lib/theme/theme_extensions.dart

import 'package:flutter/material.dart';

import 'tokens/app_data_visualization_tokens.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_flow_tokens.dart';
import 'tokens/app_generation_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_nutrition_tokens.dart';
import 'tokens/app_semantic_colors.dart';
import 'tokens/app_shape_tokens.dart';
import 'tokens/app_surface_tokens.dart';
import 'tokens/app_media_tokens.dart';
import 'tokens/app_progress_colors.dart';
import 'tokens/app_tutorial_tokens.dart';

extension AppThemeDataX on ThemeData {
  AppTutorialTokens get tutorialTokens =>
      extension<AppTutorialTokens>() ?? AppTutorialTokens.classic;
  AppProgressColors get progressColors =>
      extension<AppProgressColors>() ?? AppProgressColors.fromTheme(this);
  AppMediaTokens get mediaTokens =>
      extension<AppMediaTokens>() ?? AppMediaTokens.classic;
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ??
      AppSemanticColors.fromColorScheme(colorScheme);

  AppShapeTokens get shapeTokens =>
      extension<AppShapeTokens>() ?? AppShapeTokens.classic;

  AppSurfaceTokens get surfaceTokens =>
      extension<AppSurfaceTokens>() ??
      AppSurfaceTokens.fromColorScheme(colorScheme);

  AppMotionTokens get motionTokens =>
      extension<AppMotionTokens>() ?? AppMotionTokens.classic;

  AppEffectTokens get effectTokens =>
      extension<AppEffectTokens>() ?? AppEffectTokens.classic(brightness);

  AppDataVisualizationTokens get dataVisualizationTokens =>
      extension<AppDataVisualizationTokens>() ??
      AppDataVisualizationTokens.fromBrightness(brightness);

  AppFlowTokens get flowTokens =>
      extension<AppFlowTokens>() ?? AppFlowTokens.fromColorScheme(colorScheme);

  AppGenerationTokens get generationTokens =>
      extension<AppGenerationTokens>() ??
      AppGenerationTokens.fromColorScheme(colorScheme);

  AppNutritionTokens get nutritionTokens =>
      extension<AppNutritionTokens>() ??
      AppNutritionTokens.fromColorScheme(colorScheme);
}

extension AppThemeX on BuildContext {
  AppTutorialTokens get tutorialTokens => Theme.of(this).tutorialTokens;
  AppProgressColors get progressColors => Theme.of(this).progressColors;
  AppMediaTokens get mediaTokens => Theme.of(this).mediaTokens;
  ColorScheme get cs => Theme.of(this).colorScheme;

  AppSemanticColors get semanticColors => Theme.of(this).semanticColors;
  AppShapeTokens get shapeTokens => Theme.of(this).shapeTokens;
  AppSurfaceTokens get surfaceTokens => Theme.of(this).surfaceTokens;
  AppMotionTokens get motionTokens => Theme.of(this).motionTokens;
  AppEffectTokens get effectTokens => Theme.of(this).effectTokens;
  AppDataVisualizationTokens get dataVisualizationTokens =>
      Theme.of(this).dataVisualizationTokens;
  AppFlowTokens get flowTokens => Theme.of(this).flowTokens;
  AppGenerationTokens get generationTokens => Theme.of(this).generationTokens;
  AppNutritionTokens get nutritionTokens => Theme.of(this).nutritionTokens;
}
