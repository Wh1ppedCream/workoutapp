import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/tutorial_state_store.dart';
import '../../widgets/bodypart_focus_chips.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../utils/tutorial_launcher.dart';

enum OptimizedWorkoutSettingsAction { save, startNow }

class OptimizedWorkoutSettingsResult {
  final OptimizedWorkoutSettingsAction action;
  final int minutes;
  final int minSets;
  final int maxSets;
  final RepWeightGenerationMode repWeightMode;
  final int targetRepCount;
  final StarterWeightIntensity starterWeightIntensity;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const OptimizedWorkoutSettingsResult({
    required this.action,
    required this.minutes,
    required this.minSets,
    required this.maxSets,
    required this.repWeightMode,
    required this.targetRepCount,
    required this.starterWeightIntensity,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

class OptimizedWorkoutSettingsPage extends StatefulWidget {
  final int initialMinutes;
  final int initialMinSets;
  final int initialMaxSets;
  final RepWeightGenerationMode initialRepWeightMode;
  final int initialTargetRepCount;
  final StarterWeightIntensity initialStarterWeightIntensity;
  final Set<int> initialPreferredBodypartIds;
  final Set<int> initialBlacklistedBodypartIds;
  final List<BodyPart> bodyParts;

  const OptimizedWorkoutSettingsPage({
    super.key,
    required this.initialMinutes,
    required this.initialMinSets,
    required this.initialMaxSets,
    required this.initialRepWeightMode,
    required this.initialTargetRepCount,
    required this.initialStarterWeightIntensity,
    required this.initialPreferredBodypartIds,
    required this.initialBlacklistedBodypartIds,
    required this.bodyParts,
  });

  @override
  State<OptimizedWorkoutSettingsPage> createState() =>
      _OptimizedWorkoutSettingsPageState();
}

class _OptimizedWorkoutSettingsPageState
    extends State<OptimizedWorkoutSettingsPage> {
  final _budgetTutorialKey = GlobalKey(debugLabel: 'optimized_budget');
  final _repWeightTutorialKey = GlobalKey(debugLabel: 'optimized_rep_weight');
  final _focusTutorialKey = GlobalKey(debugLabel: 'optimized_focus');
  final _resetTutorialKey = GlobalKey(debugLabel: 'optimized_reset');
  final _actionsTutorialKey = GlobalKey(debugLabel: 'optimized_actions');
  late final TextEditingController _minutesController;
  late final TextEditingController _minSetsController;
  late final TextEditingController _maxSetsController;
  late final TextEditingController _targetRepsController;
  late RepWeightGenerationMode _repWeightMode;
  late StarterWeightIntensity _starterWeightIntensity;
  late Set<int> _preferredBodypartIds;
  late Set<int> _blacklistedBodypartIds;
  bool _tutorialQueued = false;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.initialMinutes.toString(),
    );
    _minSetsController = TextEditingController(
      text: widget.initialMinSets.toString(),
    );
    _maxSetsController = TextEditingController(
      text: widget.initialMaxSets.toString(),
    );
    _targetRepsController = TextEditingController(
      text: widget.initialTargetRepCount.toString(),
    );
    _repWeightMode = widget.initialRepWeightMode;
    _starterWeightIntensity = widget.initialStarterWeightIntensity;
    _preferredBodypartIds = {...widget.initialPreferredBodypartIds};
    _blacklistedBodypartIds = {...widget.initialBlacklistedBodypartIds};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _minSetsController.dispose();
    _maxSetsController.dispose();
    _targetRepsController.dispose();
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _minutesController.text =
          SessionSpec.defaultSessionDurationMinutes.toString();
      _minSetsController.text =
          SessionSpec.preferredMinSetsPerExercise.toString();
      _maxSetsController.text =
          SessionSpec.defaultMaxSetsPerExercise.toString();
      _targetRepsController.text = SessionSpec.defaultTargetRepCount.toString();
      _repWeightMode = RepWeightGenerationMode.mixed;
      _starterWeightIntensity = StarterWeightIntensity.medium;
      _preferredBodypartIds = <int>{};
      _blacklistedBodypartIds = <int>{};
    });
  }

  void _queueTutorial() {
    if (!mounted || _tutorialQueued) return;
    _tutorialQueued = true;
    unawaited(_showTutorial());
  }

  Future<void> _showTutorial() async {
    try {
      await showGuidedTutorialOnce(
        context,
        tutorialId: TutorialIds.optimizedWorkoutSettings,
        steps: [
          GuidedTutorialStep(
            targetKey: _budgetTutorialKey,
            icon: Icons.timer_outlined,
            title: 'Session budget',
            body:
                'Set how long the optimized workout should be and how many sets each exercise can receive.',
          ),
          GuidedTutorialStep(
            targetKey: _repWeightTutorialKey,
            icon: Icons.fitness_center_outlined,
            title: 'Reps and weight',
            body:
                'These choices control the set pattern, target reps, and how conservative generated weights should be.',
          ),
          GuidedTutorialStep(
            targetKey: _focusTutorialKey,
            icon: Icons.track_changes_outlined,
            title: 'Bodypart focus',
            body:
                'Prefer or avoid bodyparts for the next optimized workout without changing your saved rankings.',
          ),
          GuidedTutorialStep(
            targetKey: _resetTutorialKey,
            icon: Icons.refresh,
            title: 'Reset',
            body:
                'Reset brings this page back to Tonos defaults if the current setup feels off.',
          ),
          GuidedTutorialStep(
            targetKey: _actionsTutorialKey,
            icon: Icons.play_circle_outline,
            title: 'Save or start',
            body:
                'Start Now uses the current on-screen values once. Save keeps the settings for future optimized workouts.',
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
    }
  }

  void _submit(OptimizedWorkoutSettingsAction action) {
    final minutes = int.tryParse(_minutesController.text.trim());
    final minSets = int.tryParse(_minSetsController.text.trim());
    final maxSets = int.tryParse(_maxSetsController.text.trim());
    final targetReps = int.tryParse(_targetRepsController.text.trim());
    if (minutes == null ||
        minutes <= 0 ||
        minSets == null ||
        minSets < SessionSpec.defaultMinSetsPerExercise ||
        minSets > SessionSpec.maxAllowedSetsPerExercise ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise ||
        minSets > maxSets ||
        targetReps == null ||
        targetReps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a valid duration, rep target, and set range between 1-${SessionSpec.maxAllowedSetsPerExercise}.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      OptimizedWorkoutSettingsResult(
        action: action,
        minutes: minutes,
        minSets: minSets,
        maxSets: maxSets,
        repWeightMode: _repWeightMode,
        targetRepCount: targetReps,
        starterWeightIntensity: _starterWeightIntensity,
        preferredBodypartIds: {..._preferredBodypartIds},
        blacklistedBodypartIds: {..._blacklistedBodypartIds},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 72, 16, 120),
              children: [
                KeyedSubtree(
                  key: _budgetTutorialKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session budget',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Used to budget 3 minutes per set plus 5 minutes to start each exercise.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Workout duration',
                              suffixText: 'min',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _minSetsController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Minimum sets per exercise',
                              suffixText: 'sets',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _maxSetsController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Up to sets per exercise',
                              suffixText: 'sets',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                KeyedSubtree(
                  key: _repWeightTutorialKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reps & weights',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Uses history-based strength estimates when available, with Easy and Medium backing off more than Hard. New exercises use conservative starter estimates.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SettingsChoice<RepWeightGenerationMode>(
                            title: 'Rep pattern',
                            value: _repWeightMode,
                            options: const [
                              _SettingsChoiceOption(
                                value: RepWeightGenerationMode.mixed,
                                label: 'Mixed',
                              ),
                              _SettingsChoiceOption(
                                value: RepWeightGenerationMode.pyramid,
                                label: 'Pyramid',
                              ),
                              _SettingsChoiceOption(
                                value: RepWeightGenerationMode.consistent,
                                label: 'Consistent',
                              ),
                            ],
                            onChanged:
                                (value) =>
                                    setState(() => _repWeightMode = value),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _targetRepsController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Target reps',
                              suffixText: 'reps',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsChoice<StarterWeightIntensity>(
                            title: 'Weight intensity',
                            value: _starterWeightIntensity,
                            options: const [
                              _SettingsChoiceOption(
                                value: StarterWeightIntensity.easy,
                                label: 'Easy',
                              ),
                              _SettingsChoiceOption(
                                value: StarterWeightIntensity.medium,
                                label: 'Medium',
                              ),
                              _SettingsChoiceOption(
                                value: StarterWeightIntensity.hard,
                                label: 'Hard',
                              ),
                            ],
                            onChanged:
                                (value) => setState(
                                  () => _starterWeightIntensity = value,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                KeyedSubtree(
                  key: _focusTutorialKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bodypart focus',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'These picks apply only to the next optimized workout you start. Tap once to prefer, tap twice to avoid, and tap again to clear.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          BodypartFocusChips(
                            bodyParts: widget.bodyParts,
                            preferredBodypartIds: _preferredBodypartIds,
                            blacklistedBodypartIds: _blacklistedBodypartIds,
                            emptyText: 'Bodyparts could not be loaded.',
                            onChanged:
                                (selection) => setState(() {
                                  _preferredBodypartIds =
                                      selection.preferredBodypartIds;
                                  _blacklistedBodypartIds =
                                      selection.blacklistedBodypartIds;
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 16,
              child: _FloatingHeaderButton(
                icon: Icons.close,
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: KeyedSubtree(
                key: _resetTutorialKey,
                child: _FloatingHeaderButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onPressed: _resetToDefaults,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: KeyedSubtree(
          key: _actionsTutorialKey,
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed:
                      () => _submit(OptimizedWorkoutSettingsAction.startNow),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _submit(OptimizedWorkoutSettingsAction.save),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsChoiceOption<T> {
  final T value;
  final String label;

  const _SettingsChoiceOption({required this.value, required this.label});
}

class _SettingsChoice<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<_SettingsChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  const _SettingsChoice({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final selected = option.value == value;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selected,
                  onSelected: (_) => onChanged(option.value),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _FloatingHeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FloatingHeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
