import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('media status overlays expose localized spoken states', () {
    const paths = <String>[
      'lib/widgets/exercise_media_thumbnail.dart',
      'lib/widgets/shared_entity_media_thumbnail.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(
        RegExp(r'Semantics\([\s\S]{0,240}databaseWifiOnly').hasMatch(source),
        isTrue,
        reason: '$path must label its Wi-Fi-only media state.',
      );
      expect(
        RegExp(r'Semantics\([\s\S]{0,240}diagnosticsLoading').hasMatch(source),
        isTrue,
        reason: '$path must label its loading state.',
      );
      expect(source, contains('commonRetry'));
    }
  });
}
