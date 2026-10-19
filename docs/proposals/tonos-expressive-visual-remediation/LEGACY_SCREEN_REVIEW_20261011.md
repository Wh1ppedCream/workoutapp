# Tonos Expressive Legacy Screen Review — 2026-10-11

> **Currentness note — 2026-10-12:** This remains a point-in-time October 11
> review. The October 12 follow-up refined Expressive Onboarding (Included
> Equipment surfaces and Skip Setup dialog), so this report's source and
> “no production source changes” statements are historical. The current
> manifest, validation, evidence boundary, and review queue are recorded in
> [`current-source-snapshot.md`](current-source-snapshot.md),
> [`visual-readiness-audit.md`](visual-readiness-audit.md), and
> [`visual-review-queue.md`](visual-review-queue.md). No post-refinement device
> build or screenshot exists.

## Outcome

This pass completed a visual review of the reachable, unapproved candidates that could be assessed safely from the existing local evidence and current source. **No production source changes were justified.** The eligible Dashboard candidate already has a distinct plum/peach Expressive composition and showed no confirmed P1/P2 visual defect. The other reviewed candidate families had recent dedicated work or source changes and were therefore review-only under the task's recency/protection rules. No approval classifications were changed.

This is not full visual, responsive, accessibility, or release qualification. No fresh APK was built, installed, or captured in this pass; no preview data was opened or changed.

## Git and worktree checkpoint

