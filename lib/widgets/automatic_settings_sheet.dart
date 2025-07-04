// File: lib/widgets/automatic_settings_sheet.dart

import 'package:flutter/material.dart';
import '../providers/preset_session.dart';
import '../models/models.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

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
      newWeightCheck: preset.weightCheck,
      newRepCheck: preset.repCheck,
      newVolumeCheck: preset.volumeCheck,
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
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Values'),
                  Tab(text: 'Methods'),
                  Tab(text: 'Flow'),
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
                      children: [ /*
                        Text(
                          'Automatic Settings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ), */
                        const SizedBox(height: 12),
                        // Global Increment
                        TextField(
                          controller: _globalController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                    // Flow Tab
                    ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                            'To add: looping functionality for successes and failures'),
                            SizedBox(
      height: 300, // Adjust height as needed
      child: SimpleFlowChart(),
    ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveAllAndClose,
                          child: const Text('Save'),
                        ),
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


class SimpleFlowChart extends StatefulWidget {
  const SimpleFlowChart({super.key});

  @override
  State<SimpleFlowChart> createState() => _SimpleFlowChartState();
}

class _SimpleFlowChartState extends State<SimpleFlowChart> {
  final Dashboard dashboard = Dashboard();

  @override
  void initState() {
    super.initState();

    // Root node
    final root = FlowElement(
      position: const Offset(60, 50),
      size: const Size(60, 30),
      text: 'Root',
      textSize: 12,
      kind: ElementKind.rectangle,
      handlers: [Handler.bottomCenter],
    );
    dashboard.addElement(root);

    // Intermediate nodes
    final success1 = FlowElement(
      position: const Offset(60, 100),
      size: const Size(50, 25),
      text: 'Success1',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    final fail1 = FlowElement(
      position: const Offset(120, 100),
      size: const Size(50, 25),
      text: 'Fail1',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    dashboard.addElement(success1);
    dashboard.addElement(fail1);

    // Leaf nodes
    final success2 = FlowElement(
      position: const Offset(60, 150),
      size: const Size(50, 25),
      text: 'Success2',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    final fail2 = FlowElement(
      position: const Offset(120, 150),
      size: const Size(50, 25),
      text: 'Fail2',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    final success3 = FlowElement(
      position: const Offset(180, 150),
      size: const Size(50, 25),
      text: 'Success3',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    final fail3 = FlowElement(
      position: const Offset(240, 150),
      size: const Size(50, 25),
      text: 'Fail3',
      textSize: 7,
      kind: ElementKind.rectangle,
      handlers: [Handler.topCenter, Handler.bottomCenter],
    );

    dashboard.addElement(success2);
    dashboard.addElement(fail2);
    dashboard.addElement(success3);
    dashboard.addElement(fail3);

    // Connections
    dashboard.addNextById(root, success1.id, _arrow(root, success1));
    dashboard.addNextById(root, fail1.id, _arrow(root, fail1));

    dashboard.addNextById(success1, success2.id, _arrow(success1, success2));
    dashboard.addNextById(success1, fail2.id, _arrow(success1, fail2));

    dashboard.addNextById(fail1, success3.id, _arrow(fail1, success3));
    dashboard.addNextById(fail1, fail3.id, _arrow(fail1, fail3));

    dashboard.addNextById(success2, root.id, _loopArrow(success2, root));
    dashboard.addNextById(fail2, root.id, _loopArrow(fail2, root));
    dashboard.addNextById(success3, root.id, _loopArrow(success3, root));
    dashboard.addNextById(fail3, root.id, _loopArrow(fail3, root));
  }

  ArrowParams _arrow(FlowElement from, FlowElement to) {
    return ArrowParams(
      color: Colors.blue,
      thickness: 2,
      style: ArrowStyle.segmented,
      startArrowPosition: Alignment.bottomCenter,
      endArrowPosition: Alignment.topCenter,
    );
  }

  ArrowParams _loopArrow(FlowElement from, FlowElement to) {
    return ArrowParams(
      color: Colors.black26,
      thickness: 2,
      style: ArrowStyle.curve,
      startArrowPosition: Alignment.bottomCenter,
      endArrowPosition: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowChart(
      dashboard: dashboard,
      onElementPressed: (_, __, element) {
        debugPrint('Tapped: ${element.text}');
      },
    );
  }
}
