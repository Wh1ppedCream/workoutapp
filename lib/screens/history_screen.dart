// file: lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';
import 'session_detail_screen.dart';
import 'exercise_catalog_page.dart';
import 'muscle_filter_page.dart';
import '../widgets/history_summary_widget.dart';
import 'analytics_dashboard_screen.dart';


/// Displays the list of past workout sessions and navigation to filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = AppRepository();
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = _repo.fetchWorkoutSessions();
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
          
          // ─── 7-day Summary ────────────────────────────────
          // ⬇️ History summary panel
          FutureBuilder<List<WorkoutSession>>(
            future: _repo.fetchSessionsInRange(
              DateTime.now().subtract(const Duration(days: 7)),
              DateTime.now(),
            ),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Error loading summary')),
                );
              }
              final recent = snap.data ?? [];
              return HistorySummaryWidget(recentSessions: recent);
            },
          ),

          // ─── Analytics Dashboard button ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('View 7-Day Analytics'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AnalyticsDashboardScreen()),
                );
              },
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
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                        title: Text('$dateStr — $durationMin min'),
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
