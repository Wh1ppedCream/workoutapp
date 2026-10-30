# Codebase Maintainability & Reliability — Pass 2 Audit & Verification Report

- **Date**: 2026-10-29
- **Branch**: `codex/codebase-maintainability` (local only; nothing pushed to remote)
- **Original Theme/Feature Baseline**: `6331ccd4aa4a7a626e0b4a0a659ce2d5d8f36d99` (`feature/expressive-visual-polish`)
- **Pass 1 Endpoint**: `c703947` (`Record completed maintainability validation and regression coverage`; see [Pass 1 Audit Report](../20261029-codebase-maintainability/README.md))
- **Pass 2 Scope**: Targeted structural extractions (`P08`) and verified data-integrity, state-synchronization, async-recovery, lifecycle, and backup-import fixes (`P01`–`P07`), separated into clean commits for independent peer-agent verification.

---

## 1. Scope, Discipline, and Preserved Boundaries

Pass 2 continues directly from Pass 1 (`c703947`) under the same non-negotiable engineering and product rules:

1. **Commit Separation**: Pure structural extractions (`18a0aee`) are committed separately from intentional reliability and data-integrity fixes (`a436e82`, `ded7556`, `9a706d1`, `4a2f42e`), followed by a dedicated documentation and full-qualification commit.
2. **Zero Visual, Motion, or Theme Regressions**:
   - All three intentional theme families—**Classic**, **Expressive** (`A49 / B0` approved archetypes), and **Neo-Brutalism** (21 accepted surfaces, release-gated)—remain pixel-, layout-, and motion-equivalent.
   - **Zero** of the 18 protected files in `docs/theme-style-ratchet.json` were modified.
   - `tools/theme_style_inventory.dart --check` reports the exact same **4,382** style candidates (`144` allowlisted, `3,595` migrated, `643` pending, `0` unassigned) across `318` Dart files (`+2` new non-UI modules: `lib/db/flow_defaults_dao.dart` and `lib/services/optimized_workout_preferences.dart`).
3. **Zero Schema, Localization, Route, or Key Breakage**:
   - SQLite schema version remains **`v62`** (`lib/db/schema.dart` and `lib/db/schema_latest.sql` untouched).
   - Localization ARB catalogs and `lib/l10n/generated/` are untouched (`flutter gen-l10n` produces zero diff).
   - Stored `SharedPreferences` keys (`train.optimized_*`, `diagnostics.*`, etc.), `app_state` keys (`selected_gym_profile_id`), canonical screen/widget file paths, and preview datasets remain unchanged.
4. **Surgical Diffs & Worktree Hygiene**:
   - Edits in large legacy files (`database_helper.dart`, `app_repository.dart`, `nutrition_profile.dart`, `durable_active_session.dart`, `train2_page.dart`, `database_settings_page.dart`) were formatted surgically to avoid noisy whole-file reformatting hunks.
   - Pre-existing untracked workspace paths (`android/build/`, `flutter_06.png`, `incoming/`, `test/theme/widgets/failures/`, `tmp/`, `.build/`) were left completely untouched.
   - The four trailing Markdown hard-break spaces in `docs/CODEBASE_COMPREHENSIVE_REVIEW.md` noted during Pass 1 were cleaned up alongside annotating Pass 1 + Pass 2 completion status.

---

## 2. Prioritized Findings Addressed in Pass 2 (`P01`–`P08`)

