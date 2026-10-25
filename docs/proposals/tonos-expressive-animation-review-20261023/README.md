# Tonos Expressive - Animation Review Checklist

Updated: 2026-10-25.

**Progress: 6 approved / 11 pending / 17 total.**

This checklist tracks the recent Expressive animation additions and refinements. A checked item means the user explicitly approved its current motion. An unchecked item remains available for review and refinement; implementing a fix alone does not check it off. These motion decisions are separate from existing page visual approvals and from technical, accessibility, performance, or release qualification.

See the [2026-10-24 production-motion review](motion-readiness-review-20261024.md) for the per-item findings, changes, focused checks and remaining performance limitations.

The [2026-10-25 deeper interaction review](deeper-interaction-review-20261025.md) records responsive menu fixes and broader navigation, accessibility and editing checks. Approval totals are unchanged.

## Approved

- [x] **M01 - Bottom-tab page transitions.** Approved by the user on 2026-10-23. Outgoing content fades away and shrinks to 97% over 40ms. Incoming content starts at 30ms, producing a 10ms overlap; it scales from 95% to a 101.5% peak at about 80ms and settles at 100% by 150ms. **Try:** switch between bottom navigation tabs.
- [x] **M02 - Swap Exercise replacement transition.** Approved by the user on 2026-10-23. Replacement candidates use a short directional slide/fade; navigation controls retain their press feedback. **Try:** Train > Plans > open a plan > Edit > exercise menu > Swap Exercise, then use the replacement arrows. This approval concerns the swap interaction; the shared sheet entrance remains part of M09.
- [x] **M03 - Nutrition totals, rings and bars.** Approved by the user on 2026-10-24 after the ring-fill refinements. Rings fill from empty to their current goal progress over 630ms whenever their page becomes active, including first entry and returning to a cached tab or a covered page. Entry does not count the displayed numbers up from zero. Totals and meters still animate together when calorie or macro values change. Reduced motion shows final values immediately. **Try:** switch away from Nutrition and back, and try the Dashboard nutrition widget. Also log or edit food and return to Daily nutrition.
- [x] **M04 - Nutrition floating action menu.** Approved by the user on 2026-10-24 after the button-width refinements. The plus rotates as food and measurement actions appear or disappear. Each option fits its own label and icon, with their right edges aligned above the toggle; labels and shadows remain unclipped. **Try:** Nutrition > bottom-right plus; open and close it.

- [x] **M05 - Workout set feedback and exercise-card expansion/collapse.** Approved by the user on 2026-10-24 after the completion feedback, expansion smoothness and final-set timing refinements. The user subsequently requested 20% shorter opening/closing animations: card height, corners and header spacing now share the same 288ms settling recipe (previously 360ms). Completion indicators/counts and row tint remain 308ms. Completing the final set still has a short 200ms confirmation pause before automatic collapse; undoing completion or manually toggling the header cancels it. Hidden fields are retained after the first expansion with their tickers disabled, reducing reopening work. Rapid updates retarget from the painted state; added rows settle once. Approval covers this active-workout interaction group; completion-record badges (M06), planning accordions (M07) and other shared callers remain separate review targets. **Try:** Train > Start Workout; complete/undo individual sets, complete the final set, add/remove a set, and repeatedly expand/collapse an exercise.

- [x] **M06 - Workout completion records.** Approved by the user on 2026-10-25. Newly earned record badges receive a restrained, one-time pulse. Historical results remain settled. This approves the M06 animation item; other pending animation groups retain their existing status. **Try:** finish a workout that earns a record and view its completion sheet.

## Pending review

