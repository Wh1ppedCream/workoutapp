// file: lib/screens/profile/settings/exercise_editor_screen.dart
// Exercise Editor Screen: allows viewing and editing an exercise definition.

import 'package:flutter/material.dart';
import '../../../repositories/app_repository.dart';
import '../../../models/models.dart';

/// Exercise Editor Screen: allows viewing and editing an exercise definition.
class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({super.key});

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AppRepository();
  late final TabController _tabController;
  bool _isEditing = false;

  // Definitions
  List<ExerciseDefinition> _defs = [];
  ExerciseDefinition? _selectedDef;
  bool _isNewExercise = false;

  // Tab data
  List<Map<String, Object>> _muscleEntries = []; // { 'id': int, 'name': String, 'percent': double }
  List<Map<String, Object>> _bodyEntries = [];   // { 'id': int, 'name': String, 'percent': double }
  
  bool _useManualBody = false;

  // new:
List<Map<String, Object>> _equipmentEntries = []; // { 'id': int, 'name': String }
late List<int> _originalEquipmentIds;

List<Map<String, Object>> _bodyAutoEntries = [];   // muscle‐calculated values
List<Map<String, Object>> _bodyManualEntries = []; // manual overrides



  // Notes & Media (stubbed)
  String _setupNotes = '';
  String _executionNotes = '';
  String _tipsNotes = '';
  List<Map<String, Object>> _mediaItems = []; // { 'type': 'image'|'video'|'link', 'url': '' }

  /// IDs of muscles the user has deleted in this edit session.
final Set<int> _musclesToRemove = {};

/// the IDs we loaded initially, so we can diff on Save
late List<int> _originalMuscleIds;

// IDs of bodyparts the user loaded initially, so we can diff on Save
late List<int> _originalBodypartIds;




  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExerciseList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load all definitions and select the first one
  Future<void> _loadExerciseList() async {
    final defs = await _repo.lookupDefsDetailed();
    setState(() {
      _defs = defs;
      _selectedDef = null;
      _isNewExercise = false;
      _isEditing = false;
    });
  }

  /// Handle selecting an exercise definition
  Future<void> _onExerciseSelected(ExerciseDefinition def) async {
  setState(() {
    _selectedDef = def;
    _isNewExercise = false;
    _isEditing = false;
  });
  _tabController.index = 0;
  await _loadDefinitionDetails(def);
}


  /// Populate muscles, bodyparts, equipment for the selected definition
Future<void> _loadDefinitionDetails(ExerciseDefinition def) async {
  final defId = def.id;
  final now   = DateTime.now();
  // Pick a range for calculating sets: for “all time”, start at epoch
  final start = DateTime.fromMillisecondsSinceEpoch(0);

  // 1) Muscle‐hit percents (for the Muscles tab)
  final musclePercents = await _repo.computeMusclePercents(defId);

  // 2) Muscle‐calculated body‐part counts for this definition
  final autoBpMap = await _repo.fetchSetsPerBodyPartForDefinition(
    defId: defId,
    start: start,
    end:   now,
  );

  // 3) Manual overrides from your new table
  final manualList = await _repo.fetchBodyPartPercentsManual(defId);
  final manualMap  = { for (var e in manualList) e.bodyPartId : e.percent };

  setState(() {
    // --- Muscles Tab data (unchanged) ---
    _muscleEntries = def.muscles.map((rm) {
      final override = musclePercents.firstWhere(
        (e) => e.muscleId == rm.muscle.id,
        orElse: () => ExerciseMusclePercent(
          exerciseDefId: defId,
          muscleId:      rm.muscle.id,
          percent:       0.0,
        ),
      );
      return {
        'id':      rm.muscle.id,
        'name':    rm.muscle.name,
        'percent': override.percent,
      };
    }).toList();
    _originalMuscleIds = def.muscles.map((rm) => rm.muscle.id).toList();

    // --- Muscle-Calculated Bodyparts ---
    _bodyAutoEntries = autoBpMap.entries.map((e) {
  final bp    = e.key;   // a BodyPart instance
  final count = e.value; // the number of sets for that part
  return {
    'id':      bp.id,
    'name':    bp.name,
    'percent': count,  // call this 'count' if you like
  };
}).toList();

    // Keep original bodypart ids for diffing manual changes
    _originalBodypartIds = def.bodyParts.map((bp) => bp.id).toList();

    // --- Manual-Assigned Bodyparts ---
    _bodyManualEntries = def.bodyParts.map((bp) {
      // seed with override if present, else default 0
      final pct = manualMap[bp.id] ?? 0.0;
      return {
        'id':      bp.id,
        'name':    bp.name,
        'percent': pct,
      };
    }).toList();

    // Equipment (unchanged)
    _equipmentEntries = def.equipmentList
        .map((e) => {'id': e.id, 'name': e.name})
        .toList();
    _originalEquipmentIds = def.equipmentList.map((e) => e.id).toList();
  });
}



  Future<void> _toggleEdit() async {
   // if we’re about to exit editing mode, commit our muscle changes
   if (_isEditing && _selectedDef != null) {
     await _saveMuscleChanges();
     await _saveEquipmentChanges();
     await _saveBodypartChanges();
   }
   setState(() => _isEditing = !_isEditing);
 }


