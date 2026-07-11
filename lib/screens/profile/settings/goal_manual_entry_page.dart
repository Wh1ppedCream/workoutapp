import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/nutrition_models.dart';
import '../../../providers/nutrition_profile.dart';
import '../../../widgets/settings_tiles.dart';

class GoalManualEntryPage extends StatefulWidget {
  const GoalManualEntryPage({super.key});

  @override
  State<GoalManualEntryPage> createState() => _GoalManualEntryPageState();
}

class _GoalManualEntryPageState extends State<GoalManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _satFatCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<NutritionProfile>();
    final goal = profile.activeGoal;

    _startDate = DateTime(profile.day.year, profile.day.month, profile.day.day);

    void set(TextEditingController controller, num? value) {
      if (value == null) return;
      controller.text = value.toString();
    }

    set(_kcalCtrl, goal?.kcalTarget);
    set(_proteinCtrl, goal?.proteinG);
    set(_carbCtrl, goal?.carbsG);
    set(_fatCtrl, goal?.fatG);
    set(_fiberCtrl, goal?.fiberG);
    set(_sugarCtrl, goal?.sugarG);
    set(_satFatCtrl, goal?.satFatG);
    set(_sodiumCtrl, goal?.sodiumMg);
  }

  @override
  void dispose() {
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    _sugarCtrl.dispose();
    _satFatCtrl.dispose();
    _sodiumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _saveGoals() async {
    final profile = context.read<NutritionProfile>();
    if (profile.current?.id == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final goal = NutritionGoal(
        profileId: profile.current!.id!,
        startDate: _startDate,
        kcalTarget: _toDouble(_kcalCtrl),
        proteinG: _toDouble(_proteinCtrl),
        fatG: _toDouble(_fatCtrl),
        carbsG: _toDouble(_carbCtrl),
        fiberG: _toDouble(_fiberCtrl),
        sugarG: _toDouble(_sugarCtrl),
        satFatG: _toDouble(_satFatCtrl),
        sodiumMg: _toDouble(_sodiumCtrl),
      );

      await profile.setGoals(goal);
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = context.watch<NutritionProfile>().current?.id != null;

    return SettingsPageScaffold(
      title: 'Manual Nutrition Goals',
      subtitle: 'Set calorie, macro, and nutrient targets manually.',
      icon: Icons.flag,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: !canSave || _saving ? null : _saveGoals,
                icon:
                    _saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Goals'),
              ),
            ),
          ],
        ),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              SettingsSection(
                title: 'Start Date',
                children: [
                  SettingsActionTile(
                    icon: Icons.date_range,
                    title: 'Goal starts',
                    subtitle:
                        '${_startDate.year}-${_two(_startDate.month)}-${_two(_startDate.day)}',
                    trailing: const Icon(Icons.calendar_month),
                    onTap: _pickStartDate,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Calories & Macros',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _numField(
                          _kcalCtrl,
                          label: 'Calories (kcal)',
                          integerOnly: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(
                                _proteinCtrl,
                                label: 'Protein (g)',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(_carbCtrl, label: 'Carbs (g)'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _numField(_fatCtrl, label: 'Fat (g)'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(_fiberCtrl, label: 'Fiber (g)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Additional Nutrients',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _numField(_sugarCtrl, label: 'Sugar (g)'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numField(
                                _satFatCtrl,
                                label: 'Sat. Fat (g)',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _numField(
                          _sodiumCtrl,
                          label: 'Sodium (mg)',
                          integerOnly: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numField(
    TextEditingController controller, {
    required String label,
    bool integerOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          integerOnly
              ? const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              )
              : const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final parsed = num.tryParse(value);
        if (parsed == null) return 'Enter a number';
        if (parsed < 0) return 'Must be >= 0';
        return null;
      },
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  double? _toDouble(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}
