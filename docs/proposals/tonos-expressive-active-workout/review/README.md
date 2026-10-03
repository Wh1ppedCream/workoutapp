# Active Workout Expressive review evidence

This folder contains matched screenshots and UI hierarchies from the isolated
Tonos Expressive preview. It is review evidence for the Active Workout slice,
not a rollout of Expressive to other destinations or a persisted theme family.

## Build and fixture

- Device: Pixel 7, `28021FDH200228`.
- Package: `com.tonos.expressivepreview`.
- Database: `tonos_expressive_preview.db`.
- Installed preview: versionName `1.0.1`, versionCode `6`; APK SHA-256
  `1B765D233F3BABFFC612973686409BF2E6AC010D5458583CF4F5A529F6F13515`.
- Fixture: Active Review 1, with Ab Wheel, Arm Circles, and Arnold Press; three
  sets per exercise at 20 lbs × 10 reps.
- The normal `com.tonos` app and its database were not used or changed.

## Matched static comparison

Each numbered state uses the same content and scroll position in Classic and
Expressive, in both light and dark mode:

| State | Captures |
|---|---|
| Fresh workout | `classic-light-01-fresh-workout.png`, `expressive-light-01-fresh-workout.png`, and the matching `classic-dark` / `expressive-dark` files |
| One exercise expanded | `*-02-one-expanded.png` |
| Partial completion | `*-03-partial-completion.png` |
| Completed exercise | `*-04-exercise-completed.png` |
| Multiple exercises | `*-05-multiple-exercises.png` |

Each PNG has a same-name `.xml` UI hierarchy capture. The `02` state has only
Ab Wheel expanded; the other exercise cards are collapsed. Completion states
show the same persisted set content in the paired themes.

## Additional interaction states

- Keyboard visible: `expressive-light-keyboard-visible.png` and
  `expressive-dark-keyboard-visible.png`, with corresponding XML captures.
- Exercise menu: `expressive-light-menu-adjusted.png` and its XML capture.
  The Expressive menu action text now has about 30 px of right inset on Pixel 7;
  the popup surface itself still reaches the screen edge. The matching dark
  captures are `expressive-dark-menu-adjusted.png` and its XML.
- Add Exercise catalog: `expressive-light-add-exercise-open.png` and XML.
- Finish result sheet: `expressive-light-finish-confirmation.png` and XML. The
  existing finish action opened the workout completion summary directly.
- Elapsed timer drawer: `expressive-light-timer-drawer-open.png`.
- Reduced Motion: `expressive-dark-reduced-motion-active-workout.png`, with
  `reduced-motion-control-enabled.xml`. Motion was restored to its original
  off state after capture; the preview was left at Train Overview.

The device's `screenrecord` utility returned zero-frame, zero-byte output on
repeated attempts, including a controlled five-second run. No motion videos are
included; a separate `scrcpy` recording was skipped to avoid interfering with
the already-running device mirror. Expansion, rapid set tapping, field editing,
completion, menu, catalog, finish, timer, and Reduced Motion interactions were
exercised live on the preview. The compact-width case is covered by widget tests
rather than a live device setting. See the accompanying handoff/results note
for the exact device checklist and any unverified live states.

## Validation

- Pinned toolchain: Flutter 3.47.5 / Dart 3.13.4.
- Focused Active Workout, WeightCard menu/expansion, and theme-scope suites:
  31 tests passed, 0 failed, 0 skipped.
- Scoped analyzer: no issues. `git diff --check`: passed.
- At this earlier review checkpoint, the full repository suite was deferred
  until the Active Workout direction was approved. The final suite is recorded
  below.

## Current spacing-polish captures — 2026-10-02

These are current-source Pixel 7 (`28021FDH200228`) captures from the isolated `com.tonos.expressivepreview` package using `tonos_expressive_preview.db`. The normal `com.tonos` app/database were not targeted. They are **local/untracked review evidence**, not checked-in assets; the paths below identify local files only and intentionally do not create Markdown image links.

Capture directory: `docs/proposals/tonos-expressive-active-workout/review/spacing-polish-20261002/`

| Filename | State shown |
|---|---|
| `01-expanded-completed.png` | Completed exercise expanded, all three sets checked. |
| `02-expanded-partial.png` | Expanded exercise with two of three sets complete. |
| `03-collapsed.png` | Completed exercise collapsed after final-set auto-collapse. |
| `04-multiple-exercises.png` | Two exercise cards visible together: completed/collapsed Ab Wheel and expanded Arm Circles. |
| `08-dark-expanded.png` | Dark-mode expanded workout with the current completed/partial card state. |
| `06-reduced-motion-expanded.png` | Expanded state after Reduced Motion interaction. |
| `07-rm-collapse.png` | Collapsed state after Reduced Motion interaction. |
| `restore-controls-verified.png` | Preview controls after restoring light mode and turning Reduced Motion/effects off. |

Matching UI hierarchies are available beside the corresponding captures as `.xml` files. `rm-expand-result.png` is an additional immediate expanded-state capture. The screenshots use matching workout content/state where paired; the light completed/partial/collapsed states intentionally differ to document behavior. The multi-exercise image is not a matched light/dark pair.

### Current recipe note

The current light completion palette is header `#35A457`, completed rows `#7BCB8B`, and completed outer surface `#D9F0DC`; dark completion colors remain unchanged. Card rhythm is 6 dp / 1 dp / 6 dp, Add Set bottom inset is 8 dp with at least a 48 dp target, and the representative expanded card is about 25 dp shorter than the preceding spacing candidate. The 180 ms reveal, immediate Reduced Motion behavior, existing final-set auto-collapse, floating Add Exercise overlay without a permanent dead lane, maximum-scroll clearance, fixed Finish action, and elapsed timer drawer remain part of this current preview state.

## Final host qualification — 2026-10-02

- Flutter 3.47.5 / Dart 3.13.4; normal C: `TEMP`/`TMP` and default concurrency.
- One uninterrupted `flutter test --no-pub --reporter expanded`: **1,320 passed, 0 failed, 0 skipped, exit 0**, 728.9 seconds (12m 8.9s). Log and JSON result: `%TEMP%\tonos_full_suite_qualification_final_20261002_run2`.
- Repository-wide analysis: **0 errors, 0 warnings, 80 informational deprecation notices, exit 0**.
- Inventory: **297 Dart files / 2,473 candidates / 132 allowlisted / 2,341 migrated / 0 pending / 0 unassigned / 0 overlaps**; 1,002 uniquely queued and 1,471 outside configured queues. Ratchet report/enforcement passed unchanged for 18 protected files, 158 approval entries, 154 unique fingerprints, and 180 occurrences.
- Focused qualification runs: responsive-scale/compact-width 7/7; theme tokens 18/18; inventory/ratchet contracts 71/71; focused interaction coverage 8/8. These test groups overlap.
- The Pixel 7 current-source evidence above verifies light/dark completion states, multiple exercises, and Reduced Motion. Live interaction covered set editing, rapid completion, non-final completion, final-set collapse/reopen, and menu Back. Profile frame-time qualification and native TalkBack remain untested.
- `git diff --check` passed for technical changes. The user approved inclusion of the unchanged pre-existing user-authored geometry correction in this qualification checkpoint; other protected working-tree changes are excluded.
