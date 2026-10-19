# Tonos Expressive — Visual Readiness Audit

**Audit snapshot:** 2026-10-10; updated after the local remediation candidate  
**Repository baseline:** `feature/expressive-visual-polish` at `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`  
**Initial evidence:** Pixel 7, isolated preview `com.tonos.expressivepreview`, database `tonos_expressive_preview.db`, Flutter 3.47.5 / Dart 3.13.4.  
**Initial evidence set:** [`current-candidate/20261010-build-e87b4eee0383`](../tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/coverage.md). Earlier dirty-tree captures and onboarding bootstrap evidence are recorded in [`post-remediation-evidence/20261010-build-79e1ad79/`](post-remediation-evidence/20261010-build-79e1ad79/README.md); the latest dedicated-preview candidate captures are in [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).

This is a visual readiness and conservatism audit, not a new approval record or technical qualification. Visual conservatism labels below are separate from the route ledger's A–H approval/adaptation classifications. Existing user approvals remain as recorded in the route ledger. No screenshots or read-only review findings change approval status. The original route table/findings describe the initial `e87b4eee` evidence; the current-candidate follow-up below supersedes findings where implementation or fresh evidence changed.

**Current-source follow-up — 2026-10-12:** The C/D remediation records Onboarding, Dashboard, Analytics Dashboard / Weekly Sets Overview, Preset Generation QA, and the plan-specific Flow Methods editor as B implementation candidates, pending the user's visual review. Onboarding received two scoped Expressive refinements; the other four required no new production changes. Caller-specific Health dialog/menu interaction states are tracked separately and are not page archetypes. No current-device evidence was captured after this follow-up; historical screenshots remain historical. No visual approval changed.

## Method and confidence

The review combines the current-source route ledger, its production navigation edges, the dated 92-capture evidence set and hierarchy dumps, and focused read-only reviews of Profile/shared components, Catalog/Analytics, Train/planning, Progress, Logbook, and representative routes. Static evidence was used to identify presentation risks; it does not prove all interaction, accessibility, text-scale, or viewport behavior. Where a route/state was not visible in current evidence, its visual classification is provisional or explicitly unknown.

The ledger identifies 55 configurable/non-release page archetypes (52 after excluding three release-denied destinations). The evidence package contains 92 verified in-app captures: 47 light and 45 dark, plus one failed lockscreen probe and one excluded redundant Diagnostics probe. Captures are local and are not intended for public baseline inclusion. Package provenance records source-input fingerprint `e87b4eee03832c8036a89ad6ce1337d3ec8c68c8adb2348ac8d42e7aeb950073`, production-tree fingerprint `9c4dae8f328fc3dee0fc411028b4e051da6a3fc7a5200f745460b2a09a708cf4`, and APK SHA-256 `54c07578ccf8d6f8d9c32314878128d4a0ccc1e4a0aeb49c547f1466d62cdd47`. The full provenance, source hashes, capture manifest, and route crosswalk are in the linked evidence folder.

The capture device was Pixel 7 `28021FDH200228`, 1080×2400 physical pixels at 420 dpi (approximately 411×914 logical dp). Evidence is not a responsive matrix: simulated 320 dp, wide/landscape, and systematic 1×/1.15×/1.5×/2× text-scale coverage were not captured. The current evidence is therefore useful for route-level visual triage, not a claim of complete route-state or responsive qualification.

## Route-family conservative Expressive audit

Conservatism labels:

- **A — Strongly Expressive:** composition, surface roles, hierarchy, and shape visibly establish the Tonos Expressive family.
- **B — Expressive but still conservative:** meaningful Expressive identity is present, but there are identifiable lower-page, shared-component, or route-state gaps to review.
- **C — Mostly Classic with Expressive decoration:** theme accents exist, but much of the underlying composition remains conventional or insufficiently evidenced.
- **D — Generic Material / needs full Expressive adaptation:** no convincing route-level Expressive composition is present in the current ledger/source review.
- **Unverified:** available evidence is insufficient to make a responsible visual classification.

