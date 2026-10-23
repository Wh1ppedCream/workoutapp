# Full test validation — 2026-10-22

> **Follow-up — 2026-10-23:** The failure backlog below is the historical initial
> baseline. The authorized stabilization work fixed the profile-loading race and
> reconciled stale contracts, fixtures, goldens and style ownership. Updated host
> coverage is **2,146 passed / 0 failed / 0 skipped across 306 files**, assembled
> from verified completed files and a successful resumed batch. See the
> [stabilization report](tonos-expressive-test-stabilization-20261022.md) for
> current device results, exact execution boundaries and remaining qualification
> gaps. Do not treat the original unresolved counts below as current results.

## Original baseline result — before the follow-up

**The test suite is not green, and a release qualification claim is not supported.**

The complete host Flutter baseline ran all **304 files / 2,154 visible cases**: **2,030 passed, 124 failed, 0 skipped** (exit 1, approximately 34 minutes). The machine reporter separates the failed cases into 87 errors and 37 assertion failures; both are included in the 124 total.

Focused reruns cleared **24 baseline failures** through test/setup accuracy repairs. **100 baseline failures across 38 files remain unresolved.** This is baseline reconciliation, **not a second complete-suite result**: nested assertions can reveal further issues after an earlier failure is repaired. Do not infer an overall green result from the focused passes.

The separate Android core-flow integration case also **failed during manual-plan creation**. Its later workout, nutrition, measurement, navigation and locale steps were not reached. This functional failure needs investigation independently of the host theme-contract backlog.

Approved Expressive visuals and application behavior were preserved. This pass changes test harnesses/contracts, removes four unused translation keys, and records justified identical-English localization values. It does not change application Dart UI, visual approval classifications, golden masters, or ratchet approvals.

## Environment and evidence

- Checkout: `E:\projects\env_test`, existing branch and dirty worktree preserved.
- Flutter **3.47.5 stable**, Dart **3.13.4**, using `E:\tools\flutter_sdks\3.47.5\flutter`.
- Full baseline: `flutter test --no-pub --concurrency=2 --machine`.
- Logs, machine summaries, inventory/ratchet details and device attempt output: [validation artifacts](../../.build/codex_full_suite_20261022/) (ignored local files; the relative path is supplemented by the absolute path `E:\projects\env_test\.build\codex_full_suite_20261022`).
- No dependency installation, staging, commits, pushes, worktree reset or preview reseeding was performed.

## Checks completed

| Check | Result |
| --- | --- |
| Complete host Flutter baseline | 2,030 passed / 124 failed / 0 skipped; exit 1 |
| Diagnostics relay Node schema suite | 8 passed / 0 failed |
| Locked development compile-time content policy | 1 passed |
| Locked production compile-time content policy | 1 passed |
| Neo release opt-in with experimental themes off | 1 passed |
| Malformed Neo release opt-in rejection | 1 passed |
| Localization structure / reviewed-English follow-up | 4 passed |
| CLI fixtures with the selected SDK and unchanged global PATH | 2 passed |
| Global source, test, integration and content-tool analysis | 0 errors, 0 warnings, 77 informational findings; exit 0 |
| Subsequent analysis of the final matrix/cache changes | 0 errors, 0 warnings, 0 informational findings; exit 0 |
| Catalog-builder `bin` / `tool` analysis | Clean; exit 0 |
| Development content environment validation | Passed |
| Locked production content environment validation | Passed |
| Structural style inventory `--check` | Passed as a report-only inventory; it does not mean every candidate is qualified |
| Production style ratchet | Failed: drift in seven enrolled files; exit 64 |
| Isolated Android integration APK compilation | Passed, offline debug x64 build |
| Android core-flow device execution | Failed during manual-plan lookup; later flow steps were not verified |
| Legacy profile preview benchmark | Not run; see coverage limits |
| `git diff --check` | Passed again at closeout |

## Repairs made and verified

