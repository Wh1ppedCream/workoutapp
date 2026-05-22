import 'package:flutter/material.dart';

import '../../data/premade_training_plans.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';

class PremadePlansPage extends StatefulWidget {
  final int? profileId;
  final VoidCallback onPlanAdded;

  const PremadePlansPage({
    super.key,
    required this.profileId,
    required this.onPlanAdded,
  });

  @override
  State<PremadePlansPage> createState() => _PremadePlansPageState();
}

class _PremadePlansPageState extends State<PremadePlansPage> {
  final _repo = AppRepository();
  final _addingPlanIds = <String>{};

  Future<void> _addPlan(PremadeTrainingPlan plan) async {
    final profileId = widget.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gym profile first.')),
      );
      return;
    }

    setState(() => _addingPlanIds.add(plan.id));
    try {
      final presetId = await _repo.createPreset(
        '${plan.sourceName}: ${plan.name}',
        profileId: profileId,
      );
      for (var i = 0; i < plan.exercises.length; i++) {
        final exercise = plan.exercises[i];
        final defId = await _repo.findOrCreateExerciseDefinition(
          exercise.name,
          exercise.equipment,
        );
        final presetExerciseId = await _repo.addExerciseToPreset(
          presetId,
          defId,
          'weight',
          i,
        );
        await _repo.savePresetWeightSets(
          presetExerciseId,
          List<ExerciseSet>.generate(
            exercise.sets,
            (_) => ExerciseSet(weight: exercise.weight, reps: exercise.reps),
          ),
          const <int, List<ExerciseSet>>{},
        );
      }

      if (!mounted) return;
      widget.onPlanAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.name} added to your presets.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add ${plan.name}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _addingPlanIds.remove(plan.id));
      }
    }
  }

  Map<String, List<PremadeTrainingPlan>> _plansBySource() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    for (final plan in premadeTrainingPlans) {
      grouped.putIfAbsent(plan.sourceName, () => <PremadeTrainingPlan>[]).add(plan);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedPlans = _plansBySource();
    return Scaffold(
      appBar: AppBar(title: const Text('Premade Plans')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Copy coach, influencer, and app-curated routines into your own presets. Once added, you can edit them like any other preset.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in groupedPlans.entries) ...[
            _PremadeSourceSection(
              sourceName: entry.key,
              plans: entry.value,
              addingPlanIds: _addingPlanIds,
              onAddPlan: _addPlan,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _PremadeSourceSection extends StatelessWidget {
  final String sourceName;
  final List<PremadeTrainingPlan> plans;
  final Set<String> addingPlanIds;
  final Future<void> Function(PremadeTrainingPlan plan) onAddPlan;

  const _PremadeSourceSection({
    required this.sourceName,
    required this.plans,
    required this.addingPlanIds,
    required this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sourceName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final plan in plans) ...[
          _PremadePlanCard(
            plan: plan,
            isAdding: addingPlanIds.contains(plan.id),
            onAdd: () {
              onAddPlan(plan);
            },
          ),
          if (plan != plans.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PremadePlanCard extends StatelessWidget {
  final PremadeTrainingPlan plan;
  final bool isAdding;
  final VoidCallback onAdd;

  const _PremadePlanCard({
    required this.plan,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSets = plan.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plan.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${plan.exercises.length} exercises - $totalSets sets',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    final addButton = FilledButton.tonalIcon(
      onPressed: isAdding ? null : onAdd,
      icon:
          isAdding
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.add),
      label: Text(isAdding ? 'Adding' : 'Add'),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 330) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity, child: addButton),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 12),
                    addButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final exercise in plan.exercises)
              _PremadeExerciseRow(exercise: exercise),
          ],
        ),
      ),
    );
  }
}

class _PremadeExerciseRow extends StatelessWidget {
  final PremadeTrainingExercise exercise;

  const _PremadeExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fitness_center,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' - ${exercise.equipment}',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  TextSpan(
                    text: ' - ${exercise.sets} x ${exercise.reps}',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
