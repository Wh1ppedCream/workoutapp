# Q3 Device Qualification Walkthrough

2026-09-11 reconciliation: the user reported the requested device checks
passing and accepted the screenshot baseline at 1.15. Largest-font testing
was confirmed at 2.0. The following walkthrough is retained for repeat checks;
it is not a new outstanding checklist. See the
[Q3 gate](theme-q3-readiness-gate.md) for results, exceptions and final pending
verification. Its baseline decision supersedes the initial 1.0 instructions.

Q2's scoped automated rerun passed 213 tests with clean analysis. No immediate
Dart/Flutter rerun is required for these documentation changes. This checklist
collects the remaining evidence; record unavailable checks as pending.

Post-Q3 refinement note (2026-09-16): the current 21-item Neo visual route
review is accepted, and the final selector contrast correction passed
formatting, clean analysis, and 63 focused tests. Use this walkthrough only for
the still-needed current-code device, accessibility, lifecycle, and performance
evidence; do not repeat ordinary visual review unless an affected route changes.

## 1. Prepare One Reproducible Test Build

1. Use a test profile or disposable records for workout, food, and measurement edits.
2. Record phone model, Android version, display size/resolution, app version,
   build mode, date, locale, and system font/display scale.
3. In the repository terminal, record `git rev-parse HEAD`, `git status --short`,
   and `flutter --version`. The dirty tree means HEAD alone cannot identify
   the installed app. Record when and how the installed build was produced.
4. Use English, portrait, default display size, and font scale 1.0 initially.
5. Keep the same fixtures for light/dark captures. Record their names, search
   terms, selected tabs, and scroll positions. Redact personal information.
6. If the phone is running an older build, install the current working-tree
   build using your normal development workflow before testing.
7. Do not erase app storage just to manufacture an empty state.

## 2. Capture Classic References

For each row below, open the route, let it settle, capture dark, then select
light in Profile > UI & Appearance and return to precisely the same state.
Record differences in data or scroll position rather than presenting them as
matched captures. Keep the debug ribbon/build mode consistent.

| Capture ID | Navigation and state |
| --- | --- |
| train | Train > Overview, normal populated state, bottom navigation visible |
| appearance | Profile > UI & Appearance, mode control visible |
| workout | Start a disposable workout, same exercise/set rows visible |
| catalog | Catalog, search for overhead, settled results |
| detail | Open Overhead Press - Barbell, Details tab and form guide visible |
| progress | Progress > Health Trends, same cards and scroll position |
| form | Profile > User Information, same values, keyboard closed |
| dialog | Profile > UI & Appearance > Weight Units, dialog open |
| dashboard | Capture only if exposed by your existing navigation configuration |

1. Name images by ID and mode, for example train-dark.png and train-light.png.
2. Include a missing-media and an empty measurement state if available safely.
3. Supply original Classic reference images alongside new images where available.
   New dark/light images alone cannot establish before/after parity.
4. I will compare typography, spacing, colors, corners, shadows, and density.
   Record intentional accessibility reflow separately from unexplained drift.
5. If no matching original exists, report that gap. Any substitute reference or
   exception needs explicit review; do not label newly generated images approved.

## 3. Mode Switching And State

1. Choose light, close/relaunch the app, and confirm it starts in light.
2. Repeat for dark. Note any flash of the wrong mode.
3. In User Information, edit a disposable value without saving. Select part of
   the text and note focus/keyboard state.
4. For a true live change, keep that route mounted. If system mode is available
   and active, change Android dark mode through system controls and return.
5. Repeat with a detail sheet open, a scrolled list, and a workout with one
   completed set. Confirm route, values, selected tab, scroll, and session remain.
6. If only the in-app binary toggle is available, do not navigate away and call
   that a live-modal test. Mark that case pending; I can prepare a debug test
   control once we know which state cannot be exercised on the device.
7. Returning through settings can still test navigation retention, but record
   it separately. Do not finish/delete a real workout for this check.

## 4. Text, Keyboard, And Rotation

1. Use Android accessibility/display font-size controls. Record the actual
   available setting; if exact 1.3/1.6/2.0 scales are unavailable, report the
   setting rather than claiming an exact multiplier.
2. At default, intermediate, and largest settings, open a tutorial, form,
   confirmation dialog, workout controls, and exercise detail sheet.
3. Read every label; scroll to every action and activate Back, Next, Skip,
   Cancel, or Done as appropriate. Look for clipping, overlap, unreachable
   actions, and text that disappears.