- Branch: `feature/expressive-visual-polish`
- HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`
- At review start, `git status --short` showed 40 tracked change entries, 249 untracked entries (Git's default directory-collapsed display), and no staged paths. These belong to the already-dirty user worktree.
- This pass changed no application source, test, localization, approval-ledger, or evidence-media file. It adds only this report under the already-untracked visual-remediation documentation tree.
- No stage, commit, push, reset, clean, stash, branch switch, device operation, or preview database/preference operation occurred.
- `git diff --check` passed after this report was added. Git printed existing LF-to-CRLF working-copy notices for dirty files; no whitespace error was reported.

## A. Review inventory and eligibility

The route ledger and its implementation-pass notes were treated as discovery aids. Eligibility was checked against actual source ownership, production callers, recent change history, and existing screenshots. The 55-archetype approval totals and all route classifications were left untouched.

### Reviewed and unchanged

| Screen | Navigation | Source owner | Review and disposition |
| --- | --- | --- | --- |
| Dashboard root | Configurable Dashboard tab (currently default-off); enable through Profile → UI & Appearance → Edit Bottom Tabs | `lib/screens/dashboard_page.dart`, `lib/widgets/dashboard_sections.dart` | Reviewed light/dark portrait evidence. Source explicitly installs the Dashboard Expressive destination theme. The plum focal header, peach Quick Actions, and distinct plan surfaces form a coherent composition; no safe P1/P2 change was identified. Leave pending user review. Lower scroll content and the edit/reorder state were not visually covered in this pass. |
| Plan Management | Train → Plans → manage plans; also Dashboard plan action | `lib/screens/exercise/plan_management_page.dart` | Active/archived grouping and actions reviewed in light/dark. Long plan names wrap in current source; the historical truncation note is not a current source defect. Recent source work in checkpoint `9ac12f9` makes this review-only. Empty, delete/restore, and dialog states remain unreviewed. |
| Premade Plans | Train → Plans → premade plans; also Dashboard/onboarding | `lib/screens/exercise/premade_plans_page.dart` | Duration, equipment filtering, categories, and expanded plan content reviewed in light/dark. No confirmed visual defect. Recent source work in `9ac12f9` makes this review-only. The saved README and a later audit disagree about whether one dark capture was settled; the visible capture appears populated, so that state is retained as an evidence caveat. |
| Preset Detail | Train → Plans → select a plan | `lib/screens/exercise/preset_detail_screen.dart` | Light/dark composition, plan summary, exercise cards, and start action reviewed using the available card-parity/current-candidate evidence. Recent substantial source work in `9ac12f9` and the separate card-parity refinement make this route protected from another cosmetic pass. Dialog, swap, keyboard, and return states remain incomplete. |
| Gym Profile | Profile → Training → Gym & Workout Settings → profile avatar/profile selection; also Train setup | `lib/screens/exercise/gym_profile_screen.dart` | Selected-profile editor, equipment filter/groups, and save/cancel composition reviewed in light/dark. No confirmed defect; recent source work in `9ac12f9` makes this review-only. Error, unsaved-exit dialog, keyboard, and onboarding variants remain unreviewed. |
| Catalog root | Catalog tab | `lib/screens/catalog_page.dart` | Current candidate root and scrolled light/dark evidence reviewed. Plum focal area, blue exercise content, and mint anatomy grouping remain coherent. The Catalog family had dedicated October 5–6 refinements; no new edit was made. Some older root captures have stale/unverifiable source hashes; only the dated evidence folder identified below was considered. |
| Exercise browser | Catalog → Exercises; also Train/picker callers | `lib/screens/exercise/exercise_catalog_page.dart` | Search, browser rows, scrolled content, filter selection, and filter dialog reviewed across available light/dark captures. Dedicated October 6 work and responsive tests make this route review-only. A no-results image with a typed search query displays “No exercises match filters”; this is a minor copy mismatch worth correcting in a future Catalog-specific pass, not in this recent-work-protected task. |
| Muscle filter / Exercise Focus Library | Catalog → filter/focus library; also Train and picker callers | `lib/screens/exercise/muscle_filter_page.dart` | Body-part and muscle focus states plus filter selection reviewed. Recent Catalog refinement and shared callers make it review-only; no safe new correction was identified. Long-localized-label and caller variants still need qualification. |
| Body-part definitions | Catalog → Anatomy → body part; also Muscle Filter/Analytics Dashboard | `lib/screens/exercise/definitions_by_bodypart_page.dart` | Paired light/dark candidate evidence reviewed. Current file has recent dirty source work; no further modification made. Media fallback and long-label/device states remain qualification gaps. |
| Muscle definitions | Catalog → Anatomy → muscle; also body-part definitions/Analytics Dashboard | `lib/screens/exercise/definitions_by_muscle_page.dart` | Paired light/dark and scrolled evidence reviewed. Current file has recent dirty source work; no further modification made. Dedicated motion and all long-label states remain unverified. |
| Catalog Exercise Details sheet | Catalog result/definition → exercise details | `lib/widgets/exercise_detail_sheet.dart` | Metrics, Records, and Form Guide captures reviewed in light/dark where present. The October 6 sheet redesign is recent; no further edit was made. Media lifecycle and all non-Catalog callers remain unqualified. |
| Measurements & Trends Settings | Profile → Progress Settings → settings/manage measurements | `lib/screens/profile/settings/measurements_trends_settings_page.dart` | Current candidate light/dark page reviewed. October 10 source work makes it ineligible for another polish pass here. Edit/return/delete and dialog states remain separate from the approved Progress root. |
| Measured Items (Profile caller) | Profile → Progress Settings → measured items | `lib/screens/nutrition/measured_items_page.dart` | Profile-scoped light/dark evidence reviewed. October 10 source work makes it review-only. Nutrition caller, empty/editor dialogs, keyboard, and responsive device states remain separate gaps. |
| Database Settings | Profile → Data → Database Settings | `lib/screens/profile/settings/database_settings_page.dart` | Recent source work in the current dirty tree protects this route from modification. Existing light/dark evidence was reviewed; import/export permission, busy/error, confirmation, and keyboard states remain unverified. |
| Diagnostics & Privacy | Profile → Data → Diagnostics & Privacy | `lib/screens/profile/settings/diagnostics_settings_page.dart` | Current candidate light/dark evidence reviewed. October 10 source changes make this route review-only. Busy/error, consent/delete, keyboard, and accessibility states remain unverified. |

### Excluded from implementation in this pass

- **Approved/frozen:** Train Overview/Plans and shell reference; Active Workout; Profile root and approved child routes; approved Progress routes; Logbook root, Full History, and Session Detail; Workout Settings and its separately approved children; Workout Progress Flows, Flow Editor, and Flow Methods selection page; Volume Boundaries; Body Part Rankings; Muscle Rankings; Anatomy Mapping; and Exercise Set Allocation. The task expressly protects these and their shared visual owners.
- **Explicitly protected recent work:** Exercise Editor; Exercise Set Allocation and its picker; Anatomy Mapping; both ranking screens; the Catalog family with October 5–6 dedicated refinement; the planning pages with source work recorded at `9ac12f9`; Profile measurements/database/diagnostics routes recently changed in the current candidate; Optimized Workout Settings and Analytics Dashboard with active dirty source changes; and Onboarding with active dirty source changes. Lack of formal approval was not treated as permission to edit them.
- **Shared dialogs/sheets (C):** Workout/health dialogs have multiple callers, including approved workout and Progress routes. No isolated caller defect justified changing their shared presentation; an exhaustive caller/theme/keyboard matrix is still absent.
- **Preset Generation QA (D):** `lib/screens/exercise/preset_generation_qa.dart` is reachable, but no matching route-local Expressive composition was found. Creating one would be a new screen-family design rather than a polish correction, so it is recorded for a separately scoped design pass.
- **Unreferenced/placeholder:** E routes without a production caller and F placeholder routes remain outside the task's eligibility definition. No routes were activated, deleted, or promoted.

### Ledger consistency note

The master ledger's D description says Dashboard lacks a route-local Expressive branch, while current `dashboard_page.dart` explicitly wraps the route in `AppExpressiveDestinationTheme(family: dashboard)` and its source/evidence shows a plum hero and tonal grouping. This appears to be a stale classification description. It was not changed because the user prohibited approval/classification changes; record it for a future inventory reconciliation. Dashboard is still unapproved. The ledger's D count/table mismatch remains outside this pass.

## B. Changes by page

**No page was modified.** Visual review did not establish a high-confidence P1/P2 inconsistency on the eligible Dashboard route. The reviewed planning/Catalog/Profile routes were protected as recent work. The only confirmed minor observation was the Catalog search-empty copy, which belongs to a recently refined route and is deferred rather than changed here. No business logic, data semantics, persistence, route behavior, or Classic/Neo styling changed.

## C. Visual evidence and provenance

All image media remains local. No screenshots were captured, edited, moved, or deleted in this pass.

- The existing 2026-10-10 candidate folder is [`current-candidate`](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/README.md). Its README records 92 verified captures, Pixel 7 `28021FDH200228`, `com.tonos.expressivepreview`, `tonos_expressive_preview.db`, Flutter 3.47.5 / Dart 3.13.4, and APK SHA-256 `54c07578ccf8d6f8d9c32314878128d4a0ccc1e4a0aeb49c547f1466d62cdd47`. The recorded Git HEAD is `ab18ed8...`, whereas the live branch is now at `9ac12f9...`; therefore the APK is not described here as a newly built current-HEAD APK. Route-specific source hashes were compared where available, but this is not a substitute for a full current-source build or all shared-dependency verification.
- Dashboard: [light](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/dashboard/dashboard-home-light.png), [dark](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/dashboard/dashboard-home-dark.png), and [dark 2× boundary](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/dashboard/dashboard-2x-dark-boundary.png). A second [light/dark root pair](post-remediation-evidence/20261010-build-79e1ad79/dashboard-root-light.png) · [dark](post-remediation-evidence/20261010-build-79e1ad79/dashboard-root-dark.png) was inspected as historical corroboration.
- Planning: [Plan Management light](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/plan-management-light.png) · [dark](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/plan-management-dark.png); [Premade Plans light](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/premade-plans-light.png) · [dark](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/premade-plans-dark.png); [Preset Detail light](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/preset-detail-light.png) · [dark](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/preset-detail-dark.png); [Gym Profile light](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/gym-profile-light.png) · [dark](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/planning/gym-profile-dark.png).
- Catalog: root light/dark, browser light/dark/no-results/filter, Focus Library body-part/muscle, anatomy-definition, and exercise-detail states are in [`catalog evidence`](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/catalog/). Capture currency and exact-source confidence varies by route/state as described above.
- Profile data screens: Progress Settings, Measured Items, and Diagnostics & Privacy light/dark pairs are in [`profile evidence`](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/profile/). Their direct files were recently changed; these images are visual context, not a current-APK claim.
- Missing/unverified states include Dashboard full-scroll/edit/reorder on-device states; Plan Management empty/delete/restore/dialog states; Premade Plans empty/load-failure/selection persistence; Preset Detail swap/edit/discard dialogs; Gym Profile keyboard/error/unsaved-exit; Catalog dark search/no-result/media fallback and all caller variants; Profile maintenance/permission/error dialogs; and the Preset Generation QA page itself.

## D. Validation

The planning-route agent ran a focused existing-test batch as a source/evidence sanity check, despite making no source changes:

- **50 passed, 0 failed**, across 8 files: `plan_management_theme_test.dart`, `plan_management_responsive_test.dart`, `premade_plans_page_theme_test.dart`, `preset_detail_screen_theme_test.dart`, `gym_profile_screen_theme_test.dart`, `preset_generation_qa_responsive_test.dart`, `preset_generation_tokens_test.dart`, and `preset_generation_weight_math_test.dart`.
- Command used the repository-pinned Flutter 3.47.5 executable with `test --no-pub`. An initial attempt with the system Flutter 3.29 / Dart 3.7 failed the SDK floor; the pinned-SDK rerun passed.
- Scoped analysis of Plan Management, Premade Plans, Preset Detail, Gym Profile, and Preset Generation QA: **0 errors, 0 warnings, 3 informational deprecation notices**. Notices are `ReorderableListView.onReorder` at `preset_detail_screen.dart:767`, and `RadioListTile.groupValue` / `onChanged` at `preset_generation_qa.dart:710,715`.
- Formatter was not run because no Dart file changed. `git diff --check` passed.
- No full repository suite, broad analyzer, build, Pixel install, screenshot refresh, or device-data operation was performed. Current 320 dp/text-scale tests exist for some routes, but no comprehensive device matrix was run in this pass.

## E. Review readiness and priorities

These are recommendations only; no screen is approved by this report.

| Screen/group | Recommendation | Reason / next work |
| --- | --- | --- |
| Dashboard root | **Ready for user visual review** of the captured normal-width light/dark root; **additional qualification needed** | The visible composition is already Expressive. Inspect lower scroll content, edit/reorder, and compact/large-text states before any qualification claim. Reconcile the D-description mismatch separately without changing approval status. |
| Plan Management; Premade Plans; Preset Detail; Gym Profile | **Ready for user visual review** of the captured light/dark baseline; **needs interaction-state review** | Main compositions look coherent; missing modal, empty, save, and persistence states are listed above. No new polish is justified without a user review or a concrete defect. |
| Catalog root, browser, Focus Library, definitions, Details sheet | **Ready for user visual review** for inspected captures; **needs evidence/interaction follow-up** | Recent dedicated refinements protected the files. Correct the query-specific empty-state wording in a separate Catalog task; refresh evidence for routes whose source/build provenance is not exact. |
| Measurements & Trends Settings; Measured Items; Database Settings; Diagnostics & Privacy | **Deferred** | Recent source changes protect them from this pass. Review their maintenance, editor, permission, and error states after that work is explicitly reopened. |
| Onboarding; Analytics Dashboard; Optimized Workout Settings | **Blocked/deferred** | Active dirty source changes were present. Do not overlap them; finish their owning task and then review current-source evidence. |
| Preset Generation QA | **Needs a separately scoped Expressive design task** | Reachable but no meaningful route-local Expressive presentation was established. Do not invent a redesign within this polish-only assignment. |
| Shared workout/health dialogs | **Deferred** | Shared callers include approved routes; caller-specific theme, keyboard, and reduced-motion review is needed before changing shared presentation. |

## F. Preservation

- No approved/frozen route, explicitly excluded screen, Classic presentation, Neo presentation, data, persistence, navigation, or production behavior was changed.
- Exercise Editor and Exercise Set Allocation source/picker were not modified; Anatomy Mapping and both ranking screens were not modified.
- Pixel preview database/preferences were not accessed; no installed package was changed.
- Approval classifications, master inventory counts, golden images, and ratchet fingerprints were not changed.
- No commit or push was made. All pre-existing dirty and untracked work remains in place.
