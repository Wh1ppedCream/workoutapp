# Active Workout Expressive adaptation results

This is a preview-only adaptation of the approved Train + shell reference
language. The Active Workout data flow remains `SessionScreen → ExerciseCard →
WeightCard`, with `ActiveSession` retaining ownership of workout state.

## Visual and interaction changes

- The session route uses the approved warm page canvas. The elapsed-session
  drawer keeps its current location and live value, with the value receiving
  focal purple emphasis. No rest timer was added because the current route has
  no rest-timer control.
- Expressive exercise cards use a neutral outer surface, a modest purple-toned
  header, compact asymmetric card geometry, and lower-chroma set rows. Complete
  exercises retain their semantic green state.
- Numeric fields remain compact and use raised tonal surfaces. Their labels
  sit above the field outline to avoid collisions; the focused outline is
  primary purple. Set values, units, input order, callbacks, and validation
  remain owned by the existing `WeightCard` flow.
- Finish remains fixed at the bottom as the focal purple action. Add Exercise
  keeps its existing floating position as a teal supporting action. Expressive
  sessions reserve an 80 dp lane in the list viewport above the FAB, so visible
  set controls cannot be covered; later rows remain scroll-reachable.
- The Expressive exercise menu retains `MenuAnchor`, action order, callbacks,
  confirmation, and dismissal behavior. Its anchor is shifted 12 dp inward so
  action labels retain a visible screen-edge inset. Classic/Neo menu placement
  is unchanged.
- The workout-completion bottom sheet remains the existing result summary; the
  finish callback, save path, summary content, and Done behavior are unchanged.

## Motion and behavior

- The accepted controlled WeightCard reveal remains 180 ms, using the existing
  `TweenAnimationBuilder`, `ClipRect`, and `Align.heightFactor` path. Reduced
  Motion still resolves it immediately.
- The outer exercise-card silhouette changes role shape with expansion through
  a separate quick, standard-curve transition. Focal Finish and supporting Add
  Exercise use the shared Tonos press-response tiers without delaying callbacks.
- Repeated set completion updates business state immediately and remains a
  standard checkbox response with semantic green. No per-row bounce, page-wide
  celebration, or moving text was added.
- A focused weight field can be edited and retains sensible focus/IME behavior.
  The 80 dp viewport lane remains clear above the keyboard; the list scrolls
  within its reduced viewport.

## Pixel 7 checks

- Device: Pixel 7 `28021FDH200228`.
- Isolated package/database: `com.tonos.expressivepreview` /
  `tonos_expressive_preview.db`. The normal `com.tonos` app/database were not
  touched. No app data was cleared; only the isolated preview fixture was reset
  through its own controls after the Finish result flow.
- Installed preview: versionName `1.0.1`, versionCode `6`; APK SHA-256
  `1B765D233F3BABFFC612973686409BF2E6AC010D5458583CF4F5A529F6F13515`.
- Live checks: open/close an exercise; tap a set 24 times rapidly (it returned
  to unchecked); edit a weight from 20 to 25 and back; complete three sets and
  verify the exercise remains open before the final set, then auto-collapses at
  3/3; open/dismiss the exercise menu; open and return from the Exercise
  Catalog without adding; open/dismiss the elapsed-timer drawer; and finish the
  preview workout to the existing completion summary.
- Keyboard-visible light/dark captures show the focused field remains visible
  and Add Exercise stays above the IME and outside the clipped list viewport.
- The menu was rechecked after its Expressive-only inset adjustment in light
  and dark mode. The action text is fully visible with about 30 px of right
  inset on the Pixel; the popup surface itself reaches the display edge.
- Reduced Motion was checked through the preview control; the dark-mode
  capture is `review/expressive-dark-reduced-motion-active-workout.png` with
  `review/reduced-motion-control-enabled.xml`. It was restored to its original
  off state, and the app was left at Train Overview. Compact width is covered
  by widget tests, not a live device setting.
- Android `screenrecord` produced zero frames/zero-byte files in repeated
  attempts, including a controlled five-second capture. A separate host-side
  `scrcpy` recording was skipped because a pre-existing `scrcpy.exe -S` process
  was using the device and was left untouched. No motion videos were produced;
  do not interpret empty MP4 files in the folder as evidence clips.

## Validation

Toolchain: Flutter 3.47.5, Dart 3.13.4.

Focused command:

```text
flutter test --no-pub test/expressive_active_workout_presentation_test.dart test/widgets/weight_card_menu_anchor_test.dart test/widgets/weight_card_expansion_test.dart test/theme/widgets/weight_card_theme_scope_test.dart
```

Result: 31 passed, 0 failed, 0 skipped, exit code 0. Scoped analysis on the
changed workout source/helper and presentation tests reported no issues. `git
diff --check` passed. The full suite is deferred until the user approves this
Active Workout visual direction. No persisted Expressive family, preference,
dependency, or app-wide theme rollout was introduced.
