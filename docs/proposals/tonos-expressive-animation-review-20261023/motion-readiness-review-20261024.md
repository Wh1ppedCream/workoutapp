# Pending Expressive motion review - 2026-10-24

This records the implementation and technical review of M05-M17 and subsequent user review. The initial technical review did not grant visual approval. Following the user's explicit approval of M05 on 2026-10-24 and M06 on 2026-10-25, the current checklist is **6 approved / 11 pending**: M01-M06 approved, M07-M17 pending. Motion approval remains separate from technical, accessibility, performance and release qualification.

## Findings and disposition

| Item | Outcome | What changed or was retained | Evidence and limits |
| --- | --- | --- | --- |
| M05 - Workout sets | Visually approved by user, 2026-10-24 | Approved active-workout feedback includes 308ms completion pulses/row tint, coordinated 360ms exercise-card expansion/collapse, retained hidden fields and the shorter 200ms final-set confirmation pause. Rapid updates start from the painted value instead of snapping. Other shared pulses and new-row arrivals retain their 280ms timing. Layout and hit targets stay fixed. | User explicitly approved the animation group after the refinements below. Latest focused validation: 27 tests, clean scoped analysis and successful debug build; Pixel 7 updated with workout progress preserved. This does not approve M06 completion-record badges, M07 planning accordions, other callers or release qualification. |
| M06 - Completion records | Visually approved by user, 2026-10-25 | Kept the restrained one-time record-badge arrival and settled historical results. The shared pulse now has a bounded settle and smoother interrupted updates. No header/stat stagger was restored. | User explicitly approved the M06 animation item. Prior evidence: arrival/no-replay regression and rendered completion palette/contract tests. No real workout was completed just to create a record during the technical review. |
| M07 - Planning accordions | Retained | Kept coordinated, monotonic expansion and the approved inset-header geometry. Added no further bouncing, staggering, or layout changes. | Pixel 7 Generate Plans cycles, plus premade-plan rendering/interaction checks. Profile results below show mostly modest frame cost but also layout outliers; this is not a blanket smoothness guarantee. |
| M08 - Workout charts | Refined | Only matching dates in the same bucket interval interpolate. Unrelated new buckets use their actual values instead of borrowing an old point's value. Idle series reuse the settled values; no animation runs when there is no value delta. Point selection remains animated. | Workout Report accessibility, point-selection, empty/single-bucket, responsive and RTL tests. No workout history was altered. |
| M09 - Menus/dialogs/sheets | Retained | Kept the existing native fade/slide recipes at 220ms opening and 160ms closing, with reduced-motion handling. Did not restore the removed extra dialog scale. | Reversible device rule-menu and unsaved-draft dialog checks, plus existing rule/menu/health-action tests. Individual overlay types still await user approval. |
| M10 - Health charts | Retained | Kept the bounded native data transitions rather than adding whole-card entrances or repeated chart sweeps. | Health chart accessibility, empty/detail/action and caller consistency tests. Existing measurement records were not edited for this review. |
| M11 - Dashboard customization | Fixed and refined | Feedback now grows smoothly. Drag feedback honors the shared effects setting. Corrected ambiguous nested row keys. Static/non-Expressive resize fallback avoids a RenderAnimatedSize layout error and preserves the live child's state across motion changes. | Dashboard interaction, reordering, visibility, saved-state, responsive and Classic/Neo/Expressive checks. Added a live-draft preservation regression for motion being disabled and re-enabled. |
| M12 - Bodypart selection | Refined through the shared pulse | Kept chip dimensions, colors, state cycle and preferred/avoided/neutral symbols. Indicators now rise smoothly rather than jumping to their enlarged size. | Pixel 7 draft-only cycles, including updated dark-mode controls, and light/dark semantic/icon tests. Updated old tests to locate the actual avatar icon through its animation wrapper; assertions still check the distinct state symbols. |
| M13 - Conditional Save Changes | Refined | Space is established before the button fades in. Reduced the scale journey from 92%-100% to 96%-100%, removed clipping of the floating surface/shadow, and shortened dismissal to 160ms. A symmetric fade curve avoids an alpha jump during rapid reversals. | New light/dark entrance, shadow-clipping and exit-input regressions. Hiding immediately disables input; no reserved space remains at rest. The approved non-resizing nutrition-menu path keeps its prior timing and behavior. |
| M14 - Rankings | Refined through the shared pulse | Kept modest native drag lift and existing row geometry. Changed-rank feedback now grows from the current painted value instead of snapping; text fields and hit targets retain their layout. | Rank-save regressions, including unsubmitted field text, and the shared rapid-retarget/static-mode checks. No saved rankings were changed on the device. |
| M15 - Progress-rule dropdowns | Refined | All options reveal together over 160ms. Removed the per-option stagger that made the last of four choices arrive later. Kept field chevrons, selection feedback, menu placement and touch targets. Effects-off uses a static menu. | Full rule editor/refinement tests and Pixel 7 four-option menu inspection. No rule was saved. |
| M16 - Progression graph | Removed unnecessary motion | Removed the extra 5px whole-canvas nudge after structural changes. It added displacement without clarifying which node or connection changed. Graph layout, panning and native control feedback remain. | Flow-screen workspace, compact/large-text, theme ownership and action tests. The stable-canvas behavior remains listed for user review; removing the effect does not auto-approve M16. |
| M17 - Onboarding | Fixed | Expressive navigation controls now wait until the current page slide settles. Queued taps cannot advance again midway through the slide. Kept progress/choice feedback and stationary titles; Finish Setup benefits from the floating-action refinement. | A queued-navigation regression and existing handoff/recovery tests. Onboarding was not replayed to completion against the user's existing preview database. Classic/Neo retain their existing navigation recipe. |