4. Focus a form field so the keyboard opens. Reach the last field and save/cancel
   controls by scrolling. Rotate while editing and while a tutorial is open.
5. Repeat representative tutorial/form/dialog checks in a supported long-label
   locale such as French. Record the actual app locale.
6. Capture each failure with route, font setting, orientation, and keyboard state.
7. Restore the original locale and font settings afterward.

## 5. TalkBack And Focus

1. Enable TalkBack using the phone's accessibility settings.
2. Swipe through Train navigation, workout actions, a form, a tutorial, and an
   exercise detail sheet. Activate items with TalkBack's double-tap gesture.
3. Record missing or misleading names, incorrect selected/disabled state,
   duplicate announcements, and unexpected traversal order.
4. Open and dismiss a dialog/sheet using its control and system Back. Confirm
   focus returns somewhere useful and background controls do not trap traversal.
5. Check form labels/errors and whether selected tabs are announced.
6. If you have a physical keyboard, use Tab/Shift+Tab and Enter/Space on
   representative controls. Record absent hardware as pending, not passed.
7. Disable TalkBack afterward if desired. A brief recording or written
   announcement transcript is useful for any issue.

## 6. Motion And Effects

1. Enable the phone's reduced/remove-animation accessibility setting.
2. Repeat tutorial transitions, chart paging, expanding plans, quick actions,
   and detail tabs. Check for excessive motion and broken or stuck transitions.
3. Repeat normal scrolling with reduced motion off and note visible stutter.
4. To inspect Theme Lab, stop the existing debug run and run:
   `flutter run --dart-define=TONOS_THEME_LAB=true`
   This flag is verified in lib/main.dart and only applies in debug builds.
5. In the gallery, toggle reduced motion and effects off. Inspect shadows,
   focus cues, scrims, and readable contrast. Gallery results cover the gallery;
   they do not establish every production overlay's behavior.
6. Stop that run and launch normally with `flutter run` to return to the app.
7. Report any production-only effects check that cannot be reached. Do not
   enable unfinished theme families or change release navigation for this test.

## 7. Media And Scanner

1. Open a known image, zoom in, pan, zoom out, then close with the visible
   control and system Back. Check that the underlying sheet/tab stays usable.
2. Test an uncached item offline where possible. Confirm fallback is readable;
   restore connectivity and check recovery where a retry control exists.
3. Open the existing barcode scanner through its normal food-flow caller.
4. Deny camera permission and confirm dismissal/recovery remains possible.
5. Grant permission through the OS controls if necessary, scan a known barcode,
   and keep it in view briefly. Confirm only one navigation result.
6. Reopen, background/resume, and dismiss. Confirm no late navigation, stuck
   camera, or unusable screen. Record permission state and device.
7. If a route is unavailable, report where navigation stopped. Do not invent
   a successful scanner/media result or clear user data to force one.

## 8. Remaining Route Acceptance

1. Exercise Train2 if exposed by the current navigation configuration and its
   preset-generation caller. Check intro, choices, summary, and cancel/back
   using disposable inputs.
2. Open reachable Nutrition Log, Pantry Log, and Plan Meal placeholders.
   Record exactly what appears and whether back navigation works.
3. Visit profile/settings pages, especially ranking, mapping, exercise editing,
   flow methods, tutorials, and database settings. Open dialogs and cancel.
   Avoid destructive database actions.
4. Record visual/behavior defects separately from unfinished product content.
5. Decide whether any reachable placeholder is acceptable for the intended
   release. I will implement a concrete gating/removal change only after that
   decision; source reachability tests alone do not make it release-approved.

## 9. Return Evidence In Small Batches

For each check, send this record (text is sufficient for passes; images are
needed for visual comparison):

| Field | Value to provide |
| --- | --- |
| Check ID / route | e.g. 4 / tutorial |
| Build and device | Reference the metadata from step 1 |
| Conditions | Mode, locale, font setting, orientation, keyboard/TalkBack |
| Actions | Exact sequence |
| Result | Pass, fail, or not tested |
| Evidence | Image/recording filenames or observed announcements |
| Difference | Expected versus observed |
| Exception | None unless explicitly reviewed and approved |

Start with metadata and the paired captures. I can then compare images and
triage failures while you work through the remaining checks. After evidence
arrives, I will update each Q3 row, fix confirmed defects, and request only
affected rechecks. A missing prerequisite remains pending until verified or
covered by a specifically approved exception.
