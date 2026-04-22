// File: lib/screens/profile/settings/muscle_ranking_screen.dart

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
  bool _isSaving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ms = await _repo.fetchAllMusclesFull();
      final rows = await _repo.getAllMuscleRanks();
      if (!mounted) return;
      setState(() {
        _muscles = ms;
        _ranks = {for (var r in rows) r.muscleId: r.rank};
        // Sort by current rank ascending
        _muscles.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
        _isLoading = false;
        _dirty = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _muscles.removeAt(oldIndex);
      _muscles.insert(newIndex, item);
      // Update ranks based on new order
      for (var i = 0; i < _muscles.length; i++) {
        _ranks[_muscles[i].id] = i + 1;
      }
      _dirty = true;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      for (var entry in _ranks.entries) {
        await _repo.setMuscleRank(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Muscle ranks saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isSaving) {
      return const Center(child: CircularProgressIndicator());
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
      appBar: AppBar(
        title: const Text('Muscle Rankings'),
      ),
      body: ReorderableListView.builder(
        itemCount: _muscles.length,
        onReorder: _onReorder,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final m = _muscles[index];
          final r = _ranks[m.id] ?? index + 1;
          return ListTile(
            key: ValueKey(m.id),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(m.name),
            trailing: SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: r.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rank'),
                onFieldSubmitted: (v) {
                  setState(() {
                    final newRank = int.tryParse(v) ?? r;
                    _ranks[m.id] = newRank;
                    _dirty = true;
                    // Re-sort based on updated ranks
                    _muscles.sort((a, b) => (_ranks[a.id] ?? 0)
                        .compareTo(_ranks[b.id] ?? 0));
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: _dirty
          ? FloatingActionButton(
              onPressed: _saveAll,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }
}
