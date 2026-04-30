import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import 'body_heatmap.dart';
import 'exercise_card.dart';

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
      } else if (exercise is CardioExercise) {
        parts.add(
          [
            i,
            type,
            exercise.name,
            exercise.cardioName,
            exercise.plannedMinutes,
            exercise.elapsedSeconds,
          ].join('|'),
        );
      } else if (exercise is StretchExercise) {
        parts.add(
          [
            i,
            type,
            exercise.name,
            exercise.stretchInstances.length,
          ].join('|'),
        );
      }
    }
    return parts.join('::');
  }

  Future<_PresetInfoSummary> _loadSummary() async {
    var estimatedMinutes = 0;
    var totalVolume = 0.0;
    final bodyPartById = <int, BodyPart>{};
    final bodyPartUnitsById = <int, double>{};

    for (var i = 0; i < widget.exercises.length; i++) {
      final exercise = widget.exercises[i];
      estimatedMinutes += SessionSpec.defaultSetupMinutesPerExercise;

      if (exercise is WeightExercise) {
        final sets = _allWeightSets(exercise);
        estimatedMinutes += sets.length * SessionSpec.defaultMinutesPerSet;
        for (final set in sets) {
          totalVolume += set.weight * set.reps;
        }

        final defId = await _definitionIdFor(i, exercise);
        if (defId == null || sets.isEmpty) continue;

        final unitsPerSet = await _repo.computeBodyPartPercents(defId);
        unitsPerSet.forEach((bodyPart, units) {
          if (units <= 0.0) return;
          bodyPartById[bodyPart.id] = bodyPart;
          bodyPartUnitsById[bodyPart.id] =
              (bodyPartUnitsById[bodyPart.id] ?? 0.0) + units * sets.length;
        });
      } else if (exercise is CardioExercise) {
        estimatedMinutes += exercise.plannedMinutes;
      } else if (exercise is StretchExercise) {
        estimatedMinutes +=
            exercise.stretchInstances.length * SessionSpec.defaultMinutesPerSet;
      }
    }

    final bodyPartHits = bodyPartUnitsById.entries
        .map(
          (entry) => _BodyPartHit(
            bodyPart: bodyPartById[entry.key]!,
            units: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.units.compareTo(a.units));

    final maxUnits = bodyPartHits.fold<double>(
      0.0,
      (max, hit) => hit.units > max ? hit.units : max,
    );
    final frequencyMap = <String, double>{};
    for (final hit in bodyPartHits) {
      final ids = bodyPartNameToSvgIds[hit.bodyPart.name] ?? const <String>[];
      final normalized = maxUnits == 0.0 ? 0.0 : hit.units / maxUnits;
      for (final id in ids) {
        frequencyMap[id] = normalized;
      }
    }

    return _PresetInfoSummary(
      estimatedMinutes: estimatedMinutes,
      totalVolume: totalVolume,
      bodyPartHits: bodyPartHits,
      frequencyMap: frequencyMap,
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

    return FutureBuilder<_PresetInfoSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: summary == null
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
                              value: _formatMinutes(
                                summary.estimatedMinutes,
                              ),
                              label: 'Estimated time',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PresetMetricTile(
                              icon: Icons.fitness_center,
                              value: _formatVolume(summary.totalVolume),
                              label: 'Total volume',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 340;
                          final heatmap = SizedBox(
                            height: compact ? 180 : 190,
                            child: BodyHeatmap(
                              frequencyMap: summary.frequencyMap,
                              lowColor: colors.historySummaryHeatmapLow!,
                              highColor: colors.historySummaryHeatmapHigh!,
                              width: compact ? 170 : 180,
                              height: compact ? 170 : 180,
                            ),
                          );
                          final focusList = _PresetFocusList(
                            hits: summary.bodyPartHits,
                          );

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                heatmap,
                                const SizedBox(height: 12),
                                focusList,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: heatmap),
                              const SizedBox(width: 16),
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

  static String _formatVolume(double volume) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}k lbs';
    return '${volume.round()} lbs';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.infoCardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.infoCardValueText,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.infoCardLabelText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetFocusList extends StatelessWidget {
  final List<_BodyPartHit> hits;

  const _PresetFocusList({
    required this.hits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxUnits = hits.fold<double>(
      0.0,
      (max, hit) => hit.units > max ? hit.units : max,
    );
    final visibleHits = hits.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Focused Sets',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (visibleHits.isEmpty)
          Text('No focus data yet.', style: theme.textTheme.bodySmall)
        else
          for (final hit in visibleHits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FocusRow(hit: hit, maxUnits: maxUnits),
            ),
      ],
    );
  }
}

class _FocusRow extends StatelessWidget {
  final _BodyPartHit hit;
  final double maxUnits;

  const _FocusRow({
    required this.hit,
    required this.maxUnits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = maxUnits == 0.0 ? 0.0 : hit.units / maxUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(hit.bodyPart.name)),
            Text(
              _formatUnits(hit.units),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value.clamp(0.0, 1.0).toDouble(),
          ),
        ),
      ],
    );
  }

  static String _formatUnits(double units) {
    return units.floor().toString();
  }
}

class _PresetInfoSummary {
  final int estimatedMinutes;
  final double totalVolume;
  final List<_BodyPartHit> bodyPartHits;
  final Map<String, double> frequencyMap;

  const _PresetInfoSummary({
    required this.estimatedMinutes,
    required this.totalVolume,
    required this.bodyPartHits,
    required this.frequencyMap,
  });
}

class _BodyPartHit {
  final BodyPart bodyPart;
  final double units;

  const _BodyPartHit({
    required this.bodyPart,
    required this.units,
  });
}
