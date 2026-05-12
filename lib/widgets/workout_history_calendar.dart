import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';

class WorkoutHistoryCalendar extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<WorkoutReportSession>? onSessionTap;

  const WorkoutHistoryCalendar({
    super.key,
    this.refreshToken = 0,
    this.onSessionTap,
  });

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  final _repo = AppRepository();

  late Future<List<WorkoutReportSession>> _sessionsFuture;
  List<WorkoutReportSession>? _lastSessions;
  List<WorkoutReportSession>? _groupedSessionsSource;
  Map<DateTime, List<WorkoutReportSession>> _sessionsByDayCache =
      const <DateTime, List<WorkoutReportSession>>{};
  int _maxSessionsPerDayCache = 0;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateUtils.dateOnly(now);
    _sessionsFuture = _repo.fetchWorkoutReportSessions();
  }

  @override
  void didUpdateWidget(covariant WorkoutHistoryCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() {
        _sessionsFuture = _repo.fetchWorkoutReportSessions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkoutReportSession>>(
      future: _sessionsFuture,
      initialData: _lastSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Unable to load workout calendar.'),
            ),
          );
        }

        final sessions = snapshot.data ?? const <WorkoutReportSession>[];
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _lastSessions = sessions;
        }

        _refreshGroupedSessions(sessions);
        final sessionsByDay = _sessionsByDayCache;
        final selectedSessions =
            sessionsByDay[_selectedDay] ?? const <WorkoutReportSession>[];
        final maxSessionsPerDay = _maxSessionsPerDayCache;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarHeader(
                  visibleMonth: _visibleMonth,
                  onPrevious:
                      () => _showMonth(
                        DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                      ),
                  onNext:
                      () => _showMonth(
                        DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                      ),
                ),
                const SizedBox(height: 14),
                const _WeekdayRow(),
                const SizedBox(height: 8),
                _CalendarGrid(
                  visibleMonth: _visibleMonth,
                  selectedDay: _selectedDay,
                  sessionsByDay: sessionsByDay,
                  maxSessionsPerDay: maxSessionsPerDay,
                  onSelectDay: (day) => setState(() => _selectedDay = day),
                ),
                const SizedBox(height: 14),
                _SelectedDaySummary(
                  day: _selectedDay,
                  sessions: selectedSessions,
                  onSessionTap: widget.onSessionTap,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMonth(DateTime month) {
    final normalizedMonth = DateTime(month.year, month.month);
    setState(() {
      _visibleMonth = normalizedMonth;
      if (_selectedDay.year != normalizedMonth.year ||
          _selectedDay.month != normalizedMonth.month) {
        final today = DateUtils.dateOnly(DateTime.now());
        _selectedDay =
            today.year == normalizedMonth.year &&
                    today.month == normalizedMonth.month
                ? today
                : normalizedMonth;
      }
    });
  }

  Map<DateTime, List<WorkoutReportSession>> _groupSessionsByDay(
    List<WorkoutReportSession> sessions,
  ) {
    final grouped = <DateTime, List<WorkoutReportSession>>{};
    for (final session in sessions) {
      final day = DateUtils.dateOnly(session.date);
      grouped.putIfAbsent(day, () => <WorkoutReportSession>[]).add(session);
    }
    for (final daySessions in grouped.values) {
      daySessions.sort((a, b) => a.date.compareTo(b.date));
    }
    return grouped;
  }

  void _refreshGroupedSessions(List<WorkoutReportSession> sessions) {
    if (identical(_groupedSessionsSource, sessions)) return;

    final grouped = _groupSessionsByDay(sessions);
    _groupedSessionsSource = sessions;
    _sessionsByDayCache = grouped;
    _maxSessionsPerDayCache = grouped.values.fold<int>(
      0,
      (max, daySessions) => daySessions.length > max ? daySessions.length : max,
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.visibleMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthText = DateFormat('MMMM yyyy').format(visibleMonth);
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
        ),
        Expanded(
          child: Text(
            monthText.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          _labels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.cs.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final int maxSessionsPerDay;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDay,
    required this.sessionsByDay,
    required this.maxSessionsPerDay,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final days = _visibleDays();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final sessions = sessionsByDay[day] ?? const <WorkoutReportSession>[];
        return _CalendarDayButton(
          day: day,
          isCurrentMonth: day.month == visibleMonth.month,
          isSelected: DateUtils.isSameDay(day, selectedDay),
          sessionCount: sessions.length,
          maxSessionsPerDay: maxSessionsPerDay,
          onTap: () => onSelectDay(day),
        );
      },
    );
  }

  List<DateTime> _visibleDays() {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final startOffset = firstOfMonth.weekday % DateTime.daysPerWeek;
    final firstVisible = firstOfMonth.subtract(Duration(days: startOffset));
    return List.generate(
      42,
      (index) => DateUtils.dateOnly(firstVisible.add(Duration(days: index))),
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isSelected;
  final int sessionCount;
  final int maxSessionsPerDay;
  final VoidCallback onTap;

  const _CalendarDayButton({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.sessionCount,
    required this.maxSessionsPerDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final hasWorkout = sessionCount > 0;
    final intensity =
        maxSessionsPerDay == 0
            ? 0.0
            : (sessionCount / maxSessionsPerDay).clamp(0.0, 1.0).toDouble();
    final baseColor =
        hasWorkout
            ? cs.primary.withValues(alpha: 0.22 + intensity * 0.48)
            : cs.surfaceContainerHighest;
    final backgroundColor = isSelected ? cs.primary : baseColor;
    final foregroundColor =
        isSelected
            ? cs.onPrimary
            : isCurrentMonth
            ? cs.onSurface
            : cs.onSurfaceVariant.withValues(alpha: 0.45);

    return Semantics(
      button: true,
      label: DateFormat.yMMMMd().format(day),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border:
                DateUtils.isSameDay(day, DateTime.now()) && !isSelected
                    ? Border.all(color: cs.primary, width: 1.4)
                    : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                day.day.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (sessionCount > 1)
                Positioned(
                  right: 7,
                  bottom: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? cs.onPrimary : cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      sessionCount.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? cs.primary : cs.onPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDaySummary extends StatelessWidget {
  final DateTime day;
  final List<WorkoutReportSession> sessions;
  final ValueChanged<WorkoutReportSession>? onSessionTap;

  const _SelectedDaySummary({
    required this.day,
    required this.sessions,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final totalVolume = sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEE, MMM d').format(day),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sessions.isEmpty
                          ? 'No workouts logged'
                          : '${sessions.length} workout${sessions.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniSummary(label: 'Min', value: totalMinutes.toString()),
              const SizedBox(width: 12),
              _MiniSummary(label: 'Volume', value: _formatCompact(totalVolume)),
            ],
          ),
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sessions.map(
              (session) => _SessionRow(
                session: session,
                onTap:
                    onSessionTap == null
                        ? null
                        : () => onSessionTap?.call(session),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final String value;

  const _MiniSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: context.cs.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final WorkoutReportSession session;
  final VoidCallback? onTap;

  const _SessionRow({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        DateFormat.jm().format(session.date),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${session.durationMinutes} min  -  ${_formatCompact(session.totalVolume)} lbs',
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}

String _formatCompact(double value) {
  final abs = value.abs();
  if (abs >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (abs >= 1000) {
    final digits = abs >= 10000 ? 0 : 1;
    return '${(value / 1000).toStringAsFixed(digits)}k';
  }
  return value.round().toString();
}
