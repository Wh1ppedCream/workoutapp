import 'package:flutter/material.dart';

/// Tonos-specific surface recipes. Standard Material surfaces stay in
/// ColorScheme; these roles describe how the app composes them.
@immutable
class AppSurfaceTokens extends ThemeExtension<AppSurfaceTokens> {
  const AppSurfaceTokens({
    this.workoutDiscardBorder = 0.7,
    this.swapMatchFill = 30 / 255,
    this.swapMatchBorder = 110 / 255,
    this.swapFilterBorder = 0.55,
    this.swapSecondaryTextOpacity = 184 / 255,
    this.trainTabSurfaceOpacity = 0.75,
    this.splitWorkoutDividerOpacity = 0.18,
    this.planRevealBorderOpacity = 0.45,
    this.planSwapBadgeOpacity = 0.55,
    this.flowErrorBorderOpacity = 0.6,
    this.flowControlBorderOpacity = 0.46,
    this.flowControlCollapsedOpacity = 0.05,
    this.flowControlExpandedOpacity = 0.04,
    this.flowControlIconOpacity = 0.16,
    this.firstRecordFill = 0.12,
    this.firstRecordBorder = 0.72,
    this.recordBadgeFill = 0.14,
    this.recordBadgeBorder = 0.62,
    this.workoutCardCompleteFill = 24 / 255,
    this.workoutSetCompleteFill = 76 / 255,
    this.workoutChangeSetOutline = Colors.grey,
    this.exerciseDetailCardBorderOpacity = 0.32,
    this.exerciseDetailHandleOpacity = 0.55,
    this.exerciseDetailIconFillOpacity = 0.16,
    this.exerciseDetailTagFillOpacity = 0.13,
    this.exerciseDetailTagBorderOpacity = 0.28,
    this.exerciseDetailTimeframeBorderOpacity = 0.6,
    this.exerciseDetailMetricFillOpacity = 0.12,
    this.exerciseDetailMetricBorderOpacity = 0.38,
    this.exerciseDetailRangeFillOpacity = 0.12,
    this.exerciseDetailRecordBorderOpacity = 0.36,
    this.exerciseDetailRecordIconFillOpacity = 0.15,
    this.exerciseDetailRecordActionFillOpacity = 0.13,
    this.exerciseDetailRecordSetFillOpacity = 0.18,
    this.exerciseDetailLoadMoreBorderOpacity = 0.55,
    this.exerciseDetailMetricListBorderOpacity = 0.65,
    this.exerciseDetailMetricRepFillOpacity = 0.15,
    this.exerciseDetailMetricListDividerOpacity = 0.58,
    this.exerciseDetailStateBorderOpacity = 0.65,
    this.exerciseDetailChartBorderOpacity = 0.6,
    this.exerciseDetailChartGridOpacity = 0.42,
    this.exerciseDetailChartAreaOpacity = 0.08,
    required this.workoutHandle,
    this.completionMetricFill = 0.15,
    this.completionMetricBorder = 0.3,
    this.completionSetFill = 0.2,
    this.completionExerciseFill = 0.1,
    this.completionExerciseBorder = 0.52,
    required this.sessionSummary,
    required this.panel,
    required this.panelRaised,
    required this.card,
    required this.planCard,
    required this.presetFocus,
    required this.flowControl,
    required this.planFilter,
    required this.planDuration,
    required this.planGroup,
    required this.metricChip,
    required this.planActionBar,
    required this.optimizedAction,
    required this.subtleOutline,
    required this.input,
    required this.sheet,
    required this.dialog,
    required this.media,
    required this.mediaFrame,
    required this.mediaPlaceholder,
    required this.mediaOutline,
    required this.catalogSelection,
    required this.catalogUsage,
    required this.catalogOutline,
    required this.exerciseDetailCard,
    required this.exerciseDetailTimeframe,
    required this.exerciseDetailRecord,
    required this.exerciseDetailMetricList,
    required this.exerciseDetailState,
    required this.exerciseDetailChart,
    required this.exerciseDetailChartEmpty,
    required this.exerciseDetailTooltip,
    required this.divider,
    required this.settingsHero,
    required this.settingsSection,
    required this.settingsInput,
    required this.settingsSaveBar,
    required this.dialogChoice,
    required this.exerciseProgressHero,
    required this.exerciseProgressStat,
    required this.exerciseProgressSelector,
    required this.exerciseProgressTooltip,
    required this.workoutMetricStat,
    required this.workoutMetricChart,
    required this.workoutMetricTooltip,
    required this.workoutMetricRange,
    required this.workoutMetricDetails,
    required this.workoutMetricInsight,
    required this.dashboardHero,
    required this.dashboardSection,
    required this.dashboardEditor,
    required this.dashboardUsage,
    required this.historyPeriodSelector,
    required this.calendarModeSelector,
    required this.calendarDayEmpty,
    required this.historySelectedPeriod,
    required this.historyDivider,
  });

