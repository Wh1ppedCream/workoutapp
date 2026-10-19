# Exercise Browser and detail-sheet caller consistency — 2026-10-15

Branch: `feature/expressive-visual-polish`; HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f` plus the existing uncommitted worktree.

## Scope and result

All production references to `ExerciseCatalogPage`, `ExerciseDetailSheet`, and their imports were traced. There are eight external Browser construction sites and five detail-sheet helper call sites. The shared Add Exercise caller serves both plans and active workouts; the shared anatomy row serves both body-part and muscle detail pages. No additional direct sheet construction or named Browser route was found in production source.

The approved Catalog presentation is now selected centrally whenever `ExerciseDetailSheet.show` is invoked from Expressive. Callers no longer need to opt into both presentation flags. Classic and Neo retain their existing branches. This change does not grant visual approval to the calling pages.

## Browser entry points

| User entry point | Source owner | Finding / action | Verification |
| --- | --- | --- | --- |
| Catalog → Exercise Catalog | `lib/screens/catalog_page.dart` | Already passes the Expressive flag and Catalog destination scope. | Source trace; Browser rendering tests. |
| Dashboard → Exercise Catalog card | `lib/widgets/dashboard_sections.dart` | Already passes the actual family and Catalog scope. | Source trace; route contract test. |
| Train → drawer → Exercise Catalog | `lib/screens/exercise/train2_page.dart` | Already passes the actual family and Catalog scope. | Source trace; route contract test. |
| Plan editing / active workout → Add Exercise | `lib/widgets/add_exercise_fab.dart` | Now derives Browser presentation from the actual theme instead of its optional parent styling flag. Both existing parents already supplied the correct flag; this closes the default-argument hole. | Light/dark picker selection and cancellation tests; parent constructors traced in `preset_detail_screen.dart` and `session_screen.dart`. |
| Plan detail → Swap Exercise → browse Catalog | `lib/widgets/swap_exercise_sheet.dart` | Already passes the actual family and Catalog scope. | Source trace; light/dark selection/confirm and cancellation tests. |
| Progress → exercise-progress section → add exercise | `lib/widgets/exercise_progress_section.dart` | Already applies the Catalog presentation and scope; retains its add-tile callback. | Source trace. |
| Profile → Gym & Workout Settings → Workout Settings → Exercise Set Allocation → choose exercise | `lib/screens/profile/settings/exercise_analytics_screen.dart` | Already applies the Catalog presentation and scope; retains the returned definition. | Source trace; existing picker navigation test. |
| Profile → Gym & Workout Settings → Workout Settings → Exercise Editor → choose exercise | `lib/screens/profile/settings/exercise_editor_screen.dart` | Already applies the Catalog presentation and scope; retains selection and the editing guard. | Source trace; existing editor presentation tests. |

## Detail-sheet entry points

| User entry point | Source owner | Before | After / verification |
| --- | --- | --- | --- |
| Any Browser above → exercise information / thumbnail | `lib/screens/exercise/exercise_catalog_page.dart` | Both approved presentation flags supplied. | Preserved; light/dark Browser and shared-sheet widget tests. |
| Target Anatomy → selected Bodypart / Muscle → exercise information | `lib/widgets/exercise_definition_info_tile.dart`, used by both anatomy detail pages | Catalog anatomy supplied only the first flag; analytics-scoped anatomy could supply neither. | Central helper selects both flags and Catalog tokens. Light/dark tests open the actual information tile under Catalog and Analytics scopes. |
| Plan detail → exercise information, including the editing presentation | `lib/screens/exercise/preset_detail_screen.dart` | No Expressive flags supplied. | Central helper selects the approved sheet. Source call trace plus default-caller light/dark rendering tests. |
| Active workout → exercise information | `lib/screens/exercise/session_screen.dart` | No Expressive flags supplied. | Same central fix; default-caller light/dark rendering tests. |
| Logbook → Past Workout / Session Detail → exercise information | `lib/screens/exercise/session_detail_screen.dart` | No Expressive flags supplied. | Same central fix; light/dark rendering tests from a Logbook-scoped caller. |

The shared sheet tests verify the title/close treatment, media framing, heatmap launcher, enlarged media viewer and expanded Form guide, zoom/pan, vertical scrolling, dismissal, and return to the caller. They also cover a Progress-scoped caller and Classic/Neo defaults in both brightness modes.

### Nested Records navigation

The sheet previously forwarded its Catalog destination palette into Records → Past Workout. That bypassed the established Logbook-specific Session Detail presentation. The destination now explicitly uses Logbook tokens in Expressive. Light/dark widget tests open a persisted session ID, check the destination family, return, and confirm the Records content and Catalog scope remain intact. No Session Detail source or layout was changed.

## Validation

SDK: `E:\tools\flutter_sdks\3.47.5\flutter`.

- Core focused run: **83 tests passed** across Browser presentation, caller/media parity, route contracts, anatomy information tiles, Metrics/Records, swap picker, and Exercise Set Allocation tests.
- After adding Records → Past Workout → return assertions: **8/8 Metrics/Records tests passed**. These eight are included in the core 83, not an additional eight unique tests. The test harness disables the unrelated Past Workout onboarding tutorial to avoid a pending tutorial measurement timer.
- Additional existing responsive/parent-screen run: **162 passed, 24 failed** across `expressive_catalog_browser_detail_responsive_test.dart`, `expressive_catalog_anatomy_responsive_matrix_test.dart`, `preset_detail_screen_theme_test.dart`, and `exercise_editor_expressive_presentation_test.dart`.
- All 24 failures are in the unchanged `expressive_catalog_browser_detail_responsive_test.dart`: 16 tests search for the old filter action `commonSave` rather than the current `catalogApplyFilters`; eight expect the old full purple header background rather than the approved title-pill treatment. The file also retains obsolete separate-overview assertions that those failures prevent reaching. The Browser caller already passed both sheet flags before this task, so this audit does not change that caller's rendering. Those stale expectations were recorded rather than changing the approved UI to satisfy them.
- Scoped analysis of the two edited production files and four edited test files: **no issues**.
- Formatting and `git diff --check`: passed.

## Boundaries

This is exhaustive source-level caller discovery with focused rendered-widget coverage, not a physical-device walkthrough of every workflow. No device navigation, screenshots, APK build, installation, database access, or preview preference changes were performed. The Pixel 7 installation has not been refreshed by this task.

Approval ledgers and classifications were not changed. No production caller layouts, domain calculations, selection callbacks, persistence, Classic/Neo styles, or preview records were edited. Nothing was staged, committed, or pushed.
