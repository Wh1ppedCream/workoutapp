# Train + shell Expressive review evidence

This is the final matched screenshot set for user review. Each Classic/Curated pair uses the same seeded preview content, selected Train tab, navigation destination, scroll position, focus state, app/review chrome, brightness, and normal app text scale. The intentional approximately 8 dp Expressive Train-header difference remains part of the design.

## Final matched screenshots

### Train — Overview

- Classic, light: [overview-classic-light-matched-2026-09-30.png](overview-classic-light-matched-2026-09-30.png)
- Curated Expressive, light: [overview-curated-light-matched-2026-09-30.png](overview-curated-light-matched-2026-09-30.png)
- Classic, dark: [overview-classic-dark-matched-2026-09-30.png](overview-classic-dark-matched-2026-09-30.png)
- Curated Expressive, dark: [overview-curated-dark-matched-2026-09-30.png](overview-curated-dark-matched-2026-09-30.png)

### Train — Plans

- Classic, light: [plans-classic-light-matched-2026-09-30.png](plans-classic-light-matched-2026-09-30.png)
- Curated Expressive, light: [plans-curated-light-matched-2026-09-30.png](plans-curated-light-matched-2026-09-30.png)
- Classic, dark: [plans-classic-dark-matched-2026-09-30.png](plans-classic-dark-matched-2026-09-30.png)
- Curated Expressive, dark: [plans-curated-dark-matched-2026-09-30.png](plans-curated-dark-matched-2026-09-30.png)

The matching XML hierarchy snapshots are saved beside each PNG. Files named `topcheck`, `settled-check`, early capture names, or `native-font-scale-2-*` are supporting diagnostics, not members of the final matched comparison set.

## Direct Pixel workout interaction evidence

These images and hierarchies record the physical Workout compatibility checks; they are not a Workout redesign proposal:

- [Workout collapse, center tap](workout-collapse-center-2026-09-30.png)
- [Workout expand, left-edge tap](workout-expand-left-edge-2026-09-30.png)
- [Workout collapse, right-edge tap](workout-collapse-right-edge-2026-09-30.png)
- [Exercise menu, left-edge tap](workout-menu-left-edge-2026-09-30.png)
- [Non-final set completed](workout-nonfinal-set-complete-2026-09-30.png)
- [Final set completed and card auto-collapsed](workout-final-set-complete-2026-09-30.png)
- [Both completed sets retained after reopening](workout-final-state-reopen-2026-09-30.png)
- [Train after discarding the isolated session](train-after-session-discard-2026-09-30.png)

## Native 2× text observations

The Pixel system font scale was returned to **1.15** after the temporary 2.0 checks. The app's text-scale override was set to OS/app default during those checks. At 2.0, Overview's lower content and Start/Optimize remained visible after a vertical scroll; Plans' archive, Show more, premade, and manual/generated actions were reachable after scrolling. Some long plan names ellipsized. The bottom navigation showed four destinations at once; a leftward horizontal swipe exposed Profile, and tapping its measured target opened the real Profile screen. These are native Pixel observations, separate from widget-test scaling coverage.

- [Overview before scroll at 2×](native-font-scale-2-overview-before-scroll-2026-09-30.png)
- [Overview after scroll at 2×](native-font-scale-2-overview-after-scroll-2026-09-30.png)
- [Plans before scroll at 2×](native-font-scale-2-plans-before-scroll-2026-09-30.png)
- [Plans after scroll at 2×](native-font-scale-2-plans-after-scroll-2026-09-30.png)
- [Overview after scroll, final OS-scale pass](native-os2-overview-after-scroll-final-2026-09-30.png)
- [Plans after scroll, final OS-scale pass](native-os2-plans-after-scroll-final-2026-09-30.png)
- [Navigation before horizontal swipe at 2×](native-os2-nav-before-swipe-final-2026-09-30.png)
- [Navigation after horizontal swipe at 2×](native-os2-nav-after-left-swipe-final-2026-09-30.png)
- [Profile reached at 2×](native-os2-profile-reached-final-2026-09-30.png)
- Run log: [native-large-text-qualification-2026-09-30.txt](native-large-text-qualification-2026-09-30.txt), with the subsequent navigation retry in [native-profile-scroll-qualification-2026-09-30.txt](native-profile-scroll-qualification-2026-09-30.txt).