1. **Anatomy responsive fixtures:** stub exercise-media manifest readiness and thumbnail lookup. The recently added real thumbnail otherwise reached unimplemented repository/database operations and left loading animations active. Both 320dp / 2x timeouts now pass, without relaxing layout assertions or increasing the timeout.
2. **Expressive shell harness:** wait for the concrete Train route after providers load, drain the delayed tutorial gate, and unmount before disposing harness controllers. All five baseline startup/timer failures pass.
3. **Theme selector contract:** verify Classic → Neo → Expressive → Classic persistence, and stable Expressive availability when experimental themes are off. Normal app preview controls were not reintroduced.
4. **Progress legacy contract:** limit the test explicitly named Classic/Neo to those two families. The separate Expressive token, contrast and destination tests remain intact and pass.
5. **Real Expressive family in test matrices:** correctly classify `AppThemeFamily.expressive`, while retaining both the registered factory theme and synthetic identity-only coverage. Editor, picker, Analytics and responsive checks run through their actual Expressive branches. Update the mapping selector finder to its anchored menu, target the allocation Save action rather than the identically named status badge, and exercise the current Catalog picker landing action.
6. **Approved hero labels:** assert the reviewed rounded counts `3, 2, 1, 0, 0, 0`, retain the fractional `0.5` bar input assertion, and preserve responsive layout checks. All six light/dark and width/text-scale cases pass.
7. **Localization:** remove the obsolete `premadeEquipmentNoMatches` key from French, Canadian French, Chinese and Hindi; the current Expressive message remains. Document actual French/Spanish words and standard `g`/`kcal` symbols that legitimately equal English. Pin the existing invariant Bengali/Chinese plan-unit labels as narrowly scoped exceptions to the English count-selector contract; no visible value placeholder is exempted. Regenerate localizations.
8. **CLI SDK consistency:** subprocess tests choose the Dart SDK belonging to the Flutter SDK running the tests. Two baseline failures were caused by an older Dart 3.7 on PATH despite the outer command using the correct SDK. Both CLI fixture tests pass without changing global PATH.
9. **Inventory test efficiency:** cache one immutable production scan per read-only suite instead of repeating the full scan 47 times. The 21 failing inventory assertions remain unchanged and still fail; this does not accept new styling.

Focused runs are intentionally not added together: they overlap. The first seven-file follow-up had 169 passes and two failures (localization, subsequently repaired, and the still-failing production ratchet). The later five-file matrix/inventory batch had 52 passes and 22 failures (21 unchanged inventory failures plus Analytics, subsequently repaired). The final standalone Analytics run passed all three cases.

## Original remaining failure groups

### Regular Expressive expectations and approved layout changes

Many older tests enumerate all `AppThemeFamily.values` but implement only Classic/Neo expectations. Registering Expressive now exercises those missing branches. Other contracts still require replaced widgets, old caller opt-ins, old Save bars, old row density, or removed labels. Examples include:

- Catalog/detail shared presentation and one-line record rows.
- Current Metrics compact presentation, shared Dashboard compositions and separated hidden widgets.
- Plan/preset conditional floating actions and rounded focused-set counts.
- Anchored selectors and segmented Add-set choices instead of old dropdown/radio structures.
- Expressive destination colors, zero-offset shadows, and navigation controls.

These are **expectation-reconciliation candidates**, not proof that every corresponding UI is correct. Review each failed assertion against its current source and approved scope; do not restore old application layouts merely to satisfy it.

### Structural inventory and qualification protection

The report has **4,349 candidates**: **3,581 migrated, 147 allowlisted, 621 pending**. These are source-style findings, not page archetypes or visual approval totals. The inventory is explicitly report-only. Several historical tests incorrectly assume zero pending findings repository-wide.

**49 pending findings have no review-queue owner**, across:

- `lib/screens/exercise/flow_editor_expressive_widgets.dart`
- `lib/screens/exercise/full_history_screen.dart`
- `lib/screens/measurement_trends_page.dart`
- `lib/widgets/expressive_nutrition_summary.dart`

Some count drift also exposes overly broad ownership assumptions. For example, the Exercise Editor divider rule matches all 20 current color findings although its rationale/test describes one transparent divider. A blind count refresh would conceal that scope mismatch. Backlog scoping and exact ownership require review before changing qualification expectations.

