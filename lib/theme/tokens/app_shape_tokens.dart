import 'package:flutter/material.dart';

/// Shared geometry roles. Families may vary the recipe, but not layout rules.
@immutable
class AppShapeTokens extends ThemeExtension<AppShapeTokens> {
  const AppShapeTokens({
    this.trainTab = const BorderRadius.all(Radius.circular(20)),
    this.trainTabButton = const BorderRadius.all(Radius.circular(3)),
    this.workoutCompletedSet = const BorderRadius.all(Radius.circular(12)),
    this.workoutCompletedSetBorderWidth = 1,
    this.workoutCompletedSetAccentBorderWidth = 3,
    this.workoutAddChangeSet = const BorderRadius.all(Radius.circular(4)),
    this.mediaThumbnail = const BorderRadius.all(Radius.circular(10)),
    this.exerciseDetailSheet = const BorderRadius.vertical(
      top: Radius.circular(16),
    ),
    this.exerciseDetailCard = const BorderRadius.all(Radius.circular(16)),
    this.exerciseDetailIcon = const BorderRadius.all(Radius.circular(10)),
    this.exerciseDetailTag = const BorderRadius.all(Radius.circular(9)),
    this.exerciseDetailMetric = const BorderRadius.all(Radius.circular(15)),
    this.exerciseDetailTimeframe = const BorderRadius.all(Radius.circular(15)),
    this.exerciseDetailTimeframeOption = const BorderRadius.all(
      Radius.circular(11),
    ),
    this.exerciseDetailRecord = const BorderRadius.all(Radius.circular(15)),
    this.exerciseDetailRecordAction = const BorderRadius.all(
      Radius.circular(9),
    ),
    this.exerciseDetailLoadMore = const BorderRadius.all(Radius.circular(13)),
    this.exerciseDetailMetricRep = const BorderRadius.all(Radius.circular(11)),
    this.exerciseDetailState = const BorderRadius.all(Radius.circular(18)),
    this.exerciseDetailChart = const BorderRadius.all(Radius.circular(18)),
    this.exerciseDetailChartTooltip = const BorderRadius.all(
      Radius.circular(10),
    ),
    required this.compact,
    required this.control,
    required this.metric,
    required this.recordBadge,
    required this.recordBadgeCompact,
    required this.workoutSection,
    required this.planCard,
    required this.flowControl,
    required this.flowIcon,
    required this.card,
    required this.sheet,
    this.swapSheet = const BorderRadius.vertical(top: Radius.circular(24)),
    required this.pill,
    required this.settingsAction,
    required this.settingsPanel,
    required this.settingsInput,
    required this.settingsTabIndicator,
    required this.settingsScopeIcon,
    required this.settingsTitleCard,
    required this.settingsField,
    required this.settingsPicker,
    required this.settingsIcon,
    required this.profileTile,
    required this.hero,
    required this.actionBar,
    required this.dialogChoice,
    required this.exerciseProgressHero,
    required this.exerciseProgressStat,
    required this.exerciseProgressSelector,
    required this.exerciseProgressAddTile,
    required this.exerciseProgressTooltip,
    required this.workoutMetricStat,
    required this.workoutMetricChart,
    required this.workoutMetricTooltip,
    required this.workoutMetricRange,
    required this.workoutMetricRangeOption,
    required this.workoutMetricDetails,
    required this.workoutMetricInsight,
    required this.healthTrendCard,
    required this.healthTrendEntry,
    required this.dashboardHero,
    required this.dashboardSection,
    required this.dashboardEditor,
    required this.dashboardAction,
    required this.dashboardUsage,
    required this.dashboardRow,
    required this.dashboardFooter,
    required this.historySelectedPeriod,
    required this.outlineWidth,
    required this.focusRingWidth,
  });

