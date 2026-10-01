# Tonos Expressive Train review

This review guide covers the current **Train → Overview**, **Train → Plans**, and shared bottom-navigation shell in **Tonos Expressive Preview**, package **com.tonos.expressivepreview**, using the sandbox database **tonos_expressive_preview.db**. The user has approved this visual/motion language as the current reference baseline, and this slice is technically qualified. That status does not approve production rollout or any other destination. The preview is not persisted to the normal Tonos install.

The proposal keeps the existing Tonos screen hierarchy, plan and workout content, bottom-navigation destinations, and actions. It adds the current Expressive treatment to those existing elements.

## Review on Pixel 7

1. Open **Tonos Expressive Preview** from the app drawer. It starts on **Train → Overview**.
2. Tap the sliders control at the upper right, above the Overview / Plans selector.
3. Select **Expressive** under Rendered recipe and **Curated** under Palette treatment.
4. Choose **Light** or **Dark**. For the normal interaction review, leave **Reduced motion** and **Effects off** disabled. Leave text scale at **OS/app default** for comparison.
5. Tap **Done**. To compare with Classic, reopen the controls and change only Rendered recipe; keep the palette, brightness, text scale, route, and scroll position the same.
6. The current Pixel 7 is at 1.15 OS font scale. The final light screenshot shows the updated responsive Focused Sets panel with “more” visible and no overflow. At scale 1.15 it grows to 220.5 dp; at 2x the widget test verifies the stacked layout.

The controls and sample data belong to the isolated preview. **Reset review controls** restores Expressive / Curated / Light and default motion. **Reset sandbox fixtures** restores the sample plans in the preview database.

## What to inspect and do

| Screen / route | Current Tonos content retained | Expressive treatment to compare | Try this |
|---|---|---|---|
| **Train → Overview** | Overview / Plans tabs, profile avatar, Weekly Overview, Active Plans, split Start Workout / Optimize action, and the existing five-destination navigation | Plum focal card, warm canvas, tinted anatomy inset, traveling Focused Sets progress wave, plan-identity blocks with subtly tinted heatmap fields, purple Start, teal Optimize, and a springing selected navigation fill | Leave the screen untouched for 10–15 seconds and watch the Weekly Overview surface/accent marks/progress wave. Compare the wave at Shoulders, Lower Back, and Core: lengths stay tied to their values while the contour travels. Tap Focused Sets → More, an Active Plan row, its menu, the edit button, Start Workout, and Optimize. Use only the preview database. |
| **Train → Plans** | Existing Active Plans, Archived Plans, Premade Plans, Generate Custom, and Manually Add sections in their established order | Filled identity-bearing rows on both sections; 12% plan-color tint over the neutral heatmap field keeps anatomy markings readable; menu and edit controls use smaller tactile responses | Tap Plans beside the profile avatar. Compare blue, orange, and green thumbnail fields in light and dark. Tap Show 1 more and watch rows enter. Open and dismiss a row menu. Scroll to Archived and Premade, then view Generate Custom and Manually Add. |
| **Train shell** | Train, Catalog, Logbook, Progress, Profile; destination count, order, placement, and callbacks are unchanged | Tinted navigation surface with a springing selected fill and high-contrast selected icon/label; supporting touch compression on destinations | Tap Catalog, Progress, Profile, then Train to watch the selected fill move. Other destinations’ screen styling is outside this review. |
| **Reduced motion** | Same content, layouts, colors, and callbacks | Static Expressive resting geometry; no continuous surface, progress, or accent movement | In preview controls, enable Reduced motion, return to Overview, and leave it for 10 seconds. The content remains expressive and stable. Tab/navigation callbacks remain immediate. Disable it again after comparison. |
| **Effects Off** | Same content and workflows | Same stop/reset behavior as the preview’s animation-disable path | Toggle Effects Off separately if you want to confirm the second route to the same no-motion state. |

The Optimize callback shows its existing recovery warning for the seeded sample state; dismiss it with **OK**. Start Workout enters the disposable preview session; no normal Tonos data is involved. If you want to return to the visual review after opening that route, exit and relaunch Tonos Expressive Preview from the app drawer; it starts again on Train → Overview.

## Matched Pixel 7 stills

The final captures below use the restarted preview build, the same 1.15 OS font scale, seeded content, selected Train destination, and matching scroll state within each light/dark pair.

### Train → Overview

- [Expressive light — Pixel 7 final capture](current-refinement-20261001/overview-expressive-light-final.png)
- [Expressive dark — Pixel 7 final capture](current-refinement-20261001/overview-expressive-dark-final.png)

### Train → Plans

- [Expressive light — Pixel 7 final capture](current-refinement-20261001/plans-expressive-light-final.png)
- [Expressive dark — Pixel 7 final capture](current-refinement-20261001/plans-expressive-dark-final.png)

### Plan-card and menu close-ups