The protected ratchet files with changed fingerprints are:

| File under `lib/widgets/` | Previous / current occurrences |
| --- | --- |
| `workout_record_badges.dart` | 13 / 18 |
| `tonos_bottom_navigation_bar.dart` | 27 / 30 |
| `tonos_train_tabs.dart` | 20 / 20, with changed fingerprints |
| `exercise_definition_info_tile.dart` | 1 / 19 |
| `bodypart_focus_chips.dart` | 7 / 14 |
| `preset_info_card.dart` | 4 / 15 |
| `data_records_section.dart` | 10 / 13 |

The production ratchet reports 97 drift records. Its 18 enrolled scopes and existing approvals were preserved. Source review and accurate behavior/ownership tests must precede any fingerprint refresh.

### Golden differences

Both light and dark Flow-control golden tests fail in collapsed and expanded states. The expanded expected image is **430×588**, and the current output is **430×570**. The light expanded pair was inspected: panel geometry, spacing and text wrapping differ; that observation does not establish which state should be the release master.

The four golden masters were not updated. Generated comparison images remain in [the existing failures directory](../../test/theme/widgets/failures/) / `E:\projects\env_test\test\theme\widgets\failures`. They need reconciliation with the approved current design.

### Unresolved baseline cases by file

Paths below are relative to `test/`. Counts exclude the 24 baseline cases cleared by focused reruns.

| Test file | Cases still unresolved |
| --- | ---: |
| `theme/catalog_exercise_detail_presentation_contract_test.dart` | 2 |
| `theme/catalog_page_theme_inventory_contract_test.dart` | 1 |
| `theme/exercise_catalog_theme_ownership_test.dart` | 2 |
| `theme/exercise_detail_contract_test.dart` | 1 |
| `theme/exercise_detail_generation_inventory_test.dart` | 1 |
| `theme/theme_style_inventory_contract_test.dart` | 21 |
| `theme/theme_style_ratchet_cli_test.dart` | 1 |
| `theme/train2_optimized_settings_fields_theme_test.dart` | 2 |
| `theme/train_panel_ink_theme_test.dart` | 2 |
| `theme/widgets/anatomy_routes_theme_test.dart` | 2 |
| `theme/widgets/auto_preset_flow_panels_golden_test.dart` | 2 |
| `theme/widgets/auto_preset_flow_screen_theme_test.dart` | 2 |
| `theme/widgets/automatic_settings_sheet_theme_test.dart` | 2 |
| `theme/widgets/catalog_page_theme_ownership_test.dart` | 2 |
| `theme/widgets/current_metrics_section_theme_test.dart` | 2 |
| `theme/widgets/dashboard_editor_theme_test.dart` | 2 |
| `theme/widgets/dashboard_sections_theme_test.dart` | 2 |
| `theme/widgets/exercise_analytics_screen_theme_test.dart` | 2 |
| `theme/widgets/gym_profiles_drawer_expressive_test.dart` | 2 |
| `theme/widgets/onboarding_flow_theme_test.dart` | 4 |
| `theme/widgets/onboarding_info_callout_test.dart` | 2 |
| `theme/widgets/onboarding_nutrition_qualification_test.dart` | 2 |
| `theme/widgets/optimized_workout_settings_fields_theme_test.dart` | 2 |
| `theme/widgets/plan_management_theme_test.dart` | 2 |
| `theme/widgets/premade_plans_page_theme_test.dart` | 4 |
| `theme/widgets/preset_detail_screen_theme_test.dart` | 5 |
| `theme/widgets/preset_generation_qa_responsive_test.dart` | 1 |
| `theme/widgets/profile_child_responsive_test.dart` | 1 |
| `theme/widgets/session_completion_theme_contract_test.dart` | 2 |
| `theme/widgets/session_detail_theme_ownership_test.dart` | 2 |
| `theme/widgets/settings_pending_routes_theme_test.dart` | 2 |
| `theme/widgets/settings_route_theme_test.dart` | 5 |
| `theme/widgets/swap_exercise_sheet_theme_test.dart` | 3 |
| `theme/widgets/tonos_bottom_navigation_bar_test.dart` | 2 |
| `theme/widgets/tonos_dialog_test.dart` | 2 |
| `theme/widgets/tonos_train_tabs_test.dart` | 2 |
| `theme/widgets/weekly_set_analytics_theme_test.dart` | 2 |
| `theme/widgets/workout_history_calendar_theme_test.dart` | 2 |

