import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical E2.1 route ledger remains complete and schema-shaped', () {
    final ledger = File('docs/theme-e2-route-ledger.md').readAsStringSync();
    final rows =
        ledger
            .split(RegExp(r'\r?\n'))
            .where((line) => RegExp(r'^\| R\d+ \|').hasMatch(line))
            .toList();
    final fields =
        rows
            .map((row) => row.split('|').map((field) => field.trim()).toList())
            .toList();

    const expectedDestinations = [
      'lib/main.dart: _StartupGate, OnboardingFlow, MainScreen',
      'lib/screens/exercise/train_page.dart: TrainPage',
      'lib/screens/exercise/session_screen.dart: SessionScreen',
      'lib/screens/exercise/preset_detail_screen.dart: PresetDetailScreen',
      'lib/screens/exercise/preset_generation_qa.dart: PresetGenerationQaScreen',
      'lib/screens/exercise/optimized_workout_settings_page.dart: OptimizedWorkoutSettingsPage',
      'lib/screens/exercise/gym_profile_screen.dart: GymProfileScreen',
      'lib/screens/exercise/plan_management_page.dart: PlanManagementPage',
      'lib/screens/exercise/premade_plans_page.dart: PremadePlansPage',
      'lib/screens/exercise/analytics_dashboard_screen.dart: AnalyticsDashboardScreen',
      'lib/screens/catalog_page.dart: CatalogPage',
      'lib/screens/exercise/exercise_catalog_page.dart: ExerciseCatalogPage',
      'lib/screens/exercise/muscle_filter_page.dart: MuscleFilterPage',
      'lib/screens/exercise/definitions_by_bodypart_page.dart: DefinitionsByBodyPartPage',
      'lib/screens/exercise/definitions_by_muscle_page.dart: DefinitionsByMusclePage',
      'lib/widgets/exercise_detail_sheet.dart: ExerciseDetailSheet',
      'lib/widgets/exercise_media_thumbnail.dart, lib/widgets/shared_entity_media_thumbnail.dart, lib/theme/widgets/media_viewer_image.dart',
      'lib/screens/exercise/full_history_screen.dart: FullHistoryScreen',
      'lib/screens/exercise/session_detail_screen.dart: SessionDetailScreen',
      'lib/screens/exercise/history_screen.dart, lib/widgets/history_content.dart',
      'lib/screens/dashboard_page.dart, lib/widgets/dashboard_sections.dart: DashboardPage',
      'lib/screens/measurement_trends_page.dart: MeasurementsTrendsPage',
      'lib/widgets/health_trends_section.dart: MeasurementTrendDetailPage',
      'lib/widgets/exercise_progress_section.dart: _ExerciseProgressDetailPage',
      'lib/screens/nutrition/nutrition_page.dart: NutritionPage',
      'lib/screens/nutrition/food_logging_page.dart: FoodLoggingPage',
      'lib/screens/nutrition/food_customization_page.dart: FoodCustomizationPage',
      'lib/screens/nutrition/barcode_scanner_page.dart: BarcodeScannerPage',
      'lib/screens/nutrition/measured_items_page.dart: MeasuredItemsPage',
      'lib/screens/nutrition/log_entry_page.dart: LogEntryPage',
      'lib/screens/profile/settings/diet_nutrition_settings_page.dart: DietNutritionSettingsPage',
      'lib/screens/profile/settings/goal_manual_entry_page.dart: GoalManualEntryPage',
      'lib/screens/nutrition/pantry_log_page.dart: PantryLogPage',
      'lib/screens/nutrition/plan_meal_page.dart: PlanMealPage',
      'lib/screens/profile/settings/profile_page.dart: ProfilePage',
      'lib/screens/profile/settings/user_information_settings_page.dart: UserInformationSettingsPage',
      'lib/screens/profile/settings/ui_appearance_settings_page.dart: UIAppearanceSettingsPage',
      'lib/screens/profile/settings/nav_bar_settings_page.dart: NavBarSettingsPage',
      'lib/screens/profile/settings/tutorials_settings_page.dart: TutorialsSettingsPage',
      'lib/screens/profile/settings/gym_exercise_settings_page.dart: GymExerciseSettingsPage',
      'lib/screens/profile/settings/analytics_setting_screen.dart: AnalyticsSettingsScreen',
      'lib/screens/profile/settings/bodypart_ranking_screen.dart: BodyPartRankingScreen',
      'lib/screens/profile/settings/muscle_ranking_screen.dart: MuscleRankingScreen',
      'lib/screens/profile/settings/volume_boundaries_screen.dart: VolumeBoundariesScreen',
      'lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart: BodyPartMuscleMappingScreen',
      'lib/screens/profile/settings/exercise_analytics_screen.dart: ExerciseAnalyticsScreen',
      'lib/screens/profile/settings/exercise_editor_screen.dart: ExerciseEditorScreen',
      'lib/screens/profile/settings/flow_methods_page.dart: FlowMethodsPage',
      'lib/screens/profile/settings/workout_progress_flows_page.dart: WorkoutProgressFlowsPage',
      'lib/screens/exercise/auto_preset_flow_screen.dart: AutoPresetFlowScreen',
      'lib/screens/profile/settings/database_settings_page.dart: DatabaseSettingsPage',
      'lib/screens/profile/settings/diagnostics_settings_page.dart: DiagnosticsSettingsPage',
      'lib/screens/nutrition_log_page.dart: NutritionLogPage',
      'lib/screens/combined_history_page.dart: CombinedHistoryPage',
      'lib/screens/form_posing_page.dart: FormPosingPage',
      'lib/theme/theme_lab_page.dart: ThemeLabPage',
      'lib/screens/onboarding_flow.dart: PremadePlansPage, PresetGenerationQaScreen, PresetDetailScreen, GymProfileScreen callers',
      'lib/screens/profile/settings/app_settings_page.dart: AppSettingsPage',
      'lib/screens/nutrition/default_trend_page.dart: DefaultTrendPage',
      'lib/widgets/health_trends_section.dart: _MeasurementDefinitionDialog and entry/delete dialogs',
      'lib/widgets/ongoing_session_fab.dart, lib/screens/exercise/session_screen.dart: exit/finish dialogs and sheets',
      'lib/screens/dashboard_page.dart: edit/restore dialog; lib/widgets/dashboard_sections.dart action routes',
      'lib/screens/profile/settings/database_settings_page.dart, lib/screens/profile/settings/exercise_editor_screen.dart, lib/screens/profile/settings/flow_methods_page.dart: confirmation/editor dialogs',
      'lib/screens/exercise/train2_page.dart: Train2Page',
      'lib/screens/profile/settings/measurements_trends_settings_page.dart: MeasurementsTrendsSettingsPage',
    ];

    expect(rows, hasLength(expectedDestinations.length));
    expect(fields, everyElement(hasLength(12)));
    for (var index = 0; index < fields.length; index++) {
      final expectedId = 'R${index.toString().padLeft(2, '0')}';
      expect(fields[index][1], expectedId);
      expect(fields[index][3], expectedDestinations[index]);
      expect(fields[index][0], isEmpty);
      expect(fields[index][11], isEmpty);
      expect(fields[index].join('|').contains('__'), isFalse);

      final paths = RegExp(
        r'lib/[^ ,;:]+\.dart',
      ).allMatches(fields[index][3]).map((match) => match.group(0)!);
      expect(paths, isNotEmpty, reason: fields[index][3]);
      for (final path in paths) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }

    expect(ledger, contains('### Canonical E2.1 Route Matrix'));
    expect(ledger, contains('Outstanding checks / decision'));
    expect(
      ledger,
      isNot(contains('all release callers need final reachability audit')),
    );
  });

  test(
    'nested source edges remain represented by current constructor callers',
    () {
      const requiredEdges = <String, List<String>>{
        'lib/main.dart': [
          'TrainPage',
          'Train2Page',
          'CatalogPage',
          'HistoryScreen',
          'MeasurementsTrendsPage',
          'ProfilePage',
          'DashboardPage',
          'NutritionPage',
          'NutritionLogPage',
          'CombinedHistoryPage',
          'FormPosingPage',
        ],
        'lib/screens/exercise/train_page.dart': [
          'PresetDetailScreen',
          'PresetGenerationQaScreen',
          'SessionScreen',
          'OptimizedWorkoutSettingsPage',
          'GymProfileScreen',
          'AnalyticsDashboardScreen',
          'PlanManagementPage',
          'PremadePlansPage',
        ],
        'lib/screens/exercise/train2_page.dart': [
          'PresetDetailScreen',
          'PresetGenerationQaScreen',
          'SessionScreen',
          'GymProfileScreen',
          'ExerciseCatalogPage',
          'MuscleFilterPage',
        ],
        'lib/widgets/dashboard_sections.dart': [
          'SessionScreen',
          'AnalyticsDashboardScreen',
          'PlanManagementPage',
          'PremadePlansPage',
          'PresetDetailScreen',
          'PresetGenerationQaScreen',
          'MeasuredItemsPage',
        ],
        'lib/screens/nutrition/nutrition_page.dart': [
          'FoodLoggingPage',
          'MeasuredItemsPage',
          'LogEntryPage',
          'DietNutritionSettingsPage',
        ],
        'lib/screens/profile/settings/profile_page.dart': [
          'UserInformationSettingsPage',
          'UIAppearanceSettingsPage',
          'TutorialsSettingsPage',
          'GymExerciseSettingsPage',
          'MeasurementsTrendsSettingsPage',
          'DatabaseSettingsPage',
          'DiagnosticsSettingsPage',
        ],
        'lib/screens/profile/settings/exercise_editor_screen.dart': [
          'ExerciseCatalogPage',
          'ExerciseAnalyticsScreen',
        ],
        'lib/screens/profile/settings/diet_nutrition_settings_page.dart': [
          'GoalManualEntryPage',
        ],
        'lib/screens/profile/settings/workout_progress_flows_page.dart': [
          'AutoPresetFlowScreen',
        ],
        'lib/screens/exercise/definitions_by_bodypart_page.dart': [
          'DefinitionsByMusclePage',
        ],
        'lib/screens/exercise/definitions_by_muscle_page.dart': [
          'DefinitionsByBodyPartPage',
        ],
        'lib/screens/exercise/full_history_screen.dart': [
          'SessionDetailScreen',
        ],
        'lib/screens/exercise/session_detail_screen.dart': ['SessionScreen'],
        'lib/widgets/exercise_detail_sheet.dart': ['SessionDetailScreen'],
        'lib/screens/nutrition/food_logging_page.dart': [
          'FoodCustomizationPage',
          'BarcodeScannerPage',
        ],
        'lib/widgets/meal_plan_add_bar.dart': ['PantryLogPage', 'PlanMealPage'],
      };

      for (final entry in requiredEdges.entries) {
        final source = _withoutComments(File(entry.key).readAsStringSync());
        for (final destination in entry.value) {
          expect(
            _hasNavigationConstructor(source, destination),
            isTrue,
            reason: '${entry.key} should retain its $destination caller edge.',
          );
        }
      }
    },
  );

  test('ledger evidence paths remain present in the repository', () {
    const evidencePaths = [
      'test/providers/app_configuration_test.dart',
      'test/screens/measured_items_page_test.dart',
      'test/screens/onboarding_and_plan_flow_test.dart',
      'test/theme/barcode_scanner_route_test.dart',
      'test/theme/dashboard_history_contract_test.dart',
      'test/theme/dashboard_history_tokens_test.dart',
      'test/theme/e2_route_ledger_contract_test.dart',
      'test/theme/n5_route_state_contract_test.dart',
      'test/theme/settings_residue_contract_test.dart',
      'test/theme/exercise_detail_contract_test.dart',
      'test/theme/food_logging_behavior_test.dart',
      'test/theme/health_measurements_contract_test.dart',
      'test/theme/health_measurements_tokens_test.dart',
      'test/theme/media_viewer_test.dart',
      'test/theme/nutrition_presentation_test.dart',
      'test/theme/nutrition_goals_behavior_test.dart',
      'test/theme/pre_q2_route_evidence_test.dart',
      'test/theme/theme_lab_page_test.dart',
      'test/theme/tonos_theme_ready_test.dart',
      'test/theme/tutorial_presentation_test.dart',
      'test/theme/widgets/exercise_progress_responsive_test.dart',
      'test/theme/widgets/settings_tiles_test.dart',
      'test/theme/widgets/tonos_sheet_test.dart',
      'test/theme/widgets/workout_metric_chart_card_responsive_test.dart',
    ];

    for (final path in evidencePaths) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}

bool _hasNavigationConstructor(String source, String destination) {
  final escapedDestination = RegExp.escape(destination);
  final edgePatterns = [
    RegExp(
      r'(?:builder|pageBuilder|home|child|_open|_openEditor)\s*[:(][\s\S]{0,180}?\b' +
          escapedDestination +
          r'\s*\(',
    ),
    RegExp(r'(?:=>|return\s+)(?:const\s+)?\b' + escapedDestination + r'\s*\('),
  ];
  return edgePatterns.any((pattern) => pattern.hasMatch(source));
}

String _withoutComments(String source) {
  return source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\r\n]*'), '');
}
