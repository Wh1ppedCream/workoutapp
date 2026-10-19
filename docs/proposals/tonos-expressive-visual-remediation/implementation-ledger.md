# Tonos Expressive Visual Remediation — Implementation Ledger

**Candidate branch:** `feature/expressive-visual-polish`  
**Baseline:** `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`  
**Historical 2026-10-10 candidate fingerprint (19 changed Dart files):** `185de3f7a36a5c38c1ee41e76079295b5450e950f6c089f33b27032a683712b4`  
**Scope:** Muscle Rankings; Body Part / Muscle Mapping; the Exercise Editor's caller-scoped Catalog picker and analytics route identity; Weekly Sets Overview and linked anatomy routes; onboarding setup surfaces; Database Settings health values; and Optimized Workout Settings title hierarchy. Dashboard root was freshly captured for the audit but not changed.

This ledger records candidate implementation and validation. None of these
changes grants a new visual approval, changes an approval-ledger status, or
claims release readiness.

## Current-state follow-up — 2026-10-12

The 19-file list and validation below describe the October 10 candidate pass;
they are not a complete manifest of the current dirty tree. The live working
tree contains 56 changed or untracked Dart paths (52 tracked modifications and
4 untracked files), with current manifest fingerprint
`62e10fc222ec639839fe76836764647b3f3331835e4e92993952b9b82112bfc0`. The full
path/hash list and Git counts are in
[`current-source-snapshot.md`](current-source-snapshot.md).

Since the October 10 snapshot, the focused source follow-up changed
`lib/screens/onboarding_flow.dart` and
`test/theme/widgets/onboarding_expressive_presentation_test.dart`; the tracked
route-component ledger was also updated. Onboarding's Included Equipment
summary/chips now use Expressive planning tones, and Skip Setup uses the
route-local Expressive dialog. Workflow, persistence, selection, and routing
were preserved. No new device build or screenshots were made after those
changes.

Focused follow-up validation recorded 67 passing tests across seven files.
Onboarding scoped analysis was clean; Flow Methods reported two informational
Radio deprecation notices and no errors or warnings. No full repository test
suite or full analyzer was run after the follow-up. The latest known Pixel 7
build is the October 11 APK recorded in the snapshot and predates this source
delta. Current visual review remains pending for five B candidates: Onboarding,
Preset Generation QA, Analytics Dashboard / Weekly Sets Overview, Dashboard
root, and the plan-specific Flow Methods editor. No approval status changed.
The exact 55-archetype aggregate remains unresolved; the 24-route dossier is
15 approved / 9 pending. Technical and responsive qualification remain open.

## Original candidate scoped changes — 2026-10-10

| Area | Implementation | Scope and preserved behavior |
| --- | --- | --- |
| Profile → Training → Gym & Workout Settings → Workout Settings → Muscle Rankings | Expressive presentation now has one in-page back control, a localized singular `Muscle Rankings` hero, a shared `Rank` heading, and compact editable rank controls/rows. Long muscle names may wrap to two lines instead of truncating. Loading, error, and empty states retain Expressive back navigation. | Explicit Expressive ownership gates the treatment. Classic and Neo keep the AppBar and existing `SettingsRankingTile` path. Ranking values, drag reordering, editing, saving, persistence, and row color roles are unchanged. Semantics preserve the visible localized muscle name and rank context/value. |
| Profile → Training → Gym & Workout Settings → Workout Settings → Body Part / Muscle Mapping | Removed the duplicate Expressive AppBar title while retaining back navigation in normal, loading, and error states. Added a 12 dp separation between the body-part and linked-muscle zones. | Expressive-only spacing has a stable test key. Classic and Neo keep their AppBar. Mapping data, edit controls, save behavior, and callbacks are unchanged. |
| Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Editor → Choose exercise | Exercise Editor explicitly opts its shared exercise-picker route into the existing Expressive Catalog presentation. | The shared Catalog route and other callers are unchanged. The caller opt-in and family guard preserve Classic/Neo and unrelated Catalog callers. Selection and return behavior are unchanged. |
| Train → Overview → Focused Sets → Weekly Sets Overview | The overview focal card now uses the semantic Expressive destination surface/outline roles and asymmetric focal geometry. | Expressive-only. Anatomy, tabs, metrics, underlying data, and navigation are preserved; Classic and Neo retain the existing card. |
| First-run onboarding setup | Repeated intent, switch, choice, gym-space, and workout-plan setup surfaces now use the existing Expressive planning token roles and shapes, including selected-state foreground pairing. | Changes are limited to presentation. Onboarding state, selections, persistence, step order, callbacks, routing, and Classic/Neo presentations remain unchanged. A temporary route-only capture entrypoint was removed; it is not in the source diff. |
| Profile → Data → Database Settings | Expressive health-table values and the database path wrap to show their full contents instead of truncating. | The Expressive-only presentation retains the existing health surface and all status/data semantics. Classic and Neo continue to use their prior ellipsis behavior. A long path/value fixture covers both Expressive modes. |
| Analytics Dashboard → Body Part / Muscle / Exercise definition routes | The Analytics Dashboard explicitly carries its analytics presentation identity through body-part and muscle detail routes and linked definition tiles. | Uses the existing analytics destination theme roles without opting Analytics callers into the Catalog-only exercise detail sheet. Route data, linking, and other callers are preserved. |
| Train → Optimize → Optimized Workout Settings | Added the localized Expressive route title using the existing planning destination tokens. | Expressive-only hierarchy correction; form fields, calculations, actions, and Classic/Neo presentation remain unchanged. |

