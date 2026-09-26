import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy AppColors usage is retired from production code', () {
    final legacyUsage = <String>{};
    final appColorsPattern = RegExp(r'\bAppColors\b|context\.colors');

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final path = entity.path.replaceAll('\\', '/');
      if (appColorsPattern.hasMatch(entity.readAsStringSync())) {
        legacyUsage.add(path);
      }
    }

    expect(
      legacyUsage,
      isEmpty,
      reason: 'Legacy AppColors usage: $legacyUsage',
    );
  });
}
