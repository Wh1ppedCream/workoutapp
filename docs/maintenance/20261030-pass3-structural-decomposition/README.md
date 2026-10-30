# Maintainability Pass 3 — structural decomposition audit

- Branch: `codex/codebase-maintainability`, local commits only.
- Starting checkpoint: `e152d88` (Pass 2 and peer-review corrections).
- Original feature baseline: `6331ccd4aa4a7a626e0b4a0a659ce2d5d8f36d99`.
- Workspace: `E:\projects\env_test`.
- SDK: `E:\tools\flutter_sdks\3.47.5\flutter\bin\{dart,flutter}.bat`.
- Scope: S1–S4, plus the four safe constructor changes from optional S6.
- Final qualification: complete on 2026-10-30 — **2,515 full-suite tests and 172 contract checks passed**, with 0 analysis errors/warnings and 75 existing deprecation infos.

## 1. Commit guide

| Batch | Commit | Review focus |
| --- | --- | --- |
| S1 | `b391681` | Database repair/food maintenance and measurement/catalog/ranking DAOs; original connection and import transaction ownership retained. |
| S2 | `36fc7f6` | Private generation implementation parts and overridable repository domain mixins; cache ownership retained on `AppRepository`. |
| S3 | `efa5448` | Onboarding primitives/templates and editor dialogs/tabs/media parts; library-aware source contracts and inventory ownership. |
| S4 | `8b2a26f` | Health, exercise-progress, workout-report and exercise-detail presentation parts; inventory and remaining physical-file assertions synchronized. |
| S6, limited | `cdfcba5` | Four initializing-formal notices removed without changing public constructor argument names. |
| S2 comment cleanup | `f5d63cd` | Removes empty facade section labels left by the extraction; no executable changes. |

Each batch was formatted and checked before its separate commit. No commits
were pushed. The audit report is a separate final documentation commit so its
qualification record describes the completed code checkpoint.

## 2. Entry files before and after

Counts include comments and blank lines. The purpose is cohesive modules, not
removing functionality or claiming an equivalent reduction in total code size.
All canonical import paths and public types remain available.

| Canonical file | At `e152d88` | After structural batches | Extracted ownership |
| --- | ---: | ---: | --- |
| `lib/db/database_helper.dart` | 5,777 | 3,781 | Six domain/metadata DAOs under `lib/db/`. |
| `lib/services/preset_generation_service.dart` | 2,358 | 299 | Three private parts under `lib/services/preset_generation/`. |
| `lib/repositories/app_repository.dart` | 1,976 | 401 | Seven instance-method domain mixins under `lib/repositories/parts/`. |
| `lib/screens/onboarding_flow.dart` | 4,570 | 2,259 | Models/templates, plan overview, and step widgets under `lib/screens/onboarding/`. |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | 3,415 | 688 | Draft value, selection dialogs, identity, allocation, and media under `exercise_editor/`. |
| `lib/widgets/health_trends_section.dart` | 4,255 | 1,194 | Tiles, charts, dialogs, models/units under `lib/widgets/health_trends/`. |
| `lib/widgets/exercise_progress_section.dart` | 3,550 | 486 | Models, tiles, detail page, chart under `lib/widgets/exercise_progress/`. |
| `lib/widgets/workout_metric_chart_card.dart` | 3,397 | 769 | Report models, composition, selectors/insights, chart, formatters/math under `workout_metric_chart/`. |
| `lib/widgets/exercise_detail_sheet.dart` | 4,400 | 2,608 | Media preview, history cards, metric cards, record chart/formatters under `exercise_detail/`. |

The canonical entry files still own their existing route/state lifecycles.
This is a first structural cut: onboarding orchestration and the exercise-detail
tab builders remain substantial, rather than introducing a new state-management
architecture in the same pass.
The inventory now scans 361 Dart files (319 previously), reflecting 42 new
focused production modules. Larger extracted areas still include onboarding
step primitives (1,814 lines) and exercise-progress tiles (1,619 lines); they are
cohesive presentation groups, not a claim that every large file is eliminated.

## 3. Database and service invariants

### S1: database domains

- `schema_repair_dao.dart` owns the existing legacy repair operations.
- `food_fts_maintenance_dao.dart` owns trigger/index/FTS preparation, food
  normalizations, catalog compaction, starter cleanup and maintenance keys.
