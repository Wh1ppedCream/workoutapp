# Tonos Expressive — Full Implementation Review

Review date: 2026-10-22. Snapshot: the existing working tree, including its uncommitted Expressive refinements.

> **Implementation follow-up:** This report preserves the pre-fix audit snapshot saved in checkpoint `6afd311`. The eight confirmed issues and three source risks were subsequently addressed; see [review fixes and validation](tonos-expressive-review-fixes-20261022.md). The results and limitations below describe the original review, not the repaired state.

## Result

**Eight issues reproduced.** The most consequential problems concern dates and unsaved edits. One clear responsive layout regression was reproduced in Premade Plans. The findings below concern correctness and qualification; the existing personal visual approvals remain unchanged.

The review covered the **49 implemented page archetypes** in the current authoritative A/B ledger through static analysis, route/component tracing, and focused existing tests. Related shared dialogs, menus, charts, exercise cards, nutrition summaries, navigation, and onboarding were included. This does not mean every branch of every page received a new physical-device visual inspection.

No application source, approved layout, approval classification, gallery, database, preference, or fixture was changed. This report is the only new non-ignored repository file from the review. Reproduction probes and logs are under `.build/codex_expressive_full_review_20261022/` and use fake repositories or an in-memory database.

## Reproduced issues

### 1. P1 — Returning from historical nutrition records leaves meal logging on that historical date

**Where:** `lib/screens/nutrition/log_entry_page.dart:47`, `lib/providers/nutrition_profile.dart:170`, `lib/screens/nutrition/nutrition_page.dart:62`, `lib/screens/nutrition/food_logging_page.dart:116`.

**Trigger:** Open a previous date from Data & records, return to Nutrition, then use Add Meal.

`LogEntryPage` changes the shared `NutritionProfile.day`. Leaving the route does not restore the previous day. Nutrition root reads that same provider for its Daily nutrition totals, goals, and food logger, without showing the historical date. The logger intentionally defaults its timestamp to the provider's selected day. This makes an ordinary new meal liable to be logged against the previously visited date.

**Evidence:** An isolated widget probe opened records seven days earlier and returned. `profile.isToday` remained false. Source tracing confirms the root summary and logger use that retained day. No real food entry was created.

**Recommended fix:** Give historical records route-owned day state, or restore the caller's day when the route returns. Keep the summary date and logging date explicit and consistent. Cover Nutrition and Dashboard callers, nested record routes, and back navigation.

### 2. P1 — Turning plan editing off bypasses the unsaved-change warning

**Where:** `lib/screens/exercise/preset_detail_screen.dart:147`, `:772`, `:1114`.

**Trigger:** Edit a plan, change its name or exercise data, tap the pencil to leave editing, then go back.

The pencil toggles `_isEditing` directly. The Save Changes action is only available while editing. `_onWillPop` returns immediately when `_isEditing` is false, even when `PresetSession.hasChanges` is true. The dirty state can therefore leave without saving or a discard confirmation.

**Evidence:** A widget probe changed an existing plan name, verified that it was dirty and Save Changes appeared, turned editing off, and went back. The route exited without the expected confirmation. The repository in the probe did not write anything.

**Recommended fix:** Base exit protection on dirty state independently of edit mode. Resolve unsaved changes when turning editing off, or keep an accessible save/discard path. Add a regression case for both name and set edits.

### 3. P2 — Premade Plans duration controls overflow at narrow width and large text

**Where:** `lib/screens/exercise/premade_plans_page.dart:686`, `:702`.

**Trigger:** 320dp width, 2× text, in either light or dark mode.

The duration label and selector occupy a fixed 76dp toolbar. Their unconstrained action column grows to about 360dp wide and exceeds its vertical allocation. The layout reports **80px bottom overflow and 52px right overflow**. The layout matrix also reports that the duration selector is not hit-testable in this configuration.

