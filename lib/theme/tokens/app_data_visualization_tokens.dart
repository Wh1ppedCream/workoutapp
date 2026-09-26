import 'package:flutter/material.dart';

/// Dedicated data-visualization roles. They are separate from UI state roles.
@immutable
class AppDataVisualizationTokens
    extends ThemeExtension<AppDataVisualizationTokens> {
  const AppDataVisualizationTokens({
    required this.heatmapLow,
    required this.heatmapHigh,
    required this.primarySeries,
    required this.secondarySeries,
    required this.sessionExercises,
    required this.sessionSets,
    required this.sessionDuration,
    required this.sessionVolume,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.grid,
    required this.label,
    required this.selection,
    required this.recordTodayContainer,
    required this.recordTodayBorder,
    required this.onRecordTodayContainer,
    required this.recordMonthly,
    required this.recordAllTime,
    required this.firstRecord,
    required this.tertiarySeries,
    required this.carbohydrateSeries,
    required this.proteinRing,
    required this.fatRing,
    required this.paginationActive,
    required this.paginationInactive,
  });

  factory AppDataVisualizationTokens.fromBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppDataVisualizationTokens(
      heatmapLow: isDark ? const Color(0xFFA1A1A1) : const Color(0xFF9E9E9E),
      heatmapHigh: const Color(0xFF1565C0),
      primarySeries: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6200EE),
      secondarySeries:
          isDark ? const Color(0xFF42A5F5) : const Color(0xFF1E88E5),
      sessionExercises: const Color(0xFF64B5F6),
      sessionSets: const Color(0xFF81C784),
      sessionDuration: const Color(0xFFFFD54F),
      sessionVolume: const Color(0xFFF48FB1),
      positive: isDark ? const Color(0xFF66BB6A) : const Color(0xFF43A047),
      negative: isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935),
      neutral: const Color(0xFF757575),
      grid:
          isDark
              ? const Color(0x66FFFFFF)
              : const Color.fromARGB(102, 43, 42, 42),
      label: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF757575),
      selection: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6200EE),
      recordTodayContainer:
          isDark ? const Color(0x2281C784) : const Color(0x33388E3C),
      recordTodayBorder:
          isDark ? const Color(0xFF81C784) : const Color(0xFF388E3C),
      onRecordTodayContainer:
          isDark ? const Color(0xFF81C784) : const Color(0xFF388E3C),
      recordMonthly: const Color(0xFF81C784),
      recordAllTime: const Color(0xFFFFC857),
      firstRecord: Colors.white,
      tertiarySeries: const Color(0xFF9C27B0),
      carbohydrateSeries:
          isDark ? const Color(0xFFFFA726) : const Color(0xFFFF8C00),
      proteinRing: isDark ? const Color(0xFFB53CCA) : const Color(0xFF9C27B0),
      fatRing: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF8C00),
      paginationActive: const Color(0xFF9C27B0),
      paginationInactive:
          isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
    );
  }

  final Color heatmapLow;
  final Color heatmapHigh;
  final Color primarySeries;
  final Color secondarySeries;
  final Color sessionExercises;
  final Color sessionSets;
  final Color sessionDuration;
  final Color sessionVolume;
  final Color positive;
  final Color negative;
  final Color neutral;
  final Color grid;
  final Color label;
  final Color selection;
  final Color recordTodayContainer;
  final Color recordTodayBorder;
  final Color onRecordTodayContainer;
  final Color recordMonthly;
  final Color recordAllTime;
  final Color firstRecord;
  final Color tertiarySeries;
  final Color carbohydrateSeries;
  final Color proteinRing;
  final Color fatRing;
  final Color paginationActive;
  final Color paginationInactive;

  @override
  AppDataVisualizationTokens copyWith({
    Color? heatmapLow,
    Color? heatmapHigh,
    Color? primarySeries,
    Color? secondarySeries,
    Color? sessionExercises,
    Color? sessionSets,
    Color? sessionDuration,
    Color? sessionVolume,
    Color? positive,
    Color? negative,
    Color? neutral,
    Color? grid,
    Color? label,
    Color? selection,
    Color? recordTodayContainer,
    Color? recordTodayBorder,
    Color? onRecordTodayContainer,
    Color? recordMonthly,
    Color? recordAllTime,
    Color? firstRecord,
    Color? tertiarySeries,
    Color? carbohydrateSeries,
    Color? proteinRing,
    Color? fatRing,
    Color? paginationActive,
    Color? paginationInactive,
  }) {
    return AppDataVisualizationTokens(
      heatmapLow: heatmapLow ?? this.heatmapLow,
      heatmapHigh: heatmapHigh ?? this.heatmapHigh,
      primarySeries: primarySeries ?? this.primarySeries,
      secondarySeries: secondarySeries ?? this.secondarySeries,
      sessionExercises: sessionExercises ?? this.sessionExercises,
      sessionSets: sessionSets ?? this.sessionSets,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      sessionVolume: sessionVolume ?? this.sessionVolume,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      neutral: neutral ?? this.neutral,
      grid: grid ?? this.grid,
      label: label ?? this.label,
      selection: selection ?? this.selection,
      recordTodayContainer: recordTodayContainer ?? this.recordTodayContainer,
      recordTodayBorder: recordTodayBorder ?? this.recordTodayBorder,
      onRecordTodayContainer:
          onRecordTodayContainer ?? this.onRecordTodayContainer,
      recordMonthly: recordMonthly ?? this.recordMonthly,
      recordAllTime: recordAllTime ?? this.recordAllTime,
      firstRecord: firstRecord ?? this.firstRecord,
      tertiarySeries: tertiarySeries ?? this.tertiarySeries,
      carbohydrateSeries: carbohydrateSeries ?? this.carbohydrateSeries,
      proteinRing: proteinRing ?? this.proteinRing,
      fatRing: fatRing ?? this.fatRing,
      paginationActive: paginationActive ?? this.paginationActive,
      paginationInactive: paginationInactive ?? this.paginationInactive,
    );
  }

  @override
  AppDataVisualizationTokens lerp(
    covariant ThemeExtension<AppDataVisualizationTokens>? other,
    double t,
  ) {
    if (other is! AppDataVisualizationTokens) {
      return this;
    }
    return AppDataVisualizationTokens(
      heatmapLow: Color.lerp(heatmapLow, other.heatmapLow, t)!,
      heatmapHigh: Color.lerp(heatmapHigh, other.heatmapHigh, t)!,
      primarySeries: Color.lerp(primarySeries, other.primarySeries, t)!,
      secondarySeries: Color.lerp(secondarySeries, other.secondarySeries, t)!,
      sessionExercises:
          Color.lerp(sessionExercises, other.sessionExercises, t)!,
      sessionSets: Color.lerp(sessionSets, other.sessionSets, t)!,
      sessionDuration: Color.lerp(sessionDuration, other.sessionDuration, t)!,
      sessionVolume: Color.lerp(sessionVolume, other.sessionVolume, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
      label: Color.lerp(label, other.label, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      recordTodayContainer:
          Color.lerp(recordTodayContainer, other.recordTodayContainer, t)!,
      recordTodayBorder:
          Color.lerp(recordTodayBorder, other.recordTodayBorder, t)!,
      onRecordTodayContainer:
          Color.lerp(onRecordTodayContainer, other.onRecordTodayContainer, t)!,
      recordMonthly: Color.lerp(recordMonthly, other.recordMonthly, t)!,
      recordAllTime: Color.lerp(recordAllTime, other.recordAllTime, t)!,
      firstRecord: Color.lerp(firstRecord, other.firstRecord, t)!,
      tertiarySeries: Color.lerp(tertiarySeries, other.tertiarySeries, t)!,
      carbohydrateSeries:
          Color.lerp(carbohydrateSeries, other.carbohydrateSeries, t)!,
      proteinRing: Color.lerp(proteinRing, other.proteinRing, t)!,
      fatRing: Color.lerp(fatRing, other.fatRing, t)!,
      paginationActive:
          Color.lerp(paginationActive, other.paginationActive, t)!,
      paginationInactive:
          Color.lerp(paginationInactive, other.paginationInactive, t)!,
    );
  }
}
