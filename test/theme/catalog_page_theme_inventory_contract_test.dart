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
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'shadow',
      ]),
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
    expect(findings, hasLength(15));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'color_transform',
        'color_transform',
        'color_transform',
        'decoration',
        'decoration',
        'decoration',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'shadow',
      ]),
    );
    expect(
      findings.where((finding) => finding.kind == 'color_transform'),
      hasLength(3),
    );
    expect(
      findings.where((finding) => finding.kind == 'decoration'),
      hasLength(3),
    );
    expect(
      findings.where((finding) => finding.kind == 'geometry'),
      hasLength(8),
    );
    expect(findings.where((finding) => finding.kind == 'shadow'), hasLength(1));
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
