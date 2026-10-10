import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';

import '../../tools/theme_style_inventory.dart';

void main() {
  test('exercise catalog geometry preserves its family recipes', () {
    for (final family in AppThemeFamily.values) {
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.dark
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
    final source = File('lib/screens/exercise/exercise_catalog_page.dart')
        .readAsStringSync();
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
      RegExp(r'InputDecoration filterFieldDecoration\(')
          .allMatches(filterDialog),
      hasLength(1),
    );
    expect(
      RegExp(r'decoration: filterFieldDecoration\(').allMatches(filterDialog),
      hasLength(4),
    );
    expect(
      RegExp(
        r'dropdownColor:\s*usesExpressive\s*\|\|\s*isDarkNeo\s*\?\s*filterMenuSurface\s*:\s*null',
      ).allMatches(filterDialog),
      hasLength(4),
    );
    expect(filterDialog, contains('final filterMenuSurface = usesExpressive'));
    expect(filterDialog, contains('expressiveTokens.surfaceAccent'));
    expect(
      filterDialog,
      contains(
        'theme.popupMenuTheme.color ?? theme.colorScheme.surfaceContainer',
      ),
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
    expect(
      RegExp(r'border:\s*usesExpressive\s*\?\s*OutlineInputBorder\(')
          .hasMatch(source),
      isTrue,
    );
    expect(source, contains(': const OutlineInputBorder()'));
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
          'color',
          'color_transform',
          'decoration',
          'geometry',
          'shadow',
          'text_style',
        ]),
      );
      expect(
        rule?.rationale,
        contains(
          'AppBar surface tint resolves from the Catalog destination primary role',
        ),
      );

      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings = report.findings
          .where((finding) => finding.ruleId == rule!.id)
          .toList();
      expect(findings, hasLength(43));
      expect(report.hasUnassignedFindings, isFalse);
      expect(
        findings.where((finding) => finding.kind == 'color'),
        hasLength(0),
      );
      expect(
        findings.where((finding) => finding.kind == 'decoration'),
        hasLength(4),
      );
      // The Expressive row and its neutral media well each add one
      // intentionally page-owned geometry candidate.
      expect(
        findings.where((finding) => finding.kind == 'geometry'),
        hasLength(34),
      );
      expect(
        findings.where((finding) => finding.kind == 'shadow'),
        hasLength(1),
      );
      expect(
        findings.where((finding) => finding.kind == 'text_style'),
        hasLength(3),
      );
      expect(
        findings.where((finding) => finding.kind == 'color_transform'),
        hasLength(1),
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
      expect(row, contains('expressiveDestination.surfaceSelected'));
      expect(row, contains('expressiveDestination.surfaceAccent'));
      expect(row, contains('expressiveDestination.onSurfaceSelected'));
      expect(row, contains('expressiveDestination.onSurfaceAccent'));
      expect(
        row,
        contains('heatmapSurface: usesExpressive ? null : foregroundSurface'),
      );
      expect(row, contains('framed: usesExpressive'));
      expect(
        mediaButton,
        contains('Theme.of(context).shapeTokens.exerciseCatalogMedia'),
      );
      expect(mediaButton, contains('framed: false'));
      expect(mediaButton, contains('if (framed)'));
      expect(mediaButton, contains('context.surfaceTokens.mediaPlaceholder'));
      expect(source, contains('onTap: onTap'));
      expect(source, contains('onHeatmapTap: () => _openExerciseDetails(def)'));
    },
  );
}
