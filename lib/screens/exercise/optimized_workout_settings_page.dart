import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../widgets/bodypart_focus_chips.dart';

enum OptimizedWorkoutSettingsAction { save, startNow }

class OptimizedWorkoutSettingsResult {
  final OptimizedWorkoutSettingsAction action;
  final int minutes;
  final int minSets;
  final int maxSets;
  final Set<int> preferredBodypartIds;
  final Set<int> blacklistedBodypartIds;

  const OptimizedWorkoutSettingsResult({
    required this.action,
    required this.minutes,
    required this.minSets,
    required this.maxSets,
    required this.preferredBodypartIds,
    required this.blacklistedBodypartIds,
  });
}

class OptimizedWorkoutSettingsPage extends StatefulWidget {
  final int initialMinutes;
  final int initialMinSets;
  final int initialMaxSets;
  final Set<int> initialPreferredBodypartIds;
  final Set<int> initialBlacklistedBodypartIds;
  final List<BodyPart> bodyParts;

  const OptimizedWorkoutSettingsPage({
    super.key,
    required this.initialMinutes,
    required this.initialMinSets,
    required this.initialMaxSets,
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
  late final TextEditingController _minutesController;
  late final TextEditingController _minSetsController;
  late final TextEditingController _maxSetsController;
  late Set<int> _preferredBodypartIds;
  late Set<int> _blacklistedBodypartIds;

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
    _preferredBodypartIds = {...widget.initialPreferredBodypartIds};
    _blacklistedBodypartIds = {...widget.initialBlacklistedBodypartIds};
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _minSetsController.dispose();
    _maxSetsController.dispose();
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _minutesController.text =
          SessionSpec.defaultSessionDurationMinutes.toString();
      _minSetsController.text =
          SessionSpec.preferredMinSetsPerExercise.toString();
      _maxSetsController.text = SessionSpec.defaultMaxSetsPerExercise.toString();
      _preferredBodypartIds = <int>{};
      _blacklistedBodypartIds = <int>{};
    });
  }

  void _submit(OptimizedWorkoutSettingsAction action) {
    final minutes = int.tryParse(_minutesController.text.trim());
    final minSets = int.tryParse(_minSetsController.text.trim());
    final maxSets = int.tryParse(_maxSetsController.text.trim());
    if (minutes == null ||
        minutes <= 0 ||
        minSets == null ||
        minSets < SessionSpec.defaultMinSetsPerExercise ||
        minSets > SessionSpec.maxAllowedSetsPerExercise ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise ||
        minSets > maxSets) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a valid duration and set range between 1-${SessionSpec.maxAllowedSetsPerExercise}.',
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
                Card(
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
                const SizedBox(height: 16),
                Card(
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
              child: _FloatingHeaderButton(
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: _resetToDefaults,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
