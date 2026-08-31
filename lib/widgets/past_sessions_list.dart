// File: lib/widgets/past_sessions_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../repositories/app_repository.dart';
import '../screens/exercise/full_history_screen.dart';
import '../screens/exercise/session_detail_screen.dart';
import '../theme/theme_extensions.dart';
import '../utils/completed_workout_duration_formatter.dart';
import '../services/safe_failure.dart';
import 'safe_error_view.dart';

/// A scrollable, filterable list of past workout sessions.
class PastSessionsList extends StatefulWidget {
  /// Called after returning from a session detail, so parent can reload.
  final VoidCallback? onReload;
  final double height;
  final int refreshToken;

  const PastSessionsList({
    super.key,
    this.onReload,
    this.height = 300,
    this.refreshToken = 0,
  });

  @override
  State<PastSessionsList> createState() => _PastSessionsListState();
}

class _PastSessionsListState extends State<PastSessionsList>
    with AutomaticKeepAliveClientMixin<PastSessionsList> {
  AppRepository get _repo => context.read<AppRepository>();

  static const _options = {'week': 7, 'month': 30, 'year': 365, 'all': null};

  String _selected = 'week';
  late Future<List<WorkoutSession>> _sessionsFuture;
  List<WorkoutSession>? _lastSessions;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _sessionsForSelectedRange();
  }

  @override
  void didUpdateWidget(covariant PastSessionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reloadSessions();
    }
  }

  Future<List<WorkoutSession>> _sessionsForSelectedRange() {
    final days = _options[_selected];
    if (days == null) {
      return _repo.fetchWorkoutSessions();
    }

    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    return _repo.fetchSessionsInRange(start, now);
  }

  void _reloadSessions() {
    setState(() {
      _sessionsFuture = _sessionsForSelectedRange();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final cs = context.cs;
    final strings = AppLocalizations.of(context);
    final optionLabels = <String, String>{
      'week': strings.pastSessionsWeek,
      'month': strings.pastSessionsMonth,
      'year': strings.pastSessionsYear,
      'all': strings.pastSessionsAll,
    };

    return SizedBox(
      height: widget.height,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    strings.pastSessionsShow,
                    style: TextStyle(color: cs.onSurface),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selected,
                    items:
                        _options.keys
                            .map(
                              (label) => DropdownMenuItem(
                                value: label,
                                child: Text(optionLabels[label]!),
                              ),
                            )
                            .toList(),
                    onChanged: (label) {
                      if (label == null) return;
                      setState(() {
                        _selected = label;
                        _sessionsFuture = _sessionsForSelectedRange();
                      });
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.fullscreen,
                      color: colors.pastSessionsIcon!,
                    ),
                    tooltip: strings.pastSessionsFullscreen,
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
              Expanded(
                child: FutureBuilder<List<WorkoutSession>>(
                  future: _sessionsFuture,
                  initialData: _lastSessions,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: colors.pastSessionsProgress!,
                        ),
                      );
                    }
                    if (snap.hasError && !snap.hasData) {
                      return SafeErrorView(
                        title: strings.safeFailureLoadTitle,
                        failure: SafeFailure.classify(snap.error!),
                        onRetry: _reloadSessions,
                        compact: true,
                      );
                    }

                    final sessions = snap.data ?? const <WorkoutSession>[];
                    if (snap.connectionState == ConnectionState.done &&
                        snap.hasData) {
                      _lastSessions = sessions;
                    }
                    if (sessions.isEmpty) {
                      return Center(child: Text(strings.pastSessionsEmpty));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      itemCount: sessions.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: colors.pastSessionsDivider!,
                          ),
                      itemBuilder: (ctx, i) {
                        final ses = sessions[i];
                        final dateStr = DateFormat.yMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(ses.calendarDay.toLocalDateTime());
                        final duration = formatCompletedWorkoutDuration(
                          strings,
                          ses.duration,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(
                              strings.pastSessionsItem(dateStr, duration),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap:
                                () => Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => SessionDetailScreen(ses),
                                      ),
                                    )
                                    .then((_) {
                                      if (!mounted) return;
                                      widget.onReload?.call();
                                      _reloadSessions();
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
