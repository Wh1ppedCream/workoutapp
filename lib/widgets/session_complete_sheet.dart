import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';

/// A container for session metadata and its exercises.
class _SessionData {
  final WorkoutSession session;
  final List<WorkoutExercise> exercises;
  _SessionData(this.session, this.exercises);
}

/// A bottom sheet showing session summary & details.
class SessionCompleteSheet extends StatelessWidget {
  final int sessionId;
  const SessionCompleteSheet({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    return FutureBuilder<_SessionData>(
      future: _loadData(repo),
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

  Future<_SessionData> _loadData(AppRepository repo) async {
    // Fetch session metadata
    final session = await repo.fetchSessionById(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }
    // Fetch detailed exercises
    final exRows = await repo.fetchExercises(sessionId);
    final exs = <WorkoutExercise>[];
    for (var r in exRows) {
      final ex = await repo.fetchDetailedExercise(r['id'] as int);
      if (ex != null) exs.add(ex);
    }
    return _SessionData(session, exs);
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
      builder: (ctx, scrollCtrl) => Stack(
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
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr),
                        Text('Duration: $durStr'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Volume: ${totalVol.toStringAsFixed(1)} lbs  •  Calories: $calories kcal'),
                    const SizedBox(height: 4),
                    Text('Gym Score: $gymScore'),
                  ],
                ),
              ),
              const Divider(),
              // BODY
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: exercises.length,
                  itemBuilder: (ctx, i) {
                    final ex = exercises[i];
                    if (ex is WeightExercise) {
                      return _buildWeightSection(ex);
                    } else if (ex is CardioExercise) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text('${ex.cardioName} • ${ex.elapsedSeconds ~/ 60} min'),
                      );
                    } else {
                      return ListTile(
                        leading: const Icon(Icons.self_improvement),
                        title: Text(ex.name),
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
            Text('${i + 1}. ${s.weight.toInt()} lbs × ${s.reps}'),
            const Spacer(),
            Text(
              'ERM=${erm.toStringAsFixed(1)}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
