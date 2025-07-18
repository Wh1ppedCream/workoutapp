// File: lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart

import 'package:flutter/material.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/models.dart';

class BodyPartMuscleMappingScreen extends StatefulWidget {
  const BodyPartMuscleMappingScreen({super.key});

  @override
  State<BodyPartMuscleMappingScreen> createState() => _BodyPartMuscleMappingScreenState();
}

class _BodyPartMuscleMappingScreenState extends State<BodyPartMuscleMappingScreen> {
  final _repo = AppRepository();
  List<BodyPart> _bodyParts = [];
  List<Muscle> _muscles = [];
  BodyPart? _selectedBodyPart;
  Set<int> _linkedMuscleIds = {};

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final bps = await _repo.fetchAllBodyPartsFull();
    final ms  = await _repo.fetchAllMusclesFull();
    setState(() {
      _bodyParts = bps;
      _muscles   = ms;
      _selectedBodyPart = bps.isNotEmpty ? bps.first : null;
    });
    if (_selectedBodyPart != null) _loadMappings(_selectedBodyPart!.id);
  }

  Future<void> _loadMappings(int bodypartId) async {
  final List<MuscleBodyPart> rows = await _repo.fetchMusclesForBodyPart(bodypartId);
  setState(() {
    _linkedMuscleIds = rows.map((r) => r.muscleId).toSet();
  });
}


  Future<void> _toggleMapping(int muscleId, bool link) async {
    final bpId = _selectedBodyPart!.id;
    if (link) {
      await _repo.linkMuscleToBodyPart(muscleId, bpId);
      _linkedMuscleIds.add(muscleId);
    } else {
      await _repo.unlinkMuscleFromBodyPart(muscleId, bpId);
      _linkedMuscleIds.remove(muscleId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Muscles ↔ BodyParts')),
      body: _bodyParts.isEmpty
        ? const Center(child: Text('No body parts defined'))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<BodyPart>(
                  isExpanded: true,
                  value: _selectedBodyPart,
                  items: _bodyParts.map((bp) {
                    return DropdownMenuItem(value: bp, child: Text(bp.name));
                  }).toList(),
                  onChanged: (bp) {
                    setState(() => _selectedBodyPart = bp);
                    if (bp != null) _loadMappings(bp.id);
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: _muscles.map((m) {
                    final linked = _linkedMuscleIds.contains(m.id);
                    return CheckboxListTile(
                      title: Text(m.name),
                      value: linked,
                      onChanged: (ok) {
                        if (ok == null) return;
                        _toggleMapping(m.id, ok);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
    );
  }
}
