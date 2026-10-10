// File: lib/screens/exercise/definitions_by_bodypart_page.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/catalog_entity_localizer.dart';
import '../../services/tutorial_state_store.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import 'definitions_by_muscle_page.dart';

/// Bodypart detail page for the exercise focus library.
///
/// Shows linked exercises, associated muscles, recent seven-day set units, and
/// editable recommended set bounds for one bodypart.
class DefinitionsByBodyPartPage extends StatefulWidget {
  final BodyPart bodyPart;
  final bool expressiveCatalogPresentation;

  const DefinitionsByBodyPartPage({
    super.key,
    required this.bodyPart,
    this.expressiveCatalogPresentation = false,
  });

  @override
  State<DefinitionsByBodyPartPage> createState() =>
      _DefinitionsByBodyPartPageState();
}

class _DefinitionsByBodyPartPageState extends State<DefinitionsByBodyPartPage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _headerTutorialKey = GlobalKey(debugLabel: 'bodypart_detail_header');
  final _exerciseListTutorialKey = GlobalKey(
    debugLabel: 'bodypart_detail_exercise_list',
  );
  late Future<_BodyPartPageData> _dataFuture;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  /// Loads all page data together so the header and exercise list stay
  /// consistent with the same snapshot of definitions and set totals.
  Future<_BodyPartPageData> _loadData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    final definitionsFuture = _repo.lookupDefsDetailed();
    final musclesFuture = _repo.fetchAllMuscles();
    final linksFuture = _repo.fetchMusclesForBodyPart(widget.bodyPart.id);
    final recentSetsFuture = _repo.fetchAllBodyPartSetsOverTimeRange(
      start: start,
      end: now,
    );
    final boundsFuture = _repo.fetchBodyPartVolumeBounds(widget.bodyPart.id);

    final definitions =
        (await definitionsFuture)
            .where(
              (def) =>
                  def.bodyParts.any((part) => part.id == widget.bodyPart.id),
            )
            .toList();
    final muscles = await musclesFuture;
    final links = await linksFuture;
    final recentSets = await recentSetsFuture;
    final bounds = await boundsFuture;

    final muscleById = {for (final muscle in muscles) muscle.id: muscle};
    final linkedMuscles =
        links
            .map((link) => muscleById[link.muscleId])
            .whereType<Muscle>()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    definitions.sort((a, b) => a.name.compareTo(b.name));

    return _BodyPartPageData(
      definitions: definitions,
      muscles: linkedMuscles,
      recentSetUnits: _setUnitsForBodyPart(recentSets, widget.bodyPart.id),
      volumeBounds: bounds,
    );
  }

  double _setUnitsForBodyPart(Map<BodyPart, double> rows, int bodyPartId) {
    return rows.entries
        .where((entry) => entry.key.id == bodyPartId)
        .fold<double>(0.0, (sum, entry) => sum + entry.value);
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      final strings = AppLocalizations.of(context);
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.bodypartDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.accessibility_new,
            title: strings.anatomyTutorialDetailTitle,
            body: strings.anatomyTutorialBodypartDetailBody,
          ),
          GuidedTutorialStep(
            targetKey: _exerciseListTutorialKey,
            icon: Icons.fitness_center,
            title: strings.anatomyTutorialLinkedExercisesTitle,
            body: strings.anatomyTutorialBodypartExercisesBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive =
        widget.expressiveCatalogPresentation &&
        context.usesExpressivePresentation;
    final destinationTokens =
        expressive
            ? AppExpressiveDestinationTokens.forFamily(
              AppExpressiveDestinationFamily.catalog,
              Theme.of(context).brightness,
            )
            : null;
    final page = Scaffold(
      backgroundColor: expressive ? destinationTokens?.pageCanvas : null,
      appBar: AppBar(
        title: Text(
          strings.anatomyTargetExercises(
            localizedBodyPartName(context, widget.bodyPart.name),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<_BodyPartPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.anatomyBodypartLoadFailed));
          }

          final data = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _queueTutorial();
          });
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: data.definitions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return KeyedSubtree(
                  key: _headerTutorialKey,
                  child: _BodyPartHeader(
                    bodyPart: widget.bodyPart,
                    data: data,
                    expressive: expressive,
                    onEditRecommended: () => _editRecommendedSets(data),
                    onMuscleTap: (muscle) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            final page = DefinitionsByMusclePage(
                              muscle: muscle,
                              sourceBodyPart: widget.bodyPart,
                              expressiveCatalogPresentation: expressive,
                            );
                            return expressive
                                ? AppExpressiveDestinationTheme(
                                  family:
                                      AppExpressiveDestinationFamily.catalog,
                                  child: page,
                                )
                                : page;
                          },
                        ),
                      );
                    },
                  ),
                );
              }

              final definition = data.definitions[index - 1];
              return KeyedSubtree(
                key: index == 1 ? _exerciseListTutorialKey : null,
                child: _ExerciseDefinitionTile(
                  definition: definition,
                  expressive: expressive,
                ),
              );
            },
          );
        },
      ),
    );
    return expressive
        ? AppExpressiveDestinationTheme(
          family: AppExpressiveDestinationFamily.catalog,
          child: page,
        )
        : page;
  }

  Future<void> _editRecommendedSets(_BodyPartPageData data) async {
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: localizedBodyPartName(context, widget.bodyPart.name),
      targetId: widget.bodyPart.id,
      currentBounds: data.volumeBounds,
    );
    if (updatedBounds == null) return;

    try {
      await _repo.setBodyPartVolumeBounds(widget.bodyPart.id, updatedBounds);
      if (!mounted) return;

      setState(() {
        _dataFuture = _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).anatomyRecommendedSetsUpdated(
              localizedBodyPartName(context, widget.bodyPart.name),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).anatomySaveFailed)),
      );
    }
  }
}

