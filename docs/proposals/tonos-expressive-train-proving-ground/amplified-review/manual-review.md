# Tonos Expressive Train review

This preview shows the current Tonos **Train → Overview** and **Train → Plans** screens in the amplified Expressive presentation. It is a disposable preview, not the normal Tonos install. The plan rows now use the same expressive language as their surrounding sections; the current layout and actions remain Tonos-owned.

## Open the preview and set a fair comparison

1. On the Pixel 7, open **Tonos Expressive Preview** from the app drawer. It opens on **Train → Overview**.
2. Tap the sliders button in the separate strip at the upper right, above the Overview / Plans selector.
3. Set **Rendered recipe** to **Expressive**. With Expressive selected, set **Palette treatment** to **Curated**.
4. Choose **Light** or **Dark**. Keep **Reduced motion** and **Effects off** switched off for the normal-motion review. Leave text scale at **OS/app default** to match the captures; the dialog can scroll to its text-scale control.
5. Tap **Done**. To compare, reopen the sliders, change only **Rendered recipe** to **Classic**, tap Done, and inspect the same screen and scroll position. Switch back to Expressive and repeat in the other brightness.

The preview controls affect only this in-memory review. **Reset review controls** restores Expressive / Curated / Light and the default motion settings. **Reset sandbox fixtures** restores the sample plans and data in the isolated preview database.

## What to inspect

| Screen and route | Current Tonos widgets to look at | What changes from Classic | What to do |
|---|---|---|---|
| **Train → Overview** | The existing Overview / Plans selector, profile avatar, **Weekly Overview** focus card, **Active Plans** card, split **Start Workout / Optimize** bar, and bottom navigation | The warm canvas and plum Weekly Overview remain the focal treatment, with its inset focus list and apricot/mint accents. The Active Plans parent is a warm supporting group; its individual rows are now filled, plan-identity-bearing cards with a strong leading thumbnail block, asymmetric row/identity shapes, and a separate menu bubble. Start is purple and leads; Optimize is teal-toned. Anatomy heatmap colors and plan identity colors retain their meanings. | Compare the whole screen, then inspect the focus card, filled plan rows, and action hierarchy. The plan names, thumbnails, order, and menu actions are unchanged. |
| **Train → Plans** | Existing **Active Plans**, **Archived Plans**, **Premade Plans**, **Generate Custom**, and **Manually Add** sections | The current section order, controls, and density remain. Active and archived plan rows share the filled identity-bearing card treatment, with different row silhouettes and plan-colored leading blocks. Their neutral tonal fills keep blue, orange, green, and teal identities legible against the warm/mint section containers. | Tap **Plans** in the selector beside the avatar. Tap **Show 1 more** to see the real progressive reveal, then scroll through Archived and Premade to Generate Custom and Manually Add. |
| **Train shell** (visible on both tabs) | Five current destinations: **Train, Catalog, Logbook, Progress, Profile** | The existing navigation gets a tinted surface and a more visible selected shape. The selected icon sits in a springing/morphing indicator; its label remains high-contrast. Destination count, order, labels, placement, and callbacks are unchanged. | Tap **Catalog**, **Progress**, then **Train** to watch the selection indicator move. Those destinations' page styling is outside this review. |

## Motion review clips

All clips were recorded from the isolated Pixel 7 preview. The existing screen state and callbacks remain the owners of navigation, selection, and plan data; the motion wrappers only present those state changes.

- [Normal motion: plan rows, menu, reveal, tab entry, and bottom navigation](normal-motion.mp4). It opens on Overview, switches to Plans, reveals the remaining plan, opens/dismisses a row menu, opens and backs out of a plan detail, then changes tabs and shell destinations.
- [Start Workout touch and route](start-touch.mp4). The existing primary action opens the disposable session route.
- [Optimize touch and recovery warning](optimize-touch.mp4). The current Optimize callback reaches its existing “Take some time to rest” state for the seeded data; dismiss it with **OK**.
- [Rapid tab and navigation retargeting](rapid-interaction.mp4). This repeats Overview/Plans and shell selection changes.
- [Idle Overview breathing, 22 seconds](idle-10-second.mp4). Leave the screen untouched and watch the large plum Weekly Overview surface slowly breathe in tone. Its color interpolates through a small 24% portion of the focus-surface range with an 8-second half-cycle (16 seconds per full cycle); no text, metrics, heatmap meaning, or layout moves.
- [Reduced motion interactions](reduced-motion.mp4). The same Expressive colors and shapes remain, while selection snaps and the ambient loop stops. Reduced motion was on; Effects Off remained off.

The broader interaction list is in [motion-inventory.md](motion-inventory.md). Press/release callbacks and business state update immediately. Plan rows remain Expressive on both tabs, but row-arrival and touch motion are disabled while their tab is inactive; selecting the tab enables the reveal without replacing its list or losing scroll state. Selection and press springs, size/reveal transitions, and the ambient loop honor `TickerMode` and the preview’s reduced-motion path. Weekly Overview state changes snap while its tab is inactive. The breathing loop additionally runs only while Train → Overview is active and the app is resumed. Effects Off maps into the same animation-disable path.

## Boundaries

Only Train, its two tabs, and the shared bottom-navigation treatment are being reviewed. **Catalog, Logbook, Progress, Profile, Active Workout, and child routes are not visual targets for this pass.** Their product behavior and navigation remain intact. Use the preview package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`; changes made there do not target normal Tonos data.

## Matched Pixel 7 captures

All eight captures use the same seeded preview content, screen/tab, scroll position, OS/app text scale, selected destination, and unobstructed screen state. The Classic and Expressive captures are separate screenshots from the same Pixel 7 profile preview.

### Overview

- [Classic light — current matched capture](overview-classic-light-current.png)
- [Expressive light — current review build](overview-expressive-light-refined.png)
- [Classic dark — current matched capture](overview-classic-dark-current.png)
- [Expressive dark — current review build](overview-expressive-dark.png)

### Plans

- [Classic light — current matched capture](plans-classic-light-current.png)
- [Expressive light — current review build](plans-expressive-light-refined.png)
- [Classic dark — current matched capture](plans-classic-dark-current.png)
- [Expressive dark — current review build](plans-expressive-dark.png)

Each comparison pair uses the same seeded sample plans, Overview metrics, selected Train destination, text scale, and unobstructed screen state. Classic and Expressive screenshots were captured from the same Pixel 7 preview; system status-bar time can differ.
