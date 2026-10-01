# Tonos Expressive Train review

This preview shows the current Tonos **Train → Overview** and **Train → Plans** screens in the amplified Expressive presentation. It is a disposable preview, not the normal Tonos install.

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
| **Train → Overview** | The existing Overview / Plans selector, profile avatar, **Weekly Overview** focus card, **Active Plans** card, split **Start Workout / Optimize** bar, and bottom navigation | The page canvas becomes warm-toned. The Weekly Overview becomes a dark plum focal module with an inset focus list, stronger title and apricot/mint accents. The anatomy map and the meaning of its heat colors stay the same. Active Plans becomes a softer supporting group. Start is purple and visually leads; Optimize is a teal-toned secondary action. | Compare the whole screen first, then inspect the focus card and action hierarchy. The blue/orange/green plan identities should remain recognizable and unchanged. |
| **Train → Plans** | Existing **Active Plans**, **Archived Plans**, **Premade Plans**, **Generate Custom**, and **Manually Add** sections | The same sections and actions use distinct warm, mint, gold, and lavender surface groups. Their silhouettes and headings vary more; plan rows retain their identity colors, menu, edit actions, and order. | Tap **Plans** in the selector beside the avatar. Scroll down to inspect Archived and Premade, then the Generate Custom and Manually Add actions. In Active Plans, tap **Show 1 more** to see the existing progressive reveal. |
| **Train shell** (visible on both tabs) | Five current destinations: **Train, Catalog, Logbook, Progress, Profile** | The navigation gets a tinted surface and a more visible selected shape. The selected icon sits in a moving/morphing indicator; its label remains high-contrast. Destination count, order, labels, placement, and callbacks remain the same. | Tap **Catalog**, then **Train**, to watch the indicator move. Catalog's screen styling is outside this review. |

## How to see the motion

- With motion on, switch **Overview ↔ Plans** slowly, then repeat about 10 times quickly. The selected shape springs and morphs; the selected tab and content state update immediately.
- Watch the tab content as well as the selector: Overview and Plans each make a short 200 ms fade and roughly 12 dp settle on entry. This is only a paint transition around the existing mounted tab, so switching back keeps the same scroll position.
- On first launch, watch **Weekly Overview** while its real focus data finishes loading; its loading/data state change has a brief 180 ms fade/scale. It is data-driven, not an idle animation.
- Tap a bottom destination and return to Train. Watch the selected navigation shape move. The five labels and their tap areas stay in place.
- Briefly press and release **Start Workout** if you want to feel its shape response. It performs the existing start action and opens the disposable workout flow; cancel that preview session if you do not want to continue.
- On Plans, use **Show 1 more** to see the existing list reveal/section-size response. Plan data and action order do not change.
- Open the sliders and turn **Reduced motion** on. Repeat the selector and navigation actions. Selection should snap without spring travel, while the Expressive colors, typography, grouping, and shape stay visibly distinct. **Effects off** also disables optional spring recovery.

There is no continuous idle loop. Motion is tied to selection, content entry, press/release, section reveal, and asynchronous focus-card content changes; the data callbacks and selected state remain immediate.

## Boundaries

Only Train, its two tabs, and the shared bottom-navigation treatment are being reviewed. **Catalog, Logbook, Progress, Profile, Active Workout, and child routes are not visual targets for this pass.** Their product behavior and navigation remain intact. Use the preview package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`; changes made there do not target normal Tonos data.

## Matched Pixel 7 captures

All eight captures use the same seeded preview content, screen/tab, scroll position, OS/app text scale, selected destination, and unobstructed screen state. The Classic and Expressive captures are separate screenshots from the same Pixel 7 profile preview.

### Overview

- [Classic light](overview-classic-light.png)
- [Expressive light](overview-expressive-light.png)
- [Expressive light — latest review build](overview-expressive-light-final.png)
- [Classic dark](overview-classic-dark.png)
- [Expressive dark](overview-expressive-dark.png)

### Plans

- [Classic light](plans-classic-light.png)
- [Expressive light](plans-expressive-light.png)
- [Classic dark](plans-classic-dark.png)
- [Expressive dark](plans-expressive-dark.png)

## Motion clips

- [Normal motion: tab entry, plan reveal, and shell selection](normal-motion.mp4)
- [Rapid Overview / Plans and navigation switching](rapid-interaction.mp4)
- [Reduced motion: same states snapping without spring travel](reduced-motion.mp4)
