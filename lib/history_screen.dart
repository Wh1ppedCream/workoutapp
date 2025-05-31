import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db/database_helper.dart';
import 'models.dart';
import 'session_detail_screen.dart';
import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';

/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = DatabaseHelper()
        .getAllSessionsRaw()
        .then((raw) => raw.map((row) {
              return WorkoutSession(
                id: row['id'] as int,
                date: DateTime.parse(row['date'] as String),
                duration: row['duration'] as int,
              );
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          // Filter navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExerciseCatalogPage()),
                    );
                  },
                  child: const Text('Exercises'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MuscleFilterPage()),
                    );
                  },
                  child: const Text('Muscle'),
                ),
              ],
            ),
          ),
          // Session list
          Expanded(
            child: FutureBuilder<List<WorkoutSession>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                }
                final sessions = snapshot.data!;
                if (sessions.isEmpty) {
                  return const Center(child: Text('No sessions yet.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final ses = sessions[i];
                    final dateStr = DateFormat('yyyy-MM-dd').format(ses.date);
                    final durationMin = (ses.duration / 60).ceil();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('\$dateStr — \$durationMin min'),
                        onTap: () => Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => SessionDetailScreen(ses),
                              ),
                            )
                            .then((_) => setState(() {
                                  _loadSessions();
                                })),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
