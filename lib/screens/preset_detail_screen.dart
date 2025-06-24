// File: lib/screens/preset_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/preset_models.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../repositories/app_repository_presets.dart';
import '../widgets/add_exercise_fab.dart';
import '../widgets/exercise_card.dart';
import 'session_screen.dart';

/// Screen to view and edit a single Preset.
class PresetDetailScreen extends StatefulWidget {
  final int presetId;

  const PresetDetailScreen({super.key, required this.presetId});

  @override
  State<PresetDetailScreen> createState() => _PresetDetailScreenState();
}

class _PresetDetailScreenState extends State<PresetDetailScreen> {
  final AppRepository _repo = AppRepository();
  late Future<FullPreset?> _presetFuture;
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadPreset();
  }

  void _loadPreset() {
    _presetFuture = _repo.fetchFullPreset(widget.presetId);
    _presetFuture.then((fp) {
      if (fp != null) _nameController.text = fp.definition.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FullPreset?>(
      future: _presetFuture,
      builder: (context, snapshot) {
        // 1) loading state
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final preset = snapshot.data;
        if (preset == null) {
          return const Scaffold(
            body: Center(child: Text('Preset not found')),
          );
        }

        // 2) we have a valid preset + shared repo
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Preset Name',
                    ),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : Text(preset.definition.name),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: _isEditing ? Colors.green : Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isEditing = !_isEditing),
              ),
              PopupMenuButton<String>(
                onSelected: (_) {},
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),

          body: Column(
            children: [
              Expanded(
                child: _isEditing
                    ? ReorderableListView(
                        padding: const EdgeInsets.all(16),
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex--;
                          setState(() {
                            final item = preset.exercises.removeAt(oldIndex);
                            preset.exercises.insert(newIndex, item);
                          });
                          await _repo.reorderPresetExercises(
                            widget.presetId,
                            preset.exercises.map((e) => e.id).toList(),
                          );
                          _loadPreset();
                          setState(() {});
                        },
                        children: [
                          for (var ex in preset.exercises)
                            ExerciseCard(
                              key: ValueKey(ex.id),
                              exercise: _buildExerciseModel(preset, ex),
                              cardType: _cardTypeFromString(ex.type),
                              readOnlyMode: !_isEditing,
                              onDeleteExercise: _isEditing
                                  ? () async {
                                      await _repo
                                          .deletePresetExercise(ex.id);
                                      _loadPreset();
                                      setState(() {});
                                    }
                                  : null,
                              onSetAdded: _isEditing
                                  ? () {
                                      _loadPreset();
                                      setState(() {});
                                    }
                                  : null,
                              onSetDeleted: _isEditing
                                  ? () {
                                      _loadPreset();
                                      setState(() {});
                                    }
                                  : null,
                              onValueChanged: _isEditing
                                  ? () {
                                      _loadPreset();
                                      setState(() {});
                                    }
                                  : null,
                            ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: preset.exercises.length,
                        itemBuilder: (ctx, i) {
                          final ex = preset.exercises[i];
                          return ExerciseCard(
                            exercise: _buildExerciseModel(preset, ex),
                            cardType: _cardTypeFromString(ex.type),
                            readOnlyMode: true,
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _isEditing
                    ? ElevatedButton(
                        onPressed: () async {
                          await _repo.updatePresetName(
                              widget.presetId, _nameController.text);
                          setState(() {
                            _isEditing = false;
                            _loadPreset();
                          });
                        },
                        child: const Text('Save Preset'),
                      )
                    : ElevatedButton(
  onPressed: () async {
    // 1) capture the navigator synchronously
    final nav = Navigator.of(context);

    // 2) do the async work
    final sessionId = await _repo.startSessionFromPreset(widget.presetId);
    if (!mounted) return;

    // 3) use the captured navigator
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionScreen(),
        settings: RouteSettings(arguments: sessionId),
      ),
    );
  },
  child: const Text('Start Session'),
),

              ),
            ],
          ),

          // 3) only show this FAB when editing, wired with the loaded `preset`
          floatingActionButton: _isEditing
              ? AddExerciseFab(
                  onWeightPicked: (def) async {
                    final newIdx = preset.exercises.length;
                    final newId = await _repo.addExerciseToPreset(
                      widget.presetId,
                      def.id,
                      'weight',
                      newIdx,
                    );
                    await _repo.savePresetWeightSets(
                      newId,
                      [ExerciseSet()],
                      {},
                    );
                    _loadPreset();
                    setState(() {});
                  },
                  onCardioPicked: (name) async {
                    final newIdx = preset.exercises.length;
                    final newId = await _repo.addExerciseToPreset(
                      widget.presetId,
                      null,
                      'cardio',
                      newIdx,
                    );
                    await _repo.savePresetCardio(
                      newId,
                      name,
                      null,
                      0,
                      0,
                    );
                    _loadPreset();
                    setState(() {});
                  },
                  onStretchPicked: () async {
                    final newIdx = preset.exercises.length;
                    final newId = await _repo.addExerciseToPreset(
                      widget.presetId,
                      null,
                      'stretch',
                      newIdx,
                    );
                    await _repo.savePresetStretch(newId, []);
                    _loadPreset();
                    setState(() {});
                  },
                )
              : null,
        );
      },
    );
  }

  /// Build a concrete WorkoutExercise (Weight/Cardio/Stretch) from a PresetExercise.
       WorkoutExercise _buildExerciseModel(
      FullPreset preset, PresetExercise pe) {
    switch (pe.type) {
      case 'weight':
        final parents     = preset.presetSets[pe.id] ?? <ExerciseSet>[];
        final childrenMap = preset.changeSetsMap[pe.id] ?? <int, List<ExerciseSet>>{};
        return WeightExercise(
          name:       pe.name,
          equipment:  pe.equipment,
          sets:       parents,
          changeSets: childrenMap,
        );

      case 'cardio':
        final c = preset.presetCardioDetails[pe.id]!;
        return CardioExercise(
          name:           pe.name,
          equipment:      pe.equipment,
          cardioName:     c['cardio_name']     as String,
          cardioNote:     c['note']            as String?,
          plannedMinutes: c['planned_minutes'] as int,
          elapsedSeconds: c['elapsed_seconds'] as int,  // <<< use the real saved value
        );

      case 'stretch':
        final rawItems = preset.presetStretchItems[pe.id] ?? <Map<String, dynamic>>[];
        final instances = rawItems.map((m) => StretchInstance(
          id:         m['stretch_id']   as int,
          isCustom:   (m['is_custom']   as int) == 1,
          name:       m['custom_name']  as String,
          description:m['custom_desc']  as String,
        )).toList();
        return StretchExercise(
          name:             pe.name,
          equipment:        pe.equipment,
          stretchInstances: instances,
        );

      default:
        throw Exception('Unknown preset exercise type: ${pe.type}');
    }
  }


  CardType _cardTypeFromString(String type) {
    switch (type) {
      case 'weight':
        return CardType.weight;
      case 'cardio':
        return CardType.cardio;
      case 'stretch':
        return CardType.stretch;
      default:
        throw Exception('Unknown type');
    }
  }
}