- [Active plan cards — light](current-refinement-20261001/plan-cards-active-review-light.png)
- [Active plan cards — dark](current-refinement-20261001/plan-cards-active-review-dark.png)
- [Open active-plan menu](current-refinement-20261001/plan-menu-open.png)

The active plan row and its identity block share the same asymmetric expressive corner silhouette. Saturated identity color stays concentrated at the leading edge; each heatmap background blends its plan accent into the media-placeholder surface at 12%.

## Motion evidence

- [Weekly Overview untouched for 15 seconds](current-refinement-20261001/weekly-overview-idle-final-15s.mp4) — recorded after a full preview restart, with no user interaction during the capture.
- [Plan-card tactile response](current-refinement-20261001/plan-card-tactile.mp4)
- [Plan controls, menu, edit, and Show 1 more](current-refinement-20261001/plan-controls-edit-menu-show-more.mp4)
- [Start Workout touch and isolated session route](current-refinement-20261001/start-workout-touch-final-6s.mp4)
- [Optimize touch and its current recovery result](current-refinement-20261001/optimize-touch-final-6s.mp4)
- [Optimize recovery dialog still](current-refinement-20261001/optimize-final-settled.png)
- [Profile/avatar touch and existing drawer](current-refinement-20261001/profile-avatar-touch-final-5s.mp4)
- [Reduced-motion Overview idle for 10 seconds](current-refinement-20261001/weekly-overview-reduced-motion-final-10s.mp4)
- [Reduced-motion Expressive Overview still](current-refinement-20261001/overview-expressive-reduced-motion-final.png)

For a normal-motion run, switch back to Expressive / Curated / Light and leave Reduced motion and Effects Off disabled. For a reduced-motion run, turn on Reduced motion; the surface resets, the accent and wave stay still, and interaction state changes remain immediate.

## Motion and implementation contract

- Weekly Overview is the only continuous ambient surface. It runs with a 3 second half-cycle (6 seconds per surface round trip), and interpolates up to 42% toward its inset tone. Accent bars and Focused Sets wave share that phase.
- Focused Sets keeps the existing progress values and native progress semantics. The active segment is a 2.5 dp sinusoidal stroke, lifted 8% toward white from the existing warm role, with 1.5 dp amplitude and 20 dp wavelength. Its straight 1.5 dp remainder track begins at the active extent and is clipped away from the wave; the active horizontal extent stays exactly `width × value`, with a quiet 3 dp terminal dot at the track end.
- The Weekly Overview anatomy field blends 15% toward its plum inset tone in light mode and 20% in dark mode. The anatomy colors are resolved against that surface; the drawing itself and its blue data highlights are unchanged.
- The Overview heatmap and Focused Sets row use their natural side-by-side height, with the anatomy centered vertically against the details. They stack at text scale 1.35 or above, or below 340 dp available width; large-text reflow does not add a fixed blank band.
- Start Workout, Optimize, and the settings gear retain the same bounds and callbacks. Their release spring is capped at the resting paint bounds inside the action bar's fixed rounded clip, preventing the prior overshoot crop while preserving the inward press response.
- Ambient work is gated by Overview selection, at least 24 dp visibility, TickerMode, app lifecycle, and MediaQuery’s animation-disable policy. A shared controller drives the card; RepaintBoundaries isolate accent/progress painting.
- The train tabs and five-item navigation use the existing spring selection indicator. Press wrappers remain paint-only; their child controls continue owning hit tests, semantics, and callbacks.
- Reduced motion stops/resets the ambient phase, fixes progress at its static shape, disables press/reveal/selection motion, and makes content-size changes near-immediate.
- No idle profile/gym spinner is included. The profile/avatar only responds while pressed.

See [motion-inventory.md](motion-inventory.md) for the per-control motion tiers, amplitudes, spring settings, clipping boundaries, and reduced-motion behavior.

## Validation recorded for this refinement

The focused eight-file Train/plan/motion/accessibility batch passed **57 tests, 0 failures** on Flutter 3.47.5 / Dart 3.13.4. Scoped Dart analysis reported **No issues found**. The 1.15 Pixel 7 capture after hot restart has no RenderFlex overflow; widget coverage checks 1.15 Pixel geometry and the 2x stacked layout. The full suite and final expensive qualification campaign were intentionally not run in this refinement stage.

## Latest focused refinement — 2026-10-01

