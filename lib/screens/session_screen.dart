// File: lib/widgets/session_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/exercise_card.dart';
import 'exercise_catalog_page.dart'; // For Catalog flow
import '../repositories/app_repository.dart';

const List<String> _bodyweightCardioOptions = [
  'Aerobics',
  'Box Jumps',
  'Jump Squats',
  'Running',
  'Swimming',
  'Walking',
  'Zumba',
];

const List<String> _equipmentCardioOptions = [
  'Battle Ropes',
  'Bicycle',
  'Elliptical',
  'Rowing Machine',
  'Ski Machine',
  'Skipping Rope',
  'Stair Climber',
  'Stationary Bike',
  'Treadmill',
  'Vertical Climber',
];

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _repo = AppRepository();

  /// We keep a list of the abstract base type, but each entry will actually
  /// be a WeightExercise, CardioExercise, or StretchExercise.
  final List<WorkoutExercise> _exercises = [];

  /// We also keep a parallel list of CardType so the UI knows how to render each card.
  final List<CardType> _cardTypes = [];

  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
    _warmUpDatabase();
  }

  Future<void> _warmUpDatabase() async {
    await _repo.fetchAllEquipmentNames();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _finishWorkout() async {
    _timer.cancel();

    // 1) Create session
    final nowStr   = DateTime.now().toIso8601String();
    final sessionId = await _repo.createSession(nowStr, _elapsedSeconds);

    // 2) Loop over each exercise and save
    for (var i = 0; i < _exercises.length; i++) {
      final we       = _exercises[i];
      final cardType = _cardTypes[i];

      if (cardType == CardType.weight && we is WeightExercise) {
        // ─── Weight: ensure we have a definition ID first ───────────────────
        final defId = await _repo.findOrCreateExerciseDefinition(
          we.name, we.equipment,
        );

        // 2b) Insert exercise row
        final exId = await _repo.addExerciseRow(
          sessionId:     sessionId,
          exerciseDefId: defId,
          type:          'weight',
          orderIndex:    i,
        );

        // 2c) Insert sets + ChangeSets
        await _repo.addWeightSets(
          exerciseId:      exId,
          parentSets:      we.sets,
          childChangeSets: we.changeSets,
        );
      } else if (cardType == CardType.cardio && we is CardioExercise) {
        // ─── Cardio ─────────────────────────────────────────────────────────
        final exId = await _repo.addExerciseRow(
          sessionId:     sessionId,
          exerciseDefId: null,
          type:          'cardio',
          orderIndex:    i,
        );
        await _repo.saveCardioDetails(
          exerciseId:     exId,
          cardioName:     we.cardioName,
          note:           we.cardioNote,
          plannedMinutes: we.plannedMinutes,
          elapsedSeconds: we.elapsedSeconds,
        );
      } else if (cardType == CardType.stretch && we is StretchExercise) {
        final exId = await _repo.addExerciseRow(
          sessionId:     sessionId,
          exerciseDefId: null,
          type:          'stretch',
          orderIndex:    i,
        );
        await _repo.saveStretchInstance(
          exerciseId: exId,
          items:      we.stretchInstances,
        ); 
      } else {
        throw Exception('Mismatched cardType vs. actual subclass');
      }
    }

    // 4) All done—pop back to History
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Workout Timer', style: TextStyle(fontSize: 20)),
              ),
              Text(_formattedTime, style: const TextStyle(fontSize: 48)),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('New Workout'),
        centerTitle: true,
      ),

      // If no exercises have been added yet, show a placeholder
      body: _exercises.isEmpty
          ? const Center(child: Text('No exercises added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (ctx, i) => ExerciseCard(
                exercise: _exercises[i],
                cardType: _cardTypes[i],
                onDeleteExercise: () {
                  setState(() {
                    _exercises.removeAt(i);
                    _cardTypes.removeAt(i);
                  });
                },
                onSetAdded: () => setState(() {}),
                onSetDeleted: () => setState(() {}),
                onValueChanged: () => setState(() {}),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardTypeDialog(context),
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _finishWorkout,
            child: const Text('Finish Workout'),
          ),
        ),
      ),
    );
  }

  /// Pops up a dialog that lets the user choose “Exercise”, “Cardio”, or “Stretch”
  /// and then creates the appropriate subclass instance.
  void _showAddCardTypeDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add a Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1) Weight/“Exercise” card
            ListTile(
              title: const Text('Exercise'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseCatalogPage(
                      onExercisePicked: (def) {
                        setState(() {
                          _exercises.add(
                            WeightExercise(
                              name: def.name,
                              equipment: def.equipmentList.isNotEmpty
                                  ? def.equipmentList.first.name
                                  : '',
                              sets: [ExerciseSet()],
                              changeSets: {}, // start empty
                            ),
                          );
                          _cardTypes.add(CardType.weight);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            // 2) Cardio card
            ListTile(
              title: const Text('Cardio'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showCardioDetailDialog();
              },
            ),

            // 3) Stretch card
            ListTile(
              title: const Text('Stretch'),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _exercises.add(
                    StretchExercise(
                      name: 'Stretch',
                      equipment: '',
                      stretchInstances: [],
                    ),
                  );
                  _cardTypes.add(CardType.stretch);
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  /// If user chooses “Cardio”, we pop up another dialog so they can pick a type
  /// (Bodyweight vs. Equipment‐based) and then pick an exercise name from a dropdown.
  void _showCardioDetailDialog() {
    String? selectedCategory; // either 'Bodyweight' or 'Equipment Based'
    String? selectedExercise;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final options = (selectedCategory == 'Bodyweight')
              ? _bodyweightCardioOptions
              : (selectedCategory == 'Equipment Based')
                  ? _equipmentCardioOptions
                  : <String>[];

          return AlertDialog(
            title: const Text('Choose Cardio Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Radio buttons: Bodyweight vs. Equipment
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Bodyweight'),
                        value: 'Bodyweight',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Equipment Based'),
                        value: 'Equipment Based',
                        groupValue: selectedCategory,
                        onChanged: (v) {
                          setDialogState(() {
                            selectedCategory = v;
                            selectedExercise = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Once a category is chosen, show a dropdown of that category’s options
                if (selectedCategory != null) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Exercise'),
                    value: selectedExercise,
                    items: options
                        .map((ex) => DropdownMenuItem(value: ex, child: Text(ex)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedExercise = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedExercise == null)
                    ? null
                    : () {
                        Navigator.of(dialogCtx).pop();
                        setState(() {
                          _exercises.add(
                            CardioExercise(
                              name: selectedExercise!,
                              equipment: '',
                              cardioName: selectedExercise!,
                              cardioNote: null,
                              plannedMinutes: 0,
                              elapsedSeconds: 0,
                            ),
                          );
                          _cardTypes.add(CardType.cardio);
                        });
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
