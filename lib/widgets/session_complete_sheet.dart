// File: lib/widgets/session_complete_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../utils/async_pool.dart';

/// A container for session metadata and its exercises.
class _SessionData {
  final WorkoutSession session;
  final List<WorkoutExercise> exercises;
  _SessionData(this.session, this.exercises);
}

/// A bottom sheet showing session summary & details.
class SessionCompleteSheet extends StatefulWidget {
  final int sessionId;
  const SessionCompleteSheet({super.key, required this.sessionId});

  @override
  State<SessionCompleteSheet> createState() => _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends State<SessionCompleteSheet> {
  static const int _exerciseHydrationConcurrency = 6;

  late final AppRepository _repo;
  late final Future<_SessionData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _repo = AppRepository();
    _dataFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionData>(
      future: _dataFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('Error loading session')),
          );
        }
        final data = snap.data!;
        return _buildContent(context, data);
      },
    );
  }

  Future<_SessionData> _loadData() async {
    // Fetch session metadata
    final session = await _repo.fetchSessionById(widget.sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }
    // Fetch detailed exercises
    final exRows = await _repo.fetchExercises(widget.sessionId);
    final loadedExercises = await _loadDetailedExercises(exRows);
    final exs = loadedExercises.whereType<WorkoutExercise>().toList();
    return _SessionData(session, exs);
  }

  Future<List<WorkoutExercise?>> _loadDetailedExercises(
    List<Map<String, dynamic>> exerciseRows,
  ) {
    return mapWithConcurrency<Map<String, dynamic>, WorkoutExercise?>(
      exerciseRows,
      maxConcurrency: _exerciseHydrationConcurrency,
      mapper: (row, _) => _repo.fetchDetailedExercise(row['id'] as int),
    );
  }

  Widget _buildContent(BuildContext context, _SessionData data) {
    final session = data.session;
    final exercises = data.exercises;

    // Compute total volume:
    double totalVol = 0;
    for (var ex in exercises.whereType<WeightExercise>()) {
      for (var set in ex.sets) {
        totalVol += set.weight * set.reps;
      }
    }

    // Format date & duration
    final dateStr = DateFormat('MMM dd • HH:mm').format(session.date);
    final dur = Duration(seconds: session.duration);
    final hours = dur.inHours.toString().padLeft(2, '0');
    final mins = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    final durStr = '$hours:$mins:$secs';

    // Static placeholders:
    const calories = 100;
    const gymScore = '5/10';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (ctx, scrollCtrl) => Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SESSION COMPLETE!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dateStr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Duration: $durStr',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Volume: ${totalVol.toStringAsFixed(1)} lbs  •  Calories: $calories kcal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gym Score: $gymScore',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // BODY
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: exercises.length,
                      itemBuilder: (ctx, i) {
                        final ex = exercises[i];
                        if (ex is WeightExercise) {
                          return _buildWeightSection(ex);
                        } else if (ex is CardioExercise) {
                          return ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(
                              '${ex.cardioName} • ${ex.elapsedSeconds ~/ 60} min',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        } else {
                          return ListTile(
                            leading: const Icon(Icons.self_improvement),
                            title: Text(
                              ex.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              // DONE BUTTON
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.check),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildWeightSection(WeightExercise ex) {
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          '■ ${ex.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];
    for (var i = 0; i < ex.sets.length; i++) {
      final s = ex.sets[i];
      final erm = s.weight * (1 + 0.0333 * s.reps);
      rows.add(
        Row(
          children: [
            Expanded(
              child: Text(
                '${i + 1}. ${s.weight.toInt()} lbs × ${s.reps}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'ERM=${erm.toStringAsFixed(1)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