class _BodyPartHeader extends StatelessWidget {
  final BodyPart bodyPart;
  final _BodyPartPageData data;
  final bool expressive;
  final VoidCallback onEditRecommended;
  final ValueChanged<Muscle> onMuscleTap;

  const _BodyPartHeader({
    required this.bodyPart,
    required this.data,
    required this.expressive,
    required this.onEditRecommended,
    required this.onMuscleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destinationTokens = theme.extension<AppExpressiveDestinationTokens>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TonosThemeReadyCard(
            color:
                expressive
                    ? destinationTokens?.surfaceTertiary ??
                        theme.colorScheme.surfaceContainerLow
                    : null,
            elevation: expressive ? 0 : null,
            shape:
                expressive
                    ? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(28),
                        bottomLeft: Radius.circular(12),
                      ),
                    )
                    : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedBodyPartName(context, bodyPart.name),
                    maxLines: expressive ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color:
                          expressive
                              ? destinationTokens?.onSurfaceTertiary
                              : null,
                      fontWeight: expressive ? FontWeight.w700 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).anatomyLinkedExerciseCount(data.definitions.length),
                    style:
                        expressive
                            ? theme.textTheme.bodyMedium?.copyWith(
                              color: destinationTokens?.onSurfaceTertiary,
                            )
                            : null,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final gap = maxWidth < 330 ? 10.0 : 16.0;
                      final heatmapBox =
                          (maxWidth * 0.56).clamp(134.0, 178.0).toDouble();
                      final heatmapSize =
                          heatmapBox.clamp(128.0, 178.0).toDouble();

