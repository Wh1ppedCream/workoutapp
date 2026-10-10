// File: lib/screens/exercise/definitions_by_muscle_page.dart

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
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/localized_catalog_entity_name.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import 'definitions_by_bodypart_page.dart';

/// Muscle detail page for the exercise focus library.
///
/// Shows linked exercises, associated bodyparts, recent seven-day set units,
/// and editable recommended set bounds for one muscle.
class DefinitionsByMusclePage extends StatefulWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;
  final bool expressiveCatalogPresentation;

  const DefinitionsByMusclePage({
    super.key,
    required this.muscle,
    this.sourceBodyPart,
    this.expressiveCatalogPresentation = false,
  });

  @override
  State<DefinitionsByMusclePage> createState() =>
      _DefinitionsByMusclePageState();
}

class _DefinitionsByMusclePageState extends State<DefinitionsByMusclePage> {
  AppRepository get _repo => context.read<AppRepository>();
  final _headerTutorialKey = GlobalKey(debugLabel: 'muscle_detail_header');
  final _exerciseListTutorialKey = GlobalKey(
    debugLabel: 'muscle_detail_exercise_list',
  );
  late Future<_MusclePageData> _dataFuture;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  /// Loads all page data together so recommendations, links, and exercise
  /// rankings are rendered from a consistent snapshot.
  Future<_MusclePageData> _loadData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    final definitionsFuture = _repo.lookupDefsDetailed();
    final bodyPartsFuture = _repo.fetchAllBodyParts();
    final linksFuture = _repo.fetchBodyPartsForMuscle(widget.muscle.id);
    final recentSetsFuture = _repo.fetchSetsPerMuscle(start: start, end: now);
    final boundsFuture = _repo.fetchMuscleVolumeBounds(widget.muscle.id);

    final definitions =
        (await definitionsFuture)
            .where(
              (def) => def.muscles.any(
                (ranked) => ranked.muscle.id == widget.muscle.id,
              ),
            )
            .toList()
          ..sort(_compareDefinitionsByMuscleRank);
    final bodyParts = await bodyPartsFuture;
    final links = await linksFuture;
    final recentSets = await recentSetsFuture;
    final bounds = await boundsFuture;

