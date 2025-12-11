// File: lib/screens/exercise/preset_generation_qa.dart

import 'package:flutter/material.dart';
import '../profile/settings/bodypart_ranking_screen.dart';
import '../profile/settings/muscle_ranking_screen.dart';

// NEW imports
import '../../repositories/app_repository.dart';
import '../../services/preset_generation_service.dart';
import '../../models/training_plan_models.dart';

// Enums must be top-level declarations
enum RequirementOption {
  equalSplitBodyPart,
  equalSplitMuscle,
  biasRankBodyPart,
  biasRankMuscle,
  exactSetBodyPart,
  exactSetMuscle,
}
enum VolumeOption { defaultBounds, combinedMuscle, combinedBodyPart }
enum FailureOption { never, once, twice, everySet }

class PresetGenerationQaScreen extends StatefulWidget {
  /// We need the current gym profile to filter exercises.
  final int profileId;

  const PresetGenerationQaScreen({
    super.key,
    required this.profileId,
  });

  @override
  State<PresetGenerationQaScreen> createState() =>
      _PresetGenerationQaScreenState();
}

class _PresetGenerationQaScreenState extends State<PresetGenerationQaScreen> {
  // Controllers for basic questions
  final TextEditingController _sessionDurationController =
      TextEditingController();
  final TextEditingController _weeklyFrequencyController =
      TextEditingController();

  // Requirement choice
  RequirementOption? _requirementOption;

  // Volume boundaries choice
  VolumeOption _volumeOption = VolumeOption.defaultBounds;

  // Failure times choice
  FailureOption _failureOption = FailureOption.never;

  // NEW: loading state while generating
  bool _isGenerating = false;

  @override
  void dispose() {
    _sessionDurationController.dispose();
    _weeklyFrequencyController.dispose();
    super.dispose();
  }

  void _showExactSetDialog({required bool forBodyPart}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(forBodyPart
              ? 'Exact Sets per BodyPart'
              : 'Exact Sets per Muscle'),
          content: const Text('Dialog to set exact sets to be implemented.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NEW: handler for "Continue" → generate preset
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleContinue() async {
    final minutesStr = _sessionDurationController.text.trim();
    final freqStr = _weeklyFrequencyController.text.trim();

    final sessionMinutes = int.tryParse(minutesStr);
    final weeklyFrequency = int.tryParse(freqStr);

    if (sessionMinutes == null ||
        sessionMinutes <= 0 ||
        weeklyFrequency == null ||
        weeklyFrequency <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for duration and frequency.'),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final repo = AppRepository();
      final generator = PresetGenerationService(repo);

      // For now, we keep this simple:
      // - use all bodyparts (focusBodypartIds = [])
      // - sets/exercises based roughly on session length
      //
      // You can later refine this to use _requirementOption, _volumeOption,
      // and _failureOption to tweak maxExercises / minSets / etc.
      final now = DateTime.now();

      // Rough heuristic: more minutes → more exercises
      final maxExercises = (sessionMinutes / 10).clamp(4, 10).toInt();

      // Simple sets per exercise; you can tweak this later
      final minSets = 3;
      final maxSets = 5;

      final spec = SessionSpec(
        profileId: widget.profileId,
        name: 'Auto preset ${now.year}-${now.month}-${now.day}',
        focusBodypartIds: const [], // TODO: later tie this to requirementOption
        maxExercises: maxExercises,
        minSetsPerExercise: minSets,
        maxSetsPerExercise: maxSets,
        // For now, look at the last 7 days of history
        historyWindow: const Duration(days: 7),
        now: now,
      );

      final presetId = await generator.generatePreset(spec);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Preset #$presetId generated successfully!')),
);


      // TODO: Navigate to your preset editor/details screen.
      // For example, if you have a screen that uses PresetSession:
      //
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => PresetDetailScreen(presetId: presetId),
      //   ),
      // );
    } catch (e, st) {
      debugPrint('Error generating preset: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate preset: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Custom Presets'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session duration
            const Text('How many minutes do you spend in the gym per session?'),
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

            // Weekly frequency
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

            // Requirements header
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
              title: const Text('Equal split per Muscle'),
              value: RequirementOption.equalSplitMuscle,
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
            RadioListTile<RequirementOption>(
              title: const Text('Exact set requirements per BodyPart'),
              value: RequirementOption.exactSetBodyPart,
              groupValue: _requirementOption,
              onChanged: (v) {
                setState(() => _requirementOption = v);
                if (v == RequirementOption.exactSetBodyPart) {
                  _showExactSetDialog(forBodyPart: true);
                }
              },
            ),
            RadioListTile<RequirementOption>(
              title: const Text('Exact set requirements per Muscle'),
              value: RequirementOption.exactSetMuscle,
              groupValue: _requirementOption,
              onChanged: (v) {
                setState(() => _requirementOption = v);
                if (v == RequirementOption.exactSetMuscle) {
                  _showExactSetDialog(forBodyPart: false);
                }
              },
            ),
            const SizedBox(height: 24),

            // Volume boundaries
            const Text(
              'Manage volume boundaries',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<VolumeOption>(
              title: const Text('Use default volume boundaries'),
              value: VolumeOption.defaultBounds,
              groupValue: _volumeOption,
              onChanged: (v) => setState(() => _volumeOption = v!),
            ),
            RadioListTile<VolumeOption>(
              title: const Text('Combined volume boundaries (Muscles)'),
              value: VolumeOption.combinedMuscle,
              groupValue: _volumeOption,
              onChanged: (v) => setState(() => _volumeOption = v!),
            ),
            RadioListTile<VolumeOption>(
              title: const Text('Combined volume boundaries (BodyParts)'),
              value: VolumeOption.combinedBodyPart,
              groupValue: _volumeOption,
              onChanged: (v) => setState(() => _volumeOption = v!),
            ),
            const SizedBox(height: 24),

            // Failure times
            const Text(
              'Number of times to go till failure per exercise',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<FailureOption>(
              title: const Text('Never'),
              value: FailureOption.never,
              groupValue: _failureOption,
              onChanged: (v) => setState(() => _failureOption = v!),
            ),
            RadioListTile<FailureOption>(
              title: const Text('Once per exercise'),
              value: FailureOption.once,
              groupValue: _failureOption,
              onChanged: (v) => setState(() => _failureOption = v!),
            ),
            RadioListTile<FailureOption>(
              title: const Text('Twice per exercise'),
              value: FailureOption.twice,
              groupValue: _failureOption,
              onChanged: (v) => setState(() => _failureOption = v!),
            ),
            RadioListTile<FailureOption>(
              title: const Text('Every set'),
              value: FailureOption.everySet,
              groupValue: _failureOption,
              onChanged: (v) => setState(() => _failureOption = v!),
            ),
            const SizedBox(height: 24),

            // NEW: Generate button
            ElevatedButton(
              onPressed: _isGenerating ? null : _handleContinue,
              child: _isGenerating
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
