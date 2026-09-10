import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test(
    'progress consumers use structural and data-visualization ownership',
    () {
      final progress = _read('lib/widgets/exercise_progress_section.dart');
      final records = _read('lib/widgets/data_records_section.dart');
      final metric = _read('lib/widgets/workout_metric_chart_card.dart');
      final dashboard = _read('lib/widgets/workout_dashboard.dart');

      for (final role in [
        'surfaces.exerciseProgressHero',
        'surfaces.exerciseProgressStat',
        'surfaces.exerciseProgressSelector',
        'surfaces.exerciseProgressTooltip',
        'shapes.exerciseProgressHero',
        'shapes.exerciseProgressStat',
        'shapes.exerciseProgressSelector',
        'shapes.exerciseProgressAddTile',
        'shapes.exerciseProgressTooltip',
        'progressColors.accent',
        'progressColors.estimated',
        'progressColors.grid',
        'progressColors.label',
      ]) {
        expect(progress, contains(role), reason: role);
      }
      for (final state in [
        'refreshToken',
        '_selectedDefinitionId',
        '_visibleDefinitionIds',
        'interactive',
        'selectedIndex',
      ]) {
        expect(progress, contains(state), reason: state);
      }
      expect(progress, isNot(contains('surfaceContainerHighest')));
      for (final role in ['Hero', 'Stat', 'Selector', 'AddTile']) {
        expect(
          progress,
          contains('shapes.exerciseProgress$role * layout.scale'),
          reason: 'Responsive geometry must still scale $role',
        );
      }

      for (final role in [
        'dataVisualization.recordTodayContainer',
        'dataVisualization.recordTodayBorder',
        'dataVisualization.onRecordTodayContainer',
        'surfaces.divider',
      ]) {
        expect(records, contains(role), reason: role);
      }
      expect(records, contains('LogEntryPage'));

      for (final role in [
        'surfaces.workoutMetricStat',
        'surfaces.workoutMetricChart',
        'surfaces.workoutMetricTooltip',
        'surfaces.workoutMetricRange',
        'surfaces.workoutMetricDetails',
        'surfaces.workoutMetricInsight',
        'shapes.workoutMetricStat',
        'shapes.workoutMetricChart',
        'shapes.workoutMetricTooltip',
        'shapes.workoutMetricRange',
        'shapes.workoutMetricRangeOption',
        'shapes.workoutMetricDetails',
        'shapes.workoutMetricInsight',
        'progressColors.accent',
        'progressColors.grid',
        'progressColors.label',
        'dataVisualization.selection',
        'progressColors.workoutIncrease',
        'progressColors.workoutDecrease',
      ]) {
        expect(metric, contains(role), reason: role);
      }
      for (final state in [
        '_range',
        '_selectedMetricIndex',
        '_selectedIndex',
        '_loadSessions',
        'didUpdateWidget',
      ]) {
        expect(metric, contains(state), reason: state);
      }
      expect(metric, isNot(contains('surfaceContainerHighest')));

      for (final role in [
        'surfaces.dashboardSection',
        'shapes.dashboardSection',
        'shapes.settingsInput',
        'shapes.dashboardAction',
      ]) {
        expect(dashboard, contains(role), reason: role);
      }
      expect(dashboard, contains('widget.scale'));
      expect(dashboard, contains('onSessionComplete'));
      expect(dashboard, isNot(contains('surfaceContainerHighest')));
    },
  );
}
