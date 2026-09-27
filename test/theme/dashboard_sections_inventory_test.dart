import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('dashboard section widget recipes have exact migrated ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'dashboard-sections-theme-ownership',
    );

    expect(rule.pattern, 'lib/widgets/dashboard_sections.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'gradient',
      ]),
    );
    expect(rule.rationale, contains('four-mode production-widget contract'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();

    expect(findings, hasLength(18));
    expect(findings.where((finding) => finding.kind == 'color'), hasLength(1));
    expect(
      findings.where((finding) => finding.kind == 'color_transform'),
      hasLength(5),
    );
    expect(
      findings.where((finding) => finding.kind == 'decoration'),
      hasLength(6),
    );
    expect(
      findings.where((finding) => finding.kind == 'geometry'),
      hasLength(5),
    );
    expect(
      findings.where((finding) => finding.kind == 'gradient'),
      hasLength(1),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });
}
