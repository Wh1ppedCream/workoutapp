import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/expressive_planning_tokens.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_surface.dart';
import '../utils/async_pool.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';
import 'focused_sets_list.dart';

/// Summary card shown at the top of preset detail screens when not editing.
///
/// It estimates workout duration with the same set/setup constants used by
/// generation, totals current planned volume, and computes focused bodypart
/// units from exercise definitions. The widget keeps its loaded summary alive
/// while scrolling so the body heatmap does not repeatedly reload.
class PresetInfoCard extends StatefulWidget {
  final AppRepository repository;
  final List<WorkoutExercise> exercises;
  final List<CardType> cardTypes;
  final List<int?> definitionIds;
  final bool compactExpressive;

  const PresetInfoCard({
    super.key,
    required this.repository,
    required this.exercises,
    required this.cardTypes,
    required this.definitionIds,
    this.compactExpressive = false,
  });

  @override
  State<PresetInfoCard> createState() => _PresetInfoCardState();
}

class _PresetInfoCardState extends State<PresetInfoCard>
    with AutomaticKeepAliveClientMixin<PresetInfoCard> {
  static const int _focusLoadConcurrency = 6;

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
      final defId = i < widget.definitionIds.length
          ? widget.definitionIds[i]
          : null;
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
      return await widget.repository.findExerciseDefinitionId(
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

    final unitsPerSet = await widget.repository.computeBodyPartPercents(defId);
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
      mapper: (request, _) => _loadBodyPartFocus(
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
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final compactExpressive =
        widget.compactExpressive && context.usesExpressivePresentation;

    return FutureBuilder<_PresetInfoSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final strings = AppLocalizations.of(context);

        if (compactExpressive) {
          final planning = AppExpressivePlanningTokens.maybeOf(context)!;
          return TonosSurface(
            key: const ValueKey('expressive-preset-summary'),
            variant: TonosSurfaceVariant.card,
            color: planning.planFocalSurface,
            borderRadius: planning.focalShape,
            outlined: false,
            elevation: 0,
            padding: const EdgeInsets.all(14),
            child: summary == null
                ? SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: planning.planAccent,
                      ),
                    ),
                  )
                : _ExpressivePresetInfoContent(
                    summary: summary,
                    time: _formatMinutes(summary.estimatedMinutes, strings),
                    volume: WeightUnitFormatter.formatVolume(
                      summary.totalVolume,
                      weightUnit,
                      locale: Localizations.localeOf(context),
                    ),
                  ),
          );
        }

        final content = Padding(
          padding: EdgeInsets.all(compactExpressive ? 12 : 16),
          child: summary == null
              ? SizedBox(
                  height: compactExpressive ? 180 : 220,
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
                              strings,
                            ),
                            label: strings.presetEstimatedTime,
                            compactExpressive: compactExpressive,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PresetMetricTile(
                            icon: Icons.fitness_center,
                            value: WeightUnitFormatter.formatVolume(
                              summary.totalVolume,
                              weightUnit,
                              locale: Localizations.localeOf(context),
                            ),
                            label: strings.logbookTotalVolume,
                            compactExpressive: compactExpressive,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compactExpressive ? 10 : 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final gap = maxWidth < 330 ? 10.0 : 16.0;
                        final heatmapWidth = compactExpressive
                            ? (maxWidth * 0.40).clamp(112.0, 154.0).toDouble()
                            : (maxWidth * 0.46).clamp(124.0, 180.0).toDouble();
                        final heatmapSize = heatmapWidth
                            .clamp(118.0, 180.0)
                            .toDouble();
                        final heatmap = SizedBox(
                          width: heatmapWidth,
                          height: heatmapSize,
                          child: Center(
                            child: BodyHeatmap(
                              frequencyMap: summary.frequencyMap,
                              lowColor: tonosHeatmapLowForSurface(
                                context,
                                surfaces.panelRaised,
                              ),
                              highColor: tonosHeatmapHighForSurface(
                                context,
                                surfaces.panelRaised,
                              ),
                              width: heatmapSize,
                              height: heatmapSize,
                            ),
                          ),
                        );
                        final focusList = FocusedSetsList(
                          hits: summary.bodyPartHits,
                          emptyMessage: strings.presetNoFocusData,
                          compact: compactExpressive,
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
                        strings.presetFocusPreviewHelp,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
        );

        if (context.usesNeoPresentation) {
          return TonosSurface(
            variant: TonosSurfaceVariant.panelRaised,
            margin: const EdgeInsets.only(bottom: 16),
            borderRadius: shapes.card,
            clipBehavior: Clip.antiAlias,
            child: content,
          );
        }

        return Card(
          margin: EdgeInsets.only(bottom: compactExpressive ? 0 : 16),
          child: content,
        );
      },
    );
  }

  static String _formatMinutes(int minutes, AppLocalizations strings) {
    if (minutes < 60) return strings.durationMinutesCompact(minutes);
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return strings.durationHoursCompact(hours);
    return strings.durationHoursMinutesCompact(hours, mins);
  }
}

