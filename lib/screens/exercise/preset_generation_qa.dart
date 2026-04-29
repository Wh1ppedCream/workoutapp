// File: lib/screens/exercise/preset_generation_qa.dart

import 'package:flutter/material.dart';
import '../profile/settings/bodypart_ranking_screen.dart';
import '../profile/settings/muscle_ranking_screen.dart';

import '../../repositories/app_repository.dart';
import '../../services/preset_generation_service.dart';
import '../../models/training_plan_models.dart';

enum RequirementOption { equalSplitBodyPart, biasRankBodyPart, biasRankMuscle }

class PresetGenerationQaScreen extends StatefulWidget {
  /// We need the current gym profile to filter exercises.
  final int profileId;

  const PresetGenerationQaScreen({super.key, required this.profileId});

  @override
  State<PresetGenerationQaScreen> createState() =>
      _PresetGenerationQaScreenState();
}

class _PresetGenerationQaScreenState extends State<PresetGenerationQaScreen> {
  final TextEditingController _sessionDurationController =
      TextEditingController();
  final TextEditingController _weeklyFrequencyController =
      TextEditingController();
  final TextEditingController _maxSetsController = TextEditingController();

  RequirementOption? _requirementOption;

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _sessionDurationController.text = '60';
    _weeklyFrequencyController.text = '3';
    _maxSetsController.text = SessionSpec.defaultMaxSetsPerExercise.toString();
    _requirementOption = RequirementOption.equalSplitBodyPart;
  }

  @override
  void dispose() {
    _sessionDurationController.dispose();
    _weeklyFrequencyController.dispose();
    _maxSetsController.dispose();
    super.dispose();
  }

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

  Future<void> _handleContinue() async {
    final minutesStr = _sessionDurationController.text.trim();
    final freqStr = _weeklyFrequencyController.text.trim();
    final maxSetsStr = _maxSetsController.text.trim();

    final sessionMinutes = int.tryParse(minutesStr);
    final weeklyFrequency = int.tryParse(freqStr);
    final maxSets = int.tryParse(maxSetsStr);

    if (sessionMinutes == null ||
        sessionMinutes <= 0 ||
        weeklyFrequency == null ||
        weeklyFrequency <= 0 ||
        maxSets == null ||
        maxSets < SessionSpec.defaultMinSetsPerExercise ||
        maxSets > SessionSpec.maxAllowedSetsPerExercise) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid duration, frequency, and set limit values.',
          ),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final repo = AppRepository();
      final generator = PresetGenerationService(repo);
      final priorityMode = _priorityModeForRequirement();

      final now = DateTime.now();

      const minSets = SessionSpec.defaultMinSetsPerExercise;
      final maxExercises = SessionSpec.maxExercisesForDuration(
        sessionDurationMinutes: sessionMinutes,
        minSetsPerExercise: minSets,
      );

      final spec = SessionSpec(
        profileId: widget.profileId,
        name: 'Custom preset ${now.year}-${now.month}-${now.day}',
        focusBodypartIds: const [],
        priorityMode: priorityMode,
        maxExercises: maxExercises,
        minSetsPerExercise: minSets,
        maxSetsPerExercise: maxSets,
        sessionDurationMinutes: sessionMinutes,
        historyWindow: const Duration(days: 7),
        now: now,
      );

      final presetId = await generator.generatePreset(spec);

      if (!mounted) return;
      Navigator.of(context).pop(presetId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Custom Presets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('How many minutes do you spend in the gym per session?'),
            const SizedBox(height: 4),
            const Text(
              'Estimated as 3 minutes per set plus 5 minutes to start each exercise.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _sessionDurationController,
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 24),

            Text(
              'Up to how many sets per exercise? (${SessionSpec.defaultMinSetsPerExercise}-${SessionSpec.maxAllowedSetsPerExercise})',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _maxSetsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. 5',
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Set requirements for generated preset',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<RequirementOption>(
              title: const Text('Equal split per BodyPart'),
              value: RequirementOption.equalSplitBodyPart,
              groupValue: _requirementOption,
              onChanged: (v) => setState(() => _requirementOption = v),
            ),
            RadioListTile<RequirementOption>(
              title: const Text('Based on BodyPart ranking bias'),
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
              title: const Text('Based on Muscle ranking bias'),
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
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isGenerating ? null : _handleContinue,
              child:
                  _isGenerating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Generate preset'),
            ),
          ],
        ),
      ),
    );
  }
}
