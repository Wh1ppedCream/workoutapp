import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppRepository exposes no deprecated compatibility aliases', () {
    final source =
        File('lib/repositories/app_repository.dart').readAsStringSync();

    expect(source, isNot(contains('@Deprecated')));
    expect(source, isNot(contains('Future<int> createSession(')));
    expect(source, isNot(contains('Future<void> setCardioDetails(')));
    expect(source, contains('Future<int> createSessionAt('));
    expect(source, contains('Future<void> saveCardioDetails('));
  });

  test('removed screen forwarding files stay removed', () {
    const forwardingFiles = <String>[
      'lib/screens/analytics_dashboard_screen.dart',
      'lib/screens/analytics_setting_screen.dart',
      'lib/screens/app_settings_page.dart',
      'lib/screens/auto_preset_flow_screen.dart',
      'lib/screens/bodypart_muscle_mapping_screen.dart',
      'lib/screens/bodypart_ranking_screen.dart',
      'lib/screens/definitions_by_bodypart_page.dart',
      'lib/screens/exercise_analytics_screen.dart',
      'lib/screens/exercise_catalog_page.dart',
      'lib/screens/gym_profile_screen.dart',
      'lib/screens/history_screen.dart',
      'lib/screens/muscle_filter_page.dart',
      'lib/screens/muscle_ranking_screen.dart',
      'lib/screens/preset_detail_screen.dart',
      'lib/screens/profile_page.dart',
      'lib/screens/session_detail_screen.dart',
      'lib/screens/train_page.dart',
      'lib/screens/volume_boundaries_screen.dart',
      'lib/screens/nutrition/new_measurement_item_page.dart',
    ];

    for (final path in forwardingFiles) {
      expect(File(path).existsSync(), isFalse, reason: '$path is obsolete');
    }
  });

  test('measurement entry imports use the canonical screen', () {
    for (final path in <String>[
      'lib/widgets/dashboard_sections.dart',
      'lib/widgets/quick_bar.dart',
      'lib/widgets/speed_dial_fab.dart',
      'lib/screens/nutrition/measured_items_page.dart',
      'lib/screens/nutrition/nutrition_page.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains("new_measurement_item_page.dart"));
      expect(
        source,
        isNot(contains("import 'new_measurement_item_page.dart'")),
      );
    }
  });
}