These labels assess the reviewed route presentation only; they do not replace ledger statuses or user approval.

| Route family / representative routes | Conservatism assessment | Evidence-based assessment and remaining boundary |
| --- | --- | --- |
| Train Overview and Plans | **A — Strongly Expressive** | Approved reference family with substantial focal color, anatomy/Focused Sets composition, differentiated plan surfaces, and expressive navigation. The normal-width presentation is protected. Narrow responsive states are separate qualification work. |
| Active Workout / Session | **A — Strongly Expressive** | Approved reference family with expressive exercise hierarchy and completed/incomplete set treatments. Preserve the approved normal-width composition. Current evidence does not establish all keyboard, viewport, or transient interaction states. |
| Main navigation shell | **A — Strongly Expressive** | Approved expressive shell treatment is a current reference. This audit does not authorize shell redesign. |
| Planning: Plan Management, Premade Plans, Preset Detail, Optimized Workout Settings, Gym Profile | **B — Expressive but still conservative** | The paired candidate captures show clear planning color and recognizable hierarchy. Route states such as dialogs, validation, selection persistence, keyboard, and return paths remain incompletely represented. The Premade Plans dark capture is specifically a loading-state capture, not a settled visual reference. |
| Catalog root, exercise browser, filters, anatomy definitions, Exercise Focus Library, Exercise Details sheet | **B — Expressive but still conservative** | The family has meaningful color and route-specific surfaces. The browser is quieter than the root, but read-only reviewers did not establish a blocking defect or a need for broad redesign. Repeated blue browser cards are a possible rhythm refinement, not a proven issue. Caller-specific shared-picker presentation and lower-page/media states remain review gaps. |
| Progress root, Exercise Progress detail, Measurement Trend detail | **A — Strongly Expressive; individually approved** | Each of these specific routes has its own visual approval. Approval boundaries do not extend to other Progress subpages or imply technical qualification. Current screenshot coverage is incomplete for several selected/populated states and dialogs. |
| Logbook root/calendar, Full History, Session Detail | **A — Strongly Expressive; individually approved** | Each listed screen has its own approval. Do not generalize approval to other Logbook routes. Current visual approval is not responsive or release qualification. |
| Profile root and individually approved children (User Information, UI & Appearance, Navigation Editor, Guided Tutorials, Gym & Workout Settings, Workout Settings main, Body Part Rankings, Workout Progress Flows, Flow Editor, Workout Progress Rules, Ongoing Workout Exit, Volume Boundaries) | **A — Strongly Expressive; individually approved** | These are approved only within their recorded route/state boundaries. Other child screens remain independent review items. The approved screens are frozen against casual visual edits. |
| Profile/Analytics candidates: Muscle Rankings, Body Part / Muscle Mapping, Exercise Set Allocation, Exercise Editor; Measurements & Trends Settings, Measured Items, Database Settings, Diagnostics & Privacy | **B — Expressive but still conservative** | Muscle Rankings, Mapping, and the caller-scoped Exercise Editor Catalog picker have candidate treatments and fresh normal-width Pixel captures. Database health values now wrap fully in both modes. Exercise Set Allocation and the other listed settings retain separate review gaps. No new visual approvals are implied. |
| Workout Progress Flow Methods editor and related child workflows | **B — Expressive implementation candidate; visual approval pending** | The plan-specific `AddPresetMethodDialog` is distinct from the A-approved FlowMethodsPage and AutoPresetFlowScreen. It uses Tonos fields, an anchored Expressive choice menu and scrollable dialog content. Existing 2026-10-11 device evidence shows the plan-method editor in light mode and action menus in both modes; the dark editor, keyboard and unusual viewport remain for user review. |
| Onboarding | **B — Expressive implementation candidate; visual approval pending** | This pass applied planning tones to the Included Equipment summary/chips and made Skip setup a route-local plum dialog with readable foreground and mint confirmation. Focused Expressive and plan-handoff tests pass. Historical bootstrap captures predate those changes and are not current-source evidence; review the new modal, full flow and light/dark states. |
| Shared Workout/Health dialogs | **B — scoped interaction candidates; user visual approval pending** | Source review found caller-owned Expressive dialog themes for metric creation/log/edit and deletion, plus the Tonos menu shape for entry actions. The 2026-10-11 Pixel evidence and focused tests cover the Measurement Trend detail action/edit/delete path in light/dark. This does not extend the approved Log Measurement dialog scope or any owning screen's approval to every caller. Cross-caller keyboard and large-text evidence remains open. |
| Dashboard | **A — Strongly Expressive composition; route status B, visual approval pending** | Current source and paired historical captures show a focal Expressive hero, differentiated warm/cool support zones, and responsive grouping. Focused light/dark and configuration tests pass. No Dashboard-only redesign is justified; lower-scroll, edit/reorder and fresh current-source device states remain for user review. The older D wording is superseded. |
| Analytics Dashboard / Weekly Sets Overview | **B — Expressive but still conservative; route status B, visual approval pending** | The route uses analytics destination roles and a focal anatomy/metrics surface; body-part and muscle drilldowns keep the analytics destination identity. The current source preserves calculation and content order. Existing light/dark responsive route tests pass; older paired captures are not current-source evidence and the overall structure is still more conventional than the approved Train reference. |
| Preset Generation QA | **B — Expressive but still conservative; route status B, visual approval pending** | Current source uses Expressive planning roles for setup choices, fields, generated-plan review and actions; responsive tests pass across tested sizes/scales. Older light/dark images do not prove the current dirty-tree build. Review the actual generator in light/dark, including settled/error, save/cancel and persistence states. |
| Nutrition routes | **Out of this Expressive scope by explicit boundary** | Nutrition remains intentionally Classic/Neo-only in the route ledger. Do not enable or redesign it as part of this visual pass. Nutrition placeholder/deferred routes retain their separate statuses. |

