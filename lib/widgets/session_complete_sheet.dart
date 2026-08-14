// File: lib/widgets/session_complete_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../utils/weight_unit_formatter.dart';
import '../utils/app_test_keys.dart';
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
          return SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                AppLocalizations.of(context).sessionCompleteLoadError,
              ),
            ),
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
    final badgesFuture = _repo.fetchSessionRecordBadges(widget.sessionId);
    // Fetch detailed exercises
    final exRows = await _repo.fetchExercises(widget.sessionId);
    final loadedExercises = await _loadDetailedExercises(exRows);
    final badgesByExerciseId = await badgesFuture;
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
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    const completionColor = Color(0xFF7CFF8B);
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
    final hasSetRecordBadges = exercises.any(
      (completed) => completed.badges.setBadges.values.any(
        (setBadges) => setBadges.isNotEmpty,
      ),
    );
    final durationText = formatCompletedWorkoutDuration(
      AppLocalizations.of(context),
      session.duration,
    );

    final volumeText = WeightUnitFormatter.formatVolume(totalVol, weightUnit);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      snap: true,
      shouldCloseOnMinExtent: false,
      builder:
          (ctx, scrollCtrl) => Stack(
            children: [
              CustomScrollView(
                controller: scrollCtrl,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                        // HEADER
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🎉',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        strings.sessionCompleteTitle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: completionColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '🎉',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryMetricsGrid(
                                context,
                                exercises: exercises.length,
                                sets: totalSets,
                                duration: durationText,
                                volume: volumeText,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  if (hasSetRecordBadges)
                    SliverToBoxAdapter(child: _buildBadgeLegend()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, index) {
                        final completed = exercises[index];
                        return _buildWeightSection(
                          completed.exercise,
                          weightUnit,
                          badges: completed.badges,
                        );
                      }, childCount: exercises.length),
                    ),
                  ),
                ],
              ),
              // DONE BUTTON
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton.icon(
                      key: AppTestKeys.sessionCompleteDone,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(strings.commonDone),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBadgeLegend() {
    return const WorkoutRecordBadgeLegend();
  }

  Widget _buildSummaryMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool compact,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 70 : 76),
      padding: EdgeInsets.all(compact ? 7 : 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: accentColor),
          SizedBox(height: compact ? 4 : 6),
          usesLocalizedLayout
              ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: (compact
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.titleSmall)
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              )
              : Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact
                        ? theme.textTheme.labelLarge
                        : theme.textTheme.titleSmall)
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: usesLocalizedLayout ? 2 : 1,
            overflow: usesLocalizedLayout ? null : TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: compact ? 9 : null,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetricsGrid(
    BuildContext context, {
    required int exercises,
    required int sets,
    required String duration,
    required String volume,
  }) {
    final strings = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final usesLocalizedLayout =
        Localizations.localeOf(context).languageCode != 'en';
    final metrics = [
      (
        icon: Icons.fitness_center_outlined,
        label: strings.sessionMetricExercises,
        value: '$exercises',
        accent: const Color(0xFF64B5F6),
      ),
      (
        icon: Icons.format_list_numbered,
        label: strings.sessionMetricSets,
        value: '$sets',
        accent: const Color(0xFF81C784),
      ),
      (
        icon: Icons.timer_outlined,
        label: strings.sessionMetricDuration,
        value: duration,
        accent: const Color(0xFFFFD54F),
      ),
      (
        icon: Icons.monitor_weight_outlined,
        label: strings.sessionMetricVolume,
        value: volume,
        accent: const Color(0xFFF48FB1),
      ),
    ];

    if (!usesLocalizedLayout) {
      return Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            if (index > 0) const SizedBox(width: 6),
            Expanded(
              child: _buildSummaryMetric(
                context,
                icon: metrics[index].icon,
                label: metrics[index].label,
                value: metrics[index].value,
                compact: true,
                accentColor: metrics[index].accent,
              ),
            ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = textScale > 1.15 || constraints.maxWidth < 360 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent:
                columns == 4
                    ? 78
                    : textScale > 1.5
                    ? 98
                    : 82,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildSummaryMetric(
              context,
              icon: metric.icon,
              label: metric.label,
              value: metric.value,
              compact: true,
              accentColor: metric.accent,
            );
          },
        );
      },
    );
  }

  Widget _buildWeightSection(
    WeightExercise ex,
    WeightUnit weightUnit, {
    required WorkoutExerciseRecordBadges badges,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _exerciseAccentColor(ex.name, colorScheme);
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            Icon(Icons.square, size: 11, color: accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ex.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (badges.isFirstRecord) ...[
              const SizedBox(width: 8),
              const FirstRecordBadge(),
            ],
          ],
        ),
      ),
    ];
    for (var i = 0; i < ex.sets.length; i++) {
      final s = ex.sets[i];
      final setBadges = badges.forSet(i);
      final erm = s.weight * (1 + 0.0333 * s.reps);
      final setText =
          '${WeightUnitFormatter.formatWeight(s.weight, weightUnit)} x ${s.reps}';
      final ermText = AppLocalizations.of(
        context,
      ).sessionEstimatedMax(WeightUnitFormatter.formatWeight(erm, weightUnit));
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 6 : 7),
          child:
              isSpanish
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              setText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 88,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                ermText,
                                maxLines: 1,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (setBadges.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top: 4),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.start,
                            children: [
                              for (final badge in setBadges)
                                WorkoutRecordBadgeChip(badge: badge),
                            ],
                          ),
                        ),
                    ],
                  )
                  : Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (setBadges.isEmpty)
                        Expanded(
                          child: Text(
                            setText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else ...[
                        Expanded(
                          flex: 2,
                          child: Text(
                            setText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    var badgeIndex = 0;
                                    badgeIndex < setBadges.length;
                                    badgeIndex++
                                  ) ...[
                                    if (badgeIndex > 0)
                                      const SizedBox(width: 4),
                                    WorkoutRecordBadgeChip(
                                      badge: setBadges[badgeIndex],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 88,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            ermText,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.52)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Color _exerciseAccentColor(String exerciseName, ColorScheme colorScheme) {
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
}
