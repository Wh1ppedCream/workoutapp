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
  Map<int,int>   _ranks = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final parts = await _repo.fetchAllBodyPartsFull();
      final rows  = await _repo.getAllBodyPartRanks();
      if (!mounted) return;
      setState(() {
        _parts     = parts;
        _ranks     = { for (var r in rows) r.bodyPartId : r.rank };
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

  Future<void> _updateRank(int id, String val) async {
    final newRank = int.tryParse(val) ?? 0;
    try {
      await _repo.setBodyPartRank(id, newRank);
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_parts.isEmpty) {
      return const Center(child: Text('No body parts defined'));
    }
    return ListView.builder(
      itemCount: _parts.length,
      itemBuilder: (_, i) {
        final bp = _parts[i];
        final rk = _ranks[bp.id] ?? 0;
        return Material(
          child: ListTile(
          title: Text(bp.name),
          trailing: SizedBox(
            width: 60,
            child: TextFormField(
              initialValue: rk.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rank'),
              onFieldSubmitted: (v) {
                if (!mounted) return;
                _updateRank(bp.id, v);
              },
            ),
          ),
        )
        );
      },
    );
  }
}