## Concrete findings

### Profile and Analytics routes

1. **Initial Muscle Rankings finding — duplicated hierarchy (superseded by current candidate).** The initial `e87b4eee` light/dark screenshots showed a title in the AppBar and another in the hero, plural “Muscles Rankings,” and repeated per-row Rank labels. The current candidate removes that duplication, uses the localized singular title and one shared Rank heading, and wraps the long `Transverse Abdominis` label to two lines. See current Pixel images in `post-remediation-evidence/20261010-build-79e1ad79/`. Ranking values, edit/reorder/save behavior, and Classic/Neo branches remain preserved.

2. **Initial Body Part / Muscle Mapping finding — duplicate title and weak zone separation (superseded by current candidate).** The initial `e87b4eee` light capture showed a duplicate title and touching teal/amber zones; its dark capture was notification-obscured. The current candidate removes the duplicate Expressive AppBar title, adds 12 dp separation, and has clean light/dark read-only plus edit-state captures. Mapping and save behavior remain unchanged.

3. **Initial Exercise Editor picker finding — caller presentation mismatch (superseded by current candidate).** The initial `e87b4eee` light capture looked neutral and did not establish dark parity. The current candidate explicitly opts only the Expressive Exercise Editor caller into the existing Expressive Catalog presentation; fresh light/dark landing and picker captures are available. The shared Catalog route and other callers remain unchanged.

### Planning and Dashboard evidence interpretation

4. **Premade Plans dark capture — capture did not settle.** The light capture is settled; the paired dark capture shows “Checking plan exercises…” while its asynchronous FutureBuilder is unresolved. Source review indicates this is a capture taken before loading completed, not evidence of a broken page. Recapture the dark route after settling and update its manifest/metadata. Do not modify the UI solely to remove a transient loading state. Evidence: `planning/premade-plans-light.png`, `planning/premade-plans-dark.png`.

