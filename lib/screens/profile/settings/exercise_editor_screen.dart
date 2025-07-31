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
  List<Map<String, dynamic>> _muscleEntries = []; // { 'id': int, 'name': String, 'percent': double }
  List<Map<String, dynamic>> _bodyEntries = [];   // { 'id': int, 'name': String, 'percent': double }
  List<String> _equipmentList = [];
  bool _useManualBody = false;

  // Notes & Media (stubbed)
  String _setupNotes = '';
  String _executionNotes = '';
  String _tipsNotes = '';
  List<Map<String, dynamic>> _mediaItems = []; // { 'type': 'image'|'video'|'link', 'url': '' }

  /// IDs of muscles the user has deleted in this edit session.
final Set<int> _musclesToRemove = {};


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
    // new: pass the definition ID positionally
final musclePercents = await _repo.computeMusclePercents(
  _selectedDef!.id,
);
final Map<BodyPart, double> bodyPercents =
    await _repo.computeBodyPartPercents(
  _selectedDef!.id,
);



    setState(() {
      // Map muscles by definition order, default percent 0 if missing
      _muscleEntries = def.muscles.map((rm) {
        final percentEntry = musclePercents.firstWhere(
          (e) => e.muscleId == rm.muscle.id,
          orElse: () => ExerciseMusclePercent(
            exerciseDefId: def.id, 
            muscleId: rm.muscle.id,
            percent: 0.0,
          ),
        );
        return {
          'id': rm.muscle.id,
          'name': rm.muscle.name,
          'percent': percentEntry.percent,
        };
      }).toList();

      // Map bodyparts by definition, default percent 0 if missing
      _bodyEntries = def.bodyParts.map((bp) {
        final p = bodyPercents[bp] ?? 0.0;
        return {
          'id': bp.id,
          'name': bp.name,
          'percent': p,
        };
      }).toList();

      _equipmentList = def.equipmentList.map((e) => e.name).toList();
    });
  }

  Future<void> _toggleEdit() async {
  // If we’re currently editing, and the user just tapped “Save”:
  if (_isEditing && _selectedDef != null && _musclesToRemove.isNotEmpty) {
    for (var muscleId in _musclesToRemove) {
      // <-- call your repo/DB method to remove the muscle association
      await _repo.deleteExerciseMuscleMapping(_selectedDef!.id, muscleId);

    }
    _musclesToRemove.clear();
    // reload full details so all tabs refresh
    await _loadDefinitionDetails(_selectedDef!);
  }
  setState(() {
    _isEditing = !_isEditing;
  });
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
                  _equipmentList = [];
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
            onPressed: _selectedDef != null || _isNewExercise ? _toggleEdit : null,
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
              onPressed: () {
                // TODO: open add-muscle modal
              },
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
                    ? (val) => setState(() => _useManualBody = val ?? false)
                    : null,
              ),
              const Text('Use Manual Bodyparts'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _useManualBody
                ? _buildManualBodyparts()
                : _buildAutoBodyparts(),
          ),
          if (_isEditing && _useManualBody)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: open add-bodypart modal
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Associated Bodypart'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoBodyparts() {
    return ListView(
      children: _bodyEntries.map((entry) {
        return ListTile(
          title: Text(entry['name'] as String),
          trailing: Text('${entry['percent']}%'),
        );
      }).toList(),
    );
  }

  Widget _buildManualBodyparts() {
    return ListView(
      children: _bodyEntries.map((entry) {
        return ListTile(
          leading: _isEditing
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: remove bodypart
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
                // TODO: update bodypart percent override
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentTab() {
    return Column(
      children: [
        Expanded(
          child: _equipmentList.isEmpty
              ? const Center(child: Text('No equipment associated'))
              : ListView.builder(
                  itemCount: _equipmentList.length,
                  itemBuilder: (context, index) {
                    final eq = _equipmentList[index];
                    return ListTile(
                      leading: _isEditing
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // TODO: remove equipment
                              },
                            )
                          : null,
                      title: Text(eq),
                    );
                  },
                ),
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: open add-equipment modal
              },
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
                    child: Center(child: Text(media['type'])),
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
