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

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isEditing = false;

  // TODO: Replace with actual data from repository
  List<String> _exerciseNames = ['Bench Press', 'Squat', 'Deadlift'];
  String? _selectedExercise;
  bool _isNewExercise = false;

  // TODO: Replace with actual model lists
  List<Map<String, dynamic>> _muscleEntries = [];    // { 'name': '', 'percent': 100.0 }
  List<Map<String, dynamic>> _bodyEntries = [];      // { 'name': '', 'percent': 100.0 }
  List<String> _equipmentList = [];
  String _setupNotes = '';
  String _executionNotes = '';
  String _tipsNotes = '';
  List<Map<String, dynamic>> _mediaItems = [];       // { 'type': 'image'|'video'|'link', 'url': '' }
  bool _useManualBody = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // TODO: Load initial data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
    width: 250, // tweak to taste
    child: Autocomplete<String>(
      optionsBuilder: (TextEditingValue txt) {
        if (txt.text.isEmpty) return _exerciseNames;
        return _exerciseNames.where((e) =>
          e.toLowerCase().contains(txt.text.toLowerCase())
        );
      },
      onSelected: (selection) {
        setState(() {
          if (!_exerciseNames.contains(selection)) {
            // treat as "new"
            _isNewExercise = true;
            _selectedExercise = null;
            _isEditing = true;
          } else {
            _isNewExercise = false;
            _selectedExercise = selection;
            _isEditing = false;
            // TODO: load your model-data here
          }
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        // initialize text each time you open it
        controller.text = _isNewExercise
            ? ''
            : (_selectedExercise ?? '');
        return TextField(
          controller: controller,
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
  fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
),

          onSubmitted: (value) {
            // if they type something not in the list, treat as new:
            if (!_exerciseNames.contains(value)) {
              setState(() {
                _isNewExercise = true;
                _selectedExercise = null;
                _isEditing = true;
              });
            } else {
              setState(() {
                _selectedExercise = value;
                _isNewExercise = false;
              });
            }
            onSubmitted();
          },
        );
      },
     
      optionsViewBuilder: (ctx, onSelected, options) {
        return Material(
          elevation: 4,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options.map((opt) => ListTile(
              title: Text(opt),
              onTap: () => onSelected(opt),
            )).toList(),
          ),
        );
      },
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(_isEditing ? Icons.check : Icons.edit),
      onPressed: _toggleEdit,
      tooltip: _isEditing ? 'Save' : 'Edit',
    ),
  ],
  
),
      body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // put the TabBar in its own Material so the indicator shows
        Material(
  color: Theme.of(context).appBarTheme.backgroundColor,
  child: TabBar(
    controller: _tabController,
    padding: EdgeInsets.zero,
    indicatorPadding: EdgeInsets.zero,

    // Give only **right** padding on each label:
    labelPadding: const EdgeInsets.only(right: 16),

    tabs: const [
      Tab(text: 'Muscles'),
      Tab(text: 'Bodyparts'),
      Tab(text: 'Equipment'),
      Tab(text: 'Notes'),
    ],
  ),
),


        // then the content
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
                              onPressed: () {
                                // TODO: remove muscle
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
    // TODO: generate from muscle-bodypart mapping and percent
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