- `database_metadata_dao.dart` owns shared table/column existence queries.
- `measurement_dao.dart` owns measurement CRUD, model mapping and latest
  bodyweight conversion.
- `catalog_json_export_dao.dart` owns the existing catalog JSON payloads.
- `ranking_and_volume_dao.dart` owns ranking/boundary/stat operations and
  completed-set credit aggregation.

`DatabaseHelper` retains schema version 62, opening/migration orchestration,
public facade signatures, database export/import, integrity/maintenance APIs,
and connection lifecycle. Full import still validates before replacement and
performs destructive writes inside the original transaction; its FTS
suspend/rebuild/restore and committed-import error behavior remain intact.

Executor-only collaborators accept `DatabaseExecutor`. Existing non-transactional
lookup/definition/stats/analytics DAO and allocation-resolver parameters were
widened from `Database` to `DatabaseExecutor` so these calls also work inside a
caller-owned transaction. Operations that already own transactions, and the
stretch seeder that still requires a database, retain `Database` parameters.
No casts, new connections, nested transaction ownership or SQL rewrites were
introduced. The explicit integration-test reset still clears the moved FTS
capability memo through `resetCapabilities()`.

### S2: generation and repository domains

Generation parts separate weight estimation/history, candidate scoring and
bundle planning. They share the original library-private state; public service
methods and test seams remain on `PresetGenerationService`. Candidate analysis
concurrency remains 4. Scores, fallback order, working-weight calculations,
bodyweight memoization and `createPresetAtomic` persistence are preserved.

Repository parts use instance-method mixins on a small dependency interface.
They do **not** turn public repository methods into extensions. Public APIs
remain overridable through `extends AppRepository` and visible to
`implements AppRepository` fakes. Cross-domain public calls dispatch through
the same repository instance, including media helpers and warmup.

Static analysis caches, trimming, cache invalidation, and import-cache recovery
remain together in the canonical repository. `createSessionAt` and
`saveCardioDetails` also remain in that file for the compatibility contract.

## 4. UI and contract preservation

The UI parts retain their original classes, constructors, widget composition,
controllers, theme lookups, callbacks and motion calculations. Editor
presentation extensions access the existing state; `_updateEditorState` forwards
to `State.setState` in the original subclass without changing callbacks or
notification timing. Save/load/dirty tracking remains with that state owner.

A local analyzer-AST comparison checked **322 original UI declarations or
editor members** across all six UI targets. Their emitted AST source was
identical, allowing only the explicit `setState` forwarding bridge. This is
structural evidence; no new device screenshots or visual approval are claimed.
The comparison log is `.build/maintainability/pass3-ui-move-verification.log`.
The same read-only check verified **655 public method signatures** across the
database facade, repository and generation service, and an identical multiset
of **955 database string literals/interpolation segments**, including SQL and
maintenance/preference keys, across the facade and extracted DAOs.

Source-reading contracts now use `test/support/dart_source_library.dart` to
expand actual `part` directives. Missing parts, wrong `part of` ownership and
duplicate/cyclic part inclusion fail instead of silently dropping checks.
Existing theme-token, caller-state and source-order assertions remain in place.
The database import contract reads moved trigger SQL from its owning DAO while
retaining its transaction and ordering checks on the canonical facade.

Inventory path rules and review queues were updated together for each moved UI
library. Named recipe selectors and exact per-kind expected counts are retained.
Pending-debt checks group physical parts back to their canonical library; the
existing baseline's **643 findings and exact snippet digests were not changed**.
No pending styling was relabeled as migrated, and no approval ledger changed.

All 18 ratcheted source files and their fingerprint manifest remain untouched.

## 5. Focused regression evidence

| Gate | Result |
| --- | --- |
| S1 database directory, database contracts and live-import recovery | **134 passed**. |
| S2 generation/provider/repository/training/flow checks | **30 passed**. |
| S2 complete contracts plus new repository-dispatch regressions | **174 passed**. |
| S3 complete contracts, onboarding, editor, and source-ownership checks | **256 passed**. |
| S4 complete contracts and analytics/detail/measurement widget coverage | **414 passed** initially; the sole stale physical-file assertion was corrected and its focused recheck passed. Final full qualification below covers the corrected state. |
| S6 active-plan and diagnostics regressions | **20 passed**. |
| Final facade comment cleanup: compatibility/injection contracts | **7 passed**. |
| Scoped analysis after each batch | No errors or warnings; no new informational notices. |

