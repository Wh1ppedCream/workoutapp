// File: lib/screens/gym_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../models/gym_models.dart';
import '../providers/selected_profile.dart';

/// Screen for creating or editing a GymProfile.
class GymProfileScreen extends StatefulWidget {
  final GymProfile? profile;

  const GymProfileScreen({super.key, this.profile});

  @override
  State<GymProfileScreen> createState() => _GymProfileScreenState();
}

class _GymProfileScreenState extends State<GymProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  List<Map<String, dynamic>> _allEquipment = [];
  Set<int> _selectedEquipmentIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final db = await DatabaseHelper().database;
    final all = await db.query(
      'equipment',
      columns: ['id', 'name'],
      orderBy: 'name',
    );
    final assigned = <Map<String, dynamic>>[];
    if (widget.profile?.id != null) {
      assigned.addAll(
        await DatabaseHelper().fetchEquipmentForProfile(widget.profile!.id!),
      );
    }
    if (!mounted) return;
    setState(() {
      _allEquipment = all;
      _selectedEquipmentIds = assigned.map((e) => e['id'] as int).toSet();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final dbHelper = DatabaseHelper();
    final selectedProv = context.read<SelectedProfile>();
    final navigator = Navigator.of(context);
    int profileId;

    if (widget.profile?.id != null) {
      final updated = GymProfile(
        id: widget.profile!.id,
        name: name,
        createdAt: widget.profile!.createdAt,
      );
      await dbHelper.updateProfile(updated);
      profileId = updated.id!;
    } else {
      profileId = await dbHelper.createProfile(name);
    }

    final origAssigned = widget.profile?.id != null
        ? (await dbHelper.fetchEquipmentForProfile(profileId))
            .map((e) => e['id'] as int)
            .toSet()
        : <int>{};
    final toAdd = _selectedEquipmentIds.difference(origAssigned);
    final toRemove = origAssigned.difference(_selectedEquipmentIds);

    for (final eqId in toAdd) {
      await dbHelper.addEquipmentToProfile(profileId, eqId);
    }
    for (final eqId in toRemove) {
      await dbHelper.removeEquipmentFromProfile(profileId, eqId);
    }

    await selectedProv.loadProfiles();
    selectedProv.selectProfile(
      selectedProv.profiles.firstWhere((p) => p.id == profileId),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'New Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Profile Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Equipment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _allEquipment.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: _allEquipment.map((e) {
                          final id = e['id'] as int;
                          final name = e['name'] as String;
                          return CheckboxListTile(
                            value: _selectedEquipmentIds.contains(id),
                            title: Text(name),
                            onChanged: (yes) {
                              setState(() {
                                if (yes == true) {
                                  _selectedEquipmentIds.add(id);
                                } else {
                                  _selectedEquipmentIds.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
