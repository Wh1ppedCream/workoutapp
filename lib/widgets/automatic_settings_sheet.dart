// File: lib/widgets/automatic_settings_sheet.dart

import 'package:flutter/material.dart';
import '../providers/preset_session.dart';
import '../models/models.dart';

/// Bottom sheet for editing Automatic Preset settings:
/// - Global increment amount
/// - Skip first set?
/// - Per-exercise and per-set overrides
class AutomaticSettingsSheet extends StatefulWidget {
  final PresetSession preset;

  const AutomaticSettingsSheet({super.key, required this.preset});

  @override
  State<AutomaticSettingsSheet> createState() => _AutomaticSettingsSheetState();
}

class _AutomaticSettingsSheetState extends State<AutomaticSettingsSheet> {
  late TextEditingController _globalController;
  late bool _skipFirst;

  // NEW:
  bool _showMethods = false;

  /// One controller per exercise override
  final Map<int, TextEditingController> _exControllers = {};

  /// One controller per set override (parents + children)
  final Map<int, TextEditingController> _setControllers = {};

  @override
  void initState() {
    super.initState();

    final preset = widget.preset;
    
    

    // Global
    _globalController = TextEditingController(
      text: preset.globalIncrement.toString(),
    );
    _skipFirst = preset.skipFirstSet;

    // Per-exercise controllers
    for (var exId in preset.presetExerciseIds) {
      _exControllers[exId] = TextEditingController(
        text: preset.exerciseIncrementOverrides[exId]?.toString() ?? '',
      );
    }

    // Per-set controllers (parents)
    for (var parentList in preset.presetParentSetIds) {
      for (var setId in parentList) {
        _setControllers[setId] = TextEditingController(
          text: preset.setIncrementOverrides[setId]?.toString() ?? '',
        );
      }
    }
    // Per-set controllers (children)
    for (var childMap in preset.presetChildSetIds) {
      for (var entry in childMap.entries) {
        for (var setId in entry.value) {
          _setControllers[setId] = TextEditingController(
            text: preset.setIncrementOverrides[setId]?.toString() ?? '',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _globalController.dispose();
    for (var c in _exControllers.values) {
      c.dispose();
    }
    for (var c in _setControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAllAndClose() async {
    final preset = widget.preset;

    // 1) Global settings
    final globalParsed =
        double.tryParse(_globalController.text) ?? preset.globalIncrement;
    await preset.saveAutoSettings(
      newGlobalIncrement: globalParsed,
      newSkipFirstSet: _skipFirst,
      newWeightCheck:     preset.weightCheck,
      newRepCheck:        preset.repCheck,
      newVolumeCheck:     preset.volumeCheck,
      newAdjustAllSets: preset.adjustAllSets,
    );

    // 2) Per-exercise overrides
    for (var exId in preset.presetExerciseIds) {
      final parsed = double.tryParse(_exControllers[exId]!.text);
      await preset.saveExerciseOverride(exId, parsed);
    }

    // 3) Per-set overrides
    for (var setId in _setControllers.keys) {
      final parsed = double.tryParse(_setControllers[setId]!.text);
      await preset.saveSetOverride(setId, parsed);
    }

    // Finally dismiss
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    
    final preset = widget.preset;  // grab it here instead of context.watch
    
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ListView(
  controller: scrollCtrl,
  padding: const EdgeInsets.all(16),
  children: [
    // 2.1) Header
    Text(
      'Automatic Settings',
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    const SizedBox(height: 12),

    // 2.2) Toggle Buttons Row
    Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _showMethods
                  ? Colors.grey[300]
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: _showMethods
                  ? Colors.black
                  : Colors.white,
            ),
            onPressed: () => setState(() => _showMethods = false),
            child: const Text('Values'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _showMethods
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
              foregroundColor: _showMethods
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () => setState(() => _showMethods = true),
            child: const Text('Methods'),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),

    // 2.3) Now branch on which pane to show:
    if (!_showMethods) ...[
      // ─── VALUES PANEL (your existing code) ───
      // Global Increment
      TextField(
              controller: _globalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Global Increment Amount',
                suffixText: 'lbs',
                border: OutlineInputBorder(),
              ),
            ),
      const SizedBox(height: 12),
      CheckboxListTile(
              title: const Text('Skip First Set?'),
              value: _skipFirst,
              onChanged: (checked) {
                if (checked == null) return;
                setState(() => _skipFirst = checked);
              },
            ),
      const Divider(),
      // Per-Exercise Overrides
            ...preset.exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              final exId = preset.presetExerciseIds[i];
              final controller = _exControllers[exId]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(ex.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'IA',
                            hintText: 'ex',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Per-Set Overrides (parents)
                  ...List.generate(preset.presetParentSetIds[i].length,
                      (pi) {
                    final setId = preset.presetParentSetIds[i][pi];
                    final set = (ex as WeightExercise).sets[pi];
                    final setCtrl = _setControllers[setId]!;

                    return Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  'Set ${pi + 1}: ${set.weight} × ${set.reps}')),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: setCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'IA',
                                hintText: 'set',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Per-Set Overrides (children)
                  ...preset.presetChildSetIds[i].entries.expand((e) {
                    final parentIdx = e.key;
                    return e.value.map((cid) {
                      final childIndex = e.value.indexOf(cid);
                      final childSet =
                          (ex as WeightExercise).changeSets[parentIdx]!
                              [childIndex];
                      final childCtrl = _setControllers[cid]!;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'Set ${parentIdx + 1}.${childIndex + 1}: ${childSet.weight} × ${childSet.reps}')),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: childCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'IA',
                                  hintText: 'set',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  }),

                  const Divider(),
                ],
              );
            }),

            const SizedBox(height: 16),
            // ——— Replaced “Close” with “Save” ———
            ElevatedButton(
              onPressed: _saveAllAndClose,
              child: const Text('Save'),
            ),
            const SizedBox(height: 24),
    ] else ...[
    const Text('Increment When (decrement otherwise):'),
    
    CheckboxListTile(
      title: const Text('Completed weight ≥ target weight'),
      value: preset.weightCheck,
      onChanged: (b) => setState(() => preset.weightCheck = b!),
),
    CheckboxListTile(
      title: const Text('Completed reps ≥ target reps'),
      value: preset.repCheck,
      onChanged: (b) => setState(() =>preset.repCheck = b!),
    ),
    CheckboxListTile(
      title: const Text('Completed volume ≥ target volume'),
      value: preset.volumeCheck,
      onChanged: (b) => setState(() => preset.volumeCheck = b!),
    ),

    // after the three “increment when” checkboxes…
const SizedBox(height: 16),
Text('For Every Exercise:', style: Theme.of(context).textTheme.titleMedium),
RadioListTile<bool>(
  title: Text('Adjust 1 set'),
  value: false,
  groupValue: preset.adjustAllSets,
  onChanged: (v) => setState(() => preset.adjustAllSets = v!),
),
RadioListTile<bool>(
  title: Text('Adjust All sets'),
  value: true,
  groupValue: preset.adjustAllSets,
  onChanged: (v) => setState(() => preset.adjustAllSets = v!),
),


    const SizedBox(height: 16),
    const Text('to add: looping functionality for successes and failures'),
    const SizedBox(height: 24),
    ElevatedButton(
      onPressed: () {
        // call your merged save, passing all six values
        preset.saveAutoSettings(
          newGlobalIncrement: preset.globalIncrement,
          newSkipFirstSet:    preset.skipFirstSet,
          newWeightCheck:     preset.weightCheck,
          newRepCheck:        preset.repCheck,
          newVolumeCheck:     preset.volumeCheck,
          newAdjustAllSets:   preset.adjustAllSets,
        );
        Navigator.of(context).pop();
      },
      child: const Text('Save'),
    ),
  ]
  ],
),
      
      ),
    );
  }
}