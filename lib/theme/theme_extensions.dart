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
import 'tokens/app_settings_presentation_tokens.dart';
import 'tokens/app_surface_decoration_tokens.dart';
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

  AppSurfaceDecorationTokens get surfaceDecorationTokens =>
      extension<AppSurfaceDecorationTokens>() ??
      AppSurfaceDecorationTokens.classic;

  /// Only registered Classic themes opt into baseline presentation branches.
  /// Generic Material themes use the adaptive component defaults instead.
  bool get usesClassicPresentation {
    final decorations = extension<AppSurfaceDecorationTokens>();
    return decorations != null && !decorations.panel.outlined;
  }

  AppSettingsPresentationTokens get settingsPresentationTokens =>
      extension<AppSettingsPresentationTokens>() ??
      AppSettingsPresentationTokens.classic;

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
  AppSurfaceDecorationTokens get surfaceDecorationTokens =>
      Theme.of(this).surfaceDecorationTokens;
  bool get usesClassicPresentation => Theme.of(this).usesClassicPresentation;
  AppSettingsPresentationTokens get settingsPresentationTokens =>
      Theme.of(this).settingsPresentationTokens;
  AppMotionTokens get motionTokens => Theme.of(this).motionTokens;
  AppEffectTokens get effectTokens => Theme.of(this).effectTokens;
  AppDataVisualizationTokens get dataVisualizationTokens =>
      Theme.of(this).dataVisualizationTokens;
  AppFlowTokens get flowTokens => Theme.of(this).flowTokens;
  AppGenerationTokens get generationTokens => Theme.of(this).generationTokens;
  AppNutritionTokens get nutritionTokens => Theme.of(this).nutritionTokens;
}

const _neoDarkInk = Color(0xFF161616);
const _neoWarmPaper = Color(0xFFFFF8E7);
const _neoBrightPanelPurple = Color(0xFF4D2D78);
const _neoBrightPanelCyan = Color(0xFF006A72);
const _neoBrightPanelHeatmapLow = Color(0xFF4B4740);

/// Chooses the readable foreground for a painted surface.
///
/// Classic deliberately keeps its ColorScheme behavior. Neo first honors the
/// semantic neutral-surface roles, then compares its two approved foregrounds
/// against the actual painted color. Alpha surfaces are composited over their
/// parent before that comparison so a translucent fill cannot select a color
/// from the wrong visual background.
Color tonosForegroundForSurface(
  BuildContext context,
  Color surface, {
  Color? parentSurface,
}) {
  final theme = Theme.of(context);
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return theme.colorScheme.onSurface;
  }

  if (_isKnownNeutralSurface(context, surface)) {
    // Nested bright panels can override onSurface; neutral roles must not
    // inherit that dark foreground when they paint a charcoal background.
    return context.semanticColors.strongContent;
  }

  if (_isKnownBrightSurface(context, surface)) {
    return _neoDarkInk;
  }

  final background = _compositeSurface(
    surface,
    parentSurface ?? theme.colorScheme.surface,
  );
  final darkInkContrast = _contrastRatio(_neoDarkInk, background);
  final warmPaperContrast = _contrastRatio(_neoWarmPaper, background);
  return darkInkContrast >= warmPaperContrast ? _neoDarkInk : _neoWarmPaper;
}

/// Resolves the secondary foreground that belongs with [surface].
Color tonosSecondaryForegroundForSurface(
  BuildContext context,
  Color surface, {
  Color? parentSurface,
}) {
  final theme = Theme.of(context);
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return theme.colorScheme.onSurfaceVariant;
  }

  final foreground = tonosForegroundForSurface(
    context,
    surface,
    parentSurface: parentSurface,
  );
  final candidate =
      foreground == _neoDarkInk
          ? _neoDarkInk.withValues(alpha: 0.78)
          : const Color(0xFFD8CFBE);
  final background = _compositeSurface(
    surface,
    parentSurface ?? theme.colorScheme.surface,
  );
  return _contrastRatio(_compositeSurface(candidate, background), background) >=
          4.5
      ? candidate
      : foreground;
}

/// Resolves an outline from an explicit surface role.
///
/// Bright colored panels retain the near-black structural edge. Known neutral
/// surfaces use the theme's restrained neutral outline so their boundaries do
/// not disappear into a dark Neo canvas. Callers painting an arbitrary neutral
/// surface can pass `neutral: true`; no luminance guessing is used.
Color tonosOutlineForSurface(
  BuildContext context,
  Color surface, {
  bool? neutral,
}) {
  final surfaces = context.surfaceTokens;
  if (neutral == true) return surfaces.neutralOutline;
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return surfaces.subtleOutline;
  }

  final isNeutral = _isKnownNeutralSurface(context, surface);
  if (isNeutral) return surfaces.neutralOutline;
  return surfaces.subtleOutline;
}

/// Resolves the inactive anatomy color for the surface that will actually
/// contain the diagram. Bright Neo panels need a darker inactive silhouette
/// than the charcoal canvas, while the intensity ordering remains unchanged.
Color tonosHeatmapLowForSurface(BuildContext context, Color surface) {
  if (!context.surfaceDecorationTokens.panel.outlined) {
    return context.dataVisualizationTokens.heatmapLow;
  }

  if (_isKnownBrightSurface(context, surface)) {
    return _neoDataColorForSurface(
      context,
      surface,
      candidates: const [_neoBrightPanelHeatmapLow, _neoDarkInk],
    );
  }
  return context.dataVisualizationTokens.heatmapLow;
}

