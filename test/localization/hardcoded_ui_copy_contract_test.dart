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

        violations.addAll(
          _findUserFacingLiteralViolations(
            source: entity.readAsStringSync(),
            path: path,
          ),
        );
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

  test(
    'literal contract detects conditional, semantic, and empty-state copy',
    () {
      final violations = _findUserFacingLiteralViolations(
        path: 'test_fixture.dart',
        source: '''
        Text(isReady ? 'Ready to train' : 'Still loading');
        SelectableText('More details');
        Tooltip(message: isSaved ? 'Saved workout' : 'Save workout');
        Semantics(semanticLabel: isOpen ? 'Close panel' : 'Open panel');
        EmptyState(emptyMessage: 'No workouts yet');
      ''',
      );

      expect(violations, hasLength(8));
      expect(violations.join('\n'), contains('Ready to train'));
      expect(violations.join('\n'), contains('Still loading'));
      expect(violations.join('\n'), contains('No workouts yet'));
    },
  );
}

List<String> _findUserFacingLiteralViolations({
  required String source,
  required String path,
}) {
  final violations = <String>[];
  for (final pattern in _userFacingLiteralPatterns) {
    for (final match in pattern.allMatches(source)) {
      final copy = match.namedGroup('copy')?.trim() ?? '';
      if (!_looksLikeUserFacingEnglish(copy) || _allowedTokens.contains(copy)) {
        continue;
      }
      final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
      violations.add('$path:$line: "$copy"');
    }
  }
  return violations;
}

final _userFacingLiteralPatterns = <RegExp>[
  RegExp(
    r'''(?:Text|SelectableText)\(\s*(?:const\s+)?['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:title|subtitle|label|labelText|emptyMessage|hintText|helperText|tooltip|semanticLabel|message|description|body|primaryLabel|secondaryLabel)\s*:\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:Text|SelectableText)\(\s*[^'"\r\n]*?\?\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:Text|SelectableText)\(\s*[^'"\r\n]*?\?\s*['"][^'"\r\n]*['"]\s*:\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:title|subtitle|label|labelText|emptyMessage|hintText|helperText|tooltip|semanticLabel|message|description|body|primaryLabel|secondaryLabel)\s*:\s*[^'"\r\n]*?\?\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
    multiLine: true,
  ),
  RegExp(
    r'''(?:title|subtitle|label|labelText|emptyMessage|hintText|helperText|tooltip|semanticLabel|message|description|body|primaryLabel|secondaryLabel)\s*:\s*[^'"\r\n]*?\?\s*['"][^'"\r\n]*['"]\s*:\s*['"](?<copy>[A-Za-z\$][^'"\r\n]*)['"]''',
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
    '/combined_history_page.dart',
    '/form_posing_page.dart',
    '/train2_page.dart',
  ];
  return deferredFragments.any(path.contains);
}