class _ExpressivePresetInfoContent extends StatelessWidget {
  const _ExpressivePresetInfoContent({
    required this.summary,
    required this.time,
    required this.volume,
  });

  final _PresetInfoSummary summary;
  final String time;
  final String volume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planning = AppExpressivePlanningTokens.maybeOf(context)!;
    final dark = theme.brightness == Brightness.dark;
    final tokens =
        theme.extension<AppExpressiveTrainTokens>() ??
        (dark ? AppExpressiveTrainTokens.dark : AppExpressiveTrainTokens.light);
    final strings = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final focusTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onSurface: tokens.focusInsetForeground,
        onSurfaceVariant: tokens.focusInsetForeground,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: tokens.focusInsetForeground,
        displayColor: tokens.focusInsetForeground,
      ),
      progressIndicatorTheme: theme.progressIndicatorTheme.copyWith(
        color: tokens.focusWarm,
        linearTrackColor: tokens.focusInsetForeground.withValues(alpha: 0.16),
      ),
    );
    final focusList = Theme(
      data: focusTheme,
      child: Material(
        key: const ValueKey('expressive-preset-focused-sets'),
        color: tokens.focusInset,
        shape: const RoundedRectangleBorder(
          borderRadius: ExpressiveTrainShapes.focusInset,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusedSetsList(
                hits: summary.bodyPartHits,
                emptyMessage: strings.presetNoFocusData,
                titleWeight: FontWeight.w800,
                compact: true,
                roundUnits: true,
                rowSpacing: 3,
              ),
              if (summary.bodyPartHits.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  strings.presetFocusPreviewHelp,
                  style: focusTheme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final timeTile = _ExpressivePresetMetricTile(
              key: const ValueKey('expressive-preset-time'),
              icon: Icons.schedule,
              label: strings.presetEstimatedTime,
              value: time,
              surface: planning.equipmentSurface,
              foreground: planning.equipmentForeground,
            );
            final volumeTile = _ExpressivePresetMetricTile(
              key: const ValueKey('expressive-preset-volume'),
              icon: Icons.fitness_center,
              label: strings.logbookTotalVolume,
              value: volume,
              surface: planning.actionSecondary,
              foreground: planning.actionSecondaryForeground,
            );
            if (textScale >= 1.5 || constraints.maxWidth < 240) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [timeTile, const SizedBox(height: 10), volumeTile],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: timeTile),
                  const SizedBox(width: 10),
                  Expanded(child: volumeTile),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = textScale >= 1.5 || constraints.maxWidth < 240;
            final heatmapSize = stacked
                ? constraints.maxWidth.clamp(132.0, 164.0).toDouble()
                : (constraints.maxWidth - 10) / 2;
            final heatmapSurface = dark
                ? tokens.focusInset
                : Color.lerp(planning.equipmentSurface, Colors.white, 0.35)!;
            final heatmap = Container(
              key: const ValueKey('expressive-preset-heatmap'),
              width: heatmapSize,
              height: stacked ? heatmapSize : null,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: heatmapSurface,
                borderRadius: ExpressiveTrainShapes.focusInset,
              ),
              child: Center(
                child: BodyHeatmap(
                  frequencyMap: summary.frequencyMap,
                  lowColor: tonosHeatmapLowForSurface(context, heatmapSurface),
                  highColor: tonosHeatmapHighForSurface(
                    context,
                    heatmapSurface,
                  ),
                  width: heatmapSize - 12,
                  height: heatmapSize - 12,
                ),
              ),
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: heatmap),
                  const SizedBox(height: 12),
                  focusList,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: heatmap),
                  const SizedBox(width: 10),
                  Expanded(child: focusList),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExpressivePresetMetricTile extends StatelessWidget {
  const _ExpressivePresetMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.surface,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color surface;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: ExpressiveTrainShapes.focusInset,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
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

class _PresetMetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool compactExpressive;

  const _PresetMetricTile({
    required this.icon,
    required this.value,
    required this.label,
    this.compactExpressive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final semantic = context.semanticColors;
    final usesInkRecipe = context.usesNeoPresentation;
    final outlined = context.surfaceDecorationTokens.card.outlined;
    final foreground = usesInkRecipe
        ? tonosForegroundForSurface(context, surfaces.card)
        : semantic.strongContent;
    final secondaryForeground = semantic.mutedContent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 150;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compactExpressive
                ? 8
                : compact
                ? 10
                : 14,
            vertical: compactExpressive
                ? 8
                : compact
                ? 10
                : 12,
          ),
          decoration: BoxDecoration(
            color: surfaces.card,
            borderRadius: shapes.metric,
            border: outlined
                ? Border.all(
                    color: tonosOutlineForSurface(context, surfaces.card),
                    width: shapes.outlineWidth,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: compactExpressive
                    ? 17
                    : compact
                    ? 18
                    : 20,
                color: usesInkRecipe
                    ? tonosForegroundForSurface(context, surfaces.card)
                    : theme.colorScheme.primary,
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
                        color: foreground,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryForeground,
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
