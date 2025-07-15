// File: lib/widgets/past_sessions_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../screens/exercise/full_history_screen.dart';


/// A scrollable, filterable list of past WorkoutSessions.
/// Offers a dropdown for “Week”, “Month”, “Year”, “All” timeframes,
/// and shows itself inside a Card with a fullscreen button.
class PastSessionsList extends StatefulWidget {
  /// Called after returning from a session detail, so parent can reload.
  final VoidCallback? onReload;
  final double height;

  const PastSessionsList({super.key, this.onReload, this.height = 300});

  @override
  State<PastSessionsList> createState() => _PastSessionsListState();
}

class _PastSessionsListState extends State<PastSessionsList> {
  final _repo = AppRepository();

  // The dropdown options and how many days ago each represents.
  static const _options = {
    'Week': 7,
    'Month': 30,
    'Year': 365,
    'All': null,
  };

  // Current selection:
  String _selected = 'Week';

  // The future we’re building off of:
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final days = _options[_selected];
    if (days != null) {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));
      _sessionsFuture = _repo.fetchSessionsInRange(start, now);
    } else {
      // “All” case
      _sessionsFuture = _repo.fetchWorkoutSessions();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
  height: widget.height,
  child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header Row: Dropdown + Fullscreen Icon ──────
            Row(
              children: [
                const Text('Show:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selected,
                  items: _options.keys
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (label) {
                    if (label == null) return;
                    setState(() => _selected = label);
                    _loadSessions();
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Fullscreen',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FullHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),


            // ─── Session List ───────────────────────────
               Expanded(
              child: FutureBuilder<List<WorkoutSession>>(
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
                    return const Center(child: Text('No sessions yet.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final ses = sessions[i];
                      final dateStr =
                          DateFormat('yyyy-MM-dd').format(ses.date);
                      final durationMin = (ses.duration / 60).ceil();
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 4),
                        child: ListTile(
                          title: Text('$dateStr — $durationMin min'),
                          onTap: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SessionDetailScreen(ses),
                                ),
                              )
                              .then((_) {
                                widget.onReload?.call();
                                _loadSessions();
                              }),
                        ),
                      );
                    },
                  );
                },
              ),
               ),
          ],
        ),
      ),
    ),
    );
  }
}
