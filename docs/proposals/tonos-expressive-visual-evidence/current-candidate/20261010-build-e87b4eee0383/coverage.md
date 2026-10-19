# Capture coverage — 2026-10-10 candidate

## Status after evidence refresh

The current-source debug APK built successfully and was installed on Pixel 7 `28021FDH200228` as `com.tonos.expressivepreview`. Current count is **92 verified screenshots** (47 Expressive light, 45 Expressive dark), plus one excluded Android-lockscreen probe and one excluded redundant Diagnostics & Privacy checkpoint. The set includes Train/planning, Catalog, user-configured Dashboard, Profile/Analytics, Logbook, and Progress references. The isolated preview data snapshot has been restored and the app is stopped. This is enough to begin the next visual-readiness audit, but it is not complete route-state or responsive qualification.

The inventory below follows the B rows of `tonos-expressive-expansion-20261005/route-component-ledger.md` as capture candidates. The crosswalk marks the Catalog Details sheet boundary as disputed; retain it as a separately named interaction state in capture records without silently changing the 55-archetype totals.

## Expressive candidate routes

| Candidate | Navigation path | Light | Dark | Meaningful state coverage | Current status |
|---|---|---:|---:|---|---|
| Catalog root | Bottom navigation → Catalog | Captured | Captured | Root paired; lower scroll captured in light only | Partial |
| Exercise browser | Catalog → Exercise Catalog | Captured | Captured | Default list paired; light bench search, selected filter, no-results, and lower scroll captured; dark bench search and selected filter captured; media fallback and dark no-results/lower-scroll remain | Partial |
| Muscle Filter / Focus Library | Catalog → Target Anatomy → Bodyparts or Muscles; also browser filter | Both tabs captured | Both tabs captured | Both Bodyparts/Muscles tabs paired; search/selection and separate filter-route details remain | Partial |
| Body-part definitions | Focus Library → Bodyparts → select a body part | Captured | Captured | Chest header and linked content; lower scroll and alternate long-label/media states remain | Partial |
| Muscle definitions | Focus Library → Muscles → select a muscle | Captured | Captured | Pectoralis Major paired; dark lower-scroll state captured; further alternate states remain | Partial |
| Catalog Exercise Details sheet | Open exercise information from Catalog result/definition | Captured | Captured | Details paired; Metrics and Records captured in both modes; light Form Guide expanded; media fallback, remaining lower/detail states, and caller parity remain | Partial |
| Measurements & Trends Settings | Profile → Training → Progress Settings | Captured | Captured | Main Measurement Library entry; lower/return states remain | Partial |
| Measured Items (Profile caller) | Profile → Training → Progress Settings → Measurement Library | Captured | Captured | Existing Weight plus empty additional metric cards; no edit dialog or log action | Partial |
| Database Settings | Profile → Data → Database Settings | Captured | Captured | Paired default status pages; lower and cancel-only confirmation states remain; no transfer/maintenance action | Partial |
| Diagnostics & Privacy | Profile → Data → Diagnostics & Privacy | Captured | Captured | Paired default information sections; lower content and consent/report/clear actions remain untouched | Partial |
| Muscle Rankings | Profile → Training → Gym & Workout Settings → Workout Settings → Training Bias → Muscle Rankings | Captured | Captured | Paired default order only; no reorder; safe cancelable unsaved edit remains | Partial |
| Body-part/Muscle Mapping | Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Definitions → Body Part / Muscle Mapping | Captured | Captured | Paired default Biceps selection and linked items; alternate selection/edit states remain | Partial |
| Exercise Set Allocation | Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Definitions → Exercise Set Allocation | Captured | Captured | Paired Muscle credit and Body-part credit tabs; no values edited | Partial |
| Exercise Editor | Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Definitions → Exercise Editor | Captured | Captured | Paired landing and shared picker; editor form and persistence/dialog states remain, no create/edit action | Partial |
| Plan Management | Train → Plans → Manage plans action | Captured | Captured | Default active/archived groups only; empty, delete/restore dialogs, and return states remain | Partial |
| Premade Plans | Train → Plans → scroll to Premade Plans → Browse Premade Plans | Captured | Captured | Loaded default categories; duration/equipment, expansion/selection, empty/load failure, onboarding return, and persistence states remain | Partial |
| Preset Detail | Train → Overview → Active Plans → choose an existing plan | Captured | Captured | Existing plan summary, Focused Sets, and expanded exercises; edit/swap/save-discard dialogs, session entry, and route-return states remain | Partial |
| Optimized Workout Settings | Train → Overview → Optimize → gear | Captured | Captured | Default values only; validation, keyboard, persistence, motion, and expanded states remain | Partial |
| Gym Profile | Train → top-right gym/profile avatar → current profile → Edit | Captured | Captured | Existing profile and expanded Basics section; search, equipment edits, save/cancel, error, keyboard, and onboarding variants remain | Partial |

