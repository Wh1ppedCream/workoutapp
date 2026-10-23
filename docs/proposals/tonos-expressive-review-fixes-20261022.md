# Tonos Expressive — Review Fixes

Date: 2026-10-22. Baseline checkpoint: **`6afd311` — Checkpoint approved Expressive visuals and full review**.

The checkpoint preserves the previously approved implementation and original full-review report. The fixes below remain uncommitted for inspection. Nothing was pushed. Existing unrelated worktree artifacts were retained.

## Completed fixes

| Audit item | Implementation | Focused evidence |
| --- | --- | --- |
| Historical nutrition date leaks into root logging | Records routes own a dated `NutritionProfile` scope. Nested records and food/measurement routes retain that scope; writes refresh the caller without changing its date. Scoped initialization waits for the parent's profile selection. | Route/back and nested-day tests; historical records to food logger; root day remains unchanged. |
| Plan edit toggle bypasses unsaved changes | Dirty state protects navigation independently of edit mode. Turning editing off offers the existing Cancel/Discard confirmation. Discard reloads the persisted preset without writing it. | Dirty rename, toggle cancellation, back protection, explicit discard and clean exit. |
| Premade Plans toolbar overflows | Preserve the approved normal toolbar; move duration controls below the title when narrow width or increased text requires it. Measure localized/scaled text and constrain the selector. | Existing light/dark filter tests and layout matrix, including 320dp at 2x text, pass. No new exhaustive translation/device sweep. |
| Anatomy mapping accepts late responses | Sequence and selection checks reject stale loads. Loading/failure states are explicit; editing is unavailable until current links load successfully. | Controlled responses finish in reverse order; current selection keeps its links and editing is guarded while loading. |
| Rankings save an older submitted value | Body-part and muscle editors retain drafts by entity ID, validate and save the visible text, and track edits made while a save is running. | Both editors save the latest unsubmitted value after keyboard focus leaves the field. |
| Non-finite nutrition targets | Form, provider and DAO reject non-finite or negative targets. Invalid legacy targets read as unset without rewriting stored rows; valid zero/decimals remain supported. | Actual form/model validation and in-memory DAO save/read checks; invalid writes do not close the valid goal. |
| Calendar weekday/date mismatch | Derive weekday headings from the first rendered day; use calendar arithmetic for the rolling 28 dates. | All seven starting weekdays and a year boundary are covered. |
| Add change set lacks button behavior | Expressive uses an outlined button with a minimum 48dp target, button semantics, focus and keyboard activation. Classic/Neo keep their existing presentation. | Button semantics, minimum height and Tab/Enter activation pass. |

### Additional source risks resolved

- **Onboarding:** guard repeated async Next/handoff actions, disable conflicting controls during the operation, and expose recoverable errors through the existing error presentation. A delayed, failing repository test confirms one handoff attempt and a usable retry.
- **Volume boundaries:** require finite, nonnegative, ordered values in the editor/model/DAO; tolerate invalid legacy rows by returning no bounds; reject stale body-part/muscle loads. Tests cover invalid input and persistence while retaining valid zero/equal/decimal boundaries.
- **Navigation editor:** await both preference writes before reporting Saved or changing runtime navigation. Failure leaves the editor dirty and attempts to restore the prior preference snapshot. Injected first/second-write failures, delayed completion, and UI retry pass. The two preference keys are not a database transaction; restoration remains best effort if storage continues failing.

### Supporting corrections

- Nutrition reload now copies repository diary rows before sorting. The original audit's nutrition-summary failures were attributed too broadly to stale assertions: sorting an immutable repository result also interrupted reload. Both that issue and the outdated two-row/empty-message assertions are corrected.
- Removed the two unnecessary non-null assertions identified in Health Trends. No chart styling changed.

## Files changed

Application files:

