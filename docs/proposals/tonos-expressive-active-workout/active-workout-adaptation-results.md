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

## Production-preview refinement follow-up — 2026-10-02

This is a narrow refinement of the isolated Active Workout preview. It does not
expand the Expressive scope to another destination or change the Train + shell
reference baseline.

### Changes in the current candidate

- The Expressive exercise header uses a tighter layout and larger thumbnail;
  the completed exercise header now uses the semantic completed-exercise green
  role, while an incomplete header remains primary-tonal. Completion fills use
  preview theme surface tokens, and the completion palette is separate from
  Classic/Neo and the existing summary accent.
- Set-row completion and exercise completion use distinct semantic green roles.
  Completed-state fill transitions are local and fill-only, using the existing
  Tonos motion duration policy. The weight/reps fields have separately routed
  hit/focus regions so each field remains independently usable.
- The preview success ladder is: light accent/header/row `#286F3A` / `#4F9560`
  / `#C2E7C7`; dark accent/header/row `#5EB171` / `#286A3A` / `#83C98F`.
  Outer-card and completed-row fill factors are `0.18` and `0.56` light / `0.42`
  dark, respectively.
- Add Exercise remains a floating overlay above the scrollable workout list.
  The previous fixed 80 dp reserved viewport lane has been removed; the list
  instead has minimum end-of-list scroll clearance so final controls can be
  scrolled clear of the FAB without permanently reducing the visible viewport.
- Classic and Neo presentation paths remain unchanged. No production theme
  family or persisted selection was added.

### Focused validation so far

- Focused widget tests: **38 passed**, 0 failed; these cover the current workout
  presentation, completion palette, field/action geometry, and related
  interactions.
- After the FAB regression was strengthened to drag to the true maximum scroll
  extent and check the final checkbox, Weight/Reps fields, and Remove Set
  target, its focused file rerun passed **2/2** tests.
- Scoped Dart analysis on the changed workout sources and focused tests: clean.
- `git diff --check`: passed.
- Full Flutter suite: intentionally deferred until after user review.

### Pixel 7 review and captures

Device `28021FDH200228` (Pixel 7, `panther`) ran the isolated
`com.tonos.expressivepreview` profile build, versionCode 6 / versionName 1.0.1,
using `tonos_expressive_preview.db`. APK SHA-256:
`061D31C9992D17D4C5F6341F5BA30F594017E93C3860E11D50A32FD6B104CDEF`. Normal
`com.tonos` data was not touched or cleared.

Fresh matched light/dark captures and UI hierarchy XML are under
`review/refinement-20261002/`. They cover 0/3 with multiple exercises, focused
numeric entry, 2/3, 3/3 auto-collapse, reopening a completed exercise, menu,
finish flow, bottom/max-scroll clearance, and closeups of the complete and
incomplete headers, completed row, numeric field, and FAB. Light mode also has
a ~24-toggle recovery capture. Reduced Motion was enabled for collapse/reopen,
verified to change state immediately, then restored to off.

At true maximum scroll, the last set controls clear the FAB in both modes. The
final Remove Set target had about **84 dp** vertical clearance from the FAB;
the permanent reserved viewport lane is absent. In an intermediate
keyboard-visible position, the FAB can cover lower row actions. A list drag
scrolls while retaining the focused Reps value for one gesture; further
scrolling dismisses the keyboard/focus under the existing `onDrag` keyboard
policy, and the entered value remains intact. This preserves current keyboard
behavior, but the interim overlap is included in the user review evidence.

No video was produced because the existing `scrcpy.exe -S` process was left
untouched. Still captures and live interaction checks were used instead.
The preview was left in its isolated dark Active Workout session with the
keyboard hidden.
