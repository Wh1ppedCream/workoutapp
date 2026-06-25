// File: lib/screens/exercise/preset_generation_qa.dart

import 'package:flutter/material.dart';
import '../profile/settings/bodypart_ranking_screen.dart';
import '../profile/settings/muscle_ranking_screen.dart';

import '../../models/definition_models.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/preset_generation_service.dart';
import '../../models/training_plan_models.dart';
import '../../widgets/bodypart_focus_chips.dart';

/// User-facing allocation choices for generated presets.
///
/// The labels in the UI are intentionally friendlier than the enum names; these
/// map onto [TrainingPriorityMode] before calling the generator.
enum RequirementOption { equalSplitBodyPart, biasRankBodyPart, biasRankMuscle }

/// Configuration screen for Generate Custom Preset.
///
/// This screen collects user intent, validates the numeric inputs, builds a
/// [SessionSpec], and lets [PresetGenerationService] handle the actual exercise
/// selection, set allocation, and rep/weight generation.
class PresetGenerationQaScreen extends StatefulWidget {
  /// We need the current gym profile to filter exercises.
  final int profileId;
  final bool onboardingMode;

  const PresetGenerationQaScreen({
    super.key,
    required this.profileId,
    this.onboardingMode = false,
  });

  @override
  State<PresetGenerationQaScreen> createState() =>
      _PresetGenerationQaScreenState();
}

class _PresetGenerationQaScreenState extends State<PresetGenerationQaScreen> {
  final AppRepository _repo = AppRepository();
  final TextEditingController _sessionDurationController =
      TextEditingController();
  final TextEditingController _weeklyFrequencyController =
      TextEditingController();
  final TextEditingController _maxSetsController = TextEditingController();
  final TextEditingController _targetRepCountController =
      TextEditingController();

  RequirementOption? _requirementOption;
  RepWeightGenerationMode _repWeightMode = RepWeightGenerationMode.mixed;
  List<BodyPart> _bodyParts = const <BodyPart>[];
  Set<int> _preferredBodypartIds = <int>{};
  Set<int> _blacklistedBodypartIds = <int>{};

  bool _useRecentTrainingHistory = false;
  bool _isGenerating = false;
  bool _isDiscardingOnboardingPlans = false;
  final _onboardingGeneratedPlanIds = <int>[];

  @override
  void initState() {
    super.initState();
    _sessionDurationController.text = '60';
    _weeklyFrequencyController.text = '3';
    _maxSetsController.text = SessionSpec.defaultMaxSetsPerExercise.toString();
    _targetRepCountController.text =
        SessionSpec.defaultTargetRepCount.toString();
    _requirementOption = RequirementOption.equalSplitBodyPart;
    _loadBodyParts();
  }

  @override
  void dispose() {
    _sessionDurationController.dispose();
    _weeklyFrequencyController.dispose();
    _maxSetsController.dispose();
    _targetRepCountController.dispose();
    super.dispose();
  }

  /// Converts the UI allocation option into the generator's priority mode.
  TrainingPriorityMode _priorityModeForRequirement() {
    switch (_requirementOption) {
      case RequirementOption.biasRankBodyPart:
        return TrainingPriorityMode.bodyPartRanking;
      case RequirementOption.biasRankMuscle:
        return TrainingPriorityMode.muscleRanking;
      case RequirementOption.equalSplitBodyPart:
      case null:
        return TrainingPriorityMode.equalBodyPart;
    }
  }

  Future<void> _loadBodyParts() async {
    try {
      final bodyParts = await _repo.fetchAllBodyParts();
      if (!mounted) return;
      setState(() => _bodyParts = bodyParts);
    } catch (e) {
      debugPrint('Failed to load bodyparts for preset generation: $e');
    }
  }

  /// Validates the form and persists the generated preset.
  Future<void> _handleContinue() async {
    final minutesStr = _sessionDurationController.text.trim();
    final freqStr = _weeklyFrequencyController.text.trim();
    final maxSetsStr = _maxSetsController.text.trim();
    final targetRepCountStr = _targetRepCountController.text.trim();

    final sessionMinutes = int.tryParse(minutesStr);
    final weeklyFrequency = int.tryParse(freqStr);
    final maxSets = int.tryParse(maxSetsStr);
    final targetRepCount = int.tryParse(targetRepCountStr);

    if (sessionMinutes == null ||
        sessionMinutes <= 0 ||
        weeklyFrequency == null ||
        weeklyFrequency <= 0 ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise ||
        targetRepCount == null ||
        targetRepCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid duration, frequency, set limit, and rep values.',
          ),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final generator = PresetGenerationService(_repo);
      final priorityMode = _priorityModeForRequirement();

      final now = DateTime.now();

      const minSets = SessionSpec.defaultMinSetsPerExercise;
      final maxExercises = SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: sessionMinutes,
        minSetsPerExercise: minSets,
      );

