# Deeper Expressive interaction review

Reviewed on 2026-10-25. This follow-up checks for unintended effects of the recent motion and pressed-state work. It preserves the approved resting layouts and does not grant any new page or animation approvals.

## Confirmed defects fixed

| Area | Reproduced problem | Change |
| --- | --- | --- |
| Nutrition floating actions on short screens | With large French text in landscape, the open menu extended above the visible screen. | Constrain the options to the page's available height and allow them to scroll when necessary. Keep the toggle outside the scrolling options so Close remains reachable. The normal menu has no added scroll viewport. |
| Nutrition floating actions in a narrow pane | Labels were measured against the full display width, allowing the buttons to extend outside a narrower page. | Measure against the smaller of the display and local layout widths, allowing the existing two-line labels and button height to adapt. |

Only `SpeedDialFab` production code changed in this pass. The existing action destinations, callbacks, menu animation, colors, normal button dimensions, spacing and alignment remain. Classic and Neo retain their previous branch.

## Test corrections

Two existing qualification assertions had become stale following intentional animation changes:

- The tab test advanced time before the changed tab had built and started its ticker. It now pumps that first frame before advancing time, then verifies the actual destination and retained Train tab state.
- The reduced-motion Rest dialog test required a route still entering and an unavailable OK action. It now verifies the immediately completed route and available action for reduced-motion Expressive. Animated and Classic cases retain their transition expectations.

No app behavior was altered to satisfy those assertions.

## Coverage and results

**197 distinct focused tests passed across 16 files**, after correcting the two stale assertions:

- **130 qualification tests:** screen-setting matrices, accessibility, overlays and navigation, compact active workouts, Catalog/details responsiveness, media-viewer layout/gestures, profile child dialogs and bottom navigation.
- **48 editing tests:** Dashboard visibility/order/save behavior, ranking saves including unsubmitted text, preset detail/edit presentation, and rule creation/editing/deletion and narrow keyboard layouts.
- **19 menu and micro-interaction tests:** ten menu responsive/normal-geometry cases and nine existing press, motion-override, accessibility and Back-navigation regressions.

The setting matrices include short/narrow phones, landscape and tablet sizes, large and nonlinear text, safe insets, localized text, RTL presentations, reduced motion and theme-family comparisons where the respective tests support them. These are rendered widget checks rather than a claim that every screen was exercised in every combination.

The new menu tests cover light/dark modes, 320dp phone width, short landscape, a keyboard inset, a 320dp pane within a wider display, and unchanged normal menu height, gaps and right alignment. Each compact action can be scrolled fully into view and hit-tested.

Changed Dart files were formatted and scoped analysis completed with no issues. `git diff --check` passed.

The offline debug build passed and the verified `com.tonos.expressivepreview` APK was installed over the existing app on the physical Pixel 7. Existing data was backed up before the install; it was not restored, reset or reseeded. The existing Nutrition goals and measurement values remain present.

On the device, the menu's normal action bounds match the pre-refresh bounds. Open/close and Android Back work, and Back keeps Nutrition Dashboard open. A bounded check of 500 log entries for the app process found no Flutter/fatal exception matches. The device is left on **Nutrition Dashboard with its floating action menu open**, in the existing light mode. The compact and dark cases were checked with rendered widget tests rather than by changing device settings.

## Limits and preserved state

- No additional Expressive defects were reproduced in the other checked areas. This is not a full test-suite run or release certification.
- The existing qualification suite explicitly classifies a known Classic inactive Progress crossfade issue; this pass does not fix or newly approve Classic behavior.
- Full TalkBack traversal, every hardware/window configuration, real-network failures and profile-mode frame timing remain outside this pass.
- No database, preferences, fixtures or approval classifications were reset or changed. Unrelated working-tree changes remain in place. No staging, commits or pushes were performed.

## Files changed in this pass

- `lib/widgets/speed_dial_fab.dart`
- `test/theme/widgets/expressive_floating_menu_responsive_test.dart`
- `test/expressive_overlay_qualification_test.dart`
- This review and its link in the animation checklist.
