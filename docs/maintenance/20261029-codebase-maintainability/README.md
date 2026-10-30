# Codebase maintainability pass

Started: 2026-10-29. Branch: `codex/codebase-maintainability`.
Baseline: `6331ccd4aa4a7a626e0b4a0a659ce2d5d8f36d99` on
`feature/expressive-visual-polish`, already pushed before this pass.

## Scope and boundaries

This pass inventories the tracked application, native configuration, supporting
services, tooling, CI, and automated tests. It combines static analysis, existing
contracts, targeted source review, and regression tests. An inventory match is
triage evidence, not a proven defect or a claim that every line was manually
reviewed. Physical-device, native-platform builds, production infrastructure,
dependency vulnerability scanning, and performance profiling require separate
qualification; they are not inferred from Flutter tests.

Preserve approved presentation and motion in all three themes, existing routes,
stored identifiers, database schemas, preview data, and archived review evidence.
Do not combine structural moves with new features, dependency upgrades, schema
migrations, or a state-management replacement. Keep structural changes and
intentional reliability changes in separate commits.

## Inventory and ownership

The initial tracked-code inventory examined 717 source/config/test files:
375 handwritten production/configuration files, 326 test/driver files, 14
generated platform/localization files, and two catalog data files. The 375
handwritten files contain 165,760 lines; this includes configuration and platform
support, not only Dart. The app has 305 non-generated Dart files, including 19
over 2,000 lines. Generated files and catalog datasets are not refactor targets.
The reproducible per-file snapshot is retained locally at
`.build/maintainability/inventory.json` rather than adding a large generated
manifest to version control.

| Area | Current ownership and audit focus |
| --- | --- |
| App bootstrap, navigation, onboarding | `main.dart`, providers, route screens; initialization, identity guards, disposal, save/cancel, persisted tab IDs. |
| Workout logging, plans and generation | Durable active-session provider, transaction DAOs, generation/flow validators; preserve atomic completion, draft recovery, progression and ordering. |
| Database and migrations | Repository facade, DAOs, schema/maintenance/backup policy; transaction boundaries, compatibility, parameter binding, import/export/privacy contracts. |
| Nutrition | Nutrition provider, food catalog repository, food/portion editors and DAO; separate presentation from conversions and persistence, preserve historical day scope. |
| Measurements and analytics | Shared trend/chart widgets, validation/comparison services; canonical units, dates, precision and retained chart state. |
| Themes and shared components | Existing tokens, destination themes and primitives; ownership, repeated branches, accessibility and responsive behavior. Approval records are unchanged. |
| Optional content and media | Trusted URL/integrity policy, bounded cache and download coordinator; optional failures, HTTPS, hash/size bounds and recovery. |
| Diagnostics relay | Worker schema, bounded input, D1 binding and deletion/retention handlers; allowlisted metadata, parameterized statements and privacy-preserving behavior. |
| Native shells and delivery | Android manifests/signing policy, iOS/macOS/Windows/Linux/web wrappers and CI; review configuration and contracts without claiming native builds. |
| Tests and tools | Dart/Node tests, content/catalog builders, theme inventory/ratchet and device scripts; keep behavior checks distinct from lexical ownership checks. |

Large files mix real responsibilities: `database_helper.dart` has 5,812 lines,
onboarding 4,553, exercise details 4,400, Health Trends 4,255, and workout charts
3,397. Splitting them solely to meet a line target would not prove better design.
Start by moving cohesive, independently testable responsibilities.

Disk usage is a separate concern. Tracked `docs/` is approximately 590.6 MiB,
`tools/` 125.3 MiB, archived APK downloads 108.7 MiB, and `lib/` 8.5 MiB. Most
repository bytes are not handwritten application code. No screenshots, datasets,
APKs, generated sources, or other archives are deleted by this pass.

## Prioritized findings and acceptance

| ID | Priority | Finding | Required action and acceptance |
| --- | --- | --- | --- |
| M01 | High | Automatic Settings changes several `PresetSession` flags directly before Save, despite an atomic provider save API. Dismissal or a failed save can leave shared state changed. | Keep a local draft for every editable flag; test dismiss, failed save/retry, and successful persistence without changing layout. |
| M02 | High | Unit/language, Dashboard, navigation and onboarding preference providers have asynchronous load/mutation paths without consistent disposal, ordering or checked-write handling. | Reproduce initialization/disposal/write failures, serialize conflicting changes, retain last persisted state on failure, and reuse a small checked preference writer where appropriate. |
| M03 | High | Selected-profile equipment requests can finish out of order and attach another profile's equipment to the current selection. | Guard stale results and selection persistence; test deliberately reversed responses and disposal. |
| M04 | High | Food customization updates basics, density, barcodes, nutrients and portions in separate operations. A late failure can leave a partial save. | Establish a single transaction boundary, retain the public repository API and schema, and prove rollback with failure injection. |
| M05 | Medium | `AppRepository.warmUp(verify: true)` treats a completed `PRAGMA quick_check` query as success without examining its result. | Return success only for an actual `ok` result; test corruption rows, empty results and query failures. |
| M06 | Medium | Food portion conversion/default/name/payload logic lives in the large editor alongside widget construction and controllers. | Extract a pure mapper with conversion/default/precision tests and retain rendered editor contracts. |
| M07 | Medium | CI push filters omit the branch namespace used for this work (`codex/**`). | Add that namespace and extend the workflow contract; do not change release/signing permissions or deploy anything. |
| M08 | Low | `active_session.dart` still contains a 236-line commented legacy implementation after its live export. | Remove the inert historical block; preserve the stable export and all active-session consumers. Git retains the earlier implementation. |