      final spec = SessionSpec(
        profileId: widget.profileId,
        name: '',
        focusBodypartIds: const [],
        preferredBodypartIds: _preferredBodypartIds.toList(),
        blacklistedBodypartIds: _blacklistedBodypartIds.toList(),
        priorityMode: priorityMode,
        useGeneratedRepWeights: true,
        repWeightMode: _repWeightMode,
        targetRepCount: targetRepCount,
        maxExercises: maxExercises,
        minSetsPerExercise: minSets,
        maxSetsPerExercise: maxSets,
        sessionDurationMinutes: sessionMinutes,
        useRecentTrainingHistory: _useRecentTrainingHistory,
        historyWindow: const Duration(days: 7),
        now: now,
      );

      final result = await generator.generatePresetWithDetails(spec);

      if (!mounted) return;
      if (result.exercisesMissingWeightHistory.isNotEmpty) {
        await _showMissingWeightHistoryDialog(
          result.exercisesMissingWeightHistory,
        );
      }
      if (!mounted) return;
      if (widget.onboardingMode) {
        await ActivePlanStore.add(widget.profileId, result.presetId);
        if (!mounted) return;
        setState(() => _onboardingGeneratedPlanIds.add(result.presetId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generated plan added. Review it when ready.'),
          ),
        );
      } else {
        Navigator.of(context).pop(result.presetId);
      }
    } catch (e, st) {
      debugPrint('Error generating preset: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate preset: $e')));
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _discardOnboardingPlans() async {
    if (_isDiscardingOnboardingPlans) return;
    setState(() => _isDiscardingOnboardingPlans = true);
    try {
      for (final presetId in List<int>.from(_onboardingGeneratedPlanIds)) {
        await ActivePlanStore.remove(widget.profileId, presetId);
        await _repo.deletePreset(presetId);
      }
      if (!mounted) return;
      Navigator.of(context).pop<List<int>>(const <int>[]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not discard generated plans: $error')),
      );
      setState(() => _isDiscardingOnboardingPlans = false);
    }
  }

  void _finishOnboardingPlanGeneration() {
    if (_onboardingGeneratedPlanIds.isEmpty) return;
    Navigator.of(context).pop<List<int>>(
      List<int>.unmodifiable(_onboardingGeneratedPlanIds),
    );
  }

  Widget _buildSettingsSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }

  String _requirementSummary() {
    switch (_requirementOption) {
      case RequirementOption.biasRankBodyPart:
        return 'Bodypart ranking';
      case RequirementOption.biasRankMuscle:
        return 'Muscle ranking';
      case RequirementOption.equalSplitBodyPart:
      case null:
        return 'All bodyparts equally';
    }
  }

  String _repWeightModeLabel(RepWeightGenerationMode mode) {
    switch (mode) {
      case RepWeightGenerationMode.pyramid:
        return 'Pyramid';
      case RepWeightGenerationMode.consistent:
        return 'Consistent';
      case RepWeightGenerationMode.mixed:
        return 'Mixed';
    }
  }

  Future<void> _showMissingWeightHistoryDialog(List<String> exerciseNames) {
    final visibleNames = exerciseNames.take(6).toList();
    final extraCount = exerciseNames.length - visibleNames.length;
    final namesText = [
      ...visibleNames.map((name) => '- $name'),
      if (extraCount > 0) '- $extraCount more',
    ].join('\n');

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Some weights were left at 0 lbs'),
            content: Text(
              'You have not logged these exercises before, so we could not generate correct weights for them yet.\n\n$namesText',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(title: const Text('Generate Custom Presets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _isGenerating || _isDiscardingOnboardingPlans
                ? null
                : _handleContinue,
        icon:
            _isGenerating
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'Generating...' : 'Generate preset'),
      ),
      bottomNavigationBar: widget.onboardingMode
          ? _OnboardingPlanActionBar(
              addedCount: _onboardingGeneratedPlanIds.length,
              isBusy: _isDiscardingOnboardingPlans,
              onCancel: _discardOnboardingPlans,
              onSave: _onboardingGeneratedPlanIds.isEmpty
                  ? null
                  : _finishOnboardingPlanGeneration,
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          widget.onboardingMode ? 136 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Use the defaults, or open a section to tune how the preset is generated.',
            ),
            const SizedBox(height: 12),
            _buildSettingsSection(
              icon: Icons.timer_outlined,
              title: 'Workout setup',
              subtitle:
                  '${_sessionDurationController.text.trim()} min session, '
                  '${_maxSetsController.text.trim()} sets max per exercise',
              children: [
                const Text(
                  'How many minutes do you spend in the gym per session?',
                ),
                const SizedBox(height: 4),
                const Text(
                  'Estimated as 3 minutes per set plus 5 minutes to start each exercise.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sessionDurationController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 60',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('How many times per week do you work out?'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weeklyFrequencyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 5',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Up to how many sets per exercise? (${SessionSpec.defaultMinSetsPerExercise}-${SessionSpec.maxAllowedSetsPerExercise})',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxSetsController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 5',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSettingsSection(
              icon: Icons.track_changes_outlined,
              title: 'Training focus',
              subtitle:
                  '${_preferredBodypartIds.length} preferred, '
                  '${_blacklistedBodypartIds.length} avoided, '
                  '${_useRecentTrainingHistory ? 'using' : 'not using'} 7-day history',
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Generate based on 7-day workout history'),
                  subtitle: const Text(
                    'Uses recent completed sets to bias toward under-trained bodyparts and muscles.',
                  ),
                  value: _useRecentTrainingHistory,
                  onChanged:
                      (value) => setState(
                        () => _useRecentTrainingHistory = value ?? false,
                      ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bodypart focus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap once to prefer a bodypart, tap again to avoid it, and tap a third time to clear it.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                BodypartFocusChips(
                  bodyParts: _bodyParts,
                  preferredBodypartIds: _preferredBodypartIds,
                  blacklistedBodypartIds: _blacklistedBodypartIds,
                  emptyText: 'Bodyparts could not be loaded.',
                  onChanged:
                      (selection) => setState(() {
                        _preferredBodypartIds = selection.preferredBodypartIds;
                        _blacklistedBodypartIds =
                            selection.blacklistedBodypartIds;
                      }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSettingsSection(
              icon: Icons.fitness_center_outlined,
              title: 'Rep and weight generation',
              subtitle:
                  '${_repWeightModeLabel(_repWeightMode)}, '
                  '${_targetRepCountController.text.trim()} target reps',
              children: [
                RadioListTile<RepWeightGenerationMode>(
                  title: const Text('Mixed'),
                  subtitle: const Text(
                    'Pyramid for 3+ sets, consistent for 1-2 sets.',
                  ),
                  value: RepWeightGenerationMode.mixed,
                  groupValue: _repWeightMode,
                  onChanged:
                      (value) => setState(
                        () =>
                            _repWeightMode =
                                value ?? RepWeightGenerationMode.mixed,
                      ),
                ),
                RadioListTile<RepWeightGenerationMode>(
                  title: const Text('Pyramid'),
                  subtitle: const Text(
                    'Peak set uses your PR or Epley estimate; surrounding sets drop 10% weight and add 2 reps per step.',
                  ),
                  value: RepWeightGenerationMode.pyramid,
                  groupValue: _repWeightMode,
                  onChanged:
                      (value) => setState(
                        () =>
                            _repWeightMode =
                                value ?? RepWeightGenerationMode.pyramid,
                      ),
                ),
                RadioListTile<RepWeightGenerationMode>(
                  title: const Text('Consistent'),
                  subtitle: const Text(
                    'Every set uses the same reps and suggested weight.',
                  ),
                  value: RepWeightGenerationMode.consistent,
                  groupValue: _repWeightMode,
                  onChanged:
                      (value) => setState(
                        () =>
                            _repWeightMode =
                                value ?? RepWeightGenerationMode.consistent,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('Peak / target reps'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetRepCountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 6',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSettingsSection(
              icon: Icons.tune_outlined,
              title: 'Set allocation',
              subtitle: _requirementSummary(),
              children: [
                RadioListTile<RequirementOption>(
                  title: const Text('Train all bodyparts equally'),
                  value: RequirementOption.equalSplitBodyPart,
                  groupValue: _requirementOption,
                  onChanged: (v) => setState(() => _requirementOption = v),
                ),
                RadioListTile<RequirementOption>(
                  title: const Text('Train based on bodypart ranking'),
                  value: RequirementOption.biasRankBodyPart,
                  groupValue: _requirementOption,
                  onChanged: (v) => setState(() => _requirementOption = v),
                ),
                if (_requirementOption == RequirementOption.biasRankBodyPart)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BodyPartRankingScreen(),
                        ),
                      );
                    },
                    child: const Text('Rank Body Parts'),
                  ),
                RadioListTile<RequirementOption>(
                  title: const Text('Train based on muscle ranking'),
                  value: RequirementOption.biasRankMuscle,
                  groupValue: _requirementOption,
                  onChanged: (v) => setState(() => _requirementOption = v),
                ),
                if (_requirementOption == RequirementOption.biasRankMuscle)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MuscleRankingScreen(),
                        ),
                      );
                    },
                    child: const Text('Rank Muscles'),
                  ),
              ],
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );

    if (!widget.onboardingMode) return content;
    return PopScope<List<int>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _discardOnboardingPlans();
      },
      child: content,
    );
  }
}

class _OnboardingPlanActionBar extends StatelessWidget {
  final int addedCount;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  const _OnboardingPlanActionBar({
    required this.addedCount,
    required this.isBusy,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : onCancel,
                child: Text(isBusy ? 'Discarding...' : 'Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onSave,
                icon: _PlanCountBadge(count: addedCount),
                label: const Text('Review Plans'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  final int count;

  const _PlanCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.save_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: scheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
