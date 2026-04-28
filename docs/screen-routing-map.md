# Screen Routing Map

This app currently has some duplicated-looking screen files. Before changing a
feature, prefer the active paths below and verify imports when in doubt.

## App Entry Points

- `lib/main.dart` owns the `MaterialApp`, onboarding gate, `MainScreen`, bottom
  navigation, and the `/main` route.
- `lib/screens/dashboard_page.dart` is the active dashboard tab.
- `lib/screens/onboarding_flow.dart` is the active onboarding flow.

## Active Bottom-Nav Tabs

- Dashboard: `lib/screens/dashboard_page.dart`
- Train: `lib/screens/exercise/train_page.dart`
- History: `lib/screens/exercise/history_screen.dart`
- Nutrition: `lib/screens/nutrition/nutrition_page.dart`
- Profile: `lib/screens/profile/settings/profile_page.dart`
- Measurements and trends: `lib/screens/measurement_trends_page.dart`
- Nutrition log: `lib/screens/nutrition_log_page.dart`
- Combined history: `lib/screens/combined_history_page.dart`
- Form and posing: `lib/screens/form_posing_page.dart`

## Active Feature Areas

- Exercise feature work should usually go under `lib/screens/exercise/`.
- Nutrition feature work should usually go under `lib/screens/nutrition/`.
- Profile/settings feature work should usually go under
  `lib/screens/profile/settings/`.
- Shared dashboard cards and navigation widgets live under `lib/widgets/`.
- Database and repository work lives under `lib/db/` and `lib/repositories/`.

## Duplicate-Looking Files

Several root-level files under `lib/screens/` have counterparts in nested
feature folders. Treat root-level duplicates as legacy or compatibility files
unless `lib/main.dart`, a widget import, or another active screen imports them.

Known examples to verify before editing:

- `lib/screens/muscle_filter_page.dart` vs
  `lib/screens/exercise/muscle_filter_page.dart`
- `lib/screens/definitions_by_bodypart_page.dart` vs
  `lib/screens/exercise/definitions_by_bodypart_page.dart`
- `lib/screens/exercise_analytics_screen.dart` vs
  `lib/screens/profile/settings/exercise_analytics_screen.dart`
- `lib/screens/flow_chart_page.dart` vs
  `lib/screens/profile/settings/flow_chart_page.dart`
- `lib/screens/session_detail_screen.dart` vs
  `lib/screens/exercise/session_detail_screen.dart`
- `lib/screens/new_measurement_item_page.dart` vs
  `lib/screens/nutrition/new_measurement_item_page.dart`
- `lib/screens/specific_measurement_page.dart` vs
  `lib/screens/nutrition/specific_measurement_page.dart`

## Current High-Value Unfinished Areas

- Replace placeholder nutrition pages (`PantryLogPage`, `PlanMealPage`) with
  real workflows.
- Finish exercise catalog drill-down pages for body part and muscle views.
- Make flow-method settings fully functional and connected to flow charts.
- Persist onboarding answers into profile, goal, nutrition, and measurement
  settings.
- Connect nutrition trend cards to real measurement and nutrition data.
