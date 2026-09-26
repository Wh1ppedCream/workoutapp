// File: lib/widgets/session_complete_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../utils/localized_formatters.dart';
import '../utils/weight_unit_formatter.dart';
import '../utils/app_test_keys.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_surface.dart';
import '../theme/widgets/workout_actions.dart';
import '../theme/widgets/workout_sheet_handle.dart';
import 'workout_record_badges.dart';

/// A container for session metadata and its exercises.
class _SessionData {
  final WorkoutSession session;
  final List<_CompletedWeightExercise> exercises;

  const _SessionData(this.session, this.exercises);
}

/// A completed exercise together with the database row that produced it.
class _CompletedWeightExercise {
  final int rowId;
  final WeightExercise exercise;
  final WorkoutExerciseRecordBadges badges;

  const _CompletedWeightExercise({
    required this.rowId,
    required this.exercise,
    required this.badges,
  });
}

/// Production presentation for one completed weighted exercise.
///
/// Data loading stays in [SessionCompleteSheet], while this widget can also be
/// rendered by Theme Lab with deterministic fixture data. That keeps the
/// result-card geometry, foreground policy, separators, and badge treatment in
/// one place.
class WorkoutCompletionExerciseCard extends StatelessWidget {
  const WorkoutCompletionExerciseCard({
    super.key,
    required this.exercise,
    required this.weightUnit,
    required this.badges,
  });

