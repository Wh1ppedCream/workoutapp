import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

class MuscleRankingScreen extends StatefulWidget {
  const MuscleRankingScreen({super.key});

  @override
  State<MuscleRankingScreen> createState() => _MuscleRankingScreenState();
}

class _MuscleRankingScreenState extends State<MuscleRankingScreen> {
  final _repo = AppRepository();
  List<Muscle> _muscles = [];
  Map<int,int> _ranks   = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _repo.fetchAllMusclesFull();
    final rows = await _repo.getAllMuscleRanks();
    setState(() {
      _muscles = m;
      _ranks = { for (var r in rows) 
        r.muscleId : r.rank
      };
    });
  }

  Future<void> _update(int id, String v) async {
    final r = int.tryParse(v) ?? 0;
    await _repo.setMuscleRank(id, r);
    setState(() => _ranks[id] = r);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muscle Rankings')),
      body: _muscles.isEmpty
        ? const Center(child: Text('No muscles'))
        : ListView.builder(
            itemCount: _muscles.length,
            itemBuilder: (_, i) {
              final m = _muscles[i];
              final r = _ranks[m.id] ?? 0;
              return ListTile(
                title: Text(m.name),
                trailing: SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: r.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    onFieldSubmitted: (v) => _update(m.id, v),
                  ),
                ),
              );
            },
          ),
    );
  }
}
