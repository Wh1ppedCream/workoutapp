// File: lib/screens/exercise/preset_generation_qa.dart

import 'package:flutter/material.dart';
import '../profile/settings/bodypart_ranking_screen.dart';
import '../profile/settings/muscle_ranking_screen.dart';

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
  const PresetGenerationQaScreen({super.key});

  @override
  State<PresetGenerationQaScreen> createState() => _PresetGenerationQaScreenState();
}

class _PresetGenerationQaScreenState extends State<PresetGenerationQaScreen> {
  // Controllers for basic questions
  final TextEditingController _sessionDurationController = TextEditingController();
  final TextEditingController _weeklyFrequencyController = TextEditingController();

  // Requirement choice
  RequirementOption? _requirementOption;

  // Volume boundaries choice
  VolumeOption _volumeOption = VolumeOption.defaultBounds;

  // Failure times choice
  FailureOption _failureOption = FailureOption.never;

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
            const Text(
              'How many minutes do you spend in the gym per session?'
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

            // Weekly frequency
            const Text(
              'How many times per week do you work out?'
            ),
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

            ElevatedButton(
              onPressed: null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