| ID | Priority | Category | Defect / Structural Debt Verified Against `c703947` | Fix & Enforced Invariant | Commit |
| :--- | :---: | :--- | :--- | :--- | :---: |
| **P08** | Medium | Structural | `DatabaseHelper` still owned inline SQL for `flow_defaults` / `flow_default_methods`, and `TrainPage` / `Train2Page` duplicated raw `SharedPreferences` `train.optimized_*` reads and writes. | Extracted `FlowDefaultsDao` (`lib/db/flow_defaults_dao.dart`) and `OptimizedWorkoutPreferences` (`lib/services/optimized_workout_preferences.dart`) backed by `SerialAsyncQueue` + `writePreferences` compensation. | `18a0aee` |
| **P01** | High | Data Integrity | Saving/renaming/deleting default or preset progression rules updated method rows and flowchart graph JSON across multiple tables without a single SQLite transaction; mid-flight failures left dangling graph edge references or partial rule writes. | Widened `PresetAutoSettingsDao` & `PresetFlowMethodsDao` to `DatabaseExecutor`, deduplicated `FlowDefinition.renameMethodReferences` / `removeMethodReferences`, added transactional `save*Atomic`, `rename*References`, and `delete*AndReferences` DAO methods, and wired `FlowMethodsPage` + `AppRepository` through them. | `a436e82` |
| **P02** | High | State / Lifecycle | `PresetSession` maintained 6 parallel mutable lists (`exercises`, `cardTypes`, `_originalDefIds`, `_presetExerciseIds`, `_presetParentSetIds`, `_presetChildSetIds`); missing cardio rows or unknown exercise types appended partial metadata causing index skew; lacked reload-version and disposal guards; lacked `SafeFailure` load error classification. | Consolidated internal storage onto a single `List<_PresetExerciseEntry>` with unmodifiable `ListBase` projections, skipped orphan cardio/unknown rows cleanly, staged `_loadPreset()` locally before atomic publication, guarded stale reloads (`_loadVersion`) and `dispose()`, decoded `manual_selection_json` defensively, and exposed `SafeFailure? loadFailure`. | `ded7556` |
| **P03** | Medium | Async Recovery | `SyncDiagnosticsStore` and `DiagnosticsRelayReceiptStore` chained `_writeQueue = _writeQueue.then(...)` without error recovery (one failed `SharedPreferences` write permanently poisoned all future writes in the session); `ExerciseContentLocalizer` permanently cached a rejected `_bundleFuture`. | Migrated both diagnostics stores onto `SerialAsyncQueue` + `writePreferences` (with rollback compensation on failed writes) and added `_ensureBundle()` error eviction in `ExerciseContentLocalizer` so subsequent lookups retry cleanly. | `9a706d1` |
| **P04** | Low-Med | Platform Safety | `BarcodeScannerPage` invoked `_controller.switchCamera()` unawaited without `try/catch` (unlike `_toggleTorch`) and lacked `_startScanner` / `_stopScanner` error guards and `_locked` checks in `_onDetect`. | Wrapped `_switchCamera()`, `_startScanner()`, and `_stopScanner()` in `try/catch` helpers and guarded `_onDetect` when `_locked` or unmounted, while preserving `scanner.stops == 0` when `!hasPermission` across `inactive -> resumed`. | `9a706d1` |
| **P05** | Medium | Feature Parity | `Train2Page` only loaded 2 of 6 `train.optimized_*` preferences (ignoring `minSets`, `repWeightMode`, `targetRepCount`, `starterWeightIntensity`), could leave `minSets > maxSets` when lowering `maxSets`, ignored `{bool edit = false}` in `_openPreset`, failed to refresh preset summaries on return, and missed `await` on Classic manual plan creation. | Migrated `Train2Page` onto `OptimizedWorkoutPreferences`, passed `PresetDetailScreen(startInEditingMode: edit)` in `_openPreset`, incremented `_presetsRefreshToken` on return, and awaited `_openPreset(newId, edit: true)`. | `9a706d1` |
| **P06** | High | Concurrency & Sync | `SelectedProfile` and `NutritionProfile` initialized independently in `main.dart`, racing to seed duplicate `'General'` profiles on empty DB startup and leaving `NutritionProfile` out of sync on profile switch/rename/create/delete; rapid `SelectedProfile.toggleEquipment` calls could issue duplicate removes or overwrite a newly selected profile. | Serialized `SelectedProfile.toggleEquipment` via `_equipmentWrites` (`SerialAsyncQueue`) with `_selectionVersion` + `profileId` checks, added `NutritionProfile.bindSelectedProfile(SelectedProfile)` (preserving standalone test mode), and wired `ChangeNotifierProxyProvider<SelectedProfile, NutritionProfile>` in `lib/main.dart`. | `4a2f42e` |
| **P07** | High | Backup Import & Perf | (1) `DatabaseHelper.importDatabase` ran `PRAGMA table_info($table)` once **per row** instead of once **per table**; (2) `AppRepository.importDatabase` left static exercise muscle/bodypart/allocation `Future` caches stale; (3) `DatabaseSettingsPage` and `AppSettingsPage` neither paused `ActiveSession` draft saves during DB replacement nor reloaded `ActiveSession`, `SelectedProfile`, and `NutritionProfile` post-import. | Hoisted `_tableColumnInfo(txn, table)` outside the row loop (`O(1)` per table), called `clearExerciseAnalysisCache()` in `AppRepository.importDatabase`, added `ActiveSession.prepareForDatabaseReplace` / `abortDatabaseReplace` / `reloadFromDatabase` + `NutritionProfile.reloadFromDatabase`, and coordinated all three providers in both settings import flows. | `4a2f42e` |

