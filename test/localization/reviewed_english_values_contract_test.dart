import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _localeFiles = <String, String>{
  'es': 'app_es.arb',
  'fr': 'app_fr.arb',
  'fr_CA': 'app_fr_CA.arb',
  'bn': 'app_bn.arb',
  'zh': 'app_zh.arb',
  'hi': 'app_hi.arb',
};

void main() {
  test(
    'reviewed-English policy accounts for every current same-English value',
    () {
      final english = _readArb('app_en.arb');
      final policy = _readJson('docs/localization-reviewed-english.json');
      expect(policy['version'], 1);

      final locales = Map<String, dynamic>.from(policy['locales'] as Map);
      expect(locales.keys, unorderedEquals(_localeFiles.keys));

      for (final entry in _localeFiles.entries) {
        final localePolicy = Map<String, dynamic>.from(
          locales[entry.key] as Map,
        );
        final approved = Map<String, dynamic>.from(
          localePolicy['approved'] as Map,
        );
        final existing =
            (localePolicy['existingSameEnglish'] as List).cast<String>();
        final accountedFor = {...approved.keys, ...existing};
        expect(
          existing.length,
          accountedFor.length - approved.length,
          reason: '${entry.key} policy contains duplicate baseline keys.',
        );

        final translated = _readArb(entry.value);
        final sameEnglish =
            english.keys
                .where(
                  (key) =>
                      translated.containsKey(key) &&
                      translated[key] == english[key],
                )
                .toSet();

        expect(
          sameEnglish,
          unorderedEquals(accountedFor),
          reason:
              '${entry.key} gained or lost a same-English value. Review '
              'the value and update docs/localization-reviewed-english.json.',
        );

        for (final approvedEntry in approved.entries) {
          expect(
            translated[approvedEntry.key],
            equals(english[approvedEntry.key]),
            reason:
                '${entry.key}/${approvedEntry.key} is approved but no longer '
                'matches the English source value.',
          );
          expect(approvedEntry.value.toString().trim(), isNotEmpty);
        }
      }
    },
  );

  test('policy fixture rejects an unaccounted copied-English key', () {
    final english = {'known': 'Known', 'newCopy': 'New copy'};
    final translated = {'known': 'Known', 'newCopy': 'New copy'};
    const accountedFor = {'known'};

    final sameEnglish =
        english.keys.where((key) => translated[key] == english[key]).toSet();

    expect(sameEnglish.difference(accountedFor), contains('newCopy'));
  });
}

Map<String, dynamic> _readArb(String fileName) => Map<String, dynamic>.from(
  jsonDecode(File('lib/l10n/$fileName').readAsStringSync()) as Map,
);

Map<String, dynamic> _readJson(String path) =>
    Map<String, dynamic>.from(jsonDecode(File(path).readAsStringSync()) as Map);
