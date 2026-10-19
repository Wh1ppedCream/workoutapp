# User visual review list

This is the review checklist for the fresh, source-matched preview build. The captures are not available yet. For every item, compare the same fixture/state in light and dark. Judge hierarchy while squinting: focal surface, supporting groups, selection, and page rhythm should remain legible without relying on text. Verify lower-page composition too; an expressive hero followed by generic white cards is not a complete treatment.

## Review each family

1. **Train → Overview and Plans; navigation shell (reference / responsive regression only).** Open Train and inspect both Overview and Plans in light/dark at normal width. Confirm destinations remain Train, Catalog, Logbook, Progress, Profile and that selection/tabs match the established shell. At 320 dp and 1.5×/2× text, inspect Start/Optimize arrangement, Focused Sets split/stack, and plan controls. Check reduced motion and the settled idle state. Expected change: only adaptive behavior where needed; normal-width approved composition should match the reference.

2. **Active Workout / Session (reference / responsive regression only).** Start or resume a preview workout, open an exercise card, inspect several set rows, complete a non-final set, then the final set; focus Weight/Reps and show the keyboard. Repeat in dark, at narrow width, and with large text. Check stacked labels/fields, completed/incomplete distinction, FAB/Finish controls, scrolling and expansion. Expected change: only responsive label/layout handling; normal-width cards and logging workflow remain the established reference.

3. **Train → Plans → Preset Detail.** Open a populated plan and review top, exercise list, lower settings, and actions in light/dark. Inspect edit, add, reorder, swap/detail, Save/Discard and Start handoff states; use long exercise/plan names and narrow width. Expected change: plan identity and exercise grouping have stronger focal/warm/cool zones and varied role-based geometry while all exercises, metadata, and callbacks remain.

4. **Train → gym avatar/drawer → Gym Profile.** Review search idle/query/no-match, category expanded/collapsed, selected equipment, reset/select-all, save and unsaved-exit dialog in both modes. Test keyboard, 320 dp and 1.5×/2× text. Expected change: profile identity and equipment groups read as a designed configuration surface, with selection obvious; do not lose equipment rows or draft-vs-save behavior.

5. **Train → Optimize → settings gear.** Inspect workout budget, rep/weight and focus groups, reset, validation, Save and Start Now. Repeat in dark, at 320 dp and 2× text with keyboard. Expected change: stronger grouped focal/supporting regions and clearer action hierarchy, preserving the distinction between persistent Save and one-shot Start Now.

6. **Train → Plans → Active/Archived plan management.** Inspect populated and empty sections, Automatic/Visible/Hidden status, Archive/Activate, pending spinner and rollback/error state. Scroll and review narrow actions in light/dark. Expected change: active/archive sections and plan identity have visibly different role/tonal hierarchy while retaining order, membership, and the single available per-row action.

7. **Train → Plans → Browse Premade Plans.** Review duration and equipment filters, each source category, expanded plan, selected/adapted state, Add pending/success/error, and onboarding footer if reachable. Check both modes, 320 dp and 1.5×/2× text. Expected change: category/source surfaces and duration/equipment selection are more legible and compositionally distinct; plan descriptions, compatibility/replacement cues and Add behavior stay intact.

8. **Catalog root → Exercise Catalog browser.** In light/dark inspect idle, focused search, results, no-results, filters open/edit/apply/cancel, selected row if picker caller, media loading/fallback/retry and Details sheet. At 320 dp use long names. Expected change: browser and filter surfaces carry the same clear destination identity as the root; selected foreground must contrast against selected fill; media fallback and search/filter workflow remain.

9. **Catalog → Bodyparts/Muscles → Exercise Focus Library.** Inspect both tabs, search/query/empty, selection, anatomy media and fallback, then open bodypart and muscle detail. Review light/dark and narrow width. Expected change: drilldowns retain expressive color zoning instead of falling back to neutral lists; taxonomy, source relationships, and selections remain clear.

10. **Catalog → Bodypart detail and Muscle detail.** Inspect hero/anatomy, set/recommendation summary, muscle/bodypart links, edit-range dialog, ranked exercises, empty state, long names and exercise detail sheet. Review both themes and scrolling. Expected change: focal entity and supporting data groups have distinct visual roles; recommendation ranges and exercise ranking remain readable and semantically unchanged.