**Evidence:** Existing tests `Expressive light/dark premade plans preserve filter state` and `Premade plan adapts across layouts` reproduce this. The error points to the app-bar column at line 702, rather than plan content further down the page.

**Recommended fix:** Preserve the approved default app bar. Add a responsive arrangement when width/text measurements cannot accommodate the title and duration controls, with adequate height and a reachable selector. Verify longer translations too.

### 4. P2 — A late anatomy-mapping response replaces the currently selected body part's links

**Where:** `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart:88`, `:346`, `:96`.

**Trigger:** Select Shoulders, quickly select Chest, and let the Shoulders query finish last.

`_loadMappings` checks only `mounted`; it does not check that its body-part ID still matches the selected item. The header can say Chest while the linked muscles belong to Shoulders. Entering editing then takes that incorrect displayed set as its comparison baseline for saving.

**Evidence:** A controlled-completer widget probe returned Chest's links first and Shoulders' links last. Pectorals disappeared while Chest remained selected. This reproduced the stale response without touching the database.

**Recommended fix:** Discard stale responses using a request sequence or selection identity. Represent loading/failure explicitly and prevent editing an old result while a new selection is loading. Check the related volume-boundary loaders for the same request-identity requirement.

### 5. P2 — Body Part and Muscle Rankings can save an older value than the field shows

**Where:** `lib/screens/profile/settings/bodypart_ranking_screen.dart:311`, `:489`; `lib/screens/profile/settings/muscle_ranking_screen.dart:307`, `:463`.

**Trigger:** Submit rank 2, type 3, dismiss the keyboard without submitting, and tap Save.

Both rank controls update the backing map only through `onFieldSubmitted`. Typing or losing focus does not commit the latest controller value. Save reads the old map and can announce success after saving 2 while the field says 3. A first unsubmitted edit also does not mark the page dirty and reveal its save action.

**Evidence:** Separate widget probes for both ranking pages saved **2 instead of 3**. They called only fake repository setters.

**Recommended fix:** Validate and synchronize field edits through change/focus handling or collect controller values before saving. Retain stable entity IDs when sorting; test keyboard dismissal, tapping Save, and invalid input.

### 6. P2 — Manual nutrition targets accept values that can break summary rendering

**Where:** `lib/screens/profile/settings/goal_manual_entry_page.dart:687`, `:709`; `lib/db/nutrition_dao.dart:950`; `lib/screens/nutrition/nutrition_page.dart:62`.

**Trigger:** Paste `NaN`, `Infinity`, or an overflowing exponent such as `1e999` into a target field.

The validator accepts any parsed value that is not less than zero. Non-finite doubles pass that check. There is no finite-value check at the goal model/DAO boundary. Nutrition summaries call `.round()` on saved targets, which throws for infinity and NaN.

**Evidence:** The actual form validator accepted NaN. A numeric probe confirmed that all three strings parse as non-finite values and cannot be rounded. A separate **in-memory** database probe used the real `NutritionDao` to save and reload an infinite calorie target; rounding that saved target threw `UnsupportedError`.

**Recommended fix:** Require finite, nonnegative values before saving, validate again at the persistence boundary, and handle previously invalid stored values safely when reading. Keep valid zero, blank optional fields, and decimal precision working.

### 7. P2 — Data & records dates do not align with their weekday headings

**Where:** `lib/widgets/data_records_section.dart:41`, `:81`.

The headings are always Monday through Sunday, but the cells always start at today minus 27 days. These agree only when today is Sunday. On the review date, Friday **September 25, 2026** occupies the Monday column; the final Thursday occupies the Sunday column. Date selection still opens the actual cell date, making the visual calendar misleading.

**Evidence:** A widget probe verified the generated first cell and found its weekday was Friday (5), rather than Monday (1).

**Recommended fix:** Align the dates to the displayed week, or derive the weekday headings from the first rendered date. Test all seven possible current weekdays and month/year transitions.

