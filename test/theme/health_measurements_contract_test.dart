import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('health consumers retain recipe and state ownership', () {
    final health = _read('lib/widgets/health_trends_section.dart');
    final measurements = _read('lib/screens/measurement_trends_page.dart');
    final settings = _read(
      'lib/screens/profile/settings/measurements_trends_settings_page.dart',
    );

    expect(health, contains('TonosSurfaceTheme('));
    expect(
      RegExp(r'styleDarkNeoPickerSurfaces:\s*true').allMatches(health).length,
      3,
      reason: 'each Health Trends entry/edit dialog opts into picker surfaces',
    );

    for (final role in [
      'context.progressColors.healthCard',
      'surfaces.subtleOutline',
      'shapes.card',
      'shapes.healthTrendCard',
      'shapes.healthTrendEntry',
      'dataVisualization.tertiarySeries',
      'context.progressColors.healthGrid',
      'tonosHealthIncreaseForSurface',
      'tonosHealthDecreaseForSurface',
      'textTheme.bodySmall?.color',
    ]) {
      expect(health, contains(role), reason: role);
    }
    expect(health, isNot(contains('theme.cardColor')));
    expect(health, isNot(contains('BorderRadius.circular')));

    for (final state in [
      'refreshToken',
      'fullPage',
      '_trendsFuture',
      '_openTrend',
      '_logEntry',
      '_createCustomMetric',
      'MeasurementTrendDetailPage',
      '_entriesFuture',
      '_editEntry',
      '_deleteEntry',
      '_changed',
      'PopScope',
      '_MeasurementEntryDialog',
      '_MeasurementDefinitionDialog',
      'MeasurementValidationException',
      'LineTooltipItem',
    ]) {
      expect(health, contains(state), reason: state);
    }

    for (final state in [
      '_refreshToken',
      '_seenCompletedSessionVersion',
      'RefreshIndicator',
      'ListView',
      'WorkoutMetricChartCard',
      'ExerciseProgressSection',
      'HealthTrendsSection(refreshToken: _refreshToken)',
    ]) {
      expect(measurements, contains(state), reason: state);
    }

    for (final state in [
      'MeasuredItemsPage',
      'progressMeasurementLibrary',
      'SettingsActionTile',
    ]) {
      expect(settings, contains(state), reason: state);
    }
  });
}
