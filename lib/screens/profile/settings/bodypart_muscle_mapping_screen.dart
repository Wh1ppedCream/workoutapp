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
  Set<int>? _originalLinked;
  bool _isLoading = true;
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final bps = await _repo.fetchAllBodyPartsFull();
      final ms = await _repo.fetchAllMusclesFull();
      if (!mounted) return;
      setState(() {
        _bodyParts = bps;
        _muscles = ms;
        _selectedBodyPart = bps.isNotEmpty ? bps.first : null;
        _isLoading = false;
      });
      if (_selectedBodyPart != null) {
        await _loadMappings(_selectedBodyPart!.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMappings(int bodypartId) async {
    final rows = await _repo.fetchMusclesForBodyPart(bodypartId);
    if (!mounted) return;
    setState(() {
      _linkedMuscleIds = rows.map((r) => r.muscleId).toSet();
    });
  }

  Future<void> _saveMappings() async {
    if (_selectedBodyPart == null || _originalLinked == null) return;
    final bpId = _selectedBodyPart!.id;
    final added = _linkedMuscleIds.difference(_originalLinked!);
    final removed = _originalLinked!.difference(_linkedMuscleIds);
    for (var id in added) {
      await _repo.linkMuscleToBodyPart(id, bpId);
    }
    for (var id in removed) {
      await _repo.unlinkMuscleFromBodyPart(id, bpId);
    }
    if (!mounted) return;
    setState(() {
      _editing = false;
      _originalLinked = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mappings saved')),
    );
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _originalLinked = Set<int>.from(_linkedMuscleIds);
    });
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
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Muscles ↔ BodyParts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<BodyPart>(
              isExpanded: true,
              value: _selectedBodyPart,
              items: _bodyParts
                  .map((bp) => DropdownMenuItem(
                        value: bp,
                        child: Text(bp.name),
                      ))
                  .toList(),
              onChanged: !_editing
                  ? (bp) {
                      setState(() => _selectedBodyPart = bp);
                      if (bp != null) _loadMappings(bp.id);
                    }
                  : null,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _editing
                ? ListView(
                    children: _muscles.map((m) {
                      final linked = _linkedMuscleIds.contains(m.id);
                      return CheckboxListTile(
                        title: Text(m.name),
                        value: linked,
                        onChanged: (ok) {
                          if (ok == null) return;
                          setState(() {
                            if (ok) {
                              _linkedMuscleIds.add(m.id);
                            } else {
                              _linkedMuscleIds.remove(m.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )
                : ListView(
                    children: _muscles
                        .where((m) => _linkedMuscleIds.contains(m.id))
                        .map((m) => ListTile(title: Text(m.name)))
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editing ? _saveMappings : _startEditing,
        child: Icon(_editing ? Icons.save : Icons.edit),
      ),
    );
  }
}
