import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final workflow in const [
    '.github/workflows/ci.yml',
    '.github/workflows/production-release.yml',
  ]) {
    for (final gate in const {
      'Analyze source and tests': [
        'lib',
        'test',
        'integration_test',
        'test_driver',
      ],
      'Analyze content-pipeline tools': [
        'tools/content_environment_check.dart',
        'tools/content_pipeline.dart',
        'tools/shared_media_pipeline.dart',
      ],
    }.entries) {
      test('$workflow enforces strict ${gate.key}', () {
        final source = File(workflow)
            .readAsStringSync()
            .replaceAll('\r\n', '\n');
        final steps = RegExp(
          '^      - name: ${RegExp.escape(gate.key)}\n'
          r'(?:(?!^      - ).|\n)*',
          multiLine: true,
        ).allMatches(source).toList();
        expect(
          steps,
          hasLength(1),
          reason: 'The named gate must execute once.',
        );
        final step = steps.single.group(0)!;
        expect(step, isNot(contains('continue-on-error: true')));

        final run = RegExp(
          r'^        run: (.*)$',
          multiLine: true,
        ).firstMatch(step);
        expect(
          run,
          isNotNull,
          reason: 'The gate must execute an analyzer command.',
        );
        final firstLine = run!.group(1)!.trim();
        final command = const ['>-', '>', '|-', '|'].contains(firstLine)
            ? step
                  .substring(run.end)
                  .split('\n')
                  .takeWhile(
                    (line) => line.isEmpty || line.startsWith('          '),
                  )
                  .join('\n')
            : firstLine;
        final arguments = command
            .replaceAll(RegExp(r'#.*$', multiLine: true), '')
            .trim()
            .split(RegExp(r'\s+'));
        expect(arguments.take(2), ['dart', 'analyze']);
        expect(arguments, contains('--fatal-infos'));
        expect(arguments, isNot(contains('--no-fatal-infos')));
        expect(arguments, containsAll(gate.value));
      });
    }
  }
}
