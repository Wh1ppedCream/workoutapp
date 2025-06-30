// File: lib/widgets/exercise_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/selected_profile.dart';
import '../repositories/app_repository.dart';
import '../models/gym_models.dart';
import '../repositories/profile_repository.dart';
import '../widgets/exercise_detail_sheet.dart';


/// Catalog of exercise definitions with workspace-profile and advanced filters.
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

  // All loaded definitions (fully detailed)
  List<ExerciseDefinition> _allDefs = [];
  List<ExerciseDefinition> _displayedDefs = [];
  bool _isLoading = true;

  // Search query
  String _searchQuery = '';

  // Filter dialog state
  bool _useProfileFilter = true;
  int? _dialogProfileId;
  String _filterEquipment = 'All';
  String _filterArea = 'All';
  String _filterMuscle = 'All';

  // Dropdown options
  List<GymProfile> _profiles = [];
  List<String> _equipmentOptions = ['All'];
  List<String> _areaOptions = ['All'];
  List<String> _muscleOptions = ['All'];

  ExerciseDefinition? _selectedDef;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Guard: capture context-synced values before any awaits
    final sel = context.read<SelectedProfile>();
    final initialProfileId = sel.currentProfile?.id;
    setState(() { _isLoading = true; });
    // Load full definitions
    _allDefs = await _repo.lookupDefsDetailed();
    _displayedDefs = List.from(_allDefs);
    // Load profiles list
    _profiles = await _repo.dbHelper.fetchAllProfiles();
    _dialogProfileId = initialProfileId;

     // Load body-part, muscle, and equipment options
    final areas = await _repo.fetchAllBodyParts();
    final muscles = await _repo.fetchAllMuscles();

    // Figure out initial equipment list
    List<String> initialEquipment;
    if (_useProfileFilter && initialProfileId != null) {
      // only that profile’s gear
      final eqMaps = await _repo.dbHelper.fetchEquipmentForProfile(initialProfileId);
      initialEquipment = eqMaps.map((e) => e['name'] as String).toList();
    } else {
      // everything
      initialEquipment = await _repo.fetchAllEquipmentNames();
    }

    setState(() {
      _areaOptions = ['All', ...areas.map((b) => b.name)];
      _muscleOptions = ['All', ...muscles.map((m) => m.name)];
      _equipmentOptions = ['All', ...initialEquipment];
      _displayedDefs = List.from(_allDefs);  // show all until they hit “Save”
      _isLoading = false;
    });
  }

  Future<void> _applyAllFilters() async {
    setState(() { _isLoading = true; });
    List<ExerciseDefinition> filtered = List.from(_allDefs);

    // 1) Workspace profile subset-of filter
    if (_useProfileFilter && _dialogProfileId != null) {
      final eqMaps = await _repo.dbHelper.fetchEquipmentForProfile(_dialogProfileId!);
      final allowed = eqMaps.map((e) => e['name'] as String).toSet();
      filtered = filtered.where((d) {
        return d.equipmentList.every((eq) => allowed.contains(eq.name));
      }).toList();
      // Also populate equipment options from profile gear
      setState(() {
        _equipmentOptions = ['All', ...allowed];
      });
    } else {
      // Profile off: use global equipment list
      final allEq = await _repo.fetchAllEquipmentNames();
      setState(() {
        _equipmentOptions = ['All', ...allEq];
      });
    }

    // 2) Single-equipment any-of filter
    if (_filterEquipment != 'All') {
      filtered = filtered.where((d) =>
          d.equipmentList.any((eq) => eq.name == _filterEquipment)
      ).toList();
    }

    // 3) Area of Focus filter
    if (_filterArea != 'All') {
      filtered = filtered.where((d) =>
          d.bodyParts.any((bp) => bp.name == _filterArea)
      ).toList();
    }

    // 4) Specific Muscle filter
    if (_filterMuscle != 'All') {
      filtered = filtered.where((d) =>
          d.muscles.any((rm) => rm.muscle.name == _filterMuscle)
      ).toList();
    }

    // 5) Search filter
    final q = _searchQuery.toLowerCase();
    filtered = filtered.where((d) =>
        q.isEmpty || d.name.toLowerCase().contains(q)
    ).toList();

    setState(() {
      _displayedDefs = filtered;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String q) {
    setState(() {
      _searchQuery = q;
    });
    _applyAllFilters();
  }

  void _openFilterDialog() {
    // Dialog local copies
    bool useProfile = _useProfileFilter;
    int? chosenProfile = _dialogProfileId;
    String eq = _filterEquipment;
    String area = _filterArea;
    String muscle = _filterMuscle;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Selected Filters'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SwitchListTile(
                title: const Text('Use Workspace Profile'),
                value: useProfile,
                onChanged: (v) => setDialogState(() => useProfile = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Workspace Profile'),
                value: chosenProfile,
                items: _profiles.map((p) => DropdownMenuItem(
                      value: p.id!, child: Text(p.name))).toList(),
                onChanged: useProfile
                    ? (v) => setDialogState(() => chosenProfile = v)
                    : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Equipment'),
                value: eq,
                items: _equipmentOptions
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => eq = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Area of Focus'),
                value: area,
                items: _areaOptions
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => area = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Specific Muscle'),
                value: muscle,
                items: _muscleOptions
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => muscle = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _useProfileFilter = useProfile;
                  _dialogProfileId = chosenProfile;
                  _filterEquipment = eq;
                  _filterArea = area;
                  _filterMuscle = muscle;
                });
                Navigator.of(ctx).pop();
                _applyAllFilters();
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
                labelText: 'Search Exercises', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
            Expanded(
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
                              trailing: IconButton(
   icon: const Icon(Icons.info_outline),
   onPressed: () => showModalBottomSheet(
     context: context,
     isScrollControlled: true,
     builder: (_) => ExerciseDetailSheet(definition: def, defId: def.id),
   ),
 ),
                              //the following two lines show equipment names under exercise name if they are uncommented.
                              //subtitle: Text(def.equipmentList.map((e) => e.name).join(', ')),
                              selected: widget.onExercisePicked != null && _selectedDef == def,
                              onTap: widget.onExercisePicked == null
                                  ? null
                                  : () => setState(() => _selectedDef = def),
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