5. **Dashboard 2× capture — scroll boundary, not an established layout defect.** The large-text screenshot catches content at the scroll viewport boundary: the “Data & records” heading is partly above the captured viewport and Weekly Overview continues below it, while the hierarchy dump shows the Dashboard scroll region ending before bottom navigation. This is consistent with scroll position and viewport constraints; it does not establish overlapping or inaccessible content. No Dashboard-only fix is recommended from this capture. For review, capture Data & records and Weekly Overview as separate fully visible scrolled states at 2×. Evidence: `dashboard/dashboard-2x-data-weekly-stress.png` and matching hierarchy dump.

6. **Initial Analytics Dashboard finding — Expressive roles, conventional route composition.** The earlier `e87b4eee` images showed chromatic analytics roles but conventional route structure. The candidate now adjusts the Weekly Sets Overview focal card only, retains anatomy, Bodyparts/Muscles tabs, values, and navigation, and has fresh Pixel images in both modes. The overall content order is intentionally preserved; user review remains pending.

7. **Onboarding finding — Expressive component ownership.** The current source applies planning roles to intent, switch, choice, gym-space and workout-plan surfaces. This pass also toned the Included Equipment recap/chips and Skip setup modal. The bootstrap captures are not state-matched and predate this final polish, so they do not verify the current modal visually.

8. **Profile data/settings routes — interaction-state coverage remains open.** Current light/dark Database Settings captures show the full long database path and health values wrapping across lines in Expressive; its underlying table and surfaces remain unchanged. Remaining coverage gaps include metric edit/log/return flows; database transfer/maintenance, busy/error and cancelable confirmations; and diagnostics consent/report/sync-history/clear flows. Keep each route in the user-review queue; capture safe, cancelable states before proposing cosmetic changes.

### Capture artifacts and evidence gaps

- A thin lime line appears around the perimeter of several screenshots. Its source was not identified; the captures were not edited or cropped. It is not evidence of an application surface or color treatment.
- One initial lockscreen probe is marked `FAILED_EXCLUDED`; one redundant Diagnostics checkpoint capture is marked `EXCLUDED_REDUNDANT_PROBE`. Neither counts toward the 92 valid in-app images.
- The installed preview and database are isolated from normal Tonos data. Capture documentation reports the preview DB, WAL, SHM, and preference files were restored to their saved hashes after the capture session.
- Most candidate captures represent default/read-only states. Planning interaction/persistence/dialog/keyboard states, Catalog media fallback and lower detail states, profile editing dialogs, and several selected Progress states are not comprehensively represented.
- Current evidence is from one physical Pixel size. Compact 320 dp, wide/landscape, and systematic text scaling remain unqualified; do not infer responsiveness from the default Pixel captures.
- Active Workout does not have a fresh current-source screenshot in this capture set. The approved references remain valid as approval records, but these captures do not independently demonstrate the current candidate's exact rendering there.
- Onboarding and Preset Generation QA have no current route captures in this package. Historical Preset Generation QA captures exist elsewhere, but do not establish the current dirty-tree build.

### Candidate evidence record — 2026-10-10 (historical)

