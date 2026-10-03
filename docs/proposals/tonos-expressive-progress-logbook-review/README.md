# Tonos Expressive Progress + Logbook + Profile review

**READY FOR ONE COMBINED VISUAL REVIEW. Not qualified.** This guide brings the amplified Progress candidate, Logbook adaptation, and Profile-family treatment together. Full-suite and theme-family qualification remain deferred until the user reviews all three.

## Progress review

The six-screen Progress evidence covers Workout Report, Exercise Progress, Health Trends, and Ab Wheel detail in matched light/dark captures. The [amplified Progress review](../tonos-expressive-progress-proving-ground/amplified-review/20261003/README.md) remains the source for chart and data integrity, responsive coverage, Reduced Motion evidence, fixture caveats, and detailed validation.

- Workout Report: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/workout-report-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/workout-report-dark.png)
- Exercise Progress and Health Trends: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-health-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-health-dark.png)
- Exercise detail: [light](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-detail-light.png) · [dark](../tonos-expressive-progress-proving-ground/amplified-review/20261003/exercise-detail-dark.png)

## Logbook review

### Selected date: Oct 2

The Logbook captures are Pixel 7 debug-preview stills for the stated mode, theme, and selection. The DEBUG ribbon indicates build mode; it is not part of the visual theme. The images are review evidence, not release-build screenshots.

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

### Training Almanac composition and workflow

The reviewed route flow is `HistoryScreen → HistoryContent → WorkoutHistoryCalendar`. The calendar retains Month, 3M, Year, and 4Y modes and the existing day, week, month, and year selection behavior. The selected interval’s session rows lead the Expressive retrospective view; the existing heatmap and workout-count, duration, and volume totals sit in a compact secondary inset. Selection is conveyed through semantics and visible state cues, not color alone.

Selected session rows open Session Detail. The selected-period full-history action opens Full History, where date-led rows retain their detail navigation and reload behavior. Session Detail keeps its date, completed sets, volume, duration, exercise count, optional body-part heatmap and focused-set list, ordered exercise cards, record badges, set rows, and estimated 1RM. Edit, delete, dirty-save and back-confirmation flows, the exercise detail sheet, Repeat, and Save as Plan remain available. Existing cardio and stretch rendering behavior is retained.

The Expressive treatment adds a plum date-led summary, a responsive teal metric rail, a contained heatmap/focused-set inset, and asymmetric tonal exercise surfaces. Full History emphasizes localized dates and allows them to wrap. Styling stays within explicit Expressive branches; Classic and Neo presentation paths remain unchanged. No shared theme roles or dependencies were added for this Logbook slice.

The Expressive responsive matrix covers the calendar, Full History, and Session Detail at 320 dp in light and dark themes at text scales 1×, 1.15×, 1.5×, and 2×: **24 configurations**. Each checks key content/actions and that the widget tree reports no exception. No 420 dp Logbook matrix is claimed. The existing 3M selector remains in its current three-month layout.

## Profile-family review

### Route audit and scope

The Profile bottom-tab route is `ProfilePage`. Its seven active root destinations remain wired to their existing pages and callbacks. The candidate adapts ordinary personal setup and preferences while preserving local state ownership and the disabled Nutrition state.

| Route or control | Review scope | Reason |
| --- | --- | --- |
| Profile root | Included | Personal setup and settings entry point; uses only existing Profile title/subtitle and a person icon as its identity anchor. |
| User Information | Included | Local personal details and activity profile editing. |
| UI & Appearance | Included | Theme, dark mode, onboarding preference, weight unit, language, and bottom-tab customization. |
| Guided Tutorials | Included | User-facing help and tutorial reset/replay controls. |
| Gym & Workout Settings | Included | Local training defaults and workout behavior. Includes the workout-exit choice dialog, Workout Progress Flows selection/editor, and Flow Methods selection/editor. |
| Progress Settings | Included as configuration only | Personal measurement settings and the Measured Items Library belong to profile setup; Progress analysis screens remain outside this Profile review. |
| Database Settings | Excluded from redesign | Direct root destination retained, but database maintenance, backup/import/export, and content administration are outside ordinary profile setup. |
| Diagnostics | Excluded from redesign | Direct root destination retained; diagnostics controls are outside the personal setup experience. |
| Nutrition | Excluded | The existing Nutrition row stays disabled with its Later status; no Nutrition workflow or capability is introduced. |
| Analytics Settings screen | Excluded from redesign | Reachable from Gym & Workout Settings but treated as a separate analytics/settings route in this batch. Its route remains intact. |

