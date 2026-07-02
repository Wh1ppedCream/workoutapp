// File: lib/widgets/automatic_settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/preset_session.dart';
import '../providers/unit_preference_provider.dart';
import '../models/models.dart';
import 'dart:convert';
import '../theme/app_colors.dart';
import '../utils/weight_unit_formatter.dart';

/// Scope used when deciding how many successful sets count toward progression.
enum SuccessCountMode { session, exercise, set }

/// Bottom sheet for editing automatic preset progression settings.
///
/// The UI writes directly back into [PresetSession], which then persists global
/// settings, per-exercise overrides, per-set overrides, and manual set
/// selection state. The sheet mirrors all set IDs up front so parent and child
/// change sets can be edited consistently.
class AutomaticSettingsSheet extends StatefulWidget {
  final PresetSession preset;

  const AutomaticSettingsSheet({super.key, required this.preset});

  @override
  State<AutomaticSettingsSheet> createState() => _AutomaticSettingsSheetState();
}

class _AutomaticSettingsSheetState extends State<AutomaticSettingsSheet> {
  late TextEditingController _globalController;
  late bool _skipFirst;

  /// One controller per exercise override
  final Map<int, TextEditingController> _exControllers = {};

  /// One controller per set override (parents + children)
  final Map<int, TextEditingController> _setControllers = {};
  late WeightUnit _weightUnit;

  /// Whether we are in auto rotation mode or manual set-selection mode.
  bool _manualSelect = false;

  /// Per-set checkbox state when in manual mode.
  final Map<int, bool> _setSelections = {};

  SuccessCountMode _successCountMode = SuccessCountMode.session;
  bool _isSaving = false;

