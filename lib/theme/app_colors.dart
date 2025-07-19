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
  
  final Color? addExerciseFabBg;
final Color? addExerciseFabIcon;
final Color? dialogBackground;

final Color? sheetBackground;

final Color? buttonBg;
final Color? buttonText;

//flowchart 
final Color? flowChartBackground;
  final Color? flowChartGrid;

  /// Default background for every chart node
  final Color? flowNodeBg;
  /// Default border for every chart node
  final Color? flowNodeBorder;
  /// Default text color for every chart node
  final Color? flowNodeText;

  /// Default arrow color on “success” branches
  final Color? flowArrowSuccess;
  /// Default arrow color on “failure” branches
  final Color? flowArrowFailure;
  /// Default arrow color on loopbacks
  final Color? flowArrowLoopback;


// …add more fields for anything you might override…

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

    this.flowChartBackground,
    this.flowChartGrid,

    this.flowNodeBg,
    this.flowNodeBorder,  
    this.flowNodeText,
    this.flowArrowSuccess,
    this.flowArrowFailure,
    this.flowArrowLoopback,

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

    Color? flowChartBackground,
    Color? flowChartGrid,

    Color? flowNodeBg,
    Color? flowNodeBorder,
    Color? flowNodeText,
    Color? flowArrowSuccess,
    Color? flowArrowFailure,
    Color? flowArrowLoopback,

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

      flowChartBackground: flowChartBackground ?? this.flowChartBackground,
      flowChartGrid: flowChartGrid ?? this.flowChartGrid,

      flowNodeBg: flowNodeBg ?? this.flowNodeBg,
      flowNodeBorder: flowNodeBorder ?? this.flowNodeBorder,
      flowNodeText: flowNodeText ?? this.flowNodeText,
      flowArrowSuccess: flowArrowSuccess ?? this.flowArrowSuccess,
      flowArrowFailure: flowArrowFailure ?? this.flowArrowFailure,
      flowArrowLoopback: flowArrowLoopback ?? this.flowArrowLoopback,

      
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

      flowChartBackground: Color.lerp(flowChartBackground, other.flowChartBackground, t),
      flowChartGrid: Color.lerp(flowChartGrid, other.flowChartGrid, t),

      flowNodeBg: Color.lerp(flowNodeBg, other.flowNodeBg, t),
      flowNodeBorder: Color.lerp(flowNodeBorder, other.flowNodeBorder, t),
      flowNodeText: Color.lerp(flowNodeText, other.flowNodeText, t),
      flowArrowSuccess: Color.lerp(flowArrowSuccess, other.flowArrowSuccess, t),
      flowArrowFailure: Color.lerp(flowArrowFailure, other.flowArrowFailure, t),
      flowArrowLoopback: Color.lerp(flowArrowLoopback, other.flowArrowLoopback, t), 
      
      // …
    );
  }
}
