// File: lib/screens/exercise/exercise_analytics_screen.dart

import 'package:flutter/material.dart';
import '../../repositories/app_repository.dart';
import '../../models/models.dart';

class ExerciseAnalyticsScreen extends StatefulWidget {
  const ExerciseAnalyticsScreen({super.key});

  @override
  State<ExerciseAnalyticsScreen> createState() => _ExerciseAnalyticsScreenState();
}

class _ExerciseAnalyticsScreenState extends State<ExerciseAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AppRepository();
  late final TabController _tabController;

  // --- Definitions ---
  List<ExerciseDefinition> _defs = [];
  ExerciseDefinition? _sel;
  bool _isLoadingDefs = true;
  String? _defsError;

  // --- Muscles tab ---
  List<ExerciseMusclePercent> _muscleEntries = [];
  Set<int> _overrideIds = {};
  bool _isLoadingMuscles = false;

  // --- BodyParts tab ---
  Map<BodyPart, double> _bodyEntries = {};
  bool _isLoadingBody = false;

  // --- Defaults tab ---

  //TODO: right now this just shows the formula step/min/max, i want this to eventually fully allow users to change the entire formula

  final _stepCtrl = TextEditingController();
  final _minCtrl  = TextEditingController();
  final _maxCtrl  = TextEditingController();
  bool _isLoadingDefaults = false;
  String? _defaultsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDefinitions();
    _loadDefaults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stepCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDefinitions() async {
    try {
      final defs = await _repo.lookupDefsDetailed();
      if (!mounted) return;
      setState(() {
        _defs = defs;
        _sel = defs.isNotEmpty ? defs.first : null;
        _defsError = null;
      });
      if (_sel != null) {
        await Future.wait([
          _loadMuscleEntries(_sel!),
          _loadBodyEntries(_sel!),
        ]);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _defsError = e.toString();
      });
    } finally {
      if (mounted) {
      setState(() {
        _isLoadingDefs = false;
      });
    }
    }
  }

  Future<void> _onSelectDef(ExerciseDefinition def) async {
    setState(() {
      _sel = def;
      _muscleEntries = [];
      _overrideIds = {};
      _bodyEntries = {};
    });
    await Future.wait([
      _loadMuscleEntries(def),
      _loadBodyEntries(def),
    ]);
  }

  Future<void> _loadMuscleEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingMuscles = true);
    try {
      // merged defaults + overrides
      final computed = await _repo.computeMusclePercents(def.id);
      // explicit overrides
      final saved = await _repo.fetchPercentsForExercise(def.id);
      final overrideIds = saved.map((e) => e.muscleId).toSet();
      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _muscleEntries = computed;
        _overrideIds = overrideIds;
      });
    } catch (e) {
      // swallow: muscle tab will just show empty
    } finally {
      if (mounted) {
      setState(() => _isLoadingMuscles = false);
    }
    }
  }

  Future<void> _loadBodyEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingBody = true);
    try {
      final bodyMap = await _repo.computeBodyPartPercents(def.id);
      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _bodyEntries = bodyMap;
      });
    } catch (e) {
      // swallow
    } finally {
      if (mounted) {
      setState(() => _isLoadingBody = false);
      }
    }
  }

  Future<void> _loadDefaults() async {
    setState(() => _isLoadingDefaults = true);
    try {
      final step = await _repo.getFormulaStep();
      final mn   = await _repo.getFormulaMin();
      final mx   = await _repo.getFormulaMax();
      if (!mounted) return;
      setState(() {
        _stepCtrl.text = step.toString();
        _minCtrl.text  = mn.toString();
        _maxCtrl.text  = mx.toString();
        _defaultsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _defaultsError = e.toString();
      });
    } finally {
      if (mounted) {
      setState(() => _isLoadingDefaults = false);
      }
    }
  }

  Future<void> _saveDefaults() async {
    double? parse(String txt) {
      try {
        return double.parse(txt);
      } catch (_) {
        return null;
      }
    }

    final step = parse(_stepCtrl.text);
    final mn   = parse(_minCtrl.text);
    final mx   = parse(_maxCtrl.text);
    if (step == null || mn == null || mx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    try {
      await _repo.setFormulaStep(step);
      await _repo.setFormulaMin(mn);
      await _repo.setFormulaMax(mx);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Defaults saved')),
      );
      // reload so UI reflects clamp if needed
      await _loadDefaults();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save defaults: $e')),
      );
    }
  }

  Future<void> _updateMuscle(int muscleId, String txt) async {
    final val = double.tryParse(txt) ?? 0.0;
    final def = _sel;
    if (def == null) return;
    await _repo.setExerciseMuscleHitPercent(def.id, muscleId, val);
    await _loadMuscleEntries(def);
  }

  Future<void> _resetMuscle(int muscleId) async {
    final def = _sel;
    if (def == null) return;
    await _repo.removeExerciseMusclePercent(def.id, muscleId);
    await _loadMuscleEntries(def);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sel == null
            ? 'Exercise Analytics'
            : 'Analytics: ${_sel!.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '% Muscles'),
            Tab(text: '% BodyParts'),
            Tab(text: 'Defaults'),
          ],
        ),
      ),
      body: _isLoadingDefs
          ? const Center(child: CircularProgressIndicator())
          : (_defsError != null
              ? Center(child: Text('Error: $_defsError'))
              : Column(
                  children: [
                    // Definition dropdown
                    Padding(
                      padding: const EdgeInsets.all(12),
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
                          _onSelectDef(d);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Tab views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // --- % Muscles ---
                          _isLoadingMuscles
                              ? const Center(child: CircularProgressIndicator())
                              : _muscleEntries.isEmpty
                                  ? const Center(child: Text('No muscles'))
                                  : ListView.builder(
                                      itemCount: _muscleEntries.length,
                                      itemBuilder: (_, i) {
                                        final e = _muscleEntries[i];
                                        final muscleName = _sel!
                                            .muscles
                                            .firstWhere((rm) =>
                                                rm.muscle.id == e.muscleId)
                                            .muscle
                                            .name;
                                        final isOverride =
                                            _overrideIds.contains(e.muscleId);
                                        return ListTile(
                                          title: Text(muscleName),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                child: TextFormField(
                                                  initialValue: e
                                                      .percent
                                                      .toStringAsFixed(1),
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                  decoration: const InputDecoration(
                                                      labelText: '%'),
                                                  onFieldSubmitted: (v) =>
                                                      _updateMuscle(
                                                          e.muscleId, v),
                                                ),
                                              ),
                                              if (isOverride)
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.refresh),
                                                  tooltip: 'Reset to default',
                                                  onPressed: () =>
                                                      _resetMuscle(
                                                          e.muscleId),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                          // --- % BodyParts ---
                          _isLoadingBody
                              ? const Center(child: CircularProgressIndicator())
                              : _bodyEntries.isEmpty
                                  ? const Center(child: Text('No bodyparts'))
                                  : ListView(
                                      children: _bodyEntries.entries
                                          .map((kv) => ListTile(
                                                title:
                                                    Text(kv.key.name),
                                                trailing: Text(
                                                    kv.value
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ))
                                          .toList(),
                                    ),

                          // --- Defaults ---
                          _isLoadingDefaults
                              ? const Center(child: CircularProgressIndicator())
                              : (_defaultsError != null
                                  ? Center(
                                      child:
                                          Text('Error: $_defaultsError'))
                                  : Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _stepCtrl,
                                            decoration:
                                                const InputDecoration(
                                              labelText:
                                                  'Step (decrement per rank)',
                                            ),
                                            keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                decimal: true),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: _minCtrl,
                                            decoration:
                                                const InputDecoration(
                                              labelText: 'Min clamp',
                                            ),
                                            keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                decimal: true),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: _maxCtrl,
                                            decoration:
                                                const InputDecoration(
                                              labelText: 'Max clamp',
                                            ),
                                            keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                decimal: true),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: _saveDefaults,
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    )),
                        ],
                      ),
                    ),
                  ],
                )),
    );
  }
}
