# Run manually from PowerShell. Repository policy prohibits Codex from running
# Dart/Flutter verification. This script stops at the first failing command.
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

$reviewSources = @(
    'lib/main.dart'
    'lib/theme/theme_extensions.dart'
    'lib/theme/neo_brutalism_theme.dart'
    'lib/theme/neo_brutalism_pilot_gallery.dart'
    'lib/theme/debug_theme_family_control.dart'
    'lib/theme/tokens/app_surface_tokens.dart'
    'lib/theme/widgets/tonos_action.dart'
    'lib/theme/widgets/tonos_action_depth.dart'
    'lib/theme/widgets/tonos_dialog.dart'
    'lib/theme/widgets/tonos_surface.dart'
    'lib/theme/widgets/tonos_theme_ready.dart'
    'lib/theme/widgets/tonos_sheet.dart'
    'lib/theme/widgets/workout_actions.dart'
    'lib/widgets/session_complete_sheet.dart'
    'lib/widgets/settings_tiles.dart'
    'lib/widgets/weight_card.dart'
    'lib/widgets/exercise_progress_section.dart'
    'lib/widgets/workout_metric_chart_card.dart'
    'lib/widgets/workout_history_calendar.dart'
    'lib/widgets/history_summary_widget.dart'
    'lib/widgets/preset_info_card.dart'
    'lib/widgets/preset_bar.dart'
    'lib/widgets/body_heatmap.dart'
    'lib/widgets/seven_day_focus_card.dart'
    'lib/widgets/workout_record_badges.dart'
    'lib/widgets/cardio_card.dart'
    'lib/widgets/current_metrics_section.dart'
    'lib/widgets/exercise_definition_info_tile.dart'
    'lib/widgets/nutrition_bar_details.dart'
    'lib/widgets/stretch_card.dart'
    'lib/screens/exercise/definitions_by_bodypart_page.dart'
    'lib/screens/exercise/definitions_by_muscle_page.dart'
    'lib/screens/exercise/full_history_screen.dart'
    'lib/screens/nutrition/default_trend_page.dart'
    'lib/screens/nutrition/food_customization_page.dart'
    'lib/screens/nutrition/food_logging_page.dart'
    'lib/screens/profile/settings/database_settings_page.dart'
    'lib/screens/profile/settings/bodypart_ranking_screen.dart'
    'lib/screens/profile/settings/muscle_ranking_screen.dart'
)
$reviewTests = @(
    'test/theme/widgets/exercise_progress_responsive_test.dart'
    'test/theme/widgets/workout_metric_chart_card_responsive_test.dart'
    'test/theme/widgets/seven_day_focus_presentation_test.dart'
    'test/theme/widgets/neo_refinement_regression_test.dart'
    'test/theme/widgets/settings_tiles_test.dart'
    'test/theme/widgets/tonos_surface_test.dart'
    'test/theme/widgets/tonos_sheet_test.dart'
    'test/theme/theme_lab_page_test.dart'
    'test/theme/tonos_theme_ready_test.dart'
    'test/theme/pre_q2_route_evidence_test.dart'
    'test/theme/neo_brutalism_theme_test.dart'
    'test/theme/app_theme_tokens_test.dart'
    'test/widgets/responsive_accessibility_test.dart'
)

dart format @reviewSources @reviewTests
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed. Paste the output before proceeding.' }
dart analyze @reviewSources @reviewTests
if ($LASTEXITCODE -ne 0) { throw 'Analysis failed. Paste the output before proceeding.' }
flutter test test/theme
if ($LASTEXITCODE -ne 0) { throw 'Theme tests failed. Paste the output before proceeding.' }
flutter test test/widgets/responsive_accessibility_test.dart
if ($LASTEXITCODE -ne 0) { throw 'Responsive accessibility tests failed. Paste the output before proceeding.' }
git diff --check
if ($LASTEXITCODE -ne 0) { throw 'Whitespace check failed. Paste the output before proceeding.' }
Write-Output 'Neo refinement formatting, analysis, and theme tests passed.'
