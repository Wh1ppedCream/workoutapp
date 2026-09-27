import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('Catalog overview recipes have exact four-mode ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/catalog_page.dart',
      'decoration',
    );

    expect(rule?.id, 'catalog-overview-shape-ownership');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>['decoration', 'geometry', 'shadow']),
    );
    expect(rule?.rationale, contains('dedicated AppShapeTokens fields'));
    expect(
      rule?.rationale,
      contains('does not claim device visual acceptance'),
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(3));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['decoration', 'geometry', 'shadow']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/screens/catalog_page.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
    );
  });
}
