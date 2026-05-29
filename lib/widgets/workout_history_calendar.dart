import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';

enum _CalendarRangeMode { week, month, twoMonth, year }

class WorkoutHistoryCalendar extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<WorkoutReportSession>? onSessionTap;
  final VoidCallback? onOpenFullHistory;

  const WorkoutHistoryCalendar({
    super.key,
    this.refreshToken = 0,
    this.onSessionTap,
    this.onOpenFullHistory,
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
  _CalendarRangeMode _mode = _CalendarRangeMode.month;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  late DateTime _selectedWeekStart;
  late DateTime _selectedMonth;
  late int _visibleYear;

  @override
  void initState() {
    super.initState();
    final now = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = now;
    _selectedWeekStart = _startOfCalendarWeek(now);
    _selectedMonth = DateTime(now.year, now.month);
    _visibleYear = now.year;
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
        final selectedSessions = _selectedPeriodSessions(sessions);
        final maxSessionsPerDay = _maxSessionsPerDayCache;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarModeTabs(
                  selectedMode: _mode,
                  onChanged: _selectMode,
                ),
                const SizedBox(height: 14),
                _CalendarModeBody(
                  mode: _mode,
                  visibleMonth: _visibleMonth,
                  selectedDay: _selectedDay,
                  selectedWeekStart: _selectedWeekStart,
                  selectedMonth: _selectedMonth,
                  visibleYear: _visibleYear,
                  sessionsByDay: sessionsByDay,
                  maxSessionsPerDay: maxSessionsPerDay,
                  onPreviousMonth:
                      () => _showMonth(
                        DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                      ),
                  onNextMonth:
                      () => _showMonth(
                        DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                      ),
                  onSelectDay: (day) => setState(() => _selectedDay = day),
                  onSelectWeek:
                      (weekStart) =>
                          setState(() => _selectedWeekStart = weekStart),
                  onSelectMonth:
                      (month) => setState(() {
                        _selectedMonth = month;
                        _visibleYear = month.year;
                      }),
                ),
                const SizedBox(height: 14),
                _SelectedPeriodSummary(
                  title: _selectedPeriodTitle(),
                  subtitle: _workoutCountText(selectedSessions.length),
                  sessions: selectedSessions,
                  onSessionTap: widget.onSessionTap,
                  onOpenFullHistory: widget.onOpenFullHistory,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectMode(_CalendarRangeMode mode) {
    if (_mode == mode) return;

    final today = DateUtils.dateOnly(DateTime.now());
    setState(() {
      _mode = mode;
      switch (mode) {
        case _CalendarRangeMode.week:
          _selectedDay = today;
          break;
        case _CalendarRangeMode.month:
          _visibleMonth = DateTime(_selectedDay.year, _selectedDay.month);
          break;
        case _CalendarRangeMode.twoMonth:
          _selectedWeekStart = _startOfMonthWeek(today);
          break;
        case _CalendarRangeMode.year:
          _selectedMonth = DateTime(today.year, today.month);
          _visibleYear = today.year;
          break;
      }
    });
  }

  List<WorkoutReportSession> _selectedPeriodSessions(
    List<WorkoutReportSession> sessions,
  ) {
    switch (_mode) {
      case _CalendarRangeMode.week:
      case _CalendarRangeMode.month:
        return _sessionsByDayCache[_selectedDay] ??
            const <WorkoutReportSession>[];
      case _CalendarRangeMode.twoMonth:
        return _sessionsInRange(
          sessions,
          _selectedWeekStart,
          _monthWeekEndExclusive(_selectedWeekStart),
        );
      case _CalendarRangeMode.year:
        return _sessionsInRange(
          sessions,
          _selectedMonth,
          DateTime(_selectedMonth.year, _selectedMonth.month + 1),
        );
    }
  }

  String _selectedPeriodTitle() {
    switch (_mode) {
      case _CalendarRangeMode.week:
      case _CalendarRangeMode.month:
        return DateFormat('EEE, MMM d').format(_selectedDay);
      case _CalendarRangeMode.twoMonth:
        final end =
            _monthWeekEndExclusive(
              _selectedWeekStart,
            ).subtract(const Duration(days: 1));
        return _formatDateRange(_selectedWeekStart, end);
      case _CalendarRangeMode.year:
        return DateFormat('MMMM yyyy').format(_selectedMonth);
    }
  }

  List<WorkoutReportSession> _sessionsInRange(
    List<WorkoutReportSession> sessions,
    DateTime start,
    DateTime endExclusive,
  ) {
    final startDay = DateUtils.dateOnly(start);
    final endDay = DateUtils.dateOnly(endExclusive);
    final periodSessions =
        sessions.where((session) {
          final day = DateUtils.dateOnly(session.date);
          return !day.isBefore(startDay) && day.isBefore(endDay);
        }).toList();
    periodSessions.sort((a, b) => a.date.compareTo(b.date));
    return periodSessions;
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

DateTime _startOfCalendarWeek(DateTime day) {
  final date = DateUtils.dateOnly(day);
  return date.subtract(Duration(days: date.weekday % DateTime.daysPerWeek));
}

DateTime _startOfMonthWeek(DateTime day) {
  final date = DateUtils.dateOnly(day);
  final rawWeekIndex = (date.day - 1) ~/ 7;
  final weekIndex = rawWeekIndex > 3 ? 3 : rawWeekIndex;
  return DateTime(date.year, date.month, 1 + weekIndex * 7);
}

DateTime _monthWeekEndExclusive(DateTime weekStart) {
  final rawWeekIndex = (weekStart.day - 1) ~/ 7;
  final weekIndex = rawWeekIndex > 3 ? 3 : rawWeekIndex;
  if (weekIndex == 3) {
    return DateTime(weekStart.year, weekStart.month + 1);
  }
  return weekStart.add(const Duration(days: 7));
}

String _workoutCountText(int count) {
  if (count == 0) return 'No workouts logged';
  return '$count workout${count == 1 ? '' : 's'}';
}

String _formatDateRange(DateTime start, DateTime end) {
  final startFormat =
      start.year == end.year ? DateFormat('MMM d') : DateFormat('MMM d, yyyy');
  final endFormat = DateFormat('MMM d, yyyy');
  return '${startFormat.format(start)} - ${endFormat.format(end)}';
}

int _sessionCountInRange(
  Map<DateTime, List<WorkoutReportSession>> sessionsByDay,
  DateTime start,
  DateTime endExclusive,
) {
  var count = 0;
  for (var day = DateUtils.dateOnly(start);
      day.isBefore(endExclusive);
      day = day.add(const Duration(days: 1))) {
    count += sessionsByDay[day]?.length ?? 0;
  }
  return count;
}

class _CalendarModeTabs extends StatelessWidget {
  final _CalendarRangeMode selectedMode;
  final ValueChanged<_CalendarRangeMode> onChanged;

  const _CalendarModeTabs({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _buildButton(context, _CalendarRangeMode.week, 'W'),
          _buildButton(context, _CalendarRangeMode.month, 'M'),
          _buildButton(context, _CalendarRangeMode.twoMonth, '2M'),
          _buildButton(context, _CalendarRangeMode.year, 'Year'),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    _CalendarRangeMode mode,
    String label,
  ) {
    final isSelected = selectedMode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? context.cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  isSelected ? context.cs.onPrimary : context.cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarModeBody extends StatelessWidget {
  final _CalendarRangeMode mode;
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final DateTime selectedWeekStart;
  final DateTime selectedMonth;
  final int visibleYear;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final int maxSessionsPerDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onSelectWeek;
  final ValueChanged<DateTime> onSelectMonth;

  const _CalendarModeBody({
    required this.mode,
    required this.visibleMonth,
    required this.selectedDay,
    required this.selectedWeekStart,
    required this.selectedMonth,
    required this.visibleYear,
    required this.sessionsByDay,
    required this.maxSessionsPerDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
    required this.onSelectWeek,
    required this.onSelectMonth,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case _CalendarRangeMode.week:
        return _WeekCalendarStrip(
          selectedDay: selectedDay,
          sessionsByDay: sessionsByDay,
          maxSessionsPerDay: maxSessionsPerDay,
          onSelectDay: onSelectDay,
        );
      case _CalendarRangeMode.month:
        return Column(
          children: [
            _CalendarHeader(
              visibleMonth: visibleMonth,
              onPrevious: onPreviousMonth,
              onNext: onNextMonth,
            ),
            const SizedBox(height: 14),
            const _WeekdayRow(),
            const SizedBox(height: 8),
            _CalendarGrid(
              visibleMonth: visibleMonth,
              selectedDay: selectedDay,
              sessionsByDay: sessionsByDay,
              maxSessionsPerDay: maxSessionsPerDay,
              onSelectDay: onSelectDay,
            ),
          ],
        );
      case _CalendarRangeMode.twoMonth:
        return _TwoMonthWeekSelector(
          selectedWeekStart: selectedWeekStart,
          sessionsByDay: sessionsByDay,
          onSelectWeek: onSelectWeek,
        );
      case _CalendarRangeMode.year:
        return _YearMonthSelector(
          visibleYear: visibleYear,
          selectedMonth: selectedMonth,
          sessionsByDay: sessionsByDay,
          onSelectMonth: onSelectMonth,
        );
    }
  }
}

class _WeekCalendarStrip extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final int maxSessionsPerDay;
  final ValueChanged<DateTime> onSelectDay;

  const _WeekCalendarStrip({
    required this.selectedDay,
    required this.sessionsByDay,
    required this.maxSessionsPerDay,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );

    return Row(
      children:
          days
              .map(
                (day) => Expanded(
                  child: Center(
                    child: SizedBox.square(
                      dimension: 44,
                      child: _CalendarDayButton(
                        day: day,
                        isCurrentMonth: true,
                        isSelected: DateUtils.isSameDay(day, selectedDay),
                        sessionCount: sessionsByDay[day]?.length ?? 0,
                        maxSessionsPerDay: maxSessionsPerDay,
                        onTap: () => onSelectDay(day),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _TwoMonthWeekSelector extends StatelessWidget {
  final DateTime selectedWeekStart;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final ValueChanged<DateTime> onSelectWeek;

  const _TwoMonthWeekSelector({
    required this.selectedWeekStart,
    required this.sessionsByDay,
    required this.onSelectWeek,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentMonth = DateTime(today.year, today.month);
    final months = [
      DateTime(currentMonth.year, currentMonth.month - 1),
      currentMonth,
    ];
    final maxWeekSessions = months.fold<int>(0, (currentMax, month) {
      final monthMax = List.generate(4, (index) {
        final weekStart = DateTime(month.year, month.month, 1 + index * 7);
        return _sessionCountInRange(
          sessionsByDay,
          weekStart,
          _monthWeekEndExclusive(weekStart),
        );
      }).fold<int>(0, (max, count) => count > max ? count : max);
      return monthMax > currentMax ? monthMax : currentMax;
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < months.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: _MonthWeekPanel(
              month: months[index],
              selectedWeekStart: selectedWeekStart,
              sessionsByDay: sessionsByDay,
              maxWeekSessions: maxWeekSessions,
              onSelectWeek: onSelectWeek,
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthWeekPanel extends StatelessWidget {
  final DateTime month;
  final DateTime selectedWeekStart;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final int maxWeekSessions;
  final ValueChanged<DateTime> onSelectWeek;

  const _MonthWeekPanel({
    required this.month,
    required this.selectedWeekStart,
    required this.sessionsByDay,
    required this.maxWeekSessions,
    required this.onSelectWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat.MMMM().format(month),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final weekStart = DateTime(month.year, month.month, 1 + index * 7);
            final sessionCount = _sessionCountInRange(
              sessionsByDay,
              weekStart,
              _monthWeekEndExclusive(weekStart),
            );
            return _PeriodCircleButton(
              label: 'W${index + 1}',
              semanticLabel:
                  '${DateFormat.MMMM().format(month)} week ${index + 1}',
              isSelected: DateUtils.isSameDay(weekStart, selectedWeekStart),
              sessionCount: sessionCount,
              maxSessionCount: maxWeekSessions,
              onTap: () => onSelectWeek(weekStart),
            );
          },
        ),
      ],
    );
  }
}

class _YearMonthSelector extends StatelessWidget {
  final int visibleYear;
  final DateTime selectedMonth;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final ValueChanged<DateTime> onSelectMonth;

  const _YearMonthSelector({
    required this.visibleYear,
    required this.selectedMonth,
    required this.sessionsByDay,
    required this.onSelectMonth,
  });

  @override
  Widget build(BuildContext context) {
    final months = List.generate(
      12,
      (index) => DateTime(visibleYear, index + 1),
    );
    final maxMonthSessions = months.fold<int>(0, (max, month) {
      final count = _sessionCountInRange(
        sessionsByDay,
        month,
        DateTime(month.year, month.month + 1),
      );
      return count > max ? count : max;
    });

    return Column(
      children: [
        Text(
          visibleYear.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: months.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final month = months[index];
            final sessionCount = _sessionCountInRange(
              sessionsByDay,
              month,
              DateTime(month.year, month.month + 1),
            );
            return _PeriodCircleButton(
              label: DateFormat.MMM().format(month),
              semanticLabel: DateFormat.yMMMM().format(month),
              isSelected:
                  selectedMonth.year == month.year &&
                  selectedMonth.month == month.month,
              sessionCount: sessionCount,
              maxSessionCount: maxMonthSessions,
              onTap: () => onSelectMonth(month),
            );
          },
        ),
      ],
    );
  }
}

class _PeriodCircleButton extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final int sessionCount;
  final int maxSessionCount;
  final VoidCallback onTap;

  const _PeriodCircleButton({
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.sessionCount,
    required this.maxSessionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final hasWorkout = sessionCount > 0;
    final intensity =
        maxSessionCount == 0
            ? 0.0
            : (sessionCount / maxSessionCount).clamp(0.0, 1.0).toDouble();
    final backgroundColor =
        isSelected
            ? cs.primary
            : hasWorkout
            ? cs.primary.withValues(alpha: 0.22 + intensity * 0.48)
            : cs.surfaceContainerHighest;
    final foregroundColor = isSelected ? cs.onPrimary : cs.onSurface;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _SelectedPeriodSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<WorkoutReportSession> sessions;
  final ValueChanged<WorkoutReportSession>? onSessionTap;
  final VoidCallback? onOpenFullHistory;

  const _SelectedPeriodSummary({
    required this.title,
    required this.subtitle,
    required this.sessions,
    required this.onSessionTap,
    required this.onOpenFullHistory,
  });

  @override
  Widget build(BuildContext context) {
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View all sessions',
                icon: const Icon(Icons.fullscreen),
                onPressed: onOpenFullHistory,
              ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${session.durationMinutes} min  -  ${_formatCompact(session.totalVolume)} lbs',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
