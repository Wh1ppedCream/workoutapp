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
  });

  test('profile settings callers retain shared presentation boundaries', () {
    final profilePage = _read('lib/screens/profile/settings/profile_page.dart');
    final analyticsSettings = _read(
      'lib/screens/profile/settings/analytics_setting_screen.dart',
    );
    final exerciseEditor = _read(
      'lib/screens/profile/settings/exercise_editor_screen.dart',
    );

    expect(profilePage, contains('UIAppearanceSettingsPage'));
    expect(profilePage, contains('TutorialsSettingsPage'));
    expect(profilePage, contains('DatabaseSettingsPage'));
    expect(analyticsSettings, contains('ExerciseAnalyticsScreen'));
    expect(exerciseEditor, contains('context.mediaTokens'));
  });
}

String _read(String path) => File(path).readAsStringSync();