---

## 3. Commit-by-Commit Audit Guide (For Peer-Agent Review)

Every commit on `codex/codebase-maintainability` after `c703947` is self-contained, compiles cleanly, and passes its focused regression suite.

### Commit 1 — `18a0aee` (`Extract FlowDefaultsDao and OptimizedWorkoutPreferences`)
- **Type**: Structural extraction only (`P08`).
- **Files Changed (`5`)**:
  - `lib/db/flow_defaults_dao.dart` *(new)*
  - `lib/db/database_helper.dart`
  - `lib/services/optimized_workout_preferences.dart` *(new)*
  - `lib/screens/exercise/train_page.dart`
  - `test/services/optimized_workout_preferences_test.dart` *(new)*
- **What to Verify**:
  - `DatabaseHelper` public method names and return shapes for `getDefaultFlow`, `saveDefaultFlow`, `fetchDefaultFlowMethods`, `upsertDefaultFlowMethod`, and `deleteDefaultFlowMethod` are unchanged.
  - `OptimizedWorkoutPreferences` preserves the exact `SharedPreferences` keys (`train.optimized_session_minutes`, `train.optimized_min_sets`, `train.optimized_max_sets`, `train.optimized_rep_weight_mode`, `train.optimized_target_reps`, `train.optimized_starter_intensity`), clamps `minSetsPerExercise <= maxSetsPerExercise`, serializes concurrent saves via `SerialAsyncQueue`, and rolls back earlier keys via `writePreferences` if a later key write fails.

### Commit 2 — `a436e82` (`Save flow default rules and graph reference updates atomically`)
- **Type**: Transactional data-integrity fix (`P01`).
- **Files Changed (`9`)**:
  - `lib/models/preset_models.dart`
  - `lib/db/flow_defaults_dao.dart`
  - `lib/db/preset_auto_settings_dao.dart`
  - `lib/db/preset_flow_methods_dao.dart`
  - `lib/db/database_helper.dart`
  - `lib/repositories/app_repository.dart`
  - `lib/screens/profile/settings/flow_methods_page.dart`
  - `test/db/flow_defaults_dao_test.dart` *(new)*
  - `test/db/preset_flow_dao_test.dart`
- **What to Verify**:
  - Every SQL read and write inside `saveDefaultFlowMethodAtomic`, `renameDefaultFlowMethodReferences`, `deleteDefaultFlowMethodAndReferences`, `PresetFlowMethodsDao.saveMethodAtomic`, `renameMethodReferences`, and `deleteMethodAndReferences` uses the active `Transaction` (`DatabaseExecutor`), never re-entering the root `Database` handle while a transaction is open.
  - When `previousName != null && previousName != method.name`, renaming a rule deletes the old `(type, previousName)` row, upserts the new row, and rewrites all matching graph edge `label` references in a single transaction.
  - When `previousName == null || previousName == method.name`, `AppRepository.saveDefaultFlowMethod` and `saveFlowMethod` delegate to `upsertDefaultFlowMethod` / `upsertFlowMethod` so existing fake-repository widget tests remain compatible while real SQLite still executes inside a transaction.
  - `test/db/flow_defaults_dao_test.dart` and `test/db/preset_flow_dao_test.dart` install SQLite `BEFORE INSERT` and `BEFORE DELETE` `RAISE(ABORT, ...)` triggers to prove complete rollback of both method rows and graph JSON on mid-flight failures.

