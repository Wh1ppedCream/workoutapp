import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('composition root injects one repository into state providers', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('NutritionProfile(repository: repo)'));
    expect(mainSource, contains('ActiveSession(repository: repo)'));
    expect(mainSource, contains('SelectedProfile(repository: repo)'));
  });

  test('core onboarding and plan flow never creates a private repository', () {
    const injectedFiles = <String>[
      'lib/providers/durable_active_session.dart',
      'lib/providers/nutrition_profile.dart',
      'lib/providers/preset_session.dart',
      'lib/providers/selected_profile.dart',
      'lib/screens/exercise/preset_detail_screen.dart',
      'lib/screens/onboarding_flow.dart',
      'lib/services/auto_increment_service.dart',
      'lib/widgets/preset_info_card.dart',
      'lib/widgets/swap_exercise_sheet.dart',
    ];

    for (final path in injectedFiles) {
      expect(
        File(path).readAsStringSync(),
        isNot(contains('AppRepository()')),
        reason: '$path must receive the composition-root repository',
      );
    }
  });
}
