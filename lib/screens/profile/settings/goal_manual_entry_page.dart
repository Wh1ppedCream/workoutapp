import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/nutrition_profile.dart';
import '../../../models/nutrition_models.dart';

class GoalManualEntryPage extends StatefulWidget {
  const GoalManualEntryPage({super.key});

  @override
  State<GoalManualEntryPage> createState() => _GoalManualEntryPageState();
}

class _GoalManualEntryPageState extends State<GoalManualEntryPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _kcalCtrl   = TextEditingController();
  final _proteinCtrl= TextEditingController();
  final _carbCtrl   = TextEditingController();
  final _fatCtrl    = TextEditingController();
  final _fiberCtrl  = TextEditingController();
  final _sugarCtrl  = TextEditingController();
  final _satFatCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final p = context.read<NutritionProfile>();
    final g = p.activeGoal;

    _startDate = DateTime(p.day.year, p.day.month, p.day.day);

    void set(TextEditingController c, num? v) {
      if (v == null) return;
      c.text = v is int ? v.toString() : v.toString();
    }

    set(_kcalCtrl,    g?.kcalTarget);
    set(_proteinCtrl, g?.proteinG);
    set(_carbCtrl,    g?.carbsG);
    set(_fatCtrl,     g?.fatG);
    set(_fiberCtrl,   g?.fiberG);
    set(_sugarCtrl,   g?.sugarG);
    set(_satFatCtrl,  g?.satFatG);
    set(_sodiumCtrl,  g?.sodiumMg);
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NutritionProfile>();
    final canSave = p.current?.id != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Manual Nutrition Goals')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Start date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text('${_startDate.year}-${_two(_startDate.month)}-${_two(_startDate.day)}'),
              trailing: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
                  }
                },
              ),
            ),
            const SizedBox(height: 8),

            _numField(_kcalCtrl, label: 'Calories (kcal)', integerOnly: true),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _numField(_proteinCtrl, label: 'Protein (g)')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_carbCtrl,    label: 'Carbs (g)')),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _numField(_fatCtrl,     label: 'Fat (g)')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_fiberCtrl,   label: 'Fiber (g)')),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _numField(_sugarCtrl,   label: 'Sugar (g)')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_satFatCtrl,  label: 'Sat. Fat (g)')),
              ],
            ),
            const SizedBox(height: 12),

            _numField(_sodiumCtrl, label: 'Sodium (mg)', integerOnly: true),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Goals'),
                    onPressed: !canSave ? null : () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;

                      final profileId = p.current!.id!;
                      final goal = NutritionGoal(
                        profileId:  profileId,
                        startDate:  _startDate,
                        kcalTarget: _toDouble(_kcalCtrl),
                        proteinG:   _toDouble(_proteinCtrl),
                        fatG:       _toDouble(_fatCtrl),
                        carbsG:     _toDouble(_carbCtrl),
                        fiberG:     _toDouble(_fiberCtrl),
                        sugarG:     _toDouble(_sugarCtrl),
                        satFatG:    _toDouble(_satFatCtrl),
                        sodiumMg:   _toDouble(_sodiumCtrl),
                      );

                      await p.setGoals(goal);   // calls repo + reloadDay()
                      if (!context.mounted) return;
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(
    TextEditingController c, {
    required String label,
    bool integerOnly = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: integerOnly
          ? const TextInputType.numberWithOptions(signed: false, decimal: false)
          : const TextInputType.numberWithOptions(signed: false, decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (s) {
        if (s == null || s.trim().isEmpty) return null; // optional fields
        final v = num.tryParse(s);
        if (v == null) return 'Enter a number';
        if (v < 0) return 'Must be ≥ 0';
        return null;
      },
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  double? _toDouble(TextEditingController c) {
    final s = c.text.trim();
    if (s.isEmpty) return null;
    final v = double.tryParse(s);
    return v;
  }
}
