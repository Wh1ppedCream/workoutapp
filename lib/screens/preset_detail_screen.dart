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
    final repo = AppRepository();
    _presetFuture = repo.fetchFullPreset(widget.presetId);
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: _isEditing
            ? TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Preset Name',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : FutureBuilder<FullPreset?>(
                future: _presetFuture,
                builder: (_, snap) {
                  final name = snap.hasData && snap.data != null
                      ? snap.data!.definition.name
                      : '';
                  return Text(name);
                },
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: _isEditing ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<FullPreset?>(
        future: _presetFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final preset = snapshot.data;
          if (preset == null) {
            return const Center(child: Text('Preset not found'));
          }
          final exercises = preset.exercises;

          return Column(
            children: [
              Expanded(
                child: _isEditing
                    ? ReorderableListView(
                        padding: const EdgeInsets.all(16),
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex--;
                          setState(() {
                            final item = exercises.removeAt(oldIndex);
                            exercises.insert(newIndex, item);
                          });
                          await AppRepository().reorderPresetExercises(
                            widget.presetId,
                            exercises.map((e) => e.id).toList(),
                          );
                          setState(() => _loadPreset());
                        },
                        children: [
                          for (var i = 0; i < exercises.length; i++)
                            ExerciseCard(
                              key: ValueKey(exercises[i].id),
                              exercise: _buildExerciseModel(preset, exercises[i]),
                              cardType: _cardTypeFromString(exercises[i].type),
                              readOnlyMode: !_isEditing,
                              initialCompletedParents: null,
                              initialCompletedChildren: null,
                              onDeleteExercise: _isEditing
                                  ? () async {
                                      await AppRepository()
                                          .deletePresetExercise(
                                              exercises[i].id);
                                      setState(() => _loadPreset());
                                    }
                                  : null,
                              onSetAdded: _isEditing
                                  ? () => setState(() => _loadPreset())
                                  : null,
                              onSetDeleted: _isEditing
                                  ? () => setState(() => _loadPreset())
                                  : null,
                              onValueChanged: _isEditing
                                  ? () => setState(() => _loadPreset())
                                  : null,
                            ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: exercises.length,
                        itemBuilder: (ctx, i) {
                          final ex = exercises[i];
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
                          final repo = AppRepository();
                          await repo.updatePresetName(
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
                          final nav = Navigator.of(context);
                          final sessionId = await
                              AppRepository().startSessionFromPreset(
                                  widget.presetId);
                          if (!mounted) return;
                          nav.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => SessionScreen(),
                              settings: RouteSettings(
                                arguments: sessionId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start Session'),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          _isEditing ? const AddExerciseFab() : const SizedBox.shrink(),
    );
  }

  /// Build a concrete WorkoutExercise (Weight/Cardio/Stretch) from a PresetExercise.
  WorkoutExercise _buildExerciseModel(
      FullPreset preset, PresetExercise pe) {
    switch (pe.type) {
      case 'weight':
        final sets = preset.presetSets[pe.id] ?? [];
        return WeightExercise(
          name: '',
          equipment: '',
          sets: sets,
        );
      case 'cardio':
        final c = preset.presetCardioDetails[pe.id];
        return CardioExercise(
          name: c?['cardio_name'] as String? ?? '',
          equipment: '',
          cardioName: c?['cardio_name'] as String? ?? '',
          cardioNote: c?['note'] as String?,
          plannedMinutes: c?['planned_minutes'] as int? ?? 0,
          elapsedSeconds: 0,
        );
      case 'stretch':
        final items = preset.presetStretchItems[pe.id] ?? [];
        return StretchExercise(
          name: '',
          equipment: '',
          stretchInstances: items,
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
