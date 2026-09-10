import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('the structural-style inventory is valid and report-only', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );

    expect(inventory.schemaVersion, 1);
    expect(inventory.mode, 'report-only');
    expect(inventory.classifications, isNotEmpty);
    expect(inventory.pathRules, isNotEmpty);
    expect(inventory.reviewQueue, isNotEmpty);
    expect(
      inventory.classificationIds,
      containsAll(<String>[
        'structural_theme',
        'material_component',
        'tonos_semantic',
        'data_visualization',
        'illustration_media',
        'intentional_one_off',
      ]),
    );
    expect(
      inventory.pathRules.any((rule) => rule.status == 'allowlisted'),
      isTrue,
    );
    expect(inventory.pathRules.any((rule) => rule.status == 'pending'), isTrue);
    expect(
      inventory.pathRules.any(
        (rule) => rule.matches('lib/theme/theme_extensions.dart', 'color'),
      ),
      isTrue,
    );
    expect(
      inventory.pathRules.any(
        (rule) =>
            rule.matches('lib/l10n/generated/app_localizations.dart', 'color'),
      ),
      isTrue,
    );
  });

  test('every production style candidate has a measurable destination', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );

    expect(report.scannedFiles, isNotEmpty);
    expect(report.findings, isNotEmpty);
    expect(report.hasUnassignedFindings, isFalse);
    for (final finding in report.findings) {
      expect(finding.file, isNotEmpty);
      expect(finding.line, greaterThan(0));
      expect(finding.kind, isNotEmpty);
      expect(finding.ruleId, isNot('unassigned'));
      expect(finding.classification, isNot('unassigned'));
      expect(finding.status, isNot('unassigned'));
      expect(finding.target, isNotEmpty);
    }
  });
}
