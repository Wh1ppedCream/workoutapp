import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';
import '../support/dart_source_library.dart';

void main() {
  test('Exercise Detail and Preset Generation styles have exact owners', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );

    _expectMigratedRule(
      inventory: inventory,
      report: report,
      id: 'exercise-detail-sheet-theme-ownership',
      path: 'lib/widgets/exercise_detail_sheet.dart',
      rationale: 'Catalog Expressive destination wrapping',
      kindCounts: const {
        'color': 12,
        // The Expressive Details disclosure adds its owned frame and header icon.
        'color_transform': 30,
        'decoration': 38,
        'geometry': 59,
        'text_style': 1,
      },
    );
    _expectMigratedRule(
      inventory: inventory,
      report: report,
      id: 'preset-generation-qa-theme-ownership',
      path: 'lib/screens/exercise/preset_generation_qa.dart',
      rationale: 'Classic baseline',
      kindCounts: const {
        'color': 3,
        'color_transform': 4,
        'decoration': 7,
        'geometry': 14,
        'gradient': 1,
        'text_style': 11,
      },
    );
  });
}

void _expectMigratedRule({
  required ThemeStyleInventory inventory,
  required ThemeStyleInventoryReport report,
  required String id,
  required String path,
  required String rationale,
  required Map<String, int> kindCounts,
}) {
  final rule = inventory.pathRules.singleWhere((rule) => rule.id == id);
  expect(rule.pattern, sourceLibraryPattern(path));
  expect(rule.classification, 'structural_theme');
  expect(rule.status, 'migrated');
  expect(rule.kinds, unorderedEquals(kindCounts.keys));
  expect(rule.rationale, contains(rationale));
  expect(rule.matches(path, 'shadow'), isFalse);

  final findings = report.findings
      .where((finding) => finding.ruleId == id)
      .toList();
  final expectedCount = kindCounts.values.fold<int>(
    0,
    (sum, count) => sum + count,
  );
  expect(findings, hasLength(expectedCount));
  for (final entry in kindCounts.entries) {
    expect(
      findings.where((finding) => finding.kind == entry.key),
      hasLength(entry.value),
      reason: '${entry.key} count changed for $path',
    );
  }
  expect(findings.map((finding) => finding.status), everyElement('migrated'));
  expect(
    report.findings.where(
      (finding) =>
          canonicalDartLibraryPath(finding.file) == path &&
          finding.status == 'pending',
    ),
    isEmpty,
    reason: 'New style kinds in $path must receive explicit review.',
  );
}
