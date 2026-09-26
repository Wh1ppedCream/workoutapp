import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nutrition callers retain the food-flow route graph', () {
    final nutritionPage = _read('lib/screens/nutrition/nutrition_page.dart');
    final foodLoggingPage = _read(
      'lib/screens/nutrition/food_logging_page.dart',
    );
    final mealPlanAddBar = _read('lib/widgets/meal_plan_add_bar.dart');

    expect(nutritionPage, contains('FoodLoggingPage'));
    expect(foodLoggingPage, contains('FoodCustomizationPage'));
    expect(foodLoggingPage, contains('BarcodeScannerPage'));
    expect(mealPlanAddBar, contains('PantryLogPage'));
    expect(mealPlanAddBar, contains('FoodLoggingPage'));
    expect(mealPlanAddBar, contains('PlanMealPage'));
    expect(mealPlanAddBar, contains('TonosSegmentedActionBar'));
    expect(mealPlanAddBar, contains('tonosForegroundForSurface'));
  });

  test('profile settings callers retain shared presentation boundaries', () {
    final profilePage = _read('lib/screens/profile/settings/profile_page.dart');
    final appearanceSettings = _read(
      'lib/screens/profile/settings/ui_appearance_settings_page.dart',
    );
    final dialogFrame = _read('lib/theme/widgets/tonos_dialog.dart');
    final analyticsSettings = _read(
      'lib/screens/profile/settings/analytics_setting_screen.dart',
    );
    final exerciseAnalytics = _read(
      'lib/screens/profile/settings/exercise_analytics_screen.dart',
    );
    final databaseSettings = _read(
      'lib/screens/profile/settings/database_settings_page.dart',
    );
    final exerciseEditor = _read(
      'lib/screens/profile/settings/exercise_editor_screen.dart',
    );
    final flowMethods = _read(
      'lib/screens/profile/settings/flow_methods_page.dart',
    );
    final gymSettings = _read(
      'lib/screens/profile/settings/gym_exercise_settings_page.dart',
    );

    expect(profilePage, contains('UIAppearanceSettingsPage'));
    expect(profilePage, contains('TutorialsSettingsPage'));
    expect(profilePage, contains('DatabaseSettingsPage'));
    expect(dialogFrame, contains('dialogButtonForeground'));
    expect(dialogFrame, contains('textButtonTheme'));
    expect(appearanceSettings, contains('TonosChoiceDialog'));
    expect(appearanceSettings, contains('TonosDialogFrame'));
    expect(analyticsSettings, contains('ExerciseAnalyticsScreen'));
    expect(exerciseAnalytics, contains('tonosForegroundForSurface'));
    expect(databaseSettings, contains('TonosDialogFrame'));
    expect(exerciseEditor, contains('context.mediaTokens'));
    expect(exerciseEditor, contains('TonosDialogFrame'));
    expect(flowMethods, contains('TonosDialogFrame'));
    expect(gymSettings, contains('TonosDialogFrame'));
    expect(gymSettings, contains('context.cs.onPrimaryContainer'));
    expect(gymSettings, contains('fillColor'));
    expect(gymSettings, contains('WorkoutExitBehavior'));
  });

  test('workout flow dialogs retain shared presentation boundaries', () {
    final ongoingSessionFab = _read('lib/widgets/ongoing_session_fab.dart');
    final trainPage = _read('lib/screens/exercise/train_page.dart');
    final train2Page = _read('lib/screens/exercise/train2_page.dart');

    expect(ongoingSessionFab, contains('TonosDialogFrame'));
    expect(ongoingSessionFab, contains('sessionCancelQuestion'));
    expect(ongoingSessionFab, contains('sessionEndQuestion'));
    expect(trainPage, contains('TonosDialogFrame'));
    expect(trainPage, contains('trainRestTitle'));
    expect(train2Page, contains('TonosDialogFrame'));
    expect(train2Page, contains('trainOptimizedSettingsTitle'));
    expect(train2Page, contains('trainRestTitle'));
  });

  test('secondary theme-ready consumers keep explicit Neo boundaries', () {
    final themeReadyConsumers = [
      'lib/screens/exercise/definitions_by_bodypart_page.dart',
      'lib/screens/exercise/definitions_by_muscle_page.dart',
      'lib/screens/exercise/full_history_screen.dart',
      'lib/widgets/exercise_definition_info_tile.dart',
      'lib/widgets/cardio_card.dart',
      'lib/widgets/stretch_card.dart',
      'lib/screens/nutrition/default_trend_page.dart',
      'lib/screens/nutrition/food_customization_page.dart',
      'lib/screens/nutrition/food_logging_page.dart',
    ];
    for (final path in themeReadyConsumers) {
      expect(
        _read(path),
        contains('TonosThemeReadyCard'),
        reason: '$path should retain an explicit Classic/Neo card boundary',
      );
    }

    final semanticConsumers = <String, String>{
      'lib/widgets/current_metrics_section.dart': 'dataVisualizationTokens',
      'lib/widgets/nutrition_bar_details.dart': 'surfaceDecorationTokens',
    };
    semanticConsumers.forEach((path, token) {
      expect(
        _read(path),
        contains(token),
        reason: '$path should resolve its Neo presentation through $token',
      );
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