/// Persist adds/removals of bodyparts when saving.
Future<void> _saveBodypartChanges() async {
  final defId = _selectedDef!.id;

  final currIds = _bodyEntries
      .map((e) => e['id'] as int)
      .toSet();
  final origIds = _originalBodypartIds.toSet();

  // 1) removals
  for (var removed in origIds.difference(currIds)) {
    await _repo.deleteExerciseBodypartMapping(defId, removed);
  }

  // 2) additions
  for (var added in currIds.difference(origIds)) {
    await _repo.addExerciseBodypartMapping(defId, added);
  }

  // 3) percent overrides
for (var entry in _bodyEntries) {
  final bpId = entry['id'] as int;
  final pct  = entry['percent'] as double;
  if (_useManualBody) {
    await _repo.setExerciseBodyPartPercent(defId, bpId, pct);
  } else {
    // if they’ve switched back to auto, wipe out any manual override
    await _repo.removeExerciseBodyPartPercent(defId, bpId);
  }
}

  // reset baseline
  _originalBodypartIds = currIds.toList();
}

/// Let the user pick one or more new BodyParts to stage.
Future<void> _openAddBodypartDialog() async {
  final allBps = await _repo.fetchAllBodyPartsFull(); // List<BodyPart>
  final existing = _bodyEntries.map((e) => e['id'] as int).toSet();
  final available = allBps.where((bp) => !existing.contains(bp.id)).toList();
  final selectedIds = <int>{};

  final result = await showDialog<Set<int>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Associated Bodyparts'),
      content: SizedBox(
        width: double.maxFinite,
        child: StatefulBuilder(builder: (ctx2, setState2) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: available.length,
            itemBuilder: (_, i) {
              final bp = available[i];
              final checked = selectedIds.contains(bp.id);
              return CheckboxListTile(
                title: Text(bp.name),
                value: checked,
                onChanged: (on) => setState2(() {
                  if (on == true) selectedIds.add(bp.id);
                  else selectedIds.remove(bp.id);
                }),
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(),    child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(selectedIds), child: const Text('Add')),
      ],
    ),
  );

  if (result != null && result.isNotEmpty) {
    setState(() {
      for (var id in result) {
        final bp = allBps.firstWhere((b) => b.id == id);
        _bodyEntries.add({'id': bp.id, 'name': bp.name, 'percent': 0.0});
      }
    });
  }
}


 /// Persist adds/removals on equipment when saving.
Future<void> _saveEquipmentChanges() async {
  final defId = _selectedDef!.id;

  final currIds = _equipmentEntries
      .map((e) => e['id'] as int)
      .toSet();
  final origIds = _originalEquipmentIds.toSet();

  // 1) removals
  for (var removed in origIds.difference(currIds)) {
    await _repo.deleteExerciseEquipmentMapping(defId, removed);
  }

  // 2) additions
  for (var added in currIds.difference(origIds)) {
    await _repo.addExerciseEquipmentMapping(defId, added);
  }

  // reset baseline
  _originalEquipmentIds = currIds.toList();
}