## Motion clips

Five short clips were recorded from the running Pixel preview for human motion review:

- Overview ↔ Plans selection: [motion-overview-plans-2026-09-30.mp4](motion-overview-plans-2026-09-30.mp4)
- Bottom-navigation selection: [motion-bottom-navigation-2026-09-30.mp4](motion-bottom-navigation-2026-09-30.mp4)
- Start press/release and route to Session: [motion-start-press-release-2026-09-30.mp4](motion-start-press-release-2026-09-30.mp4)
- Rapid repeated Train selection: [motion-rapid-train-selection-2026-09-30.mp4](motion-rapid-train-selection-2026-09-30.mp4)
- Reduced-motion comparison: [motion-reduced-motion-comparison-2026-09-30.mp4](motion-reduced-motion-comparison-2026-09-30.mp4)

The clips are qualitative interaction evidence, not profile measurements. The Start clip demonstrates button press/release and route behavior; it is not a physical-latency result. The frame-timing runs did not record these videos.

## Native Back and keyboard checks

- Back dismissed preview controls while leaving Profile in place: [preview-controls-back-check-2026-09-30.xml](preview-controls-back-check-2026-09-30.xml).
- Back dismissed a plan context menu and left Train → Plans selected: [plan-menu-back-2026-09-30.xml](plan-menu-back-2026-09-30.xml).
- In Workout Session, the weight field received focus and opened the numeric keyboard; one Back dismissed the keyboard and left the session/set row visible: [keyboard visible](workout-weight-keyboard-visible-2026-09-30.png), [after Back](workout-weight-keyboard-dismissed-2026-09-30.png).
- The disposable session was explicitly canceled through the production Exit → Cancel Workout confirmation; the final Train hierarchy shows Start Workout and no ongoing-session action: [after discard](after-keyboard-discard-2026-09-30.xml).
- The Workout Timer modal was also dismissed with Back. The earlier direct exercise-menu Back check and set-completion flow remain recorded in the workout evidence above.
- TalkBack was **not tested**. No speech/announcement claim is made.

## Canonical preview build

- Package: `com.tonos.expressivepreview`
- Database: `tonos_expressive_preview.db`
- Profile APK: `build/app/outputs/flutter-apk/app-profile.apk`
- APK SHA-256: `5482D46855BA3961FD82D3FB107124C7F6AD1453DEC693F93394AEDDE1281966`
- Package version: 6 / 1.0.1
- Build log: [canonical-profile-build-2026-09-30.txt](canonical-profile-build-2026-09-30.txt)

The APK is separate from normal/internal Tonos and does not write their databases. On reconnect, the Pixel was confirmed to have version 6/1.0.1 running. The app was left at Train → Overview, Expressive / Curated / Light, explicit 1× preview text, reduced motion off, effects off, system font scale 1.15, no open overlay, and no active workout. Final app state: [canonical overview screenshot](canonical-train-overview-ready-2026-09-30.png) and [hierarchy](canonical-train-overview-ready-2026-09-30.xml). Launch from the device app drawer or use the ADB command in [the manual review guide](../qualification/manual-review.md). In-app controls switch Classic/Expressive, palette, light/dark, reduced motion, effects, and text scale; **Reset review controls** and **Reset sandbox fixtures** restore the isolated review state/content.

## Unfinished native review

- Native large-text navigation needs a horizontal swipe to reveal Profile; long plan names can ellipsize at 2×. This is documented for user judgment, not a redesign request.
- Keyboard focus and one-Back IME dismissal were checked. Broader focus-order certification was not performed.
- Native Back was checked for the review controls, a plan menu, Workout Timer modal, and return from the disposable workout. This is representative smoke evidence, not exhaustive certification.
- TalkBack: not tested; no announcement claim is made.
