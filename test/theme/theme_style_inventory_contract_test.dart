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