The final candidate for that October 10 capture run is recorded in
[`current-source-snapshot.md`](current-source-snapshot.md). Its Pixel 7
evidence is in
[`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).
The isolated-preview debug APK SHA-256 is
`2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7`. The
captured device is Pixel 7 `28021FDH200228` at its normal approximately 411 dp
logical width. Screenshot media remains local by user instruction. The earlier
build-79e1ad79 captures are retained as historical evidence, and the
wrong-entrypoint build-bbd53b9c capture is explicitly diagnostic-only.

At that time, this candidate and evidence superseded earlier issue/capture
notes for these states:

- **Muscle Rankings:** one in-page title, shared Rank heading, compact rank
  controls, and a two-line long muscle label instead of ellipsis; captured in
  light and dark.
- **Body Part / Muscle Mapping:** one Expressive title, clearer 12 dp section
  separation, and clean read-only/edit captures in light and dark.
- **Exercise Editor:** its picker alone opts into the existing Expressive
  Catalog presentation; landing and picker states have light/dark captures.
- **Weekly Sets Overview:** the focal anatomy/metrics card has an
  Expressive destination surface and asymmetric shape; both Bodyparts and
  Muscles tabs were captured in light and dark.
- **Analytics anatomy route identity:** Dashboard navigation now keeps the
  analytics theme identity when opening Body Part, Muscle, and linked
  definition routes. Fresh overview/detail images cover light and dark; this
  does not imply approval of the Analytics Dashboard or linked routes.
- **Database Settings:** long health-table values and the file path now wrap
  rather than truncate in Expressive. Light/dark normal and scrolled captures
  show the full path; Classic/Neo retain their previous behavior.
- **Optimized Workout Settings:** the Expressive page now shows its localized
  destination title above the existing Session budget and Reps & weights
  surfaces. Light/dark captures cover the default state only.
- **Dashboard root:** earlier candidate light/dark captures show the Dashboard
  route selected. Those images are from build `79e1ad79`, not the latest
  build-`2e4a2bd4` capture set. The current source and earlier screenshots show
  an Expressive focal hero and distinct supporting tonal zones, contradicting
  the old generic/D queue description. This pass records the route as B
  implementation-ready and awaiting personal visual approval; the old D
  wording is superseded, but aggregate inventory reconciliation remains open.
- **Onboarding:** historical repeated-setup images are separated under a
  bootstrap-build directory; they are not state matched and predate the current
  source. This pass applied planning tones to Included Equipment summary/chips
  and added a route-local Expressive Skip setup dialog. Review those updated
  states in a current-source build; the old note that Skip setup is a standard
  AlertDialog is superseded.

These findings do not approve or freeze any route. The five current B
candidates are listed in the current review queue. Remaining unrepresented states include picker search/filter/selection
return and failure; ranking keyboard, drag, and save; changed Mapping values;
onboarding completion/return paths; Optimized Workout Settings validation and
keyboard flows; Database Settings transfer/confirmation/error flows; and many
downstream dialogs and error states. No comprehensive responsive matrix is
established by the device captures.

## Approval and inventory boundaries

The last approval update reported **55 archetypes: A25 / B14 / C10 / D1 / E0 / F5 / G0**. The detailed status tables do not reconcile to that aggregate: C shows grouped entries plus a separately tracked Flow Methods editor, while D lists three distinct routes despite D1. This pass records five named route candidates as B and caller-specific Health dialog/menu states separately, but does not publish a replacement aggregate without a unique 55-row crosswalk. The separate 24-route dossier remains **15 approved / 9 pending**; the plan-specific Flow Methods editor remains pending within that subset. No candidate was marked visually approved; qualification is separate. Focused validation totals 67 passing tests across seven files, with no full-suite run. No current-device screenshots were captured after the onboarding change.

The separate 24-route review dossier reports **15 approved / 9 pending**. It is not the same denominator as the 55-archetype ledger. Visual approval, technical qualification, responsive qualification, accessibility qualification, analyzer/test status, style-inventory/ratchet status, and release readiness are independent. No candidate is newly approved by this audit.

## Recommended visual review order

The current user review order is maintained in the separate
[`visual-review-queue.md`](visual-review-queue.md): Onboarding, Preset
Generation QA, Analytics Dashboard / Weekly Sets Overview, Dashboard root, and
the plan-specific Flow Methods editor. Review each in light and dark using a
current-source build; keep caller-specific Health overlays as separate review
states and preserve all existing A approval boundaries.

The reviewed images and inventory remain local. Do not publish or stage this evidence package as public product media.
