import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active UI never renders or retains raw exception details', () {
    final violations = <String>[];
    final roots = <Directory>[
      Directory('lib/screens'),
      Directory('lib/widgets'),
      Directory('lib/providers'),
    ];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        violations.addAll(
          _findUnsafeFailureHandling(
            source: entity.readAsStringSync(),
            path: entity.path.replaceAll('\\', '/'),
          ),
        );
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Classify exceptions with SafeFailure and render localized recovery '
          'copy. Raw paths, SQL, URLs, and exception messages must never enter '
          'UI state or user-facing strings.\n${violations.join('\n')}',
    );
  });

  test(
    'contract detects raw interpolation, conversion, and retained errors',
    () {
      final violations = _findUnsafeFailureHandling(
        path: 'test_fixture.dart',
        source: r'''
        String? loadError;
        Object? restoreError;
        loadError = error.toString();
        Text('Failed: $error');
        Text('Failed: $e');
        debugPrint('Allowed developer log: $error');
        final safe = SafeFailure.classify(error);
      ''',
      );

      expect(violations, hasLength(5));
    },
  );
}

List<String> _findUnsafeFailureHandling({
  required String source,
  required String path,
}) {
  final withoutComments = source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\r\n]*'), '');
  final lines = withoutComments.split(RegExp(r'\r?\n'));
  final violations = <String>[];

  for (var index = 0; index < lines.length; index += 1) {
    final line = lines[index];
    if (line.contains('debugPrint(')) continue;

    for (final pattern in _unsafePatterns) {
      if (pattern.hasMatch(line)) {
        violations.add('$path:${index + 1}: ${line.trim()}');
        break;
      }
    }
  }
  return violations;
}

final _unsafePatterns = <RegExp>[
  RegExp(r'\b(?:error|exception|snapshot\.error|snap\.error)\.toString\s*\('),
  RegExp(r'\$(?:error|exception)(?![A-Za-z0-9_])'),
  RegExp(r'\$\{\s*(?:error|exception|snapshot\.error|snap\.error)\s*\}'),
  RegExp(r'\$e(?![A-Za-z0-9_])|\$\{\s*e\s*\}'),
  RegExp(r'\b(?:String|Object)\?\s+_?\w*(?:load|save|restore)Error\b'),
  RegExp(
    r'\b_?\w*(?:error|failure)\w*\s*=\s*(?:error|exception|e)\.toString\s*\(',
  ),
];
