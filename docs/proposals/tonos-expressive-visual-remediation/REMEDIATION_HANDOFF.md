# Tonos Expressive Visual Remediation — Closeout Handoff

## Current-state supplement — 2026-10-12

This supplement supersedes the October 10 “current” wording in the dated
closeout below. The October 10 and October 11 evidence remains historical for
the builds and source states recorded in those documents.

- **Git:** branch `feature/expressive-visual-polish`, HEAD
  `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`; no upstream. The verified
  `origin/feature/classic-m3e` baseline still points to this SHA. Current status
  is 61 tracked modifications, 2,194 untracked paths, and 0 staged. Nothing was
  staged, committed, pushed, reset, cleaned, or stashed for this update.
- **Source:** 56 current changed/untracked Dart paths (52 tracked and 4
  untracked); fingerprint
  `62e10fc222ec639839fe76836764647b3f3331835e4e92993952b9b82112bfc0`.
  Since the October 10 snapshot, the source/test delta is the Onboarding
  Expressive refinement; see the current manifest for exact file hashes.
- **Implementation:** Onboarding's Included Equipment summary/chips now use
  planning tones and Skip Setup uses its Expressive dialog. No workflow,
  selection, persistence, or routing changes were intended.
- **Validation:** latest focused follow-up recorded 67 passing tests across
  seven files. Onboarding scoped analysis was clean; Flow Methods had two
  informational Radio deprecation notices and no errors/warnings. No full-suite
  or full analyzer run followed the change.
- **Visual evidence:** no build or screenshots were made after the Onboarding
  refinement. The last known Pixel 7 APK is the October 11 build,
  `91AFB3AE4E7171D2F2A7E1E144756A6C75C88B89B9161D66EF7E41C39345DCB3`, for
  `com.tonos.expressivepreview` on `28021FDH200228`; it predates the latest
  source. The October 10 capture set is also historical. See
  [`current-source-snapshot.md`](current-source-snapshot.md).
- **Preview data:** isolated database/preferences were restored and hash-
  verified after the October 11 audit. They were not rechecked October 12;
  production data was not touched.
- **Review:** the current five B targets, in order, are Onboarding; Preset
  Generation QA; Analytics Dashboard / Weekly Sets Overview; Dashboard root;
  plan-specific Flow Methods editor. The 55-archetype total remains
  unreconciled; the separate 24-route dossier remains 15 approved / 9 pending.
  No approval classifications changed. Technical, responsive, accessibility,
  style inventory/ratchet, and release qualification are separate and remain
  incomplete.

The numbered closeout that follows is the October 10 handoff as originally
recorded. Its “next ten” list is historical; use the current five-item queue in
[`visual-review-queue.md`](visual-review-queue.md).

**Recorded:** 2026-10-10  
**Purpose:** Consolidate the current local candidate for user review. This is
not a completion claim for the larger visual-remediation project, not visual
approval, and not release qualification.

## 1. Git checkpoint and safety

- Pushed preservation baseline: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`
  (`checkpoint: preserve Tonos Expressive visual review and audit baseline`).
- The remote was checked with `git ls-remote`: `origin/feature/classic-m3e`
  still points to that exact SHA. The baseline remains recoverable.
- Current local branch: `feature/expressive-visual-polish`.
- Current HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`; the branch has no
  upstream configured. Current candidate changes are not committed or pushed.
- The index is empty. The working tree has **19 modified tracked Dart files**
  (10 production, 9 tests) plus numerous pre-existing/unrelated untracked
  artifacts. They were preserved. No reset, clean, stash, staging, commit, or
  remediation push was performed. The malformed local Codex ref was untouched.
- Candidate input fingerprint (the 19 changed Dart paths and contents):
  `185de3f7a36a5c38c1ee41e76079295b5450e950f6c089f33b27032a683712b4`.
- The new closeout docs and evidence index are local/untracked along with the
  surrounding proposal material; screenshot media is intentionally local.

## 2. Implementation inventory

