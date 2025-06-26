// File: lib/widgets/exercise_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/selected_profile.dart';
import '../db/database_helper.dart';
import '../repositories/app_repository.dart';
import '../repositories/profile_repository.dart';

/// Catalog of exercise definitions with advanced filters,
/// including optional workspace-profile scoping.
class ExerciseCatalogPage extends StatefulWidget {
  final void Function(ExerciseDefinition)? onExercisePicked;
  const ExerciseCatalogPage({
    super.key,
    this.onExercisePicked,
  });

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  final _repo = AppRepository();

  // UI state
  bool _isLoading = true;
  String _searchQuery = '';
  bool _useProfileFilter = true;
  int? _dialogProfileId;

  // Filter dropdown options
  List<int?> _profileIds = [];
  List<String> _profileNames = [];
  List<String> _equipmentList = [];
  List<String> _bodyPartList = [];
  List<String> _muscleList = [];

  // Selected filter values
  String _filterEquipment = 'All';
  String _filterArea = 'All';
  String _filterMuscle = 'All';

  // Definitions storage
  List<ExerciseDefinition> _allDefs = [];
  List<ExerciseDefinition> _displayedDefs = [];
  ExerciseDefinition? _selectedDef;

  @override
  void initState() {
    super.initState();
    final sel = context.read<SelectedProfile>();
    _dialogProfileId = sel.currentProfile?.id;
    _loadLookupsAndDefs();
  }

  Future<void> _loadLookupsAndDefs() async {
    setState(() => _isLoading = true);
    // Load profiles for dialog
    final sel = context.read<SelectedProfile>();
    _profileIds = sel.profiles.map((p) => p.id).toList();
    _profileNames = sel.profiles.map((p) => p.name).toList();

    // Determine equipment names based on profile filter state
    List<String>? eqNames;
    if (_useProfileFilter && _dialogProfileId != null) {
      final eqMaps = await DatabaseHelper().fetchEquipmentForProfile(_dialogProfileId!);
      eqNames = eqMaps.map((e) => e['name'] as String).toList();
    } else {
      eqNames = await _repo.fetchAllEquipmentNames();
    }

    // Body-parts and muscles lookup
    final bodyParts = await _repo.fetchAllBodyParts();
    final muscles = await _repo.fetchAllMuscles();

    setState(() {
      _equipmentList = ['All', ...?eqNames];
      _bodyPartList = ['All', ...bodyParts.map((b) => b.name)];
      _muscleList = ['All', ...muscles.map((m) => m.name)];
    });

    // Load definitions: full equipment-only filter if using profile
    if (_useProfileFilter && eqNames.isNotEmpty) {
      _allDefs = await _repo.lookupDefsOnlyWithEquipment(eqNames);
    } else {
      _allDefs = await _repo.lookupDefsFiltered();
    }

    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    final filtered = _allDefs.where((d) {
      final matchesSearch = query.isEmpty || d.name.toLowerCase().contains(query);
      final matchesArea = _filterArea == 'All' || d.bodyParts.any((bp) => bp.name == _filterArea);
      final matchesMuscle = _filterMuscle == 'All' || d.muscles.any((rm) => rm.muscle.name == _filterMuscle);
      final matchesEquipment = _filterEquipment == 'All' ||
          d.equipmentList.any((e) => e.name == _filterEquipment);
      return matchesSearch && matchesArea && matchesMuscle && matchesEquipment;
    }).toList();

    setState(() {
      _displayedDefs = filtered;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String q) {
    setState(() {
      _searchQuery = q;
      _isLoading = true;
    });
    _applyFilters();
  }

  void _openFilterDialog() {
    // Local copies
    bool useProfile = _useProfileFilter;
    int? chosenProfileId = _dialogProfileId;
    List<String> dialogEquipment = List.from(_equipmentList);
    String eqFilter = _filterEquipment;
    String areaFilter = _filterArea;
    String muscleFilter = _filterMuscle;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Selected Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Use Workspace Profile'),
                    value: useProfile,
                    onChanged: (v) async {
                      setDialogState(() => useProfile = v);
                      // Reload equipment list for dialog
                      List<String> names;
                      if (v && chosenProfileId != null) {
                        var cpid = chosenProfileId?.toInt() ?? 0;
                        final eqMaps = await DatabaseHelper().fetchEquipmentForProfile(cpid);
                        names = eqMaps.map((e) => e['name'] as String).toList();
                      } else {
                        names = await _repo.fetchAllEquipmentNames();
                      }
                      setDialogState(() {
                        dialogEquipment = ['All', ...names];
                        if (!dialogEquipment.contains(eqFilter)) eqFilter = 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Workspace Profile'),
                    value: chosenProfileId,
                    items: List.generate(
                      _profileIds.length,
                      (i) => DropdownMenuItem(
                        value: _profileIds[i],
                        child: Text(_profileNames[i]),
                      ),
                    ),
                    onChanged: useProfile
                        ? (v) async {
                            setDialogState(() => chosenProfileId = v);
                            // reload equipment for this profile
                            final eqMaps = await DatabaseHelper().fetchEquipmentForProfile(v!);
                            final names = eqMaps.map((e) => e['name'] as String).toList();
                            setDialogState(() {
                              dialogEquipment = ['All', ...names];
                              if (!dialogEquipment.contains(eqFilter)) eqFilter = 'All';
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Equipment'),
                    value: eqFilter,
                    items: dialogEquipment
                        .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => eqFilter = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Area of Focus'),
                    value: areaFilter,
                    items: _bodyPartList
                        .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => areaFilter = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Specific Muscle'),
                    value: muscleFilter,
                    items: _muscleList
                        .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => muscleFilter = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Commit dialog selections
                  setState(() {
                    _useProfileFilter = useProfile;
                    _dialogProfileId = chosenProfileId;
                    _equipmentList = dialogEquipment;
                    _filterEquipment = eqFilter;
                    _filterArea = areaFilter;
                    _filterMuscle = muscleFilter;
                  });
                  Navigator.of(ctx).pop();
                  _loadLookupsAndDefs();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Catalog'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Exercises',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _openFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters'),
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(child: Text('Previously Done: TODO')),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedDefs.isEmpty
                      ? const Center(child: Text('No exercises match filters.'))
                      : ListView.builder(
                          itemCount: _displayedDefs.length,
                          itemBuilder: (_, i) {
                            final def = _displayedDefs[i];
                            return ListTile(
                              title: Text(def.name),
                              subtitle: Text(def.equipmentList.map((e) => e.name).join(', ')),
                              selected: widget.onExercisePicked != null && _selectedDef == def,
                              onTap: widget.onExercisePicked == null
                                  ? null
                                  : () {
                                      setState(() => _selectedDef = def);
                                    },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.onExercisePicked != null && _selectedDef != null
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                widget.onExercisePicked!(_selectedDef!);
                Navigator.of(context).pop();
              },
            )
          : null,
    );
  }
}
