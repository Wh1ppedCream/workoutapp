# Train + shell Expressive motion inventory

This is the current review contract for the disposable Expressive preview. It covers only Train Overview, Train Plans, and the existing bottom-navigation shell. Tonos continues to own navigation, selection, plans, callbacks, and workout data; the wrappers add presentation only.

## Tactile roles

The shared press response changes paint only. Pointer-down applies the configured compressed pose immediately; release uses the shared Flutter spring (mass 1, stiffness 800, damping ratio 0.72). Scale, offset, rotation, and optional corner interpolation are bounded. Transforms do not alter layout or hit testing, and the wrapped Material/InkWell control remains the callback, keyboard, focus, and semantics owner.

| Element | Role and response | Geometry / clipping | Reduced motion |
|---|---|---|---|
| Overview / Plans selector | Supporting: 0.93 scale, 1.5 dp downward offset on press. The selected fill travels and morphs using the selection spring (mass 1, stiffness 650, damping ratio 0.80). | The fill moves from 0.78 to 0.94 of a segment width and occupies 0.82 of the selector height. It is decorative and clipped to the existing track. | Fill snaps to the selected segment; tab state/callback updates immediately. |
| Bottom navigation | Supporting: 0.93 scale, 1.5 dp offset. The existing selected fill travels between Train, Catalog, Logbook, Progress, and Profile. | Fill travels at 0.78 width and settles at 0.94, inside its fixed 32 dp slot; bounded spring overshoot remains inside the navigation container. Destination count/order and hit areas are unchanged. | Selection snaps; destination callback is immediate. |
| Start Workout | Focal: 0.91 scale and 2 dp offset, with the split action’s existing corner morph. | Only the Start segment responds; the existing action bar owns its bounds and InkWell. | No transform or shape motion; session callback remains immediate. |
| Optimize | Supporting: 0.93 scale and 1.5 dp offset with its existing segment shape response. | The Optimize segment and its settings action remain separate controls. | No transform; optimization/settings callbacks remain immediate. |
| Optimize settings gear | Compact: 0.88 scale, 0.5 dp offset, and 0.05 rad rotation. | Rotation is local to the gear control; it does not change the adjacent Optimize hit target. | No transform; callback is immediate. |
| Train profile/avatar | Compact: 0.88 scale, 0.5 dp offset, and 0.05 rad rotation on press. There is no idle spin or loop. | The current green profile identity remains static at rest; the transform is local to its existing button. | No transform; drawer action is immediate. |
| Active Plan row, on either Train tab | Supporting: 0.93 scale and 1.5 dp offset; the row corners interpolate toward the pressed plan shape. Arrival is a 240 ms fade/8 dp settle/0.965-to-1 scale. Rows stagger by 55 ms, bounded by the existing five-row batch. | The press wrapper surrounds the clipped card so the outer silhouette can move as one unit. Inner heatmap identity geometry is contained within the existing row inset; see the plan-card notes below. | Row appears at rest and has no press transform. Detail navigation remains immediate. |
| Active Plan menu bubble | Compact: 0.88 scale, 0.5 dp offset, and 0.05 rad rotation. The popup itself uses the normal Material menu transition. | The neutral bubble and popup sit inside the existing trailing control bounds. The card row does not own the menu callback. | No press transform; menu actions remain available and immediate. |
| Active Plans edit / Archived Plans edit | Compact: 0.88 scale and a −0.05 rad rotation. | Each edit icon remains within its current Material IconButton; no section clipping is added around the transform. | No transform; the existing management action opens immediately. |
| Overview Active Plans edit | Compact: 0.88 scale and a −0.05 rad rotation. | Same edit-control boundary as the Plans tab. The response is disabled while Overview is inactive. | No transform; management callback is immediate. |
| Focused Sets inset / More | Supporting response on the existing interactive inset: 0.93 scale, 1.5 dp offset, and its pressed-corner interpolation. | The inset remains a single semantic button. Progress bars inside it are informational and have no touch response. | No transform; opening the existing details is immediate. |
| Show 1 more | Supporting: 0.93 scale and 1.5 dp offset. The existing plan section changes size over 220 ms with ease-out. | Only newly revealed rows animate in; the surrounding section grows in place without changing the information order. | Reveal/press transforms are skipped; section size resolves in 1 ms and state updates immediately. |
| Premade / Generate / Manually Add | Supporting: 0.93 scale and 1.5 dp offset with an existing local shape response. | Each existing action retains its current card/button bounds. | No transform; action/navigation callbacks are immediate. |
| Overview / Plans content entry | 200 ms fade (0.90 to 1) and an 8 dp vertical settle. | Only the newly selected existing tab content enters. Both tab subtrees remain mounted, preserving their scroll and local state. | Resolves directly to the resting layout. |
| Preview controls | These are review-only controls, not a production Tonos interaction. Material dialog controls retain their normal Flutter response. | Separate preview strip; it does not add a production destination or alter Tonos navigation. | Settings apply immediately; Effects Off shares the preview's animation-disable path. |