/// Compare the original vs. current _muscleEntries and persist adds/removes/percentage‐overrides.
Future<void> _saveMuscleChanges() async {
  final def = _selectedDef!;
  final defId = def.id;

  // current IDs & a quick lookup for percent
  final currIds = _muscleEntries.map((e) => e['id'] as int).toSet();
  final currPct = {
    for (var e in _muscleEntries) e['id'] as int : e['percent'] as double
  };

  final origIds = _originalMuscleIds.toSet();

  // 1) removals
  for (var removed in origIds.difference(currIds)) {
    await _repo.deleteExerciseMuscleMapping(defId, removed);
    // also wipe out any overrides
    await _repo.removeExerciseMusclePercent(defId, removed);
  }

  // 2) additions
  for (var added in currIds.difference(origIds)) {
    // new rank = position in the list + 1
    final rank = _muscleEntries.indexWhere((e) => e['id'] == added) + 1;
    await _repo.addExerciseMuscleMapping(defId, added, rank);
    // if user typed a percent override
    final p = currPct[added]!;
    if (p != 0.0) {
      await _repo.setExerciseMuscleHitPercent(defId, added, p);
    }
  }

  // 3) updates for existing
  for (var kept in currIds.intersection(origIds)) {
    final p = currPct[kept]!;
    await _repo.setExerciseMuscleHitPercent(defId, kept, p);
  }

  // refresh our baseline for any further edits
  _originalMuscleIds = currIds.toList();
}



/// Show a dialog of all muscles *not* yet on this exercise,
/// let the user pick many, and then add them (with 0% default) to the UI list.
Future<void> _openAddMuscleDialog() async {
  // 1) grab every muscle in the DB
  final allMuscles = await _repo.fetchAllMusclesFull();
  // 2) filter out the ones already staged
  final existingIds = _muscleEntries.map((e) => e['id'] as int).toSet();
  final available = allMuscles.where((m) => !existingIds.contains(m.id)).toList();

  // 3) track selections
  final selectedIds = <int>{};

  // 4) show dialog
  if (!mounted) return;
  final result = await showDialog<Set<int>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Associated Muscles'),
      content: SizedBox(
        width: double.maxFinite,
        // need StatefulBuilder to update the checkboxes
        child: StatefulBuilder(builder: (ctx2, setDialogState) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: available.length,
            itemBuilder: (ctx3, i) {
              final m = available[i];
              final checked = selectedIds.contains(m.id);
              return CheckboxListTile(
                title: Text(m.name),
                value: checked,
                onChanged: (on) {
                  setDialogState(() {
                    if (on == true) {
                      selectedIds.add(m.id);
                    } else {
                      selectedIds.remove(m.id);
                    }
                  });
                },
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () => Navigator.of(ctx).pop(selectedIds),
        ),
      ],
    ),
  );

  // 5) merge them into the UI list
  if (result != null && result.isNotEmpty) {
    setState(() {
      for (final id in result) {
        final m = allMuscles.firstWhere((muscle) => muscle.id == id);
        _muscleEntries.add(<String, Object>{
          'id':      m.id,
          'name':    m.name,
          'percent': 0.0,
        });
      }
    });
  }
}

