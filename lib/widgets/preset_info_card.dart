import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../utils/async_pool.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';
import 'exercise_card.dart';
import 'focused_sets_list.dart';

/// Summary card shown at the top of preset detail screens when not editing.
///
/// It estimates workout duration with the same set/setup constants used by
/// generation, totals current planned volume, and computes focused bodypart
/// units from exercise definitions. The widget keeps its loaded summary alive
/// while scrolling so the body heatmap does not repeatedly reload.
class PresetInfoCard extends StatefulWidget {
  final List<WorkoutExercise> exercises;
  final List<CardType> cardTypes;
  final List<int?> definitionIds;

  const PresetInfoCard({
    super.key,
    required this.exercises,
    required this.cardTypes,
    required this.definitionIds,
  });

  @override
  State<PresetInfoCard> createState() => _PresetInfoCardState();
}

class _PresetInfoCardState extends State<PresetInfoCard>
    with AutomaticKeepAliveClientMixin<PresetInfoCard> {
  static const int _focusLoadConcurrency = 6;

  final _repo = AppRepository();
  late Future<_PresetInfoSummary> _summaryFuture;
  late String _signature;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    BodyHeatmap.preload();
    _signature = _buildSignature();
    _summaryFuture = _loadSummary();
  }

  @override
  void didUpdateWidget(covariant PresetInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSignature = _buildSignature();
    if (nextSignature != _signature) {
      _signature = nextSignature;
      _summaryFuture = _loadSummary();
    }
  }

  /// A cheap snapshot of the preset inputs that affect summary output.
  ///
  /// When this changes we reload the async bodypart-focus data; otherwise we
  /// keep the existing Future so scrolling and parent rebuilds stay smooth.
  String _buildSignature() {
    final parts = <String>[];
    for (var i = 0; i < widget.exercises.length; i++) {
      final exercise = widget.exercises[i];
      final type = i < widget.cardTypes.length ? widget.cardTypes[i].name : '';
      final defId =
          i < widget.definitionIds.length ? widget.definitionIds[i] : null;
      if (exercise is WeightExercise) {
        final sets = _allWeightSets(exercise);
        parts.add(
          [
            i,
            type,
            defId ?? '',
            exercise.name,
            exercise.equipment,
            for (final set in sets) '${set.weight}:${set.reps}',
          ].join('|'),
        );
      }
    }
    return parts.join('::');
  }

  /// Builds the display summary, limiting definition-analysis lookups so large
  /// presets do not flood the database with concurrent work.
  Future<_PresetInfoSummary> _loadSummary() async {
    var estimatedMinutes = 0;
    var totalVolume = 0.0;
    final bodyPartById = <int, BodyPart>{};
    final bodyPartUnitsById = <int, double>{};
    final focusLoads = <_PresetBodyPartFocusRequest>[];

    for (var i = 0; i < widget.exercises.length; i++) {
      final exercise = widget.exercises[i];

      if (exercise is WeightExercise) {
        estimatedMinutes += SessionSpec.defaultSetupMinutesPerExercise;
        final sets = _allWeightSets(exercise);
        estimatedMinutes += sets.length * SessionSpec.defaultMinutesPerSet;
        for (final set in sets) {
          totalVolume += set.weight * set.reps;
        }

        if (sets.isNotEmpty) {
          focusLoads.add(
            _PresetBodyPartFocusRequest(
              index: i,
              exercise: exercise,
              setCount: sets.length,
            ),
          );
        }
      }
      // TODO(cardio/stretch): include cardio and stretch in plan summaries
      // after their cards are fixed, updated, and added back into the app.
    }

    final focusRows = await _loadBodyPartFocuses(focusLoads);
    for (final focus in focusRows.whereType<_PresetBodyPartFocus>()) {
      focus.unitsPerSet.forEach((bodyPart, units) {
        if (units <= 0.0) return;
        bodyPartById[bodyPart.id] = bodyPart;
        bodyPartUnitsById[bodyPart.id] =
            (bodyPartUnitsById[bodyPart.id] ?? 0.0) + units * focus.setCount;
      });
    }

    final bodyPartHits =
        bodyPartUnitsById.entries
            .map(
              (entry) => FocusedSetHit(
                bodyPart: bodyPartById[entry.key]!,
                units: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _PresetInfoSummary(
      estimatedMinutes: estimatedMinutes,
      totalVolume: totalVolume,
      bodyPartHits: bodyPartHits,
      frequencyMap: bodyPartFrequencyMapFromNames({
        for (final hit in bodyPartHits) hit.bodyPart.name: hit.units,
      }),
    );
  }

  Future<int?> _definitionIdFor(int index, WeightExercise exercise) async {
    if (index < widget.definitionIds.length) {
      final defId = widget.definitionIds[index];
      if (defId != null) return defId;
    }

    try {
      return await _repo.findExerciseDefinitionId(
        exercise.name,
        exercise.equipment,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_PresetBodyPartFocus?> _loadBodyPartFocus({
    required int index,
    required WeightExercise exercise,
    required int setCount,
  }) async {
    final defId = await _definitionIdFor(index, exercise);
    if (defId == null) return null;

    final unitsPerSet = await _repo.computeBodyPartPercents(defId);
    if (unitsPerSet.isEmpty) return null;

    return _PresetBodyPartFocus(unitsPerSet: unitsPerSet, setCount: setCount);
  }

  Future<List<_PresetBodyPartFocus?>> _loadBodyPartFocuses(
    List<_PresetBodyPartFocusRequest> requests,
  ) {
    return mapWithConcurrency<
      _PresetBodyPartFocusRequest,
      _PresetBodyPartFocus?
    >(
      requests,
      maxConcurrency: _focusLoadConcurrency,
      mapper:
          (request, _) => _loadBodyPartFocus(
            index: request.index,
            exercise: request.exercise,
            setCount: request.setCount,
          ),
    );
  }

  static List<ExerciseSet> _allWeightSets(WeightExercise exercise) {
    return [
      ...exercise.sets,
      for (final childSets in exercise.changeSets.values) ...childSets,
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colors = context.colors;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;

    return FutureBuilder<_PresetInfoSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                summary == null
                    ? const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PresetMetricTile(
                                icon: Icons.schedule,
                                value: _formatMinutes(summary.estimatedMinutes),
                                label: 'Estimated time',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PresetMetricTile(
                                icon: Icons.fitness_center,
                                value: WeightUnitFormatter.formatVolume(
                                  summary.totalVolume,
                                  weightUnit,
                                ),
                                label: 'Total volume',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final gap = maxWidth < 330 ? 10.0 : 16.0;
                            final heatmapWidth =
                                (maxWidth * 0.46)
                                    .clamp(124.0, 180.0)
                                    .toDouble();
                            final heatmapSize =
                                heatmapWidth.clamp(118.0, 180.0).toDouble();
                            final heatmap = SizedBox(
                              width: heatmapWidth,
                              height: heatmapSize,
                              child: Center(
                                child: BodyHeatmap(
                                  frequencyMap: summary.frequencyMap,
                                  lowColor: colors.historySummaryHeatmapLow!,
                                  highColor: colors.historySummaryHeatmapHigh!,
                                  width: heatmapSize,
                                  height: heatmapSize,
                                ),
                              ),
                            );
                            final focusList = FocusedSetsList(
                              hits: summary.bodyPartHits,
                              emptyMessage: 'No focus data yet.',
                            );

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                heatmap,
                                SizedBox(width: gap),
                                Expanded(child: focusList),
                              ],
                            );
                          },
                        ),
                        if (summary.bodyPartHits.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Add weight exercises with bodypart data to preview preset focus.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
          ),
        );
      },
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

class _PresetMetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PresetMetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 150;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: colors.infoCardBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.infoCardValueText,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.infoCardLabelText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PresetInfoSummary {
  final int estimatedMinutes;
  final double totalVolume;
  final List<FocusedSetHit> bodyPartHits;
  final Map<String, double> frequencyMap;

  const _PresetInfoSummary({
    required this.estimatedMinutes,
    required this.totalVolume,
    required this.bodyPartHits,
    required this.frequencyMap,
  });
}

class _PresetBodyPartFocus {
  final Map<BodyPart, double> unitsPerSet;
  final int setCount;

  const _PresetBodyPartFocus({
    required this.unitsPerSet,
    required this.setCount,
  });
}

class _PresetBodyPartFocusRequest {
  final int index;
  final WeightExercise exercise;
  final int setCount;

  const _PresetBodyPartFocusRequest({
    required this.index,
    required this.exercise,
    required this.setCount,
  });
}