## Ordered batches

1. Establish baseline analyzer, full Flutter suite, Node relay, inventory and
   ratchet results. Record existing failures before changing production code.
2. Make low-risk structural extractions (M06, M08, persistence orchestration).
   Preserve public callers and visual contracts; checkpoint the structural batch.
3. Fix demonstrated reliability defects separately (M01-M05), with failure,
   cancellation, concurrency and disposal regression tests as appropriate.
4. Close the CI branch-coverage gap (M07) and document ownership/maintenance rules.
5. Run focused checks per batch, then broad validation at the milestone. Record
   the final state, commits, remaining backlog and unverified qualification.

## Baseline and validation

Before production changes, the full Flutter baseline completed with **2,391
passes and 14 failures**. Logs are local, ignored artifacts under
`.build/maintainability/`. The diagnostics relay passed all eight Node tests.
Repository analysis completed with 79 informational diagnostics and no errors or
warnings. The theme ratchet report listed 18 protected files; enforcement later
exposed stale enclosing-statement fingerprints in four of those files. The
protected-file list is unchanged by this pass.

The 14 failures are existing test/reference drift: two route-marker contracts,
five inventory ownership/debt assertions, one inventory CLI contract, two flow
control golden cases (four reference images), two onboarding duration assertions,
and two chip-indicator assertions which do not account for the existing motion
wrapper. Resolve these against `6331ccd` without changing its app presentation.
Two existing speed-dial style snippets remain technical debt: give them an
explicit nutrition review queue and exact pending digest, not an allowlist or a
claim of visual reapproval. Freeze the current inset flow-control rendering as
the pre-refactor golden reference. Historical images remain in Git.

An independently modified `docs/CODEBASE_COMPREHENSIVE_REVIEW.md` appeared during
the audit. Preserve it unchanged and exclude it from this pass's commits.

### Checkpoint guardrail repair

- Updated route-marker assertions to the shared Tonos overlay APIs already used
  by the checkpoint, without altering app navigation.
- Reviewed exact existing recipe counts in WeightCard, Flow Methods, Workout
  Progress Flows and settings tiles. Kept kind/count assertions; added kind-level
  checks for the flow groups rather than replacing them with loose presence checks.
- Added the two existing speed-dial snippets to the exact pending-debt digest
  and nutrition review queue. Neither snippet is promoted to qualified status.
- Reviewed the stale ratchet statements against detailed lexical output: the
  existing ink-shape outline suppression, chip pulse wrapper, and Cardio/Stretch
  shared popup-motion wrappers. Replaced four obsolete hashes at unchanged
  occurrence counts and added the one existing ink-shape statement. The same 18
  files remain protected. No theme/widget source in those files was changed.
- Preserved current flow-control rendering in four golden references and checked
  the generated images before subsequent refactoring. Old images remain in Git.
  Updated assertions for the existing 220ms onboarding selection motion and
  wrapped chip icons. This is technical baseline repair, not new visual approval.
- Added `codex/**` to CI push filters with a workflow contract. No remote build
  or deployment is triggered by the local audit.

The focused guardrail and protected-component rerun passed **102 tests**; route,
onboarding, optimized-settings and golden cases also passed in the preceding
focused run. Full-suite revalidation remains the final milestone.

### Structural and safety batches in progress

- M06/M08: extracted the pure food-portion mapper and removed the commented legacy
  workout implementation. **47 focused tests passed**, including conversions,
  editor light/dark recipes, numeric round trips, repository injection and durable
  workout behavior.
- M01/M05: all automatic-settings flags remain local until the existing atomic
  save succeeds; integrity verification checks the returned `ok` row. **18 focused
  tests passed**, including dismiss, failed-save/retry and all three themes.
- M03: stale equipment responses are ignored, and profile-selection writes are
  serialized. **31 focused tests passed**, including reversed responses, delayed
  writes and existing Catalog caller behavior.
- M02: preference changes wait for loading, check backend success, compensate
  failed writes, and publish only after persistence; loading/mutations respect
  disposal. UI owners report save failures through existing localized feedback.
  **58 focused tests passed** before adding additional compensation/disposal cases.
  The helper documents the difference between best-effort preference compensation
  and real database transactions.

## Follow-up structural backlog

- Extract exercise-detail tab bodies and media-viewer presentation along actual
  feature boundaries, retaining the single approved shared caller behavior.
- Separate chart data preparation from chart presentation in report, exercise
  progress and Health Trends components; retain existing animation ownership.
- Split onboarding's page orchestration from reusable page content and controls.
- Continue reducing facade orchestration only where a domain owner and transaction
  boundary already exist; do not duplicate SQL in a new abstraction layer.
- Review legacy nutrition compatibility fallbacks against real supported schema
  versions before deleting them. Empty catches are not automatically defects:
  several explicitly support older schemas or optional public media.
- Address deprecated Flutter APIs in focused migration batches with rendered
  control/semantics checks, rather than bulk replacing APIs during this pass.

These are follow-up candidates, not automatic permission to redesign frozen
screens or evidence that they are defective.

## Diagnostics reference

The relay review uses the local [Workers review skill](C:/Users/talh7/.codex/skills/workers-best-practices/SKILL.md),
[Cloudflare Workers best practices](https://developers.cloudflare.com/workers/best-practices/workers-best-practices/),
and [D1 prepared statements](https://developers.cloudflare.com/d1/worker-api/prepared-statements/).
The existing intentional absence of request logging is retained; general
observability guidance does not override the app's privacy boundary. Running
the local schema/handler tests does not qualify the deployed service or secrets.
