import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../providers/unit_preference_provider.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../utils/weight_unit_formatter.dart';
import 'body_heatmap.dart';

enum _CalendarRangeMode { month, threeMonth, year, fourYear }

class WorkoutHistoryCalendar extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<WorkoutReportSession>? onSessionTap;
  final VoidCallback? onOpenFullHistory;
  final EdgeInsetsGeometry margin;

  const WorkoutHistoryCalendar({
    super.key,
    this.refreshToken = 0,
    this.onSessionTap,
    this.onOpenFullHistory,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  State<WorkoutHistoryCalendar> createState() => _WorkoutHistoryCalendarState();
}

class _WorkoutHistoryCalendarState extends State<WorkoutHistoryCalendar> {
  AppRepository get _repo => context.read<AppRepository>();

  late Future<List<WorkoutReportSession>> _sessionsFuture;
  List<WorkoutReportSession>? _lastSessions;
  List<WorkoutReportSession>? _groupedSessionsSource;
  Map<DateTime, List<WorkoutReportSession>> _sessionsByDayCache =
      const <DateTime, List<WorkoutReportSession>>{};
  final Map<String, Future<Map<BodyPart, double>>> _heatmapFutures = {};
  int _maxSessionsPerDayCache = 0;
  _CalendarRangeMode _mode = _CalendarRangeMode.month;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  late DateTime _visibleThreeMonthEnd;
  late DateTime _selectedWeekStart;
  late DateTime _selectedMonth;
  late int _visibleYear;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = now;
    _visibleThreeMonthEnd = DateTime(now.year, now.month);
    _selectedWeekStart = _startOfMonthWeek(now);
    _selectedMonth = DateTime(now.year, now.month);
    _visibleYear = now.year;
    _selectedYear = now.year;
    unawaited(BodyHeatmap.preload());
    _sessionsFuture = _repo.fetchWorkoutReportSessions();
  }

  @override
  void didUpdateWidget(covariant WorkoutHistoryCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() {
        _heatmapFutures.clear();
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
          return Card(
            margin: widget.margin,
            child: SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return Card(
            margin: widget.margin,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).logbookCalendarLoadFailed,
              ),
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
        final selectedRange = _selectedPeriodRange();
        final maxSessionsPerDay = _maxSessionsPerDayCache;

        return Card(
          margin: widget.margin,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarModeTabs(selectedMode: _mode, onChanged: _selectMode),
                const SizedBox(height: 14),
                _CalendarModeBody(
                  mode: _mode,
                  visibleMonth: _visibleMonth,
                  visibleThreeMonthEnd: _visibleThreeMonthEnd,
                  selectedDay: _selectedDay,
                  selectedWeekStart: _selectedWeekStart,
                  selectedMonth: _selectedMonth,
                  visibleYear: _visibleYear,
                  selectedYear: _selectedYear,
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
                  onPreviousThreeMonths:
                      () => _showThreeMonthBlock(
                        DateTime(
                          _visibleThreeMonthEnd.year,
                          _visibleThreeMonthEnd.month - 3,
                        ),
                      ),
                  onNextThreeMonths:
                      () => _showThreeMonthBlock(
                        DateTime(
                          _visibleThreeMonthEnd.year,
                          _visibleThreeMonthEnd.month + 3,
                        ),
                      ),
                  onPreviousYear: () => _showYear(_visibleYear - 1),
                  onNextYear: () => _showYear(_visibleYear + 1),
                  onSelectDay: (day) => setState(() => _selectedDay = day),
                  onSelectWeek:
                      (weekStart) =>
                          setState(() => _selectedWeekStart = weekStart),
                  onSelectMonth:
                      (month) => setState(() {
                        _selectedMonth = month;
                        _visibleYear = month.year;
                      }),
                  onSelectYear: (year) => setState(() => _selectedYear = year),
                ),
                const SizedBox(height: 14),
                _SelectedPeriodHeatmapSummary(
                  sessions: selectedSessions,
                  heatmapFuture: _heatmapFutureFor(
                    selectedRange,
                    hasSessions: selectedSessions.isNotEmpty,
                  ),
                ),
                const SizedBox(height: 14),
                _SelectedPeriodSummary(
                  title: _selectedPeriodTitle(),
                  subtitle: _workoutCountText(
                    AppLocalizations.of(context),
                    selectedSessions.length,
                  ),
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

  _DateRange _selectedPeriodRange() {
    switch (_mode) {
      case _CalendarRangeMode.month:
        return _DateRange(
          start: _selectedDay,
          endExclusive: _selectedDay.add(const Duration(days: 1)),
        );
      case _CalendarRangeMode.threeMonth:
        return _DateRange(
          start: _selectedWeekStart,
          endExclusive: _monthWeekEndExclusive(_selectedWeekStart),
        );
      case _CalendarRangeMode.year:
        return _DateRange(
          start: _selectedMonth,
          endExclusive: DateTime(_selectedMonth.year, _selectedMonth.month + 1),
        );
      case _CalendarRangeMode.fourYear:
        return _DateRange(
          start: DateTime(_selectedYear),
          endExclusive: DateTime(_selectedYear + 1),
        );
    }
  }

  Future<Map<BodyPart, double>> _heatmapFutureFor(
    _DateRange range, {
    required bool hasSessions,
  }) {
    if (!hasSessions) {
      return Future<Map<BodyPart, double>>.value(const <BodyPart, double>{});
    }
    return _heatmapFutures.putIfAbsent(
      range.cacheKey,
      () => _repo.fetchAllBodyPartSetsOverTimeRange(
        start: range.start,
        end: range.endInclusive,
      ),
    );
  }

  void _selectMode(_CalendarRangeMode mode) {
    if (_mode == mode) return;

    final today = DateUtils.dateOnly(DateTime.now());
    setState(() {
      _mode = mode;
      switch (mode) {
        case _CalendarRangeMode.month:
          _visibleMonth = DateTime(_selectedDay.year, _selectedDay.month);
          break;
        case _CalendarRangeMode.threeMonth:
          _visibleThreeMonthEnd = DateTime(today.year, today.month);
          _selectedWeekStart = _startOfMonthWeek(today);
          break;
        case _CalendarRangeMode.year:
          _selectedMonth = DateTime(today.year, today.month);
          _visibleYear = today.year;
          break;
        case _CalendarRangeMode.fourYear:
          _selectedYear = today.year;
          break;
      }
    });
  }

  List<WorkoutReportSession> _selectedPeriodSessions(
    List<WorkoutReportSession> sessions,
  ) {
    final range = _selectedPeriodRange();
    return _sessionsInRange(sessions, range.start, range.endExclusive);
  }

  String _selectedPeriodTitle() {
    switch (_mode) {
      case _CalendarRangeMode.month:
        return DateFormat(
          'EEE, MMM d',
          Localizations.localeOf(context).toLanguageTag(),
        ).format(_selectedDay);
      case _CalendarRangeMode.threeMonth:
        final end = _monthWeekEndExclusive(
          _selectedWeekStart,
        ).subtract(const Duration(days: 1));
        return _formatDateRange(
          _selectedWeekStart,
          end,
          Localizations.localeOf(context).toLanguageTag(),
        );
      case _CalendarRangeMode.year:
        return DateFormat.yMMMM(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(_selectedMonth);
      case _CalendarRangeMode.fourYear:
        return _selectedYear.toString();
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

  void _showThreeMonthBlock(DateTime endMonth) {
    final normalizedEnd = DateTime(endMonth.year, endMonth.month);
    final oldStart = DateTime(
      _visibleThreeMonthEnd.year,
      _visibleThreeMonthEnd.month - 2,
    );
    final selectedMonth = DateTime(
      _selectedWeekStart.year,
      _selectedWeekStart.month,
    );
    final selectedMonthOffset =
        ((selectedMonth.year - oldStart.year) * 12 +
                selectedMonth.month -
                oldStart.month)
            .clamp(0, 2)
            .toInt();
    final selectedWeekIndex =
        ((_selectedWeekStart.day - 1) ~/ 7).clamp(0, 3).toInt();
    final newSelectedMonth = DateTime(
      normalizedEnd.year,
      normalizedEnd.month - 2 + selectedMonthOffset,
    );

    setState(() {
      _visibleThreeMonthEnd = normalizedEnd;
      _selectedWeekStart = DateTime(
        newSelectedMonth.year,
        newSelectedMonth.month,
        1 + selectedWeekIndex * 7,
      );
    });
  }

  void _showYear(int year) {
    setState(() {
      _visibleYear = year;
      _selectedMonth = DateTime(year, _selectedMonth.month);
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

class _DateRange {
  final DateTime start;
  final DateTime endExclusive;

  const _DateRange({required this.start, required this.endExclusive});

  DateTime get endInclusive =>
      endExclusive.subtract(const Duration(microseconds: 1));

  String get cacheKey =>
      '${start.toIso8601String()}|${endExclusive.toIso8601String()}';
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

String _workoutCountText(AppLocalizations strings, int count) {
  if (count == 0) return strings.logbookNoWorkouts;
  return strings.logbookWorkoutCount(count);
}

String _formatDateRange(DateTime start, DateTime end, String localeName) {
  final startFormat =
      start.year == end.year
          ? DateFormat.MMMd(localeName)
          : DateFormat.yMMMd(localeName);
  final endFormat = DateFormat.yMMMd(localeName);
  return '${startFormat.format(start)} - ${endFormat.format(end)}';
}

String _formatMonthRangeTitle(
  DateTime startMonth,
  DateTime endMonth,
  String localeName,
) {
  final startFormat =
      startMonth.year == endMonth.year
          ? DateFormat.MMM(localeName)
          : DateFormat.yMMM(localeName);
  return '${startFormat.format(startMonth)} - '
          '${DateFormat.yMMM(localeName).format(endMonth)}'
      .toUpperCase();
}

int _sessionCountInRange(
  Map<DateTime, List<WorkoutReportSession>> sessionsByDay,
  DateTime start,
  DateTime endExclusive,
) {
  var count = 0;
  for (
    var day = DateUtils.dateOnly(start);
    day.isBefore(endExclusive);
    day = day.add(const Duration(days: 1))
  ) {
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
          _buildButton(context, _CalendarRangeMode.month, 'M'),
          _buildButton(context, _CalendarRangeMode.threeMonth, '3M'),
          _buildButton(context, _CalendarRangeMode.year, 'Y'),
          _buildButton(context, _CalendarRangeMode.fourYear, '4Y'),
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
              color: isSelected ? context.cs.onPrimary : context.cs.onSurface,
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
  final DateTime visibleThreeMonthEnd;
  final DateTime selectedDay;
  final DateTime selectedWeekStart;
  final DateTime selectedMonth;
  final int visibleYear;
  final int selectedYear;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final int maxSessionsPerDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousThreeMonths;
  final VoidCallback onNextThreeMonths;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onSelectWeek;
  final ValueChanged<DateTime> onSelectMonth;
  final ValueChanged<int> onSelectYear;

  const _CalendarModeBody({
    required this.mode,
    required this.visibleMonth,
    required this.visibleThreeMonthEnd,
    required this.selectedDay,
    required this.selectedWeekStart,
    required this.selectedMonth,
    required this.visibleYear,
    required this.selectedYear,
    required this.sessionsByDay,
    required this.maxSessionsPerDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousThreeMonths,
    required this.onNextThreeMonths,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.onSelectDay,
    required this.onSelectWeek,
    required this.onSelectMonth,
    required this.onSelectYear,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    switch (mode) {
      case _CalendarRangeMode.month:
        return Column(
          children: [
            _CalendarHeader(
              title:
                  DateFormat.yMMMM(
                    localeName,
                  ).format(visibleMonth).toUpperCase(),
              onPrevious: onPreviousMonth,
              onNext: onNextMonth,
              previousTooltip: strings.logbookPreviousMonth,
              nextTooltip: strings.logbookNextMonth,
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
      case _CalendarRangeMode.threeMonth:
        return _ThreeMonthWeekSelector(
          visibleEndMonth: visibleThreeMonthEnd,
          selectedWeekStart: selectedWeekStart,
          sessionsByDay: sessionsByDay,
          onPrevious: onPreviousThreeMonths,
          onNext: onNextThreeMonths,
          onSelectWeek: onSelectWeek,
        );
      case _CalendarRangeMode.year:
        return _YearMonthSelector(
          visibleYear: visibleYear,
          selectedMonth: selectedMonth,
          sessionsByDay: sessionsByDay,
          onPrevious: onPreviousYear,
          onNext: onNextYear,
          onSelectMonth: onSelectMonth,
        );
      case _CalendarRangeMode.fourYear:
        return _FourYearSelector(
          selectedYear: selectedYear,
          sessionsByDay: sessionsByDay,
          onSelectYear: onSelectYear,
        );
    }
  }
}

class _ThreeMonthWeekSelector extends StatelessWidget {
  final DateTime visibleEndMonth;
  final DateTime selectedWeekStart;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectWeek;

  const _ThreeMonthWeekSelector({
    required this.visibleEndMonth,
    required this.selectedWeekStart,
    required this.sessionsByDay,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectWeek,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      DateTime(visibleEndMonth.year, visibleEndMonth.month - 2),
      DateTime(visibleEndMonth.year, visibleEndMonth.month - 1),
      visibleEndMonth,
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

    return Column(
      children: [
        _CalendarHeader(
          title: _formatMonthRangeTitle(
            months.first,
            visibleEndMonth,
            Localizations.localeOf(context).toLanguageTag(),
          ),
          onPrevious: onPrevious,
          onNext: onNext,
          previousTooltip:
              AppLocalizations.of(context).logbookPreviousThreeMonths,
          nextTooltip: AppLocalizations.of(context).logbookNextThreeMonths,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < months.length; index++) ...[
              if (index > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 1,
                    height: 132,
                    color: context.cs.outlineVariant.withValues(alpha: 0.22),
                  ),
                ),
              ],
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
        ),
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
          DateFormat.MMMM(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(month),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final weekStart = DateTime(month.year, month.month, 1 + index * 7);
            final sessionCount = _sessionCountInRange(
              sessionsByDay,
              weekStart,
              _monthWeekEndExclusive(weekStart),
            );
            return _PeriodCircleButton(
              label: AppLocalizations.of(context).logbookWeekShort(index + 1),
              semanticLabel: AppLocalizations.of(context).logbookMonthWeek(
                DateFormat.MMMM(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(month),
                index + 1,
              ),
              isSelected: DateUtils.isSameDay(weekStart, selectedWeekStart),
              sessionCount: sessionCount,
              maxSessionCount: maxWeekSessions,
              compact: true,
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
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectMonth;

  const _YearMonthSelector({
    required this.visibleYear,
    required this.selectedMonth,
    required this.sessionsByDay,
    required this.onPrevious,
    required this.onNext,
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
        _CalendarHeader(
          title: visibleYear.toString(),
          onPrevious: onPrevious,
          onNext: onNext,
          previousTooltip: AppLocalizations.of(context).logbookPreviousYear,
          nextTooltip: AppLocalizations.of(context).logbookNextYear,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
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
              label: DateFormat.MMM(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(month),
              semanticLabel: DateFormat.yMMMM(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(month),
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

class _FourYearSelector extends StatelessWidget {
  final int selectedYear;
  final Map<DateTime, List<WorkoutReportSession>> sessionsByDay;
  final ValueChanged<int> onSelectYear;

  const _FourYearSelector({
    required this.selectedYear,
    required this.sessionsByDay,
    required this.onSelectYear,
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(4, (index) => currentYear - 3 + index);
    final maxYearSessions = years.fold<int>(0, (max, year) {
      final count = _sessionCountInRange(
        sessionsByDay,
        DateTime(year),
        DateTime(year + 1),
      );
      return count > max ? count : max;
    });

    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: years.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final year = years[index];
        final sessionCount = _sessionCountInRange(
          sessionsByDay,
          DateTime(year),
          DateTime(year + 1),
        );
        return _PeriodCircleButton(
          label: year.toString(),
          semanticLabel: year.toString(),
          isSelected: year == selectedYear,
          sessionCount: sessionCount,
          maxSessionCount: maxYearSessions,
          compact: true,
          onTap: () => onSelectYear(year),
        );
      },
    );
  }
}

class _PeriodCircleButton extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final int sessionCount;
  final int maxSessionCount;
  final bool compact;
  final VoidCallback onTap;

  const _PeriodCircleButton({
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.sessionCount,
    required this.maxSessionCount,
    this.compact = false,
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
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact
                        ? Theme.of(context).textTheme.labelLarge
                        : Theme.of(context).textTheme.titleSmall)
                    ?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            if (sessionCount > 1)
              _WorkoutCountBadge(
                count: sessionCount,
                compact: compact,
                foregroundColor: isSelected ? cs.primary : cs.onPrimary,
                backgroundColor: isSelected ? cs.onPrimary : cs.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String previousTooltip;
  final String nextTooltip;

  const _CalendarHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: previousTooltip,
        ),
        Expanded(
          child: Text(
            title,
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
          tooltip: nextTooltip,
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
      primary: false,
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
    final lastOfMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final startOffset = firstOfMonth.weekday % DateTime.daysPerWeek;
    final firstVisible = firstOfMonth.subtract(Duration(days: startOffset));
    final endOffset =
        DateTime.daysPerWeek - 1 - (lastOfMonth.weekday % DateTime.daysPerWeek);
    final lastVisible = lastOfMonth.add(Duration(days: endOffset));
    final visibleDayCount = lastVisible.difference(firstVisible).inDays + 1;
    return List.generate(
      visibleDayCount,
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
      label: DateFormat.yMMMMd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
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
              child: Text(
                day.day.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (sessionCount > 1)
              _WorkoutCountBadge(
                count: sessionCount,
                foregroundColor: isSelected ? cs.primary : cs.onPrimary,
                backgroundColor: isSelected ? cs.onPrimary : cs.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCountBadge extends StatelessWidget {
  final int count;
  final bool compact;
  final Color foregroundColor;
  final Color backgroundColor;

  const _WorkoutCountBadge({
    required this.count,
    this.compact = false,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 15.0 : 17.0;
    return Positioned(
      top: compact ? -1 : -2,
      right: compact ? -1 : -2,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontSize: compact ? 8 : 9,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SelectedPeriodHeatmapSummary extends StatelessWidget {
  final List<WorkoutReportSession> sessions;
  final Future<Map<BodyPart, double>> heatmapFuture;

  const _SelectedPeriodHeatmapSummary({
    required this.sessions,
    required this.heatmapFuture,
  });

  @override
  Widget build(BuildContext context) {
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    final workoutCount = sessions.length;
    final totalDurationSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
    final totalVolume = sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );

    return FutureBuilder<Map<BodyPart, double>>(
      future: heatmapFuture,
      builder: (context, snapshot) {
        final heatmap = snapshot.data ?? const <BodyPart, double>{};
        final frequencyMap = bodyPartFrequencyMapFromNames({
          for (final entry in heatmap.entries) entry.key.name: entry.value,
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final colors = context.colors;
            final maxWidth = constraints.maxWidth;
            final gap = maxWidth < 330 ? 10.0 : 16.0;
            final heatmapBox = (maxWidth * 0.57).clamp(138.0, 250.0).toDouble();
            final heatmapSize = heatmapBox.clamp(128.0, 200.0).toDouble();
            final summaryHeight = heatmapBox.clamp(210.0, 250.0).toDouble();
            final compactMetrics = summaryHeight < 230 || maxWidth < 360;
            final metricGap = compactMetrics ? 8.0 : 12.0;

            return SizedBox(
              height: summaryHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: heatmapBox,
                    height: heatmapBox,
                    child: Center(
                      child:
                          snapshot.connectionState == ConnectionState.waiting
                              ? SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colors.historySummaryHeatmapHigh!,
                                ),
                              )
                              : BodyHeatmap(
                                frequencyMap: frequencyMap,
                                lowColor: colors.historySummaryHeatmapLow!,
                                highColor: colors.historySummaryHeatmapHigh!,
                                width: heatmapSize,
                                height: heatmapSize,
                              ),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _CalendarMetricCard(
                            value: workoutCount.toString(),
                            label: AppLocalizations.of(context).logbookWorkouts,
                            compact: compactMetrics,
                          ),
                        ),
                        SizedBox(height: metricGap),
                        Expanded(
                          child: _CalendarMetricCard(
                            value: _durationLabel(
                              AppLocalizations.of(context),
                              totalDurationSeconds,
                            ),
                            label:
                                AppLocalizations.of(context).logbookTotalTime,
                            compact: compactMetrics,
                          ),
                        ),
                        SizedBox(height: metricGap),
                        Expanded(
                          child: _CalendarMetricCard(
                            value: WeightUnitFormatter.formatVolume(
                              totalVolume,
                              weightUnit,
                            ),
                            label:
                                AppLocalizations.of(context).logbookTotalVolume,
                            compact: compactMetrics,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CalendarMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const _CalendarMetricCard({
    required this.value,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : 12,
        horizontal: compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: colors.infoCardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.infoCardShadow!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.bold,
                color: colors.infoCardValueText,
              ),
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              color: colors.infoCardLabelText,
            ),
          ),
        ],
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
                tooltip: AppLocalizations.of(context).logbookViewAllSessions,
                icon: const Icon(Icons.fullscreen),
                onPressed: onOpenFullHistory,
              ),
            ],
          ),
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var index = 0; index < sessions.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.cs.outlineVariant.withValues(alpha: 0.22),
                ),
              _SessionRow(
                session: sessions[index],
                onTap:
                    onSessionTap == null
                        ? null
                        : () => onSessionTap?.call(sessions[index]),
              ),
            ],
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
    final weightUnit = context.watch<UnitPreferenceProvider>().weightUnit;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        DateFormat.jm(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(session.date),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        AppLocalizations.of(context).logbookSessionSummary(
          session.durationMinutes,
          session.exerciseCount,
          session.setCount,
          WeightUnitFormatter.formatVolume(session.totalVolume, weightUnit),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}

String _durationLabel(AppLocalizations strings, int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final mins = (totalSeconds % 3600) ~/ 60;
  return strings.durationHoursMinutes(hours, mins);
}