## Device coverage and remaining qualification limits

The core-flow test clears preferences and recreates its explicitly named integration database. It was compiled with `TONOS_INTEGRATION_TEST=true` and `TONOS_DATABASE_NAME=tonos_integration_test.db`, then targeted only at a newly created disposable `TonosValidation20261022` AVD (`emulator-5580`, installed Android 36 image). The current Pixel installation was not used for resets or fixtures.

The test APK was built offline against the existing dependency cache, using a build-only init script to resolve the already-cached `androidx.test:runner:1.2.0` for its existing `1.2+` selector. No tracked dependency change was made. Gradle heap/workers were capped; emulator startup and compilation were separated when memory pressure increased. The successful APK build is compilation evidence, not a device-test pass or release-build qualification.

`integration_test/expressive_preview_device_test.dart` is a separate profile/performance campaign. It requires profile mode and an exact preview package/database guard, prepares preview fixtures and still contains a five-destination navigation assumption. Running it on the current Pixel would overwrite the review preview data. It remains unexecuted and needs a dedicated safe physical profile target plus updated contracts. An emulator debug run cannot substitute for that performance qualification.

**Final device outcome:** failed. The emulator completed fresh database initialization and the test reached onboarding quick-start, training-fixture preparation and manual-plan creation. The first failure was `StateError: Bad state: No element` at `integration_test/core_flows_test.dart:267`, where the test looked for the newly created manual plan among the expected profile's preset rows. Database-lock warnings appeared before that failure; `database_closed` errors followed during teardown. The log explicitly reports `Some tests failed` after approximately 7 minutes 33 seconds; the interrupted shell session's final exit code was not recovered.

This is not established to be only a stale test. The fixture already unmounts the initial provider tree before creating the training fixture, and the production manual-plan path awaits row creation before opening its detail page. Investigate selected-profile readiness, the actual profile attached to the new plan, transaction timing and test teardown before changing the assertion. Do not bypass the database check or describe the later flow steps as passed.

At closeout, no validation emulator, Flutter test VM or integration driver remained running; `adb devices` listed only the existing Pixel. The disposable AVD files remain under the ignored validation-artifact directory. No APK was installed on the Pixel, and its databases and preferences were not touched.

**Final diff check:** passed (`git diff --check`, exit 0). Normal Windows line-ending notices are not whitespace errors.

## Files changed by this validation pass

- `test/expressive_catalog_anatomy_responsive_matrix_test.dart`
- `test/expressive_overlay_qualification_test.dart`
- `test/localization/arb_structure_contract_test.dart`
- `test/theme/debug_theme_family_control_test.dart`
- `test/theme/progress_expressive_theme_scope_test.dart`
- `test/theme/theme_style_inventory_contract_test.dart`
- `test/theme/theme_style_ratchet_cli_test.dart`
- `test/theme/widgets/analytics_destination_routes_test.dart`
- `test/theme/widgets/exercise_editor_expressive_presentation_test.dart`
- `test/theme/widgets/profile_analytics_dropdown_interaction_test.dart`
- `test/theme/widgets/preset_info_card_theme_test.dart`
- `docs/localization-reviewed-english.json`
- `lib/l10n/app_fr.arb`, `app_fr_CA.arb`, `app_zh.arb`, `app_hi.arb` (unused key removal only)
- This report.

Existing application fixes, theme integration edits, user-authored work, screenshots, preview preferences and workout data were preserved. No visual approval status was changed. A subsequent complete suite is still required after the unresolved contracts and qualification gaps are addressed.
