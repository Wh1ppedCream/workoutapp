import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every supported locale defines the one-hour plan description',
    () async {
      for (final fileName in const [
        'app_en.arb',
        'app_es.arb',
        'app_fr.arb',
        'app_fr_CA.arb',
        'app_bn.arb',
        'app_zh.arb',
        'app_hi.arb',
      ]) {
        final decoded =
            jsonDecode(await File('lib/l10n/$fileName').readAsString())
                as Map<String, dynamic>;
        final message = decoded['premadeOneHourDescription'];
        expect(
          message,
          isA<String>(),
          reason: '$fileName is missing the message.',
        );
        expect((message as String).trim(), isNotEmpty);
        expect(message, contains('{duration}'));
        expect(message, contains('{planName}'));
      }

      final english =
          jsonDecode(await File('lib/l10n/app_en.arb').readAsString())
              as Map<String, dynamic>;
      final metadata =
          english['@premadeOneHourDescription'] as Map<String, dynamic>;
      final placeholders = metadata['placeholders'] as Map<String, dynamic>;
      expect(placeholders.keys, containsAll(['duration', 'planName']));
    },
  );
}
