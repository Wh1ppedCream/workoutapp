// File: lib/screens/exercise/definitions_by_bodypart_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/tutorial_state_store.dart';
import '../../utils/localized_body_part_name.dart';
import '../../utils/tutorial_launcher.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import 'definitions_by_muscle_page.dart';

/// Bodypart detail page for the exercise focus library.
///
/// Shows linked exercises, associated muscles, recent seven-day set units, and
/// editable recommended set bounds for one bodypart.
class DefinitionsByBodyPartPage extends StatefulWidget {
  final BodyPart bodyPart;

  const DefinitionsByBodyPartPage({super.key, required this.bodyPart});

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
    return Scaffold(
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
                    onEditRecommended: () => _editRecommendedSets(data),
                    onMuscleTap: (muscle) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => DefinitionsByMusclePage(
                                muscle: muscle,
                                sourceBodyPart: widget.bodyPart,
                              ),
                        ),
                      );
                    },
                  ),
                );
              }

              final definition = data.definitions[index - 1];
              return KeyedSubtree(
                key: index == 1 ? _exerciseListTutorialKey : null,
                child: _ExerciseDefinitionTile(definition: definition),
              );
            },
          );
        },
      ),
    );
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
  final VoidCallback onEditRecommended;
  final ValueChanged<Muscle> onMuscleTap;

  const _BodyPartHeader({
    required this.bodyPart,
    required this.data,
    required this.onEditRecommended,
    required this.onMuscleTap,
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
                  Text(
                    localizedBodyPartName(context, bodyPart.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).anatomyLinkedExerciseCount(data.definitions.length),
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

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
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
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SetStatChip(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      ).anatomyDoneLastSevenDays,
                                  value: AppLocalizations.of(
                                    context,
                                  ).anatomySetUnits(
                                    data.recentSetUnits.toStringAsFixed(1),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SetStatChip(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      ).anatomyRecommended,
                                  value: _rangeLabel(
                                    AppLocalizations.of(context),
                                    data.volumeBounds,
                                  ),
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
            style: theme.textTheme.titleMedium,
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
                          label: Text(muscle.name),
                          avatar: const Icon(Icons.fitness_center, size: 18),
                          onPressed: () => onMuscleTap(muscle),
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
              AppLocalizations.of(context).anatomyNoExercisesFor(
                localizedBodyPartName(context, bodyPart.name),
              ),
            ),
          ],
        ],
      ),
    );
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

  const _ExerciseDefinitionTile({required this.definition});

  @override
  Widget build(BuildContext context) {
    return ExerciseDefinitionInfoTile(
      definition: definition,
      subtitle: _ExerciseMetadata(definition: definition),
    );
  }
}

class _ExerciseMetadata extends StatelessWidget {
  final ExerciseDefinition definition;

  const _ExerciseMetadata({required this.definition});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final equipment =
        definition.equipmentList.isEmpty
            ? AppLocalizations.of(context).anatomyNoEquipment
            : definition.equipmentList
                .map((equipment) => equipment.name)
                .join(', ');
    final muscles =
        definition.muscles.isEmpty
            ? AppLocalizations.of(context).anatomyNoMusclesListed
            : definition.muscles
                .take(3)
                .map((ranked) => ranked.muscle.name)
                .join(', ');

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
            muscles,
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