/// Let the user pick one or more new equipment items to stage.
Future<void> _openAddEquipmentDialog() async {
  final allEq = await _repo.fetchAllEquipment(); // List<Equipment>
  final existing = _equipmentEntries.map((e) => e['id'] as int).toSet();
  final available = allEq.where((e) => !existing.contains(e.id)).toList();
  final selectedIds = <int>{};

if (!mounted) return;
  final result = await showDialog<Set<int>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Equipment'),
      content: SizedBox(
        width: double.maxFinite,
        child: StatefulBuilder(builder: (ctx2, setState2) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: available.length,
            itemBuilder: (_, i) {
              final eq = available[i];
              final checked = selectedIds.contains(eq.id);
              return CheckboxListTile(
                title: Text(eq.name),
                value: checked,
                onChanged: (on) => setState2(() {
                  if (on == true) {
                    selectedIds.add(eq.id);
                  } else {
                    selectedIds.remove(eq.id);
                  }
                }),
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(),    child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(selectedIds), child: const Text('Add')),
      ],
    ),
  );

  if (result != null) {
    setState(() {
      for (var id in result) {
        final eq = allEq.firstWhere((e) => e.id == id);
        _equipmentEntries.add({'id': eq.id, 'name': eq.name});
      }
    });
  }
}



  @override
  Widget build(BuildContext context) {
    // **ADD**: show a loader until an exercise is selected
    if (_defs.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 250,
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue txt) {
              final names = _defs.map((d) => d.name).toList();
              if (txt.text.isEmpty) return names;
              return names
                  .where(
                      (name) => name.toLowerCase().contains(txt.text.toLowerCase()))
                  .toList();
            },
            onSelected: (selection) {
              final match = _defs.firstWhere(
                (d) => d.name == selection,
                orElse: () => ExerciseDefinition(
                  id: -1,
                  name: selection,
                  equipmentId: null,
                  rating: 0,
                  equipmentList: [],
                  bodyParts: [],
                  muscles: [],
                ),
              );
              if (match.id == -1) {
                // New exercise
                setState(() {
                  _isNewExercise = true;
                  _selectedDef = null;
                  _isEditing = true;
                  _muscleEntries = [];
                  _bodyEntries = [];
                  _equipmentEntries  = [];
                });
              } else {
                _onExerciseSelected(match);
              }
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
    controller: textController,
    focusNode: focusNode,
    decoration: InputDecoration(
                  hintText: 'Select or enter exercise',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  filled: true,
      fillColor: Theme.of(context)
          .colorScheme
          .surface
          .withAlpha(25),
    ),
    onSubmitted: (_) => onFieldSubmitted(),
  );
},
            optionsViewBuilder: (ctx, onSelected, options) {
              return Material(
                elevation: 4,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: options
                      .map((opt) => ListTile(
                            title: Text(opt),
                            onTap: () => onSelected(opt),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: (_selectedDef != null || _isNewExercise)
    ? () => _toggleEdit()
    : null,
            tooltip: _isEditing ? 'Save' : 'Edit',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Muscles'),
                Tab(text: 'Bodyparts'),
                Tab(text: 'Equipment'),
                Tab(text: 'Notes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMusclesTab(),
                _buildBodypartsTab(),
                _buildEquipmentTab(),
                _buildNotesMediaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusclesTab() {
    return Column(
      children: [
        Expanded(
          child: _muscleEntries.isEmpty
              ? const Center(child: Text('No muscles associated'))
              : ListView.builder(
                  itemCount: _muscleEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _muscleEntries[index];
                    return ListTile(
                      leading: _isEditing
                          ? IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () async {
    final muscleId   = entry['id']   as int;
    final muscleName = entry['name'] as String;
    // 1) confirm
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Muscle'),
        content: Text('Remove "$muscleName" from this exercise?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true),  child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;

    // 2) queue it and remove from the visible list
    setState(() {
      _musclesToRemove.add(muscleId);
      _muscleEntries.removeAt(index);
    });
  },
)

                          : null,
                      title: Text(entry['name'] as String),
                      trailing: SizedBox(
                        width: 80,
                        child: TextFormField(
                          enabled: _isEditing,
                          initialValue: entry['percent'].toString(),
                          decoration: const InputDecoration(suffixText: '%'),
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (val) {
                            // TODO: update percent override
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _openAddMuscleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Associated Muscle'),
            ),
          ),
      ],
    );
  }

Widget _buildBodypartsTab() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _useManualBody,
              onChanged: _isEditing
                  ? (v) => setState(() => _useManualBody = v ?? false)
                  : null,
            ),
            const Text('Use Manual Bodyparts'),
          ],
        ),
        const SizedBox(height: 16),

        // 1) Muscle-Calculated section
        const Text('Muscle-Calculated Bodyparts',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(child: _buildAutoBodyparts()),

        const SizedBox(height: 24),

        // 2) Manually-Assigned section
        const Text('Manually Assigned Bodyparts',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(child: _buildManualBodyparts()),

        // Only allow adding when in edit mode & manual toggled on
        if (_isEditing && _useManualBody)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: _openAddBodypartDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Bodypart'),
            ),
          ),
      ],
    ),
  );
}


// ========= Muscle-Calculated Bodyparts =========
Widget _buildAutoBodyparts() {
  // No editing here, just show the count each muscle contributes to each body-part
  return ListView(
    children: _bodyAutoEntries.map((e) {
      final name  = e['name']    as String;
      final count = e['percent'] as double; // this is actually a count, not a % 
      return ListTile(
        title: Text(name),
        trailing: Text(
          count.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }).toList(),
  );
}

// ========= Manually-Assigned Bodyparts =========
Widget _buildManualBodyparts() {
  return ListView.builder(
    itemCount: _bodyManualEntries.length,
    itemBuilder: (_, i) {
      final entry = _bodyManualEntries[i];
      final id    = entry['id']      as int;
      final name  = entry['name']    as String;
      final pct   = entry['percent'] as double;

      return ListTile(
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Remove Bodypart'),
                      content: Text('Remove "$name" from this exercise?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(context).pop(true),  child: const Text('Remove')),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  setState(() {
                    _bodyManualEntries.removeAt(i);
                  });
                },
              )
            : null,
        title: Text(name),
        trailing: SizedBox(
          width: 80,
          child: TextFormField(
            enabled: _isEditing && _useManualBody,
            initialValue: pct.toStringAsFixed(1),
            decoration: const InputDecoration(suffixText: '%'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (val) {
              final newPct = double.tryParse(val) ?? 0.0;
              setState(() {
                entry['percent'] = newPct;
              });
            },
          ),
        ),
      );
    },
  );
}



  

 Widget _buildEquipmentTab() {
  return Column(
    children: [
      Expanded(
        child: _equipmentEntries.isEmpty
            ? const Center(child: Text('No equipment associated'))
            : ListView.builder(
                itemCount: _equipmentEntries.length,
                itemBuilder: (context, i) {
                  final entry = _equipmentEntries[i];
                  return ListTile(
                    leading: _isEditing
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final eqId = entry['id'] as int;
                              final eqName = entry['name'] as String;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Remove Equipment'),
                                  content: Text('Remove "$eqName" from this exercise?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.of(context).pop(true),  child: const Text('Remove')),
                                  ],
                                ),
                              );
                              if (confirm != true) return;
                              setState(() {
                                _equipmentEntries.removeAt(i);
                              });
                            },
                          )
                        : null,
                    title: Text(entry['name'] as String),
                  );
                },
              ),
      ),
      if (_isEditing)
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _openAddEquipmentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Equipment'),
          ),
        ),
    ],
  );
}


  Widget _buildNotesMediaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Setup', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            enabled: _isEditing,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: TextEditingController(text: _setupNotes),
            onChanged: (val) {
              // TODO: update setup notes
            },
          ),
          const SizedBox(height: 12),
          const Text('Execution', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            enabled: _isEditing,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: TextEditingController(text: _executionNotes),
            onChanged: (val) {
              // TODO: update execution notes
            },
          ),
          const SizedBox(height: 12),
          const Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            enabled: _isEditing,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: TextEditingController(text: _tipsNotes),
            onChanged: (val) {
              // TODO: update tips
            },
          ),
          const SizedBox(height: 24),
          const Text('Media', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _mediaItems.length + (_isEditing ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isEditing && index == _mediaItems.length) {
                return GestureDetector(
                  onTap: () {
                    // TODO: add media
                  },
                  child: Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.add),
                  ),
                );
              }
              final media = _mediaItems[index];
              // TODO: render actual media thumbnail
              return Stack(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: Center(child: Text(media['url'] as String)),
                  ),
                  if (_isEditing)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: remove media
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }



}
