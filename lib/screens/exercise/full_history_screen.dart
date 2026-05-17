// File: lib/screens/exercise/full_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import 'session_detail_screen.dart';

/// Shows every workout session in a simple scrollable list.
class FullHistoryScreen extends StatefulWidget {
  const FullHistoryScreen({super.key});

  @override
  State<FullHistoryScreen> createState() => _FullHistoryScreenState();
}

class _FullHistoryScreenState extends State<FullHistoryScreen> {
  final _repo = AppRepository();
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repo.fetchWorkoutSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Sessions')),
      body: FutureBuilder<List<WorkoutSession>>(
        future: _sessionsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final sessions = snap.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions saved.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = sessions[i];
              final dateStr = DateFormat('yyyy-MM-dd').format(s.date);
              final durationMin = (s.duration / 60).ceil();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '$dateStr — $durationMin min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap:
                      () => Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => SessionDetailScreen(s),
                            ),
                          )
                          .then((_) {
                            // nothing extra here
                          }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
