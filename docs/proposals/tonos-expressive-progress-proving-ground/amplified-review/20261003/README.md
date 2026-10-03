# Tonos Expressive Progress — amplified review

This document presents the amplified Expressive Progress candidate for visual review against the qualified Train + shell and Active Workout reference system. The work substantially departs from Classic presentation in the Expressive branch while retaining the existing Progress content, chart data, semantics, and product workflows. Focused and integrated QA have passed, and the fresh light/dark Pixel captures are ready for review. This candidate is ready for **visual review only**; Progress qualification, family promotion, and full-suite qualification remain deferred until the user reviews and approves the direction.

The amplified captures below came from Pixel 7 (`28021FDH200228`, Android 16, 1080 × 2400), running the isolated debug preview package `com.tonos.expressivepreview` with `tonos_expressive_preview.db`. The DEBUG ribbon is a build-mode indicator, not part of the theme. This evidence does not represent a release build. The original Pixel 7 captures and foundation notes remain in the parent [Progress review](../../README.md) as before; this separate amplified review set does not replace the foundation evidence.

## Selected architecture

### Workout Report

The report direction uses a left-aligned title and a single analytical focal area with a strong tonal hierarchy for the selected metric, range controls, chart, and supporting detail. The intended composition preserves direct reading of the selected value and trend while giving metric and range selection the static Expressive identity used elsewhere in the reference system.

### Exercise Progress home

Exercise Progress is composed as one asymmetric tonal module. A left-aligned identity/title zone and chart form the focal area; a unified split or stacked tonal summary rail carries both **actual 1RM** and **estimated 1RM**, with their labels and values. The rail is one integrated surface, not two separate generic metric cards. When no actual 1RM exists, the actual value remains explicitly absent instead of being inferred from the estimate.

A compact, accessible teal **Edit** action sits beside the section heading. Selection, add, and remove workflows stay available in edit mode, and the selector keeps its accessibility labels and actions. The amplified treatment removes the large isolated selector edit tile from the Expressive composition.

#### Actual 1RM summary refinement

Exercise Progress displays the localized **Actual 1RM** label and an em dash when no actual value exists; accessibility semantics exposes **“No actual 1RM.”** Only the missing Actual delta row is omitted. Estimated 1RM and its delta remain visible. Chart and data behavior are unchanged. Same-state captures: [light](exercise-progress-summary-light.png) · [dark](exercise-progress-summary-dark.png).

The focused responsive widget test passed (**7 passed**), scoped analysis passed with no issues, and `git diff --check` passed. The full suite is intentionally deferred for this scoped refinement; this note does not claim broad qualification.

### Health Trends

The intended review covers the empty state, metric-card shapes, **+ Metric** action, and horizontal scrolling. Empty measurements remain honestly represented as empty; no trend values are fabricated for the candidate.

### Ab Wheel detail

The detail page gives the 1RM chart a strong asymmetric analytical focal surface, with an intentional tonal header, inset plot surface, and legend. The selected-point callout remains anchored to the same plotted point and coordinates and reports that point's actual values and date. The chart painter, scale, data points, coordinates, range logic, series colors, and point-selection behavior are retained.

Recordings become a cohesive flat tonal group. Each row keeps the date and labeled actual/estimated values, explicitly represents a missing actual value, and uses a compact chevron with the existing session-navigation response. Rows remain pressable and scannable without nested outlined-card hierarchy.

## Integrity and behavior contract

- Chart painters, scale, plotted points, coordinates, range logic, point selection, data colors, and chart semantics remain the established implementation. Styling changes add tonal structure around the chart and callout; they do not animate plotted values or geometry.
- The selected-point callout continues to describe the actual selected point. Actual and estimated 1RM remain separate labeled measures, and unavailable actual data stays absent in both the home summary and recordings.
- Existing callbacks, state, selectors, routes, and add/remove/edit workflows remain in place. The expressive composition does not change workout or measurement data.
- The selected Expressive exercise hero exposes its truthful selected state in semantics. Classic and Neo retain their prior hero semantics.
- Classic and Neo keep their existing presentation and chart-color resolver paths. Amplified visual treatment is scoped to Expressive; no shared theme roles or dependencies are added by this slice.
- No ambient chart controller or per-frame plotted-geometry rebuild is introduced. Press feedback belongs to interaction chrome. Reduced Motion should preserve the static Expressive identity and snap interaction changes without animating chart geometry; exact behavior remains part of final QA/Pixel verification.

## Responsive and accessibility review matrix

The intended width and text-scale matrix is:

| Available width | Text scale | Expected review |
| --- | --- | --- |
| 320 dp | 1×, 1.15×, 1.5×, 2× | Summary rail stacks cleanly; labels, values, edit action, selectors, and chart remain available without overflow. |
| 420 dp | 1×, 1.15×, 1.5×, 2× | Asymmetric composition reflows as needed; title remains left-aligned, and dense analytical content remains legible. |

