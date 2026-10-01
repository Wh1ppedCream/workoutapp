# Tonos Expressive Train review

This review is limited to the current **Train → Overview**, **Train → Plans**, and shared bottom-navigation shell. It is an isolated visual/motion candidate in **Tonos Expressive Preview**, package **com.tonos.expressivepreview**, using the sandbox database **tonos_expressive_preview.db**. It is not persisted to the normal Tonos install.

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
| **Train → Overview** | Overview / Plans tabs, profile avatar, Weekly Overview, Active Plans, split Start Workout / Optimize action, and the existing five-destination navigation | Plum focal card, warm canvas, tonal inset, animated accent marks and Focused Sets progress, bright plan-identity blocks on neutral-filled rows, purple Start, teal Optimize, and a springing selected navigation fill | Leave the screen untouched for 10–15 seconds and watch the Weekly Overview surface/accent marks/progress edge. Tap Focused Sets → More, an Active Plan row, its menu, the edit button, Start Workout, and Optimize. Use only the preview database. |
| **Train → Plans** | Existing Active Plans, Archived Plans, Premade Plans, Generate Custom, and Manually Add sections in their established order | Filled identity-bearing rows on both sections; plan identity stays in the leading block while muted tonal bodies keep the anatomy thumbnail readable; menu and edit controls use smaller tactile responses | Tap Plans beside the profile avatar. Tap Show 1 more and watch rows enter. Open and dismiss a row menu. Scroll to Archived and Premade, then view Generate Custom and Manually Add. |
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

The active plan row and its identity block now share the same asymmetric expressive corner silhouette. The heatmap stays on the media-placeholder field while saturated identity color stays concentrated at the leading edge.

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
- The wave preserves the exact progress proportion and native progress semantics. It is 6 dp tall and its edge moves by at most 1.25 dp.
- Ambient work is gated by Overview selection, at least 24 dp visibility, TickerMode, app lifecycle, and MediaQuery’s animation-disable policy. A shared controller drives the card; RepaintBoundaries isolate accent/progress painting.
- The train tabs and five-item navigation use the existing spring selection indicator. Press wrappers remain paint-only; their child controls continue owning hit tests, semantics, and callbacks.
- Reduced motion stops/resets the ambient phase, fixes progress at its static shape, disables press/reveal/selection motion, and makes content-size changes near-immediate.
- No idle profile/gym spinner is included. The profile/avatar only responds while pressed.

See [motion-inventory.md](motion-inventory.md) for the per-control motion tiers, amplitudes, spring settings, clipping boundaries, and reduced-motion behavior.

## Validation recorded for this refinement

The focused eight-file Train/plan/motion/accessibility batch passed **57 tests, 0 failures** on Flutter 3.47.5 / Dart 3.13.4. Scoped Dart analysis reported **No issues found**. The 1.15 Pixel 7 capture after hot restart has no RenderFlex overflow; widget coverage checks 1.15 Pixel geometry and the 2x stacked layout. The full suite and final expensive qualification campaign were intentionally not run in this refinement stage.