### 8. P2 — Add change set lacks a complete accessible button interaction

**Where:** `lib/theme/widgets/workout_actions.dart:159`; used by `lib/widgets/weight_card.dart:1615`.

The shared action is a decorated container around a text `GestureDetector`. It exposes no button role or keyboard-focus/activation behavior, and the gesture target is the text rather than the surrounding padded shape. This affects editable change-set cards, including the Expressive workout/plan experience.

**Evidence:** An isolated Expressive semantics probe found `isButton == false`. The source has no focus or keyboard activation wrapper.

**Recommended fix:** Use a button/InkWell implementation with focus, keyboard activation, a suitable touch target, and button semantics while preserving the approved visual appearance.

## Additional source risks requiring targeted follow-up

These are not counted among the eight reproduced issues.

1. **Onboarding handoff re-entry and errors.** `onboarding_flow.dart:725–875` launches async gym-profile/plan work, while the Next action at `:966` is disabled only by `_isFinishing`. An in-flight Next action is not guarded while opening Premade Plans, the generator, or a manual draft. Repeated taps can queue handoffs; profile/draft duplication depends on repository completion order. The handoff path also lacks the finish path's error handling. Reproduce with delayed/failing fake repositories before changing it.
2. **Volume-boundary input validation.** `volume_boundaries_screen.dart:177` checks whether doubles parse but does not enforce finite, nonnegative, ordered boundaries. The DAO writes these values directly. Exercise negative, reversed, and non-finite input through the full save/read/analytics path before qualification.
3. **Navigation editor reports success before persistence completes.** `nav_bar_settings_page.dart:68` ignores the future from `NavBarConfig.update`, marks the editor clean, and displays Saved immediately. `nav_bar_config.dart:251` persists asynchronously. A preference-write failure could therefore be reported as success; inject that failure and verify recovery.

## Page coverage

The table accounts for all 49 current page archetypes. “No additional finding” means the checks performed did not establish another defect; it is not exhaustive release certification. Some source is shared with Classic/Neo, so a defect visible in Expressive is not necessarily exclusive to Expressive.