Eight new regression cases were added:

- Six in `test/db/extracted_domain_daos_test.dart`: repeatable repairs and data
  retention, measurement units/timestamps/CRUD, caller transaction rollback,
  ranking/stat/export payloads, empty range aggregates, and trigger/flag
  ownership. These use in-memory SQLite and the production schema.
- Two in `test/repositories/domain_dispatch_test.dart`: convenience media APIs
  and cross-domain warmup honor public subclass overrides.

During validation, a new DAO test initially assumed the schema contained no
equipment rows; it was corrected to query its inserted ID. A first screen-check
command also referenced a nonexistent generic editor test filename and was
replaced by the actual presentation/interaction suites. No production changes
were needed for those harness issues. The gallery, preview database and device
were not used or modified.

## 6. Final qualification

| Gate | Result |
| --- | --- |
| Complete Flutter unit/widget suite | **2,515 passed**, 0 failed; 19m 20s wall time including startup. Eight more cases than the 2,507-test starting checkpoint. |
| All 43 contract test files | **172 passed**, 0 failed. |
| `dart analyze lib test integration_test test_driver tools` | Exit 0; **0 errors, 0 warnings, 75 infos**, down from 79. |
| Theme inventory | **4,382 candidates** across 361 Dart files: 3,595 migrated, 144 allowlisted, 643 pending, 0 unassigned; no missing or overlapping review queues. |
| Theme ratchet | **18 protected source files passed**, none modified. |
| Development / locked production content checks | Both passed with 2 configured environments. |
| Node diagnostics relay | **8 passed**, 0 failed. |
| Read-only extraction comparison | 322 UI declarations/members, 655 public method signatures and 955 database literals/segments preserved. |
| Whitespace back to `6331ccd` | Passed for all code commits and the staged audit report; checked again after the documentation commit. |

Local logs use the prefix `.build/maintainability/pass3-`; overlapping focused,
contract and complete-suite counts must not be summed.
No executable production or test logic changed after the full suite started.
The only later source edit removed orphaned comment headings in `f5d63cd`,
with 7 compatibility/injection checks rerun. The audit text was finalized after
the full run completed. The final tracked worktree is clean; unrelated
untracked artifacts remain preserved.

The handoff's two tool-path examples needed correction to match this checkout:
the ratchet takes its manifest path as the enforcement argument, and Node relay
tests live under `services/diagnostics_relay/test/`. Content checks also require
an explicit `--source`. The commands below use the real interfaces.

```powershell
$Dart = 'E:\tools\flutter_sdks\3.47.5\flutter\bin\dart.bat'
$Flutter = 'E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat'

& $Dart analyze lib test integration_test test_driver tools
& $Dart run tools/theme_style_inventory.dart --check
& $Dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json
& $Dart run tools/content_environment_check.dart --source assets/content/content_environments.json --target development
& $Dart run tools/content_environment_check.dart --source assets/content/content_environments.json --target production --locked
node --test services/diagnostics_relay/test/schema.test.mjs
$contracts = rg --files test -g '*contract_test.dart'
& $Flutter test --no-pub --concurrency=4 --reporter expanded @contracts
& $Flutter test --no-pub --concurrency=4 --reporter expanded
git diff --check 6331ccd..HEAD
```

## 7. Deferred work and qualification boundaries

- Optional S5 read batching is deferred. Preset loading retains its existing
  overridable single-item reads, request guards and behavior. Query-shape changes
  deserve their own performance/fake-fallback review rather than being mixed
  into this structural checkpoint.
- S6 is deliberately limited to the four initializing-formal notices. The 75
  Flutter deprecation infos remain; replacing those UI APIs can affect widget
  identity, interaction or ratcheted styling and was not forced into this pass.
- No SQLite schema/migration, ARB/generated localization, preference key,
  dependency/lockfile, route, approved layout or motion specification was changed.
- No build, install, device navigation, screenshot capture, preview reset,
  fixture reseed, staging of unrelated artifacts, destructive cleanup or push.
- Existing untracked `android/build/`, `flutter_06.png`, `incoming/`,
  `test/theme/widgets/failures/` and `tmp/` remain outside these commits.
  `.build/` retains ignored scratch evidence and logs.
- Unit/widget and static qualification are distinct from physical-device and
  release qualification. This pass does not assert either of the latter.
