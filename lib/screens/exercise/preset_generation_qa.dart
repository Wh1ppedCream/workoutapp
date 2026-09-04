// File: lib/screens/exercise/preset_generation_qa.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../profile/settings/bodypart_ranking_screen.dart';
import '../profile/settings/muscle_ranking_screen.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/safe_failure_localizations.dart';
import '../../models/definition_models.dart';
import '../../repositories/app_repository.dart';
import '../../services/active_plan_store.dart';
import '../../services/preset_generation_service.dart';
import '../../services/tutorial_state_store.dart';
import '../../models/training_plan_models.dart';
import '../../widgets/bodypart_focus_chips.dart';
import '../../widgets/guided_tutorial_overlay.dart';
import '../../utils/tutorial_launcher.dart';

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
  AppRepository get _repo => context.read<AppRepository>();
  final _introTutorialKey = GlobalKey(debugLabel: 'generate_plans_intro');
  final _workoutSetupTutorialKey = GlobalKey(
    debugLabel: 'generate_plans_workout_setup',
  );
  final _focusTutorialKey = GlobalKey(debugLabel: 'generate_plans_focus');
  final _repWeightTutorialKey = GlobalKey(
    debugLabel: 'generate_plans_rep_weight',
  );
  final _allocationTutorialKey = GlobalKey(
    debugLabel: 'generate_plans_allocation',
  );
  final _generateTutorialKey = GlobalKey(debugLabel: 'generate_plans_button');
  final TextEditingController _sessionDurationController =
      TextEditingController();
  final TextEditingController _weeklyFrequencyController =
      TextEditingController();
  final TextEditingController _maxSetsController = TextEditingController();
  final TextEditingController _targetRepCountController =
      TextEditingController();

  RequirementOption? _requirementOption;
  RepWeightGenerationMode _repWeightMode = RepWeightGenerationMode.mixed;
  StarterWeightIntensity _starterWeightIntensity =
      StarterWeightIntensity.medium;
  List<BodyPart> _bodyParts = const <BodyPart>[];
  Set<int> _preferredBodypartIds = <int>{};
  Set<int> _blacklistedBodypartIds = <int>{};

  bool _useRecentTrainingHistory = false;
  bool _isGenerating = false;
  bool _isDiscardingOnboardingPlans = false;
  bool _tutorialQueued = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueTutorial();
    });
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
        tutorialId: TutorialIds.generatePlans,
        steps: [
          GuidedTutorialStep(
            targetKey: _introTutorialKey,
            icon: Icons.auto_awesome,
            title: strings.generateTutorialIntroTitle,
            body: strings.generateTutorialIntroBody,
          ),
          GuidedTutorialStep(
            targetKey: _workoutSetupTutorialKey,
            icon: Icons.timer_outlined,
            title: strings.generateWorkoutSetupTitle,
            body: strings.generateTutorialSetupBody,
          ),
          GuidedTutorialStep(
            targetKey: _focusTutorialKey,
            icon: Icons.track_changes_outlined,
            title: strings.generateTrainingFocusTitle,
            body: strings.generateTutorialFocusBody,
          ),
          GuidedTutorialStep(
            targetKey: _repWeightTutorialKey,
            icon: Icons.fitness_center_outlined,
            title: strings.generateRepsWeightsTitle,
            body: strings.generateTutorialRepsBody,
          ),
          GuidedTutorialStep(
            targetKey: _allocationTutorialKey,
            icon: Icons.tune_outlined,
            title: strings.generateSetAllocationTitle,
            body: strings.generateTutorialAllocationBody,
          ),
          GuidedTutorialStep(
            targetKey: _generateTutorialKey,
            icon: Icons.play_arrow,
            title: strings.generateTutorialGenerateTitle,
            body: strings.generateTutorialGenerateBody,
          ),
        ],
      );
    } finally {
      _tutorialQueued = false;
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
        SnackBar(
          content: Text(AppLocalizations.of(context).generateValidationError),
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
        starterWeightIntensity: _starterWeightIntensity,
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
          SnackBar(
            content: Text(AppLocalizations.of(context).generateNoViablePlans),
          ),
        );
        return;
      }

      final starterEstimateSet = <String>{};
      final unavailableStarterSet = <String>{};
      for (final result in bundleResult.plans) {
        starterEstimateSet.addAll(result.exercisesWithStarterWeightEstimates);
        unavailableStarterSet.addAll(
          result.exercisesWithUnavailableStarterWeights,
        );
      }
      final starterEstimateNames = starterEstimateSet.toList()..sort();
      final unavailableStarterNames = unavailableStarterSet.toList()..sort();
      if (starterEstimateNames.isNotEmpty ||
          unavailableStarterNames.isNotEmpty) {
        await _showStarterWeightDialog(
          starterEstimateNames: starterEstimateNames,
          unavailableStarterNames: unavailableStarterNames,
        );
      }
      if (!mounted) return;
      if (widget.onboardingMode) {
        final activePlanStore = context.read<ActivePlanStore>();
        for (final presetId in generatedPlanIds) {
          await activePlanStore.add(widget.profileId, presetId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).generateFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _discardOnboardingPlans() async {
    if (_isDiscardingOnboardingPlans) return;
    final activePlanStore = context.read<ActivePlanStore>();
    final repository = _repo;
    setState(() => _isDiscardingOnboardingPlans = true);
    try {
      for (final presetId in List<int>.from(_onboardingGeneratedPlanIds)) {
        await activePlanStore.remove(widget.profileId, presetId);
        await repository.deletePreset(presetId);
      }
      if (!mounted) return;
      Navigator.of(context).pop<List<int>>(const <int>[]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).generateDiscardFailed(
              safeFailureMessage(AppLocalizations.of(context), error),
            ),
          ),
        ),
      );
      setState(() => _isDiscardingOnboardingPlans = false);
    }
  }

  void _finishOnboardingPlanGeneration() {
    if (_onboardingGeneratedPlanIds.isEmpty) return;
    Navigator.of(
      context,
    ).pop<List<int>>(List<int>.unmodifiable(_onboardingGeneratedPlanIds));
  }

  String _fieldValue(TextEditingController controller, String fallback) {
    final value = controller.text.trim();
    return value.isEmpty ? fallback : value;
  }

  Widget _buildIntroCard() {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
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
                      strings.generateIntroTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.generateIntroBody,
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
    final strings = AppLocalizations.of(context);
    final planCount =
        int.tryParse(_fieldValue(_weeklyFrequencyController, '1')) ?? 1;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSummaryPill(
          icon: Icons.calendar_month_outlined,
          text: strings.generatePlanCountPill(planCount),
        ),
        _buildSummaryPill(
          icon: Icons.timer_outlined,
          text: strings.generateDurationPill(
            _fieldValue(_sessionDurationController, '60'),
          ),
        ),
        _buildSummaryPill(
          icon: Icons.format_list_numbered_outlined,
          text: strings.generateMaxSetsPill(
            _fieldValue(
              _maxSetsController,
              SessionSpec.defaultMaxSetsPerExercise.toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPill({required IconData icon, required String text}) {
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
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
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
        color:
            selected
                ? scheme.primary.withValues(alpha: 0.72)
                : scheme.outlineVariant.withValues(alpha: 0.58),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color:
            selected
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
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
    final strings = AppLocalizations.of(context);
    switch (_requirementOption) {
      case RequirementOption.biasRankBodyPart:
        return strings.generateRequirementBodyparts;
      case RequirementOption.biasRankMuscle:
        return strings.generateRequirementMuscles;
      case RequirementOption.equalSplitBodyPart:
      case null:
        return strings.generateRequirementEven;
    }
  }

  String _repWeightModeLabel(RepWeightGenerationMode mode) {
    final strings = AppLocalizations.of(context);
    switch (mode) {
      case RepWeightGenerationMode.pyramid:
        return strings.repModePyramid;
      case RepWeightGenerationMode.consistent:
        return strings.repModeConsistent;
      case RepWeightGenerationMode.mixed:
        return strings.repModeMixed;
    }
  }

  String _starterWeightIntensityLabel(StarterWeightIntensity intensity) {
    final strings = AppLocalizations.of(context);
    switch (intensity) {
      case StarterWeightIntensity.easy:
        return strings.intensityEasy;
      case StarterWeightIntensity.medium:
        return strings.intensityMedium;
      case StarterWeightIntensity.hard:
        return strings.intensityHard;
    }
  }

  String _generateButtonLabel() {
    final strings = AppLocalizations.of(context);
    if (_isGenerating) return strings.generateGenerating;
    final count = int.tryParse(_weeklyFrequencyController.text.trim()) ?? 1;
    return strings.generateButton(count);
  }

  String _generatedPlansMessage({
    required int generated,
    required int requested,
  }) {
    final strings = AppLocalizations.of(context);
    if (generated < requested) {
      return strings.generatePartialMessage(generated, requested);
    }
    return strings.generateSuccessMessage(generated);
  }

  Future<void> _showStarterWeightDialog({
    required List<String> starterEstimateNames,
    required List<String> unavailableStarterNames,
  }) {
    final strings = AppLocalizations.of(context);
    String namesText(List<String> names) {
      final visibleNames = names.take(6).toList();
      final extraCount = names.length - visibleNames.length;
      return [
        ...visibleNames.map((name) => '- $name'),
        if (extraCount > 0) '- ${strings.generateMoreNames(extraCount)}',
      ].join('\n');
    }

    final body = [
      if (starterEstimateNames.isNotEmpty) ...[
        strings.generateStarterEstimatedBody,
        '',
        namesText(starterEstimateNames),
      ],
      if (unavailableStarterNames.isNotEmpty) ...[
        if (starterEstimateNames.isNotEmpty) '',
        strings.generateStarterUnavailableBody,
        '',
        namesText(unavailableStarterNames),
      ],
    ].join('\n');

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(strings.generateStarterDialogTitle),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.commonOkay),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final content = Scaffold(
      appBar: AppBar(title: Text(strings.generatePageTitle)),
      floatingActionButton: KeyedSubtree(
        key: _generateTutorialKey,
        child: FloatingActionButton.extended(
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
      ),
      bottomNavigationBar:
          widget.onboardingMode
              ? _OnboardingPlanActionBar(
                addedCount: _onboardingGeneratedPlanIds.length,
                isBusy: _isDiscardingOnboardingPlans,
                onCancel: _discardOnboardingPlans,
                onSave:
                    _onboardingGeneratedPlanIds.isEmpty
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
            KeyedSubtree(key: _introTutorialKey, child: _buildIntroCard()),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: _workoutSetupTutorialKey,
              child: _buildSettingsSection(
                icon: Icons.timer_outlined,
                title: strings.generateWorkoutSetupTitle,
                subtitle: strings.generateSetupSummary(
                  _fieldValue(_weeklyFrequencyController, '1'),
                  _fieldValue(_sessionDurationController, '60'),
                  _fieldValue(
                    _maxSetsController,
                    SessionSpec.defaultMaxSetsPerExercise.toString(),
                  ),
                ),
                children: [
                  _buildNumberField(
                    controller: _sessionDurationController,
                    label: strings.generateSessionLength,
                    hintText: '60',
                    helperText: strings.generateSessionLengthHelp,
                    suffixText: strings.unitMinutesShort,
                  ),
                  const SizedBox(height: 14),
                  _buildNumberField(
                    controller: _weeklyFrequencyController,
                    label: strings.generatePlansToCreate,
                    hintText: '1',
                    helperText: strings.generatePlansToCreateHelp(
                      SessionSpec.maxGeneratedPlansPerBundle,
                    ),
                    suffixText: strings.unitPlans,
                  ),
                  const SizedBox(height: 14),
                  _buildNumberField(
                    controller: _maxSetsController,
                    label: strings.generateMaxSetsPerExercise,
                    hintText: SessionSpec.defaultMaxSetsPerExercise.toString(),
                    helperText: strings.generateSetLimitHelp(
                      SessionSpec.defaultMinSetsPerExercise,
                      SessionSpec.maxAllowedSetsPerExercise,
                    ),
                    suffixText: strings.unitSets,
                  ),
                ],
              ),
            ),
            KeyedSubtree(
              key: _focusTutorialKey,
              child: _buildSettingsSection(
                icon: Icons.track_changes_outlined,
                title: strings.generateTrainingFocusTitle,
                subtitle: strings.generateFocusSummary(
                  _preferredBodypartIds.length,
                  _blacklistedBodypartIds.length,
                  _useRecentTrainingHistory
                      ? strings.generateHistoryUsing
                      : strings.generateHistoryNotUsing,
                ),
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.generateUseRecentTraining),
                    subtitle: Text(strings.generateUseRecentTrainingBody),
                    value: _useRecentTrainingHistory,
                    onChanged:
                        (value) => setState(
                          () => _useRecentTrainingHistory = value ?? false,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.optimizedBodypartFocusTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.generateBodypartFocusInstruction,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  BodypartFocusChips(
                    bodyParts: _bodyParts,
                    preferredBodypartIds: _preferredBodypartIds,
                    blacklistedBodypartIds: _blacklistedBodypartIds,
                    emptyText: strings.optimizedBodypartsUnavailable,
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
            KeyedSubtree(
              key: _repWeightTutorialKey,
              child: _buildSettingsSection(
                icon: Icons.fitness_center_outlined,
                title: strings.generateRepsWeightsTitle,
                subtitle: strings.generateRepsSummary(
                  _repWeightModeLabel(_repWeightMode),
                  _fieldValue(
                    _targetRepCountController,
                    SessionSpec.defaultTargetRepCount.toString(),
                  ),
                  _starterWeightIntensityLabel(_starterWeightIntensity),
                ),
                children: [
                  _buildChoiceTile<RepWeightGenerationMode>(
                    title: strings.repModeMixed,
                    subtitle: strings.generateMixedBody,
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
                    title: strings.repModePyramid,
                    subtitle: strings.generatePyramidBody,
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
                    title: strings.repModeConsistent,
                    subtitle: strings.generateConsistentBody,
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
                    label: strings.optimizedTargetReps,
                    hintText: SessionSpec.defaultTargetRepCount.toString(),
                    helperText: strings.generateTargetRepsHelp,
                    suffixText: strings.unitReps,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    strings.optimizedWeightIntensity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildChoiceTile<StarterWeightIntensity>(
                    title: strings.intensityEasy,
                    subtitle: strings.generateEasyBody,
                    value: StarterWeightIntensity.easy,
                    groupValue: _starterWeightIntensity,
                    onChanged:
                        (value) => setState(
                          () =>
                              _starterWeightIntensity =
                                  value ?? StarterWeightIntensity.easy,
                        ),
                  ),
                  _buildChoiceTile<StarterWeightIntensity>(
                    title: strings.intensityMedium,
                    subtitle: strings.generateMediumBody,
                    value: StarterWeightIntensity.medium,
                    groupValue: _starterWeightIntensity,
                    onChanged:
                        (value) => setState(
                          () =>
                              _starterWeightIntensity =
                                  value ?? StarterWeightIntensity.medium,
                        ),
                  ),
                  _buildChoiceTile<StarterWeightIntensity>(
                    title: strings.intensityHard,
                    subtitle: strings.generateHardBody,
                    value: StarterWeightIntensity.hard,
                    groupValue: _starterWeightIntensity,
                    onChanged:
                        (value) => setState(
                          () =>
                              _starterWeightIntensity =
                                  value ?? StarterWeightIntensity.hard,
                        ),
                  ),
                ],
              ),
            ),
            KeyedSubtree(
              key: _allocationTutorialKey,
              child: _buildSettingsSection(
                icon: Icons.tune_outlined,
                title: strings.generateSetAllocationTitle,
                subtitle: _requirementSummary(),
                children: [
                  _buildChoiceTile<RequirementOption>(
                    title: strings.generateEvenCoverageTitle,
                    subtitle: strings.generateEvenCoverageBody,
                    value: RequirementOption.equalSplitBodyPart,
                    groupValue: _requirementOption,
                    onChanged: (v) => setState(() => _requirementOption = v),
                  ),
                  _buildChoiceTile<RequirementOption>(
                    title: strings.generateBodypartRankingsTitle,
                    subtitle: strings.generateBodypartRankingsBody,
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
                      child: Text(strings.generateRankBodyparts),
                    ),
                  _buildChoiceTile<RequirementOption>(
                    title: strings.generateMuscleRankingsTitle,
                    subtitle: strings.generateMuscleRankingsBody,
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
                      child: Text(strings.generateRankMuscles),
                    ),
                ],
              ),
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
    final strings = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : onCancel,
                child: Text(
                  isBusy ? strings.generateDiscarding : strings.commonCancel,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onSave,
                icon: _PlanCountBadge(count: addedCount),
                label: Text(strings.generateReviewPlans),
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
