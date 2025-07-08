// File: lib/widgets/automatic_settings_sheet.dart

import 'package:flutter/material.dart';
import '../providers/preset_session.dart';
import '../models/models.dart';
import 'dart:convert';

enum SuccessCountMode { session, exercise, set }


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

class _AutomaticSettingsSheetState extends State<AutomaticSettingsSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _globalController;
  late bool _skipFirst;

  /// One controller per exercise override
  final Map<int, TextEditingController> _exControllers = {};

  /// One controller per set override (parents + children)
  final Map<int, TextEditingController> _setControllers = {};

  // Whether we’re in “auto” (rotating pointer) or “manual” mode
bool _manualSelect = false;

// Holds per-set checkbox state when in manual mode
final Map<int, bool> _setSelections = {};

SuccessCountMode _successCountMode = SuccessCountMode.session;



  @override
  void initState() {
    super.initState();

    final preset = widget.preset;

    // 1) Seed the global/manual flag
  _manualSelect = preset.manualSelect;

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


    // Seed _setSelections from whatever was saved in PresetSession.manualSelections
  final allIds = <int>[
    for (var list in preset.presetParentSetIds)      ...list,
    for (var childMap in preset.presetChildSetIds)
      for (var list in childMap.values)              ...list,
  ];
  for (var id in allIds) {
    _setSelections[id] = preset.manualSelections[id] ?? false;
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

    // 1) Global settings + manual flags
final globalParsed = double.tryParse(_globalController.text) ?? preset.globalIncrement;
final manualJson   = json.encode(
  _setSelections.map((key, value) => MapEntry(key.toString(), value))
);


    await preset.saveAutoSettings(
      newGlobalIncrement: globalParsed,
      newSkipFirstSet: _skipFirst,
      newWeightCheck: preset.weightCheck,
      newRepCheck: preset.repCheck,
      newVolumeCheck: preset.volumeCheck,
      newAdjustAllSets: preset.adjustAllSets,

      newUseManualSelect:   _manualSelect,
      newManualSelectionJson:  manualJson,
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

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final preset = widget.preset;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Values'),
                  Tab(text: 'Methods'),
                ],
                labelPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Values Tab
                    ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [ 
                        const SizedBox(height: 12),
                        // Global Increment
                        TextField(
                          controller: _globalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Global Increment Amount',
                            suffixText: 'lbs',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2) Auto vs Manual toggle
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ChoiceChip(
          label: const Text('Auto Select'),
          selected: !_manualSelect,
          onSelected: (_) => setState(() => _manualSelect = false),
        ),
        ),

        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
          label: const Text('Manual Select'),
          selected: _manualSelect,
          onSelected: (_) => setState(() => _manualSelect = true),
        ),
        ),
      ],
    ),
    const SizedBox(height: 16),

    if (!_manualSelect) ...[

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
                                    child: Text(
                                      ex.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
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
                              ...List.generate(
                                preset.presetParentSetIds[i].length,
                                (pi) {
                                  final setId =
                                      preset.presetParentSetIds[i][pi];
                                  final set = (ex as WeightExercise).sets[pi];
                                  final setCtrl = _setControllers[setId]!;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              'Set ${pi + 1}: ${set.weight} × ${set.reps}'),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: setCtrl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
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
                                },
                              ),
                              // Per-Set Overrides (children)
                              ...preset
                                  .presetChildSetIds[i]
                                  .entries
                                  .expand((e) {
                                final parentIdx = e.key;
                                return e.value.map((cid) {
                                  final childIndex =
                                      e.value.indexOf(cid);
                                  final childSet = (ex as WeightExercise)
                                      .changeSets[parentIdx]![childIndex];
                                  final childCtrl = _setControllers[cid]!;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              'Set ${parentIdx + 1}.${childIndex + 1}: ${childSet.weight} × ${childSet.reps}'),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: childCtrl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
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

ElevatedButton(
                          onPressed: _saveAllAndClose,
                          child: const Text('Save'),
                        ),

    const SizedBox(height: 24),


    ]
                     
                     // 3b) Manual mode: per-set checkboxes
    else ...[
  // We hide Skip First entirely in manual mode
  const Divider(),

  // For each exercise:
  ...preset.exercises.asMap().entries.map((entry) {
    final i      = entry.key;
    final ex     = entry.value as WeightExercise;
    final exId   = preset.presetExerciseIds[i];
    final exCtrl = _exControllers[exId]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise-level IA field stays the same
        Row(
          children: [
            Expanded(
              child: Text(
                ex.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: exCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

        // Parent sets, with a Checkbox to the left
        ...List.generate(preset.presetParentSetIds[i].length, (pi) {
          final setId   = preset.presetParentSetIds[i][pi];
          final set     = ex.sets[pi];
          final setCtrl = _setControllers[setId]!;

          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: _setSelections[setId] ?? false,
                  onChanged: (v) => setState(() => _setSelections[setId] = v!),
                ),
                Expanded(
                  child: Text('Set ${pi + 1}: ${set.weight} × ${set.reps}'),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: setCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

        // Child sets, same pattern
        ...preset.presetChildSetIds[i].entries.expand((e) {
          final parentIdx = e.key;
          return e.value.asMap().entries.map((childEntry) {
            final ci        = childEntry.key;
            final cid       = childEntry.value;
            final child     = ex.changeSets[parentIdx]![ci];
            final childCtrl = _setControllers[cid]!;

            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: _setSelections[cid] ?? false,
                    onChanged: (v) => setState(() => _setSelections[cid] = v!),
                  ),
                  Expanded(
                    child: Text('Set ${parentIdx + 1}.${ci + 1}: ${child.weight} × ${child.reps}'),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: childCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  ElevatedButton(
                          onPressed: _saveAllAndClose,
                          child: const Text('Save'),
                        ),

    const SizedBox(height: 24),
],

                     
                     
                      ],
                    ),
                    // Methods Tab
                    ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text('Increment When (decrement otherwise):'),
                        CheckboxListTile(
                          title:
                              const Text('Completed weight ≥ target weight'),
                          value: preset.weightCheck,
                          onChanged: (b) => setState(() => preset.weightCheck = b!),
                        ),
                        CheckboxListTile(
                          title:
                              const Text('Completed reps ≥ target reps'),
                          value: preset.repCheck,
                          onChanged: (b) => setState(() => preset.repCheck = b!),
                        ),
                        CheckboxListTile(
                          title:
                              const Text('Completed volume ≥ target volume'),
                          value: preset.volumeCheck,
                          onChanged: (b) => setState(() => preset.volumeCheck = b!),
                        ),
                        const SizedBox(height: 16),

                        // ── New section header ───────────────────────────────
const Text(
  'Success/Fails counted and increments/decrements made based off:',
  style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),

// ── Three radio options ──────────────────────────────
// TODO: code and enable these options, currently only works per session ('Workout Session') here (the codes default, the boxes don't work at all)
RadioListTile<SuccessCountMode>(
  title: const Text('Workout Session'),
  value: SuccessCountMode.session,
  groupValue: _successCountMode,
  onChanged: (mode) => setState(() => _successCountMode = mode!),
),
RadioListTile<SuccessCountMode>(
  title: const Text('per Exercise'),
  value: SuccessCountMode.exercise,
  groupValue: _successCountMode,
  onChanged: (mode) => setState(() => _successCountMode = mode!),
),
RadioListTile<SuccessCountMode>(
  title: const Text('per Set'),
  value: SuccessCountMode.set,
  groupValue: _successCountMode,
  onChanged: (mode) => setState(() => _successCountMode = mode!),
),

const SizedBox(height: 16),

                        Text('For Every Exercise:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        RadioListTile<bool>(
                          title: const Text('Adjust 1 set'),
                          value: false,
                          groupValue: preset.adjustAllSets,
                          onChanged: (v) => setState(
                              () => preset.adjustAllSets = v!),
                        ),
                        RadioListTile<bool>(
                          title: const Text('Adjust All sets'),
                          value: true,
                          groupValue: preset.adjustAllSets,
                          onChanged: (v) => setState(
                              () => preset.adjustAllSets = v!),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveAllAndClose,
                          child: const Text('Save'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    
                  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
