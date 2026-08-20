import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final workflowFiles =
      Directory('.github/workflows')
          .listSync()
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.yml') || file.path.endsWith('.yaml'),
          )
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  test('workflows pin Actions and do not retain checkout credentials', () {
    expect(workflowFiles, isNotEmpty);
    final usesPattern = RegExp(
      r'^\s*uses:\s+([^\s@]+)@([^\s#]+)',
      multiLine: true,
    );
    final immutableRef = RegExp(r'^[0-9a-f]{40}$');

    for (final file in workflowFiles) {
      final source = file.readAsStringSync();
      final uses = usesPattern.allMatches(source).toList();

      expect(uses, isNotEmpty, reason: '${file.path} has no pinned Actions.');
      for (final match in uses) {
        expect(
          match.group(2),
          matches(immutableRef),
          reason:
              '${file.path} must pin ${match.group(1)} to a full commit SHA.',
        );
      }

      final checkoutCount =
          uses.where((match) => match.group(1) == 'actions/checkout').length;
      final disabledCredentialCount =
          RegExp(
            r'^\s*persist-credentials:\s*false\s*$',
            multiLine: true,
          ).allMatches(source).length;
      expect(
        disabledCredentialCount,
        checkoutCount,
        reason: '${file.path} must disable credentials for every checkout.',
      );
      expect(source, matches(RegExp(r'^permissions:\s*$', multiLine: true)));
      expect(source, isNot(contains('permissions: write-all')));
      expect(source, isNot(contains('pull_request_target')));
    }
  });

  test('CI follows feature-branch and required-check policy', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();

    expect(
      workflow,
      matches(RegExp(r'pull_request:\s*\r?\n\s+branches:\s*\r?\n\s+- master')),
    );
    for (final prefix in [
      'feature',
      'fix',
      'updates',
      'dependency',
      'chore',
      'release',
    ]) {
      expect(workflow, contains('- "$prefix/**"'));
    }
    expect(workflow, isNot(contains('local-db')));
    expect(workflow, contains('name: Localization, analyzer, and tests'));
    expect(workflow, contains('name: Release APK'));
    expect(workflow, contains('dart format lib/l10n/generated'));
    expect(workflow, contains('dart analyze tools/content_pipeline.dart'));
    expect(workflow, contains('working-directory: tools/catalog_builder'));
    expect(workflow, contains('dart analyze bin tool'));
    expect(workflow, contains('test/tooling_fixture_contract_test.dart'));
  });

  test('Dependabot reviews workflow and Dart dependencies', () {
    final source = File('.github/dependabot.yml').readAsStringSync();

    expect(source, contains('package-ecosystem: github-actions'));
    expect(source, contains('directory: /tools/catalog_builder'));
    expect(RegExp('package-ecosystem: pub').allMatches(source), hasLength(2));
  });
}