    final bodyPartById = {
      for (final bodyPart in bodyParts) bodyPart.id: bodyPart,
    };
    final linkedBodyParts =
        links
            .map((link) => bodyPartById[link.bodyPartId])
            .whereType<BodyPart>()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return _MusclePageData(
      definitions: definitions,
      bodyParts: linkedBodyParts,
      recentSetUnits: recentSets[widget.muscle.id] ?? 0.0,
      volumeBounds: bounds,
    );
  }

  int _compareDefinitionsByMuscleRank(
    ExerciseDefinition a,
    ExerciseDefinition b,
  ) {
    final aRank = _rankForMuscle(a);
    final bRank = _rankForMuscle(b);
    final rankCompare = aRank.compareTo(bRank);
    if (rankCompare != 0) return rankCompare;
    return a.name.compareTo(b.name);
  }

  int _rankForMuscle(ExerciseDefinition definition) {
    for (final ranked in definition.muscles) {
      if (ranked.muscle.id == widget.muscle.id) return ranked.rank;
    }
    return 999;
  }

  Future<void> _editRecommendedSets(_MusclePageData data) async {
    final displayName = await _localizedMuscleName();
    if (!mounted) return;
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: displayName,
      targetId: widget.muscle.id,
      currentBounds: data.volumeBounds,
    );
    if (updatedBounds == null) return;

    try {
      await _repo.setMuscleVolumeBounds(widget.muscle.id, updatedBounds);
      if (!mounted) return;

      setState(() {
        _dataFuture = _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).anatomyRecommendedSetsUpdated(displayName),
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

  Future<String> _localizedMuscleName() async {
    try {
      return await CatalogEntityLocalizer.instance.resolveName(
        CatalogEntityDisplayName(
          catalogId: widget.muscle.catalogId,
          canonicalName: widget.muscle.name,
        ),
        Localizations.localeOf(context),
      );
    } catch (_) {
      return widget.muscle.name;
    }
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
        tutorialId: TutorialIds.muscleDetail,
        steps: [
          GuidedTutorialStep(
            targetKey: _headerTutorialKey,
            icon: Icons.fitness_center,
            title: strings.anatomyTutorialMuscleDetailTitle,
            body: strings.anatomyTutorialMuscleDetailBody,
          ),
          GuidedTutorialStep(
            targetKey: _exerciseListTutorialKey,
            icon: Icons.list_alt,
            title: strings.anatomyTutorialLinkedExercisesTitle,
            body: strings.anatomyTutorialMuscleExercisesBody,
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
        title: LocalizedCatalogEntityNamesBuilder(
          entities: [
            CatalogEntityDisplayName(
              catalogId: widget.muscle.catalogId,
              canonicalName: widget.muscle.name,
            ),
          ],
          builder:
              (context, names) => Text(
                strings.anatomyTargetExercises(names.single),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        ),
      ),
      body: FutureBuilder<_MusclePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.anatomyMuscleLoadFailed));
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
                  child: _MuscleHeader(
                    muscle: widget.muscle,
                    sourceBodyPart: widget.sourceBodyPart,
                    data: data,
                    expressive: expressive,
                    onEditRecommended: () => _editRecommendedSets(data),
                    onBodyPartTap: (bodyPart) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            final page = DefinitionsByBodyPartPage(
                              bodyPart: bodyPart,
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
                  muscleId: widget.muscle.id,
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
}

class _MuscleHeader extends StatelessWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;
  final _MusclePageData data;
  final bool expressive;
  final VoidCallback onEditRecommended;
  final ValueChanged<BodyPart> onBodyPartTap;

  const _MuscleHeader({
    required this.muscle,
    required this.sourceBodyPart,
    required this.data,
    required this.expressive,
    required this.onEditRecommended,
    required this.onBodyPartTap,
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
                    ? destinationTokens?.surfaceAccent ??
                        theme.colorScheme.surfaceContainerLow
                    : null,
            elevation: expressive ? 0 : null,
            shape:
                expressive
                    ? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(28),
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(28),
                      ),
                    )
                    : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      expressive
                          ? CircleAvatar(
                            radius: 26,
                            backgroundColor: destinationTokens?.surfaceAccent,
                            child: Icon(
                              Icons.fitness_center,
                              color: destinationTokens?.onSurfaceAccent,
                              size: 25,
                            ),
                          )
                          : CircleAvatar(
                            radius: 26,
                            child: LocalizedCatalogEntityNamesBuilder(
                              entities: [
                                CatalogEntityDisplayName(
                                  catalogId: muscle.catalogId,
                                  canonicalName: muscle.name,
                                ),
                              ],
                              builder:
                                  (context, names) => Text(
                                    _initialFor(names.single),
                                    style: theme.textTheme.titleLarge,
                                  ),
                            ),
                          ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LocalizedCatalogEntityName(
                              entity: CatalogEntityDisplayName(
                                catalogId: muscle.catalogId,
                                canonicalName: muscle.name,
                              ),
                              maxLines: expressive ? 2 : 1,
                              overflow:
                                  expressive ? null : TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color:
                                    expressive
                                        ? destinationTokens?.onSurfaceAccent
                                        : null,
                                fontWeight: expressive ? FontWeight.w700 : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).anatomyLinkedExerciseCount(
                                data.definitions.length,
                              ),
                              style:
                                  expressive
                                      ? theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            destinationTokens?.onSurfaceAccent,
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (sourceBodyPart != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).anatomyOpenedFrom(
                        localizedBodyPartName(context, sourceBodyPart!.name),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            expressive
                                ? destinationTokens?.onSurfaceAccent
                                : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (expressive)
                    _MuscleExpressiveMetricBays(
                      recentLabel:
                          AppLocalizations.of(context).anatomySetsLastSevenDays,
                      recentValue: AppLocalizations.of(context).anatomySetUnits(
                        LocalizedFormatters.number(
                          data.recentSetUnits,
                          Localizations.localeOf(context),
                          minimumFractionDigits: 1,
                          maximumFractionDigits: 1,
                        ),
                      ),
                      recommendedLabel:
                          AppLocalizations.of(context).anatomyRecommended,
                      recommendedValue: _rangeLabel(
                        AppLocalizations.of(context),
                        data.volumeBounds,
                        Localizations.localeOf(context),
                      ),
                      onEdit: onEditRecommended,
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SetStatChip(
                          label:
                              AppLocalizations.of(
                                context,
                              ).anatomySetsLastSevenDays,
                          value: AppLocalizations.of(context).anatomySetUnits(
                            LocalizedFormatters.number(
                              data.recentSetUnits,
                              Localizations.localeOf(context),
                              minimumFractionDigits: 1,
                              maximumFractionDigits: 1,
                            ),
                          ),
                        ),
                        SetStatChip(
                          label:
                              AppLocalizations.of(context).anatomyRecommended,
                          value: _rangeLabel(
                            AppLocalizations.of(context),
                            data.volumeBounds,
                            Localizations.localeOf(context),
                          ),
                          onEdit: onEditRecommended,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).anatomyRelatedBodyParts,
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
          if (data.bodyParts.isEmpty)
            Text(
              AppLocalizations.of(context).anatomyNoBodyPartLinks,
              style: theme.textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  data.bodyParts
                      .map(
                        (bodyPart) => ActionChip(
                          label: Text(
                            localizedBodyPartName(context, bodyPart.name),
                            maxLines: expressive ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          avatar: const Icon(Icons.accessibility_new, size: 18),
                          onPressed: () => onBodyPartTap(bodyPart),
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
            LocalizedCatalogEntityNamesBuilder(
              entities: [
                CatalogEntityDisplayName(
                  catalogId: muscle.catalogId,
                  canonicalName: muscle.name,
                ),
              ],
              builder:
                  (context, names) => Text(
                    AppLocalizations.of(
                      context,
                    ).anatomyNoExercisesFor(names.single),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
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

class _MuscleExpressiveMetricBays extends StatelessWidget {
  const _MuscleExpressiveMetricBays({
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
    final first = _MuscleExpressiveMetricBay(
      label: recentLabel,
      value: recentValue,
    );
    final second = _MuscleExpressiveMetricBay(
      label: recommendedLabel,
      value: recommendedValue,
      onEdit: onEdit,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 330 ||
            MediaQuery.textScalerOf(context).scale(16) > 19;
        return Container(
          decoration: BoxDecoration(
            color: tokens.surfaceSelected,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(8),
              bottomLeft: Radius.circular(18),
            ),
            border: Border.all(
              color: tokens.outlineAccent.withValues(alpha: 0.35),
            ),
          ),
          child:
              stacked
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

class _MuscleExpressiveMetricBay extends StatelessWidget {
  const _MuscleExpressiveMetricBay({
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
  final int muscleId;
  final bool expressive;

  const _ExerciseDefinitionTile({
    required this.definition,
    required this.muscleId,
    required this.expressive,
  });

  @override
  Widget build(BuildContext context) {
    final rank = _rankForMuscle(definition);
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(
        definition: definition,
        muscleRank: rank,
        expressive: expressive,
      ),
      expressiveCatalogPresentation: expressive,
    );
  }

  int _rankForMuscle(ExerciseDefinition definition) {
    for (final ranked in definition.muscles) {
      if (ranked.muscle.id == muscleId) return ranked.rank;
    }
    return 999;
  }
}

class _ExerciseMetadata extends StatelessWidget {
  final ExerciseDefinition definition;
  final int muscleRank;
  final bool expressive;

  const _ExerciseMetadata({
    required this.definition,
    required this.muscleRank,
    required this.expressive,
  });

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
    final bodyParts =
        definition.bodyParts.isEmpty
            ? AppLocalizations.of(context).anatomyNoBodyPartsListed
            : definition.bodyParts
                .map(
                  (bodyPart) => localizedBodyPartName(context, bodyPart.name),
                )
                .join(', ');

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equipmentLabel,
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(
              context,
            ).anatomyRankForMuscle(muscleRank, bodyParts),
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
        ],
      ),
    );
  }
}

class _MusclePageData {
  final List<ExerciseDefinition> definitions;
  final List<BodyPart> bodyParts;
  final double recentSetUnits;
  final VolumeBoundaries? volumeBounds;

  const _MusclePageData({
    required this.definitions,
    required this.bodyParts,
    required this.recentSetUnits,
    required this.volumeBounds,
  });
}