All changes are Expressive-scoped. The candidate does not change business
logic, persisted data meanings, or Classic/Neo presentation. No shared theme
ownership files or approval classifications changed.

| Production file | Screen / issue | Change |
| --- | --- | --- |
| `lib/screens/profile/settings/muscle_ranking_screen.dart` | Profile → Training → Gym & Workout Settings → Workout Settings → Training Bias → Muscle Rankings had duplicated/incorrect title hierarchy, per-row Rank labels, overly tall rows, and long-label clipping risk. | Expressive-only single in-page title, singular localized name, shared Rank heading, compact rank controls/rows, long-name wrapping, and Expressive loading/error/empty back navigation. Ranking, drag, edit, save, and persistence behavior stay intact. |
| `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart` | Mapping had duplicate Expressive title and insufficient separation between body-part and linked-muscle zones. | Removed only the duplicate Expressive app-bar title, retained back behavior in normal/loading/error states, and added 12 dp zone separation. Mapping content and save callbacks are unchanged. |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | Exercise Editor's picker did not use the established Expressive Catalog presentation. | This caller opts into the existing Catalog presentation. Other picker callers and Catalog routes are not opted in by this change. |
| `lib/screens/exercise/analytics_dashboard_screen.dart` | Analytics navigation could lose its destination/theme identity in anatomy drill-downs. | Passes the analytics presentation identity to linked body-part/muscle routes. |
| `lib/screens/exercise/definitions_by_bodypart_page.dart` | Body-part detail needed to honor its originating Analytics destination. | Consumes the explicit Analytics identity while preserving other callers and route data. |
| `lib/screens/exercise/definitions_by_muscle_page.dart` | Muscle detail needed to honor its originating Analytics destination. | Consumes the explicit Analytics identity while preserving other callers and route data. |
| `lib/widgets/exercise_definition_info_tile.dart` | Linked definition tiles needed to carry the correct Analytics route identity; the shared tile also appears in other contexts. | Carries the explicit destination identity for the Analytics caller; it does not make Analytics use the Catalog-only detail sheet. This changed file has 7 ratchet fingerprint mismatches. |
| `lib/screens/onboarding_flow.dart` | Repeated onboarding setup surfaces retained more Classic-like treatment than the approved Expressive reference. | Uses existing Expressive planning token roles/shapes and selected foreground pairing across setup surfaces. Step order, selections, callbacks, persistence, and navigation remain the same. Temporary capture routing was removed from `main.dart`; `main.dart` has no diff. |
| `lib/screens/profile/settings/database_settings_page.dart` | Long health values and database path truncated in the Expressive view. | Expressive-only wrapping keeps the complete values/path visible; Classic/Neo keep their prior ellipsis behavior. |
| `lib/screens/exercise/optimized_workout_settings_page.dart` | Expressive Optimize route lacked its destination title hierarchy. | Adds the localized page title using existing planning tokens; fields, calculations, and actions are unchanged. |

The candidate source diff is 19 Dart files total: the 10 production files in
the table and these 9 focused test files:

- `test/theme/widgets/analytics_destination_routes_test.dart`
- `test/theme/widgets/analytics_ranking_label_contract_test.dart`
- `test/theme/widgets/analytics_ranking_label_responsive_test.dart`
- `test/theme/widgets/anatomy_routes_theme_test.dart`
- `test/theme/widgets/exercise_editor_expressive_presentation_test.dart`
- `test/theme/widgets/onboarding_expressive_presentation_test.dart`
- `test/theme/widgets/optimized_workout_settings_fields_theme_test.dart`
- `test/theme/widgets/settings_pending_routes_theme_test.dart`
- `test/theme/widgets/weekly_set_analytics_theme_test.dart`

No ActivePlanStore or DiagnosticsService constructor change is part of this
candidate. The changed files do not include a DropdownButtonFormField
`value`→`initialValue` migration. Current Flutter analysis reports zero errors,
but these earlier suspected API/migration questions were not separately
audited in this closeout and should not be described as fixes from this pass.

