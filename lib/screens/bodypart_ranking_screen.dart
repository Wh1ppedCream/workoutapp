import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

class BodyPartRankingScreen extends StatefulWidget {
  const BodyPartRankingScreen({super.key});

  @override
  State<BodyPartRankingScreen> createState() => _BodyPartRankingScreenState();
}

class _BodyPartRankingScreenState extends State<BodyPartRankingScreen> {
  final _repo = AppRepository();
  List<BodyPart> _parts = [];
  Map<int,int>   _ranks = {}; // bodypartId → rank

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final parts = await _repo.fetchAllBodyPartsFull();
    // this returns List<BodyPartRanking>
    final List<BodyPartRanking> rows = await _repo.getAllBodyPartRanks();
    setState(() {
      _parts = parts;
      _ranks = {
        for (var r in rows) 
          r.bodyPartId : r.rank
      };
    });
   }

  Future<void> _updateRank(int id, String val) async {
    final rank = int.tryParse(val) ?? 0;
    await _repo.setBodyPartRank(id, rank);
    setState(() => _ranks[id] = rank);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('BodyPart Rankings')),
      body: _parts.isEmpty
        ? const Center(child: Text('No body parts'))
        : ListView.builder(
            itemCount: _parts.length,
            itemBuilder: (_, i) {
              final bp = _parts[i];
              final rk = _ranks[bp.id] ?? 0;
              return ListTile(
                title: Text(bp.name),
                trailing: SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: rk.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    onFieldSubmitted: (v) => _updateRank(bp.id, v),
                  ),
                ),
              );
            },
          ),
    );
  }
}
