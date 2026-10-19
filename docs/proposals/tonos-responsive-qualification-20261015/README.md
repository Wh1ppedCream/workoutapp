# Tonos screen settings and responsive validation — 2026-10-15

## Outcome

**550 passed, 4 failed, 0 skipped across 45 test files**, using the latest
completed result for each test. This is a focused responsive/accessibility and
interaction run, not the full repository suite or release qualification.

One demonstrated responsive defect was corrected: the Expressive Exercise
Details Records chart legend truncated its labels at 320dp with 2× text in
both themes. It now measures the actual localized, scaled labels and stacks
them when they cannot fit side by side. Stacked labels can wrap. Normal-size
layouts that fit retain their existing appearance. Chart values, chart
geometry, series colors, and Classic/Neo presentation are unchanged.

The four remaining failures are existing presentation assertions, detailed
below. They do not establish an overflow or functional defect, but the overall
test selection is **not green**. No new visual approval is implied.

## Repository and reproducibility

- Checkout: `E:\projects\env_test`.
- Branch: `feature/expressive-visual-polish`.
- HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`.
- The pre-existing dirty/untracked worktree was preserved. Results describe
  this working tree, not the committed baseline alone.
- SDK: `E:\tools\flutter_sdks\3.47.5\flutter`.
- Tests used `flutter test --no-pub`, with concurrency limited to two in the
  completed broad runs.
- Local raw results: `build/responsive-qualification/20261015-current/`.
  The directory contains file lists, JSON test events, analyzer output, and
  `summary.json`. These build artifacts are local and may be removed by a
  future normal build-directory cleanup.

### Completed runs

| Run | Files | Passed | Failed | Interpretation |
|---|---:|---:|---:|---|
| `responsive-tests.jsonl` | 32 | 424 | 29 | Initial completed broad run; includes tests with obsolete assertions. |
| `additional-tests.jsonl` | 13 | 94 | 1 | Profile, Logbook, Dashboard, measurements, and interaction coverage; ranking expectation later corrected. |
| `final-regression-tests.jsonl` | 4 | 40 | 0 | Final Catalog, rankings, new screen-settings matrix, and Details metrics/records regression tests after correction. |
| **Latest unique results** | **45** | **550** | **4** | Later results replace earlier results for the same test; reruns are not added to the total. |

The initial `initial-tests.jsonl` run was interrupted and is not counted.
Intermediate exploratory/harness reruns are also excluded from final totals.
Two Profile regression tests have duplicate names for different theme cases;
the aggregation keeps both occurrences rather than undercounting them.

## Settings exercised

These settings were exercised by the listed tests; they are **not** a complete
Cartesian product across every route and state.

| Setting | Actual coverage |
|---|---|
| Narrow and standard phones | 320dp plus normal phone widths around 360–430dp. |
| Short screens | New Profile/navigation cases at 320×480 and 640×320; existing overlay/session tests include short landscape heights. |
| Tablets and wide layouts | Representative 600/800/1024dp cases; Dashboard additionally checks its content cap at 1440dp. |
| Landscape | Representative 640×360 and 800×360/390 cases across existing route/overlay tests; new Profile case at 640×320. |
| Text sizes | Existing matrices cover 1×, 1.15×, 1.3×, 1.5×, and 2× where specified; tutorial tests also include intermediate sizes. |
| Nonlinear scaling and direction | Existing navigation stress test combines nonlinear scaling, French labels, and RTL. This does not establish full RTL support for all routes. |
| Display density | New Profile matrix keeps logical dimensions correct at DPR 1, 2, and 3, including 411×914 and 800×1280 logical viewports. |
| Safe areas | New Profile matrix supplies 24dp top and 34dp bottom insets. |
| Keyboard | Existing session, editor, settings, generator, and dialog tests simulate keyboard insets and check action/input reachability. |
| Accessibility settings | Existing reduced-motion, semantics, focus, and touch-target tests; new Profile matrix combines bold text, high contrast, accessible navigation, and disabled animations. Enabling these flags is not a full color-contrast audit. |
| Theme families | Expressive light/dark is the primary route matrix; Classic/Neo regression cases run where available. New Profile/navigation matrix covers all six family/brightness combinations. |
| Resizing | New Profile matrix resizes the same app and checks scrolling, destination access, and return navigation. |

## Feature coverage and limits

| Area | Checks exercised |
|---|---|
| Shell and Train | Navigation labels/selection, touch targets, compact and large-text tabs, localized navigation, reduced-motion/focus tests. |
| Active Workout | Session and WeightCard compact-scale cases, editing/keyboard cases, exit confirmation and completion overlays, semantics. |
| Catalog | Root/anatomy responsive matrices, browser search/filter reset/apply, dialog bounds, browser-to-sheet navigation, sheet bounds, tabs, media/heatmap access, Metrics and Records, empty/populated data fixtures, media viewer tests. |
| Logbook | Calendar period layouts and summary states, Full History metadata/navigation, Session Detail responsive actions, keyboard/dialog cases. Some portrait calendar fixtures use tall test surfaces; they are not evidence of every physical phone height. |
| Progress and measurements | Chart accessibility/responsiveness, Exercise Progress detail, Weekly Sets Overview, measurement cards, and entry actions. Two Health Trends style assertions remain failing. |
| Profile | Root routes/scrolling; User Information edits/save and keyboard; Navigation Editor state changes; rules/dialogs; existing settings presentation checks. The new matrix exercises all seven enabled root destinations for reachability and opens/returns from Gym & Workout Settings. It does not open every child route in every scenario. |
| Plans and gym configuration | Generator, optimized settings, preset detail, premade plans, Plan Management and Gym Profile tests. Existing draft/equipment interaction tests pass; two older Gym Profile style assertions remain failing. |
| Dashboard, onboarding, nutrition | Existing selected responsive, editor, and accessibility/qualification tests. This does not approve disabled/deferred product routes or certify every populated state. |

Interaction assertions include real widget taps, scrolling, selection, filtering,
navigation/back, and mocked-repository edits/saves where the individual test
implements them. Passing an overflow assertion alone is not counted as proof
of complete functionality or persistence.

## Changes made in this pass

| File | Change |
|---|---|
| `lib/widgets/exercise_detail_sheet.dart` | Measure Records legend labels under the actual text scaler; use a wrapping stacked legend when the compact Catalog row cannot fit. This is the only production-code change in this pass. |
| `test/expressive_catalog_browser_detail_responsive_test.dart` | Update obsolete Save/header/overview/equipment/tooltip assumptions to the current approved Apply/title-pill/media-overlay UI; verify accessible heatmap naming, title containment, and untruncated chart labels. Retain geometry, interaction, and selection checks. |
| `test/theme/widgets/analytics_ranking_label_responsive_test.dart` | Use the actual Expressive light theme, apply text scaling inside MaterialApp, include 2× text, and require nonoverlapping label/input bounds rather than an obsolete mandatory stacked layout. Replace the deprecated semantics flag accessor. |
| `test/expressive_screen_settings_matrix_test.dart` | New six-family/brightness tests, each covering seven viewport/density cases, French root labels, accessibility flags, safe areas, scrolling, and navigation/back. |
| This report | Current results, coverage boundaries, defect, and remaining failures. |

Both pre-existing modified test files and the shared production file already
contained earlier work. Their full Git diffs include those earlier changes;
the descriptions above identify only this pass's edits.

## Remaining failures — not responsive fixes

| Test | Observed failure | Follow-up |
|---|---|---|
| Gym Profile recipes/draft behavior — Expressive light | Search fill expected the older equipment surface; current source uses the newer tinted section surface. | Reconcile the older recipe test with the accepted equipment palette before treating its later assertions as qualified. |
| Gym Profile recipes/draft behavior — Expressive dark | Same mismatch in dark mode. | Same. Current equipment interaction tests passed separately. |
| Progress Expressive detail uses family surfaces and matching foregrounds | Expected green increase foreground; actual foreground uses the current readable summary treatment. | Reconcile the assertion with the approved contrast treatment; do not recolor the page merely to satisfy the old test. |
| Expressive Health entry action popup keeps Tonos shape and actions | Expected older asymmetric menu shape; actual popup is rounded 14dp with its current outline. | Reconcile with the newer entry-actions treatment. Dedicated entry-action refinement tests passed separately. |

These failures occurred before their tests completed all downstream assertions.
No claim is made that those unexecuted assertions passed. The current changes
do not alter either page to force old recipe expectations to pass.

## Validation and safety

- Final four-file regression run: **40 passed, 0 failed**.
- Scoped analysis of the changed source and three test files: **No issues found**.
- Formatting check on those four Dart files: clean.
- `git diff --check` on this pass's files: clean (Git may print line-ending
  conversion notices for pre-existing LF working copies).
- No golden or style-ratchet baseline was regenerated.
- No visual approval classification was changed.
- No physical-device interaction, APK build/install, screenshot capture, or
  preview bootstrap was performed for this task. Device display settings,
  preview/production databases, WAL/SHM files, and preferences were not touched.
- No staging, commits, pushes, reset, clean, or stash.

## What remains unverified

1. Fresh human visual comparison of every approved screen at every size. Widget
   geometry/interaction results do not replace that review.
2. Physical tablet/foldable behavior, split-screen transitions, OS-specific
   keyboard/IME behavior, and screen-reader journeys on actual hardware.
3. Every route with long real user data, every localized string, and arbitrary
   window dimensions beyond the recorded representative matrices.
4. Full-application automated contrast, performance, and release qualification.
5. The four style-assertion failures above and broader repository checks not
   selected here. The full Flutter suite was not run.

Recommended next steps are to reconcile those four assertions against current
approved designs, then perform a short physical small-screen/large-text and
landscape smoke test on the approved baseline. The current approved presentation
should remain protected during that follow-up.
