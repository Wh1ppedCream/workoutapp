import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('composition root injects one repository into state providers', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(
      RegExp(r'AppRepository\s*\(\s*\)').allMatches(mainSource),
      hasLength(1),
    );
    expect(mainSource, contains('Provider<AppRepository>.value(value: repo)'));
    expect(mainSource, contains('ActivePlanStore(repository: repo)'));
    expect(mainSource, contains('NutritionProfile(repository: repo)'));
    expect(mainSource, contains('ActiveSession(repository: repo)'));
    expect(mainSource, contains('SelectedProfile(repository: repo)'));
  });

  test('only the composition root constructs a production repository', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      if (normalizedPath.endsWith('/main.dart') ||
          normalizedPath.endsWith('/repositories/app_repository.dart')) {
        continue;
      }
      final source = file.readAsStringSync().replaceAll(
        RegExp(r'/\*.*?\*/', dotAll: true),
        '',
      );
      expect(
        RegExp(r'AppRepository\s*\(').hasMatch(source),
        isFalse,
        reason: '${file.path} must receive the composition-root repository',
      );
    }
  });

  test('UI and state layers do not construct the database singleton', () {
    for (final directory in const [
      'lib/screens',
      'lib/widgets',
      'lib/providers',
      'lib/services',
    ]) {
      final files = Directory(directory)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        final source = file.readAsStringSync().replaceAll(
          RegExp(r'/\*.*?\*/', dotAll: true),
          '',
        );
        expect(
          RegExp(r'DatabaseHelper\s*\(').hasMatch(source),
          isFalse,
          reason: '${file.path} must use the injected AppRepository boundary',
        );
      }
    }
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
