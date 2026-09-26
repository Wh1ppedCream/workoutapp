import 'package:flutter/material.dart';

/// Theme roles for nutrition-specific surfaces that are not generic actions.
@immutable
class AppNutritionTokens extends ThemeExtension<AppNutritionTokens> {
  const AppNutritionTokens({
    required this.pantryLogSurface,
    required this.addMealSurface,
    required this.planMealSurface,
    required this.textDetailsBorder,
    this.foodBorder = const Color(0xFFE0E0E0),
    this.photoPlaceholder = const Color(0xFFEEEEEE),
    this.mutedAction = const Color(0xFF9E9E9E),
    this.favoriteAction = const Color(0xFFFFC107),
    this.addFoodAction = const Color(0xFF4CAF50),
    this.densityHelp = Colors.black54,
    this.selectedLabel = Colors.white,
    this.logGrid = const Color(0xFFEEEEEE),
    this.compactShape = const BorderRadius.all(Radius.circular(8)),
    this.sectionShape = const BorderRadius.all(Radius.circular(12)),
    this.portionShape = const BorderRadius.all(Radius.circular(10)),
    this.quantityShape = const BorderRadius.all(Radius.circular(6)),
  });

  /// Builds a complete fallback from the active Material color scheme.
  factory AppNutritionTokens.fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return AppNutritionTokens(
      pantryLogSurface:
          isDark
              ? scheme.surfaceContainerHighest
              : scheme.surfaceContainerHighest.withValues(alpha: 0.72),
      addMealSurface:
          isDark
              ? scheme.secondaryContainer
              : scheme.secondaryContainer.withValues(alpha: 0.8),
      planMealSurface:
          isDark
              ? scheme.tertiaryContainer
              : scheme.tertiaryContainer.withValues(alpha: 0.8),
      textDetailsBorder: scheme.outline,
    );
  }

  /// Values that preserve the reviewed Classic nutrition UI.
  factory AppNutritionTokens.classic(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppNutritionTokens(
      pantryLogSurface:
          isDark ? const Color(0xFF4E4E1A) : const Color(0xFFFFF9C4),
      addMealSurface:
          isDark ? const Color(0xFF2E4E2E) : const Color(0xFFC8E6C9),
      planMealSurface:
          isDark ? const Color(0xFF1A2E4E) : const Color(0xFFBBDEFB),
      textDetailsBorder:
          isDark
              ? const Color.fromARGB(255, 100, 100, 100)
              : const Color.fromARGB(255, 223, 223, 223),
    );
  }

  final Color pantryLogSurface;
  final Color addMealSurface;
  final Color planMealSurface;
  final Color textDetailsBorder;

  // These defaults preserve the existing food UI in both Classic modes.
  final Color foodBorder;
  final Color photoPlaceholder;
  final Color mutedAction;
  final Color favoriteAction;
  final Color addFoodAction;
  final Color densityHelp;
  final Color selectedLabel;
  final Color logGrid;
  final BorderRadius compactShape;
  final BorderRadius sectionShape;
  final BorderRadius portionShape;
  final BorderRadius quantityShape;

  @override
  AppNutritionTokens copyWith({
    Color? pantryLogSurface,
    Color? addMealSurface,
    Color? planMealSurface,
    Color? textDetailsBorder,
    Color? foodBorder,
    Color? photoPlaceholder,
    Color? mutedAction,
    Color? favoriteAction,
    Color? addFoodAction,
    Color? densityHelp,
    Color? selectedLabel,
    Color? logGrid,
    BorderRadius? compactShape,
    BorderRadius? sectionShape,
    BorderRadius? portionShape,
    BorderRadius? quantityShape,
  }) {
    return AppNutritionTokens(
      pantryLogSurface: pantryLogSurface ?? this.pantryLogSurface,
      addMealSurface: addMealSurface ?? this.addMealSurface,
      planMealSurface: planMealSurface ?? this.planMealSurface,
      textDetailsBorder: textDetailsBorder ?? this.textDetailsBorder,
      foodBorder: foodBorder ?? this.foodBorder,
      photoPlaceholder: photoPlaceholder ?? this.photoPlaceholder,
      mutedAction: mutedAction ?? this.mutedAction,
      favoriteAction: favoriteAction ?? this.favoriteAction,
      addFoodAction: addFoodAction ?? this.addFoodAction,
      densityHelp: densityHelp ?? this.densityHelp,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      logGrid: logGrid ?? this.logGrid,
      compactShape: compactShape ?? this.compactShape,
      sectionShape: sectionShape ?? this.sectionShape,
      portionShape: portionShape ?? this.portionShape,
      quantityShape: quantityShape ?? this.quantityShape,
    );
  }

  @override
  AppNutritionTokens lerp(
    covariant ThemeExtension<AppNutritionTokens>? other,
    double t,
  ) {
    if (other is! AppNutritionTokens) return this;
    return AppNutritionTokens(
      pantryLogSurface:
          Color.lerp(pantryLogSurface, other.pantryLogSurface, t)!,
      addMealSurface: Color.lerp(addMealSurface, other.addMealSurface, t)!,
      planMealSurface: Color.lerp(planMealSurface, other.planMealSurface, t)!,
      textDetailsBorder:
          Color.lerp(textDetailsBorder, other.textDetailsBorder, t)!,
      foodBorder: Color.lerp(foodBorder, other.foodBorder, t)!,
      photoPlaceholder:
          Color.lerp(photoPlaceholder, other.photoPlaceholder, t)!,
      mutedAction: Color.lerp(mutedAction, other.mutedAction, t)!,
      favoriteAction: Color.lerp(favoriteAction, other.favoriteAction, t)!,
      addFoodAction: Color.lerp(addFoodAction, other.addFoodAction, t)!,
      densityHelp: Color.lerp(densityHelp, other.densityHelp, t)!,
      selectedLabel: Color.lerp(selectedLabel, other.selectedLabel, t)!,
      logGrid: Color.lerp(logGrid, other.logGrid, t)!,
      compactShape: BorderRadius.lerp(compactShape, other.compactShape, t)!,
      sectionShape: BorderRadius.lerp(sectionShape, other.sectionShape, t)!,
      portionShape: BorderRadius.lerp(portionShape, other.portionShape, t)!,
      quantityShape: BorderRadius.lerp(quantityShape, other.quantityShape, t)!,
    );
  }
}