### Commit 3 — `ded7556` (`Guard PresetSession against missing details, stale reloads, and disposal`)
- **Type**: Provider structural invariant & async lifecycle fix (`P02`).
- **Files Changed (`2`)**:
  - `lib/providers/preset_session.dart`
  - `test/providers/preset_session_lifecycle_test.dart` *(new)*
- **What to Verify**:
  - All 6 positional collections (`exercises`, `cardTypes`, `presetExerciseIds`, `presetParentSetIds`, `presetChildSetIds`, and `definitionIdForExercise(i)`) project from the single `List<_PresetExerciseEntry> _entries` via read-only `_PresetEntryListView<T>` wrappers; callers cannot mutate those getters directly to desynchronize indices.
  - In `_loadPreset()`, if `type == 'cardio'` and `fetchPresetCardio(peId)` returns `null`, or if `type` is unrecognized, no entry is appended (previously `cardTypes` and `_presetExerciseIds` grew while `exercises` did not).
  - `_loadPreset()` stages into local variables (`stagedEntries`, `stagedPresetName`, `stagedIsAutomatic`, etc.) and checks `if (!_isCurrentLoad(version)) return;` after every `await`, so overlapping `discardChanges()` / `saveChanges()` reloads or mid-load `dispose()` calls never publish partial or stale state.
  - Initial `ready` runs `_loadPreset(rethrowErrors: false)` and records `SafeFailure? loadFailure` without emitting unhandled async zone errors; `discardChanges()` runs `_loadPreset(rethrowErrors: true)` and preserves existing in-memory `_entries` if the reload fails.

### Commit 4 — `9a706d1` (`Recover failed diagnostics and localizer futures and harden scanner and Train2`)
- **Type**: Async error recovery, platform safety, and training-hub parity (`P03`, `P04`, `P05`).
- **Files Changed (`8`)**:
  - `lib/services/diagnostics_service.dart`
  - `lib/services/exercise_content_localizer.dart`
  - `lib/screens/nutrition/barcode_scanner_page.dart`
  - `lib/screens/exercise/train2_page.dart`
  - `test/services/diagnostics_service_test.dart`
  - `test/services/exercise_content_localizer_test.dart`
  - `test/theme/barcode_scanner_route_test.dart`
  - `test/screens/train2_settings_and_preset_edit_test.dart` *(new)*
- **What to Verify**:
  - `SyncDiagnosticsStore` and `DiagnosticsRelayReceiptStore` use `SerialAsyncQueue` + `writePreferences`; injecting a `SharedPreferences` write failure throws to the caller, preserves prior stored state, and allows the very next `.record(...)` / `.add(...)` / `.clear()` / `.replace(...)` call to succeed.
  - `ExerciseContentLocalizer._ensureBundle()` clears `_bundleFuture = null` on failure and rethrows with `Error.throwWithStackTrace`, allowing subsequent localization calls to reload the asset bundle.
  - `BarcodeScannerPage` catches camera errors in `_switchCamera()`, `_startScanner()`, and `_stopScanner()`, ignores duplicate detections once `_locked == true`, and keeps `scanner.stops == 0` when `AppLifecycleState.inactive` fires before camera permission is granted (`!_controller.value.hasPermission`).
  - `Train2Page` loads and saves via `OptimizedWorkoutPreferences` (feeding all 6 settings into `SessionSpec`), forwards `startInEditingMode: edit` to `PresetDetailScreen`, increments `_presetsRefreshToken` on return, and awaits `_openPreset(newId, edit: true)` in Classic manual plan creation.

