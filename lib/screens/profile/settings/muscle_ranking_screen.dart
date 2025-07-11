// File: lib/screens/muscle_ranking_screen.dart

import 'package:flutter/material.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/models.dart';

class MuscleRankingScreen extends StatefulWidget {
  const MuscleRankingScreen({super.key});

  @override
  State<MuscleRankingScreen> createState() => _MuscleRankingScreenState();
}

class _MuscleRankingScreenState extends State<MuscleRankingScreen> {
  final _repo = AppRepository();
  List<Muscle> _muscles = [];
  Map<int, int> _ranks = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ms   = await _repo.fetchAllMusclesFull();
      final rows = await _repo.getAllMuscleRanks();
      if (!mounted) return;
      setState(() {
        _muscles   = ms;
        _ranks     = { for (var r in rows) r.muscleId : r.rank };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error     = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _update(int id, String val) async {
    final newRank = int.tryParse(val) ?? 0;
    try {
      await _repo.setMuscleRank(id, newRank);
      if (!mounted) return;
      setState(() => _ranks[id] = newRank);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  Widget build(BuildContext ctx) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error loading muscles: $_error')),
      );
    }
    if (_muscles.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No muscles defined')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Muscle Rankings')),
      body: ListView.builder(
        itemCount: _muscles.length,
        itemBuilder: (_, i) {
          final m  = _muscles[i];
          final r  = _ranks[m.id] ?? 0;
          return ListTile(
            title: Text(m.name),
            trailing: SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: r.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rank'),
                onFieldSubmitted: (v) {
                  if (!mounted) return;
                  _update(m.id, v);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
