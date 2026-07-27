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

  final Color? metricAddBorderColor;
  final Color? metricAddIconColor;

  /// Accent color for GenericBar (border, text, splash)
  final Color? genericBarAccent;

  final Color? presetBadgeBg;
  final Color? presetBadgeText;

  /// Light “Pantry Log” segment background
  final Color? mealPlanPantryLogBg;

  /// Light “Add Meal” segment background
  final Color? mealPlanAddMealBg;

  /// Light “Plan Meal” segment background
  final Color? mealPlanPlanMealBg;

  /// Divider between segments
  final Color? mealPlanDivider;

  /// Border color for health-trends tiles and the “+” button
  final Color? healthTrendBorder;

  /// Icon color for the “+” button and chevrons in trend tiles
  final Color? healthTrendIcon;
  final Color? healthTrendLine;

  final Color? nutritionCalorieBar;
  final Color? nutritionProteinBar;
  final Color? nutritionCarbBar;
  final Color? nutritionFatBar;

  final Color? nutritionCalorieCircle;
  final Color? nutritionProteinCircle;
  final Color? nutritionCarbCircle;
  final Color? nutritionFatCircle;

  final Color? nutritionTextDetailsBorder;

  final Color? nutritionPageIndicatorActive;
  final Color? nutritionPageIndicatorInactive;

  /// Start Workout button background
  final Color? workoutStartBg;

  /// Start Workout button text/icon color
  final Color? workoutStartText;

  /// Background for “today” circle in DataRecordsSection
  final Color? dataRecordsTodayBg;

  /// Border for “today” circle
  final Color? dataRecordsTodayBorder;

  /// Text color for “today” day number
  final Color? dataRecordsTodayText;

  /// Default circle border (non-today)
  final Color? dataRecordsDefaultBorder;

  /// Chevron icon color in the summary row
  final Color? dataRecordsChevron;

  /// Color for the loading spinner in PastSessionsList
  final Color? pastSessionsProgress;

  /// Icon color for the fullscreen button
  final Color? pastSessionsIcon;

  /// Divider color between list items
  final Color? pastSessionsDivider;

  final Color? historySummaryProgress; // spinner
  final Color? historySummaryHeatmapLow; // body-heatmap “cold” color
  final Color? historySummaryHeatmapHigh; // body-heatmap “hot” color

  /// Background for all InfoCards
  final Color? infoCardBackground;

  /// Text color for the “value” line
  final Color? infoCardValueText;

  /// Text color for the “label” line
  final Color? infoCardLabelText;

  /// Shadow color behind InfoCards
  final Color? infoCardShadow;

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

    this.metricAddBorderColor,
    this.metricAddIconColor,

    this.genericBarAccent,

    this.presetBadgeBg,
    this.presetBadgeText,

    this.mealPlanPantryLogBg,
    this.mealPlanAddMealBg,
    this.mealPlanPlanMealBg,
    this.mealPlanDivider,

    this.healthTrendBorder,
    this.healthTrendIcon,
    this.healthTrendLine,

    this.nutritionCalorieBar,
    this.nutritionProteinBar,
    this.nutritionCarbBar,
    this.nutritionFatBar,

    this.nutritionCalorieCircle,
    this.nutritionProteinCircle,
    this.nutritionCarbCircle,
    this.nutritionFatCircle,

    this.nutritionTextDetailsBorder,

    this.nutritionPageIndicatorActive,
    this.nutritionPageIndicatorInactive,

    this.workoutStartBg,
    this.workoutStartText,

    this.dataRecordsTodayBg,
    this.dataRecordsTodayBorder,
    this.dataRecordsTodayText,
    this.dataRecordsDefaultBorder,
    this.dataRecordsChevron,

    this.pastSessionsProgress,
    this.pastSessionsIcon,
    this.pastSessionsDivider,

    this.historySummaryProgress,
    this.historySummaryHeatmapLow,
    this.historySummaryHeatmapHigh,

    this.infoCardBackground,
    this.infoCardValueText,
    this.infoCardLabelText,
    this.infoCardShadow,

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

    Color? metricAddBorderColor,
    Color? metricAddIconColor,

    Color? genericBarAccent,

    Color? presetBadgeBg,
    Color? presetBadgeText,

    Color? mealPlanPantryLogBg,
    Color? mealPlanAddMealBg,
    Color? mealPlanPlanMealBg,
    Color? mealPlanDivider,

    Color? healthTrendBorder,
    Color? healthTrendIcon,
    Color? healthTrendLine,

    Color? nutritionCalorieBar,
    Color? nutritionProteinBar,
    Color? nutritionCarbBar,
    Color? nutritionFatBar,

    Color? nutritionCalorieCircle,
    Color? nutritionProteinCircle,
    Color? nutritionCarbCircle,
    Color? nutritionFatCircle,

    Color? nutritionTextDetailsBorder,

    Color? nutritionPageIndicatorActive,
    Color? nutritionPageIndicatorInactive,

    Color? workoutStartBg,
    Color? workoutStartText,

    Color? dataRecordsTodayBg,
    Color? dataRecordsTodayBorder,
    Color? dataRecordsTodayText,
    Color? dataRecordsDefaultBorder,
    Color? dataRecordsChevron,

    Color? pastSessionsProgress,
    Color? pastSessionsIcon,
    Color? pastSessionsDivider,

    Color? historySummaryProgress,
    Color? historySummaryHeatmapLow,
    Color? historySummaryHeatmapHigh,

    Color? infoCardBackground,
    Color? infoCardValueText,
    Color? infoCardLabelText,
    Color? infoCardShadow,

    // …
  }) {
    return AppColors(
      quickBarMeasurementBg:
          quickBarMeasurementBg ?? this.quickBarMeasurementBg,
      quickBarMeasurementText:
          quickBarMeasurementText ?? this.quickBarMeasurementText,
      quickBarFoodBg: quickBarFoodBg ?? this.quickBarFoodBg,
      quickBarFoodText: quickBarFoodText ?? this.quickBarFoodText,
      quickBarWorkoutBg: quickBarWorkoutBg ?? this.quickBarWorkoutBg,
      quickBarWorkoutText: quickBarWorkoutText ?? this.quickBarWorkoutText,

      addExerciseFabBg: addExerciseFabBg ?? this.addExerciseFabBg,
      addExerciseFabIcon: addExerciseFabIcon ?? this.addExerciseFabIcon,
      dialogBackground: dialogBackground ?? this.dialogBackground,

      sheetBackground: sheetBackground ?? this.sheetBackground,

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

      metricAddBorderColor: metricAddBorderColor ?? this.metricAddBorderColor,
      metricAddIconColor: metricAddIconColor ?? this.metricAddIconColor,

      genericBarAccent: genericBarAccent ?? this.genericBarAccent,

      presetBadgeBg: presetBadgeBg ?? this.presetBadgeBg,
      presetBadgeText: presetBadgeText ?? this.presetBadgeText,

      mealPlanPantryLogBg: mealPlanPantryLogBg ?? this.mealPlanPantryLogBg,
      mealPlanAddMealBg: mealPlanAddMealBg ?? this.mealPlanAddMealBg,
      mealPlanPlanMealBg: mealPlanPlanMealBg ?? this.mealPlanPlanMealBg,
      mealPlanDivider: mealPlanDivider ?? this.mealPlanDivider,

      healthTrendBorder: healthTrendBorder ?? this.healthTrendBorder,
      healthTrendIcon: healthTrendIcon ?? this.healthTrendIcon,
      healthTrendLine: healthTrendLine ?? this.healthTrendLine,

      nutritionCalorieBar: nutritionCalorieBar ?? this.nutritionCalorieBar,
      nutritionProteinBar: nutritionProteinBar ?? this.nutritionProteinBar,
      nutritionCarbBar: nutritionCarbBar ?? this.nutritionCarbBar,
      nutritionFatBar: nutritionFatBar ?? this.nutritionFatBar,

      nutritionCalorieCircle:
          nutritionCalorieCircle ?? this.nutritionCalorieCircle,
      nutritionProteinCircle:
          nutritionProteinCircle ?? this.nutritionProteinCircle,
      nutritionCarbCircle: nutritionCarbCircle ?? this.nutritionCarbCircle,
      nutritionFatCircle: nutritionFatCircle ?? this.nutritionFatCircle,

      nutritionTextDetailsBorder:
          nutritionTextDetailsBorder ?? this.nutritionTextDetailsBorder,

      nutritionPageIndicatorActive:
          nutritionPageIndicatorActive ?? this.nutritionPageIndicatorActive,
      nutritionPageIndicatorInactive:
          nutritionPageIndicatorInactive ?? this.nutritionPageIndicatorInactive,

      workoutStartBg: workoutStartBg ?? this.workoutStartBg,
      workoutStartText: workoutStartText ?? this.workoutStartText,

      dataRecordsTodayBg: dataRecordsTodayBg ?? this.dataRecordsTodayBg,
      dataRecordsTodayBorder:
          dataRecordsTodayBorder ?? this.dataRecordsTodayBorder,
      dataRecordsTodayText: dataRecordsTodayText ?? this.dataRecordsTodayText,
      dataRecordsDefaultBorder:
          dataRecordsDefaultBorder ?? this.dataRecordsDefaultBorder,
      dataRecordsChevron: dataRecordsChevron ?? this.dataRecordsChevron,

      pastSessionsProgress: pastSessionsProgress ?? this.pastSessionsProgress,
      pastSessionsIcon: pastSessionsIcon ?? this.pastSessionsIcon,
      pastSessionsDivider: pastSessionsDivider ?? this.pastSessionsDivider,

      historySummaryProgress:
          historySummaryProgress ?? this.historySummaryProgress,
      historySummaryHeatmapLow:
          historySummaryHeatmapLow ?? this.historySummaryHeatmapLow,
      historySummaryHeatmapHigh:
          historySummaryHeatmapHigh ?? this.historySummaryHeatmapHigh,

      infoCardBackground: infoCardBackground ?? this.infoCardBackground,
      infoCardValueText: infoCardValueText ?? this.infoCardValueText,
      infoCardLabelText: infoCardLabelText ?? this.infoCardLabelText,
      infoCardShadow: infoCardShadow ?? this.infoCardShadow,

      // …
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      quickBarMeasurementBg: Color.lerp(
        quickBarMeasurementBg,
        other.quickBarMeasurementBg,
        t,
      ),
      quickBarMeasurementText: Color.lerp(
        quickBarMeasurementText,
        other.quickBarMeasurementText,
        t,
      ),
      quickBarFoodBg: Color.lerp(quickBarFoodBg, other.quickBarFoodBg, t),
      quickBarFoodText: Color.lerp(quickBarFoodText, other.quickBarFoodText, t),
      quickBarWorkoutBg: Color.lerp(
        quickBarWorkoutBg,
        other.quickBarWorkoutBg,
        t,
      ),
      quickBarWorkoutText: Color.lerp(
        quickBarWorkoutText,
        other.quickBarWorkoutText,
        t,
      ),

      addExerciseFabBg: Color.lerp(addExerciseFabBg, other.addExerciseFabBg, t),
      addExerciseFabIcon: Color.lerp(
        addExerciseFabIcon,
        other.addExerciseFabIcon,
        t,
      ),
      dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t),

      sheetBackground: Color.lerp(sheetBackground, other.sheetBackground, t),

      buttonBg: Color.lerp(buttonBg, other.buttonBg, t),
      buttonText: Color.lerp(buttonText, other.buttonText, t),

      flowChartBackground: Color.lerp(
        flowChartBackground,
        other.flowChartBackground,
        t,
      ),
      flowChartGrid: Color.lerp(flowChartGrid, other.flowChartGrid, t),

      flowNodeBg: Color.lerp(flowNodeBg, other.flowNodeBg, t),
      flowNodeBorder: Color.lerp(flowNodeBorder, other.flowNodeBorder, t),
      flowNodeText: Color.lerp(flowNodeText, other.flowNodeText, t),
      flowArrowSuccess: Color.lerp(flowArrowSuccess, other.flowArrowSuccess, t),
      flowArrowFailure: Color.lerp(flowArrowFailure, other.flowArrowFailure, t),
      flowArrowLoopback: Color.lerp(
        flowArrowLoopback,
        other.flowArrowLoopback,
        t,
      ),

      metricAddBorderColor: Color.lerp(
        metricAddBorderColor,
        other.metricAddBorderColor,
        t,
      ),
      metricAddIconColor: Color.lerp(
        metricAddIconColor,
        other.metricAddIconColor,
        t,
      ),

      genericBarAccent: Color.lerp(genericBarAccent, other.genericBarAccent, t),

      presetBadgeBg: Color.lerp(presetBadgeBg, other.presetBadgeBg, t),
      presetBadgeText: Color.lerp(presetBadgeText, other.presetBadgeText, t),

      mealPlanPantryLogBg: Color.lerp(
        mealPlanPantryLogBg,
        other.mealPlanPantryLogBg,
        t,
      ),
      mealPlanAddMealBg: Color.lerp(
        mealPlanAddMealBg,
        other.mealPlanAddMealBg,
        t,
      ),
      mealPlanPlanMealBg: Color.lerp(
        mealPlanPlanMealBg,
        other.mealPlanPlanMealBg,
        t,
      ),
      mealPlanDivider: Color.lerp(mealPlanDivider, other.mealPlanDivider, t),

      healthTrendBorder: Color.lerp(
        healthTrendBorder,
        other.healthTrendBorder,
        t,
      ),
      healthTrendIcon: Color.lerp(healthTrendIcon, other.healthTrendIcon, t),
      healthTrendLine: Color.lerp(healthTrendLine, other.healthTrendLine, t),

      nutritionCalorieBar: Color.lerp(
        nutritionCalorieBar,
        other.nutritionCalorieBar,
        t,
      ),
      nutritionProteinBar: Color.lerp(
        nutritionProteinBar,
        other.nutritionProteinBar,
        t,
      ),
      nutritionCarbBar: Color.lerp(nutritionCarbBar, other.nutritionCarbBar, t),
      nutritionFatBar: Color.lerp(nutritionFatBar, other.nutritionFatBar, t),

      nutritionCalorieCircle: Color.lerp(
        nutritionCalorieCircle,
        other.nutritionCalorieCircle,
        t,
      ),
      nutritionProteinCircle: Color.lerp(
        nutritionProteinCircle,
        other.nutritionProteinCircle,
        t,
      ),
      nutritionCarbCircle: Color.lerp(
        nutritionCarbCircle,
        other.nutritionCarbCircle,
        t,
      ),
      nutritionFatCircle: Color.lerp(
        nutritionFatCircle,
        other.nutritionFatCircle,
        t,
      ),

      nutritionTextDetailsBorder: Color.lerp(
        nutritionTextDetailsBorder,
        other.nutritionTextDetailsBorder,
        t,
      ),

      nutritionPageIndicatorActive: Color.lerp(
        nutritionPageIndicatorActive,
        other.nutritionPageIndicatorActive,
        t,
      ),
      nutritionPageIndicatorInactive: Color.lerp(
        nutritionPageIndicatorInactive,
        other.nutritionPageIndicatorInactive,
        t,
      ),

      workoutStartBg: Color.lerp(workoutStartBg, other.workoutStartBg, t),
      workoutStartText: Color.lerp(workoutStartText, other.workoutStartText, t),

      dataRecordsTodayBg: Color.lerp(
        dataRecordsTodayBg,
        other.dataRecordsTodayBg,
        t,
      ),
      dataRecordsTodayBorder: Color.lerp(
        dataRecordsTodayBorder,
        other.dataRecordsTodayBorder,
        t,
      ),
      dataRecordsTodayText: Color.lerp(
        dataRecordsTodayText,
        other.dataRecordsTodayText,
        t,
      ),
      dataRecordsDefaultBorder: Color.lerp(
        dataRecordsDefaultBorder,
        other.dataRecordsDefaultBorder,
        t,
      ),
      dataRecordsChevron: Color.lerp(
        dataRecordsChevron,
        other.dataRecordsChevron,
        t,
      ),

      pastSessionsProgress: Color.lerp(
        pastSessionsProgress,
        other.pastSessionsProgress,
        t,
      ),
      pastSessionsIcon: Color.lerp(pastSessionsIcon, other.pastSessionsIcon, t),
      pastSessionsDivider: Color.lerp(
        pastSessionsDivider,
        other.pastSessionsDivider,
        t,
      ),

      historySummaryProgress: Color.lerp(
        historySummaryProgress,
        other.historySummaryProgress,
        t,
      ),
      historySummaryHeatmapLow: Color.lerp(
        historySummaryHeatmapLow,
        other.historySummaryHeatmapLow,
        t,
      ),
      historySummaryHeatmapHigh: Color.lerp(
        historySummaryHeatmapHigh,
        other.historySummaryHeatmapHigh,
        t,
      ),

      infoCardBackground: Color.lerp(
        infoCardBackground,
        other.infoCardBackground,
        t,
      ),
      infoCardValueText: Color.lerp(
        infoCardValueText,
        other.infoCardValueText,
        t,
      ),
      infoCardLabelText: Color.lerp(
        infoCardLabelText,
        other.infoCardLabelText,
        t,
      ),
      infoCardShadow: Color.lerp(infoCardShadow, other.infoCardShadow, t),

      // …
    );
  }
}