  /// Iterates every parent and child preset_set row ID in the loaded preset.
  Iterable<int> _allSetIds(PresetSession preset) sync* {
    for (final parentList in preset.presetParentSetIds) {
      yield* parentList;
    }
    for (final childMap in preset.presetChildSetIds) {
      for (final childList in childMap.values) {
        yield* childList;
      }
    }
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveAllAndClose,
      child: Text(_isSaving ? 'Saving...' : 'Save'),
    );
  }

  Widget _buildIncrementField(
    TextEditingController controller, {
    double width = 60,
    String hintText = 'set',
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'IA',
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSetIncrementRow({
    Widget? leading,
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          if (leading != null) leading,
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          _buildIncrementField(controller),
        ],
      ),
    );
  }

  void _disposeControllers(Iterable<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    final preset = widget.preset;
    _weightUnit = context.read<UnitPreferenceProvider>().weightUnit;

    // Seed the global/manual flag
    _manualSelect = preset.manualSelect;

    // Global increment & skip-first
    _globalController = TextEditingController(
      text: WeightUnitFormatter.formatInputWeight(
        preset.globalIncrement,
        _weightUnit,
      ),
    );
    _skipFirst = preset.skipFirstSet;

    // Per-exercise controllers
    for (var exId in preset.presetExerciseIds) {
      _exControllers[exId] = TextEditingController(
        text: _formatOptionalIncrement(preset.exerciseIncrementOverrides[exId]),
      );
    }

    // Per-set controllers and manual selections.
    for (final setId in _allSetIds(preset)) {
      _setControllers[setId] = TextEditingController(
        text: _formatOptionalIncrement(preset.setIncrementOverrides[setId]),
      );
      _setSelections[setId] = preset.manualSelections[setId] ?? false;
    }
  }

  @override
  void dispose() {
    _globalController.dispose();
    _disposeControllers(_exControllers.values);
    _disposeControllers(_setControllers.values);
    super.dispose();
  }

  Future<void> _saveAllAndClose() async {
    if (_isSaving) return;
    final preset = widget.preset;
    setState(() => _isSaving = true);
    var closedSheet = false;

    try {
      // 1) Global settings + manual flags
      final globalParsed =
          _parseIncrement(_globalController.text) ?? preset.globalIncrement;
      final manualJson = json.encode(
        _setSelections.map((key, value) => MapEntry(key.toString(), value)),
      );

      await preset.saveAutoSettings(
        newGlobalIncrement: globalParsed,
        newSkipFirstSet: _skipFirst,
        newWeightCheck: preset.weightCheck,
        newRepCheck: preset.repCheck,
        newVolumeCheck: preset.volumeCheck,
        newAdjustAllSets: preset.adjustAllSets,
        newUseManualSelect: _manualSelect,
        newManualSelectionJson: manualJson,
      );

      // 2) Per-exercise overrides
      for (var exId in preset.presetExerciseIds) {
        final parsed = _parseIncrement(_exControllers[exId]!.text);
        await preset.saveExerciseOverride(exId, parsed);
      }

      // 3) Per-set overrides
      for (var setId in _setControllers.keys) {
        final parsed = _parseIncrement(_setControllers[setId]!.text);
        await preset.saveSetOverride(setId, parsed);
      }

      if (mounted) {
        closedSheet = true;
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted && !closedSheet) setState(() => _isSaving = false);
    }
  }

  String _formatOptionalIncrement(double? pounds) {
    if (pounds == null) return '';
    return WeightUnitFormatter.formatInputWeight(pounds, _weightUnit);
  }

  double? _parseIncrement(String text) {
    final value = double.tryParse(text);
    if (value == null) return null;
    return WeightUnitFormatter.toPounds(value, _weightUnit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final extras = theme.extension<AppColors>();
    final sheetBg = extras?.sheetBackground ?? cs.surface;
    final labelColor = cs.onSurface;
    final dividerColor = cs.onSurface.withValues(alpha: 0.12);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder:
          (ctx, scrollCtrl) => Container(
            color: sheetBg,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [Tab(text: 'Values'), Tab(text: 'Methods')],
                    labelColor: cs.primary,
                    unselectedLabelColor: labelColor.withValues(alpha: 0.6),
                    indicatorColor: cs.primary,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Values tab.
                        ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          children: [
                            const SizedBox(height: 12),
                            TextField(
                              controller: _globalController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Global Increment Amount',
                                suffixText: _weightUnit.shortLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Auto Select'),
                                    selected: !_manualSelect,
                                    onSelected:
                                        (_) => setState(
                                          () => _manualSelect = false,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Manual Select'),
                                    selected: _manualSelect,
                                    onSelected:
                                        (_) => setState(
                                          () => _manualSelect = true,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (!_manualSelect) ...[
                              CheckboxListTile(
                                title: const Text('Skip First Set?'),
                                value: _skipFirst,
                                activeColor: cs.primary,
                                onChanged: (checked) {
                                  if (checked == null) return;
                                  setState(() => _skipFirst = checked);
                                },
                              ),
                              Divider(color: dividerColor),

                              // Per-Exercise Overrides
                              ...widget.preset.exercises.asMap().entries.map((
                                entry,
                              ) {
                                final i = entry.key;
                                final ex = entry.value;
                                final exId = widget.preset.presetExerciseIds[i];
                                final controller = _exControllers[exId]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ex.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _buildIncrementField(
                                          controller,
                                          width: 80,
                                          hintText: 'ex',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    ...List.generate(
                                      widget
                                          .preset
                                          .presetParentSetIds[i]
                                          .length,
                                      (pi) {
                                        final setId =
                                            widget
                                                .preset
                                                .presetParentSetIds[i][pi];
                                        final set =
                                            (ex as WeightExercise).sets[pi];
                                        final setCtrl = _setControllers[setId]!;
                                        return _buildSetIncrementRow(
                                          label:
                                              'Set ${pi + 1}: ${set.weight} × ${set.reps}',
                                          controller: setCtrl,
                                        );
                                      },
                                    ),

                                    ...widget
                                        .preset
                                        .presetChildSetIds[i]
                                        .entries
                                        .expand((e) {
                                          final parentIdx = e.key;
                                          return e.value.asMap().entries.map((
                                            childEntry,
                                          ) {
                                            final childIndex = childEntry.key;
                                            final cid = childEntry.value;
                                            final childSet =
                                                (ex as WeightExercise)
                                                    .changeSets[parentIdx]![childIndex];
                                            final childCtrl =
                                                _setControllers[cid]!;
                                            return _buildSetIncrementRow(
                                              label:
                                                  'Set ${parentIdx + 1}.${childIndex + 1}: ${childSet.weight} × ${childSet.reps}',
                                              controller: childCtrl,
                                            );
                                          });
                                        }),

                                    const Divider(),
                                  ],
                                );
                              }),
                              const SizedBox(height: 16),

                              _buildSaveButton(),
                              const SizedBox(height: 24),
                            ] else ...[
                              const Divider(),
                              // Exercise-level IA stays the same
                              ...widget.preset.exercises.asMap().entries.map((
                                entry,
                              ) {
                                final i = entry.key;
                                final ex = entry.value as WeightExercise;
                                final exId = widget.preset.presetExerciseIds[i];
                                final exCtrl = _exControllers[exId]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ex.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _buildIncrementField(
                                          exCtrl,
                                          width: 80,
                                          hintText: 'ex',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    ...List.generate(
                                      widget
                                          .preset
                                          .presetParentSetIds[i]
                                          .length,
                                      (pi) {
                                        final setId =
                                            widget
                                                .preset
                                                .presetParentSetIds[i][pi];
                                        final set = ex.sets[pi];
                                        final setCtrl = _setControllers[setId]!;

                                        return _buildSetIncrementRow(
                                          leading: Checkbox(
                                            value:
                                                _setSelections[setId] ?? false,
                                            onChanged:
                                                (v) => setState(
                                                  () =>
                                                      _setSelections[setId] =
                                                          v!,
                                                ),
                                            activeColor: cs.primary,
                                          ),
                                          label:
                                              'Set ${pi + 1}: ${set.weight} × ${set.reps}',
                                          controller: setCtrl,
                                        );
                                      },
                                    ),

                                    ...widget
                                        .preset
                                        .presetChildSetIds[i]
                                        .entries
                                        .expand((e) {
                                          final parentIdx = e.key;
                                          return e.value.asMap().entries.map((
                                            childEntry,
                                          ) {
                                            final ci = childEntry.key;
                                            final cid = childEntry.value;
                                            final child =
                                                ex.changeSets[parentIdx]![ci];
                                            final childCtrl =
                                                _setControllers[cid]!;

                                            return _buildSetIncrementRow(
                                              leading: Checkbox(
                                                value:
                                                    _setSelections[cid] ??
                                                    false,
                                                onChanged:
                                                    (v) => setState(
                                                      () =>
                                                          _setSelections[cid] =
                                                              v!,
                                                    ),
                                                activeColor: cs.primary,
                                              ),
                                              label:
                                                  'Set ${parentIdx + 1}.${ci + 1}: ${child.weight} × ${child.reps}',
                                              controller: childCtrl,
                                            );
                                          });
                                        }),

                                    const Divider(),
                                  ],
                                );
                              }),
                              const SizedBox(height: 16),

                              _buildSaveButton(),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),

                        // Methods tab.
                        ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text('Increment When (decrement otherwise):'),
                            CheckboxListTile(
                              title: const Text(
                                'Completed weight ≥ target weight',
                              ),
                              value: widget.preset.weightCheck,
                              activeColor: cs.primary,
                              onChanged:
                                  (b) => setState(
                                    () => widget.preset.weightCheck = b!,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text('Completed reps ≥ target reps'),
                              value: widget.preset.repCheck,
                              activeColor: cs.primary,
                              onChanged:
                                  (b) => setState(
                                    () => widget.preset.repCheck = b!,
                                  ),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                'Completed volume ≥ target volume',
                              ),
                              value: widget.preset.volumeCheck,
                              activeColor: cs.primary,
                              onChanged:
                                  (b) => setState(
                                    () => widget.preset.volumeCheck = b!,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Success/Fails counted and increments/decrements made based off:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            RadioListTile<SuccessCountMode>(
                              title: const Text('Workout Session'),
                              value: SuccessCountMode.session,
                              groupValue: _successCountMode,
                              activeColor: cs.primary,
                              onChanged:
                                  (m) => setState(() => _successCountMode = m!),
                            ),
                            RadioListTile<SuccessCountMode>(
                              title: const Text('per Exercise'),
                              value: SuccessCountMode.exercise,
                              groupValue: _successCountMode,
                              activeColor: cs.primary,
                              onChanged:
                                  (m) => setState(() => _successCountMode = m!),
                            ),
                            RadioListTile<SuccessCountMode>(
                              title: const Text('per Set'),
                              value: SuccessCountMode.set,
                              groupValue: _successCountMode,
                              activeColor: cs.primary,
                              onChanged:
                                  (m) => setState(() => _successCountMode = m!),
                            ),

                            const SizedBox(height: 16),
                            const Text(
                              'For Every Exercise:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            RadioListTile<bool>(
                              title: const Text('Adjust 1 set'),
                              value: false,
                              groupValue: widget.preset.adjustAllSets,
                              activeColor: cs.primary,
                              onChanged:
                                  (b) => setState(
                                    () => widget.preset.adjustAllSets = b!,
                                  ),
                            ),
                            RadioListTile<bool>(
                              title: const Text('Adjust All sets'),
                              value: true,
                              groupValue: widget.preset.adjustAllSets,
                              activeColor: cs.primary,
                              onChanged:
                                  (b) => setState(
                                    () => widget.preset.adjustAllSets = b!,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            _buildSaveButton(),
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
