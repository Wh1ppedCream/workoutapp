import 'package:flutter/material.dart';

import '../../data/premade_training_plans.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';

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
  static const _homemadeSourceName = 'Homemade';
  static const _homemadePlanGroups = [
    'Full Body',
    'Push Pull Legs',
    'Upper Lower',
    'Body Part (Bro) Split',
  ];

  final _repo = AppRepository();
  final _addingPlanIds = <String>{};
  var _selectedDurationMinutes = 60;

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
      final presetName = await _uniqueAddedPlanName(plan.name, profileId);
      final presetId = await _repo.createPreset(
        presetName,
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

      await ActivePlanStore.add(profileId, presetId);

      if (!mounted) return;
      widget.onPlanAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$presetName added to Active Plans.')),
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

  Future<String> _uniqueAddedPlanName(String baseName, int profileId) async {
    final existingRows = await _repo.fetchAllPresetsRaw(profileId: profileId);
    final existingNames = {
      for (final row in existingRows) (row['name'] as String).trim(),
    };
    if (!existingNames.contains(baseName)) return baseName;

    var copyNumber = 2;
    while (existingNames.contains('$baseName ($copyNumber)')) {
      copyNumber++;
    }
    return '$baseName ($copyNumber)';
  }

  Map<String, List<PremadeTrainingPlan>> _plansBySource() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    final filteredPlans = premadeTrainingPlans.where(
      (plan) => plan.durationMinutes == _selectedDurationMinutes,
    );
    for (final plan in filteredPlans) {
      grouped
          .putIfAbsent(plan.sourceName, () => <PremadeTrainingPlan>[])
          .add(plan);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedPlans = _plansBySource();
    final homemadePlans =
        groupedPlans.remove(_homemadeSourceName) ??
        const <PremadeTrainingPlan>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Premade Plans')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _PremadeDurationHeader(
            durationMinutes: _selectedDurationMinutes,
            onChanged: (durationMinutes) {
              setState(() => _selectedDurationMinutes = durationMinutes);
            },
            child: Text(
              'Copy coach, influencer, and app-curated routines into your own plans. Once added, you can edit them like any other plan.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PremadeSourceSection(
            sourceName: _homemadeSourceName,
            plans: homemadePlans,
            planGroupNames: _homemadePlanGroups,
            initiallyExpanded: true,
            addingPlanIds: _addingPlanIds,
            onAddPlan: _addPlan,
          ),
          const SizedBox(height: 16),
          for (final entry in groupedPlans.entries) ...[
            _PremadeSourceSection(
              sourceName: entry.key,
              plans: entry.value,
              initiallyExpanded: false,
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

class _PremadeDurationHeader extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;
  final Widget child;

  const _PremadeDurationHeader({
    required this.durationMinutes,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final switcher = _PremadeDurationSwitch(
      durationMinutes: durationMinutes,
      onChanged: onChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: switcher),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child),
            const SizedBox(width: 14),
            switcher,
          ],
        );
      },
    );
  }
}

class _PremadeDurationSwitch extends StatelessWidget {
  final int durationMinutes;
  final ValueChanged<int> onChanged;

  const _PremadeDurationSwitch({
    required this.durationMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTwoHour = durationMinutes == 120;
    final activeStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w800,
    );
    final inactiveStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1hr', style: isTwoHour ? inactiveStyle : activeStyle),
            Switch(
              value: isTwoHour,
              onChanged: (value) => onChanged(value ? 120 : 60),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text('2hr', style: isTwoHour ? activeStyle : inactiveStyle),
          ],
        ),
      ),
    );
  }
}

class _PremadeSourceSection extends StatelessWidget {
  final String sourceName;
  final List<PremadeTrainingPlan> plans;
  final List<String> planGroupNames;
  final bool initiallyExpanded;
  final Set<String> addingPlanIds;
  final Future<void> Function(PremadeTrainingPlan plan) onAddPlan;

  const _PremadeSourceSection({
    required this.sourceName,
    required this.plans,
    this.planGroupNames = const <String>[],
    required this.initiallyExpanded,
    required this.addingPlanIds,
    required this.onAddPlan,
  });

  Map<String, List<PremadeTrainingPlan>> _plansByGroup() {
    final grouped = <String, List<PremadeTrainingPlan>>{};
    for (final plan in plans) {
      grouped
          .putIfAbsent(plan.planGroupName, () => <PremadeTrainingPlan>[])
          .add(plan);
    }
    return grouped;
  }

  List<String> _orderedGroupNames(
    Map<String, List<PremadeTrainingPlan>> grouped,
  ) {
    final ordered = <String>[
      ...planGroupNames,
      for (final groupName in grouped.keys)
        if (!planGroupNames.contains(groupName)) groupName,
    ];
    if (ordered.isNotEmpty) return ordered;
    return grouped.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _plansByGroup();
    final orderedGroupNames = _orderedGroupNames(grouped);
    final planCount = plans.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          sourceName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '$planCount ${planCount == 1 ? 'plan' : 'plans'} available',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          for (final groupName in orderedGroupNames)
            _PremadePlanGroupTile(
              groupName: groupName,
              plans: grouped[groupName] ?? const <PremadeTrainingPlan>[],
              addingPlanIds: addingPlanIds,
              onAddPlan: onAddPlan,
            ),
        ],
      ),
    );
  }
}

class _PremadePlanGroupTile extends StatelessWidget {
  final String groupName;
  final List<PremadeTrainingPlan> plans;
  final Set<String> addingPlanIds;
  final Future<void> Function(PremadeTrainingPlan plan) onAddPlan;

  const _PremadePlanGroupTile({
    required this.groupName,
    required this.plans,
    required this.addingPlanIds,
    required this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planCount = plans.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        title: Text(
          groupName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          planCount == 0
              ? 'No plan templates yet'
              : '$planCount ${planCount == 1 ? 'plan' : 'plans'}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Templates for this split can be added here later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final plan in plans) ...[
              _PremadePlanCard(
                plan: plan,
                isAdding: addingPlanIds.contains(plan.id),
                onAdd: () {
                  onAddPlan(plan);
                },
              ),
              if (plan != plans.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PremadePlanCard extends StatefulWidget {
  final PremadeTrainingPlan plan;
  final bool isAdding;
  final VoidCallback onAdd;

  const _PremadePlanCard({
    required this.plan,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  State<_PremadePlanCard> createState() => _PremadePlanCardState();
}

class _PremadePlanCardState extends State<_PremadePlanCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = widget.plan;
    final totalSets = plan.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      onPressed: widget.isAdding ? null : widget.onAdd,
      icon:
          widget.isAdding
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.add),
      label: Text(widget.isAdding ? 'Adding' : 'Add'),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpanded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titleWithIcon = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: titleBlock),
                    ],
                  );

                  if (constraints.maxWidth < 330) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWithIcon,
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: addButton),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleWithIcon),
                      const SizedBox(width: 12),
                      addButton,
                    ],
                  );
                },
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: details,
              ),
              crossFadeState:
                  _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              sizeCurve: Curves.easeOutCubic,
            ),
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
