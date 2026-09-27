import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

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
      rationale: 'Classic values',
      kindCounts: const {
        'color': 4,
        'color_transform': 22,
        'decoration': 22,
        'geometry': 15,
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
        'color': 2,
        'color_transform': 1,
        'decoration': 8,
        'geometry': 7,
        'gradient': 1,
        'text_style': 12,
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
  expect(rule.pattern, path);
  expect(rule.classification, 'structural_theme');
  expect(rule.status, 'migrated');
  expect(rule.kinds, unorderedEquals(kindCounts.keys));
  expect(rule.rationale, contains(rationale));
  expect(rule.matches(path, 'shadow'), isFalse);

  final findings =
      report.findings.where((finding) => finding.ruleId == id).toList();
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
      (finding) => finding.file == path && finding.status == 'pending',
    ),
    isEmpty,
    reason: 'New style kinds in $path must receive explicit review.',
  );
}