  static const AppShapeTokens classic = AppShapeTokens(
    trainTab: BorderRadius.all(Radius.circular(20)),
    trainTabButton: BorderRadius.all(Radius.circular(3)),
    mediaThumbnail: BorderRadius.all(Radius.circular(10)),
    exerciseDetailSheet: BorderRadius.vertical(top: Radius.circular(16)),
    exerciseDetailCard: BorderRadius.all(Radius.circular(16)),
    exerciseDetailIcon: BorderRadius.all(Radius.circular(10)),
    exerciseDetailTag: BorderRadius.all(Radius.circular(9)),
    exerciseDetailMetric: BorderRadius.all(Radius.circular(15)),
    exerciseDetailTimeframe: BorderRadius.all(Radius.circular(15)),
    exerciseDetailTimeframeOption: BorderRadius.all(Radius.circular(11)),
    exerciseDetailRecord: BorderRadius.all(Radius.circular(15)),
    exerciseDetailRecordAction: BorderRadius.all(Radius.circular(9)),
    exerciseDetailLoadMore: BorderRadius.all(Radius.circular(13)),
    exerciseDetailMetricRep: BorderRadius.all(Radius.circular(11)),
    exerciseDetailState: BorderRadius.all(Radius.circular(18)),
    exerciseDetailChart: BorderRadius.all(Radius.circular(18)),
    exerciseDetailChartTooltip: BorderRadius.all(Radius.circular(10)),
    compact: BorderRadius.all(Radius.circular(8)),
    control: BorderRadius.all(Radius.circular(12)),
    metric: BorderRadius.all(Radius.circular(14)),
    recordBadge: BorderRadius.all(Radius.circular(7)),
    recordBadgeCompact: BorderRadius.all(Radius.circular(5)),
    workoutSection: BorderRadius.all(Radius.circular(10)),
    planCard: BorderRadius.all(Radius.circular(18)),
    flowControl: BorderRadius.all(Radius.circular(20)),
    flowIcon: BorderRadius.all(Radius.circular(13)),
    card: BorderRadius.all(Radius.circular(16)),
    sheet: BorderRadius.all(Radius.circular(24)),
    swapSheet: BorderRadius.vertical(top: Radius.circular(24)),
    pill: BorderRadius.all(Radius.circular(999)),
    settingsAction: BorderRadius.all(Radius.circular(15)),
    settingsPanel: BorderRadius.all(Radius.circular(22)),
    settingsInput: BorderRadius.all(Radius.circular(14)),
    settingsTabIndicator: BorderRadius.all(Radius.circular(14)),
    settingsScopeIcon: BorderRadius.all(Radius.circular(14)),
    settingsTitleCard: BorderRadius.all(Radius.circular(24)),
    settingsField: BorderRadius.all(Radius.circular(16)),
    settingsPicker: BorderRadius.all(Radius.circular(20)),
    settingsIcon: BorderRadius.all(Radius.circular(13)),
    profileTile: BorderRadius.all(Radius.circular(18)),
    hero: BorderRadius.all(Radius.circular(28)),
    actionBar: BorderRadius.all(Radius.circular(24)),
    dialogChoice: BorderRadius.all(Radius.circular(14)),
    exerciseProgressHero: BorderRadius.all(Radius.circular(18)),
    exerciseProgressStat: BorderRadius.all(Radius.circular(14)),
    exerciseProgressSelector: BorderRadius.all(Radius.circular(14)),
    exerciseProgressAddTile: BorderRadius.all(Radius.circular(12)),
    exerciseProgressTooltip: BorderRadius.all(Radius.circular(10)),
    workoutMetricStat: BorderRadius.all(Radius.circular(16)),
    workoutMetricChart: BorderRadius.all(Radius.circular(18)),
    workoutMetricTooltip: BorderRadius.all(Radius.circular(10)),
    workoutMetricRange: BorderRadius.all(Radius.circular(14)),
    workoutMetricRangeOption: BorderRadius.all(Radius.circular(11)),
    workoutMetricDetails: BorderRadius.all(Radius.circular(14)),
    workoutMetricInsight: BorderRadius.all(Radius.circular(14)),
    healthTrendCard: BorderRadius.all(Radius.circular(18)),
    healthTrendEntry: BorderRadius.all(Radius.circular(14)),
    dashboardHero: BorderRadius.all(Radius.circular(22)),
    dashboardSection: BorderRadius.all(Radius.circular(24)),
    dashboardEditor: BorderRadius.all(Radius.circular(20)),
    dashboardAction: BorderRadius.all(Radius.circular(16)),
    dashboardUsage: BorderRadius.all(Radius.circular(13)),
    dashboardRow: BorderRadius.all(Radius.circular(14)),
    dashboardFooter: BorderRadius.all(Radius.circular(22)),
    historySelectedPeriod: BorderRadius.all(Radius.circular(18)),
    outlineWidth: 1,
    focusRingWidth: 2,
  );

