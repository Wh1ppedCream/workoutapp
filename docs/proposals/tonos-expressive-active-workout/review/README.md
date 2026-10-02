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
- The full repository suite is intentionally deferred until the Active Workout
  design direction is approved.