/// Resolves the primary chart stroke for its actual painted surface.
///
/// Neo keeps luminous colors on charcoal, but bright panels need darker
/// structural chart colors so lines and points remain visible in both modes.
Color tonosPrimarySeriesForSurface(BuildContext context, Color surface) {
  final data = context.dataVisualizationTokens;
  if (!context.surfaceDecorationTokens.panel.outlined ||
      !_isKnownBrightSurface(context, surface)) {
    return data.primarySeries;
  }
  return _neoDataColorForSurface(
    context,
    surface,
    candidates: const [_neoBrightPanelPurple, _neoDarkInk],
  );
}

/// Resolves the secondary chart stroke for its actual painted surface.
Color tonosSecondarySeriesForSurface(BuildContext context, Color surface) {
  final data = context.dataVisualizationTokens;
  if (!context.surfaceDecorationTokens.panel.outlined ||
      !_isKnownBrightSurface(context, surface)) {
    return data.secondarySeries;
  }
  return _neoDataColorForSurface(
    context,
    surface,
    candidates: const [_neoBrightPanelCyan, _neoDarkInk],
  );
}

/// Resolves the high-intensity anatomy color for its actual painted surface.
Color tonosHeatmapHighForSurface(BuildContext context, Color surface) {
  final data = context.dataVisualizationTokens;
  if (!context.surfaceDecorationTokens.panel.outlined ||
      !_isKnownBrightSurface(context, surface)) {
    return data.heatmapHigh;
  }
  return _neoDataColorForSurface(
    context,
    surface,
    candidates: const [_neoBrightPanelCyan, _neoDarkInk],
  );
}

Color _neoDataColorForSurface(
  BuildContext context,
  Color surface, {
  required List<Color> candidates,
  Color? parentSurface,
  double minimumContrast = 3,
}) {
  final background = _compositeSurface(
    surface,
    parentSurface ?? Theme.of(context).colorScheme.surface,
  );
  for (final candidate in candidates) {
    if (_contrastRatio(candidate, background) >= minimumContrast) {
      return candidate;
    }
  }
  return _neoDarkInk;
}

Color _compositeSurface(Color surface, Color parent) {
  return surface.a < 1 ? Color.alphaBlend(surface, parent) : surface;
}

bool _isKnownNeutralSurface(BuildContext context, Color surface) {
  final surfaces = context.surfaceTokens;
  return surface == surfaces.panel ||
      surface == surfaces.panelRaised ||
      surface == surfaces.card ||
      surface == surfaces.input ||
      surface == surfaces.sheet ||
      surface == surfaces.dialog ||
      surface == surfaces.media ||
      surface == surfaces.mediaFrame ||
      surface == surfaces.mediaPlaceholder ||
      surface == surfaces.catalogUsage ||
      surface == surfaces.exerciseDetailCard ||
      surface == surfaces.exerciseDetailTooltip ||
      surface == surfaces.exerciseDetailMetricList ||
      surface == surfaces.exerciseDetailChartEmpty ||
      surface == surfaces.exerciseProgressTooltip ||
      surface == surfaces.workoutMetricStat ||
      surface == surfaces.workoutMetricChart ||
      surface == surfaces.workoutMetricTooltip ||
      surface == surfaces.workoutMetricDetails ||
      surface == surfaces.dashboardSection ||
      surface == surfaces.dashboardEditor;
}

bool _isKnownBrightSurface(BuildContext context, Color surface) {
  final surfaces = context.surfaceTokens;
  return surface == surfaces.settingsHero ||
      surface == surfaces.settingsSection ||
      surface == surfaces.settingsInput ||
      surface == surfaces.settingsSaveBar ||
      surface == surfaces.flowControl ||
      surface == surfaces.planCard ||
      surface == surfaces.planActionBar ||
      surface == surfaces.optimizedAction ||
      surface == surfaces.presetFocus ||
      surface == surfaces.planFilter ||
      surface == surfaces.planDuration ||
      surface == surfaces.planGroup ||
      surface == surfaces.metricChip ||
      surface == surfaces.dialogChoice ||
      surface == surfaces.catalogSelection ||
      surface == surfaces.exerciseDetailTimeframe ||
      surface == surfaces.exerciseDetailRecord ||
      surface == surfaces.exerciseDetailState ||
      surface == surfaces.exerciseDetailChart ||
      surface == surfaces.exerciseProgressHero ||
      surface == surfaces.exerciseProgressStat ||
      surface == surfaces.exerciseProgressSelector ||
      surface == surfaces.workoutMetricRange ||
      surface == surfaces.workoutMetricInsight ||
      surface == surfaces.dashboardHero ||
      surface == surfaces.dashboardUsage ||
      surface == surfaces.historyPeriodSelector ||
      surface == surfaces.calendarModeSelector ||
      surface == surfaces.historySelectedPeriod ||
      surface == surfaces.sessionSummary;
}

double _contrastRatio(Color foreground, Color background) {
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

/// Resolves a visual animation duration against the system reduced-motion
/// setting while retaining the active theme's reduced-motion recipe.
Duration appMotionDuration(BuildContext context, Duration duration) {
  if (!MediaQuery.disableAnimationsOf(context)) return duration;
  return context.motionTokens.reduced;
}