                      final heatmap = SizedBox(
                        width: heatmapBox,
                        height: heatmapBox,
                        child: Center(
                          child: SingleBodyPartHeatmap(
                            bodyPartName: bodyPart.name,
                            size: heatmapSize,
                            padding: 2,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                      final strings = AppLocalizations.of(context);
                      final recentValue = strings.anatomySetUnits(
                        LocalizedFormatters.number(
                          data.recentSetUnits,
                          Localizations.localeOf(context),
                          minimumFractionDigits: 1,
                          maximumFractionDigits: 1,
                        ),
                      );
                      final recommendedValue = _rangeLabel(
                        strings,
                        data.volumeBounds,
                        Localizations.localeOf(context),
                      );
                      if (expressive) {
                        final metrics = _BodyPartExpressiveMetricBays(
                          recentLabel: strings.anatomyDoneLastSevenDays,
                          recentValue: recentValue,
                          recommendedLabel: strings.anatomyRecommended,
                          recommendedValue: recommendedValue,
                          onEdit: onEditRecommended,
                        );
                        final stack =
                            maxWidth < 380 ||
                            MediaQuery.textScalerOf(context).scale(16) > 19;
                        if (stack) {
                          return Column(
                            children: [
                              heatmap,
                              const SizedBox(height: 12),
                              metrics,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            heatmap,
                            SizedBox(width: gap),
                            Expanded(child: metrics),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heatmap,
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SetStatChip(
                                  label: strings.anatomyDoneLastSevenDays,
                                  value: recentValue,
                                ),
                                const SizedBox(height: 10),
                                SetStatChip(
                                  label: strings.anatomyRecommended,
                                  value: recommendedValue,
                                  onEdit: onEditRecommended,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).anatomyAssociatedMuscles,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: expressive ? FontWeight.w700 : null,
              color:
                  expressive
                      ? destinationTokens?.actionPrimary ??
                          theme.colorScheme.primary
                      : null,
            ),
          ),
          const SizedBox(height: 8),
          if (data.muscles.isEmpty)
            Text(
              AppLocalizations.of(context).anatomyNoMuscleLinks,
              style: theme.textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  data.muscles
                      .map(
                        (muscle) => ActionChip(
                          label: LocalizedCatalogEntityName(
                            entity: CatalogEntityDisplayName(
                              catalogId: muscle.catalogId,
                              canonicalName: muscle.name,
                            ),
                            maxLines: expressive ? null : 1,
                            overflow: expressive ? null : TextOverflow.ellipsis,
                          ),
                          avatar: const Icon(Icons.fitness_center, size: 18),
                          onPressed: () => onMuscleTap(muscle),
                        ),
                      )
                      .toList(),
            ),
          const Divider(height: 32),
          Text(
            AppLocalizations.of(context).anatomyExercises,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: expressive ? FontWeight.w700 : null,
              color:
                  expressive
                      ? destinationTokens?.actionPrimary ??
                          theme.colorScheme.primary
                      : null,
            ),
          ),
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).anatomyNoExercisesFor(
                localizedBodyPartName(context, bodyPart.name),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _rangeLabel(
    AppLocalizations strings,
    VolumeBoundaries? bounds,
    Locale locale,
  ) {
    if (bounds == null) return strings.anatomyNotSet;
    final min = LocalizedFormatters.number(
      bounds.minEffective,
      locale,
      maximumFractionDigits: 0,
    );
    final max = LocalizedFormatters.number(
      bounds.maxRecoverable,
      locale,
      maximumFractionDigits: 0,
    );
    return strings.anatomySetRange(min, max);
  }
}

class _BodyPartExpressiveMetricBays extends StatelessWidget {
  const _BodyPartExpressiveMetricBays({
    required this.recentLabel,
    required this.recentValue,
    required this.recommendedLabel,
    required this.recommendedValue,
    required this.onEdit,
  });

  final String recentLabel;
  final String recentValue;
  final String recommendedLabel;
  final String recommendedValue;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppExpressiveDestinationTokens>()!;
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 19;
    final first = _BodyPartExpressiveMetricBay(
      label: recentLabel,
      value: recentValue,
    );
    final second = _BodyPartExpressiveMetricBay(
      label: recommendedLabel,
      value: recommendedValue,
      onEdit: onEdit,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final useStacked = stacked || constraints.maxWidth < 310;
        return Container(
          decoration: BoxDecoration(
            color: tokens.surfaceSelected,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(8),
            ),
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: 0.35),
            ),
          ),
          child:
              useStacked
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      first,
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: tokens.outlineAccent.withValues(alpha: 0.25),
                      ),
                      second,
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: first),
                      Container(
                        width: 1,
                        height: 48,
                        color: tokens.outlineAccent.withValues(alpha: 0.25),
                      ),
                      Expanded(child: second),
                    ],
                  ),
        );
      },
    );
  }
}

