import 'package:flutter/material.dart';

/// Progress-specific recipes preserve the distinct legacy chart meanings.
/// Generic chart palettes are not interchangeable with these Material colors.
@immutable
class AppProgressColors extends ThemeExtension<AppProgressColors> {
  const AppProgressColors({
    required this.accent,
    required this.estimated,
    required this.estimatedOneRm,
    required this.grid,
    required this.label,
    required this.exerciseIncrease,
    required this.exerciseDecrease,
    required this.neutral,
    required this.workoutIncrease,
    required this.workoutDecrease,
    required this.healthIncrease,
    required this.healthDecrease,
    required this.healthCard,
    required this.healthGrid,
  });

  factory AppProgressColors.fromTheme(ThemeData theme) => AppProgressColors(
    accent: theme.colorScheme.primary,
    estimated: theme.colorScheme.onSurfaceVariant,
    estimatedOneRm: Colors.green.shade400,
    grid: theme.colorScheme.outlineVariant,
    label: theme.colorScheme.onSurfaceVariant,
    exerciseIncrease: Colors.green.shade400,
    exerciseDecrease: theme.colorScheme.error,
    neutral: theme.colorScheme.onSurfaceVariant,
    workoutIncrease: Colors.green.shade400,
    workoutDecrease: Colors.red.shade400,
    healthIncrease: Colors.greenAccent.shade400,
    healthDecrease: Colors.redAccent.shade100,
    healthCard: theme.cardColor,
    healthGrid: theme.dividerColor,
  );

  final Color accent;
  final Color estimated;

  /// The separate estimated one-rep-max series in exercise history charts.
  final Color estimatedOneRm;
  final Color grid;
  final Color label;
  final Color exerciseIncrease;
  final Color exerciseDecrease;
  final Color neutral;
  final Color workoutIncrease;
  final Color workoutDecrease;
  final Color healthIncrease;
  final Color healthDecrease;
  final Color healthCard;
  final Color healthGrid;

  @override
  AppProgressColors copyWith({
    Color? accent,
    Color? estimated,
    Color? estimatedOneRm,
    Color? grid,
    Color? label,
    Color? exerciseIncrease,
    Color? exerciseDecrease,
    Color? neutral,
    Color? workoutIncrease,
    Color? workoutDecrease,
    Color? healthIncrease,
    Color? healthDecrease,
    Color? healthCard,
    Color? healthGrid,
  }) => AppProgressColors(
    accent: accent ?? this.accent,
    estimated: estimated ?? this.estimated,
    estimatedOneRm: estimatedOneRm ?? this.estimatedOneRm,
    grid: grid ?? this.grid,
    label: label ?? this.label,
    exerciseIncrease: exerciseIncrease ?? this.exerciseIncrease,
    exerciseDecrease: exerciseDecrease ?? this.exerciseDecrease,
    neutral: neutral ?? this.neutral,
    workoutIncrease: workoutIncrease ?? this.workoutIncrease,
    workoutDecrease: workoutDecrease ?? this.workoutDecrease,
    healthIncrease: healthIncrease ?? this.healthIncrease,
    healthDecrease: healthDecrease ?? this.healthDecrease,
    healthCard: healthCard ?? this.healthCard,
    healthGrid: healthGrid ?? this.healthGrid,
  );

  @override
  AppProgressColors lerp(covariant AppProgressColors? other, double t) {
    if (other == null) return this;
    return AppProgressColors(
      accent: Color.lerp(accent, other.accent, t)!,
      estimated: Color.lerp(estimated, other.estimated, t)!,
      estimatedOneRm: Color.lerp(estimatedOneRm, other.estimatedOneRm, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
      label: Color.lerp(label, other.label, t)!,
      exerciseIncrease:
          Color.lerp(exerciseIncrease, other.exerciseIncrease, t)!,
      exerciseDecrease:
          Color.lerp(exerciseDecrease, other.exerciseDecrease, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      workoutIncrease: Color.lerp(workoutIncrease, other.workoutIncrease, t)!,
      workoutDecrease: Color.lerp(workoutDecrease, other.workoutDecrease, t)!,
      healthIncrease: Color.lerp(healthIncrease, other.healthIncrease, t)!,
      healthDecrease: Color.lerp(healthDecrease, other.healthDecrease, t)!,
      healthCard: Color.lerp(healthCard, other.healthCard, t)!,
      healthGrid: Color.lerp(healthGrid, other.healthGrid, t)!,
    );
  }
}