The included associated pages are User Information, UI Appearance, bottom-tab Navigation Editor, Guided Tutorials, Gym & Workout Settings, its exit-choice dialog, Workout Progress Flows and its editor, Flow Methods selection and editor, Progress Settings, and the Measured Items Library. The scope does not add cloud profiles, social identity, an online avatar, account sync, or account-dashboard concepts. Profile data and preferences remain local-first.

### Composition and treatment

The root uses a filled plum identity cover with the real Profile title and subtitle, a person outline icon, and no invented name, avatar, or profile selector. Account, Training, and Data settings sit in distinct tonal groups; User Information is featured within the Account group, while the Nutrition group remains visibly disabled. The groups use filled surfaces and varied containment to give the root a stronger hierarchy than a stack of Classic settings cards.

Associated pages use Expressive-specific presentation branches with tonal grouping, filled preference surfaces, and stronger focal/supporting roles while retaining their real labels, fields, selection controls, actions, tutorial anchors, and routes. User Information remains an editable local form. UI Appearance groups display, units/language, and navigation preferences. Gym settings groups workout logic and flow tools; measurement settings lead to the local measurement-item library. Classic and Neo continue through their existing presentation paths.

### Profile captures

All links below point directly to Profile-family captures present in `captures/profile/` when this guide was assembled. These are review stills, not motion recordings.

**Root and theme comparison**

- Expressive root: [light](captures/profile/profile-expressive-light-root.png) · [dark](captures/profile/profile-expressive-dark-root.png)
- Expressive scrolled root: [light](captures/profile/profile-expressive-light-root-scrolled.png) · [light lower section](captures/profile/profile-expressive-light-root-lower.png) · [dark](captures/profile/profile-expressive-dark-root-scrolled.png)
- Classic root: [light](captures/profile/profile-classic-light-root.png) · [dark](captures/profile/profile-classic-dark-root.png)
- [Expressive light root with Reduced Motion](captures/profile/profile-expressive-light-reduced-motion-root.png)

**Personal setup, appearance, and help**

- User Information: [light](captures/profile/profile-expressive-light-personal-info.png) · [dark](captures/profile/profile-expressive-dark-personal-info.png)
- UI Appearance preferences: [light](captures/profile/profile-expressive-light-appearance-preferences.png) · [dark](captures/profile/profile-expressive-dark-appearance-preferences.png)
- Weight-unit selection dialog: [light](captures/profile/profile-expressive-light-weight-units-dialog.png) · [dark](captures/profile/profile-expressive-dark-weight-units-dialog.png)
- Bottom-tab Navigation Editor: [light](captures/profile/profile-expressive-light-navigation-editor.png) · [dark](captures/profile/profile-expressive-dark-navigation-editor.png)
- [Guided Tutorials, light](captures/profile/profile-expressive-light-tutorials.png)

**Training and measurement preferences**

- Gym & Workout Settings: [light](captures/profile/profile-expressive-light-gym-workout-settings.png) · [dark](captures/profile/profile-expressive-dark-gym-workout-settings.png)
- [Workout exit-choice dialog, light](captures/profile/profile-expressive-light-workout-exit-choice.png)
- [Workout Progress Flows, light](captures/profile/profile-expressive-light-workout-progress-flows.png)
- Flow Methods: [selection, light](captures/profile/profile-expressive-light-flow-methods-selection.png) · [editor, light](captures/profile/profile-expressive-light-flow-methods-editor.png)
- Progress Settings: [light](captures/profile/profile-expressive-light-measurements-settings.png) · [dark](captures/profile/profile-expressive-dark-measurements-settings.png)
- Measured Items Library: [light](captures/profile/profile-expressive-light-measured-items-library.png) · [dark](captures/profile/profile-expressive-dark-measured-items-library.png)

No dark captures were available for Tutorials, the workout exit-choice dialog, Workout Progress Flows, or Flow Methods. No Classic child-page comparisons were captured. The ambiguous `profile-current.png` is not linked as a review state.

### Pixel, fixture, and package caveats

Profile stills were captured on the Pixel 7 using the isolated debug-preview package `com.tonos.expressivepreview` and local database `tonos_expressive_preview.db`. The DEBUG ribbon is a build-mode marker, not part of Profile. Personal details visible in the associated-page captures are local preview-fixture values; they do not indicate an online account or remote profile service. Expressive remains preview-only: it is not persisted as an Appearance option and does not change Classic or Neo availability.

### Responsive and accessibility limits

The Profile root widget matrix covers 320 dp in light and dark Expressive with text scales 1×, 1.15×, 1.5×, and 2×. It checks key root labels, Nutrition’s disabled action and Later state, and framework exceptions before and after scrolling. The root route test checks all seven labels against their existing destinations; a separate child-navigation check mounts Guided Tutorials.