| # | Page / archetype | Evidence and outcome |
| --- | --- | --- |
| 1 | Nutrition Goals | Goal presentation/state tests; invalid saved targets affect its consumers. |
| 2 | Manual Nutrition Goals | Form, keyboard and save checks; issue 6. |
| 3 | Onboarding | Existing presentation checks plus full-scaffold portrait/landscape probes; handoff risk remains. |
| 4 | Today's / Calendar Records | Timeline/accessibility checks and route-day probe; issue 1. Old summary assertions need repair. |
| 5 | Train2 | Theme contract and shared action/settings paths; no additional finding established. |
| 6 | Train | Shared shell/navigation/scale checks; overlay fixture/timer failures limit full-shell confirmation. |
| 7 | Plan Management | Light/dark, responsive, and action tests; no additional finding established. |
| 8 | Active Workout | Compact/large-text, FAB/scroll and shared card review; issue 8 in change-set mode. |
| 9 | Progress root | Chart accessibility/responsiveness and destination tracing; no additional finding established. |
| 10 | Exercise Progress / 1RM detail | Responsive/semantic chart and route checks; no additional finding established. |
| 11 | Measurement Trend detail | Chart points, entries, routes and accessibility tests; no additional finding established. |
| 12 | Logbook root | Destination contracts, history/calendar source and shared history checks; no additional finding established. |
| 13 | Full History | Existing theme/widget checks; no additional finding established. |
| 14 | Catalog root | Catalog/anatomy responsive matrix and route review; no additional finding established. |
| 15 | Dashboard root and configuration | Editor visibility/reorder/scroll tests and shared sections; historical nutrition state can also affect its summary. |
| 16 | Session Detail / Past Workout | Compact/large-text and ownership checks; no additional finding established. |
| 17 | Profile root | Screen settings matrix, navigation and shared settings checks; no additional finding established. |
| 18 | User Information | Settings tests and weight-save source tracing; no additional finding established. |
| 19 | UI & Appearance | Contrast/selection tests and settings review; no additional finding established. |
| 20 | Navigation Editor | Settings/large-text checks; async persistence risk above. |
| 21 | Guided Tutorials | Focused settings checks and shared overlay review; tutorial timing remains a test-harness gap. |
| 22 | Gym & Workout Settings | Shared settings/child-route checks; no additional finding established. |
| 23 | Workout Settings | Profile analytics dropdown/responsive checks; no additional finding established. |
| 24 | Body Part Rankings | Responsive labels and isolated save probe; issue 5. |
| 25 | Muscle Rankings | Responsive labels and isolated save probe; issue 5. |
| 26 | Body Part / Muscle Mapping | Dropdown/editor checks and delayed-response probe; issue 4. |
| 27 | Exercise Set Allocation | Settings/child-route/selector checks and source review; no additional finding established. |
| 28 | Exercise Editor | Existing dialog/theme/action tests and route tracing; no additional finding established. |
| 29 | Workout Progress Flows | Focused page and editor-action tests; no additional finding established. |
| 30 | Flow editor / AutoPresetFlowScreen | Existing theme/editor checks; no additional finding established. |
| 31 | Flow Methods selection | Existing refinement/selector checks; no additional finding established. |
| 32 | Plan-specific Flow Methods editor | Existing refinement and copy-source checks; an old Radio-based assertion is stale. |
| 33 | Volume Boundaries | Selector/large-text checks and input/save tracing; validation risk above. |
| 34 | Database Settings | Existing route/theme checks and import/export guard tracing; no destructive operations performed. |
| 35 | Diagnostics & Privacy | Focused page tests; no real export, upload, sync, or removal performed. |
| 36 | Progress Settings | Child-route/theme checks and source review; no additional finding established. |
| 37 | Measurement Library / Measured Items | Shared health-trend/caller checks and source review; no additional finding established. |
| 38 | Nutrition root | Summary/accessibility tests, calendar and day-state tracing; issues 1 and 7. |
| 39 | Target Anatomy library | Responsive/search/route checks; no additional finding established. |
| 40 | Selected Bodypart Detail | Responsive/anatomy checks; old information-button assertion is stale. |
| 41 | Selected Muscle Detail | Responsive/anatomy checks; two long-metadata tests time out and remain unqualified. |
| 42 | Exercise Catalog / Browser | Search/filter/caller/responsive checks; no additional finding established. |
| 43 | Exercise Details Sheet | Compact/responsive/media and shared-caller checks; no additional finding established. |
| 44 | Weekly Sets Overview | Existing theme checks and shared composition tracing; no additional finding established. |
| 45 | Generate Plans | Responsive/editor checks; old header-padding assertion is stale. |
| 46 | Gym Profile / Equipment | Equipment/refinement/theme checks; no additional finding established. |
| 47 | Optimized Workout Settings | Field, action, chip and large-text checks; no additional finding established. |
| 48 | Premade Plans | Narrow/large-text and filter checks; issue 3. |
| 49 | Plan / Preset Detail | Dirty-state probe, responsive/card/route review; issue 2, plus shared issue 8. |

### Shared-component observations

- Expressive exercise-detail callers route through `ExerciseDetailSheet.show`, which enables the current Catalog presentation for Expressive. Direct sheet construction is contained in that factory. No separate old Expressive detail-sheet implementation was found in the traced callers.
- The expanded image viewer has focused Expressive media-layout tests. This review did not replace its instructions, zoom/pan, or scrolling implementation.
- Dashboard composition uses the shared Expressive nutrition, analytics, history, and planning presentation paths. No new duplicate widget design was introduced or requested by this audit.
- Existing intentionally floating controls, accepted overlaps, shadows, header shapes, and approved palettes were treated as requirements. No aesthetic redesign recommendations were substituted for defects.

