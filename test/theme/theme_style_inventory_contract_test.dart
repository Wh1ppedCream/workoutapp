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
        'stable_category_data',
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

  test('app-shell status bar policy has exact migrated ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor('lib/main.dart', 'color');

    expect(rule?.id, 'app-shell-system-status-bar-overlay');
    expect(rule?.classification, 'application_shell');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['color']));
    expect(rule?.rationale, contains('not a user-selectable theme accent'));
    final appSource = File('lib/main.dart').readAsStringSync();
    expect(
      appSource,
      matches(
        RegExp(
          r'value:\s*appSystemUiOverlayStyleFor\(\s*Theme\.of\(context\)\.brightness\s*,?\s*\)',
        ),
      ),
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(1));
    expect(findings.single.snippet, contains('statusBarColor'));
    expect(findings.single.status, 'migrated');
  });

  test('tutorial recipe exception stays kind-limited', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'tutorial-scrim',
    );

    expect(rule.classification, 'intentional_one_off');
    expect(rule.status, 'allowlisted');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_literal',
        'color_literal_candidate',
        'color_transform',
        'decoration',
        'geometry',
        'shadow',
      ]),
    );
    expect(
      rule.matches('lib/widgets/guided_tutorial_overlay.dart', 'shadow'),
      isTrue,
    );
    expect(
      rule.matches('lib/widgets/guided_tutorial_overlay.dart', 'local_theme'),
      isFalse,
    );
    expect(rule.matches('lib/widgets/drawers.dart', 'shadow'), isFalse);
  });

  test('entity identity colors stay a documented data-color allowlist', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'identity-color-palettes',
    );

    expect(rule.pattern, 'lib/widgets/identity_color_palettes.dart');
    expect(rule.classification, 'intentional_one_off');
    expect(rule.status, 'allowlisted');
    expect(rule.target, contains('identity data colors'));
    expect(rule.rationale, contains('ThemePaletteId'));
    expect(rule.rationale, contains('IdentityPaletteId'));
    expect(rule.rationale, contains('contrast-qualified'));
    expect(rule.rationale, contains('theme-aware swatches'));
  });

  test('settings category accents have a narrow data-color allowlist', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'settings-category-accents',
    );

    expect(rule.pattern, 'lib/widgets/settings_tiles.dart');
    expect(rule.classification, 'stable_category_data');
    expect(rule.status, 'allowlisted');
    expect(
      rule.kinds,
      unorderedEquals(<String>['color_literal', 'color_literal_candidate']),
    );
    expect(rule.target, contains('Stable settings-category data colors'));
    expect(rule.rationale, contains('future user-selectable theme palette'));
    expect(
      inventory.ruleFor('lib/widgets/settings_tiles.dart', 'color_literal')?.id,
      'settings-category-accents',
    );
    expect(
      inventory.ruleFor('lib/widgets/settings_tiles.dart', 'decoration')?.id,
      'settings-tiles-recipes',
    );
    expect(
      inventory
          .ruleFor('lib/widgets/settings_tiles.dart', 'decoration')
          ?.status,
      'migrated',
    );
    final settingsRecipeRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'settings-tiles-recipes',
    );
    expect(
      settingsRecipeRule.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'gradient',
        'shadow',
        'text_style',
      ]),
    );
    final localThemeRule = inventory.ruleFor(
      'lib/widgets/settings_tiles.dart',
      'local_theme',
    );
    expect(localThemeRule?.id, 'settings-tiles-local-theme');
    expect(localThemeRule?.status, 'migrated');
    expect(localThemeRule?.kinds, unorderedEquals(<String>['local_theme']));
    expect(localThemeRule?.rationale, contains('Four-mode contracts'));
  });

  test('dashboard editor inventory ownership stays exact and kind-limited', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final surfaceRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'dashboard-editor-surface-recipes',
    );
    final categoryRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'dashboard-editor-category-accents',
    );

    expect(surfaceRule.pattern, 'lib/screens/dashboard_page.dart');
    expect(surfaceRule.classification, 'structural_theme');
    expect(surfaceRule.status, 'migrated');
    expect(
      surfaceRule.kinds,
      unorderedEquals(<String>['decoration', 'geometry']),
    );
    expect(surfaceRule.rationale, contains('dashboardEditor'));
    expect(surfaceRule.rationale, contains('manual/device review'));

    expect(categoryRule.pattern, 'lib/screens/dashboard_page.dart');
    expect(categoryRule.classification, 'stable_category_data');
    expect(categoryRule.status, 'allowlisted');
    expect(categoryRule.kinds, unorderedEquals(<String>['color_transform']));
    expect(categoryRule.rationale, contains('future user-selectable theme'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final surfaceFindings =
        report.findings
            .where((finding) => finding.ruleId == surfaceRule.id)
            .toList();
    final categoryFindings =
        report.findings
            .where((finding) => finding.ruleId == categoryRule.id)
            .toList();

    expect(surfaceFindings, hasLength(8));
    expect(
      surfaceFindings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'decoration',
        'geometry',
        'decoration',
        'geometry',
        'decoration',
        'geometry',
        'decoration',
        'geometry',
      ]),
    );
    expect(
      surfaceFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
    expect(categoryFindings, hasLength(2));
    expect(
      categoryFindings.every((finding) => finding.status == 'allowlisted'),
      isTrue,
    );
    expect(
      inventory.ruleFor('lib/screens/dashboard_page.dart', 'text_style')?.id,
      'release-screens',
    );
  });

  test('Weekly Overview progress scope has an exact migrated rule', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/seven_day_focus_card.dart',
      'local_theme',
    );

    expect(rule?.id, 'seven-day-focus-local-theme');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['local_theme']));
    expect(
      rule?.matches('lib/widgets/seven_day_focus_card.dart', 'decoration'),
      isFalse,
    );
  });

  test('Weekly Overview tap recipe has exact rendered ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/seven_day_focus_card.dart',
      'color_transform',
    );

    expect(rule?.id, 'seven-day-focus-tap-recipe');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>['color_transform', 'color', 'geometry']),
    );
    expect(rule?.rationale, contains('0.22'));
    expect(rule?.rationale, contains('16px'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(3));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['color_transform', 'color', 'geometry']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      inventory
          .ruleFor('lib/widgets/seven_day_focus_card.dart', 'decoration')
          ?.id,
      'release-widgets',
    );
  });

  test('single-bodypart heatmap owns only its surface and shape findings', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/body_heatmap.dart',
      'decoration',
    );

    expect(rule?.id, 'single-bodypart-heatmap-container');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['decoration', 'geometry']));
    expect(rule?.rationale, contains('surfaceContainerHighest'));
    expect(rule?.rationale, contains('14px'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(2));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['decoration', 'geometry']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      inventory.ruleFor('lib/widgets/body_heatmap.dart', 'text_style')?.id,
      'release-widgets',
    );
  });

  test(
    'nutrition ValueCard owns only its border and scaled shape findings',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      final rule = inventory.ruleFor(
        'lib/widgets/nutrition_text_details.dart',
        'decoration',
      );

      expect(rule?.id, 'value-card-nutrition-border');
      expect(rule?.classification, 'structural_theme');
      expect(rule?.status, 'migrated');
      expect(rule?.kinds, unorderedEquals(<String>['decoration', 'geometry']));
      expect(rule?.rationale, contains('textDetailsBorder'));
      expect(rule?.rationale, contains('8px'));

      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings =
          report.findings
              .where((finding) => finding.ruleId == rule!.id)
              .toList();
      expect(findings, hasLength(3));
      expect(
        findings.map((finding) => finding.kind),
        unorderedEquals(<String>['decoration', 'geometry', 'geometry']),
      );
      expect(
        findings.map((finding) => finding.status),
        everyElement('migrated'),
      );
      expect(
        inventory
            .ruleFor('lib/widgets/nutrition_text_details.dart', 'text_style')
            ?.id,
        'release-widgets',
      );
    },
  );

  test('WeightCard token recipes retain exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final inputThemeRule = inventory.ruleFor(
      'lib/widgets/weight_card.dart',
      'local_theme',
    );

    expect(inputThemeRule?.id, 'weight-card-input-theme');
    expect(inputThemeRule?.classification, 'structural_theme');
    expect(inputThemeRule?.status, 'migrated');
    expect(inputThemeRule?.kinds, unorderedEquals(<String>['local_theme']));

    final recipeRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'weight-card-recipes',
    );
    expect(recipeRule.pattern, 'lib/widgets/weight_card.dart');
    expect(recipeRule.classification, 'structural_theme');
    expect(recipeRule.status, 'migrated');
    expect(
      recipeRule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'shadow',
      ]),
    );
    final popupTextRule = inventory.ruleFor(
      'lib/widgets/weight_card.dart',
      'text_style',
    );
    expect(popupTextRule?.id, 'weight-card-popup-text');
    expect(popupTextRule?.classification, 'structural_theme');
    expect(popupTextRule?.status, 'migrated');
    expect(popupTextRule?.kinds, unorderedEquals(<String>['text_style']));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'weight-card-recipes')
            .toList();
    expect(findings, hasLength(23));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));

    final popupTextFindings =
        report.findings
            .where((finding) => finding.ruleId == 'weight-card-popup-text')
            .toList();
    expect(popupTextFindings, hasLength(3));
    expect(
      popupTextFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );
  });

  test('Train panel ink theme is an exact migrated local scope', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/exercise/train_page.dart',
      'local_theme',
    );

    expect(rule?.id, 'train-panel-ink-theme');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['local_theme']));
    expect(
      inventory
          .ruleFor('lib/screens/exercise/train_page.dart', 'decoration')
          ?.id,
      'train-action-bar-recipes',
    );

    final recipeRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'train-action-bar-recipes',
    );
    expect(recipeRule.pattern, 'lib/screens/exercise/train_page.dart');
    expect(recipeRule.classification, 'structural_theme');
    expect(recipeRule.status, 'migrated');
    expect(
      recipeRule.kinds,
      unorderedEquals(<String>[
        'decoration',
        'geometry',
        'shadow',
        'color',
        'color_transform',
        'text_style',
      ]),
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'train-action-bar-recipes')
            .toList();
    expect(findings, hasLength(7));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('Train2 tab selector owns only its exact theme recipe', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'train2-tab-selector-recipe',
    );

    expect(rule.pattern, 'lib/screens/exercise/train2_page.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(rule.kinds, unorderedEquals(<String>['color', 'decoration']));
    expect(rule.rationale, contains('surfaceContainerHighest'));
    expect(rule.rationale, contains('transparent normal/selected borders'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(3));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['decoration', 'color', 'color']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      inventory
          .ruleFor('lib/screens/exercise/train2_page.dart', 'text_style')
          ?.id,
      'train2-route-typography',
    );
  });

  test('Train2 route typography stays a count-pinned one-off', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/exercise/train2_page.dart',
      'text_style',
    );

    expect(rule?.id, 'train2-route-typography');
    expect(rule?.classification, 'intentional_one_off');
    expect(rule?.status, 'allowlisted');
    expect(rule?.kinds, unorderedEquals(<String>['text_style']));
    expect(rule?.rationale, contains('onTrainProfileAvatar'));
    expect(rule?.rationale, contains('global typography tokens'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(5));
    expect(findings.map((finding) => finding.kind), everyElement('text_style'));
    expect(
      findings.map((finding) => finding.status),
      everyElement('allowlisted'),
    );
  });

  test('qualified workout record badges use the exact migrated rule', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'workout-record-badges',
    );

    expect(rule.pattern, 'lib/widgets/workout_record_badges.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      inventory
          .ruleFor('lib/widgets/workout_record_badges.dart', 'decoration')
          ?.id,
      'workout-record-badges',
    );
    expect(
      inventory.ruleFor('lib/widgets/settings_tiles.dart', 'decoration')?.id,
      isNot('workout-record-badges'),
    );
    final expansionTileScopeRule = inventory.ruleFor(
      'lib/theme/widgets/tonos_expansion_tile_scope.dart',
      'local_theme',
    );
    expect(expansionTileScopeRule?.id, 'theme-system');
    expect(expansionTileScopeRule?.status, 'migrated');
  });

  test('history summary recipes have exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'history-summary-recipes',
    );

    expect(rule.pattern, 'lib/widgets/history_summary_widget.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(rule.rationale, contains('lazy range loading'));
    expect(
      inventory
          .ruleFor('lib/widgets/history_summary_widget.dart', 'shadow')
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'history-summary-recipes')
            .toList();
    expect(findings, hasLength(10));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('workout history calendar recipes have exact ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'workout-history-calendar-recipes',
    );

    expect(rule.pattern, 'lib/widgets/workout_history_calendar.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(
      inventory
          .ruleFor('lib/widgets/workout_history_calendar.dart', 'shadow')
          ?.id,
      isNot('workout-history-calendar-recipes'),
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'workout-history-calendar-recipes',
            )
            .toList();
    expect(findings, hasLength(19));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('workout dashboard D2 recipe has exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'workout-dashboard-recipes',
    );

    expect(rule.pattern, 'lib/widgets/workout_dashboard.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(rule.rationale, contains('D2'));
    expect(
      inventory.ruleFor('lib/widgets/workout_dashboard.dart', 'shadow')?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'workout-dashboard-recipes')
            .toList();
    expect(findings, hasLength(8));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('data records D2 recipe has exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'data-records-recipes',
    );

    expect(rule.pattern, 'lib/widgets/data_records_section.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
      ]),
    );
    expect(rule.rationale, contains('D2'));
    expect(
      inventory.ruleFor('lib/widgets/data_records_section.dart', 'shadow')?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'data-records-recipes')
            .toList();
    expect(findings, hasLength(4));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('PresetsLoaded recipes have exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'presets-loaded-recipes',
    );

    expect(rule.pattern, 'lib/widgets/presets_loaded.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>['color_transform', 'geometry', 'text_style']),
    );
    expect(rule.rationale, contains('four-mode rendered contract'));
    expect(
      inventory.ruleFor('lib/widgets/presets_loaded.dart', 'decoration')?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'presets-loaded-recipes')
            .toList();
    expect(findings, hasLength(6));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('exercise info title keeps bold emphasis under Material ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/exercise_definition_info_tile.dart',
      'text_style',
    );

    expect(rule?.id, 'exercise-definition-info-title');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['text_style']));
    expect(
      rule?.rationale,
      contains('No new token is warranted for this one-off emphasis'),
    );
    expect(
      inventory
          .ruleFor(
            'lib/widgets/exercise_definition_info_tile.dart',
            'decoration',
          )
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'exercise-definition-info-title',
            )
            .toList();
    expect(findings, hasLength(1));
    expect(findings.single.kind, 'text_style');
    expect(findings.single.status, 'migrated');
  });

  test('plan-builder coach styles have exact four-mode ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/onboarding_plan_builder_coach.dart',
      'decoration',
    );

    expect(rule?.id, 'plan-builder-coach-recipes');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
      ]),
    );
    expect(rule?.rationale, contains('four-mode production-widget contract'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'plan-builder-coach-recipes')
            .toList();
    expect(findings, hasLength(6));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'color_transform',
        'decoration',
        'decoration',
        'geometry',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('Stretch Search fields inherit exact Tonos dialog ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/stretch_search_dialog.dart',
      'decoration',
    );

    expect(rule?.id, 'stretch-search-dialog-controls');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['decoration']));
    expect(rule?.rationale, contains('four-mode rendered contract'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'stretch-search-dialog-controls',
            )
            .toList();
    expect(findings, hasLength(2));
    expect(findings.map((finding) => finding.kind), everyElement('decoration'));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('set stat chip owns its exact token-backed surface decoration', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/set_stat_chip.dart',
      'decoration',
    );

    expect(rule?.id, 'set-stat-chip-surface');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, ['decoration']);
    expect(rule?.rationale, contains('AppSurfaceTokens.metricChip'));
    expect(
      inventory.ruleFor('lib/widgets/set_stat_chip.dart', 'text_style')?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'set-stat-chip-surface')
            .toList();
    expect(findings, hasLength(1));
    expect(findings.single.kind, 'decoration');
    expect(findings.single.status, 'migrated');
  });

  test('past-session label has exact Material foreground ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/past_sessions_list.dart',
      'text_style',
    );

    expect(rule?.id, 'past-sessions-filter-label');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, ['text_style']);
    expect(rule?.rationale, contains('ColorScheme.onSurface'));
    expect(
      inventory
          .ruleFor('lib/widgets/past_sessions_list.dart', 'decoration')
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(1));
    expect(findings.single.kind, 'text_style');
    expect(findings.single.status, 'migrated');
  });

  test('cardio and stretch action colors have exact semantic ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );

    final cardioRule = inventory.ruleFor(
      'lib/widgets/cardio_card.dart',
      'color',
    );
    expect(cardioRule?.id, 'cardio-timer-semantic-colors');
    expect(cardioRule?.classification, 'tonos_semantic');
    expect(cardioRule?.status, 'migrated');
    expect(cardioRule?.kinds, ['color']);
    final cardioFindings =
        report.findings
            .where((finding) => finding.ruleId == cardioRule?.id)
            .toList();
    expect(cardioFindings, hasLength(2));
    expect(
      cardioFindings.map((finding) => finding.status),
      everyElement('migrated'),
    );

    final stretchRule = inventory.ruleFor(
      'lib/widgets/stretch_card.dart',
      'color',
    );
    expect(stretchRule?.id, 'stretch-add-semantic-color');
    expect(stretchRule?.classification, 'tonos_semantic');
    expect(stretchRule?.status, 'migrated');
    expect(stretchRule?.kinds, ['color']);
    final stretchFindings =
        report.findings
            .where((finding) => finding.ruleId == stretchRule?.id)
            .toList();
    expect(stretchFindings, hasLength(1));
    expect(stretchFindings.single.status, 'migrated');

    expect(
      inventory.ruleFor('lib/widgets/cardio_card.dart', 'decoration')?.id,
      'release-widgets',
    );
    expect(
      inventory.ruleFor('lib/widgets/stretch_card.dart', 'decoration')?.id,
      'release-widgets',
    );
  });

  test(
    'bodypart focus chips separate semantic colors from component recipe',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );

      final semanticRule = inventory.ruleFor(
        'lib/widgets/bodypart_focus_chips.dart',
        'color',
      );
      expect(semanticRule?.id, 'bodypart-focus-semantic-status');
      expect(semanticRule?.classification, 'tonos_semantic');
      expect(semanticRule?.status, 'migrated');
      expect(semanticRule?.kinds, ['color']);
      final semanticFindings =
          report.findings
              .where((finding) => finding.ruleId == semanticRule?.id)
              .toList();
      expect(semanticFindings, hasLength(2));
      expect(
        semanticFindings.map((finding) => finding.status),
        everyElement('migrated'),
      );

      final recipeRule = inventory.ruleFor(
        'lib/widgets/bodypart_focus_chips.dart',
        'text_style',
      );
      expect(recipeRule?.id, 'bodypart-focus-chip-recipe');
      expect(recipeRule?.classification, 'structural_theme');
      expect(recipeRule?.status, 'migrated');
      expect(
        recipeRule?.kinds,
        unorderedEquals(<String>['geometry', 'text_style']),
      );
      final recipeFindings =
          report.findings
              .where((finding) => finding.ruleId == recipeRule?.id)
              .toList();
      expect(recipeFindings, hasLength(4));
      expect(
        recipeFindings.map((finding) => finding.kind),
        unorderedEquals(<String>[
          'geometry',
          'text_style',
          'text_style',
          'text_style',
        ]),
      );
      expect(
        recipeFindings.map((finding) => finding.status),
        everyElement('migrated'),
      );
      expect(
        inventory
            .ruleFor('lib/widgets/bodypart_focus_chips.dart', 'decoration')
            ?.id,
        'release-widgets',
      );
    },
  );

  test('preset info metric surfaces have exact token ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/preset_info_card.dart',
      'decoration',
    );
    expect(rule?.id, 'preset-info-card-metric-recipe');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['decoration', 'geometry']));
    expect(rule?.rationale, contains('AppSurfaceTokens.card'));
    expect(rule?.rationale, contains('AppShapeTokens.metric'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule?.id).toList();
    expect(findings, hasLength(2));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['decoration', 'geometry']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      inventory.ruleFor('lib/widgets/preset_info_card.dart', 'text_style')?.id,
      'release-widgets',
    );
  });

  test('session completion recipes have exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'session-completion-recipes',
    );

    expect(rule.pattern, 'lib/widgets/session_complete_sheet.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(rule.rationale, contains('Classic/Neo light/dark'));
    expect(
      inventory
          .ruleFor('lib/widgets/session_complete_sheet.dart', 'shadow')
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'session-completion-recipes')
            .toList();
    expect(findings, hasLength(16));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('flow dropdown foregrounds have exact Material ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'flow-screen-dropdown-foreground',
    );

    expect(rule.pattern, 'lib/widgets/flow_screen_widgets.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(rule.kinds, ['text_style']);
    expect(rule.rationale, contains('ColorScheme.onSurface'));
    expect(
      inventory
          .ruleFor('lib/widgets/flow_screen_widgets.dart', 'decoration')
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(6));
    expect(findings.map((finding) => finding.kind), everyElement('text_style'));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('recommended-sets dialog shares exact form and error ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'recommended-sets-dialog-controls',
    );

    expect(rule.pattern, 'lib/widgets/recommended_sets_editor_dialog.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(rule.kinds, unorderedEquals(['decoration', 'text_style']));
    expect(rule.rationale, contains('TonosDialogFrame'));
    expect(
      inventory
          .ruleFor(
            'lib/widgets/recommended_sets_editor_dialog.dart',
            'geometry',
          )
          ?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule.id).toList();
    expect(findings, hasLength(3));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test(
    'Current Metrics data colors and marker remain narrowly allowlisted',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      final rule = inventory.pathRules.singleWhere(
        (rule) => rule.id == 'current-metrics-category-colors',
      );

      expect(rule.pattern, 'lib/widgets/current_metrics_section.dart');
      expect(rule.classification, 'stable_category_data');
      expect(rule.status, 'allowlisted');
      expect(rule.kinds, unorderedEquals(<String>['color']));
      expect(rule.rationale, contains('four-mode rendered-color regression'));
      final markerRule = inventory.pathRules.singleWhere(
        (rule) => rule.id == 'current-metrics-category-marker',
      );
      expect(markerRule.pattern, 'lib/widgets/current_metrics_section.dart');
      expect(markerRule.classification, 'stable_category_data');
      expect(markerRule.status, 'allowlisted');
      expect(markerRule.kinds, unorderedEquals(<String>['decoration']));

      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings =
          report.findings
              .where(
                (finding) =>
                    finding.ruleId == 'current-metrics-category-colors',
              )
              .toList();
      expect(findings, hasLength(5));
      expect(
        findings.map((finding) => finding.status),
        everyElement('allowlisted'),
      );

      final markerFindings =
          report.findings
              .where(
                (finding) =>
                    finding.file ==
                        'lib/widgets/current_metrics_section.dart' &&
                    finding.ruleId == 'current-metrics-category-marker',
              )
              .toList();
      expect(markerFindings, hasLength(1));
      expect(markerFindings.single.kind, 'decoration');
      expect(markerFindings.single.status, 'allowlisted');

      final pendingMetricsStyles = report.findings.where(
        (finding) =>
            finding.file == 'lib/widgets/current_metrics_section.dart' &&
            finding.status == 'pending',
      );
      expect(pendingMetricsStyles, isEmpty);
    },
  );

  test(
    'TonosBottomNavigationBar owns exactly four migrated theme candidates',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      final rule = inventory.pathRules.singleWhere(
        (rule) => rule.id == 'tonos-bottom-navigation',
      );
      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings =
          report.findings
              .where((finding) => finding.ruleId == 'tonos-bottom-navigation')
              .toList();

      expect(rule.pattern, 'lib/widgets/tonos_bottom_navigation_bar.dart');
      expect(rule.classification, 'theme_system');
      expect(rule.status, 'migrated');
      expect(
        rule.kinds,
        unorderedEquals(<String>['color', 'decoration', 'geometry', 'shadow']),
      );
      expect(findings, hasLength(4));
      expect(
        findings.map((finding) => finding.kind).toSet(),
        unorderedEquals(<String>{'color', 'decoration', 'geometry', 'shadow'}),
      );
      expect(findings.every((finding) => finding.status == 'migrated'), isTrue);
    },
  );

  test(
    'Train tab geometry is narrowly token-owned and queued as navigation',
    () {
      final inventory = loadThemeStyleInventory(
        'docs/theme-style-inventory.json',
      );
      final rule = inventory.pathRules.singleWhere(
        (rule) => rule.id == 'tonos-train-tabs-geometry',
      );
      final report = scanThemeStyleInventory(
        root: Directory('lib'),
        inventory: inventory,
      );
      final findings =
          report.findings
              .where((finding) => finding.ruleId == 'tonos-train-tabs-geometry')
              .toList();
      final matchingQueues =
          inventory.reviewQueue
              .where(
                (queue) => queue.matches('lib/widgets/tonos_train_tabs.dart'),
              )
              .toList();

      expect(rule.pattern, 'lib/widgets/tonos_train_tabs.dart');
      expect(rule.classification, 'theme_system');
      expect(rule.status, 'migrated');
      expect(rule.kinds, unorderedEquals(<String>['geometry']));
      expect(findings, hasLength(4));
      expect(findings.every((finding) => finding.status == 'migrated'), isTrue);
      expect(matchingQueues, hasLength(1));
      expect(matchingQueues.single.id, 'navigation-anatomy-support');
    },
  );

  test('Train tab presentation recipes have an exact migrated owner', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'tonos-train-tabs-recipes',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'tonos-train-tabs-recipes')
            .toList();

    expect(rule.pattern, 'lib/widgets/tonos_train_tabs.dart');
    expect(rule.classification, 'theme_system');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'shadow',
      ]),
    );
    expect(findings, hasLength(4));
    expect(
      findings.map((finding) => finding.kind).toSet(),
      unorderedEquals(<String>{
        'color',
        'color_transform',
        'decoration',
        'shadow',
      }),
    );
    expect(findings.every((finding) => finding.status == 'migrated'), isTrue);
    expect(
      inventory.ruleFor('lib/widgets/tonos_train_tabs.dart', 'geometry')?.id,
      'tonos-train-tabs-geometry',
    );
  });

  test('accepted Health Trends recipes have an exact migrated rule', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'health-trends-recipes',
    );

    expect(rule.pattern, 'lib/widgets/health_trends_section.dart');
    expect(rule.classification, 'structural_theme');
    expect(rule.status, 'migrated');
    expect(
      rule.kinds,
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
      inventory
          .ruleFor('lib/widgets/health_trends_section.dart', 'decoration')
          ?.id,
      'health-trends-recipes',
    );
  });

  test('reviewed flow and Exercise Progress recipes have scoped rules', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );

    final flowMethodsRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'flow-methods-recipes',
    );
    expect(
      flowMethodsRule.pattern,
      'lib/screens/profile/settings/flow_methods_page.dart',
    );
    expect(flowMethodsRule.status, 'migrated');
    expect(
      flowMethodsRule.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );

    final flowMethodsFindings =
        report.findings
            .where((finding) => finding.ruleId == 'flow-methods-recipes')
            .toList();
    expect(flowMethodsFindings, hasLength(20));
    expect(
      flowMethodsFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );

    final workoutFlowsRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'workout-progress-flows-recipes',
    );
    expect(
      workoutFlowsRule.pattern,
      'lib/screens/profile/settings/workout_progress_flows_page.dart',
    );
    expect(workoutFlowsRule.status, 'migrated');
    expect(
      workoutFlowsRule.kinds,
      unorderedEquals(<String>['color_transform', 'decoration', 'geometry']),
    );
    final workoutFlowsFindings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'workout-progress-flows-recipes',
            )
            .toList();
    expect(workoutFlowsFindings, hasLength(18));
    expect(
      workoutFlowsFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );

    final workoutMetricChartRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'workout-metric-chart-recipes',
    );
    expect(
      workoutMetricChartRule.pattern,
      'lib/widgets/workout_metric_chart_card.dart',
    );
    expect(workoutMetricChartRule.status, 'migrated');
    expect(
      workoutMetricChartRule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    final workoutMetricChartFindings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'workout-metric-chart-recipes',
            )
            .toList();
    expect(workoutMetricChartFindings, hasLength(35));
    expect(
      workoutMetricChartFindings.every(
        (finding) => finding.status == 'migrated',
      ),
      isTrue,
    );

    final exerciseProgressRule = inventory.pathRules.singleWhere(
      (rule) => rule.id == 'exercise-progress-chart-recipes',
    );
    expect(
      exerciseProgressRule.pattern,
      'lib/widgets/exercise_progress_section.dart',
    );
    expect(exerciseProgressRule.status, 'migrated');
    expect(
      exerciseProgressRule.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'local_theme',
        'shadow',
        'text_style',
      ]),
    );
    final exerciseProgressFindings =
        report.findings
            .where(
              (finding) => finding.ruleId == 'exercise-progress-chart-recipes',
            )
            .toList();
    expect(exerciseProgressFindings, hasLength(40));
    expect(
      exerciseProgressFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
    final localThemeFindings =
        report.findings
            .where(
              (finding) =>
                  finding.file ==
                      'lib/widgets/exercise_progress_section.dart' &&
                  finding.kind == 'local_theme',
            )
            .toList();
    expect(localThemeFindings, hasLength(2));
    expect(
      localThemeFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
  });

  test('exercise editor hotspot precedes the broad settings rule', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/profile/settings/exercise_editor_screen.dart',
      'decoration',
    );

    expect(rule?.id, 'exercise-editor-hotspot');
    expect(rule?.status, 'pending');
  });

  test('flow event fields use the opted-in dialog form recipe', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/widgets/flow_widgets.dart',
      'decoration',
    );

    expect(rule?.id, 'flow-event-dialog-fields');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['decoration']));
    expect(rule?.rationale, contains('TonosDialogFrame'));
    expect(
      inventory.ruleFor('lib/widgets/flow_widgets.dart', 'text_style')?.id,
      'release-widgets',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings
            .where((finding) => finding.ruleId == 'flow-event-dialog-fields')
            .toList();
    expect(findings, hasLength(2));
    expect(findings.map((finding) => finding.kind), everyElement('decoration'));
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/widgets/automatic_settings_sheet.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
      reason:
          'Automatic Settings styling has a separate four-mode ownership contract.',
    );
  });

  test('Food Customization recipes have exact, kind-limited ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/nutrition/food_customization_page.dart',
      'geometry',
    );

    expect(rule?.id, 'food-customization-expansion-recipes');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['geometry', 'text_style']));
    expect(rule?.rationale, contains('four-mode production-page contract'));
    expect(
      inventory
          .ruleFor(
            'lib/screens/nutrition/food_customization_page.dart',
            'decoration',
          )
          ?.id,
      'food-customization-unit-dropdown-material-recipe',
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(9));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'geometry',
        'text_style',
        'text_style',
        'text_style',
        'text_style',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));

    final dropdownRule = inventory.ruleFor(
      'lib/screens/nutrition/food_customization_page.dart',
      'decoration',
    );
    expect(dropdownRule?.classification, 'material_component');
    expect(dropdownRule?.status, 'migrated');
    expect(dropdownRule?.kinds, <String>['decoration']);
    expect(
      dropdownRule?.rationale,
      contains('four-mode production-page contract'),
    );
    final dropdownFindings =
        report.findings
            .where((finding) => finding.ruleId == dropdownRule!.id)
            .toList();
    expect(dropdownFindings, hasLength(1));
    expect(dropdownFindings.single.kind, 'decoration');
    expect(dropdownFindings.single.status, 'migrated');
  });

  test('UI Appearance family previews have exact recipe ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/profile/settings/ui_appearance_settings_page.dart',
      'decoration',
    );

    expect(rule?.id, 'ui-appearance-theme-family-previews');
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
      ]),
    );
    expect(
      rule?.rationale,
      contains('light/dark production-selector contract'),
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(7));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'decoration',
        'geometry',
        'geometry',
        'geometry',
        'color',
        'shadow',
        'color_transform',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
  });

  test('Gym Profile recipes have exact four-mode ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/exercise/gym_profile_screen.dart',
      'geometry',
    );

    expect(rule?.id, 'gym-profile-four-mode-recipes');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>[
        'color',
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(rule?.rationale, contains('four-mode rendered GymProfileScreen'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(39));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'color',
        ...List<String>.filled(14, 'color_transform'),
        ...List<String>.filled(7, 'decoration'),
        ...List<String>.filled(16, 'geometry'),
        'text_style',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/screens/exercise/gym_profile_screen.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  test('Food Logging recipes have exact four-mode ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/nutrition/food_logging_page.dart',
      'component_style',
    );

    expect(rule?.id, 'food-logging-four-mode-recipes');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'component_style',
        'decoration',
        'geometry',
      ]),
    );
    expect(rule?.rationale, contains('four-mode production-flow contract'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(17));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        ...List<String>.filled(4, 'color_transform'),
        ...List<String>.filled(3, 'component_style'),
        ...List<String>.filled(3, 'decoration'),
        ...List<String>.filled(7, 'geometry'),
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/screens/nutrition/food_logging_page.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  test('Log Entry recipes have exact four-mode ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/nutrition/log_entry_page.dart',
      'decoration',
    );

    expect(rule?.id, 'nutrition-log-entry-four-mode-recipes');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(
      rule?.kinds,
      unorderedEquals(<String>[
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(
      rule?.rationale,
      contains('four-mode rendered LogEntryPage contract'),
    );
    expect(rule?.rationale, contains('does not claim device review'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(8));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        'color_transform',
        ...List<String>.filled(3, 'decoration'),
        ...List<String>.filled(3, 'geometry'),
        'text_style',
      ]),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/screens/nutrition/log_entry_page.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  test('barcode scanner camera contrast stays a narrow one-off allowlist', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor(
      'lib/screens/nutrition/barcode_scanner_page.dart',
      'color',
    );

    expect(rule?.id, 'barcode-scanner-theme-independent-camera-ui');
    expect(rule?.classification, 'intentional_one_off');
    expect(rule?.status, 'allowlisted');
    expect(
      rule?.kinds,
      unorderedEquals(<String>[
        'color',
        'color_literal',
        'color_literal_candidate',
        'color_transform',
        'decoration',
        'geometry',
        'text_style',
      ]),
    );
    expect(rule?.rationale, contains('live camera image'));
    expect(rule?.rationale, contains('does not exempt scanner lifecycle'));

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(12));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>[
        ...List<String>.filled(5, 'color'),
        'color_literal',
        'color_literal_candidate',
        'color_transform',
        'decoration',
        ...List<String>.filled(2, 'geometry'),
        'text_style',
      ]),
    );
    expect(
      findings.map((finding) => finding.status),
      everyElement('allowlisted'),
    );
    expect(
      report.findings.where(
        (finding) =>
            finding.file == 'lib/screens/nutrition/barcode_scanner_page.dart' &&
            finding.status == 'pending',
      ),
      isEmpty,
    );
  });

  test('PresetBar rename and automatic badge have exact theme ownership', () {
    final inventory = loadThemeStyleInventory(
      'docs/theme-style-inventory.json',
    );
    final rule = inventory.ruleFor('lib/widgets/preset_bar.dart', 'decoration');

    expect(rule?.id, 'preset-bar-rename-and-badge');
    expect(rule?.classification, 'structural_theme');
    expect(rule?.status, 'migrated');
    expect(rule?.kinds, unorderedEquals(<String>['decoration', 'text_style']));
    expect(rule?.rationale, contains('TonosDialogFrame'));
    expect(rule?.rationale, contains('automaticPlanBadge'));
    expect(
      inventory.ruleFor('lib/widgets/preset_bar.dart', 'text_style')?.id,
      rule?.id,
    );

    final report = scanThemeStyleInventory(
      root: Directory('lib'),
      inventory: inventory,
    );
    final findings =
        report.findings.where((finding) => finding.ruleId == rule!.id).toList();
    expect(findings, hasLength(2));
    expect(
      findings.map((finding) => finding.kind),
      unorderedEquals(<String>['decoration', 'text_style']),
    );
    expect(findings.map((finding) => finding.status), everyElement('migrated'));
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
    final localThemeFindings =
        report.findings
            .where((finding) => finding.kind == 'local_theme')
            .toList();
    expect(localThemeFindings, isNotEmpty);
    expect(
      localThemeFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
      reason: 'Every local Theme scope must have verified theme ownership.',
    );
    expect(
      report.findings.where(
        (finding) => finding.file == 'lib/widgets/meal_plan_add_bar.dart',
      ),
      isEmpty,
      reason:
          'MealPlanAddBar delegates style ownership to TonosSegmentedActionBar',
    );
    final exerciseEditorFindings =
        report.findings
            .where(
              (finding) =>
                  finding.file ==
                  'lib/screens/profile/settings/exercise_editor_screen.dart',
            )
            .toList();
    expect(exerciseEditorFindings, isNotEmpty);
    expect(
      exerciseEditorFindings.every(
        (finding) => finding.ruleId == 'exercise-editor-hotspot',
      ),
      isTrue,
    );

    final queueCoverage = report.reviewQueueCoverage;
    expect(report.toJson()['reviewQueueCoverage'], queueCoverage);
    expect(
      report.toText(),
      contains('Pending candidates without a review queue: 0'),
    );
    expect(queueCoverage['candidateCount'], report.findings.length);
    expect(queueCoverage['overlappingCandidateCount'], 0);
    expect(queueCoverage['pendingOutsideQueueCandidateCount'], 0);
    final uniqueQueueCount =
        queueCoverage['uniquelyAssignedCandidateCount'] as int;
    final outsideQueueCount =
        queueCoverage['outsideQueueCandidateCount'] as int;
    final overlapCount = queueCoverage['overlappingCandidateCount'] as int;
    expect(
      uniqueQueueCount + outsideQueueCount + overlapCount,
      report.findings.length,
    );
    final queueRows =
        (queueCoverage['queues'] as List).cast<Map<String, dynamic>>();
    expect(queueRows, hasLength(inventory.reviewQueue.length));
    for (final queue in queueRows) {
      final statusCounts = queue['countsByStatus'] as Map<String, int>;
      expect(
        statusCounts.values.fold<int>(0, (sum, count) => sum + count),
        queue['candidateCount'],
      );
    }
    final badgeFindings =
        report.findings
            .where((finding) => finding.ruleId == 'workout-record-badges')
            .toList();
    expect(badgeFindings, hasLength(6));
    expect(
      badgeFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
    final settingsAccentFindings =
        report.findings
            .where((finding) => finding.ruleId == 'settings-category-accents')
            .toList();
    expect(settingsAccentFindings, hasLength(16));
    expect(
      settingsAccentFindings.every(
        (finding) => finding.status == 'allowlisted',
      ),
      isTrue,
    );
    final settingsRecipeFindings =
        report.findings
            .where((finding) => finding.ruleId == 'settings-tiles-recipes')
            .toList();
    expect(settingsRecipeFindings, hasLength(99));
    expect(
      settingsRecipeFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
    final settingsLocalThemeFindings =
        report.findings
            .where((finding) => finding.ruleId == 'settings-tiles-local-theme')
            .toList();
    expect(settingsLocalThemeFindings, hasLength(2));
    expect(
      settingsLocalThemeFindings.every(
        (finding) => finding.status == 'migrated',
      ),
      isTrue,
    );
    final healthTrendFindings =
        report.findings
            .where((finding) => finding.ruleId == 'health-trends-recipes')
            .toList();
    expect(healthTrendFindings, hasLength(29));
    expect(
      healthTrendFindings.every((finding) => finding.status == 'migrated'),
      isTrue,
    );
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