- `lib/db/analytics_dao.dart`, `lib/db/nutrition_dao.dart`
- `lib/models/analytics_models.dart`, `lib/models/nutrition_models.dart`
- `lib/providers/nav_bar_config.dart`, `lib/providers/nutrition_profile.dart`, `lib/providers/preset_session.dart`
- `lib/screens/exercise/premade_plans_page.dart`, `lib/screens/exercise/preset_detail_screen.dart`
- `lib/screens/nutrition/log_entry_page.dart`, `lib/screens/onboarding_flow.dart`
- `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart`
- `lib/screens/profile/settings/bodypart_ranking_screen.dart`, `lib/screens/profile/settings/muscle_ranking_screen.dart`
- `lib/screens/profile/settings/goal_manual_entry_page.dart`, `lib/screens/profile/settings/nav_bar_settings_page.dart`, `lib/screens/profile/settings/volume_boundaries_screen.dart`
- `lib/theme/widgets/workout_actions.dart`
- `lib/widgets/data_records_section.dart`, `lib/widgets/health_trends_section.dart`, `lib/widgets/speed_dial_fab.dart`

Regression tests:

- `test/providers/nav_bar_persistence_regression_test.dart`
- `test/theme/widgets/nutrition_records_scope_regression_test.dart`
- `test/theme/widgets/plan_and_goal_state_regression_test.dart`
- `test/theme/widgets/ranking_save_regression_test.dart`
- `test/theme/widgets/mapping_and_change_set_regression_test.dart`
- `test/theme/widgets/volume_boundary_validation_regression_test.dart`
- `test/theme/widgets/onboarding_handoff_regression_test.dart`
- Updated `test/theme/food_logging_behavior_test.dart` and `test/theme/widgets/nutrition_goals_expressive_test.dart` for scoped dates and the approved current records layout.

Documentation: this report and a follow-up link in `tonos-expressive-full-review-20261022.md`.

## Validation

Pinned SDK: `E:/tools/flutter_sdks/3.47.5/flutter/bin/`.

- Formatted changed Dart blocks/files; avoided whole-file formatting churn in the large DAO/provider/Health Trends sources.
- `dart analyze --format machine lib` plus seven new regression files: **0 errors, 0 warnings, 51 existing informational notices**. This is not a claim of an entirely notice-free analyzer result.
- Focused Flutter run with `--no-pub --concurrency=1 --machine`: **135 passed, 0 failed, 21 files**.
- The run includes the seven regression files plus nutrition goals, food logging, Premade Plans, ranking responsiveness, analytics dropdowns, profile settings, compact active/past workouts, FAB scrolling, onboarding presentation, nutrition accessibility/destinations, and Health Trends chart accessibility.
- Logs: `.build/codex_expressive_fixes_20261022/analyzer-final.txt` and `validation-final.jsonl`.
- `git diff --check`: passed.
- Pixel 7 preview refreshed successfully by **hot restart** through `lib/expressive_review_main.dart`; Flutter reported completion in 6,455ms. The VM main isolate changed and the Expressive preview remained the foreground app. The existing database and preferences were retained; no reseeding entrypoint or app reinstall was used.

## Preserved scope and remaining qualification

- Existing visual classifications remain unchanged: **49 approved / 0 pending implemented page archetypes**. The screenshot gallery and approval ledger were not altered.
- No database reset, reseed, fixture replacement, dependency fetch, full test suite, release build, or push was performed. New persistence checks use fake repositories/preferences or in-memory databases.
- Approved default palettes, card proportions, shadows, floating controls, and Classic/Neo visual styling were preserved. Responsive fallback, loading/error states and accessible button behavior changed where required by the audited defects.
- The original audit's unrelated stale source-inventory/save-button assertions, shell/tutorial fixture issues and long-metadata anatomy timeouts remain separate qualification work. The focused passing run does not claim the whole repository suite passes.
- No new exhaustive physical-device sweep, TalkBack review, localization matrix, performance soak, or release qualification is claimed. The preview restart confirms updated code was loaded, not exhaustive visual verification of every repaired state.
