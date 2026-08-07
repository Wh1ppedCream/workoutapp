import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active UI does not introduce hardcoded user-facing English copy', () {
    final violations = <String>[];
    final roots = [Directory('lib/screens'), Directory('lib/widgets')];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path.replaceAll('\\', '/');
        if (_isDeferredSurface(path)) continue;

        final source = entity.readAsStringSync();
        for (final pattern in _userFacingLiteralPatterns) {
          for (final match in pattern.allMatches(source)) {
            final copy = match.namedGroup('copy')?.trim() ?? '';
            if (!_looksLikeUserFacingEnglish(copy) ||
                _allowedTokens.contains(copy)) {
              continue;
            }
            final line =
                '\n'.allMatches(source.substring(0, match.start)).length + 1;
            violations.add('$path:$line: "$copy"');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Move user-facing copy into app_en.arb and every supported locale. '
          'If a surface is intentionally deferred, exclude the whole surface '
          'with a narrow path rule rather than allowlisting its prose.\n'
          '${violations.join('\n')}',
    );
  });

  test('literal classifier catches prose around interpolated values', () {
    expect(_looksLikeUserFacingEnglish('Save changes'), isTrue);
    expect(_looksLikeUserFacingEnglish(r'${count} days ago'), isTrue);
    expect(_looksLikeUserFacingEnglish(r'${count}'), isFalse);
    expect(_looksLikeUserFacingEnglish(r'$value x ${reps}'), isFalse);
    expect(
      _looksLikeUserFacingEnglish(
        'https://cdn.example.com/manifests/content.json',
      ),
      isFalse,
    );
  });
}

final _userFacingLiteralPatterns = <RegExp>[
  RegExp(
    r'''Text\(\s*(?:const\s+)?['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:title|subtitle|label|labelText|emptyMessage|hintText|helperText|tooltip|semanticLabel|message)\s*:\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
];

const _allowedTokens = <String>{
  'A',
  'GO',
  'IA',
  'P',
  'cm',
  'ex',
  'ft/in',
  'https://...',
  'kg',
  'lbs',
};

bool _looksLikeUserFacingEnglish(String copy) {
  if (copy.contains(r'\n')) return false;
  if (copy.startsWith('http://') || copy.startsWith('https://')) return false;
  final literalCopy = copy.replaceAll(
    RegExp(r'\$(?:[A-Za-z_]\w*|\{[^}]+\})'),
    '',
  );
  final withoutIncompleteInterpolation = literalCopy.replaceFirst(
    RegExp(r'\$\{.*$'),
    '',
  );
  if (withoutIncompleteInterpolation.trim() == 'x') return false;
  return RegExp(r'[A-Za-z]').hasMatch(withoutIncompleteInterpolation);
}

bool _isDeferredSurface(String path) {
  const deferredFragments = <String>[
    '/nutrition/',
    '/cardio_',
    '/stretch_',
    '/meal_plan_',
    '/nutrition_',
    '/speed_dial_fab.dart',
    '/combined_history_page.dart',
    '/form_posing_page.dart',
    '/train2_page.dart',
  ];
  return deferredFragments.any(path.contains);
}
