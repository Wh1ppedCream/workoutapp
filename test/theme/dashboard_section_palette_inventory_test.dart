import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('dashboard section palette has an exact data-color allowlist', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'dashboard-section-identity-colors',
    );

    expect(rule.pattern, 'lib/widgets/dashboard_section_palette.dart');
    expect(rule.classification, 'stable_category_data');
    expect(rule.status, 'allowlisted');
    expect(
      rule.kinds,
      unorderedEquals(<String>['color_literal', 'color_literal_candidate']),
    );
    expect(rule.rationale, contains('future user-selectable theme palette'));
    expect(rule.matches(rule.pattern, 'decoration'), isFalse);

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();

    expect(findings, hasLength(16));
    expect(
      findings.where((finding) => finding.kind == 'color_literal'),
      hasLength(8),
    );
    expect(
      findings.where((finding) => finding.kind == 'color_literal_candidate'),
      hasLength(8),
    );
    expect(
      findings.map((finding) => finding.status),
      everyElement('allowlisted'),
    );
  });
}