### Commit 5 — `4a2f42e` (`Synchronize profile providers, cache import table metadata, and reload state after import`)
- **Type**: Provider synchronization, concurrency serialization, import `O(1)` metadata caching, and post-import live state reload (`P06`, `P07`).
- **Files Changed (`11`)**:
  - `lib/providers/selected_profile.dart`
  - `lib/providers/nutrition_profile.dart`
  - `lib/main.dart`
  - `lib/db/database_helper.dart`
  - `lib/repositories/app_repository.dart`
  - `lib/providers/durable_active_session.dart`
  - `lib/screens/profile/settings/database_settings_page.dart`
  - `lib/screens/profile/settings/app_settings_page.dart`
  - `test/providers/selected_profile_race_test.dart`
  - `test/providers/profile_sync_and_import_reload_test.dart` *(new)*
  - `test/database_import_contract_test.dart`
- **What to Verify**:
  - `SelectedProfile.toggleEquipment` runs inside `_equipmentWrites.run(...)` (`SerialAsyncQueue`), re-evaluates `equipment.any(...)` inside the serialized critical section (so rapid double-taps remove then re-add instead of issuing duplicate removes), and aborts publication if `_selectionVersion` or `currentProfile?.id` changed mid-flight.
  - `lib/main.dart` registers `SelectedProfile` before `NutritionProfile` and binds them via `ChangeNotifierProxyProvider<SelectedProfile, NutritionProfile>`, while keeping exact substrings required by `test/repository_injection_contract_test.dart`. Standalone `NutritionProfile(repository: repo)` instances in isolated widget tests continue working without a `SelectedProfile` ancestor.
  - On empty-DB cold start, bound `NutritionProfile` awaits `selectedProfile.ready` and reuses the single `'General'` profile seeded via `saveGymProfileAtomic` instead of racing `createProfile('General')`.
  - `DatabaseHelper.importDatabase` calls `_tableColumnInfo(txn, table)` once per non-empty table before `for (final row in rows)` (`O(1)` per table; verified in `profile_sync_and_import_reload_test.dart` across both 10-row and 25-row imports).
  - `AppRepository.importDatabase` invokes `clearExerciseAnalysisCache()` after `_dbHelper.importDatabase(...)` completes.
  - Both `DatabaseSettingsPage._importDatabase` and `AppSettingsPage._importDatabase` look up optional `ActiveSession`, `SelectedProfile`, and `NutritionProfile` via `Provider.of<T>(context, listen: false)` (catching `ProviderNotFoundException` so standalone route tests remain valid), call `await activeSession?.prepareForDatabaseReplace()` before `importDatabase`, call `activeSession?.abortDatabaseReplace()` if `importDatabase` throws, and run `reloadFromDatabase()` / `loadProfiles()` on success.

---

## 4. Verification Matrix — 2026-10-29

All checks were executed from `E:\projects\env_test` using the pinned Flutter `3.47.5` toolchain (`E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat` and `dart.bat`) and Node.js.