This is the current review evidence for the requested Train/shell polish. The preview was rebuilt and relaunched on Pixel 7 `28021FDH200228` from package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`. The device was left on Train → Overview, Light, Reduced Motion off, Effects Off off, with no dialog, keyboard, or active preview workout.

### Matched stills and close-ups

- [Train Overview — light](expressive-polish-20261001/overview-light.png)
- [Train Overview — dark](expressive-polish-20261001/overview-dark.png)
- [Train Plans — light](expressive-polish-20261001/plans-light.png)
- [Train Plans — dark](expressive-polish-20261001/plans-dark.png)
- [Blue plan heatmap — light / dark](expressive-polish-20261001/plan-blue-light.png) · [dark](expressive-polish-20261001/plan-blue-dark.png)
- [Orange plan heatmap — light / dark](expressive-polish-20261001/plan-orange-light.png) · [dark](expressive-polish-20261001/plan-orange-dark.png)
- [Green plan heatmap — light / dark](expressive-polish-20261001/plan-green-light.png) · [dark](expressive-polish-20261001/plan-green-dark.png)
- [Weekly Overview anatomy field — light / dark](expressive-polish-20261001/weekly-heatmap-light.png) · [dark](expressive-polish-20261001/weekly-heatmap-dark.png)
- [Focused Sets wave — light / dark](expressive-polish-20261001/focused-sets-wavy-light.png) · [dark](expressive-polish-20261001/focused-sets-wavy-dark.png)
- [Action bar at rest — light / dark](expressive-polish-20261001/action-bar-rest-light.png) · [dark](expressive-polish-20261001/action-bar-rest-dark.png)

### Motion clips

- [Focused Sets wave and ambient idle, untouched](expressive-polish-20261001/focused-sets-wave-idle.mp4)
- [Start / Optimize / settings gear tactile checks](expressive-polish-20261001/action-bar-tactile.mp4)
- [Weekly Overview untouched idle](expressive-polish-20261001/weekly-overview-idle.mp4)
- [Reduced Motion idle](expressive-polish-20261001/reduced-motion-idle.mp4); paired stills [A](expressive-polish-20261001/overview-reduced-motion-a.png) and [B](expressive-polish-20261001/overview-reduced-motion-b.png) show the same static phase.

The tint strength was raised after review because the first light/dark difference was difficult to see: plan tints are now 12%, and the Weekly Overview anatomy field is 15% light / 20% dark. See the newest tint-adjustment captures below. The Weekly Overview panel keeps its approved ambient surface breathing and accent motion. The wave is an active sinusoidal line rather than a filled bar with a moving edge: only its phase changes, and reduced motion fixes it at phase zero. The normal Preview and Reduced Motion captures retain the same content and composition.

The action-bar clip records the optimized-workout recovery result, the settings route, and Start → isolated session → return to Train. Pixel stills captured during the press show the controls moving inward without cropped corners or changed resting placement. Start, Optimize, and gear bounds remain at their original positions.

Focused validation for that refinement: **51 tests passed, 0 failures**, Flutter 3.47.5 / Dart 3.13.4. The final full qualification is recorded in [the results document](../../../tonos-expressive-train-proving-ground-results.md#25-final-train--shell-qualification--2026-10-01).

### Latest user tint adjustment — 2026-10-01

The user found the previous plan and Weekly Overview heatmap tints difficult to see. Only those tint strengths changed: plan heatmaps are now 12%; the Weekly Overview anatomy field is 15% in light mode and 20% in dark mode. Plan-card geometry, heatmap data colors, layout, controls, and motion are unchanged.

Fresh Pixel 7 captures from the isolated preview are in `tint-adjustment-20261001/`:

- [Train Overview — light](tint-adjustment-20261001/overview-light.png) · [dark](tint-adjustment-20261001/overview-dark.png)
- [Train Plans — light](tint-adjustment-20261001/plans-light.png) · [dark](tint-adjustment-20261001/plans-dark.png)

The Plans captures show the blue, orange, and green active-plan thumbnails together. Use these newest stills to judge tint visibility; the earlier `expressive-polish-20261001/` images show the preceding, more subtle tint values.

### Focused Sets wave polish — 2026-10-01

This pass changes only the Focused Sets progress treatment. The active wave is slightly brighter and thicker (2.5 dp, previously 2.2 dp), while its 1.5 dp amplitude and 20 dp wavelength remain. The straight track is now painted only after the exact active extent, with a clip boundary that prevents it from showing under the wave. Short positive values keep the wavy treatment instead of falling back to a straight active line. Progress values, the 6 dp slot, the terminal marker, shared phase, and native progress semantics are unchanged.

Pixel 7 `28021FDH200228` captures from the isolated `com.tonos.expressivepreview` app:

- Train Overview: [light](wave-refinement-20261001/overview-light-final.png) · [dark](wave-refinement-20261001/overview-dark.png)
- Normal motion: [12-second idle clip](wave-refinement-20261001/wave-normal-motion.mp4) · [frame A](wave-refinement-20261001/wave-normal-a.png) · [frame B](wave-refinement-20261001/wave-normal-b.png)
- Reduced Motion: [10-second clip](wave-refinement-20261001/wave-reduced-motion.mp4) · [still A](wave-refinement-20261001/reduced-motion-a.png) · [still B](wave-refinement-20261001/reduced-motion-b.png)

The two normal-motion frames show the wave at different phases. The reduced-motion stills are byte-identical across the 10-second interval, and the reduced-motion clip remains static. The canonical profile preview was rebuilt and visually rechecked on Pixel 7 after qualification; it is at Train → Overview, Expressive / Curated / Light / 1×, with Reduced Motion off.
