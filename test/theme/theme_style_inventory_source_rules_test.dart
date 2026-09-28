import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

ThemeStyleInventory _inventory(String path, {String? sourcePattern}) {
  final baseline = loadThemeStyleInventory('docs/theme-style-inventory.json');
  return ThemeStyleInventory(
    schemaVersion: 1,
    mode: 'report-only',
    classifications: baseline.classifications,
    pathRules: [
      ThemeStyleInventoryRule(
        id: 'error-role',
        pattern: path,
        kinds: const ['color_transform'],
        classification: 'structural_theme',
        status: 'migrated',
        target: 'Material error role',
        rationale: 'Only the reviewed error-role expression is qualified.',
        sourcePattern: sourcePattern,
      ),
      ThemeStyleInventoryRule(
        id: 'pending',
        pattern: path,
        classification: 'pending_triage',
        status: 'pending',
        target: 'Review other route styling',
        rationale: 'Unqualified expressions remain visible.',
      ),
    ],
    reviewQueue: [
      ThemeStyleReviewItem(
        id: 'route',
        title: 'Fixture route',
        patterns: [path],
        target: 'Reviewed source expressions',
        rationale: 'The fixture includes qualified and unqualified styles.',
      ),
    ],
  );
}

void main() {
  const pattern = r'scheme\.error\.withValues\([^)]*\)';
  const path = 'lib/screens/route.dart';

  test('source selectors require a matching candidate span and kind', () {
    final inventory = _inventory(path, sourcePattern: pattern);
    const source =
        'scheme.error.withValues(alpha: 0.2); '
        'scheme.surface.withValues(alpha: 0.2);';
    expect(inventory.ruleFor(path, 'color_transform')?.id, 'pending');
    expect(
      inventory
          .ruleFor(
            path,
            'color_transform',
            source: source,
            candidateOffset: source.indexOf('.withValues'),
          )
          ?.id,
      'error-role',
    );
    expect(
      inventory
          .ruleFor(
            path,
            'color_transform',
            source: source,
            candidateOffset: source.lastIndexOf('.withValues'),
          )
          ?.id,
      'pending',
    );
    expect(
      inventory
          .ruleFor(
            path,
            'decoration',
            source: source,
            candidateOffset: source.indexOf('.withValues'),
          )
          ?.id,
      'pending',
    );
    expect(
      inventory.ruleFor('lib/screens/other.dart', 'color_transform'),
      isNull,
    );
  });

  test(
    'scanner isolates same-line findings and masks comments and strings',
    () {
      final root = Directory.systemTemp.createTempSync('theme-source-rules-');
      addTearDown(() => root.deleteSync(recursive: true));
      final file = File('${root.path}/route.dart');
      file.writeAsStringSync('''
void build() {
  final error = scheme.error.withValues(alpha: 0.2); final base = scheme.surface.withValues(alpha: 0.2);
  // scheme.error.withValues(alpha: 0.2)
  final label = 'scheme.error.withValues(alpha: 0.2)';
  final other = scheme.surface.withValues(alpha: 0.2); // scheme.error.withValues(alpha: 0.2)
}
''');
      final report = scanThemeStyleInventory(
        root: root,
        inventory: _inventory(
          file.path.replaceAll('\\', '/'),
          sourcePattern: pattern,
        ),
      );
      expect(report.findings, hasLength(3));
      expect(
        report.findings.where((finding) => finding.ruleId == 'error-role'),
        hasLength(1),
      );
      expect(
        report.findings.where((finding) => finding.status == 'pending'),
        hasLength(2),
      );
    },
  );

  test('rules without source selectors preserve existing matching', () {
    final inventory = _inventory(path);
    expect(inventory.ruleFor(path, 'color_transform')?.id, 'error-role');
    expect(inventory.ruleFor(path, 'decoration')?.id, 'pending');
  });

  test('invalid source selectors are rejected', () {
    final json = <String, dynamic>{
      'id': 'invalid',
      'pattern': path,
      'classification': 'structural_theme',
      'status': 'migrated',
      'target': 'Error',
      'rationale': 'Fixture',
    };
    for (final value in ['', ' ', '.*', '[', 2, <String>[]]) {
      expect(
        () =>
            ThemeStyleInventoryRule.fromJson({...json, 'sourcePattern': value}),
        throwsFormatException,
      );
    }
  });
}
