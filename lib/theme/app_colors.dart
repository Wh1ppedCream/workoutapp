// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color? quickBarMeasurementBg;
  final Color? quickBarMeasurementText;
  final Color? quickBarFoodBg;
  final Color? quickBarFoodText;
  final Color? quickBarWorkoutBg;
  final Color? quickBarWorkoutText;
  // …add more fields for anything you might override…
  final Color? addExerciseFabBg;
final Color? addExerciseFabIcon;
final Color? dialogBackground;

final Color? sheetBackground;

final Color? buttonBg;
final Color? buttonText;


  const AppColors({
    this.quickBarMeasurementBg,
    this.quickBarMeasurementText,
    this.quickBarFoodBg,
    this.quickBarFoodText,  
    this.quickBarWorkoutBg,
    this.quickBarWorkoutText,

    this.addExerciseFabBg,
    this.addExerciseFabIcon,
    this.dialogBackground,

    this.sheetBackground,

    this.buttonBg,
    this.buttonText,
    // …
  });

  @override
  AppColors copyWith({
    Color? quickBarMeasurementBg,
    Color? quickBarMeasurementText,
    Color? quickBarFoodBg,
    Color? quickBarFoodText,
    Color? quickBarWorkoutBg,
    Color? quickBarWorkoutText,

    Color? addExerciseFabBg,
    Color? addExerciseFabIcon,
    Color? dialogBackground,

    Color? sheetBackground,

    Color? buttonBg,
    Color? buttonText,
    // …
  }) {
    return AppColors(
      quickBarMeasurementBg:
          quickBarMeasurementBg ?? this.quickBarMeasurementBg,
      quickBarMeasurementText:
          quickBarMeasurementText ?? this.quickBarMeasurementText,
      quickBarFoodBg: 
          quickBarFoodBg ?? this.quickBarFoodBg,
      quickBarFoodText:
          quickBarFoodText ?? this.quickBarFoodText,  
      quickBarWorkoutBg: 
          quickBarWorkoutBg ?? this.quickBarWorkoutBg,
      quickBarWorkoutText:
          quickBarWorkoutText ?? this.quickBarWorkoutText,


      addExerciseFabBg:
          addExerciseFabBg ?? this.addExerciseFabBg,
      addExerciseFabIcon:
          addExerciseFabIcon ?? this.addExerciseFabIcon,
      dialogBackground:
          dialogBackground ?? this.dialogBackground,

      sheetBackground:
          sheetBackground ?? this.sheetBackground,


      buttonBg: buttonBg ?? this.buttonBg,
      buttonText: buttonText ?? this.buttonText,
      
      // …
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      quickBarMeasurementBg: Color.lerp(
          quickBarMeasurementBg, other.quickBarMeasurementBg, t),
      quickBarMeasurementText: Color.lerp(
          quickBarMeasurementText, other.quickBarMeasurementText, t),
      quickBarFoodBg: Color.lerp(quickBarFoodBg, other.quickBarFoodBg, t),
      quickBarFoodText: Color.lerp(quickBarFoodText, other.quickBarFoodText, t),
      quickBarWorkoutBg: Color.lerp(
          quickBarWorkoutBg, other.quickBarWorkoutBg, t),
      quickBarWorkoutText: Color.lerp(
          quickBarWorkoutText, other.quickBarWorkoutText, t),


      addExerciseFabBg: Color.lerp(addExerciseFabBg, other.addExerciseFabBg, t),
      addExerciseFabIcon: Color.lerp(addExerciseFabIcon, other.addExerciseFabIcon, t),
      dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t),

      sheetBackground: Color.lerp(sheetBackground, other.sheetBackground, t),


      buttonBg: Color.lerp(buttonBg, other.buttonBg, t),
      buttonText: Color.lerp(buttonText, other.buttonText, t),
      // …
    );
  }
}
