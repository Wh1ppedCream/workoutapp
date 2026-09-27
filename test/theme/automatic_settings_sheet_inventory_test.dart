import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('Automatic Settings owns only its qualified Material findings', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (candidate) => candidate.id == 'automatic-settings-theme-ownership',
    );

    expect(rule.pattern, 'lib/widgets/automatic_settings_sheet.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>['color_transform', 'text_style']),
    );
    expect(rule.rationale, contains('ColorScheme.onSurface'));
    expect(rule.rationale, contains('inherited size and foreground'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(6));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'color_transform',
        'color_transform',
        'text_style',
        'text_style',
        'text_style',
        'text_style',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      inventory
          .ruleFor('lib/widgets/automatic_settings_sheet.dart', 'decoration')
          ?.id,
      'release-widgets',
    );
  });
}