## Focused validation

- **135 tests passed** across 13 focused test files. This was not the full application suite.
- Added regressions for continuous pulse growth/retargeting, one-time arrivals, reduced motion, effects-off, inactive tickers, Classic fallback, unclipped conditional actions, rejected exit taps, retained live draft state, and queued onboarding navigation.
- Scoped Dart analysis completed with **no errors or warnings**. Ten existing Radio API deprecation information messages remain in the flow editor/rule files; those fields were not changed by this pass.
- Changed Dart files were formatted. Whitespace/diff checks were run separately.
- Both Android profile and normal debug builds completed successfully. The normal debug preview was restored after profiling.
- Source baselines confirm no changes to `main.dart`, the approved nutrition summary/menu files, the swap sheet, the approved tab-transition implementation, or the approved swap-content transition implementation.

## Pixel 7 profile sample

Device: physical Pixel 7, existing Expressive installation and data, current 1.15x system text scale. A 35-second VM timeline captured four Training focus open/close cycles. Timeline stream settings were restored afterwards, and only the review-owned ADB forward was removed.

| Trace span | Samples | Median | 95th percentile | Maximum |
| --- | ---: | ---: | ---: | ---: |
| Flutter UI Frame | 295 | 4.150ms | 9.717ms | 72.475ms |
| GPURasterizer::Draw | 295 | 2.596ms | 5.794ms | 18.060ms |

Four UI spans and one raster span exceeded a 16.67ms reference threshold. That threshold is only a reference, not a claim about the device's active refresh-rate deadline. The largest UI outlier contained about 59.2ms of layout work. These outliers remain a reason for a broader first-use/release-performance pass; the percentile numbers do not mean every transition met budget.

This sample measures the Generate Plans accordion path, not all 13 groups. It is not a cross-device frame-rate guarantee. Screenshots inspect resting/intermediate visuals; the timeline supplies the frame-cost evidence.

## Preservation and review status

- Existing dirty worktree changes were preserved. No staging, commits, pushes, resets or cleanup were performed.
- Preview databases/preferences were backed up. No reseeding, workout completion, measurement logging, saved plan editing, saved ranking changes or rule creation was performed.
- A temporary local plan edit was explicitly discarded. Bodypart selections were cycled back and exited without saving.
- Dark mode was enabled temporarily for inspection, then the original explicit light-mode preference was restored. The Expressive family and 1.15x text scale were preserved.
- Diagnostic source baselines, logs, captures and timeline JSON remain in the ignored `.build/codex_pending_motion_review_20261024/` folder. They were not added to the visual screenshot gallery.
- At the initial technical review, M05-M17 remained unchecked. The user subsequently approved M05; M06-M17 remain pending. Existing page-archetype classifications and approval ledgers were not changed.

At the end of the initial review, the normal preview was open in light mode on **Workout Progress Rules > the Quads, Hips plan-specific Add Rule dialog > Rule type menu**, with all four options visible. The rule name was empty and no rule was saved.

The subsequent M05 timing follow-up lengthened only the completed-set indicator/count pulses to 308ms. Formatting, scoped analysis, all 17 focused motion/weight-card tests, a normal debug build and the diff whitespace check passed. Hot reload could not attach, so the Pixel 7 received the updated app with its existing data retained. The ongoing **Workout Session** was reopened; Turkish Get Up and Overhead Squat - Dumbbell still showed 5/5 done, and Burpee still showed 0/4 done. No sets were toggled for this follow-up. The bounded runtime log check found no Flutter error matches. M05 remains pending the user's motion review.