## 3. Tests and technical validation

No validation was rerun during this closeout; values below are from the
completed candidate runs recorded in
[`implementation-ledger.md`](implementation-ledger.md). Logs remain in
`%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\`.

- **Final focused combined tests:** 63 passed, 0 failed, across five files:
  Analytics destination routes, ranking label contract, ranking responsive
  cases, pending settings routes, and Weekly Sets analytics. Additional
  focused runs covered onboarding, Database Settings, Exercise Editor,
  anatomy route ownership, and Optimized Workout Settings. Their overlapping
  counts are not summed as unique tests.
- **Full `flutter test --no-pub`:** 1,809 passed, 20 failed, 0 skipped; exit
  code 1. Failures: 17 theme-style/inventory ownership contract cases, two
  light/dark Flow Editor panel goldens, and one Profile Analytics dropdown
  interaction test (`Scrollable` finder expected exactly one but found five
  in its Expressive dark case). There was no pre-remediation full run, so the
  failures are not attributed to this candidate or labeled pre-existing.
  Log: `%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\full_flutter_test_final_current_20261010.log`.
- **Full `flutter analyze`:** 0 errors, 0 warnings, 79 info-only deprecation
  diagnostics; exit code 1 because informational diagnostics are present.
  Log: `%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\full_flutter_analyze_final_current_20261010.log`.
- **Scoped `dart analyze`:** 11 selected changed Dart files; 0 errors, 0
  warnings, 4 info-only deprecation notices (two `onReorder`, two `hasFlag`).
- **Formatter check:** checked all 19 changed Dart files; exit code 1 because
  four long-form files would be broadly reformatted:
  `definitions_by_bodypart_page.dart`, `definitions_by_muscle_page.dart`,
  `exercise_definition_info_tile.dart`, and
  `settings_pending_routes_theme_test.dart`. The broad formatting was not
  applied; the other 15 did not require formatting changes.
- **`git diff --check`:** final closeout run passed (exit code 0) on the tracked
  candidate diff; Git printed only line-ending conversion notices for
  existing test files. The newly created handoff/evidence files are untracked,
  so their relative links and screenshot manifest were checked separately.
- **Theme-style inventory `--check`:** exit code 0, zero unassigned
  candidates. The report still notes 16 pending candidates without review
  queues and 2,110 candidates outside configured queues; those are coverage
  gaps not enforced by check mode.
- **Style ratchet enforcement:** exit code 64, 22 fingerprint mismatches: 15
  in unchanged `lib/widgets/tonos_bottom_navigation_bar.dart` and 7 in
  changed `lib/widgets/exercise_definition_info_tile.dart`. No ratchet
  baseline was changed. Log:
  `%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\theme_style_ratchet_final_current_20261010.log`.

The full suite, analyzer, formatter, and ratchet are **not green**. Passing
focused tests do not establish full technical or release qualification.

## 4. Visual audit: changed, unchanged, and open

### Remediated candidate screens

- Muscle Rankings: title/Rank hierarchy, compact controls, and long-label
  wrapping.
- Body Part / Muscle Mapping: single Expressive title and separated editing
  zones.
- Exercise Editor and its caller-specific picker: Expressive Catalog
  presentation for this caller only.
- Weekly Sets Overview and its body-part/muscle detail destinations: stronger
  Expressive focal surface and preserved Analytics identity.
- First-run Onboarding: Expressive planning setup surfaces.
- Database Settings: full health/path values visible in Expressive.
- Optimized Workout Settings: localized Expressive destination title.

All are candidates only. No user visual approvals were added.

### Reviewed or protected but unchanged by this batch

- Approved Train Overview/Plans and shell, Active Workout, Progress routes,
  Logbook routes, and individually approved Profile pages were not redesigned.
- Catalog root/browser and other shared picker callers were not generalized
  into the Exercise Editor picker treatment.
- Dashboard root was inspected in the route/source audit and has earlier
  candidate captures, but is not in the latest 2e4a2bd4 screenshot set and
  was not changed. Its source-vs-route-ledger classification mismatch remains
  unresolved.
- Other planning, Catalog, Progress, Logbook, and Profile child routes were
  not modified in this candidate. The route ledger remains the authority for
  their approval status.

### Still needing attention

- Candidate visual review in both modes for the changed routes listed above.
- Database transfer/permission/error/confirmation states; onboarding full
  route/state matching and Skip dialog; editor picker search/filter/select and
  return; mapping changed values/save; ranking drag/edit/save/keyboard; Optimize
  validation, keyboard, and persistence.
- Remaining catalog, planning, settings, and shared-dialog routes from the
  queue. Dashboard/Analytics route-ledger discrepancies need separate
  inventory reconciliation; no classifications were changed here.
- The 55-archetype ledger has known count-boundary inconsistencies documented
  in the visual audit. Do not infer a corrected total from this handoff.

## 5. Pixel 7 evidence and provenance

- Latest current-candidate evidence folder:
  [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).
- It has 20 primary unaltered screenshots, with exact filename, route, mode,
  and state in `manifest.csv`: Muscle Rankings, Mapping, Exercise Editor and
  its picker, Weekly Sets Overview/body-part/muscle detail, Database Settings
  initial/scrolled health-path state, and default Optimized Workout Settings
  in light/dark. One additional Volume Boundaries dark navigation probe is
  retained but marked diagnostic, not primary evidence.
- Device: Pixel 7 `28021FDH200228`; package: `com.tonos.expressivepreview`;
  database: `tonos_expressive_preview.db`. The standard preview entrypoint was
  `lib/expressive_preview_main.dart`. Flutter 3.47.5 and bundled Dart 3.13.4.
- APK: `E:\projects\env_test\build\app\outputs\flutter-apk\app-debug.apk`,
  233,544,099 bytes, SHA-256
  `2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7`.
  Installation succeeded. The earlier build using the wrong `lib/main.dart`
  entrypoint is isolated and labeled diagnostic-only; it is excluded from
  current evidence.
- Preview DB, WAL, SHM, and preferences were restored byte-for-byte and
  device-hash-verified against the saved pre-capture copies. The preview
  process is stopped and was not relaunched after restoration. Normal Tonos
  data was not touched.
- Onboarding images are from the separate bootstrap build and remain
  identifiable as such; no onboarding screenshot came from this exact APK.
  The latest set has no hierarchy XML. No screenshot set covers every
  interactive/error/keyboard state.
- The images remain local and untracked by explicit user preference.

## 6. Design consistency and protected boundaries

The changes reuse existing Expressive destination/planning semantics and
explicit family ownership. They keep success/data meaning and route behavior
intact. No new theme token, package, or broad checkbox/control redesign was
introduced. Classic and Neo branches are preserved in the relevant scoped
widgets. Previously approved screens were not deliberately restyled, and no
visual approval ledger or ratchet baseline was changed.

## 7. Responsive findings and limitations

- Physical evidence covers only the Pixel 7 normal viewport at approximately
  411×914 dp.
- The focused ranking tests exercise 393 dp and 320 dp with 1×/1.5× text and a
  long muscle label. Weekly Sets tests include 320×900 dp at 2× plus other
  widget sizes. These are targeted widget scenarios, not a route-wide matrix.
- Database health values and long path now wrap in both Expressive modes; the
  scrolled captures show the full path. Mapping's section gap and ranking
  labels were inspected at the states described above.
- No current-source device capture exists for 320 dp, tablet/wide, landscape,
  or a systematic 1×/1.15×/1.5×/2× text-scale matrix. Keyboard, drag, save,
  validation, error, and full persistence states are not comprehensively
  qualified. See [`responsive-validation.md`](responsive-validation.md).

## 8. Outstanding work and priority

- **P0 — confirmed critical product defect:** none identified by this
  closeout. This is not a claim that the full application has no critical
  defects.
- **P1 — technical qualification:** resolve/triage the 20 full-suite failures
  with a baseline comparison; investigate the Profile Analytics dropdown
  finder assertion and the two Flow Editor goldens; reconcile the 17 style
  ownership failures; resolve the 22 ratchet mismatches without blindly
  updating baselines; decide whether the 79 analyzer infos and four format
  mismatches need cleanup. The existing checkpoint is safe; the candidate
  should not be treated as release-qualified.
- **P2 — user visual review:** inspect the next ten screens/states below.
  Keep every route independent and preserve existing approval boundaries.
- **P3 — breadth/coverage:** complete the responsive, accessibility, keyboard,
  dialog, and state matrices; reconcile route-ledger/source mismatches and
  style-inventory coverage gaps; review remaining unmodified routes in the
  existing queue. Do not bundle these with this closeout.

## 9. Historical next-ten user visual-review targets — 2026-10-10

Review in light and dark unless noted. These are review suggestions, not
approval changes. Use the latest evidence folder for already captured states;
the missing-state notes below describe what a screenshot should show.

1. **Muscle Rankings** — Profile → Training → Gym & Workout Settings → Workout
   Settings → Training Bias → Muscle Rankings. Inspect the single title,
   shared Rank heading, long label, and rank fields; additionally inspect
   edit/drag/save behavior. Current default light/dark captures are present.
2. **Body Part / Muscle Mapping** — Profile → Training → Gym & Workout Settings
   → Workout Settings → Exercise Definitions → Body Part / Muscle Mapping.
   Inspect read-only and edit states, selected body part, linked muscles, and
   save/return. Current read-only light/dark captures are present; edit captures
   exist in the earlier 79e1ad79 folder, not this latest set.
3. **Exercise Editor and its picker** — Profile → Training → Gym & Workout
   Settings → Workout Settings → Exercise Definitions → Exercise Editor →
   Choose exercise. Inspect the landing and picker in light/dark, then search,
   filter, choose an exercise, and return. Latest default captures are present;
   interaction states are not.
4. **Weekly Sets Overview** — Train → Overview → Focused Sets card. Inspect
   its focal anatomy/metrics composition, legibility, tabs, and surrounding
   page in both modes. Latest overview light/dark captures are present.
5. **Weekly Sets body-part detail** — from Weekly Sets Overview, open a body
   part. Inspect populated metrics, detail hierarchy, and back navigation in
   light/dark. Latest detail captures are present.
6. **Weekly Sets muscle detail** — from Weekly Sets Overview, open a muscle.
   Inspect its focal surface, metric data, linked route behavior, and back
   navigation in light/dark. Latest detail captures are present.
7. **Database Settings** — Profile → Data → Database Settings. Inspect the
   initial and scrolled health/path views in light/dark; separately review
   permission, import/export, progress, confirmation, and failure states.
   Latest initial and scrolled screenshots are present; action states are not.
8. **Optimized Workout Settings** — Train → Optimize. Inspect the localized
   title and default form in light/dark, then validation, keyboard, save/start,
   and return behavior. Latest screenshots cover only the default form.
9. **Onboarding** — First-run onboarding gate; use Profile → UI & Appearance
   → Replay Onboarding if available without resetting user data. Review all
   setup steps and Skip confirmation in matched light/dark states. Existing
   bootstrap evidence is from a separate APK and is not state-matched; do not
   treat it as latest-build proof.
10. **Exercise Set Allocation** — Profile → Training → Gym & Workout Settings
    → Workout Settings → Exercise Definitions → Exercise Set Allocation.
    This is an unmodified pending route. Inspect tabs, editing, validation,
    save, and persistence in light/dark; no current evidence is linked.

These ten targets do not exhaust the route queue. Catalog, planning, other
Profile/settings children, shared dialogs, and placeholder/deferred routes
remain independently classified in `visual-review-queue.md` and the
authoritative route ledger.

## Closeout boundary

This handoff consolidates the work done so far. It does not authorize more
implementation, change any approval, qualify the release, or publish evidence.
Preserve the local candidate and wait for the user's next instruction.
