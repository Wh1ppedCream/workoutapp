// File: lib/screens/profile/settings/bodypart_ranking_screen.dart

import 'package:flutter/material.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/models.dart';

class BodyPartRankingScreen extends StatefulWidget {
  const BodyPartRankingScreen({super.key});

  @override
  State<BodyPartRankingScreen> createState() => _BodyPartRankingScreenState();
}

class _BodyPartRankingScreenState extends State<BodyPartRankingScreen> {
  final _repo = AppRepository();
  List<BodyPart> _parts = [];
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
      final parts = await _repo.fetchAllBodyPartsFull();
      final rows = await _repo.getAllBodyPartRanks();
      if (!mounted) return;
      setState(() {
        _parts = parts;
        _ranks = {for (var r in rows) r.bodyPartId: r.rank};
        // sort by current rank ascending
        _parts.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
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
      final part = _parts.removeAt(oldIndex);
      _parts.insert(newIndex, part);
      // update ranks based on new order
      for (var i = 0; i < _parts.length; i++) {
        _ranks[_parts[i].id] = i + 1;
      }
      _dirty = true;
    });
  }

  Future<void> _saveAll() async {
    setState(() {
      _isSaving = true;
    });
    try {
      for (var entry in _ranks.entries) {
        await _repo.setBodyPartRank(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Body part ranks saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
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
      return Center(child: Text('Error: \$_error'));
    }
    if (_parts.isEmpty) {
      return const Center(child: Text('No body parts defined'));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Rank Body Parts'),
      ),
      body: ReorderableListView.builder(
        itemCount: _parts.length,
        onReorder: _onReorder,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final bp = _parts[index];
          final rk = _ranks[bp.id] ?? index + 1;
          return ListTile(
            key: ValueKey(bp.id),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(bp.name),
            trailing: SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: rk.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rank'),
                onFieldSubmitted: (v) {
                  setState(() {
                    final newRank = int.tryParse(v) ?? rk;
                    _ranks[bp.id] = newRank;
                    _dirty = true;
                    // re-sort list based on updated ranks
                    _parts.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
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
