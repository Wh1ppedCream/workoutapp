// File: lib/screens/exercise/definitions_by_muscle_page.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/exercise_definition_info_tile.dart';
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
  final _repo = AppRepository();
  late Future<_MusclePageData> _dataFuture;

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
          content: Text('${widget.muscle.name} recommended sets updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.muscle.name} Exercises')),
      body: FutureBuilder<_MusclePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load muscle: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: data.definitions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MuscleHeader(
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
                );
              }

              final definition = data.definitions[index - 1];
              return _ExerciseDefinitionTile(
                definition: definition,
                muscleId: widget.muscle.id,
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
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(_exerciseCountLabel(data.definitions.length)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (sourceBodyPart != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Opened from ${sourceBodyPart!.name}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SetStatChip(
                        label: 'Sets last 7 days',
                        value: '${data.recentSetUnits.toStringAsFixed(1)} sets',
                      ),
                      SetStatChip(
                        label: 'Recommended',
                        value: _rangeLabel(data.volumeBounds),
                        onEdit: onEditRecommended,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Related Bodyparts', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.bodyParts.isEmpty)
            Text(
              'No bodypart links have been added for this muscle yet.',
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
          Text('Exercises', style: theme.textTheme.titleMedium),
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            Text('No exercises are currently linked to ${muscle.name}.'),
          ],
        ],
      ),
    );
  }

  String _exerciseCountLabel(int count) {
    if (count == 1) return '1 linked exercise';
    return '$count linked exercises';
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  String _rangeLabel(VolumeBoundaries? bounds) {
    if (bounds == null) return 'Not set';
    final min = bounds.minEffective.toStringAsFixed(0);
    final max = bounds.maxRecoverable.toStringAsFixed(0);
    return '$min-$max sets';
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
            ? 'No equipment listed'
            : definition.equipmentList
                .map((equipment) => equipment.name)
                .join(', ');
    final bodyParts =
        definition.bodyParts.isEmpty
            ? 'No bodyparts listed'
            : definition.bodyParts.map((bodyPart) => bodyPart.name).join(', ');

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            equipment,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Rank $muscleRank for this muscle - $bodyParts',
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
