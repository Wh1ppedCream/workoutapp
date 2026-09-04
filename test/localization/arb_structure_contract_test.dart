import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _localeFiles = <String, String>{
  'en': 'app_en.arb',
  'es': 'app_es.arb',
  'fr': 'app_fr.arb',
  'fr_CA': 'app_fr_CA.arb',
  'bn': 'app_bn.arb',
  'zh': 'app_zh.arb',
  'hi': 'app_hi.arb',
};

void main() {
  test('ARB files keep message keys and runtime placeholders aligned', () {
    final english = _readArb(_localeFiles['en']!);
    final messageKeys =
        english.keys.where((key) => !key.startsWith('@')).toSet();

    expect(messageKeys, isNotEmpty);

    for (final entry in _localeFiles.entries) {
      final locale = _readArb(entry.value);
      final localeMessageKeys =
          locale.keys.where((key) => !key.startsWith('@')).toSet();
      expect(
        localeMessageKeys,
        unorderedEquals(messageKeys),
        reason: '${entry.value} must match the English message-key set.',
      );

      for (final key in messageKeys) {
        expect(locale[key], isA<String>(), reason: '${entry.value}/$key');
        final message = locale[key] as String;
        expect(message.trim(), isNotEmpty, reason: '${entry.value}/$key');
        final metadata = english['@$key'];
        if (metadata is! Map || metadata['placeholders'] is! Map) continue;

        final placeholders = (metadata['placeholders'] as Map).keys;
        for (final placeholder in placeholders) {
          final pattern = RegExp(
            r'\{' + RegExp.escape(placeholder.toString()) + r'(?:\b|[,}])',
          );
          expect(
            pattern.hasMatch(message),
            isTrue,
            reason:
                '${entry.value}/$key must retain the {$placeholder} placeholder.',
          );
        }
      }
    }
  });

  test('ARB locale tags match the supported locale file names', () {
    for (final entry in _localeFiles.entries) {
      final locale = _readArb(entry.value)['@@locale'];
      expect(locale, entry.key, reason: '${entry.value} has the wrong locale.');
    }
  });
}

Map<String, dynamic> _readArb(String fileName) => Map<String, dynamic>.from(
  jsonDecode(File('lib/l10n/$fileName').readAsStringSync()) as Map,
);
