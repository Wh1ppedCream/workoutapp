# Tonos Expressive Progress + Logbook review

**READY FOR USER REVIEW. Not qualified.** This combined review brings the completed Progress visual review together with the Logbook Training Almanac adaptation. The candidate is ready for visual review only; full-suite qualification, theme-family qualification, and family promotion remain deferred until the user reviews and approves the direction.

## Progress review

The six-screen Progress evidence covers Workout Report, Exercise Progress, Health Trends, and Ab Wheel detail in matched light/dark captures. The [amplified Progress review](../tonos-expressive-progress-proving-ground/amplified-review/20261003/README.md) remains the source for its design, chart and data integrity, responsive coverage, Reduced Motion evidence, fixture caveats, and review details.

- Workout Report: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/workout-report-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/workout-report-dark.png)
- Exercise Progress and Health Trends: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-health-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-health-dark.png)
- Exercise detail: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-detail-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-detail-dark.png)

## Logbook review captures

The Logbook captures are Pixel 7 debug-preview stills for the stated mode, theme, and selection. The DEBUG ribbon indicates build mode; it is not part of the visual theme. The images are review evidence, not release-build screenshots.

### Selected date: Oct 2

- Expressive: [light, corrected contrast](captures/logbook-expressive-oct2-light.png) · [dark](captures/logbook-expressive-oct2-dark.png)
- Classic comparison: [light](captures/logbook-classic-oct2-light.png) · [dark](captures/logbook-classic-oct2-dark.png)

### Expressive range and empty-history states

- [3M, Oct 1–7, light](captures/logbook-expressive-3m-light.png)
- [Year, light](captures/logbook-expressive-year-light.png)
- [4Y, light](captures/logbook-expressive-4y-light.png)
- [2023 with no sessions, light](captures/logbook-expressive-2023-empty-light.png)

### Full History

- Expressive: [light](captures/full-history-expressive-light.png) · [dark](captures/full-history-expressive-dark.png)
- Classic: [light](captures/full-history-classic-light.png) · [dark](captures/full-history-classic-dark.png)

### Session Detail

- Expressive: [light](captures/session-detail-expressive-light.png) · [dark](captures/session-detail-expressive-dark.png)
- Classic: [light](captures/session-detail-classic-light.png) · [dark](captures/session-detail-classic-dark.png)

### Reduced Motion and final restored state

Reduced Motion was enabled with Month selected and Oct 2 selected. After tapping Oct 2, the [40 ms immediate capture](captures/reduced-motion-oct2-immediate.png) already showed Friday, the selected date, and all three session rows. This confirms the state snaps promptly with Reduced Motion enabled. The evidence is a static still: no motion clip or frame-time profile was captured, so this review makes no repeated-motion or animation-performance claim.

The [final restored device capture](captures/final-restored-logbook-state.png) shows Expressive light, Logbook, Month mode, the default current date Oct 3 with no sessions, and normal motion restored.

## Training Almanac composition and workflow

The reviewed route flow is `HistoryScreen → HistoryContent → WorkoutHistoryCalendar`. The calendar retains Month, 3M, Year, and 4Y modes and the existing day, week, month, and year selection behavior. The selected interval’s session rows lead the Expressive retrospective view; the existing heatmap and workout-count, duration, and volume totals sit in a compact secondary inset. Selection is conveyed through semantics and visible state cues, not color alone.

Selected session rows open Session Detail. The selected-period full-history action opens Full History, where date-led rows retain their detail navigation and reload behavior. Session Detail keeps its date, completed sets, volume, duration, exercise count, optional body-part heatmap and focused-set list, ordered exercise cards, record badges, set rows, and estimated 1RM. Edit, delete, dirty-save and back-confirmation flows, the exercise detail sheet, Repeat, and Save as Plan remain available. Existing cardio and stretch rendering behavior is retained.

The Expressive treatment adds a plum date-led summary, a responsive teal metric rail, a contained heatmap/focused-set inset, and asymmetric tonal exercise surfaces. Full History emphasizes localized dates and allows them to wrap. Styling stays within explicit Expressive branches; Classic and Neo presentation paths remain unchanged. No shared theme roles or dependencies were added for this Logbook slice.

The Expressive responsive matrix covers the calendar, Full History, and Session Detail at 320 dp in light and dark themes at text scales 1×, 1.15×, 1.5×, and 2×: **24 configurations**. Each checks key content/actions and that the widget tree reports no exception. No 420 dp Logbook matrix is claimed. The existing 3M selector remains in its current three-month layout.

## Device, fixture, and visual-review notes

Captures were made on Pixel 7 `28021FDH200228`, using the isolated debug preview package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`. Flutter 3.47.5 / Dart 3.13.4 were used; the `C:` drive had 5.43 GiB free. The preview was installed with `adb install -r`. No workout actions that mutate history were performed during capture.

The fixture contains six 2026 sessions: three on Oct 2, one on Oct 1, one on Sep 30, and one on Sep 28. Totals are **2h24m** and **7.1k lbs**. Oct 2 totals **3 workouts, 46m36s, and 2.5k lbs**. The Oct 1–7 3M selection totals **4 workouts, 1h8m, and 3.7k lbs**. The 2023 selection has **0 sessions**. Dates and durations match across Classic and Expressive captures.

The agent visually checked the captured layouts and contrast. In the Classic overview Oct 2’s session rows fall below the captured fold; the Classic Full History and Session Detail captures show the history content fully for comparison.

## QA status

The latest reported focused Logbook QA was:

- Scoped analyzer: **clean**.
- Five focused files: **20 passed, 0 failed, 0 skipped**, exit 0, 24.89 seconds.
- Diff check and theme-style inventory: reported green; the inventory recorded **5 migrated, 0 pending**.

These focused results do not constitute full-suite or theme-family qualification. Progress and Logbook qualification remain deferred pending user review and approval.

## User review questions

### Progress

1. Does Progress now feel as expressive as Train and Workout?
2. Is Workout Report bold enough?
3. Is the chart still trustworthy and easy to read?
4. Does Exercise Progress now feel coherent?
5. Is Health Trends visually strong enough?
6. Does the detail page finally feel Expressive?
7. Is anything too decorative for analytics?

### Logbook

1. Does Logbook clearly belong to the same Expressive system?
2. Is historical browsing still fast and scannable?
3. Are session cards distinct enough from Classic?
4. Is chronology/date navigation clear?
5. Is the density appropriate?
6. Do historical-detail screens feel like the same system?
7. Is any repeated motion annoying? For this review, motion behavior is represented by static stills; only the immediate Reduced Motion snap is confirmed, and no motion clip was captured.
8. Does dark mode feel intentional?

The combined Progress + Logbook slice is **READY FOR USER REVIEW**, not qualified. Both were allowed to depart substantially from Classic presentation while preserving Tonos data, workflows, semantics, and the qualified reference principles. Do not qualify either slice until the user reviews them together.