11. **Exercise Details sheet.** Open from browser/details or anatomy route. Review media loaded and fallback, Form Guide/Equipment/Target Anatomy expansion, tabs that are in scope, scroll/resize, dismiss/back, both modes and 320 dp. Expected change: deliberate modal/sheet silhouette and tonal grouping; shared Metrics/Records behavior should stay at its caller-owned presentation.

12. **Progress root → Workout Report.** Review top metrics, chart, date labels, range selection, Additional Details and scrolled lower content in light/dark. Ensure selected metric is apparent and AUG/SEP tick labels no longer collide at normal and narrow widths/1.5× text. Expected change: clearer health/Progress surface identity without changing chart series colors, data, selected point, or semantic increase/decrease.

13. **Progress → Exercise Progress.** Inspect selected exercise, chart, Actual/Estimated values, empty/one-entry/populated states and exercise selector. Review light/dark, scroll, 320 dp and large text. Expected change: focal data and supporting metric surfaces have intentional tonal contrast; chart meaning, units and point selection remain unchanged.

14. **Progress → Health Trends and Measurement Trend detail.** Inspect metric cards, add/edit/delete measurement dialogs, empty/populated chart and nested detail; verify the originating destination identity is retained on return/detail. Review both modes and narrow width. Expected change: health cards use an intentional Expressive destination role rather than blending into generic `surfaceContainer`; chart/data colors and measurement semantics remain.

15. **Logbook → Month / 3M / Year / 4Y.** Select each period, inspect selected/unselected day/tile geometry, month changes, calendar/history and empty/populated content in light/dark. At 320 dp/2× inspect 4Y labels: years must remain understandable without `20…` truncation or unreadably small text. Expected change: period-appropriate selection geometry remains coherent and the broader calendar has clear visual rhythm.

16. **Logbook → Full History.** Review grouped dates, multiple sessions, empty/loading states, row selection, and transition to Session Detail in both themes. Expected change: date groups read as structural plum bands and sessions remain clear within the supporting surface; chronology, duration, and session actions stay intact.

17. **Logbook / Progress → Session Detail.** Review summary and exercise/set history, edit/repeat/rename or destructive dialogs as available, keyboard and scroll. At extreme text scale verify metrics wrap without overlap. Expected change: stronger session identity and grouping without changing logged values or available actions.

18. **Profile root and child settings.** Review Account, Training and Data groups; Nutrition disabled state; selected destination icons; User Information fields, UI & Appearance, Navigation Editor and Guided Tutorials. Inspect lower sections, selected rows, save states and dialogs in light/dark; test 320 dp and 1.5×/2× text. Expected change: settings should scan as designed Tonos destinations rather than Android preferences; category identities, current labels/values, disabled status and edit/save behavior remain.

19. **Profile → Analytics Settings (seven-route family).** Visit Analytics Settings, Body Part Ranking, Muscle Ranking, Volume Boundaries, Anatomy Mapping, Exercise Set Allocation and Exercise Editor. For each inspect top and lower content, selected options/rows, edit/save/cancel, reorder where present, validation and dialogs in light/dark. Test 320 dp at 1.5× and 2× text: page headers and important context must wrap rather than truncate. Expected change: dedicated analytics/configuration identity with real chromatic zones, organized controls, and readable hierarchy; ranking/allocation/mapping meaning and editor behavior remain.

20. **Motion and Reduced Motion.** For any page where source adds tactile/selection motion, capture/observe a short interaction: press/release, selection, expand/collapse, add/remove or reorder. Compare normal motion with Reduced Motion enabled. The static page must still look Expressive; with Reduced Motion, nonessential movement should settle immediately, ambient loops should stop, and all actions remain identical. Do not infer motion changes from static screenshots.

## Global acceptance questions

For each changed route, ask: Is the page unmistakably Tonos Expressive? Is its composition materially distinct from Classic? Do color and shape communicate role? Does the lower half hold the same identity as the hero? Is dark mode chromatic and section-distinct? Can the information be understood at a glance? Are all actions, data meanings, states and workflows retained? Do 320 dp and large text adapt without overlap, hidden actions, or unnecessary truncation?