## Fresh references for previously approved screens

These captures refresh current-build evidence only; they do not change or reopen visual approval status. They show the explicitly selected Expressive preview mode and have matching route/state hierarchy dumps.

| Approved screen | Light evidence | Dark evidence | Captured state and boundary |
|---|---|---|---|
| Logbook root / calendar | `logbook/logbook-root-light.png`; `logbook/logbook-root-populated-day-light.png` | `logbook/logbook-root-empty-day-dark.png`; `logbook/logbook-root-populated-day-dark.png` | Empty Oct 10 and populated Oct 5 selected-day states. This does not capture every M / 3M / Y / 4Y selector state. |
| Full History / All Sessions | `logbook/full-history-light.png` | `logbook/full-history-dark.png` | Grouped historical session list. |
| Session Detail / Past Workout | `logbook/session-detail-light.png` | `logbook/session-detail-dark.png` | Read-only Oct 8 workout detail only; edit mode and Save as Plan / Delete Session dialogs were not recaptured. |
| Progress root | `progress/progress-root-light-top.png`; `progress/progress-root-light-scrolled.png` | `progress/progress-root-dark-top.png`; `progress/progress-root-dark-scrolled.png` | Workout Report set to All at top, plus scrolled Exercise Progress / Health Trends. Exercise Progress 1RM detail and Measurement Trend detail remain distinct routes and were not captured here. |

## Other ledger families

| Family | Current capture treatment |
|---|---|
| A — approved references | Train Overview and Train → Plans have fresh light/dark references, including Active Plans and lower Plans content. Gym & Workout Settings and Workout Settings have paired references. Logbook root, Full History, read-only Session Detail, and Progress root now have fresh references as listed above. Other approved screens are not recaptured. Existing approvals remain untouched. |
| C — partially adapted / grouped rows | The visible ledger table does not fully enumerate its reported C10. Resolve route membership from the source crosswalk before treating this as a complete capture queue. |
| D — generic routes | Dashboard has current light/dark references in `dashboard/`, plus one 2× dark stress image showing clipping/crowding at the Data & records / Weekly Overview boundary; this is a qualification gap, not a pass. Six `analytics/weekly-sets-*` images cover the separate `AnalyticsDashboardScreen` destination reached from Train or Dashboard → Weekly Overview → Focused Sets: Bodyparts/Muscles initial states in both themes and lower Bodyparts scroll in both themes. They do not show the Dashboard page/card itself. Preset Generation QA remains uncaptured. The ledger lists all three but reports D1; this evidence pass does not reconcile the classification or change approval status. |
| E — no production caller | Do not force navigation to these routes. The table rows conflict with reported E0; keep the discrepancy open. |
| F — placeholder/deferred | Deferred — no current visual capture required. Do not enable or seed these routes. |
| G/H — protected or intentionally Classic/Neo | No candidate capture or redesign implied. Preserve the stated boundary. |

## Responsive evidence

No simulated viewport captures have been produced. The Pixel 7 provides approximately 411×914 logical dp at the current density; it does not prove 320 dp, tablet, or landscape behavior. There is no route-wide 1× / 1.15× / 1.5× / 2× matrix. One Dashboard image uses 2× preview text scaling and visibly records clipping/crowding as an unresolved qualification gap, not a pass.

The current screenshot set has a thin lime-green perimeter visible on the newly added captures. Its source is unconfirmed; image files remain unaltered and the route/state was corroborated with UI hierarchy dumps. Treat it as an unresolved capture artifact, not app styling.

## Completion criterion

Do not mark a candidate complete until its light and dark default views plus its route-specific meaningful states are verified in `manifest.csv`. Current meaningful gaps include Catalog media fallback and dark lower/detail states; planning validation, keyboard, persistence, dialogs, and edit flows; Profile child-page dialogs and edit/error states; unrepresented Logbook period-selector variants and historical edit/dialog states; Progress detail routes; and responsive widths/scales. Record genuinely unavailable states with the exact reason rather than substituting old screenshots. The current 92-capture set is ready to support the next visual audit, not to close those gaps or qualify release readiness.
