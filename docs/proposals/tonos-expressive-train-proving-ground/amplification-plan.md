# Train + shell Expressive amplification plan

## Diagnosis

The matched Overview pair still has the same pale canvas, two large rounded cards, anatomy-and-bars arrangement, stacked plan rows, split bottom action, and five-item navigation. The current Expressive pass mostly changes selector/nav treatment and the Start color. That reads as a Classic skin. The archived Plans images also have a light/dark labeling mismatch, so they are not a valid brightness comparison; the product order and widget hierarchy remain useful references.

## Presentation changes

| Region | Current Classic-like reading | Expressive break |
|---|---|---|
| Page and surfaces | Near-neutral canvas with repeated pale rounded cards | Use a visibly chromatic canvas and a small, coordinated set of saturated and soft tonal fields; reserve the highest contrast for the focal module and main action. Dark mode gets the same color relationships at dark tonal values. |
| Train header and selector | Familiar two-segment capsule beside the avatar | Keep Overview / Plans and avatar behavior, but give the selector a stronger asymmetric silhouette, a larger selected segment, and a visible shape transition. Preserve the current tap targets and header placement. |
| Seven-day focus | One card containing a title, anatomy heatmap, ranked body-part bars, counts, and More | Turn this into the page's unmistakable hero: bolder type, asymmetric layered containment, a distinct anatomy field, and a strongly grouped ranked list. Keep the rolling seven-day body-part meaning, heatmap colors, ranks, counts, and More action unchanged. |
| Active Plans | Another large card containing identity-colored plan rows | Make it a quieter, more compact supporting group with a different silhouette and less enclosing chrome. Preserve plan identity colors, row content, edit/menu actions, and order. |
| Plans tab | Repeated full-width section cards and rows | Establish a stronger active / archived / library / creation hierarchy through varied section shapes, colored tonal groupings, and selective scale. Preserve Active → Archived → Premade → Generate Custom → Manually Add, every existing action, and progressive reveal. |
| Start / Optimize | Equal halves of one long rounded bar | Give Start clear visual gravity as a distinct focal action; keep Optimize available as a smaller tonal companion with its settings action. Keep their position and callbacks. |
| Bottom navigation | Pale strip with a small selected fill | Make the whole navigation surface and selected destination expressive through a colored container, icon treatment, label hierarchy, and a morphing selected shape. Keep the configured destination order, labels, routes, and bottom placement. |
| Type and scale | Similar title weights/sizes across adjacent cards | Use a more variable hierarchy: expressive hero/section titles, compact supporting labels, and clear numeric emphasis without changing text or using a new font. |

Plan identity, success/completion, warnings/errors, heatmap, chart, and other domain colors retain their existing ownership. New chroma belongs to Expressive presentation roles only.

## Motion inventory

| Role | Train + shell behavior | Reduced motion |
|---|---|---|
| REACTIVE | Selector/nav retargeting; Start/Optimize and plan-action press/release; focus-details press feedback; Show-more response | Immediate state and callbacks; static selected geometry |
| TRANSITION | Overview ↔ Plans uses a 200 ms fade and roughly 12 dp settle; focus loading/data/error changes fade and scale in 180 ms; progressive plan reveal resizes its section in 220 ms | Keep the same final layout/content and snap without translation, fade, or size interpolation |
| AMBIENT / SUBTLE | Overview focus data can arrive and reveal itself without a tap; keep this state-driven and brief rather than adding an idle loop | Show the final data state immediately |
| MORPH | Selected tab/nav silhouette and Start press shape; plan reveal changes the section container size | Render the final state without interpolation |

Business state and callbacks stay immediate. Keep animated regions isolated, stop tickers when offscreen, honor `TickerMode` and the existing system/preview reduced-motion path, and avoid changing any Classic/Neo motion recipe. The tab transition wraps the existing `IndexedStack`, so both tab subtrees stay mounted and retain their scroll and UI state.

## Review gates

1. Recompose only the preview-only Expressive Train + shell; keep routes, data, actions, user-configured navigation, and plan reveal behavior intact.
2. Capture on the isolated Pixel 7 after each major integration. With reduced motion enabled, the screen must still look immediately different from Classic across the canvas, hero, plan grouping, actions, and navigation.
3. Compare fresh, state-matched Classic / Expressive Overview and Plans captures in light and dark. Verify ordinary and rapid selection, plan actions/reveal, and Start routing; record normal and reduced-motion clips.
4. Run focused widget/accessibility checks for 320 dp width, 2× text, semantics, hit targets, reduced motion, and unchanged Classic/Neo behavior. Do not run the full qualification campaign in this design iteration.

Scope ends at Train + shell. Active Workout, Progress, persistence of an Expressive family, and promotion beyond the preview remain out of scope pending user review.
