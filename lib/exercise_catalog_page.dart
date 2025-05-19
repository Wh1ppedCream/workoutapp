// File: lib/exercise_catalog_page.dart
import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models.dart';

class ExerciseCatalogPage extends StatefulWidget {
  const ExerciseCatalogPage({Key? key}) : super(key: key);

  @override
  _ExerciseCatalogPageState createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  List<Equipment> _equipmentList = [];
  List<BodyPart> _bodyPartList = [];
  List<ExerciseDefinition> _allDefinitions = [];
  List<ExerciseDefinition> _filtered = [];

  int? _selectedEquipmentId;
  int? _selectedBodyPartId;

  @override
  void initState() {
    super.initState();
    _loadLookupsAndDefs();
  }

  Future<void> _loadLookupsAndDefs() async {
   final dbHelper = DatabaseHelper();
   final database = await dbHelper.database;
   // Fetch equipment
   final eqRows = await database.query('equipment');
    _equipmentList = eqRows.map((r) => Equipment(r['id'] as int, r['name'] as String)).toList();

    // Fetch body parts
    final bpRows = await database.query('bodypart');
    _bodyPartList = bpRows.map((r) => BodyPart(r['id'] as int, r['name'] as String)).toList();

    // Fetch definitions
    final defRows = await database.query('exercise_definitions');
    _allDefinitions = defRows.map((r) =>
      ExerciseDefinition(
        id: r['id'] as int,
        name: r['name'] as String,
        equipmentId: r['equipment_id'] as int?,
      )
    ).toList();

    setState(() {
      _filtered = _allDefinitions;
    });
  }

  void _applyFilters() {
    setState(() {
      _filtered = _allDefinitions.where((def) {
        final matchEq = _selectedEquipmentId == null || def.equipmentId == _selectedEquipmentId;
        // For bodyPart filter, you’d need a join - here we skip until adding a query method
        final matchBp = true; 
        return matchEq && matchBp;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Catalog')),
      body: Column(
        children: [
          // Equipment filter dropdown (insert around top of body)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<int?>(
              decoration: const InputDecoration(labelText: 'Filter by Equipment'),
              items: [null, ..._equipmentList].map((eq) {
                return DropdownMenuItem<int?>(
                  value: eq?.id,
                  child: Text(eq?.name ?? 'All'),
                );
              }).toList(),
              onChanged: (val) {
                _selectedEquipmentId = val;
                _applyFilters();
              },
              value: _selectedEquipmentId,
            ),
          ),
          // Body part filter placeholder (expand later with join query)
          // ...

          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final def = _filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(def.name),
                    subtitle: Text(
                      def.equipmentId != null
                        ? _equipmentList.firstWhere((e) => e.id == def.equipmentId).name
                        : 'No equipment'
                    ),
                    onTap: () {
                      // TODO: navigate to history-by-definition screen
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
