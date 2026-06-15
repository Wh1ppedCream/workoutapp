// File: lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart

import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/settings_tiles.dart';

class BodyPartMuscleMappingScreen extends StatefulWidget {
  const BodyPartMuscleMappingScreen({super.key});

  @override
  State<BodyPartMuscleMappingScreen> createState() =>
      _BodyPartMuscleMappingScreenState();
}

class _BodyPartMuscleMappingScreenState
    extends State<BodyPartMuscleMappingScreen> {
  final _repo = AppRepository();
  List<BodyPart> _bodyParts = [];
  List<Muscle> _muscles = [];
  BodyPart? _selectedBodyPart;
  Set<int> _linkedMuscleIds = {};
  Set<int>? _originalLinked;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final bodyParts = await _repo.fetchAllBodyPartsFull();
      final muscles = await _repo.fetchAllMusclesFull();
      if (!mounted) return;
      setState(() {
        _bodyParts = bodyParts;
        _muscles = muscles;
        _selectedBodyPart = bodyParts.isNotEmpty ? bodyParts.first : null;
        _isLoading = false;
        _error = null;
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

  Future<void> _loadMappings(int bodyPartId) async {
    final rows = await _repo.fetchMusclesForBodyPart(bodyPartId);
    if (!mounted) return;
    setState(() {
      _linkedMuscleIds = rows.map((r) => r.muscleId).toSet();
    });
  }

  Future<void> _saveMappings() async {
    if (_selectedBodyPart == null || _originalLinked == null) return;
    setState(() => _isSaving = true);
    try {
      final bodyPartId = _selectedBodyPart!.id;
      final added = _linkedMuscleIds.difference(_originalLinked!);
      final removed = _originalLinked!.difference(_linkedMuscleIds);
      for (var id in added) {
        await _repo.linkMuscleToBodyPart(id, bodyPartId);
      }
      for (var id in removed) {
        await _repo.unlinkMuscleFromBodyPart(id, bodyPartId);
      }
      if (!mounted) return;
      setState(() {
        _editing = false;
        _isSaving = false;
        _originalLinked = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mappings saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _originalLinked = Set<int>.from(_linkedMuscleIds);
    });
  }

  void _cancelEditing() {
    setState(() {
      _linkedMuscleIds = Set<int>.from(_originalLinked ?? _linkedMuscleIds);
      _editing = false;
      _originalLinked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anatomy Mapping'),
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: _editing
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _cancelEditing,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveMappings,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(child: _buildBody()),
      floatingActionButton: (!_editing && !_isLoading && _error == null)
          ? FloatingActionButton.extended(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final linkedMuscles =
        _muscles.where((m) => _linkedMuscleIds.contains(m.id)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 112),
      children: [
        const SettingsHeroCard(
          title: 'Anatomy Mapping',
          subtitle:
              'Connect muscles to body parts so heatmaps, analytics, and generated workouts agree.',
          icon: Icons.hub,
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: 'Selected Body Part',
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<BodyPart>(
                isExpanded: true,
                value: _selectedBodyPart,
                decoration: InputDecoration(
                  labelText: 'Body part',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: _bodyParts
                    .map(
                      (bodyPart) => DropdownMenuItem(
                        value: bodyPart,
                        child: Text(bodyPart.name),
                      ),
                    )
                    .toList(),
                onChanged: !_editing
                    ? (bodyPart) {
                        setState(() => _selectedBodyPart = bodyPart);
                        if (bodyPart != null) _loadMappings(bodyPart.id);
                      }
                    : null,
              ),
            ),
          ],
        ),
        SettingsSection(
          title: _editing ? 'Choose Linked Muscles' : 'Linked Muscles',
          subtitle: _editing
              ? 'Select every muscle that belongs to this body part.'
              : '${linkedMuscles.length} muscles currently linked.',
          children: _editing
              ? _editableMuscleTiles()
              : _readOnlyMuscleTiles(linkedMuscles),
        ),
      ],
    );
  }

  List<Widget> _editableMuscleTiles() {
    if (_muscles.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(18),
          child: Text('No muscles defined.'),
        ),
      ];
    }

    return settingsTilesWithDividers(
      context,
      _muscles.map((muscle) {
        final linked = _linkedMuscleIds.contains(muscle.id);
        return CheckboxListTile(
          value: linked,
          onChanged: (checked) {
            if (checked == null) return;
            setState(() {
              if (checked) {
                _linkedMuscleIds.add(muscle.id);
              } else {
                _linkedMuscleIds.remove(muscle.id);
              }
            });
          },
          title: Text(
            muscle.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          secondary: const Icon(Icons.fitness_center),
        );
      }).toList(),
    );
  }

  List<Widget> _readOnlyMuscleTiles(List<Muscle> linkedMuscles) {
    if (linkedMuscles.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(18),
          child: Text('No muscles linked yet. Tap Edit to add some.'),
        ),
      ];
    }

    return settingsTilesWithDividers(
      context,
      linkedMuscles
          .map(
            (muscle) => SettingsActionTile(
              icon: Icons.fitness_center,
              title: muscle.name,
              trailing: const SizedBox.shrink(),
            ),
          )
          .toList(),
    );
  }
}