- [ ] **M07 - Expandable planning sections.** Headers, chevrons and content use coordinated expansion/collapse motion. **Try:** Train > Plans > Generate Custom Plans or Browse Premade Plans. Also review the equipment groups in Gym Profile / Equipment.
- [ ] **M08 - Workout Report charts.** Matching date buckets interpolate when their values change, and the selected-point indicator moves between points. New or differently grouped buckets show their actual values directly instead of borrowing unrelated old values; unchanged series do not run an empty data transition. **Try:** Progress > Workout Report; change the date range, switch metric views, and select graph points.
- [ ] **M09 - Shared menus, dialogs and sheets.** Shared overlays use approximately 220ms opening / 160ms closing motion, without the removed extra dialog scale. **Try:** Catalog Filters, exercise overflow menus, and plan action dialogs/sheets. Review each overlay type before approving this group.
- [ ] **M10 - Health Trends charts.** Mini charts and detail charts interpolate when measurement data changes. **Try:** Nutrition > Health Trends > Weight or another metric; add/edit an entry and observe the updated chart.
- [ ] **M11 - Dashboard customization.** Dragged cards lift slightly, moved/restored rows settle, and count badges pulse smoothly when their counts change. Static/reduced-motion layouts preserve child state without running a zero-duration resize. **Try:** Dashboard > Customize dashboard; reorder widgets and move widgets between visible and hidden groups.
- [ ] **M12 - Bodypart selection feedback.** Preferred, avoided and neutral states transition their colors and pulse their indicators. **Try:** Train > Optimize > Bodypart focus, or Generate Plans > Training focus; cycle a chip through all three states.
- [ ] **M13 - Conditional Save Changes button.** The action establishes space before fading in with a restrained scale change; its surface and shadow are not clipped by the size reveal. It fades away during the faster exit when no changes are pending, leaving no reserved space while hidden. **Try:** Train > Plans > open a plan > Edit; change its name, exercises or sets.
- [ ] **M14 - Bodypart and muscle rankings.** Dragged rows receive a modest lift and rank indicators respond to position changes. **Try:** Profile > Gym & Workout Settings > Workout Settings > Body Part Rankings or Muscle Rankings; drag a row.
- [ ] **M15 - Workout Progress Rules dropdowns.** Options reveal together over 160ms instead of arriving in a staggered sequence. The applicable chevron rotates and changed selections receive a smooth small pulse. **Try:** Profile > Gym & Workout Settings > Workout Progress Rules > Add/Edit Rule; open and change choice fields.
- [ ] **M16 - Plan Progression graph.** Graph edits keep the canvas steady; the extra whole-canvas nudge has been removed so it does not add displacement to graph editing. Native control feedback remains. **Try:** open an automatic plan > overflow menu > Plan Progression; make a structural graph edit and pan/select nodes.
- [ ] **M17 - Onboarding.** Progress advances smoothly, pages move between steps, choices transition, and the Finish Setup floating action appears on the final step. Navigation controls wait for the current slide to settle, preventing queued taps from skipping another step. Titles remain steady. **Try:** Profile > UI & Appearance > Replay Onboarding, then fully close and reopen Tonos.

## Removed effects

These are excluded from the pending total because they were removed following user feedback:

- Expanded exercise-image opening animation.
- Calendar/results slide and resize additions.
- Onboarding title fade.
- Workout completion header/stat stagger.

There is no separate remaining nutrition-tools animation beyond the nutrition feedback, floating menu and shared overlays listed above. Recent additions respect reduced-motion/effects settings; this checklist does not claim comprehensive device or accessibility validation.

## Review record

- **2026-10-23:** User explicitly approved Bottom tabs and Swap Exercise and requested this checklist. M01 and M02 checked; all other listed motion groups remain pending.
- **2026-10-24:** Shortened M03 ring entry from 900ms to 630ms following user feedback and submitted it for review.
- **2026-10-24:** User explicitly approved M03 after reviewing the ring-fill refinements. M01-M03 checked; 3 approved / 14 pending / 17 total.
- **2026-10-24:** User explicitly approved M04 after reviewing the fitted, right-aligned menu options. M01-M04 checked; 4 approved / 13 pending / 17 total.
- **2026-10-24:** Production-motion review refined pending feedback, conditional actions, date-aware chart changes, rule dropdowns, graph stability and onboarding navigation, and fixed the dashboard resize fallback. M01-M04 remain approved; M05-M17 remain pending the user's visual approval.
- **2026-10-24:** User explicitly approved M05 following the set-feedback and exercise-card expansion/collapse refinements, including the 200ms final-set pause. M01-M05 checked; 5 approved / 12 pending / 17 total. M06-M17 remain pending; this is motion approval, separate from technical and release qualification.
- **2026-10-24:** After approving M05, the user requested opening and closing to take 20% less time: 360ms to 288ms. The completion pulses/row tint (308ms), final-set pause (200ms), other interaction groups and approval totals are unchanged. The earlier visual approval preceded this explicitly requested timing adjustment.
- **2026-10-25:** User explicitly approved M06 - Workout completion records. M01-M06 checked; 6 approved / 11 pending / 17 total. M07-M17 remain pending. This records animation approval only and does not grant additional technical or release qualification.
