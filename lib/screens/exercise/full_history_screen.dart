// File: lib/screens/exercise/full_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
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
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repo.fetchWorkoutSessions();
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _repo.fetchWorkoutSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.fullHistoryTitle)),
      body: FutureBuilder<List<WorkoutSession>>(
        future: _sessionsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(strings.fullHistoryLoadError));
          }
          final sessions = snap.data!;
          if (sessions.isEmpty) {
            return Center(child: Text(strings.fullHistoryEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = sessions[i];
              final dateStr = DateFormat.yMMMd(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(s.date);
              final durationMin = (s.duration / 60).ceil();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    strings.fullHistorySessionSummary(dateStr, durationMin),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SessionDetailScreen(s)),
                    );
                    if (mounted) _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
