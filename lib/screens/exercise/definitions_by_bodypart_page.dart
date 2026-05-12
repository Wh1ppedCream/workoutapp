// File: lib/screens/exercise/definitions_by_bodypart_page.dart

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/body_heatmap.dart';
import '../../widgets/exercise_definition_info_tile.dart';
import '../../widgets/recommended_sets_editor_dialog.dart';
import '../../widgets/set_stat_chip.dart';
import 'definitions_by_muscle_page.dart';

/// Displays exercises filtered by a specific bodypart.
class DefinitionsByBodyPartPage extends StatefulWidget {
  final BodyPart bodyPart;

  const DefinitionsByBodyPartPage({super.key, required this.bodyPart});

  @override
  State<DefinitionsByBodyPartPage> createState() =>
      _DefinitionsByBodyPartPageState();
}

class _DefinitionsByBodyPartPageState extends State<DefinitionsByBodyPartPage> {
  final _repo = AppRepository();
  late Future<_BodyPartPageData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.bodyPart.name} Exercises')),
      body: FutureBuilder<_BodyPartPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load bodypart: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: data.definitions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _BodyPartHeader(
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
                );
              }

              final definition = data.definitions[index - 1];
              return _ExerciseDefinitionTile(definition: definition);
            },
          );
        },
      ),
    );
  }

  Future<void> _editRecommendedSets(_BodyPartPageData data) async {
    final updatedBounds = await showRecommendedSetsEditorDialog(
      context,
      targetName: widget.bodyPart.name,
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
          content: Text('${widget.bodyPart.name} recommended sets updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
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
                  Text(bodyPart.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_exerciseCountLabel(data.definitions.length)),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SingleBodyPartHeatmap(
                              bodyPartName: bodyPart.name,
                              size: 178,
                              padding: 2,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SetStatChip(
                              label: 'Done (7 days)',
                              value:
                                  '${data.recentSetUnits.toStringAsFixed(1)} sets',
                            ),
                            const SizedBox(height: 10),
                            SetStatChip(
                              label: 'Recommended',
                              value: _rangeLabel(data.volumeBounds),
                              onEdit: onEditRecommended,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Associated Muscles', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.muscles.isEmpty)
            Text(
              'No muscle links have been added for this bodypart yet.',
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
          Text('Exercises', style: theme.textTheme.titleMedium),
          if (data.definitions.isEmpty) ...[
            const SizedBox(height: 12),
            Text('No exercises are currently linked to ${bodyPart.name}.'),
          ],
        ],
      ),
    );
  }

  String _exerciseCountLabel(int count) {
    if (count == 1) return '1 linked exercise';
    return '$count linked exercises';
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
            ? 'No equipment listed'
            : definition.equipmentList
                .map((equipment) => equipment.name)
                .join(', ');
    final muscles =
        definition.muscles.isEmpty
            ? 'No muscles listed'
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
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            muscles,
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