## Files in the original candidate source diff — 2026-10-10

Production source:

- `lib/screens/exercise/analytics_dashboard_screen.dart`
- `lib/screens/exercise/definitions_by_bodypart_page.dart`
- `lib/screens/exercise/definitions_by_muscle_page.dart`
- `lib/screens/exercise/optimized_workout_settings_page.dart`
- `lib/screens/onboarding_flow.dart`
- `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart`
- `lib/screens/profile/settings/database_settings_page.dart`
- `lib/screens/profile/settings/exercise_editor_screen.dart`
- `lib/screens/profile/settings/muscle_ranking_screen.dart`
- `lib/widgets/exercise_definition_info_tile.dart`

Focused tests:

- `test/theme/widgets/analytics_destination_routes_test.dart`
- `test/theme/widgets/analytics_ranking_label_contract_test.dart`
- `test/theme/widgets/analytics_ranking_label_responsive_test.dart`
- `test/theme/widgets/anatomy_routes_theme_test.dart`
- `test/theme/widgets/exercise_editor_expressive_presentation_test.dart`
- `test/theme/widgets/onboarding_expressive_presentation_test.dart`
- `test/theme/widgets/optimized_workout_settings_fields_theme_test.dart`
- `test/theme/widgets/settings_pending_routes_theme_test.dart`
- `test/theme/widgets/weekly_set_analytics_theme_test.dart`

No shared theme ownership files, approval ledgers, Classic/Neo implementations,
or unrelated production routes are in this candidate source diff.

## Focused validation — October 10 candidate

- Final focused combined run: **63 passed, 0 failed** across five test files:
  analytics destination routes, ranking contracts, ranking responsive cases,
  pending settings routes, and Weekly Sets analytics. Separate focused runs
  also covered onboarding, Database Settings, Exercise Editor presentation,
  anatomy route theme ownership, and Optimized Workout Settings; do not add
  overlapping run totals as if they were unique tests.
- Scoped `dart analyze` over 11 selected changed Dart files completed without
  errors or warnings and emitted four informational deprecation notices (two
  `onReorder`, two `hasFlag`). Full-repository Flutter analysis is recorded
  below.
- A format check over all 19 changed Dart files returned exit 1 because four
  existing long-form files would be broadly reformatted:
  `definitions_by_bodypart_page.dart`, `definitions_by_muscle_page.dart`,
  `exercise_definition_info_tile.dart`, and
  `settings_pending_routes_theme_test.dart`. These were left narrowly edited;
  the other 15 passed without formatter changes.
- `git diff --check`: passed; Git printed working-tree line-ending conversion
  notices for some existing test files.
- Theme-style inventory `--check`: **exit code 0**, with 0 unassigned
  candidates. Its report still shows review-queue coverage gaps (16 pending
  candidates without a review queue and 2,110 candidates outside configured
  queues); the command's check mode does not fail on those coverage totals.
- Theme-style ratchet enforcement: **exit code 64**, with 22 fingerprint
  mismatches: 15 in `lib/widgets/tonos_bottom_navigation_bar.dart` and 7 in
  `lib/widgets/exercise_definition_info_tile.dart`. No ratchet baseline was
  changed. The latter file has an intentional route-identity update in this
  candidate; bottom navigation is outside the candidate source diff.

## Full-suite and remaining qualification — October 10 candidate

- The uninterrupted `flutter test --no-pub` run completed with **1,809 passed,
  20 failed, 0 skipped, exit code 1**. The failures comprise 17
  style-inventory/ownership contract failures, two Flow Editor golden
  failures, and one Profile Analytics dropdown interaction assertion
  (expected one `Scrollable`, found five in its Expressive dark case). No
  pre-remediation full run was made, so these failures are not labeled
  pre-existing or attributed to this candidate without a baseline comparison.
  The full suite is not green.
- Full `flutter analyze` completed with **0 errors, 0 warnings, and 79
  informational deprecation notices**, exiting 1 because info diagnostics are
  present.
- Theme-style inventory `--check`: **exit code 0**, 0 unassigned candidates;
  its report still shows 16 candidates without review queues and 2,110
  candidates outside configured queues (not enforced in check mode).
- Candidate Pixel 7 build/install and fresh local captures are recorded in
  [`current-source-snapshot.md`](current-source-snapshot.md) and
  [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).
  Capture media remains local. Preview database, WAL, SHM, and preferences
  were restored and device-hash-verified against the pre-capture backup; the
  preview process is stopped.
- User visual review is pending for the changed routes. No candidate screen is
  newly approved or frozen by this ledger.
- Device captures cover the Pixel 7 normal viewport only. Comprehensive
  narrow/wide/landscape and systematic 1×, 1.15×, 1.5×, and 2× responsive
  qualification remains open.
- Visual approval, responsive/accessibility qualification, analyzer/test
  status, theme inventory/ratchet status, and release readiness remain
  separate. Release readiness is not claimed.