class _BodyPartExpressiveMetricBay extends StatelessWidget {
  const _BodyPartExpressiveMetricBay({
    required this.label,
    required this.value,
    this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppExpressiveDestinationTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 2,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: tokens.onSurfaceSelected),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.onSurfaceSelected,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                IconTheme.merge(
                  data: IconThemeData(color: tokens.onSurfaceSelected),
                  child: RecommendedSetsEditButton(onPressed: onEdit!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseDefinitionTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool expressive;

  const _ExerciseDefinitionTile({
    required this.definition,
    required this.expressive,
  });

  @override
  Widget build(BuildContext context) {
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(
        definition: definition,
        expressive: expressive,
      ),
      expressiveCatalogPresentation: expressive,
    );
  }
}

class _ExerciseMetadata extends StatelessWidget {
  final ExerciseDefinition definition;
  final bool expressive;

  const _ExerciseMetadata({required this.definition, required this.expressive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final destinationTokens =
        Theme.of(context).extension<AppExpressiveDestinationTokens>();
    final equipmentEntities = definition.equipmentList
        .where((item) => item.name.trim().isNotEmpty)
        .map(
          (item) => CatalogEntityDisplayName(
            catalogId: item.catalogId,
            canonicalName: item.name,
          ),
        )
        .toList(growable: false);
    final equipmentLabel =
        equipmentEntities.isEmpty
            ? Text(
              AppLocalizations.of(context).anatomyNoEquipment,
              maxLines: expressive ? null : 1,
              overflow: expressive ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    expressive
                        ? destinationTokens?.actionPrimary
                        : colors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
            : LocalizedCatalogEntityNamesBuilder(
              entities: equipmentEntities,
              builder:
                  (context, names) => Text(
                    names.join(', '),
                    maxLines: expressive ? null : 1,
                    overflow: expressive ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          expressive
                              ? destinationTokens?.actionPrimary
                              : colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            );
    final muscleEntities = definition.muscles
        .take(3)
        .map(
          (ranked) => CatalogEntityDisplayName(
            catalogId: ranked.muscle.catalogId,
            canonicalName: ranked.muscle.name,
          ),
        )
        .toList(growable: false);
    final muscleLabel =
        muscleEntities.isEmpty
            ? Text(
              AppLocalizations.of(context).anatomyNoMusclesListed,
              maxLines: expressive ? null : 1,
              overflow: expressive ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    expressive
                        ? destinationTokens?.supportingForeground
                        : context.usesNeoPresentation
                        ? context.semanticColors.positive
                        : Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            )
            : LocalizedCatalogEntityNamesBuilder(
              entities: muscleEntities,
              builder:
                  (context, names) => Text(
                    names.join(', '),
                    maxLines: expressive ? null : 1,
                    overflow: expressive ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          expressive
                              ? destinationTokens?.supportingForeground
                              : context.usesNeoPresentation
                              ? context.semanticColors.positive
                              : Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [equipmentLabel, const SizedBox(height: 3), muscleLabel],
      ),
    );
  }
}

class _BodyPartPageData {
  final List<ExerciseDefinition> definitions;
  final List<Muscle> muscles;
  final double recentSetUnits;
  final VolumeBoundaries? volumeBounds;

  const _BodyPartPageData({
    required this.definitions,
    required this.muscles,
    required this.recentSetUnits,
    required this.volumeBounds,
  });
}
