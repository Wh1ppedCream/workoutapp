import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('dashboard consumers use named structural recipes', () {
    final dashboard = _read('lib/screens/dashboard_page.dart');
    final sections = _read('lib/widgets/dashboard_sections.dart');

    expect(dashboard, contains('PageStorageKey(\'dashboard_scroll\')'));
    expect(dashboard, contains('DashboardConfig'));
    expect(dashboard, contains('surfaces.dashboardEditor'));
    expect(dashboard, contains('shapes.dashboardEditor'));
    expect(dashboard, contains('surfaces.dashboardSection'));
    expect(dashboard, contains('shapes.dashboardSection'));
    expect(dashboard, contains('shapes.dashboardFooter'));
    expect(dashboard, isNot(contains('surfaceContainerHighest')));

    expect(sections, contains('surfaces.dashboardHero'));
    expect(sections, contains('shapes.dashboardHero'));
    expect(sections, contains('surfaces.dashboardSection'));
    expect(sections, contains('shapes.dashboardSection'));
    expect(sections, contains('shapes.dashboardAction'));
    expect(sections, contains('shapes.dashboardUsage'));
    expect(sections, contains('shapes.dashboardRow'));
    expect(sections, isNot(contains('surfaceContainerHighest')));
  });

  test(
    'history consumers use named recipes without moving state ownership',
    () {
      final summary = _read('lib/widgets/history_summary_widget.dart');
      final calendar = _read('lib/widgets/workout_history_calendar.dart');
      final content = _read('lib/widgets/history_content.dart');
      final historyScreen = _read('lib/screens/exercise/history_screen.dart');
      final pastSessions = _read('lib/widgets/past_sessions_list.dart');
      final fullHistory = _read(
        'lib/screens/exercise/full_history_screen.dart',
      );

      expect(summary, contains('surfaces.historyPeriodSelector'));
      expect(summary, contains('shapes.compact'));
      expect(summary, contains('_selectedIndex'));
      expect(summary, contains('_ensureTabLoaded'));
      expect(summary, isNot(contains('surfaceContainerHighest')));

      for (final role in [
        'surfaces.calendarModeSelector',
        'surfaces.calendarDayEmpty',
        'surfaces.historySelectedPeriod',
        'surfaces.historyDivider',
        'shapes.historySelectedPeriod',
        'shapes.pill',
      ]) {
        expect(calendar, contains(role), reason: role);
      }
      for (final stateField in [
        '_selectedDay',
        '_selectedWeekStart',
        '_selectedMonth',
        '_selectedYear',
        '_visibleMonth',
        'onSessionTap',
        'onOpenFullHistory',
      ]) {
        expect(calendar, contains(stateField), reason: stateField);
      }
      expect(calendar, isNot(contains('surfaceContainerHighest')));

      expect(content, contains('WorkoutHistoryCalendar'));
      expect(content, contains('refreshToken'));
      expect(content, contains('onSessionTap'));
      expect(content, contains('onOpenFullHistory'));

      expect(historyScreen, contains('logbook_calendar_tutorial'));
      expect(historyScreen, contains('HistoryContent'));
      expect(historyScreen, contains('_refreshToken'));

      expect(pastSessions, contains('AutomaticKeepAliveClientMixin'));
      expect(pastSessions, contains("String _selected = 'week'"));
      expect(pastSessions, contains('_sessionsForSelectedRange'));
      expect(pastSessions, contains('FullHistoryScreen'));
      expect(pastSessions, contains('SessionDetailScreen'));

      expect(fullHistory, contains('ListView.separated'));
      expect(fullHistory, contains('SessionDetailScreen'));
      expect(fullHistory, contains('_reload'));
    },
  );
}
