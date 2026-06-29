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
    _weeklyFrequencyController.text = '1';
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
        weeklyFrequency > SessionSpec.maxGeneratedPlansPerBundle ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise ||
        targetRepCount == null ||
        targetRepCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid duration, plan count, set limit, and rep values.',
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

      final bundleResult = await generator.generatePresetBundle(
        spec,
        planCount: weeklyFrequency,
      );
      final generatedPlanIds =
          bundleResult.plans.map((result) => result.presetId).toList();

      if (!mounted) return;
      if (generatedPlanIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No viable plans could be generated with the current settings.',
            ),
          ),
        );
        return;
      }

      final missingWeightHistorySet = <String>{};
      for (final result in bundleResult.plans) {
        missingWeightHistorySet.addAll(result.exercisesMissingWeightHistory);
      }
      final missingWeightHistoryNames = missingWeightHistorySet.toList()
        ..sort();
      if (missingWeightHistoryNames.isNotEmpty) {
        await _showMissingWeightHistoryDialog(missingWeightHistoryNames);
      }
      if (!mounted) return;
      if (widget.onboardingMode) {
        for (final presetId in generatedPlanIds) {
          await ActivePlanStore.add(widget.profileId, presetId);
        }
        if (!mounted) return;
        setState(() => _onboardingGeneratedPlanIds.addAll(generatedPlanIds));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _generatedPlansMessage(
                generated: bundleResult.generatedCount,
                requested: bundleResult.requestedCount,
              ),
            ),
          ),
        );
      } else {
        if (bundleResult.isPartial) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _generatedPlansMessage(
                  generated: bundleResult.generatedCount,
                  requested: bundleResult.requestedCount,
                ),
              ),
            ),
          );
        }
        Navigator.of(context).pop<List<int>>(generatedPlanIds);
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

  String _fieldValue(TextEditingController controller, String fallback) {
    final value = controller.text.trim();
    return value.isEmpty ? fallback : value;
  }

  Widget _buildIntroCard() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.46),
            scheme.surfaceContainerHighest.withValues(alpha: 0.58),
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.auto_awesome, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build your plan week',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create one plan or a balanced bundle using your profile, focus, and limits.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryPills(),
        ],
      ),
    );
  }

  Widget _buildSummaryPills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSummaryPill(
          icon: Icons.calendar_month_outlined,
          text: '${_fieldValue(_weeklyFrequencyController, '1')} plan(s)',
        ),
        _buildSummaryPill(
          icon: Icons.timer_outlined,
          text: '${_fieldValue(_sessionDurationController, '60')} min',
        ),
        _buildSummaryPill(
          icon: Icons.format_list_numbered_outlined,
          text:
              '${_fieldValue(_maxSetsController, SessionSpec.defaultMaxSetsPerExercise.toString())} sets max',
        ),
      ],
    );
  }

  Widget _buildSummaryPill({
    required IconData icon,
    required String text,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String helperText,
    String? suffixText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.78),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            fillColor: scheme.surface.withValues(alpha: 0.54),
            border: border,
            enabledBorder: border,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChoiceTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value == groupValue;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: selected
            ? scheme.primary.withValues(alpha: 0.72)
            : scheme.outlineVariant.withValues(alpha: 0.58),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.24)
            : scheme.surface.withValues(alpha: 0.38),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: RadioListTile<T>(
          value: value,
          groupValue: groupValue,
          selected: selected,
          onChanged: onChanged,
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: shape,
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
      ),
    );
  }

  String _requirementSummary() {
    switch (_requirementOption) {
      case RequirementOption.biasRankBodyPart:
        return 'Bodypart rankings';
      case RequirementOption.biasRankMuscle:
        return 'Muscle rankings';
      case RequirementOption.equalSplitBodyPart:
      case null:
        return 'Even coverage';
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

  String _generateButtonLabel() {
    if (_isGenerating) return 'Generating...';
    final count = int.tryParse(_weeklyFrequencyController.text.trim()) ?? 1;
    return count <= 1 ? 'Generate plan' : 'Generate $count plans';
  }

  String _generatedPlansMessage({
    required int generated,
    required int requested,
  }) {
    final planWord = requested == 1 ? 'plan' : 'plans';
    if (generated < requested) {
      return 'Generated $generated of $requested $planWord. Your current settings limited the rest.';
    }
    return generated == 1
        ? 'Generated plan added. Review it when ready.'
        : 'Generated $generated plans. Review them when ready.';
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
      appBar: AppBar(title: const Text('Generate Plans')),
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
        label: Text(_generateButtonLabel()),
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
            _buildIntroCard(),
            const SizedBox(height: 14),
            _buildSettingsSection(
              icon: Icons.timer_outlined,
              title: 'Workout setup',
              subtitle:
                  '${_fieldValue(_weeklyFrequencyController, '1')} plan(s), '
                  '${_fieldValue(_sessionDurationController, '60')} min, '
                  '${_fieldValue(_maxSetsController, SessionSpec.defaultMaxSetsPerExercise.toString())} max sets',
              children: [
                _buildNumberField(
                  controller: _sessionDurationController,
                  label: 'Session length',
                  hintText: '60',
                  helperText: 'Estimated as 3 min/set + 5 min/exercise.',
                  suffixText: 'min',
                ),
                const SizedBox(height: 14),
                _buildNumberField(
                  controller: _weeklyFrequencyController,
                  label: 'Plans to create',
                  hintText: '1',
                  helperText:
                      'Usually matches training days/week. Max ${SessionSpec.maxGeneratedPlansPerBundle}.',
                  suffixText: 'plans',
                ),
                const SizedBox(height: 14),
                _buildNumberField(
                  controller: _maxSetsController,
                  label: 'Max sets per exercise',
                  hintText: SessionSpec.defaultMaxSetsPerExercise.toString(),
                  helperText:
                      '${SessionSpec.defaultMinSetsPerExercise}-${SessionSpec.maxAllowedSetsPerExercise} sets allowed.',
                  suffixText: 'sets',
                ),
              ],
            ),
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
                  title: const Text('Use recent training'),
                  subtitle: const Text(
                    'Bias toward under-trained areas from the last 7 days.',
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
                  'Tap once to prefer, twice to avoid, third to clear.',
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
            _buildSettingsSection(
              icon: Icons.fitness_center_outlined,
              title: 'Reps & weights',
              subtitle:
                  '${_repWeightModeLabel(_repWeightMode)}, '
                  '${_fieldValue(_targetRepCountController, SessionSpec.defaultTargetRepCount.toString())} target reps',
              children: [
                _buildChoiceTile<RepWeightGenerationMode>(
                  title: 'Mixed',
                  subtitle: 'Pyramid for 3+ sets; steady for shorter work.',
                  value: RepWeightGenerationMode.mixed,
                  groupValue: _repWeightMode,
                  onChanged:
                      (value) => setState(
                        () =>
                            _repWeightMode =
                                value ?? RepWeightGenerationMode.mixed,
                      ),
                ),
                _buildChoiceTile<RepWeightGenerationMode>(
                  title: 'Pyramid',
                  subtitle: 'Peak set uses PR/Epley; nearby sets get lighter.',
                  value: RepWeightGenerationMode.pyramid,
                  groupValue: _repWeightMode,
                  onChanged:
                      (value) => setState(
                        () =>
                            _repWeightMode =
                                value ?? RepWeightGenerationMode.pyramid,
                      ),
                ),
                _buildChoiceTile<RepWeightGenerationMode>(
                  title: 'Consistent',
                  subtitle: 'Same reps and suggested weight each set.',
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
                _buildNumberField(
                  controller: _targetRepCountController,
                  label: 'Target reps',
                  hintText: SessionSpec.defaultTargetRepCount.toString(),
                  helperText: 'Peak reps for pyramid; steady reps otherwise.',
                  suffixText: 'reps',
                ),
              ],
            ),
            _buildSettingsSection(
              icon: Icons.tune_outlined,
              title: 'Set allocation',
              subtitle: _requirementSummary(),
              children: [
                _buildChoiceTile<RequirementOption>(
                  title: 'Even bodypart coverage',
                  subtitle: 'Spread work broadly across available bodyparts.',
                  value: RequirementOption.equalSplitBodyPart,
                  groupValue: _requirementOption,
                  onChanged: (v) => setState(() => _requirementOption = v),
                ),
                _buildChoiceTile<RequirementOption>(
                  title: 'Use bodypart rankings',
                  subtitle: 'Give higher-ranked bodyparts more planned work.',
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
                _buildChoiceTile<RequirementOption>(
                  title: 'Use muscle rankings',
                  subtitle: 'Allocate work from your ranked muscle priorities.',
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
