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
  test('Catalog detail styling is explicit and opt-in', () {
    final source =
        File('lib/widgets/exercise_detail_sheet.dart').readAsStringSync();
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

    // History and metrics remain owned by their existing implementations;
    // Expressive opt-in is consumed by Details-only card/tag helpers.
    expect(
      _section(source, 'Widget _buildMetricsTab', 'Widget _buildRecordsTab'),
      isNot(contains('expressiveCatalogPresentation')),
    );
    expect(
      _section(source, 'Widget _buildRecordsTab', 'Widget _buildSheetDragHandle'),
      isNot(contains('expressiveCatalogPresentation')),
    );
    expect(source, contains('expressive: false'));
  });
}
