# Tonos Expressive Active Workout adaptation plan

**Status:** implementation plan for the isolated preview. This does not change
the approved Train + shell reference, persisted theme families, or production
selection behavior.

## Design direction

Reuse the approved warm canvas, purple primary action, teal supporting action,
role-based asymmetry, tonal containment, bounded tactile motion, and Reduced
Motion policy. Keep the current `SessionScreen` composition and control order.
Expressive styling is explicitly opted into by the preview `SessionScreen` and
passed only to its workout cards; shared `WeightCard` instances in plan editors
must retain their current Classic/Neo presentation.

Avoid a purple hero on every exercise card. Give the expanded exercise a modest
primary-container header, keep its outer card on a neutral container, and place
the dense set rows on a related, lower-chroma Material surface. Numeric fields
remain compact on a raised filled surface, with a quiet `outlineVariant` border
and primary focus outline. Completed rows retain green ownership and immediate
state updates.

## Region plan

| Region | Current presentation | Expressive adaptation | Motion role | Density risk | Behavioral contract | Accessibility risk |
|---|---|---|---|---|---|---|
| Session header and timer drawer | Centered Workout Session AppBar; leading menu opens a drawer with the live elapsed timer. | Warm page canvas; keep title/menu placement; give the drawer a raised tonal surface and make the elapsed value the focal type role. No new rest timer. | Compact menu press; timer text remains value-driven and does not interpolate misleadingly. | Added header height or timer chrome. | Existing drawer, elapsed source, route, and Back behavior stay intact. | Preserve menu target, timer label, contrast, and scaled text. |
| Exercise card/header | Material Card; collapse button, exercise name/progress, optional thumbnail/details, anchored menu. | Neutral tonal outer card with a controlled asymmetric silhouette; expanded header gets a restrained primary-container band, while fully complete state keeps its green semantic cue. | Moderate header/menu press response; outer silhouette morphs with expansion, separate from the accepted row reveal. | Repeated header padding or large per-card color fields. | Preserve order, callbacks, disclosure, thumbnail/details, and `MenuAnchor` behavior. | Keep each action independently labelled and reachable; do not make the whole header a competing tap target. |
| Set rows and fields | Compact repeated rows; 48 dp checkbox target; numeric weight/reps fields; responsive stacking at compact width/large text. | Inset tonal row surface with a small role-specific corner treatment; compact filled numeric fields with a clear primary focus outline. Keep current padding, columns, and text scale behavior. | High-frequency tier: local color/check response only; no whole-row bounce or moving text. | Any row-height increase, field wrapping, or reduced visible set count. | Preserve values, units, validation, field focus, target size, completion semantics, and immediate updates. | Keep field semantics and checkbox action/name together; preserve 2× and compact layout. |
| Completion | Green checkbox/row state; non-final completion stays open; final required set collapses; reopening restores state. | Green remains exclusively completion/success. The row updates immediately; retain the standard checkbox check-state response and tonal green row. | No custom per-row animator or page-wide celebration; repeated logging stays calm. Reduced Motion keeps the state change immediate. | A bloom that obscures adjacent fields or slows repeated logging. | Preserve completion persistence, auto-collapse, and completed-state restore exactly. | Green is not the only state cue; maintain checked semantics and contrast. |
| Add Set / change set | Right-aligned Add Set TextButton and existing change-set action. | Keep both in place as compact supporting actions; use quiet tonal/teal emphasis only where it improves scan order. | Supporting press tier; callback is immediate. | Taller buttons or action rows. | Preserve set creation and change-set model mutation. | Preserve touch targets and disabled/read-only behavior. |
| Add Exercise and Finish | Floating Add Exercise button; full-width bottom SafeArea Finish action. | Retain placement. Finish is the focal purple action; Add Exercise is secondary teal. Give each its own role-shaped treatment. In the isolated Expressive preview, keep the FAB as a floating overlay and provide only minimum end-of-list scroll clearance so the final set controls can be brought clear of it; do not reserve a fixed viewport lane. | Focal press for Finish; supporting press for Add Exercise. No callback waits for visual recovery. | Overlay can cover controls near the list end; verify scrolling provides enough clearance without adding persistent empty viewport space. | Preserve catalog route, finish guard, save flow, confirmation/completion sheet, and return route. | Keep stable hit bounds, busy state, keyboard activation, and clear labels. |
| Menus, dialogs, and sheets | `MenuAnchor`; Tonos confirmation dialogs; exercise-detail and completion sheets. | Use the same elevated surface/container roles and moderate Expressive geometry through the root preview theme or narrow overlay theme. Keep standard Material dismissal/focus semantics. | Standard menu/sheet transition; no custom novelty motion. | Overlay styling that creates extra nested panels or moves actions. | Preserve action order, remove confirmation, outside/Escape/Back dismissal, and existing sheet callbacks. | Verify focus return, readable 2× text, safe areas, and one semantic action per control. |

## Implementation and qualification boundary

1. Add a session-only Expressive presentation flag, default off, and use it only
   when the root preview identity is Expressive. Do not use theme identity alone
   inside the shared card to restyle plan-editing routes.
2. Style the existing SessionScreen actions and WeightCard surfaces without
   reordering content or moving controls. Any style helper stays Tonos-owned and
   has no effect under Classic or Neo. The Expressive-only floating FAB overlays
   the list, with minimum end-of-list scroll clearance for the final controls;
   it does not reserve a fixed viewport lane or alter the shared Classic/Neo
   layout.
3. Preserve the approved controlled expansion exactly: `TweenAnimationBuilder`,
   `ClipRect`, `Align.heightFactor`, the current 180 ms quick duration, and
   immediate Reduced Motion behavior. Any outer-shape interpolation is separate
   from that reveal.
4. Keep the 48×48 completion target, `MenuAnchor`, set persistence, non-final
   open/final-set auto-collapse, and reopen state unchanged.
5. Add focused tests for paired Expressive light/dark rendering, Classic/Neo
   isolation, current workout contracts, semantics, compact width/large text,
   finish/add callbacks, and non-overlapping FAB/set-control bounds. Capture
   matched realistic workout states and short motion/reduced-motion evidence on
   the isolated Pixel preview before asking for design review.

Progress, Catalog redesign, Logbook, Profile, Nutrition, persisted Expressive
selection, and app-wide rollout are out of scope. Full-suite qualification is
deferred until the user approves this Active Workout design direction.