  final WeightExercise exercise;
  final WeightUnit weightUnit;
  final WorkoutExerciseRecordBadges badges;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildCard);

  Widget _buildCard(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panel.outlined;
    final usesClassicPresentation = context.usesClassicPresentation;
    final panelForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(context, surfaces.card)
            : colorScheme.onSurface;
    final panelSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(context, surfaces.card)
            : colorScheme.onSurfaceVariant;
    final estimatedMaxTextStyle =
        usesClassicPresentation
            ? const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)
            : theme.textTheme.bodySmall?.copyWith(
              color: panelSecondaryForeground,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            );
    final accentColor = _completionExerciseAccentColor(
      exercise.name,
      colorScheme,
    );
    final exerciseFill =
        usesInkRecipe
            ? surfaces.card
            : accentColor.withValues(alpha: surfaces.completionExerciseFill);
    final exerciseBorder =
        usesInkRecipe
            ? tonosOutlineForSurface(context, surfaces.card)
            : accentColor.withValues(alpha: surfaces.completionExerciseBorder);
    final exerciseRadius =
        usesInkRecipe ? shapes.compact : shapes.workoutSection;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final usesStackedRows = textScale > 1.15 || constraints.maxWidth < 360;
    final usesCompactNeoSpacing = usesInkRecipe && !usesStackedRows;
    final rows = <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: usesCompactNeoSpacing ? 2 : 3),
        child: Row(
          children: [
            Icon(Icons.square, size: 11, color: accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                exercise.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color:
                      usesClassicPresentation ? accentColor : panelForeground,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (badges.isFirstRecord && !usesStackedRows) ...[
              const SizedBox(width: 8),
              const FirstRecordBadge(),
            ],
          ],
        ),
      ),
      if (badges.isFirstRecord && usesStackedRows)
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: FirstRecordBadge(),
        ),
    ];

    for (var index = 0; index < exercise.sets.length; index++) {
      if (usesInkRecipe && index > 0) {
        rows.add(
          Divider(
            height: usesCompactNeoSpacing ? 4 : 8,
            thickness: 1,
            color: panelSecondaryForeground.withValues(alpha: 0.35),
          ),
        );
      }
      rows.add(
        _buildSetRow(
          context,
          set: exercise.sets[index],
          index: index,
          badges: badges.forSet(index),
          accentColor: accentColor,
          exerciseBorder: exerciseBorder,
          panelForeground: panelForeground,
          estimatedMaxTextStyle: estimatedMaxTextStyle,
          usesInkRecipe: usesInkRecipe,
          usesClassicPresentation: usesClassicPresentation,
          usesStackedRows: usesStackedRows,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: usesCompactNeoSpacing ? 6 : 8),
      padding:
          usesCompactNeoSpacing
              ? const EdgeInsets.fromLTRB(10, 4, 10, 5)
              : const EdgeInsets.fromLTRB(12, 5, 12, 7),
      decoration: BoxDecoration(
        color: exerciseFill,
        borderRadius: exerciseRadius,
        border: Border.all(
          color: exerciseBorder,
          width: usesInkRecipe ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildSetRow(
    BuildContext context, {
    required ExerciseSet set,
    required int index,
    required List<WorkoutRecordBadge> badges,
    required Color accentColor,
    required Color exerciseBorder,
    required Color panelForeground,
    required TextStyle? estimatedMaxTextStyle,
    required bool usesInkRecipe,
    required bool usesClassicPresentation,
    required bool usesStackedRows,
  }) {
    final locale = Localizations.localeOf(context);
    final surfaces = context.surfaceTokens;
    final estimatedMax = set.weight * (1 + 0.0333 * set.reps);
    final setText =
        '${WeightUnitFormatter.formatWeight(set.weight, weightUnit, locale: locale)} x ${LocalizedFormatters.number(set.reps, locale, maximumFractionDigits: 0)}';
    final estimatedText = AppLocalizations.of(context).sessionEstimatedMax(
      WeightUnitFormatter.formatWeight(
        estimatedMax,
        weightUnit,
        locale: locale,
      ),
    );
    final setForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              accentColor,
              parentSurface: surfaces.card,
            )
            : (usesClassicPresentation ? accentColor : panelForeground);
    final rowGap = usesInkRecipe && !usesStackedRows ? 6.0 : 8.0;
    final rowTopPadding = usesInkRecipe && !usesStackedRows ? 2.0 : 4.0;
    final badgeTopPadding = usesInkRecipe && !usesStackedRows ? 2.0 : 4.0;
    final indicatorSize = 22.0 * MediaQuery.textScalerOf(context).scale(1);
    final setIndicator = Container(
      constraints: BoxConstraints(
        minWidth: indicatorSize,
        minHeight: indicatorSize,
      ),
      padding: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: surfaces.completionSetFill),
        border: Border.all(
          color: usesInkRecipe ? exerciseBorder : accentColor,
          width: usesInkRecipe ? 1 : 0,
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${index + 1}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: setForeground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final estimatedMaxColumn = SizedBox(
      width: 88,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          estimatedText,
          maxLines: 1,
          textAlign: TextAlign.right,
          style: estimatedMaxTextStyle,
        ),
      ),
    );
    final resultRow = Row(
      children: [
        setIndicator,
        SizedBox(width: rowGap),
        Expanded(
          child: Text(
            setText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: panelForeground),
          ),
        ),
        if (!usesStackedRows) ...[SizedBox(width: rowGap), estimatedMaxColumn],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: rowTopPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          resultRow,
          if (usesStackedRows)
            Padding(
              padding: EdgeInsets.only(left: indicatorSize + rowGap, top: 3),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  estimatedText,
                  textAlign: TextAlign.end,
                  style: estimatedMaxTextStyle,
                ),
              ),
            ),
          if (badges.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: indicatorSize + rowGap,
                top: badgeTopPadding,
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final badge in badges)
                    WorkoutRecordBadgeChip(badge: badge),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Color _completionExerciseAccentColor(
  String exerciseName,
  ColorScheme colorScheme,
) {
  final palette = [
    colorScheme.primary,
    colorScheme.tertiary,
    colorScheme.secondary,
    colorScheme.error,
  ];
  final hash = exerciseName.codeUnits.fold<int>(
    0,
    (value, codeUnit) => value + codeUnit,
  );
  return palette[hash % palette.length];
}

/// Shared bounded shell for completion loading, error, preview, and success
/// states. Classic returns the child unchanged so its existing modal surface
/// remains the source of truth.
class WorkoutCompletionSurface extends StatelessWidget {
  const WorkoutCompletionSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!context.surfaceDecorationTokens.sheet.outlined) return child;

    final effects = context.effectTokens;
    final shadowRight =
        effects.raisedPanelShadowOffset.dx > 0
            ? effects.raisedPanelShadowOffset.dx
            : 0.0;
    final shadowBottom =
        effects.raisedPanelShadowOffset.dy > 0
            ? effects.raisedPanelShadowOffset.dy
            : 0.0;
    return Padding(
      padding: EdgeInsets.only(right: shadowRight, bottom: shadowBottom),
      child: TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: context.surfaceTokens.sheet,
        padding: padding,
        borderRadius: context.shapeTokens.sheet,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Shared loading and failure content; only the caller owns dismissal.
class WorkoutCompletionStatus extends StatelessWidget {
  const WorkoutCompletionStatus.loading({super.key})
    : isLoading = true,
      onClose = null;

  const WorkoutCompletionStatus.error({super.key, required this.onClose})
    : isLoading = false;

  final bool isLoading;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final neo = context.surfaceDecorationTokens.sheet.outlined;
    final foreground = tonosForegroundForSurface(
      context,
      context.surfaceTokens.sheet,
    );
    return WorkoutCompletionSurface(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 152),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              isLoading
                  ? SizedBox(
                    height: 152,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: neo ? foreground : null,
                      ),
                    ),
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        strings.sessionCompleteLoadError,
                        textAlign: TextAlign.center,
                        style: neo ? TextStyle(color: foreground) : null,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onClose,
                        child: Text(strings.commonClose),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

/// Prepared exercise data consumed by the shared completion presentation.
///
/// The production sheet builds these records after repository hydration, while
/// Theme Lab supplies deterministic fixtures. Keeping the data boundary here
/// prevents either caller from reimplementing the result-card presentation.
@immutable
class WorkoutCompletionExercise {
  const WorkoutCompletionExercise({
    required this.exercise,
    required this.weightUnit,
    required this.badges,
  });

  final WeightExercise exercise;
  final WeightUnit weightUnit;
  final WorkoutExerciseRecordBadges badges;
}

/// Shared presentation for a prepared workout-completion summary.
///
/// Repository access and modal routing stay outside this widget. A nullable
/// [scrollController] lets the production bottom sheet provide its draggable
/// scroll view while Theme Lab renders the same header, metrics, result cards,
/// legend, and Done action in its fixture column.
class WorkoutCompletionPresentation extends StatelessWidget {
  const WorkoutCompletionPresentation({
    super.key,
    required this.exercises,
    required this.totalSets,
    required this.duration,
    required this.volume,
    required this.onDone,
    this.doneButtonKey,
    this.scrollController,
    this.showHandle = true,
  });

  final List<WorkoutCompletionExercise> exercises;
  final int totalSets;
  final String duration;
  final String volume;
  final VoidCallback onDone;
  final Key? doneButtonKey;
  final ScrollController? scrollController;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    if (scrollController == null) {
      return _buildColumn(context);
    }

    final usesClassicPresentation = context.usesClassicPresentation;
    final scrollView = CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeaderBlock(context)),
        if (_hasRecordBadges)
          const SliverToBoxAdapter(child: WorkoutRecordBadgeLegend()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            usesClassicPresentation ? 88 : 12,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WorkoutCompletionExerciseCard(
                exercise: exercises[index].exercise,
                weightUnit: exercises[index].weightUnit,
                badges: exercises[index].badges,
              ),
              childCount: exercises.length,
            ),
          ),
        ),
      ],
    );
    final doneAction = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: WorkoutDoneAction(
          buttonKey: doneButtonKey,
          onPressed: onDone,
          label: AppLocalizations.of(context).commonDone,
        ),
      ),
    );

    if (usesClassicPresentation) {
      return Stack(
        children: [
          Positioned.fill(child: scrollView),
          Positioned(left: 0, right: 0, bottom: 0, child: doneAction),
        ],
      );
    }

    final content = Column(children: [Expanded(child: scrollView), doneAction]);
    return WorkoutCompletionSurface(padding: EdgeInsets.zero, child: content);
  }

  Widget _buildColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandle) const WorkoutSheetHandle(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSummaryHeader(context),
        ),
        const Divider(),
        if (_hasRecordBadges) const WorkoutRecordBadgeLegend(),
        for (final completed in exercises)
          WorkoutCompletionExerciseCard(
            exercise: completed.exercise,
            weightUnit: completed.weightUnit,
            badges: completed.badges,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: WorkoutDoneAction(
            buttonKey: doneButtonKey,
            onPressed: onDone,
            label: AppLocalizations.of(context).commonDone,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandle)
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Center(child: WorkoutSheetHandle()),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSummaryHeader(context),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final completionColor = semantic.completionAccent;
    final usesInkRecipe = context.surfaceDecorationTokens.sheet.outlined;
    final shapes = context.shapeTokens;
    final celebrationTextStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: 25);
    final completionHeader = Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎉', style: celebrationTextStyle),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).sessionCompleteTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color:
                    usesInkRecipe
                        ? semantic.onWorkoutContainer
                        : completionColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('🎉', style: celebrationTextStyle),
        ],
      ),
    );
    final header =
        usesInkRecipe
            ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: completionColor,
                border: Border.all(
                  color: tonosOutlineForSurface(context, completionColor),
                  width: shapes.outlineWidth,
                ),
                borderRadius: shapes.control,
              ),
              child: completionHeader,
            )
            : completionHeader;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 16),
        _buildSummaryMetricsGrid(context),
      ],
    );
  }

  Widget _buildSummaryMetricsGrid(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dataVisualization = context.dataVisualizationTokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final metrics = [
      (
        icon: Icons.fitness_center_outlined,
        label: strings.sessionMetricExercises,
        value: exercises.length.toString(),
        accent: dataVisualization.sessionExercises,
      ),
      (
        icon: Icons.format_list_numbered,
        label: strings.sessionMetricSets,
        value: totalSets.toString(),
        accent: dataVisualization.sessionSets,
      ),
      (
        icon: Icons.timer_outlined,
        label: strings.sessionMetricDuration,
        value: duration,
        accent: dataVisualization.sessionDuration,
      ),
      (
        icon: Icons.monitor_weight_outlined,
        label: strings.sessionMetricVolume,
        value: volume,
        accent: dataVisualization.sessionVolume,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            textScale >= 1.8 || constraints.maxWidth < 300
                ? 1
                : textScale > 1.15 || constraints.maxWidth < 360
                ? 2
                : 4;
        const gap = 6.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _buildSummaryMetric(
                  context,
                  icon: metric.icon,
                  label: metric.label,
                  value: metric.value,
                  accentColor: metric.accent,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.sheet.outlined;
    final preservesClassicDensity =
        context.usesClassicPresentation &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    final keepsNeoMetricLinesCompact =
        usesInkRecipe && MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    final surfaces = context.surfaceTokens;
    final metricFill =
        usesInkRecipe
            ? surfaces.card
            : accentColor.withValues(alpha: surfaces.completionMetricFill);
    final metricBorder =
        usesInkRecipe
            ? tonosOutlineForSurface(context, surfaces.card)
            : accentColor.withValues(alpha: surfaces.completionMetricBorder);
    final metricForeground =
        usesInkRecipe
            ? tonosForegroundForSurface(
              context,
              metricFill,
              parentSurface: surfaces.sheet,
            )
            : colorScheme.onSurface;
    final metricSecondaryForeground =
        usesInkRecipe
            ? tonosSecondaryForegroundForSurface(context, metricFill)
            : colorScheme.onSurfaceVariant;
    Widget metricLine(String text, TextStyle? style) {
      final line = Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.visible,
        style: style,
      );
      if (!keepsNeoMetricLinesCompact) return line;
      return SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: line,
        ),
      );
    }

    return Container(
      key: usesInkRecipe ? ValueKey('workout-completion-metric-$label') : null,
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: metricFill,
        borderRadius: shapes.control,
        border: Border.all(
          color: metricBorder,
          width: usesInkRecipe ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: usesInkRecipe ? metricForeground : accentColor,
          ),
          const SizedBox(height: 4),
          metricLine(
            value,
            theme.textTheme.labelLarge?.copyWith(
              color: metricForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          metricLine(
            label,
            theme.textTheme.labelSmall?.copyWith(
              fontSize: preservesClassicDensity ? 9 : 11,
              color: metricSecondaryForeground,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasRecordBadges => exercises.any(
    (completed) => completed.badges.setBadges.values.any(
      (setBadges) => setBadges.isNotEmpty,
    ),
  );
}

/// A bottom sheet showing session summary & details.
class SessionCompleteSheet extends StatefulWidget {
  final int sessionId;
  const SessionCompleteSheet({super.key, required this.sessionId});

  @override
  State<SessionCompleteSheet> createState() => _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends State<SessionCompleteSheet> {
  static const int _exerciseHydrationConcurrency = 6;

  AppRepository get _repo => context.read<AppRepository>();
  late final Future<_SessionData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionData>(
      future: _dataFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const WorkoutCompletionStatus.loading();
        }
        if (snap.hasError || snap.data == null) {
          return WorkoutCompletionStatus.error(
            onClose: () => Navigator.of(context).pop(),
          );
        }
        final data = snap.data!;
        return _buildContent(context, data);
      },
    );
  }

  Future<_SessionData> _loadData() async {
    // Fetch session metadata
    final session = await _repo.fetchSessionById(widget.sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }
    final badgesByExerciseId = await _repo.fetchSessionRecordBadges(
      widget.sessionId,
    );
    // Fetch detailed exercises
    final exRows = await _repo.fetchExercises(widget.sessionId);
    final loadedExercises = await _loadDetailedExercises(exRows);
    // TODO(cardio/stretch): include cardio and stretch rows here after those
    // cards are fixed, updated, and added back into the user flow.
    final exs =
        loadedExercises
            .whereType<_CompletedWeightExercise>()
            .map(
              (completed) => _CompletedWeightExercise(
                rowId: completed.rowId,
                exercise: completed.exercise,
                badges:
                    badgesByExerciseId[completed.rowId] ??
                    const WorkoutExerciseRecordBadges(isFirstRecord: false),
              ),
            )
            .toList();
    return _SessionData(session, exs);
  }

  Future<List<_CompletedWeightExercise?>> _loadDetailedExercises(
    List<Map<String, dynamic>> exerciseRows,
  ) {
    return mapWithConcurrency<Map<String, dynamic>, _CompletedWeightExercise?>(
      exerciseRows,
      maxConcurrency: _exerciseHydrationConcurrency,
      mapper: (row, _) async {
        final exerciseId = row['id'] as int;
        final exercise = await _repo.fetchDetailedExercise(exerciseId);
        if (exercise is! WeightExercise) return null;
        return _CompletedWeightExercise(
          rowId: exerciseId,
          exercise: exercise,
          badges: const WorkoutExerciseRecordBadges(isFirstRecord: false),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, _SessionData data) {
    final session = data.session;
    final exercises = data.exercises;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    // Compute total volume:
    double totalVol = 0;
    for (final completed in exercises) {
      for (var set in completed.exercise.sets) {
        totalVol += set.weight * set.reps;
      }
    }

    final totalSets = exercises.fold<int>(
      0,
      (total, completed) => total + completed.exercise.sets.length,
    );
    final durationText = formatCompletedWorkoutDuration(
      AppLocalizations.of(context),
      session.duration,
    );

    final volumeText = WeightUnitFormatter.formatVolume(
      totalVol,
      weightUnit,
      locale: Localizations.localeOf(context),
    );
    final preparedExercises = [
      for (final completed in exercises)
        WorkoutCompletionExercise(
          exercise: completed.exercise,
          weightUnit: weightUnit,
          badges: completed.badges,
        ),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      snap: true,
      shouldCloseOnMinExtent: false,
      builder: (_, scrollCtrl) {
        return WorkoutCompletionPresentation(
          exercises: preparedExercises,
          totalSets: totalSets,
          duration: durationText,
          volume: volumeText,
          scrollController: scrollCtrl,
          doneButtonKey: AppTestKeys.sessionCompleteDone,
          onDone: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