The shared compact tier is 0.88 scale, 0.5 dp offset, and 0.05 rad rotation. Supporting controls use 0.93 scale and 1.5 dp offset; the focal Start action uses 0.91 scale and 2 dp offset. Shape interpolation varies by component role. All input callbacks are independent of the animation.

## Ambient and progress motion

| Element | Motion and value ownership | Visibility / lifecycle policy | Reduced motion |
|---|---|---|---|
| Weekly Overview surface | A sine-eased color interpolation reaches 42% of the distance from the focal surface toward its inset tone. One half-cycle is 3 seconds; the surface completes a round trip in 6 seconds. Text, metrics, heatmap data, and layout do not move. | One controller belongs to the visible Overview focus card. It runs only while Overview is selected and at least 24 dp of the card is visible, and stops for inactive TickerMode or a non-resumed app lifecycle. Visibility is reevaluated after scrolling/state changes, not on each tick. | Loop stops and resets to the neutral focus surface; static Expressive colors remain. |
| Weekly Overview accent marks | The warm bar changes from 34 to 48 dp beside a 13 dp cool bar with a 5 dp gap. Their vertical offsets move by up to 1.5 dp in opposite directions inside the original 6 dp slot. Both use the focus-card phase. | Shares the single Overview controller; no extra repeating timer/controller. Decorative bars are ignored by pointer and semantics handling. | Marks remain in their neutral static pose. |
| Focused Sets progress | The existing 6 dp determinate bar uses a wavy leading edge with at most 1.25 dp amplitude. Mean fill position remains exactly equal to the current value. A hidden native LinearProgressIndicator remains the semantics owner with the exact value. | Descendants listen to the shared Overview phase. Painting is isolated in a RepaintBoundary; no independent loop is created. | Wave phase is fixed at zero; the same numerical value and semantics remain. |

## Plan-card geometry and color

- Active plan rows use the broad alternating Expressive row silhouettes. Each bright plan-identity block uses a complementary inner radius constrained to the outer row radius with the existing scaled 5 dp inset; the thumbnail frame therefore no longer clips on its lower corner, and row height is unchanged.
- Identity color stays concentrated in the leading block. The row body uses a neutral container blended with the identity at 13% normally or 16% for the active state, preserving filled-card presence without putting saturated blue behind the anatomy data.
- Both the heatmap frame and its color-resolver surface use the same media-placeholder tone. This keeps blue heatmap highlights legible on blue-identity plans.
- Menu bubble and popup use neutral surfaceContainerHigh. The menu remains a supporting action and does not compete with the plan identity.
- The card press wrapper lets the outer row silhouette compress as a unit; the Material shape clip still contains the thumbnail and row content. Pixel close-ups show no inner-corner clipping.

## Responsive and implementation notes

- At Pixel 7 logical width (about 411 dp) and OS text scale 1.15, the side-by-side focus content grows from 198 dp to 220.5 dp so Focused Sets does not clip. At text scale 1.35 or higher, or width below 340 dp, the heatmap and details stack. The 2x-text widget test verifies this stacked state without overflow.
- The focus surface interpolates its own color while the unchanged child is passed through the shared phase scope. Accent bars and progress painting listen locally, so the entire Train page does not rebuild on each animation tick.
- The ambient owner stops and resets when its visibility threshold is crossed, Overview is inactive, TickerMode is disabled, reduced motion/Effects Off is active, or the app leaves the resumed state. Controllers are disposed with their widgets.
- The normal preview uses standard Flutter Material widgets and Tonos-owned paint/gesture wrappers. It does not imply spring-based layout morphing, a third-party animation package, an idle avatar spinner, or animation on other Tonos destinations.