  final BorderRadius compact;
  final BorderRadius trainTab;
  final BorderRadius trainTabButton;
  final BorderRadius workoutCompletedSet;
  final double workoutCompletedSetBorderWidth;
  final double workoutCompletedSetAccentBorderWidth;
  final BorderRadius mediaThumbnail;
  final BorderRadius workoutAddChangeSet;
  final BorderRadius exerciseDetailSheet;
  final BorderRadius exerciseDetailCard;
  final BorderRadius exerciseDetailIcon;
  final BorderRadius exerciseDetailTag;
  final BorderRadius exerciseDetailMetric;
  final BorderRadius exerciseDetailTimeframe;
  final BorderRadius exerciseDetailTimeframeOption;
  final BorderRadius exerciseDetailRecord;
  final BorderRadius exerciseDetailRecordAction;
  final BorderRadius exerciseDetailLoadMore;
  final BorderRadius exerciseDetailMetricRep;
  final BorderRadius exerciseDetailState;
  final BorderRadius exerciseDetailChart;
  final BorderRadius exerciseDetailChartTooltip;
  final BorderRadius control;
  final BorderRadius metric;
  final BorderRadius recordBadge;
  final BorderRadius recordBadgeCompact;
  final BorderRadius workoutSection;
  final BorderRadius planCard;
  final BorderRadius flowControl;
  final BorderRadius flowIcon;
  final BorderRadius card;
  final BorderRadius sheet;
  final BorderRadius swapSheet;
  final BorderRadius pill;
  final BorderRadius settingsAction;
  final BorderRadius settingsPanel;
  final BorderRadius settingsInput;
  final BorderRadius settingsTabIndicator;
  final BorderRadius settingsScopeIcon;
  final BorderRadius settingsTitleCard;
  final BorderRadius settingsField;
  final BorderRadius settingsPicker;
  final BorderRadius settingsIcon;
  final BorderRadius profileTile;
  final BorderRadius hero;
  final BorderRadius actionBar;
  final BorderRadius dialogChoice;
  final BorderRadius exerciseProgressHero;
  final BorderRadius exerciseProgressStat;
  final BorderRadius exerciseProgressSelector;
  final BorderRadius exerciseProgressAddTile;
  final BorderRadius exerciseProgressTooltip;
  final BorderRadius workoutMetricStat;
  final BorderRadius workoutMetricChart;
  final BorderRadius workoutMetricTooltip;
  final BorderRadius workoutMetricRange;
  final BorderRadius workoutMetricRangeOption;
  final BorderRadius workoutMetricDetails;
  final BorderRadius workoutMetricInsight;
  final BorderRadius healthTrendCard;
  final BorderRadius healthTrendEntry;
  final BorderRadius dashboardHero;
  final BorderRadius dashboardSection;
  final BorderRadius dashboardEditor;
  final BorderRadius dashboardAction;
  final BorderRadius dashboardUsage;
  final BorderRadius dashboardRow;
  final BorderRadius dashboardFooter;
  final BorderRadius historySelectedPeriod;
  final double outlineWidth;
  final double focusRingWidth;