Expressive responsive coverage exercised 320 dp at 1×, 1.15×, 1.5×, and 2×, along with the 420 dp responsive case. Classic and Neo have scoped regression coverage, not the same full width/text-scale matrix. Focused responsive widget coverage and the integrated batch have passed. Review touch targets and semantic labels for Edit/Done, selector actions, chart points, recordings, and route navigation in the captures and on-device candidate.

## Pixel evidence

The following matched light/dark screenshots are the current primary review set:

- Workout Report: [light](workout-report-light.png) · [dark](workout-report-dark.png)
- Exercise Progress and Health Trends: [light](exercise-health-light.png) · [dark](exercise-health-dark.png)
- Exercise detail: [light](exercise-detail-light.png) · [dark](exercise-detail-dark.png)

Supporting captures show the [1M range](support-workout-report-1m-light.png), [expanded report details](support-report-details-expanded-light.png), [time metric](support-report-time-metric-light.png), [historical selected point](exercise-detail-selected-point-light.png), and [Reduced Motion in light](support-reduced-motion-light.png) and [dark](support-reduced-motion-dark.png). The six primary images and both Reduced Motion images were visually accepted for this review. The original foundation screenshots remain in `../../review/` and were not replaced.

### Fixture and date comparison caveat

The preview startup manifest reseeded its fixture for the October 3 device run. The BEFORE All-range Report evidence has two weekly buckets: Sep 21 with 1 workout and Sep 28 with 5. The AFTER capture has one Sep 28–Oct 4 bucket with 6 workouts. The totals remain 6 workouts, 2h24m, and 7.1k lbs, but the bucket grouping and dates do not match exactly.

The expanded All-details summary also changes with the reseed and bucket range: AFTER shows 6.0 Avg/week, a 3-day longest streak, Friday as most active, and 2.5k lbs Best Volume. BEFORE showed 0.2 Avg/day, a 2-day longest streak, Thursday as most active, and the same 2.5k lbs Best Volume. These differences are fixture/date aggregation changes, not a claim that the two screenshots use identical buckets or detail summaries.

The current Ab Wheel detail has four recordings dated Oct 1–2. Each displays an estimated 27 lbs and no actual 1RM. The selected historical point is Oct 2 at 1:56 AM; its selected date/value semantics were confirmed on device. The current 1M report's latest day also reflects Oct 3 data. No fixture recipe/series edits or manual measurement additions were made for these captures.

### Interaction and motion evidence

Workout Report metric and range interactions use native InkWell feedback with duration-gated transitions; they do not use a custom spring response. Exercise Progress selector and edit flows remain available. The Reduced Motion light/dark captures show the static Expressive presentation. During the Pixel Reduced Motion check, Time was tapped and captured immediately at [the immediate Time response capture](support-reduced-motion-time-immediate.png); Time was already selected and the chart had updated without waiting. The chart's plotted values, coordinates, and selected-point geometry remain static; no ambient chart controller or per-frame plotted-geometry rebuild was introduced. No motion clip or frame-time/profile result was captured, so this review makes no frame-by-frame motion or performance claim.

The final device state was restored to Progress → Workouts → All, Details collapsed, and normal motion. The Reduced Motion stills and all six primary screenshots were visually accepted for presentation in this review; this is not user approval or qualification.

## Validation status

Final reported QA ran with Flutter 3.47.5 / Dart 3.13.4 and normal `C:` `TEMP`/`TMP` paths:

- Scoped analyzer: **0 errors, 0 warnings, 0 infos**, exit 0, 10.44 seconds.
- Focused Exercise batch: **7 passed, 0 failed, 0 skipped**, exit 0, 18.82 seconds.
- Integrated five-file batch: **31 passed, 0 failed, 0 skipped**, exit 0, 41.03 seconds.
- Diff check: **0 findings**.

The final clean rerun supersedes the interim failures recorded during iteration. The selected Expressive hero now reports `selected: true`; Classic and Neo keep their prior semantics. Expressive responsive checks cover 320 dp at all four text scales and the 420 dp responsive case; Classic and Neo are covered by scoped regressions rather than the full matrix. Reduced Motion retains the static Expressive identity, and the immediate Time-state update was captured on device. Full-suite qualification and Progress qualification remain deferred until user approval.

## User review questions

1. Does Progress now feel as unmistakably Expressive as Train and Active Workout?
2. Is Workout Report's composition bold enough?
3. Do the selected metric and range controls feel like the established Tonos Expressive family?
4. Is the chart still clear and trustworthy?
5. Does Exercise Progress now feel like one coherent component rather than nested cards?
6. Is the new edit action appropriately sized and placed?
7. Do Health Trends empty states feel intentional?
8. Does the Ab Wheel detail page finally feel like Tonos Expressive rather than Classic?
9. Are Recording rows expressive enough while remaining easy to scan?
10. Is anything now too visually busy for an analytical screen?
11. Does dark mode feel equally intentional?
12. Does Reduced Motion retain enough static Expressive identity?

The amplified Progress candidate is ready for visual review against the qualified Train + shell and Active Workout reference system. The redesign was allowed to depart substantially from Classic presentation while preserving data integrity, chart semantics, accessibility, and product workflows. Do not qualify Progress until this stronger static and interaction language is approved.