## Validation results

Pinned SDK: `E:/tools/flutter_sdks/3.47.5/flutter/bin/`. Flutter tests ran with `--no-pub --concurrency=1`; no dependency fetch, device build, or full test suite.

| Check | Result |
| --- | --- |
| Existing focused tests across 49 files | **591 cases: 571 passed, 20 failed**. Includes Classic/Neo guard cases; this is not 591 distinct pages. |
| Additional isolated audit probes | **14 cases:** four onboarding scaffold cases passed, two numeric/persistence confirmation cases passed, and eight expected-behavior assertions failed to reproduce defects. |
| `dart analyze --format machine lib` | **0 errors, 2 warnings, 51 informational deprecations**; nonzero exit, not a clean analyzer result. |
| `git diff --check` | Passed; Git emitted line-ending conversion notices for existing dirty files. |

The two analyzer warnings are unnecessary non-null assertions in `health_trends_section.dart:3102` and `:3361`. Informational items are maintenance work, including deprecated Radio and TickerMode APIs. They are not evidence of a new runtime failure.

### What the 20 existing-test failures mean

- **3 real layout failures:** the Premade Plans issue above.
- **10 obsolete assertions/inventory expectations:** nutrition summary text (2); old always-present plan save button (2); generation header padding (1); old anatomy information icon (1); old add-set Radio controls (1); preset/swap/anatomy inventory expectations (3). Update these to the accepted current UI; do not revert approved designs just to satisfy old assertions.
- **5 shell/tutorial harness failures:** two tests cannot find the expected initial Train page/tab, and three leave a delayed Train tutorial timer pending. Their intended shell/overlay assertions are not fully confirmed by this run.
- **2 unresolved long-metadata anatomy timeouts:** `pumpAndSettle` times out at `expressive_catalog_anatomy_responsive_matrix_test.dart:461`. No RenderFlex overflow was reported in these failures. Tutorial animation/loading isolation needs investigation before calling them application defects or passing them.

The new probes deliberately assert expected safe behavior. Their failed assertions are reproduction evidence, not application fixes or changes to the project's existing tests.

### Screen-setting coverage and limits

- Existing checks exercise narrow phones, short landscape, larger/tablet sizes, text scales up to 2×, light/dark themes, and selected French/RTL/nonlinear text, reduced-motion, safe-area, and keyboard cases.
- The broad screen-settings matrix specifically exercises Profile/navigation. It does not qualify every page at every configuration.
- New onboarding probes exercised the complete current scaffold at **320×640 / 2×** and **640×320 / 1.3×**, light and dark, with safe-area insets. They visited all currently present review-mode pages without submitting setup. An unselected equipment branch and the plan-overview-after-creation branch were not exercised by these probes.
- There was no new physical-device sweep, OS-level TalkBack session, screenshot campaign, performance soak, destructive persistence test, release build, or release qualification.
- Unreviewed caller-specific health/food dialogs, optional/unreferenced routes, placeholders, and the historical route crosswalk remain separate from the 49-page approval count. An empty unapproved gallery is not evidence that every technical state has been qualified.

## Suggested repair order

1. Fix historical nutrition day ownership and plan unsaved-change protection.
2. Fix mapping request identity, ranking commit behavior, and non-finite goal validation.
3. Fix Premade Plans large-text layout and calendar weekday alignment while retaining approved default proportions.
4. Complete change-set button accessibility and investigate the three source risks.
5. Repair stale assertions/fixtures, resolve the remaining anatomy timeouts, and rerun the affected focused checks.
6. Perform a small device review of the repaired states, including light/dark, large text, keyboard, back navigation, and delayed/failing loads.

Evidence directory: `.build/codex_expressive_full_review_20261022/`. `results-summary.json` indexes the test failures; the JSONL logs retain the assertions and Flutter layout diagnostics. `inventory.json` preserves the 49-entry scope used for this review.