  @override
  AppShapeTokens copyWith({
    BorderRadius? trainTab,
    BorderRadius? trainTabButton,
    BorderRadius? workoutCompletedSet,
    double? workoutCompletedSetBorderWidth,
    double? workoutCompletedSetAccentBorderWidth,
    BorderRadius? workoutAddChangeSet,
    BorderRadius? mediaThumbnail,
    BorderRadius? exerciseDetailSheet,
    BorderRadius? exerciseDetailCard,
    BorderRadius? exerciseDetailIcon,
    BorderRadius? exerciseDetailTag,
    BorderRadius? exerciseDetailMetric,
    BorderRadius? exerciseDetailTimeframe,
    BorderRadius? exerciseDetailTimeframeOption,
    BorderRadius? exerciseDetailRecord,
    BorderRadius? exerciseDetailRecordAction,
    BorderRadius? exerciseDetailLoadMore,
    BorderRadius? exerciseDetailMetricRep,
    BorderRadius? exerciseDetailState,
    BorderRadius? exerciseDetailChart,
    BorderRadius? exerciseDetailChartTooltip,
    BorderRadius? compact,
    BorderRadius? control,
    BorderRadius? metric,
    BorderRadius? recordBadge,
    BorderRadius? recordBadgeCompact,
    BorderRadius? workoutSection,
    BorderRadius? planCard,
    BorderRadius? flowControl,
    BorderRadius? flowIcon,
    BorderRadius? card,
    BorderRadius? sheet,
    BorderRadius? swapSheet,
    BorderRadius? pill,
    BorderRadius? settingsAction,
    BorderRadius? settingsPanel,
    BorderRadius? settingsInput,
    BorderRadius? settingsTabIndicator,
    BorderRadius? settingsScopeIcon,
    BorderRadius? settingsTitleCard,
    BorderRadius? settingsField,
    BorderRadius? settingsPicker,
    BorderRadius? settingsIcon,
    BorderRadius? profileTile,
    BorderRadius? hero,
    BorderRadius? actionBar,
    BorderRadius? dialogChoice,
    BorderRadius? exerciseProgressHero,
    BorderRadius? exerciseProgressStat,
    BorderRadius? exerciseProgressSelector,
    BorderRadius? exerciseProgressAddTile,
    BorderRadius? exerciseProgressTooltip,
    BorderRadius? workoutMetricStat,
    BorderRadius? workoutMetricChart,
    BorderRadius? workoutMetricTooltip,
    BorderRadius? workoutMetricRange,
    BorderRadius? workoutMetricRangeOption,
    BorderRadius? workoutMetricDetails,
    BorderRadius? workoutMetricInsight,
    BorderRadius? healthTrendCard,
    BorderRadius? healthTrendEntry,
    BorderRadius? dashboardHero,
    BorderRadius? dashboardSection,
    BorderRadius? dashboardEditor,
    BorderRadius? dashboardAction,
    BorderRadius? dashboardUsage,
    BorderRadius? dashboardRow,
    BorderRadius? dashboardFooter,
    BorderRadius? historySelectedPeriod,
    double? outlineWidth,
    double? focusRingWidth,
  }) {
    return AppShapeTokens(
      trainTab: trainTab ?? this.trainTab,
      trainTabButton: trainTabButton ?? this.trainTabButton,
      workoutCompletedSet: workoutCompletedSet ?? this.workoutCompletedSet,
      workoutCompletedSetBorderWidth:
          workoutCompletedSetBorderWidth ?? this.workoutCompletedSetBorderWidth,
      workoutCompletedSetAccentBorderWidth:
          workoutCompletedSetAccentBorderWidth ??
          this.workoutCompletedSetAccentBorderWidth,
      mediaThumbnail: mediaThumbnail ?? this.mediaThumbnail,
      workoutAddChangeSet: workoutAddChangeSet ?? this.workoutAddChangeSet,
      exerciseDetailSheet: exerciseDetailSheet ?? this.exerciseDetailSheet,
      exerciseDetailCard: exerciseDetailCard ?? this.exerciseDetailCard,
      exerciseDetailIcon: exerciseDetailIcon ?? this.exerciseDetailIcon,
      exerciseDetailTag: exerciseDetailTag ?? this.exerciseDetailTag,
      exerciseDetailMetric: exerciseDetailMetric ?? this.exerciseDetailMetric,
      exerciseDetailTimeframe:
          exerciseDetailTimeframe ?? this.exerciseDetailTimeframe,
      exerciseDetailTimeframeOption:
          exerciseDetailTimeframeOption ?? this.exerciseDetailTimeframeOption,
      exerciseDetailRecord: exerciseDetailRecord ?? this.exerciseDetailRecord,
      exerciseDetailRecordAction:
          exerciseDetailRecordAction ?? this.exerciseDetailRecordAction,
      exerciseDetailLoadMore:
          exerciseDetailLoadMore ?? this.exerciseDetailLoadMore,
      exerciseDetailMetricRep:
          exerciseDetailMetricRep ?? this.exerciseDetailMetricRep,
      exerciseDetailState: exerciseDetailState ?? this.exerciseDetailState,
      exerciseDetailChart: exerciseDetailChart ?? this.exerciseDetailChart,
      exerciseDetailChartTooltip:
          exerciseDetailChartTooltip ?? this.exerciseDetailChartTooltip,
      compact: compact ?? this.compact,
      control: control ?? this.control,
      metric: metric ?? this.metric,
      recordBadge: recordBadge ?? this.recordBadge,
      recordBadgeCompact: recordBadgeCompact ?? this.recordBadgeCompact,
      workoutSection: workoutSection ?? this.workoutSection,
      planCard: planCard ?? this.planCard,
      flowControl: flowControl ?? this.flowControl,
      flowIcon: flowIcon ?? this.flowIcon,
      card: card ?? this.card,
      sheet: sheet ?? this.sheet,
      swapSheet: swapSheet ?? this.swapSheet,
      pill: pill ?? this.pill,
      settingsAction: settingsAction ?? this.settingsAction,
      settingsPanel: settingsPanel ?? this.settingsPanel,
      settingsInput: settingsInput ?? this.settingsInput,
      settingsTabIndicator: settingsTabIndicator ?? this.settingsTabIndicator,
      settingsScopeIcon: settingsScopeIcon ?? this.settingsScopeIcon,
      settingsTitleCard: settingsTitleCard ?? this.settingsTitleCard,
      settingsField: settingsField ?? this.settingsField,
      settingsPicker: settingsPicker ?? this.settingsPicker,
      settingsIcon: settingsIcon ?? this.settingsIcon,
      profileTile: profileTile ?? this.profileTile,
      hero: hero ?? this.hero,
      actionBar: actionBar ?? this.actionBar,
      dialogChoice: dialogChoice ?? this.dialogChoice,
      exerciseProgressHero: exerciseProgressHero ?? this.exerciseProgressHero,
      exerciseProgressStat: exerciseProgressStat ?? this.exerciseProgressStat,
      exerciseProgressSelector:
          exerciseProgressSelector ?? this.exerciseProgressSelector,
      exerciseProgressAddTile:
          exerciseProgressAddTile ?? this.exerciseProgressAddTile,
      exerciseProgressTooltip:
          exerciseProgressTooltip ?? this.exerciseProgressTooltip,
      workoutMetricStat: workoutMetricStat ?? this.workoutMetricStat,
      workoutMetricChart: workoutMetricChart ?? this.workoutMetricChart,
      workoutMetricTooltip: workoutMetricTooltip ?? this.workoutMetricTooltip,
      workoutMetricRange: workoutMetricRange ?? this.workoutMetricRange,
      workoutMetricRangeOption:
          workoutMetricRangeOption ?? this.workoutMetricRangeOption,
      workoutMetricDetails: workoutMetricDetails ?? this.workoutMetricDetails,
      workoutMetricInsight: workoutMetricInsight ?? this.workoutMetricInsight,
      healthTrendCard: healthTrendCard ?? this.healthTrendCard,
      healthTrendEntry: healthTrendEntry ?? this.healthTrendEntry,
      dashboardHero: dashboardHero ?? this.dashboardHero,
      dashboardSection: dashboardSection ?? this.dashboardSection,
      dashboardEditor: dashboardEditor ?? this.dashboardEditor,
      dashboardAction: dashboardAction ?? this.dashboardAction,
      dashboardUsage: dashboardUsage ?? this.dashboardUsage,
      dashboardRow: dashboardRow ?? this.dashboardRow,
      dashboardFooter: dashboardFooter ?? this.dashboardFooter,
      historySelectedPeriod:
          historySelectedPeriod ?? this.historySelectedPeriod,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
    );
  }

