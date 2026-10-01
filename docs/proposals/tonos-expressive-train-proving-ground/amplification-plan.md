# Train + shell Expressive amplification plan

## Initial diagnosis

Before this amplification pass, the matched Overview pair still had the pale canvas, two large rounded cards, anatomy-and-bars arrangement, stacked plan rows, split bottom action, and five-item navigation. The then-current Expressive pass mostly changed selector/nav treatment and the Start color, which read as a Classic skin. The old archived Plans images also had a light/dark labeling mismatch. The current status is recorded below; the earlier diagnosis is historical, not a description of the review build.

## Presentation changes

| Region | Current Classic-like reading | Expressive break |
|---|---|---|
| Page and surfaces | Near-neutral canvas with repeated pale rounded cards | Use a visibly chromatic canvas and a small, coordinated set of saturated and soft tonal fields; reserve the highest contrast for the focal module and main action. Dark mode gets the same color relationships at dark tonal values. |
| Train header and selector | Familiar two-segment capsule beside the avatar | Keep Overview / Plans and avatar behavior, but give the selector a stronger asymmetric silhouette, a larger selected segment, and a visible shape transition. Preserve the current tap targets and header placement. |
| Seven-day focus | One card containing a title, anatomy heatmap, ranked body-part bars, counts, and More | Turn this into the page's unmistakable hero: bolder type, asymmetric layered containment, a distinct anatomy field, and a strongly grouped ranked list. Keep the rolling seven-day body-part meaning, heatmap colors, ranks, counts, and More action unchanged. |
| Active Plans | Another large card containing identity-colored plan rows | Keep the warm supporting section, and make each plan row an expressive identity-bearing filled card with an accent block, thumbnail, and separate menu shape. Preserve identity, row content, edit/menu actions, and order. |
| Plans tab | Repeated full-width section cards and rows | Establish a stronger active / archived / library / creation hierarchy through varied section shapes, colored tonal groupings, and selective scale. Preserve Active → Archived → Premade → Generate Custom → Manually Add, every existing action, and progressive reveal. |
| Start / Optimize | Equal halves of one long rounded bar | Give Start clear visual gravity as a distinct focal action; keep Optimize available as a smaller tonal companion with its settings action. Keep their position and callbacks. |
| Bottom navigation | Pale strip with a small selected fill | Make the whole navigation surface and selected destination expressive through a colored container, icon treatment, label hierarchy, and a morphing selected shape. Keep the configured destination order, labels, routes, and bottom placement. |
| Type and scale | Similar title weights/sizes across adjacent cards | Use a more variable hierarchy: expressive hero/section titles, compact supporting labels, and clear numeric emphasis without changing text or using a new font. |

Plan identity, success/completion, warnings/errors, heatmap, chart, and other domain colors retain their existing ownership. New chroma belongs to Expressive presentation roles only.

## Current review build

The approved bolder palette and the existing Tonos screen hierarchy remain. The plan-row holdover has been addressed in both Overview and Plans: rows use neutral surface-container blends lightly tinted by each plan identity color, a stronger leading identity/thumbnail block, alternating row and identity-block geometry, and a distinct trailing menu bubble. Blue, orange, green, and teal plan identity hues are preserved; the parent Active and Archived section colors still provide the wider grouping.

The motion pass now reaches beyond the selector, shell navigation, and Start action. It includes plan-row and menu presses, edit controls, focus details, Show More, list-item reveals, section size changes, tab entry, data-state changes in Weekly Overview, and a low-amplitude idle color breath on the Weekly Overview surface. The ambient loop runs only on active Train → Overview and stops for reduced motion, Effects Off, disabled tickers, inactive tabs, and a paused app. See `amplified-review/motion-inventory.md` and `amplified-review/manual-review.md` for the implementation inventory and Pixel 7 evidence.

The current matched Classic/Expressive light and dark captures are in `amplified-review/`; their plan names, section order, Overview metrics, selected destination, and content state match. The clips document normal interaction, touch on Start and Optimize, rapid retargeting, an untouched idle interval, and reduced motion.

## Motion inventory

The current per-component trigger, motion type and duration, reduced-motion behavior, and offscreen policy are recorded in [`amplified-review/motion-inventory.md`](amplified-review/motion-inventory.md). Plan-row arrival is explicitly disabled while its tab is inactive; the two existing tab subtrees remain mounted so their scroll and UI state are retained. Weekly Overview content-state motion and ambient motion are also disabled while Overview is inactive. State changes and callbacks remain immediate.

## Review gates

1. Recompose only the preview-only Expressive Train + shell; keep routes, data, actions, user-configured navigation, and plan reveal behavior intact.
2. Capture on the isolated Pixel 7 after each major integration. With reduced motion enabled, the screen must still look immediately different from Classic across the canvas, hero, plan grouping, actions, and navigation.
3. Compare fresh, state-matched Classic / Expressive Overview and Plans captures in light and dark. Verify ordinary and rapid selection, plan actions/reveal, and Start routing; record normal and reduced-motion clips.
4. Run focused widget/accessibility checks for 320 dp width, 2× text, semantics, hit targets, reduced motion, and unchanged Classic/Neo behavior. Do not run the full qualification campaign in this design iteration.

Scope ends at Train + shell. Active Workout, Progress, persistence of an Expressive family, and promotion beyond the preview remain out of scope pending user review.
