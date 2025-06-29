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

  @override
  void initState() {
    super.initState();
    _repo.lookupDefsDetailed().then((l) {
      setState(() => _defs = l);
      if (l.isNotEmpty) _onSelect(l.first);
    });
  }

  Future<void> _onSelect(ExerciseDefinition def) async {
    final rows = await _repo.fetchPercentsForExercise(def.id);
    setState(() {
      _sel     = def;
      _entries = rows;
    });
  }

  Future<void> _update(int muscleId, String v) async {
    final p = double.tryParse(v) ?? 0.0;
    await _repo.setExerciseMuscleHitPercent(_sel!.id, muscleId, p);
    _onSelect(_sel!);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('% Hit per Muscle')),
      body: Column(
        children: [
          if (_defs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButton<ExerciseDefinition>(
                isExpanded: true,
                value: _sel,
                items: _defs.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                onChanged: (d) {
                  if (d != null) _onSelect(d);
                },
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (_, i) {
                final e = _entries[i];
                final name = _defs.firstWhere((d) => d.id == _sel!.id).muscles
                  .firstWhere((rm) => rm.muscle.id == e.muscleId).muscle.name;
                return ListTile(
                  title: Text(name),
                  trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: e.percent.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '%'),
                      onFieldSubmitted: (v) => _update(e.muscleId, v),
                    ),
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
