import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _section(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end, startIndex + start.length);
  if (startIndex < 0 || endIndex < 0) {
    throw StateError('Could not isolate $start to $end');
  }
  return source.substring(startIndex, endIndex);
}

void main() {
  test('Session history route preserves an active destination scope', () {
    final source = File('lib/widgets/exercise_detail_sheet.dart')
        .readAsStringSync();
    final historyRoute = _section(
      source,
      'Future<void> _openHistorySession(',
      'Future<_LoadedExerciseMedia?> _loadPrimaryMedia()',
    );

    expect(
      historyRoute,
      contains('final destinationFamily = _destinationTokens?.family;'),
    );
    expect(
      historyRoute,
      contains('if (destinationFamily == null) return detail;'),
    );
    expect(historyRoute, contains('AppExpressiveDestinationTheme('));
    expect(historyRoute, contains('family: destinationFamily'));
  });

  test('Catalog detail styling is explicit and opt-in', () {
    final source = File('lib/widgets/exercise_detail_sheet.dart')
        .readAsStringSync();
    final sheetApi = _section(
      source,
      'class ExerciseDetailSheet extends StatefulWidget',
      'State<ExerciseDetailSheet> createState',
    );
    final detailTab = _section(
      source,
      'Widget _buildDetailsTab',
      'void _recoverFromMissingPreview',
    );
    final detailCards = _section(
      source,
      'Widget _buildDetailCard',
      'Widget _buildDetailLabel',
    );
    final expressiveGate = _section(
      source,
      'bool get _usesExpressiveCatalogSheet',
      'final DraggableScrollableController _sheetController',
    );
    final metricsTab = _section(
      source,
      'Widget _buildMetricsTab',
      'Widget _buildRecordsTab',
    );
    final metricsPresentation = _section(
      source,
      'Widget _buildMetricsTimeframePicker',
      'Widget _buildSheetDragHandle',
    );
    final recordsTab = _section(
      source,
      'Widget _buildRecordsTab',
      'Widget _buildExpressiveRecordTrendModule',
    );
    final expressiveRecords = _section(
      source,
      'Widget _buildExpressiveRecordTrendModule',
      'Widget _buildSheetDragHandle',
    );
    final recordBadgeLegend = _section(
      recordsTab,
      'if (hasSetRecordBadges)',
      'for (var index = 0; index < history.length; index++) ...[',
    );

    expect(sheetApi, contains('bool expressiveCatalogPresentation = false'));
    expect(
      sheetApi,
      contains('expressiveCatalogPresentation: expressiveCatalogPresentation'),
    );
    expect(detailTab, contains('_buildFormGuideCard(def)'));
    expect(detailTab, contains('_buildEquipmentCard(def)'));
    expect(detailTab, contains('_buildTargetAnatomyCard(def)'));
    expect(detailCards, contains('expressive ? expressiveContainer'));
    expect(detailCards, contains('shapes.exerciseDetailCard'));
    expect(expressiveGate, contains('widget.expressiveCatalogPresentation'));
    expect(
      expressiveGate,
      contains('AppThemeFamilyIdentity.expressivePreview'),
    );
    expect(expressiveGate, contains('AppExpressiveDestinationFamily.catalog'));
    expect(metricsTab, contains('_usesExpressiveCatalogSheet'));
    expect(
      metricsPresentation,
      contains('expressive: _usesExpressiveCatalogSheet'),
    );
    expect(metricsPresentation, contains('destination!.surfacePrimary'));
    expect(
      metricsPresentation,
      contains('_destinationTokens!.surfaceSelected'),
    );
    expect(
      recordsTab,
      contains('final expressive = _usesExpressiveCatalogSheet'),
    );
    expect(
      recordsTab,
      contains('_buildExpressiveRecordTrendModule(records, weightUnit)'),
    );
    expect(
      RegExp(r'if\s*\(hasSetRecordBadges\)\s*if\s*\(expressive\)')
          .hasMatch(recordBadgeLegend),
      isTrue,
    );
    expect(
      recordBadgeLegend,
      contains('exercise-detail-expressive-record-badge-legend'),
    );
    expect(
      recordBadgeLegend,
      contains('child: const WorkoutRecordBadgeLegend'),
    );
    expect(recordBadgeLegend, contains('padding: EdgeInsets.zero'));
    expect(
      recordBadgeLegend,
      contains('theme.colorScheme.surfaceContainerHigh'),
    );
    expect(
      RegExp(
        r'else\s+const\s+WorkoutRecordBadgeLegend\(\s*padding:\s*EdgeInsets\.only\(bottom:\s*6\)\s*,?\s*\)',
      ).hasMatch(recordBadgeLegend),
      isTrue,
    );
    expect(
      expressiveRecords,
      contains('theme.colorScheme.surfaceContainerLow'),
    );
    expect(source, contains('expressive: false'));
  });
}