| Check | Command | Result |
| :--- | :--- | :--- |
| **Full Flutter unit & widget suite** | `flutter test --no-pub --concurrency=4 --reporter expanded` | **2,486 passed, zero failures**, 14m 31s (`+24` new regression/contract cases over Pass 1's `2,462`; local log at `.build/maintainability/pass2-final-tests.log`) |
| **Pass 2 new & extended regression suites** | Focused runs across `optimized_workout_preferences_test`, `flow_defaults_dao_test`, `preset_flow_dao_test`, `preset_session_lifecycle_test`, `diagnostics_service_test`, `exercise_content_localizer_test`, `barcode_scanner_route_test`, `train2_settings_and_preset_edit_test`, `selected_profile_race_test`, `profile_sync_and_import_reload_test` | **All passed, zero failures** |
| **Localization generation freshness** | `flutter gen-l10n` + `git status --porcelain -- lib/l10n/generated` | **Passed** (0 modified/untracked files) |
| **Source, test, integration & driver analysis** | `dart analyze lib test integration_test test_driver` | **Exit 0 — 79 informational notices, 0 warnings, 0 errors** (matches Pass 1 baseline) |
| **Root tools & `catalog_builder` analysis** | `dart analyze tools/...` and `dart analyze bin tool` in `tools/catalog_builder` | **No issues found** |
| **Theme style inventory check** | `dart run tools/theme_style_inventory.dart --check` | **Passed** (`318` Dart files, `4,382` candidates: `144` allowlisted, `3,595` migrated, `643` pending, `0` unassigned) |
| **Theme style ratchet enforcement** | `dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json` | **Passed** (all 18 protected files unchanged) |
| **Content-environment preflight** | `dart run tools/content_environment_check.dart --source assets/content/content_environments.json --target development` and `--target production --locked` | **Both passed** (`2` configured environments validated) |
| **Compile-time content & Neo release variants** | `content_environment_compile_time_test.dart` (locked dev) + `app_theme_compile_time_test.dart` (Neo release opt-in + malformed opt-in rejection) | **All 3 compile-time variants passed** |
| **Diagnostics relay Worker suite** | `node --test services/diagnostics_relay/test/*.test.mjs` | **8 passed, 0 failed** |
| **Architectural, DI, import, privacy & safe-error contracts** | `repository_injection_contract_test`, `database_import_contract_test`, `database_export_privacy_contract_test`, `settings_residue_contract_test`, `safe_error_handling_contract_test` | **All passed, zero failures** |
| **Git whitespace / patch hygiene** | `git diff --check 6331ccd..HEAD` | **Passed** (0 whitespace errors across all Pass 1 + Pass 2 commits, including `docs/CODEBASE_COMPREHENSIVE_REVIEW.md`) |

---

## 5. Quick Re-Verification Script for Reviewing Agent

To audit Pass 2 end-to-end from PowerShell in `E:\projects\env_test`:

```powershell
$Flutter = 'E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat'
$Dart    = 'E:\tools\flutter_sdks\3.47.5\flutter\bin\dart.bat'

# 1. Inspect Pass 2 commit boundaries and whitespace cleanliness
git log c703947..HEAD --oneline --stat
git diff --check 6331ccd..HEAD

# 2. Verify zero changes to ratcheted theme files, schema, and generated l10n
git diff --name-only c703947..HEAD -- lib/db/schema.dart lib/db/schema_latest.sql lib/l10n docs/theme-style-ratchet.json docs/theme-style-inventory.json
& $Dart run tools/theme_style_inventory.dart --check
& $Dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json

# 3. Run static analysis across app, tests, and tooling
& $Dart analyze lib test integration_test test_driver
& $Dart analyze tools/content_environment_check.dart tools/content_pipeline.dart tools/shared_media_pipeline.dart tools/theme_style_inventory.dart tools/theme_style_ratchet.dart

# 4. Run all Pass 2 targeted failure-injection, race, lifecycle, and contract tests
& $Flutter test --no-pub `
  test/services/optimized_workout_preferences_test.dart `
  test/db/flow_defaults_dao_test.dart `
  test/db/preset_flow_dao_test.dart `
  test/providers/preset_session_lifecycle_test.dart `
  test/services/diagnostics_service_test.dart `
  test/services/exercise_content_localizer_test.dart `
  test/theme/barcode_scanner_route_test.dart `
  test/screens/train2_settings_and_preset_edit_test.dart `
  test/providers/selected_profile_race_test.dart `
  test/providers/profile_sync_and_import_reload_test.dart `
  test/database_import_contract_test.dart `
  test/database_export_privacy_contract_test.dart `
  test/repository_injection_contract_test.dart `
  test/theme/settings_residue_contract_test.dart `
  test/localization/safe_error_handling_contract_test.dart
```

---

## 6. Remaining Backlog & Unverified Qualification Boundaries

1. **Monolith Decomposition Along Domain Boundaries (Next Structural Phase)**:
   - `lib/screens/onboarding_flow.dart` (4,553 lines), `lib/widgets/exercise_detail_sheet.dart` (4,400 lines), `lib/widgets/health_trends_section.dart` (4,255 lines), `lib/widgets/exercise_progress_section.dart` (3,550 lines), `lib/screens/profile/settings/exercise_editor_screen.dart` (3,415 lines), `lib/widgets/workout_metric_chart_card.dart` (3,397 lines), and `lib/services/preset_generation_service.dart` (2,358 lines) remain intact for dedicated structural decomposition batches that preserve canonical entry paths and update `docs/theme-style-ratchet.json` only where enrolled files are intentionally split.
2. **Batch Loading & Locale Asset Splitting (Optional Perf Follow-Ups)**:
   - `PresetSession._loadPreset` is now structurally skew-proof, staged, versioned, and disposal-safe, though per-exercise `fetchDefinitionInfo` / `fetchPresetSets` queries can still be batched via `IN (...)` queries for very large presets.
   - `ExerciseContentLocalizer` now recovers cleanly from transient load failures, though `assets/exercise_content_localizations.json` (~986 KB) is still decoded as a combined multi-locale bundle on first non-English lookup.
3. **Typed Query DTOs & Deprecated Flutter Widget Migrations**:
   - Remaining raw `Map<String, dynamic>` query return shapes in `AppRepository` and the 79 baseline `info` notices (primarily Flutter 3.32–3.41 `RadioGroup`, `TickerMode.valuesOf`, `ReorderableListView.onReorderItem`, and `SemanticsData.flagsCollection` migrations) remain separate, focused follow-up candidates.
4. **Device, Native Release, & Deployed Infrastructure Qualification**:
   - Consistent with Pass 1, no physical-device camera/navigation runs, native Android/iOS/desktop release builds, deployed Cloudflare Worker checks, or on-device frame-timing profiles were executed during this headless pass; those remain required before shipping a production release.

## 7. Peer-review corrections — 2026-10-30

The independent review of `76d1405` reproduced four gaps despite the earlier
green suite. The following corrections supersede the relevant completion claims
above; the earlier 2,486-test full-suite result remains historical.

| Finding | Correction | Regression evidence |
| --- | --- | --- |
| R1: A post-commit maintenance error could resume the old workout and overwrite the imported draft. | `DatabaseImportCommittedException` marks failures after the authoritative transaction commits. Repository analysis caches are invalidated for that outcome. Both settings import entry points use `database_import_coordinator.dart` to reconcile live state before reporting the maintenance failure; only pre-commit failure resumes the old draft. Existing localized copy now distinguishes successful import from failed maintenance. | `test/services/database_import_coordinator_test.dart` injects a SQLite recipe-cache rebuild failure after commitment, verifies cache invalidation and restored live state, and confirms the imported draft survives app pause. A separate case checks pre-commit rejection resumes the original session. |
| R2: Queued equipment actions captured the profile too late. | Capture profile ID/version before enqueueing; cancel a stale queued action before it can write. | `selected_profile_race_test.dart` queues two actions on A, switches to B while the first write is pending, then checks that B's equipment is unchanged. |
| R3: A failed initial preset load still allowed a destructive partial save. | Explicit loaded/loading/failure state; guard editing, save and start APIs until a complete load succeeds. The detail route shows the existing safe error/retry component and hides editing while unloaded. Train and Train2 generation callers check the load outcome. Later failed reloads retain the known draft. | `preset_session_lifecycle_test.dart` checks failed/pending initial loading, zero writes, retry recovery and later draft preservation. `preset_detail_screen_theme_test.dart` verifies failure/retry across Classic, Expressive and Neo in light/dark modes. |
| R4: Old favorites responses or failed optimistic writes could affect another profile. | Guard publication by profile identity, profile generation and request sequence; invalidate outstanding reads on switches/database reload. Scope pending favorite operations to the originating profile and reject stale rollback. | `profile_sync_and_import_reload_test.dart` covers reversed profile responses, same-ID database replacement, and a late failed favorite toggle after switching profiles. |

Validation for these corrections:

- Dedicated regression/import/privacy/DI/food-editor run: **74 passed**.
- Compatibility run covering preset settings, manual plans, Train2, onboarding,
  durable workouts, preset persistence and theme contracts: **120 passed**.
  The runs overlap; their counts are not summed. The latter run also includes
  the final late-favorite-write regression.
- Repository/root-tool analysis passed with **0 errors, 0 warnings and the same
  79 informational notices**. Inventory passed (319 Dart files, 4,382 candidates)
  and ratchet enforcement passed for the same 18 protected source files.
  `git diff --check` passed. Results are retained under
  `.build/maintainability/review-fixes-*`.
- Changed code is formatted with the pinned SDK; unrelated legacy formatting is
  excluded from the large-file diffs. Normal approved page layouts and motion,
  schema, localization catalogs and preview data are preserved. The new visible
  states are the necessary initial-load/error/retry handling and accurate import
  maintenance feedback.
- The initial focused follow-up did not include a full-suite rerun or commit.
  The additional review and requested checkpoint validation are recorded below.
  Device builds/navigation, screenshots, preview-data resets, dependency upgrades
  and pushes remain outside this follow-up.

### Additional handoff review corrections

- Updated `settings_residue_contract_test.dart` to enforce the shared import
  coordinator, JSON argument ownership and committed-error handling in both
  settings callers. The original contract failure was a stale direct-call marker;
  the replacement retains explicit ownership checks.
- Recovery steps now run independently, so a failed profile reload cannot skip
  nutrition recovery. An existing maintenance failure remains the primary thrown
  exception; secondary failures log only the owner and exception type. Tests
  cover a mid-sequence reload failure and combined maintenance/reload failures.
- Profile invalidation clears totals, goals, meals and prior errors together with
  favorites. A listener-based regression holds the new profile's totals pending
  and checks that every notification is free of the previous profile's data.
- Both training hubs dispose their temporary `PresetSession` in `finally` after
  cloning its workout snapshot, including failed loads and early returns.
- Loaded and unloaded preset routes share the pop handler. Four widget cases
  verify toolbar/system back and `closeAfterSave` true/false, preserving the
  `PresetDetailResult.discarded` contract for the onboarding caller.

The targeted handoff run passed **43 checks** and the separate contract sweep
passed **172 checks across 43 contract test files**, including the previously
failing settings residue contract.

### Final checkpoint validation — 2026-10-30

| Check | Final result |
| --- | --- |
| Complete Flutter unit/widget suite, `--no-pub --concurrency=4 --reporter expanded` | **2,507 passed, 0 failed**, 15m 33s. |
| Separate contract sweep | **172 passed** across all 43 `*contract_test.dart` files. |
| Targeted handoff regression checks | **43 passed**; overlaps with both suites above. |
| Repository, test, integration/driver source and root-tool analysis | Exit 0, **0 errors, 0 warnings**, same 79 informational notices. |
| Catalog-builder `bin` / `tool` analysis | No issues; existing dependencies used. |
| Theme inventory / ratchet enforcement | Passed: 319 Dart files / 4,382 candidates; same 18 protected source files, none modified. |
| Diagnostics relay Node tests | **8 passed**, 0 failed. |
| Development and locked-production content-environment checks | Both passed. |
| Working/staged diff whitespace checks | Passed; only explicitly selected follow-up files enter the checkpoint. |

Logs are retained locally under `.build/maintainability/review-followup-*`.
Production and test code did not change after the complete suite started; only
this audit record was finalized afterward. Overlapping run counts are not summed.
The checkpoint includes the original R1–R4 fixes and all additional handoff
corrections above. Unrelated untracked artifacts remain preserved. No device or
release build, preview-data reset, dependency fetch/upgrade or push was performed.
