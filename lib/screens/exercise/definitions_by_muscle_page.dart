// File: lib/screens/exercise/definitions_by_muscle_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import 'definitions_by_bodypart_page.dart';

/// Muscle detail page for the exercise focus library.
///
/// Shows linked exercises, associated bodyparts, recent seven-day set units,
/// and editable recommended set bounds for one muscle.
class DefinitionsByMusclePage extends StatefulWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;

  const DefinitionsByMusclePage({
    super.key,
    required this.muscle,
    this.sourceBodyPart,
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
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: widget.muscle.name,
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
            ).anatomyRecommendedSetsUpdated(widget.muscle.name),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.anatomyTargetExercises(widget.muscle.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                    onEditRecommended: () => _editRecommendedSets(data),
                    onBodyPartTap: (bodyPart) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  DefinitionsByBodyPartPage(bodyPart: bodyPart),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MuscleHeader extends StatelessWidget {
  final Muscle muscle;
  final BodyPart? sourceBodyPart;
  final _MusclePageData data;
  final VoidCallback onEditRecommended;
  final ValueChanged<BodyPart> onBodyPartTap;

  const _MuscleHeader({
    required this.muscle,
    required this.sourceBodyPart,
    required this.data,
    required this.onEditRecommended,
    required this.onBodyPartTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Text(
                          _initialFor(muscle.name),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              muscle.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).anatomyLinkedExerciseCount(
                                data.definitions.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (sourceBodyPart != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).anatomyOpenedFrom(sourceBodyPart!.name),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
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
                          data.recentSetUnits.toStringAsFixed(1),
                        ),
                      ),
                      SetStatChip(
                        label: AppLocalizations.of(context).anatomyRecommended,
                        value: _rangeLabel(
                          AppLocalizations.of(context),
                          data.volumeBounds,
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
            style: theme.textTheme.titleMedium,
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
                          label: Text(bodyPart.name),
                          avatar: const Icon(Icons.accessibility_new, size: 18),
                          onPressed: () => onBodyPartTap(bodyPart),
                        ),
                      )
                      .toList(),
            ),
          const Divider(height: 32),
          Text(
            AppLocalizations.of(context).anatomyExercises,
            style: theme.textTheme.titleMedium,
          ),
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).anatomyNoExercisesFor(muscle.name),
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

  String _rangeLabel(AppLocalizations strings, VolumeBoundaries? bounds) {
    if (bounds == null) return strings.anatomyNotSet;
    final min = bounds.minEffective.toStringAsFixed(0);
    final max = bounds.maxRecoverable.toStringAsFixed(0);
    return strings.anatomySetRange(min, max);
  }
}

class _ExerciseDefinitionTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final int muscleId;

  const _ExerciseDefinitionTile({
    required this.definition,
    required this.muscleId,
  });

  @override
  Widget build(BuildContext context) {
    final rank = _rankForMuscle(definition);
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(definition: definition, muscleRank: rank),
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

  const _ExerciseMetadata({required this.definition, required this.muscleRank});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final equipment =
        definition.equipmentList.isEmpty
            ? AppLocalizations.of(context).anatomyNoEquipment
            : definition.equipmentList
                .map((equipment) => equipment.name)
                .join(', ');
    final bodyParts =
        definition.bodyParts.isEmpty
            ? AppLocalizations.of(context).anatomyNoBodyPartsListed
            : definition.bodyParts.map((bodyPart) => bodyPart.name).join(', ');

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            equipment,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(
              context,
            ).anatomyRankForMuscle(muscleRank, bodyParts),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.green.shade600,
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