  /// Builds a complete surface fallback from the active Material scheme.
  factory AppSurfaceTokens.fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return AppSurfaceTokens(
      panel: scheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.34 : 0.54,
      ),
      panelRaised: scheme.surfaceContainerHighest,
      workoutHandle: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      sessionSummary: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      card: isDark ? const Color(0xFF222222) : Colors.white,
      planCard: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
      presetFocus: scheme.surface.withValues(alpha: 0.35),
      flowControl: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
      planFilter: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
      planDuration: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      planGroup: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      metricChip: scheme.surfaceContainerHighest,
      planActionBar: scheme.surface.withValues(alpha: 0.96),
      optimizedAction: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
      subtleOutline: scheme.outlineVariant,
      input: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
      sheet: isDark ? const Color(0xFF303030) : Colors.white,
      dialog: isDark ? const Color(0xFF202020) : Colors.white,
      media: scheme.surface,
      mediaFrame: scheme.surfaceContainerHigh,
      mediaPlaceholder: scheme.surfaceContainerHighest,
      mediaOutline: scheme.outlineVariant,
      catalogSelection: scheme.primaryContainer.withValues(alpha: 0.45),
      catalogUsage: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      catalogOutline: scheme.outlineVariant,
      exerciseDetailCard: scheme.surfaceContainerHighest.withValues(
        alpha: 0.52,
      ),
      exerciseDetailTimeframe: scheme.surfaceContainerHighest.withValues(
        alpha: 0.58,
      ),
      exerciseDetailRecord: scheme.surfaceContainerHighest.withValues(
        alpha: 0.42,
      ),
      exerciseDetailMetricList: scheme.surfaceContainerHighest.withValues(
        alpha: 0.44,
      ),
      exerciseDetailState: scheme.surfaceContainerHighest.withValues(
        alpha: 0.44,
      ),
      exerciseDetailChart: scheme.surfaceContainerHighest.withValues(
        alpha: 0.26,
      ),
      exerciseDetailChartEmpty: scheme.surfaceContainerHighest.withValues(
        alpha: 0.28,
      ),
      exerciseDetailTooltip: scheme.surfaceContainerHighest.withValues(
        alpha: 0.96,
      ),
      divider: scheme.outlineVariant.withValues(alpha: 0.55),
      settingsHero: scheme.surfaceContainerHighest.withValues(alpha: 0.54),
      settingsSection: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
      settingsInput: scheme.surface.withValues(alpha: 0.44),
      settingsSaveBar: scheme.surface.withValues(alpha: 0.96),
      dialogChoice: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      exerciseProgressHero: scheme.surfaceContainerHighest.withValues(
        alpha: 0.36,
      ),
      exerciseProgressStat: scheme.surface.withValues(alpha: 0.72),
      exerciseProgressSelector: scheme.surface.withValues(alpha: 0.72),
      exerciseProgressTooltip: scheme.surfaceContainerHighest,
      workoutMetricStat: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      workoutMetricChart: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      workoutMetricTooltip: scheme.surfaceContainerHighest,
      workoutMetricRange: scheme.surfaceContainerHighest.withValues(
        alpha: 0.55,
      ),
      workoutMetricDetails: scheme.surfaceContainerHighest.withValues(
        alpha: 0.38,
      ),
      workoutMetricInsight: scheme.surfaceContainerHighest.withValues(
        alpha: 0.42,
      ),
      dashboardHero: scheme.surfaceContainerHighest.withValues(alpha: 0.54),
      dashboardSection: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
      dashboardEditor: scheme.surfaceContainerHighest.withValues(alpha: 0.46),
      dashboardUsage: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      historyPeriodSelector: scheme.surfaceContainerHighest,
      calendarModeSelector: scheme.surfaceContainerHighest.withValues(
        alpha: 0.35,
      ),
      calendarDayEmpty: scheme.surfaceContainerHighest,
      historySelectedPeriod: scheme.surfaceContainerHighest.withValues(
        alpha: 0.45,
      ),
      historyDivider: scheme.outlineVariant.withValues(alpha: 0.22),
    );
  }

  final Color panel;
  final double workoutDiscardBorder;
  final double swapMatchFill;
  final double swapMatchBorder;
  final double swapFilterBorder;
  final double swapSecondaryTextOpacity;
  final double trainTabSurfaceOpacity;
  final double splitWorkoutDividerOpacity;
  final double planRevealBorderOpacity;
  final double planSwapBadgeOpacity;
  final double flowErrorBorderOpacity;
  final double flowControlBorderOpacity;
  final double flowControlCollapsedOpacity;
  final double flowControlExpandedOpacity;
  final double flowControlIconOpacity;
  final Color presetFocus;
  final double firstRecordFill;
  final double firstRecordBorder;
  final double recordBadgeFill;
  final double recordBadgeBorder;
  final double workoutCardCompleteFill;
  final double workoutSetCompleteFill;
  final Color workoutChangeSetOutline;
  final double exerciseDetailCardBorderOpacity;
  final double exerciseDetailHandleOpacity;
  final double exerciseDetailIconFillOpacity;
  final double exerciseDetailTagFillOpacity;
  final double exerciseDetailTagBorderOpacity;
  final double exerciseDetailTimeframeBorderOpacity;
  final double exerciseDetailMetricFillOpacity;
  final double exerciseDetailMetricBorderOpacity;
  final double exerciseDetailRangeFillOpacity;
  final double exerciseDetailRecordBorderOpacity;
  final double exerciseDetailRecordIconFillOpacity;
  final double exerciseDetailRecordActionFillOpacity;
  final double exerciseDetailRecordSetFillOpacity;
  final double exerciseDetailLoadMoreBorderOpacity;
  final double exerciseDetailMetricListBorderOpacity;
  final double exerciseDetailMetricRepFillOpacity;
  final double exerciseDetailMetricListDividerOpacity;
  final double exerciseDetailStateBorderOpacity;
  final double exerciseDetailChartBorderOpacity;
  final double exerciseDetailChartGridOpacity;
  final double exerciseDetailChartAreaOpacity;
  final Color workoutHandle;
  final Color sessionSummary;
  final double completionMetricFill;
  final double completionMetricBorder;
  final double completionSetFill;
  final double completionExerciseFill;
  final double completionExerciseBorder;
  final Color panelRaised;
  final Color card;
  final Color planCard;
  final Color flowControl;
  final Color planFilter;
  final Color planDuration;
  final Color planGroup;
  final Color metricChip;
  final Color planActionBar;
  final Color optimizedAction;
  final Color subtleOutline;
  final Color input;
  final Color sheet;
  final Color dialog;
  final Color media;
  final Color mediaFrame;
  final Color mediaPlaceholder;
  final Color mediaOutline;
  final Color catalogSelection;
  final Color catalogUsage;
  final Color catalogOutline;
  final Color exerciseDetailCard;
  final Color exerciseDetailTimeframe;
  final Color exerciseDetailRecord;
  final Color exerciseDetailMetricList;
  final Color exerciseDetailState;
  final Color exerciseDetailChart;
  final Color exerciseDetailChartEmpty;
  final Color exerciseDetailTooltip;
  final Color divider;
  final Color settingsHero;
  final Color settingsSection;
  final Color settingsInput;
  final Color settingsSaveBar;
  final Color dialogChoice;
  final Color exerciseProgressHero;
  final Color exerciseProgressStat;
  final Color exerciseProgressSelector;
  final Color exerciseProgressTooltip;
  final Color workoutMetricStat;
  final Color workoutMetricChart;
  final Color workoutMetricTooltip;
  final Color workoutMetricRange;
  final Color workoutMetricDetails;
  final Color workoutMetricInsight;
  final Color dashboardHero;
  final Color dashboardSection;
  final Color dashboardEditor;
  final Color dashboardUsage;
  final Color historyPeriodSelector;
  final Color calendarModeSelector;
  final Color calendarDayEmpty;
  final Color historySelectedPeriod;
  final Color historyDivider;

  @override
  AppSurfaceTokens copyWith({
    double? workoutDiscardBorder,
    double? swapMatchFill,
    double? swapMatchBorder,
    double? swapFilterBorder,
    double? swapSecondaryTextOpacity,
    double? trainTabSurfaceOpacity,
    double? splitWorkoutDividerOpacity,
    double? planRevealBorderOpacity,
    double? planSwapBadgeOpacity,
    double? flowErrorBorderOpacity,
    double? flowControlBorderOpacity,
    double? flowControlCollapsedOpacity,
    double? flowControlExpandedOpacity,
    double? flowControlIconOpacity,
    double? firstRecordFill,
    double? firstRecordBorder,
    double? recordBadgeFill,
    double? recordBadgeBorder,
    double? workoutCardCompleteFill,
    double? workoutSetCompleteFill,
    Color? workoutChangeSetOutline,
    double? exerciseDetailCardBorderOpacity,
    double? exerciseDetailHandleOpacity,
    double? exerciseDetailIconFillOpacity,
    double? exerciseDetailTagFillOpacity,
    double? exerciseDetailTagBorderOpacity,
    double? exerciseDetailTimeframeBorderOpacity,
    double? exerciseDetailMetricFillOpacity,
    double? exerciseDetailMetricBorderOpacity,
    double? exerciseDetailRangeFillOpacity,
    double? exerciseDetailRecordBorderOpacity,
    double? exerciseDetailRecordIconFillOpacity,
    double? exerciseDetailRecordActionFillOpacity,
    double? exerciseDetailRecordSetFillOpacity,
    double? exerciseDetailLoadMoreBorderOpacity,
    double? exerciseDetailMetricListBorderOpacity,
    double? exerciseDetailMetricRepFillOpacity,
    double? exerciseDetailMetricListDividerOpacity,
    double? exerciseDetailStateBorderOpacity,
    double? exerciseDetailChartBorderOpacity,
    double? exerciseDetailChartGridOpacity,
    double? exerciseDetailChartAreaOpacity,
    Color? workoutHandle,
    Color? sessionSummary,
    double? completionMetricFill,
    double? completionMetricBorder,
    double? completionSetFill,
    double? completionExerciseFill,
    double? completionExerciseBorder,
    Color? panel,
    Color? panelRaised,
    Color? card,
    Color? planCard,
    Color? presetFocus,
    Color? flowControl,
    Color? planFilter,
    Color? planDuration,
    Color? planGroup,
    Color? metricChip,
    Color? planActionBar,
    Color? optimizedAction,
    Color? subtleOutline,
    Color? input,
    Color? sheet,
    Color? dialog,
    Color? media,
    Color? mediaFrame,
    Color? mediaPlaceholder,
    Color? mediaOutline,
    Color? catalogSelection,
    Color? catalogUsage,
    Color? catalogOutline,
    Color? exerciseDetailCard,
    Color? exerciseDetailTimeframe,
    Color? exerciseDetailRecord,
    Color? exerciseDetailMetricList,
    Color? exerciseDetailState,
    Color? exerciseDetailChart,
    Color? exerciseDetailChartEmpty,
    Color? exerciseDetailTooltip,
    Color? divider,
    Color? settingsHero,
    Color? settingsSection,
    Color? settingsInput,
    Color? settingsSaveBar,
    Color? dialogChoice,
    Color? exerciseProgressHero,
    Color? exerciseProgressStat,
    Color? exerciseProgressSelector,
    Color? exerciseProgressTooltip,
    Color? workoutMetricStat,
    Color? workoutMetricChart,
    Color? workoutMetricTooltip,
    Color? workoutMetricRange,
    Color? workoutMetricDetails,
    Color? workoutMetricInsight,
    Color? dashboardHero,
    Color? dashboardSection,
    Color? dashboardEditor,
    Color? dashboardUsage,
    Color? historyPeriodSelector,
    Color? calendarModeSelector,
    Color? calendarDayEmpty,
    Color? historySelectedPeriod,
    Color? historyDivider,
  }) {
    return AppSurfaceTokens(
      panel: panel ?? this.panel,
      workoutDiscardBorder: workoutDiscardBorder ?? this.workoutDiscardBorder,
      swapMatchFill: swapMatchFill ?? this.swapMatchFill,
      swapMatchBorder: swapMatchBorder ?? this.swapMatchBorder,
      swapFilterBorder: swapFilterBorder ?? this.swapFilterBorder,
      swapSecondaryTextOpacity:
          swapSecondaryTextOpacity ?? this.swapSecondaryTextOpacity,
      trainTabSurfaceOpacity:
          trainTabSurfaceOpacity ?? this.trainTabSurfaceOpacity,
      splitWorkoutDividerOpacity:
          splitWorkoutDividerOpacity ?? this.splitWorkoutDividerOpacity,
      planRevealBorderOpacity:
          planRevealBorderOpacity ?? this.planRevealBorderOpacity,
      planSwapBadgeOpacity: planSwapBadgeOpacity ?? this.planSwapBadgeOpacity,
      flowErrorBorderOpacity:
          flowErrorBorderOpacity ?? this.flowErrorBorderOpacity,
      flowControlBorderOpacity:
          flowControlBorderOpacity ?? this.flowControlBorderOpacity,
      flowControlCollapsedOpacity:
          flowControlCollapsedOpacity ?? this.flowControlCollapsedOpacity,
      flowControlExpandedOpacity:
          flowControlExpandedOpacity ?? this.flowControlExpandedOpacity,
      flowControlIconOpacity:
          flowControlIconOpacity ?? this.flowControlIconOpacity,
      firstRecordFill: firstRecordFill ?? this.firstRecordFill,
      firstRecordBorder: firstRecordBorder ?? this.firstRecordBorder,
      recordBadgeFill: recordBadgeFill ?? this.recordBadgeFill,
      recordBadgeBorder: recordBadgeBorder ?? this.recordBadgeBorder,
      workoutCardCompleteFill:
          workoutCardCompleteFill ?? this.workoutCardCompleteFill,
      workoutSetCompleteFill:
          workoutSetCompleteFill ?? this.workoutSetCompleteFill,
      workoutChangeSetOutline:
          workoutChangeSetOutline ?? this.workoutChangeSetOutline,
      exerciseDetailCardBorderOpacity:
          exerciseDetailCardBorderOpacity ??
          this.exerciseDetailCardBorderOpacity,
      exerciseDetailHandleOpacity:
          exerciseDetailHandleOpacity ?? this.exerciseDetailHandleOpacity,
      exerciseDetailIconFillOpacity:
          exerciseDetailIconFillOpacity ?? this.exerciseDetailIconFillOpacity,
      exerciseDetailTagFillOpacity:
          exerciseDetailTagFillOpacity ?? this.exerciseDetailTagFillOpacity,
      exerciseDetailTagBorderOpacity:
          exerciseDetailTagBorderOpacity ?? this.exerciseDetailTagBorderOpacity,
      exerciseDetailTimeframeBorderOpacity:
          exerciseDetailTimeframeBorderOpacity ??
          this.exerciseDetailTimeframeBorderOpacity,
      exerciseDetailMetricFillOpacity:
          exerciseDetailMetricFillOpacity ??
          this.exerciseDetailMetricFillOpacity,
      exerciseDetailMetricBorderOpacity:
          exerciseDetailMetricBorderOpacity ??
          this.exerciseDetailMetricBorderOpacity,
      exerciseDetailRangeFillOpacity:
          exerciseDetailRangeFillOpacity ?? this.exerciseDetailRangeFillOpacity,
      exerciseDetailRecordBorderOpacity:
          exerciseDetailRecordBorderOpacity ??
          this.exerciseDetailRecordBorderOpacity,
      exerciseDetailRecordIconFillOpacity:
          exerciseDetailRecordIconFillOpacity ??
          this.exerciseDetailRecordIconFillOpacity,
      exerciseDetailRecordActionFillOpacity:
          exerciseDetailRecordActionFillOpacity ??
          this.exerciseDetailRecordActionFillOpacity,
      exerciseDetailRecordSetFillOpacity:
          exerciseDetailRecordSetFillOpacity ??
          this.exerciseDetailRecordSetFillOpacity,
      exerciseDetailLoadMoreBorderOpacity:
          exerciseDetailLoadMoreBorderOpacity ??
          this.exerciseDetailLoadMoreBorderOpacity,
      exerciseDetailMetricListBorderOpacity:
          exerciseDetailMetricListBorderOpacity ??
          this.exerciseDetailMetricListBorderOpacity,
      exerciseDetailMetricRepFillOpacity:
          exerciseDetailMetricRepFillOpacity ??
          this.exerciseDetailMetricRepFillOpacity,
      exerciseDetailMetricListDividerOpacity:
          exerciseDetailMetricListDividerOpacity ??
          this.exerciseDetailMetricListDividerOpacity,
      exerciseDetailStateBorderOpacity:
          exerciseDetailStateBorderOpacity ??
          this.exerciseDetailStateBorderOpacity,
      exerciseDetailChartBorderOpacity:
          exerciseDetailChartBorderOpacity ??
          this.exerciseDetailChartBorderOpacity,
      exerciseDetailChartGridOpacity:
          exerciseDetailChartGridOpacity ?? this.exerciseDetailChartGridOpacity,
      exerciseDetailChartAreaOpacity:
          exerciseDetailChartAreaOpacity ?? this.exerciseDetailChartAreaOpacity,
      workoutHandle: workoutHandle ?? this.workoutHandle,
      sessionSummary: sessionSummary ?? this.sessionSummary,
      completionMetricFill: completionMetricFill ?? this.completionMetricFill,
      completionMetricBorder:
          completionMetricBorder ?? this.completionMetricBorder,
      completionSetFill: completionSetFill ?? this.completionSetFill,
      completionExerciseFill:
          completionExerciseFill ?? this.completionExerciseFill,
      completionExerciseBorder:
          completionExerciseBorder ?? this.completionExerciseBorder,
      panelRaised: panelRaised ?? this.panelRaised,
      card: card ?? this.card,
      planCard: planCard ?? this.planCard,
      presetFocus: presetFocus ?? this.presetFocus,
      flowControl: flowControl ?? this.flowControl,
      planFilter: planFilter ?? this.planFilter,
      planDuration: planDuration ?? this.planDuration,
      planGroup: planGroup ?? this.planGroup,
      metricChip: metricChip ?? this.metricChip,
      planActionBar: planActionBar ?? this.planActionBar,
      optimizedAction: optimizedAction ?? this.optimizedAction,
      subtleOutline: subtleOutline ?? this.subtleOutline,
      input: input ?? this.input,
      sheet: sheet ?? this.sheet,
      dialog: dialog ?? this.dialog,
      media: media ?? this.media,
      mediaFrame: mediaFrame ?? this.mediaFrame,
      mediaPlaceholder: mediaPlaceholder ?? this.mediaPlaceholder,
      mediaOutline: mediaOutline ?? this.mediaOutline,
      catalogSelection: catalogSelection ?? this.catalogSelection,
      catalogUsage: catalogUsage ?? this.catalogUsage,
      catalogOutline: catalogOutline ?? this.catalogOutline,
      exerciseDetailCard: exerciseDetailCard ?? this.exerciseDetailCard,
      exerciseDetailTimeframe:
          exerciseDetailTimeframe ?? this.exerciseDetailTimeframe,
      exerciseDetailRecord: exerciseDetailRecord ?? this.exerciseDetailRecord,
      exerciseDetailMetricList:
          exerciseDetailMetricList ?? this.exerciseDetailMetricList,
      exerciseDetailState: exerciseDetailState ?? this.exerciseDetailState,
      exerciseDetailChart: exerciseDetailChart ?? this.exerciseDetailChart,
      exerciseDetailChartEmpty:
          exerciseDetailChartEmpty ?? this.exerciseDetailChartEmpty,
      exerciseDetailTooltip:
          exerciseDetailTooltip ?? this.exerciseDetailTooltip,
      divider: divider ?? this.divider,
      settingsHero: settingsHero ?? this.settingsHero,
      settingsSection: settingsSection ?? this.settingsSection,
      settingsInput: settingsInput ?? this.settingsInput,
      settingsSaveBar: settingsSaveBar ?? this.settingsSaveBar,
      dialogChoice: dialogChoice ?? this.dialogChoice,
      exerciseProgressHero: exerciseProgressHero ?? this.exerciseProgressHero,
      exerciseProgressStat: exerciseProgressStat ?? this.exerciseProgressStat,
      exerciseProgressSelector:
          exerciseProgressSelector ?? this.exerciseProgressSelector,
      exerciseProgressTooltip:
          exerciseProgressTooltip ?? this.exerciseProgressTooltip,
      workoutMetricStat: workoutMetricStat ?? this.workoutMetricStat,
      workoutMetricChart: workoutMetricChart ?? this.workoutMetricChart,
      workoutMetricTooltip: workoutMetricTooltip ?? this.workoutMetricTooltip,
      workoutMetricRange: workoutMetricRange ?? this.workoutMetricRange,
      workoutMetricDetails: workoutMetricDetails ?? this.workoutMetricDetails,
      workoutMetricInsight: workoutMetricInsight ?? this.workoutMetricInsight,
      dashboardHero: dashboardHero ?? this.dashboardHero,
      dashboardSection: dashboardSection ?? this.dashboardSection,
      dashboardEditor: dashboardEditor ?? this.dashboardEditor,
      dashboardUsage: dashboardUsage ?? this.dashboardUsage,
      historyPeriodSelector:
          historyPeriodSelector ?? this.historyPeriodSelector,
      calendarModeSelector: calendarModeSelector ?? this.calendarModeSelector,
      calendarDayEmpty: calendarDayEmpty ?? this.calendarDayEmpty,
      historySelectedPeriod:
          historySelectedPeriod ?? this.historySelectedPeriod,
      historyDivider: historyDivider ?? this.historyDivider,
    );
  }

  @override
  AppSurfaceTokens lerp(
    covariant ThemeExtension<AppSurfaceTokens>? other,
    double t,
  ) {
    if (other is! AppSurfaceTokens) {
      return this;
    }
    return AppSurfaceTokens(
      panel: Color.lerp(panel, other.panel, t)!,
      workoutDiscardBorder:
          workoutDiscardBorder +
          (other.workoutDiscardBorder - workoutDiscardBorder) * t,
      swapMatchFill: swapMatchFill + (other.swapMatchFill - swapMatchFill) * t,
      swapMatchBorder:
          swapMatchBorder + (other.swapMatchBorder - swapMatchBorder) * t,
      swapFilterBorder:
          swapFilterBorder + (other.swapFilterBorder - swapFilterBorder) * t,
      swapSecondaryTextOpacity:
          swapSecondaryTextOpacity +
          (other.swapSecondaryTextOpacity - swapSecondaryTextOpacity) * t,
      trainTabSurfaceOpacity:
          trainTabSurfaceOpacity +
          (other.trainTabSurfaceOpacity - trainTabSurfaceOpacity) * t,
      splitWorkoutDividerOpacity:
          splitWorkoutDividerOpacity +
          (other.splitWorkoutDividerOpacity - splitWorkoutDividerOpacity) * t,
      planRevealBorderOpacity:
          planRevealBorderOpacity +
          (other.planRevealBorderOpacity - planRevealBorderOpacity) * t,
      planSwapBadgeOpacity:
          planSwapBadgeOpacity +
          (other.planSwapBadgeOpacity - planSwapBadgeOpacity) * t,
      flowErrorBorderOpacity:
          flowErrorBorderOpacity +
          (other.flowErrorBorderOpacity - flowErrorBorderOpacity) * t,
      flowControlBorderOpacity:
          flowControlBorderOpacity +
          (other.flowControlBorderOpacity - flowControlBorderOpacity) * t,
      flowControlCollapsedOpacity:
          flowControlCollapsedOpacity +
          (other.flowControlCollapsedOpacity - flowControlCollapsedOpacity) * t,
      flowControlExpandedOpacity:
          flowControlExpandedOpacity +
          (other.flowControlExpandedOpacity - flowControlExpandedOpacity) * t,
      flowControlIconOpacity:
          flowControlIconOpacity +
          (other.flowControlIconOpacity - flowControlIconOpacity) * t,
      firstRecordFill:
          firstRecordFill + (other.firstRecordFill - firstRecordFill) * t,
      firstRecordBorder:
          firstRecordBorder + (other.firstRecordBorder - firstRecordBorder) * t,
      recordBadgeFill:
          recordBadgeFill + (other.recordBadgeFill - recordBadgeFill) * t,
      recordBadgeBorder:
          recordBadgeBorder + (other.recordBadgeBorder - recordBadgeBorder) * t,
      workoutCardCompleteFill:
          workoutCardCompleteFill +
          (other.workoutCardCompleteFill - workoutCardCompleteFill) * t,
      workoutSetCompleteFill:
          workoutSetCompleteFill +
          (other.workoutSetCompleteFill - workoutSetCompleteFill) * t,
      workoutChangeSetOutline:
          Color.lerp(
            workoutChangeSetOutline,
            other.workoutChangeSetOutline,
            t,
          )!,
      exerciseDetailCardBorderOpacity: _lerpDouble(
        exerciseDetailCardBorderOpacity,
        other.exerciseDetailCardBorderOpacity,
        t,
      ),
      exerciseDetailHandleOpacity: _lerpDouble(
        exerciseDetailHandleOpacity,
        other.exerciseDetailHandleOpacity,
        t,
      ),
      exerciseDetailIconFillOpacity: _lerpDouble(
        exerciseDetailIconFillOpacity,
        other.exerciseDetailIconFillOpacity,
        t,
      ),
      exerciseDetailTagFillOpacity: _lerpDouble(
        exerciseDetailTagFillOpacity,
        other.exerciseDetailTagFillOpacity,
        t,
      ),
      exerciseDetailTagBorderOpacity: _lerpDouble(
        exerciseDetailTagBorderOpacity,
        other.exerciseDetailTagBorderOpacity,
        t,
      ),
      exerciseDetailTimeframeBorderOpacity: _lerpDouble(
        exerciseDetailTimeframeBorderOpacity,
        other.exerciseDetailTimeframeBorderOpacity,
        t,
      ),
      exerciseDetailMetricFillOpacity: _lerpDouble(
        exerciseDetailMetricFillOpacity,
        other.exerciseDetailMetricFillOpacity,
        t,
      ),
      exerciseDetailMetricBorderOpacity: _lerpDouble(
        exerciseDetailMetricBorderOpacity,
        other.exerciseDetailMetricBorderOpacity,
        t,
      ),
      exerciseDetailRangeFillOpacity: _lerpDouble(
        exerciseDetailRangeFillOpacity,
        other.exerciseDetailRangeFillOpacity,
        t,
      ),
      exerciseDetailRecordBorderOpacity: _lerpDouble(
        exerciseDetailRecordBorderOpacity,
        other.exerciseDetailRecordBorderOpacity,
        t,
      ),
      exerciseDetailRecordIconFillOpacity: _lerpDouble(
        exerciseDetailRecordIconFillOpacity,
        other.exerciseDetailRecordIconFillOpacity,
        t,
      ),
      exerciseDetailRecordActionFillOpacity: _lerpDouble(
        exerciseDetailRecordActionFillOpacity,
        other.exerciseDetailRecordActionFillOpacity,
        t,
      ),
      exerciseDetailRecordSetFillOpacity: _lerpDouble(
        exerciseDetailRecordSetFillOpacity,
        other.exerciseDetailRecordSetFillOpacity,
        t,
      ),
      exerciseDetailLoadMoreBorderOpacity: _lerpDouble(
        exerciseDetailLoadMoreBorderOpacity,
        other.exerciseDetailLoadMoreBorderOpacity,
        t,
      ),
      exerciseDetailMetricListBorderOpacity: _lerpDouble(
        exerciseDetailMetricListBorderOpacity,
        other.exerciseDetailMetricListBorderOpacity,
        t,
      ),
      exerciseDetailMetricRepFillOpacity: _lerpDouble(
        exerciseDetailMetricRepFillOpacity,
        other.exerciseDetailMetricRepFillOpacity,
        t,
      ),
      exerciseDetailMetricListDividerOpacity: _lerpDouble(
        exerciseDetailMetricListDividerOpacity,
        other.exerciseDetailMetricListDividerOpacity,
        t,
      ),
      exerciseDetailStateBorderOpacity: _lerpDouble(
        exerciseDetailStateBorderOpacity,
        other.exerciseDetailStateBorderOpacity,
        t,
      ),
      exerciseDetailChartBorderOpacity: _lerpDouble(
        exerciseDetailChartBorderOpacity,
        other.exerciseDetailChartBorderOpacity,
        t,
      ),
      exerciseDetailChartGridOpacity: _lerpDouble(
        exerciseDetailChartGridOpacity,
        other.exerciseDetailChartGridOpacity,
        t,
      ),
      exerciseDetailChartAreaOpacity: _lerpDouble(
        exerciseDetailChartAreaOpacity,
        other.exerciseDetailChartAreaOpacity,
        t,
      ),
      workoutHandle: Color.lerp(workoutHandle, other.workoutHandle, t)!,
      sessionSummary: Color.lerp(sessionSummary, other.sessionSummary, t)!,
      completionMetricFill:
          completionMetricFill +
          (other.completionMetricFill - completionMetricFill) * t,
      completionMetricBorder:
          completionMetricBorder +
          (other.completionMetricBorder - completionMetricBorder) * t,
      completionSetFill:
          completionSetFill + (other.completionSetFill - completionSetFill) * t,
      completionExerciseFill:
          completionExerciseFill +
          (other.completionExerciseFill - completionExerciseFill) * t,
      completionExerciseBorder:
          completionExerciseBorder +
          (other.completionExerciseBorder - completionExerciseBorder) * t,
      panelRaised: Color.lerp(panelRaised, other.panelRaised, t)!,
      card: Color.lerp(card, other.card, t)!,
      planCard: Color.lerp(planCard, other.planCard, t)!,
      presetFocus: Color.lerp(presetFocus, other.presetFocus, t)!,
      flowControl: Color.lerp(flowControl, other.flowControl, t)!,
      planFilter: Color.lerp(planFilter, other.planFilter, t)!,
      planDuration: Color.lerp(planDuration, other.planDuration, t)!,
      planGroup: Color.lerp(planGroup, other.planGroup, t)!,
      metricChip: Color.lerp(metricChip, other.metricChip, t)!,
      planActionBar: Color.lerp(planActionBar, other.planActionBar, t)!,
      optimizedAction: Color.lerp(optimizedAction, other.optimizedAction, t)!,
      subtleOutline: Color.lerp(subtleOutline, other.subtleOutline, t)!,
      input: Color.lerp(input, other.input, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      dialog: Color.lerp(dialog, other.dialog, t)!,
      media: Color.lerp(media, other.media, t)!,
      mediaFrame: Color.lerp(mediaFrame, other.mediaFrame, t)!,
      mediaPlaceholder:
          Color.lerp(mediaPlaceholder, other.mediaPlaceholder, t)!,
      mediaOutline: Color.lerp(mediaOutline, other.mediaOutline, t)!,
      catalogSelection:
          Color.lerp(catalogSelection, other.catalogSelection, t)!,
      catalogUsage: Color.lerp(catalogUsage, other.catalogUsage, t)!,
      catalogOutline: Color.lerp(catalogOutline, other.catalogOutline, t)!,
      exerciseDetailCard:
          Color.lerp(exerciseDetailCard, other.exerciseDetailCard, t)!,
      exerciseDetailTimeframe:
          Color.lerp(
            exerciseDetailTimeframe,
            other.exerciseDetailTimeframe,
            t,
          )!,
      exerciseDetailRecord:
          Color.lerp(exerciseDetailRecord, other.exerciseDetailRecord, t)!,
      exerciseDetailMetricList:
          Color.lerp(
            exerciseDetailMetricList,
            other.exerciseDetailMetricList,
            t,
          )!,
      exerciseDetailState:
          Color.lerp(exerciseDetailState, other.exerciseDetailState, t)!,
      exerciseDetailChart:
          Color.lerp(exerciseDetailChart, other.exerciseDetailChart, t)!,
      exerciseDetailChartEmpty:
          Color.lerp(
            exerciseDetailChartEmpty,
            other.exerciseDetailChartEmpty,
            t,
          )!,
      exerciseDetailTooltip:
          Color.lerp(exerciseDetailTooltip, other.exerciseDetailTooltip, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      settingsHero: Color.lerp(settingsHero, other.settingsHero, t)!,
      settingsSection: Color.lerp(settingsSection, other.settingsSection, t)!,
      settingsInput: Color.lerp(settingsInput, other.settingsInput, t)!,
      settingsSaveBar: Color.lerp(settingsSaveBar, other.settingsSaveBar, t)!,
      dialogChoice: Color.lerp(dialogChoice, other.dialogChoice, t)!,
      exerciseProgressHero:
          Color.lerp(exerciseProgressHero, other.exerciseProgressHero, t)!,
      exerciseProgressStat:
          Color.lerp(exerciseProgressStat, other.exerciseProgressStat, t)!,
      exerciseProgressSelector:
          Color.lerp(
            exerciseProgressSelector,
            other.exerciseProgressSelector,
            t,
          )!,
      exerciseProgressTooltip:
          Color.lerp(
            exerciseProgressTooltip,
            other.exerciseProgressTooltip,
            t,
          )!,
      workoutMetricStat:
          Color.lerp(workoutMetricStat, other.workoutMetricStat, t)!,
      workoutMetricChart:
          Color.lerp(workoutMetricChart, other.workoutMetricChart, t)!,
      workoutMetricTooltip:
          Color.lerp(workoutMetricTooltip, other.workoutMetricTooltip, t)!,
      workoutMetricRange:
          Color.lerp(workoutMetricRange, other.workoutMetricRange, t)!,
      workoutMetricDetails:
          Color.lerp(workoutMetricDetails, other.workoutMetricDetails, t)!,
      workoutMetricInsight:
          Color.lerp(workoutMetricInsight, other.workoutMetricInsight, t)!,
      dashboardHero: Color.lerp(dashboardHero, other.dashboardHero, t)!,
      dashboardSection:
          Color.lerp(dashboardSection, other.dashboardSection, t)!,
      dashboardEditor: Color.lerp(dashboardEditor, other.dashboardEditor, t)!,
      dashboardUsage: Color.lerp(dashboardUsage, other.dashboardUsage, t)!,
      historyPeriodSelector:
          Color.lerp(historyPeriodSelector, other.historyPeriodSelector, t)!,
      calendarModeSelector:
          Color.lerp(calendarModeSelector, other.calendarModeSelector, t)!,
      calendarDayEmpty:
          Color.lerp(calendarDayEmpty, other.calendarDayEmpty, t)!,
      historySelectedPeriod:
          Color.lerp(historySelectedPeriod, other.historySelectedPeriod, t)!,
      historyDivider: Color.lerp(historyDivider, other.historyDivider, t)!,
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