This is a widget-test TextScaler matrix, not a native Android font-scale or screen-reader qualification. The associated child-page captures are representative stills; they do not establish a complete 320 dp/text-scale matrix, keyboard/focus-order audit, or screen-reader pass across all forms, dialogs, and selectors. Only the light root has a Reduced Motion capture, and no Profile motion video was captured.

## Device, fixture, and visual-review notes

The Logbook captures were made on Pixel 7 `28021FDH200228`, using the isolated debug-preview package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`. Flutter 3.47.5 / Dart 3.13.4 were used; the `C:` drive had 5.43 GiB free. The preview was installed with `adb install -r`. No workout actions that mutate history were performed during capture.

The Logbook fixture contains six 2026 sessions: three on Oct 2, one on Oct 1, one on Sep 30, and one on Sep 28. Totals are **2h24m** and **7.1k lbs**. Oct 2 totals **3 workouts, 46m36s, and 2.5k lbs**. The Oct 1–7 3M selection totals **4 workouts, 1h8m, and 3.7k lbs**. The 2023 selection has **0 sessions**. Dates and durations match across Classic and Expressive captures.

The agent visually checked the captured layouts and contrast. In the Classic overview Oct 2’s session rows fall below the captured fold; the Classic Full History and Session Detail captures show the history content fully for comparison.

## Focused validation status

These results are destination-focused evidence only. They do not qualify any of the three destinations or the Expressive family.

| Slice | Latest reported focused status |
| --- | --- |
| Progress | Scoped analyzer: **0 errors, 0 warnings, 0 infos**. Focused Exercise batch: **7 passed**. Integrated five-file batch: **31 passed, 0 failed, 0 skipped**. Diff check: **0 findings**. |
| Logbook | Five focused files: **20 passed, 0 failed, 0 skipped**. Scoped analyzer reported clean; theme-style inventory: **5 migrated, 0 pending**; diff check reported green. |
| Profile | `profile_expressive_presentation_test.dart`: **4 passed, 0 failed**, including the 320 dp × light/dark × four text scales matrix and route checks. Settings-route batch: **13 passed**. Final integrated nine-file Profile-focused regression rerun: **92 passed, 0 failed, 0 skipped**, exit 0. Scoped `dart analyze` over all 10 Profile source files and the new test: **16 infos, 0 warnings, 0 errors**, exit 0; the infos are existing Flutter deprecations for `RadioListTile` `groupValue`/`onChanged`, `ReorderableListView.onReorder`, and `TickerMode.of`. Tracked Profile/settings source diff check: **0 findings**. |

The combined review README diff check also reports **0 findings**. No full-suite qualification was run.

Profile’s Classic/Neo isolation is explicit: only the Expressive preview context enters the new root composition; Classic and Neo retain the existing root branch. The focused family test checks that Expressive uses its tonal surfaces while Classic and Neo retain `SettingsPageScaffold`. Expressive stays preview-only; no family enum or persistence/availability changes were made.

## User review questions

### Progress

1. Does Progress now feel as expressive as Train and Workout?
2. Is Workout Report bold enough?
3. Is the chart still easy to trust and read?
4. Is Exercise Progress composition strong enough?
5. Does the detail page finally feel fully Expressive?
6. Is anything too decorative for analytics?

### Logbook

1. Does Logbook clearly belong to Tonos Expressive?
2. Is history still fast to scan?
3. Are session cards bold enough without becoming oversized?
4. Is chronology/date navigation clear?
5. Do historical detail pages feel coherent?
6. Is repeated motion appropriately restrained?

### Profile

1. Does Profile immediately feel like the same Expressive product?
2. Is the Profile identity region strong enough?
3. Does it feel personal without looking like an online/social account page?
4. Are settings/preferences grouped clearly?
5. Are associated pages sufficiently transformed from Classic?
6. Are forms/selection controls comfortable to use?
7. Is density appropriate?
8. Does dark mode feel intentionally designed?
9. Does Reduced Motion retain enough static Expressive identity?
10. Is anything still obviously inherited from Classic?
11. Is anything too visually playful for a profile/settings experience?
12. Is any Profile child page missing from this review that should clearly have been included?

The amplified Progress, Logbook, and Profile-family Expressive candidates are ready for one combined visual review. All three were allowed to depart substantially from Classic presentation while preserving Tonos's real data, workflows, local-first architecture, semantics, and the qualified Train + Active Workout reference system. Do not qualify these slices or begin Catalog until the user reviews all three together.
