// File: lib/screens/exercise_muscle_percent_screen.dart

import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

class ExerciseMusclePercentScreen extends StatefulWidget {
  const ExerciseMusclePercentScreen({super.key});

  @override
  State<ExerciseMusclePercentScreen> createState() => _ExerciseMusclePercentScreenState();
}

class _ExerciseMusclePercentScreenState extends State<ExerciseMusclePercentScreen> {
  final _repo = AppRepository();

  List<ExerciseDefinition> _defs = [];
  ExerciseDefinition? _sel;
  List<ExerciseMusclePercent> _entries = [];
  Set<int> _overrides = {}; // muscleIds for which user has saved an override

  bool _isLoading = true;
  bool _isLoadingEntries = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    try {
      final defs = await _repo.lookupDefsDetailed();
      if (!mounted) return;
      setState(() {
        _defs = defs;
        _sel = defs.isNotEmpty ? defs.first : null;
      });
      if (_sel != null) {
        await _loadEntries(_sel!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingEntries = true);
    try {
      // 1) Compute defaults + overrides merged
      final computed = await _repo.computeMusclePercents(def.id);
      // 2) Fetch explicit overrides
      final saved = await _repo.fetchPercentsForExercise(def.id);
      final overrideIds = saved.map((e) => e.muscleId).toSet();

      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _entries = computed;
        _overrides = overrideIds;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load entries: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingEntries = false);
    }
  }

  Future<void> _updatePercent(int muscleId, String val) async {
    final parsed = double.tryParse(val) ?? 0.0;
    final def = _sel;
    if (def == null) return;
    try {
      await _repo.setExerciseMuscleHitPercent(def.id, muscleId, parsed);
      await _loadEntries(def);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update percent: $e')),
      );
    }
  }

  Future<void> _resetPercent(int muscleId) async {
    final def = _sel;
    if (def == null) return;
    try {
      await _repo.removeExerciseMusclePercent(def.id, muscleId);
      await _loadEntries(def);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset to default: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('% Hit per Muscle')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    if (_defs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('% Hit per Muscle')),
        body: const Center(child: Text('No exercises defined')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('% Hit per Muscle')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<ExerciseDefinition>(
              isExpanded: true,
              value: _sel,
              items: _defs
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d.name),
                      ))
                  .toList(),
              onChanged: (d) {
                if (d == null) return;
                setState(() {
                  _sel = d;
                  _entries = [];
                  _overrides = {};
                });
                _loadEntries(d);
              },
            ),
          ),
          const Divider(height: 1),
          if (_isLoadingEntries)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No muscle percentages set'))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (_, i) {
                        final e = _entries[i];
                        final def = _sel!;
                        final muscleName = def.muscles
                            .firstWhere((rm) => rm.muscle.id == e.muscleId)
                            .muscle
                            .name;
                        final isOverride = _overrides.contains(e.muscleId);

                        return ListTile(
                          title: Text(muscleName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 70,
                                child: TextFormField(
                                  initialValue: e.percent.toStringAsFixed(1),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: '%'),
                                  onFieldSubmitted: (v) =>
                                      _updatePercent(e.muscleId, v),
                                ),
                              ),
                              if (isOverride)
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Revert to default',
                                  onPressed: () =>
                                      _resetPercent(e.muscleId),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
