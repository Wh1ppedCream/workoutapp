# Current-source snapshot — 2026-10-05

## Checkpoint

- Repository: `E:\projects\env_test`
- Branch: `feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- HEAD subject: `Add Expressive planning route previews`
- Source state: dirty candidate working tree with pre-existing user-owned changes. No changes from this pass have been committed or pushed.
- Device state: final current-source profile preview build and Pixel 7 captures are complete for the touched review states. See `device-review/final-current-source-20261005-125052/capture-notes.md`.

## Current pass coverage

The route audit and candidate work covered these areas:

| Area | Current candidate coverage | Verified focused evidence |
| --- | --- | --- |
| Dashboard | Expressive dashboard composition and compact/large-text hero/action treatment. | Dashboard theme tests include a populated light/dark state and large-text state. |
| Analytics Dashboard | Expressive analytics destination treatment; existing Body Parts and Muscles tabs and source content are preserved. | Analytics route tests. |
| Nutrition | Nutrition home, food logging and customization, barcode scanner, diary, manual goals, and diet/nutrition settings. | Destination, presentation, editor/logging/scanner, goals, and accessibility reproduction tests. |
| Onboarding | Expressive onboarding surfaces while preserving the existing multi-step and plan-return workflow. | Expressive presentation tests plus Classic/Neo onboarding and plan-flow tests. |
| Auto Preset Flow and Preset Generation QA | Expressive planning roles for flow editing and generation QA; semantic error and choice states retained. | Flow theme and generation token tests, plus generation weight-math tests. |

Known responsive/accessibility refinements in this source include Dashboard hero/action stacking at compact width or large text, large-text Nutrition diary collision avoidance, compact large-text portion controls, and a high-contrast opaque scanner reticle. These describe tested candidate behavior, not completed device qualification.

## Validation recorded for this candidate

- Earlier focused Flutter tests: **162 passed, 0 failed**, across **22 targets**. Superseded at closure by the final focused run below.
- Final focused Flutter tests: **180 passed, 0 failed**, across **32 targets** covering Dashboard, Nutrition, onboarding, Auto Preset Flow/generation, Profile settings, Analytics Settings, and the final ranking/editor fixes. Full repository suite remains deferred.
- The final 32 focused targets were:

  ```text
  test/theme/dashboard_history_contract_test.dart
  test/theme/dashboard_history_tokens_test.dart
  test/theme/nutrition_presentation_test.dart
  test/theme/nutrition_goals_behavior_test.dart
  test/theme/preset_generation_tokens_test.dart
  test/theme/widgets/dashboard_sections_theme_test.dart
  test/theme/widgets/dashboard_editor_theme_test.dart
  test/theme/widgets/nutrition_accessibility_repro_test.dart
  test/theme/widgets/nutrition_destination_presentation_test.dart
  test/theme/widgets/nutrition_goals_expressive_test.dart
  test/theme/widgets/nutrition_text_details_theme_test.dart
  test/screens/onboarding_and_plan_flow_test.dart
  test/theme/widgets/onboarding_expressive_presentation_test.dart
  test/theme/widgets/onboarding_flow_theme_test.dart
  test/theme/widgets/onboarding_info_callout_test.dart
  test/theme/widgets/onboarding_nutrition_qualification_test.dart
  test/theme/widgets/onboarding_plan_overview_states_test.dart
  test/theme/widgets/auto_preset_flow_screen_theme_test.dart
  test/preset_generation_weight_math_test.dart
  test/theme/widgets/profile_expressive_presentation_test.dart
  test/theme/widgets/profile_settings_expressive_test.dart
  test/theme/widgets/ui_appearance_expressive_contrast_test.dart
  test/theme/widgets/settings_route_theme_test.dart
  test/theme/widgets/analytics_destination_routes_test.dart
  test/theme/widgets/analytics_ranking_label_contract_test.dart
  test/theme/widgets/analytics_ranking_label_responsive_test.dart
  test/theme/widgets/exercise_editor_expressive_presentation_test.dart
  test/theme/widgets/exercise_analytics_screen_theme_test.dart
  test/theme/widgets/exercise_muscle_percent_screen_theme_test.dart
  test/theme/widgets/weekly_set_analytics_theme_test.dart
  test/theme/widgets/bodypart_focus_chips_theme_test.dart
  test/theme/widgets/gym_profile_screen_theme_test.dart
  ```
- Final scoped analyzer: **0 errors, 2 warnings, 12 info notices**. Both warnings are unnecessary non-null assertions in the already-dirty `ui_appearance_settings_page.dart` at lines 263 and 281. Info notices are existing Flutter API deprecations for Radio `groupValue`/`onChanged` and reorder callbacks.
- Check-only formatter flagged six already-dirty files; no formatter write-mode changes were made. `git diff --check` exited 0 with line-ending warnings only.
- Theme-style inventory check: exit code 0; 301 Dart files, 3,316 candidates, 0 unassigned, 109 pending findings, 5 outside review queues.
- Theme-style ratchet report completed. Ratchet enforcement exited 64 because fingerprints differ from the recorded baseline in the pre-existing protected dirty files `lib/widgets/tonos_bottom_navigation_bar.dart` and `lib/widgets/exercise_definition_info_tile.dart`. The report does not establish that those files were changed by this expansion.
- `git diff --check`: exit code 0; Git emitted line-ending warnings for existing working-tree files.
- The full repository suite and release qualification are not claimed. An isolated preview APK and partial current-source Pixel device review are now recorded in the closure section below.

## Theme and workflow boundaries

- Train Overview/Plans, Active Workout, and the navigation shell remain protected references; this pass does not claim to redesign them.
- Classic and Neo branches were covered by focused parity/theme tests in changed families, including onboarding and Nutrition destination scope. No global Classic or Neo redesign is part of this candidate.
- Completion, nutrition, chart, plan, and other domain data semantics remain owned by their existing feature behavior. Expressive destination roles are explicitly scoped; Nutrition-specific token roles are not applied globally to unrelated destinations.
- The focused validation run did not test every route/state in the 55-archetype ledger. Route-specific gaps remain listed there.

## Remaining gaps and boundaries

- Current-source Pixel evidence is partial and limited to the states listed in the final capture notes; do not infer that every route or state has device coverage.
- Flow Methods, Workout Progress Flows, and shared workout/health dialogs remain separate visual-review candidates.
- Existing Profile child routes, Catalog, Progress, Logbook, planning, and Analytics Settings candidates retain the route-specific gaps documented in `route-component-ledger.md`.
- Train2 stays frozen. No production caller was found for App Settings, Default Trend, or Exercise Muscle Percent during the route audit.
- Nutrition Log, Combined History, and Form and Posing are release-denied placeholders; Pantry Log and Plan Meal are reachable placeholder pages. They remain product-incomplete and were not embellished with invented workflows.
- Shared non-Catalog Exercise Details callers and cross-destination shared components remain caller-sensitive; a wrapper-level Expressive test does not prove all callers.

## Final closure evidence — 2026-10-05

- Final Pixel 7 evidence was captured from HEAD `ab18ed8cab5582c8449e13724afae3c4b74ebeea` plus the dirty working tree, using Flutter 3.47.5/Dart 3.13.4, serial `28021FDH200228`, package `com.tonos.expressivepreview`, and database `tonos_expressive_preview.db`. Exact build identity and route list are in the capture notes.
- The final fixes were limited to Expressive destination-context propagation in Food Customization, the Flow canvas inset, responsive Rank-field label width, and the Exercise Editor treatment. Classic and Neo branches were preserved. No production qualification, commit, or push was performed.
- Remaining visible items are logged in the closure section of `README.md`: Flow chart grid/blue handles and subtitle ellipsis; Food Customization footer overlap and truncated Amount label; plus incomplete route/device coverage listed in the ledger. These were intentionally left for later review.

## Working-tree note

The repository contained extensive dirty and untracked user work before this pass. Keep it intact. This documentation records the candidate and its evidence; it does not authorize cleanup, staging, commits, pushes, or broader qualification.
