import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('exercise catalog geometry preserves its family recipes', () {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme =
            brightness == Brightness.dark
                ? AppThemeFactory.dark(family)
                : AppThemeFactory.light(family);
        final isNeo = family == AppThemeFamily.neoBrutalism;
        final shapes = theme.shapeTokens;

        expect(
          shapes.exerciseCatalogRow,
          BorderRadius.circular(isNeo ? 4 : 16),
        );
        expect(shapes.exerciseCatalogMedia, BorderRadius.circular(12));
        expect(shapes.outlineWidth, isNeo ? 2 : 1);
        expect(shapes.exerciseCatalogSelectedOutlineWidth, isNeo ? 3 : 1.5);
      }
    }
  });

  test('exercise catalog keeps Material field and contrast ownership', () {
    final source =
        File(
          'lib/screens/exercise/exercise_catalog_page.dart',
        ).readAsStringSync();
    final filterStart = source.indexOf('void _openFilterDialog()');
    final filterEnd = source.indexOf('void _openExerciseDetails(', filterStart);
    expect(filterStart, greaterThanOrEqualTo(0));
    expect(filterEnd, greaterThan(filterStart));
    final filterDialog = source.substring(filterStart, filterEnd);

    expect(filterDialog, contains('TonosDialogFrame('));
    expect(filterDialog, contains('styleFormControls: true'));
    expect(
      RegExp(r'DropdownButtonFormField<').allMatches(filterDialog),
      hasLength(4),
    );
    expect(
      RegExp(r'decoration: InputDecoration\(').allMatches(filterDialog),
      hasLength(4),
    );
    expect(
      RegExp(
        r'dropdownColor: isDarkNeo \? filterMenuSurface : null',
      ).allMatches(filterDialog),
      hasLength(4),
    );
    expect(
      filterDialog,
      contains('tonosForegroundForSurface(context, surfaces.settingsInput)'),
    );
    expect(
      filterDialog,
      contains('tonosForegroundForSurface(context, filterMenuSurface)'),
    );
    expect(filterDialog, contains('selectedItemBuilder'));

    expect(source, contains('child: TextField('));
    expect(source, contains('prefixIcon: const Icon(Icons.search)'));
    expect(source, contains('border: const OutlineInputBorder()'));
    expect(source, contains('Timer(const Duration(milliseconds: 250)'));
    expect(source, contains('_applyAllFilters(showLoading: false)'));
  });

  test(
    'exercise catalog row and media geometry have exact inventory owners',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      const path = 'lib/screens/exercise/exercise_catalog_page.dart';
      final rule = inventory.ruleFor(path, 'decoration');

      expect(rule?.id, 'exercise-catalog-theme-ownership');
      expect(rule?.pattern, path);
      expect(rule?.classification, 'structural_theme');
      expect(rule?.status, 'migrated');
      expect(
        rule?.kinds,
        unorderedEquals(<String>[
          'decoration',
          'geometry',
          'shadow',
          'text_style',
        ]),
      );
      expect(rule?.rationale, contains('Device review'));

      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings =
          report.findings
              .where((finding) => finding.ruleId == rule!.id)
              .toList();
      expect(findings, hasLength(13));
      expect(
        findings.where((finding) => finding.kind == 'decoration'),
        hasLength(6),
      );
      expect(
        findings.where((finding) => finding.kind == 'geometry'),
        hasLength(4),
      );
      expect(
        findings.where((finding) => finding.kind == 'shadow'),
        hasLength(1),
      );
      expect(
        findings.where((finding) => finding.kind == 'text_style'),
        hasLength(2),
      );
      expect(
        findings.map((finding) => finding.status),
        everyElement('migrated'),
      );
      expect(
        report.findings.where(
          (finding) => finding.file == path && finding.status == 'pending',
        ),
        isEmpty,
      );

      final source = File(path).readAsStringSync();
      final rowStart = source.indexOf('class _ExerciseCatalogBar');
      final mediaStart = source.indexOf('class _ExerciseInfoMediaButton');
      expect(rowStart, greaterThanOrEqualTo(0));
      expect(mediaStart, greaterThan(rowStart));
      final row = source.substring(rowStart, mediaStart);
      final mediaButton = source.substring(mediaStart);

      expect(row, contains('shapes.exerciseCatalogRow'));
      expect(row, contains('shapes.exerciseCatalogSelectedOutlineWidth'));
      expect(row, contains('shapes.outlineWidth'));
      expect(row, contains('effects.cardShadow'));
      expect(row, contains('surfaces.catalogSelection'));
      expect(row, contains('surfaces.catalogOutline'));
      expect(
        mediaButton,
        contains('Theme.of(context).shapeTokens.exerciseCatalogMedia'),
      );
      expect(source, contains('onTap: onTap'));
      expect(source, contains('onHeatmapTap: () => _openExerciseDetails(def)'));
    },
  );
}
