# Tonos Expressive reference baseline

**Current status (2026-10-02):** Train + shared navigation shell and Active Workout are the approved, host-qualified Expressive reference slices for later adaptations. The user approved inclusion of the unchanged pre-existing geometry test correction in this qualification checkpoint; other protected working-tree changes are excluded. See the dated record in [qualification results](tonos-expressive-train-proving-ground-results.md#26-current-reference-slice-and-qualification-status--2026-10-02).

This reference covers the isolated preview treatment of **Train → Overview**, **Train → Plans**, the existing bottom-navigation shell, and **Active Workout**. Expressive remains preview-only and non-persisted; Classic and Neo remain the persisted theme families. **Progress adaptation is not done.** Catalog, Logbook, and Profile have not been adapted.

## Color

- A warm neutral canvas carries a plum Weekly Overview as the focal surface. Dark mode preserves the same hierarchy through deeper related tones and readable foreground contrast.
- Purple is the primary action family, used by Start Workout and the selected Train/navigation states. Teal is a supporting-action family for Optimize.
- Plan identity remains owned by each plan: its saturated accent is concentrated in the leading identity block, while the row body and heatmap field stay tonal. The heatmap background blends plan identity at 12%; anatomy/data colors retain their existing meaning.
- The Weekly Overview anatomy field blends 15% toward its plum inset tone in light mode and 20% in dark mode. Anatomy and chart/data colors are not recolored to match the theme accent.

## Shape and containment

- Expressive geometry uses a controlled mix of broad, alternating and asymmetric corners. Focal surfaces have the strongest silhouette; supporting sections and compact controls use quieter shapes.
- Weekly Overview is the focal container. Active Plans is a supporting grouped surface containing filled plan rows. Each plan's identity block follows the row silhouette with an inset inner corner, avoiding thumbnail clipping.
- The Overview/Plans selector and bottom navigation keep their existing positions and destinations. Selected shapes provide a clear state within the existing compact controls.
- Containment creates a tonal ladder across the warm canvas, focal plum card, inset focus panel, supporting plan group, identity-bearing rows, and action bar.

## Typography

The existing Tonos/system font stack remains. The hierarchy emphasizes the Weekly Overview title, section and action labels, and Focused Sets values; supporting labels remain readable within the current dense layout. The system does not enlarge every title or replace the current information hierarchy.

## Motion contract

- Supporting press response: scale 0.93 with 1.5 dp downward offset; compact response: scale 0.88 with 0.5 dp offset and 0.05 rad rotation. Focal Start uses scale 0.91 with 2 dp offset. The shared release spring is mass 1, stiffness 800, damping ratio 0.72.
- Train-tab/selection motion uses mass 1, stiffness 650, damping ratio 0.80. Press wrappers change paint only; existing controls retain hit testing, semantics, and callbacks.
- Weekly Overview breathing uses one shared phase: a 3-second half-cycle / 6-second round trip, easing the surface up to 42% toward its inset tone. Accent marks and Focused Sets share this owner.
- Accent marks vary from 34 dp to 48 dp beside a 13 dp mark, with a 5 dp gap and at most 1.5 dp opposing vertical offsets inside the original 6 dp slot.
- Focused Sets uses a 2.5 dp rounded sinusoidal active stroke, 1.5 dp amplitude, 20 dp wavelength, and a subtle 8% lift toward white from the warm role. The straight 1.5 dp remainder begins exactly at the active endpoint and is clipped away from the active segment. A fixed 3 dp terminal marker closes the full track. Active width remains `track width × value`; the native progress semantic/value remains unchanged. Short positive values retain the wave.
- Existing content entry uses a 200 ms fade and 8 dp settle; newly revealed plan rows use a 220 ms ease-out size transition. The surrounding sections retain their order and scroll state.
- Ambient motion runs only for the selected Overview while at least 24 dp of its focus card is visible, TickerMode is enabled, the app is resumed, and animation is permitted. Repaint boundaries keep accent/wave painting local; controllers are disposed with their owners.

## Reduced motion and accessibility

Reduced Motion stops and resets the ambient phase, fixes the wave at its static sinusoidal geometry, skips nonessential press/selection/reveal travel, and resolves layout changes immediately or near-immediately. Static colors, shapes, filled plan rows, containment, type hierarchy, and wave geometry remain Expressive. Callbacks remain immediate, and progress values/semantics remain stable.

Automated responsive coverage includes 1×, 1.15×, 1.5×, 2× and compact 320 dp width, with long labels, RTL layout direction, navigation reachability, selected state, and semantics checks. Pixel 7 checks include native OS 2× text reflow/scrolling and touch/navigation behavior. TalkBack announcements and focus order were not tested; landscape and unsupported RTL-language shaping remain outside this qualification.

## Next phase boundary

The next destination phase, when authorized, is **adapt the approved reference language to Progress**. Treat Train + shell and Active Workout as the existing reference system; do not restart their visual design.

See the [qualification results](tonos-expressive-train-proving-ground-results.md), [handoff](tonos-expressive-train-proving-ground-handoff.md), [motion inventory](proposals/tonos-expressive-train-proving-ground/amplified-review/motion-inventory.md), and [Pixel device record](proposals/tonos-expressive-train-proving-ground/qualification/device-qualification.md) for evidence and limits.

## Current Active Workout reference — 2026-10-02

The Active Workout slice uses the production `SessionScreen → ExerciseCard → WeightCard` composition in the isolated preview. `ActiveSession` remains the workout-state owner. The preview preserves the logger's current order, content, and dense set-row workflow.

- Completed-state colors in light mode: exercise header `#35A457`, completed set rows `#7BCB8B`, and completed exercise outer surface `#D9F0DC`. These are Expressive success/completion roles only. The current dark-mode completion palette is unchanged from its existing recipe; Classic and Neo remain untouched.
- Expanded card rhythm is 6 dp below the header, a 1 dp divider, then 6 dp before set content. Add Set has an 8 dp bottom inset and a touch target of at least 48 dp. The representative expanded card is approximately 25 dp shorter than the earlier spacing candidate.
- Controlled expansion remains 180 ms; Reduced Motion resolves expansion and collapse immediately. Set completion keeps the existing non-final-open/final-set-auto-collapse rule and completion state on reopen. The completion target, `MenuAnchor` menu, and independently routed Weight/Reps field hit regions remain in place.
- Add Exercise remains a floating overlay; there is no permanent reserved dead lane. End-of-list clearance lets the last controls scroll clear of the FAB at maximum scroll. Finish stays fixed and reachable, and the elapsed-session timer retains its existing drawer interaction.

These current values supersede older Active Workout color and fixed-lane descriptions in historical records. The preview remains isolated at `com.tonos.expressivepreview` with `tonos_expressive_preview.db`; it does not add a persisted Expressive choice or alter normal Tonos data.