A further M05 consistency fix addresses feedback appearing to snap: the Expressive header previously changed color immediately, row tint used a shorter duration, and final-set auto-collapse immediately hid and disabled the completing row. Row/header colors now use 308ms, and final-set auto-collapse waits for that feedback to finish. Completion state and persistence still update immediately. Undo/manual header interaction cancels the pending collapse; reduced motion retains immediate collapse. Eight new regressions cover light/dark transitions, repeated completion with parent rebuilds, undo, manual expansion and reduced motion. All 25 focused motion/weight-card tests passed; formatting, scoped analysis, diff whitespace checks and the debug build passed. The Pixel 7 was refreshed and left on the ongoing Workout Session, with its pre-refresh progress preserved (5/5 Turkish Get Up, 4/5 Overhead Squat - Dumbbell, 0/4 Burpee). No sets were toggled by the review; the bounded runtime log check found no Flutter error matches. Device motion still awaits the user's review.

The later M05 expansion refinement coordinates active-workout card height, corners and header geometry on the existing 360ms spatial recipe; header color now shares that header timeline, while completion pulses and row tint remain 308ms. The visited set body stays mounted offstage when closed, with input/focus/semantics excluded and tickers muted. A repaint boundary isolates its painting during the outer height reveal. Classic/Neo and preset-detail retention/timing are unchanged. Two additional light/dark regressions cover retained field state, monotonic height/endpoints and reversal without a height jump; all 27 focused motion/weight-card tests and scoped analysis passed. These checks do not establish a device frame-time guarantee.

The normal debug build passed and was installed on the Pixel 7 with existing data retained. Two Burpee expand/collapse cycles completed without runtime error matches in the bounded log check. The ongoing Workout Session remains open with Burpee expanded, and the pre-refresh completion counts are preserved (5/5 Turkish Get Up, 5/5 Overhead Squat - Dumbbell, 0/4 Burpee). No set values or completion states were changed by these checks. M05 remains pending user review.

The user subsequently requested quicker automatic closing specifically after the final set. Its confirmation pause is now 200ms instead of 308ms; the 360ms opening/closing motion and 308ms completion pulses/row tint are unchanged. The light/dark regressions now verify that automatic collapse starts at 200ms, with undo/manual cancellation still covered. All 27 focused tests, scoped analysis, formatting, diff whitespace checks and the debug build passed. The Pixel 7 was refreshed and the ongoing Workout Session reopened with its pre-refresh completion counts preserved. No sets were toggled; the bounded runtime log check found no Flutter error matches.

After these refinements, the user explicitly approved M05 on 2026-10-24. This approval covers workout set feedback, added-row feedback and active-workout exercise-card expansion/collapse, including final-set automatic closing. M06-M17 remain pending; current totals are 5 approved / 12 pending / 17 total. Earlier statements that M05 was pending describe the review state at those earlier stages.

After approving M05, the user requested 20% shorter exercise-card opening and closing. The active-workout height, corners and header geometry now use 288ms instead of 360ms. Completion pulses and row tint remain 308ms; the final-set pause remains 200ms. Added/removed-row resizing, preset-detail timing, Classic/Neo and other motion groups are unchanged. All 27 focused tests, scoped analysis, formatting, diff whitespace checks and the debug build passed. The Pixel 7 was refreshed and left on Workout Session with Burpee expanded, preserving all pre-refresh completion counts. No sets were toggled; the bounded log check found no Flutter error matches. The recorded visual approval preceded this explicitly requested timing adjustment; approval totals remain 5 approved / 12 pending.

## Files changed in this pass

Application:

- `lib/theme/widgets/tonos_expressive_state_motion.dart`
- `lib/theme/widgets/tonos_expressive_navigation_motion.dart`
- `lib/widgets/workout_metric_chart_card.dart`
- `lib/screens/dashboard_page.dart`
- `lib/screens/profile/settings/flow_methods_page.dart`
- `lib/screens/exercise/auto_preset_flow_screen.dart`
- `lib/screens/onboarding_flow.dart`
- `lib/widgets/weight_card.dart` (M05 follow-up)

Tests:

- `test/theme/widgets/expressive_pending_motion_test.dart` (new)
- `test/theme/widgets/onboarding_handoff_regression_test.dart`
- `test/theme/widgets/bodypart_focus_chips_expressive_test.dart`
- `test/widgets/weight_card_expansion_test.dart` (M05 follow-up)

Review documentation:

- `README.md` in this folder
- This report
