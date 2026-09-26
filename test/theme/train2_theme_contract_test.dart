import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reachable Train2 consumers use theme-owned route roles', () {
    final source =
        File('lib/screens/exercise/train2_page.dart').readAsStringSync();

    for (final role in [
      'shapes.trainTab',
      'semantic.trainProfileAvatar',
      'semantic.onTrainProfileAvatar',
      'dataVisualization.tertiarySeries',
      'semantic.trainOptimizedAction',
    ]) {
      expect(source, contains(role), reason: role);
    }

    for (final legacyColor in [
      'Colors.lightGreen',
      'Colors.purple',
      'Colors.green',
    ]) {
      expect(source, isNot(contains(legacyColor)), reason: legacyColor);
    }

    expect(source, contains('PresetGenerationQaScreen'));
  });
}