  @override
  AppShapeTokens lerp(
    covariant ThemeExtension<AppShapeTokens>? other,
    double t,
  ) {
    if (other is! AppShapeTokens) {
      return this;
    }
    return AppShapeTokens(
      trainTab: BorderRadius.lerp(trainTab, other.trainTab, t)!,
      trainTabButton:
          BorderRadius.lerp(trainTabButton, other.trainTabButton, t)!,
      workoutCompletedSet:
          BorderRadius.lerp(workoutCompletedSet, other.workoutCompletedSet, t)!,
      workoutCompletedSetBorderWidth: _lerpDouble(
        workoutCompletedSetBorderWidth,
        other.workoutCompletedSetBorderWidth,
        t,
      ),
      workoutCompletedSetAccentBorderWidth: _lerpDouble(
        workoutCompletedSetAccentBorderWidth,
        other.workoutCompletedSetAccentBorderWidth,
        t,
      ),
      mediaThumbnail:
          BorderRadius.lerp(mediaThumbnail, other.mediaThumbnail, t)!,
      workoutAddChangeSet:
          BorderRadius.lerp(workoutAddChangeSet, other.workoutAddChangeSet, t)!,
      exerciseDetailSheet:
          BorderRadius.lerp(exerciseDetailSheet, other.exerciseDetailSheet, t)!,
      exerciseDetailCard:
          BorderRadius.lerp(exerciseDetailCard, other.exerciseDetailCard, t)!,
      exerciseDetailIcon:
          BorderRadius.lerp(exerciseDetailIcon, other.exerciseDetailIcon, t)!,
      exerciseDetailTag:
          BorderRadius.lerp(exerciseDetailTag, other.exerciseDetailTag, t)!,
      exerciseDetailMetric:
          BorderRadius.lerp(
            exerciseDetailMetric,
            other.exerciseDetailMetric,
            t,
          )!,
      exerciseDetailTimeframe:
          BorderRadius.lerp(
            exerciseDetailTimeframe,
            other.exerciseDetailTimeframe,
            t,
          )!,
      exerciseDetailTimeframeOption:
          BorderRadius.lerp(
            exerciseDetailTimeframeOption,
            other.exerciseDetailTimeframeOption,
            t,
          )!,
      exerciseDetailRecord:
          BorderRadius.lerp(
            exerciseDetailRecord,
            other.exerciseDetailRecord,
            t,
          )!,
      exerciseDetailRecordAction:
          BorderRadius.lerp(
            exerciseDetailRecordAction,
            other.exerciseDetailRecordAction,
            t,
          )!,
      exerciseDetailLoadMore:
          BorderRadius.lerp(
            exerciseDetailLoadMore,
            other.exerciseDetailLoadMore,
            t,
          )!,
      exerciseDetailMetricRep:
          BorderRadius.lerp(
            exerciseDetailMetricRep,
            other.exerciseDetailMetricRep,
            t,
          )!,
      exerciseDetailState:
          BorderRadius.lerp(exerciseDetailState, other.exerciseDetailState, t)!,
      exerciseDetailChart:
          BorderRadius.lerp(exerciseDetailChart, other.exerciseDetailChart, t)!,
      exerciseDetailChartTooltip:
          BorderRadius.lerp(
            exerciseDetailChartTooltip,
            other.exerciseDetailChartTooltip,
            t,
          )!,
      compact: BorderRadius.lerp(compact, other.compact, t)!,
      control: BorderRadius.lerp(control, other.control, t)!,
      metric: BorderRadius.lerp(metric, other.metric, t)!,
      recordBadge: BorderRadius.lerp(recordBadge, other.recordBadge, t)!,
      recordBadgeCompact:
          BorderRadius.lerp(recordBadgeCompact, other.recordBadgeCompact, t)!,
      workoutSection:
          BorderRadius.lerp(workoutSection, other.workoutSection, t)!,
      planCard: BorderRadius.lerp(planCard, other.planCard, t)!,
      flowControl: BorderRadius.lerp(flowControl, other.flowControl, t)!,
      flowIcon: BorderRadius.lerp(flowIcon, other.flowIcon, t)!,
      card: BorderRadius.lerp(card, other.card, t)!,
      sheet: BorderRadius.lerp(sheet, other.sheet, t)!,
      swapSheet: BorderRadius.lerp(swapSheet, other.swapSheet, t)!,
      pill: BorderRadius.lerp(pill, other.pill, t)!,
      settingsAction:
          BorderRadius.lerp(settingsAction, other.settingsAction, t)!,
      settingsPanel: BorderRadius.lerp(settingsPanel, other.settingsPanel, t)!,
      settingsInput: BorderRadius.lerp(settingsInput, other.settingsInput, t)!,
      settingsTabIndicator:
          BorderRadius.lerp(
            settingsTabIndicator,
            other.settingsTabIndicator,
            t,
          )!,
      settingsScopeIcon:
          BorderRadius.lerp(settingsScopeIcon, other.settingsScopeIcon, t)!,
      settingsTitleCard:
          BorderRadius.lerp(settingsTitleCard, other.settingsTitleCard, t)!,
      settingsField: BorderRadius.lerp(settingsField, other.settingsField, t)!,
      settingsPicker:
          BorderRadius.lerp(settingsPicker, other.settingsPicker, t)!,
      settingsIcon: BorderRadius.lerp(settingsIcon, other.settingsIcon, t)!,
      profileTile: BorderRadius.lerp(profileTile, other.profileTile, t)!,
      hero: BorderRadius.lerp(hero, other.hero, t)!,
      actionBar: BorderRadius.lerp(actionBar, other.actionBar, t)!,
      dialogChoice: BorderRadius.lerp(dialogChoice, other.dialogChoice, t)!,
      exerciseProgressHero:
          BorderRadius.lerp(
            exerciseProgressHero,
            other.exerciseProgressHero,
            t,
          )!,
      exerciseProgressStat:
          BorderRadius.lerp(
            exerciseProgressStat,
            other.exerciseProgressStat,
            t,
          )!,
      exerciseProgressSelector:
          BorderRadius.lerp(
            exerciseProgressSelector,
            other.exerciseProgressSelector,
            t,
          )!,
      exerciseProgressAddTile:
          BorderRadius.lerp(
            exerciseProgressAddTile,
            other.exerciseProgressAddTile,
            t,
          )!,
      exerciseProgressTooltip:
          BorderRadius.lerp(
            exerciseProgressTooltip,
            other.exerciseProgressTooltip,
            t,
          )!,
      workoutMetricStat:
          BorderRadius.lerp(workoutMetricStat, other.workoutMetricStat, t)!,
      workoutMetricChart:
          BorderRadius.lerp(workoutMetricChart, other.workoutMetricChart, t)!,
      workoutMetricTooltip:
          BorderRadius.lerp(
            workoutMetricTooltip,
            other.workoutMetricTooltip,
            t,
          )!,
      workoutMetricRange:
          BorderRadius.lerp(workoutMetricRange, other.workoutMetricRange, t)!,
      workoutMetricRangeOption:
          BorderRadius.lerp(
            workoutMetricRangeOption,
            other.workoutMetricRangeOption,
            t,
          )!,
      workoutMetricDetails:
          BorderRadius.lerp(
            workoutMetricDetails,
            other.workoutMetricDetails,
            t,
          )!,
      workoutMetricInsight:
          BorderRadius.lerp(
            workoutMetricInsight,
            other.workoutMetricInsight,
            t,
          )!,
      healthTrendCard:
          BorderRadius.lerp(healthTrendCard, other.healthTrendCard, t)!,
      healthTrendEntry:
          BorderRadius.lerp(healthTrendEntry, other.healthTrendEntry, t)!,
      dashboardHero: BorderRadius.lerp(dashboardHero, other.dashboardHero, t)!,
      dashboardSection:
          BorderRadius.lerp(dashboardSection, other.dashboardSection, t)!,
      dashboardEditor:
          BorderRadius.lerp(dashboardEditor, other.dashboardEditor, t)!,
      dashboardAction:
          BorderRadius.lerp(dashboardAction, other.dashboardAction, t)!,
      dashboardUsage:
          BorderRadius.lerp(dashboardUsage, other.dashboardUsage, t)!,
      dashboardRow: BorderRadius.lerp(dashboardRow, other.dashboardRow, t)!,
      dashboardFooter:
          BorderRadius.lerp(dashboardFooter, other.dashboardFooter, t)!,
      historySelectedPeriod:
          BorderRadius.lerp(
            historySelectedPeriod,
            other.historySelectedPeriod,
            t,
          )!,
      outlineWidth: _lerpDouble(outlineWidth, other.outlineWidth, t),
      focusRingWidth: _lerpDouble(focusRingWidth, other.focusRingWidth, t),
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
