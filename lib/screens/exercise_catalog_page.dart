import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models.dart';

class ExerciseCatalogPage extends StatefulWidget {
  final void Function(ExerciseDefinition)? onExercisePicked;
  const ExerciseCatalogPage({
    super.key,
    this.onExercisePicked,
  });

  @override
  _ExerciseCatalogPageState createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  final _db = DatabaseHelper();

  // Lookup lists
  List<String> _equipmentList = [];
  List<String> _bodyPartList = [];
  List<String> _muscleList = [];

  // All definitions and filtered view
  List<ExerciseDefinition> _allDefs = [];
  List<ExerciseDefinition> _displayedDefs = [];

  // Filters
  String _filterEquipment = 'All';
  String _filterArea = 'All';
  String _filterMuscle = 'All';

  // Loading / search
  bool _isLoading = true;
  String _searchQuery = '';

  ExerciseDefinition? _selectedDef;

  @override
  void initState() {
    super.initState();
    _loadLookupsAndDefs();
  }

  Future<void> _loadLookupsAndDefs() async {
    try {
      final equipmentNames = await _db.getAllEquipmentNames();

      // getAllBodyParts returns List<BodyPart>; map to names
      final bodyParts = await _db.getAllBodyParts();
      final bodyPartNames = bodyParts.map((bp) => bp.name).toList();

      final muscleNames = await _db.getAllMuscleNames();

      setState(() {
        _equipmentList = ['All', ...equipmentNames];
        _bodyPartList = ['All', ...bodyPartNames];
        _muscleList = ['All', ...muscleNames];
      });

      final defs = await _db.getExerciseDefinitionsFiltered();
      setState(() {
        _allDefs = defs;
        _applySearchAndDisplay();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applySearchAndDisplay() {
    final query = _searchQuery.toLowerCase();
    final filtered = _allDefs.where((d) {
      return query.isEmpty || d.name.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _displayedDefs = filtered;
    });
  }

  void _openFilterDialog() {
    String selectedEq = _filterEquipment;
    String selectedArea = _filterArea;
    String selectedMuscle = _filterMuscle;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Selected Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  value: selectedEq,
                  items: _equipmentList
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setDialogState(() => selectedEq = v!);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Area of Focus'),
                  value: selectedArea,
                  items: _bodyPartList
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setDialogState(() => selectedArea = v!);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Specific Muscle'),
                  value: selectedMuscle,
                  items: _muscleList
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setDialogState(() => selectedMuscle = v!);
                  },
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
              onPressed: () async {
                Navigator.of(ctx).pop();
                setState(() => _isLoading = true);

                List<String>? equipNames =
                    selectedEq != 'All' ? [selectedEq] : null;

                List<int>? bodyPartIds;
                if (selectedArea != 'All') {
                  final rows = await (await _db.database)
                      .query('bodypart', where: 'name = ?', whereArgs: [selectedArea]);
                  if (rows.isNotEmpty) {
                    bodyPartIds = [rows.first['id'] as int];
                  }
                }

                List<int>? muscleIds;
                if (selectedMuscle != 'All') {
                  final rows = await (await _db.database)
                      .query('muscles', where: 'name = ?', whereArgs: [selectedMuscle]);
                  if (rows.isNotEmpty) {
                    muscleIds = [rows.first['id'] as int];
                  }
                }

                final defs = await _db.getExerciseDefinitionsFiltered(
                  equipmentNames: equipNames,
                  bodypartIds: bodyPartIds,
                  muscleIds: muscleIds,
                );

                setState(() {
                  _filterEquipment = selectedEq;
                  _filterArea = selectedArea;
                  _filterMuscle = selectedMuscle;
                  _allDefs = defs;
                  _applySearchAndDisplay();
                  _isLoading = false;
                });
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
                labelText: 'Search exercises',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) {
                setState(() {
                  _searchQuery = q;
                });
                _applySearchAndDisplay();
              },
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
            const Text(
              'Previously Done',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Expanded(
              flex: 1,
              child: Center(child: Text('TODO: load past exercises')),
            ),
            const SizedBox(height: 16),
            const Text(
              'All Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                              selected:
                                  widget.onExercisePicked != null && _selectedDef == def,
                              onTap: widget.onExercisePicked == null
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedDef = def;
                                      });
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
