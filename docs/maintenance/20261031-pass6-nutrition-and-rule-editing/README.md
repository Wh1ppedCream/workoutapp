# Pass 6 — nutrition safety, rule editing and Android compatibility

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fe6ed3e`.
Work is performed in the existing checkout, preserving approved presentation,
stored formats, preview/user data and unrelated files. No push is included.

## Authorized sequence

| Batch | Scope | State |
| --- | --- | --- |
| 1 | Full pinned-SDK baseline and failure investigation before production edits | Complete: 2,578 tests pass; clean analysis |
| 2 | Focused Nutrition transaction/failure tests; correct demonstrated single-entry failure risks while retaining item-by-item batches | Complete: 44 focused tests pass |
| 3a | Shared typed Flow Methods editing parameters with compatibility tests | Complete: 36 focused tests pass |
| 3b | Standalone preset-rule dialog and properly scoped shared controls, preserving rendering and public imports | Complete: 125 focused checks pass |
| 4 | Reassess further extraction against demonstrated responsibility/testability benefits | Complete: no additional split justified in this pass |
| 5 | Independent Android compatibility review/change and build/native validation | Complete: debug and arm64 release builds; Pixel 7 smoke and data comparison pass |

Floating-action coordination on Nutrition/Train2 remains explicitly deferred.
No screen redesign, global state-management migration, arbitrary file-size
target, schema migration, preview reseed or destructive cleanup is authorized.

## Baseline

The pinned SDK check reports Flutter **3.47.5** and Dart **3.13.4**.
The full-suite run started against `fe6ed3e`, before production or test edits:

```powershell
.\tools\tonos.ps1 check
.\tools\tonos.ps1 flutter test --no-pub
.\tools\tonos.ps1 dart analyze --fatal-infos lib test integration_test test_driver tools
```

Local logs: `.build/maintainability/pass6-baseline-tests.log` and
`.build/maintainability/pass6-baseline-analysis.log`. Final results and exact
checkpoint IDs will be recorded as the batches finish. Focused, variant and
whole-suite counts overlap and must not be added together.

The baseline finished with **2,578 passed, zero failures**, in **18m 27s** on
the test clock. Full source/test/integration/tool analysis reported **zero
errors, warnings and infos**. This is a fresh complete run of `fe6ed3e`, closing
the earlier Pass 5 full-run/focused-recheck qualification gap. No production
or test source was edited before this baseline completed.

Baseline checkpoint: **ac5f504**.

## Nutrition failure hardening

Eight new tests use the production schema in an in-memory SQLite database,
with SQL triggers injecting failures after the primary write. Before the fix,
three success/outer-transaction cases passed and **five late-failure cases
failed**: later food insertion, usage statistics, recipe insertion, moving an
entry between days, and soft deletion could leave committed diary changes
while returning an error.

Root `addDiaryFood`, `addDiaryRecipe`, `updateDiaryEntry` and `deleteDiaryEntry`
now start one transaction encompassing their existing bodies. Executor-bound
private operations retain all SQL, nutrient snapshots, units, dates and
calculation policy. A supplied transaction is reused; errors must escape the
outer callback for the caller's transaction to roll back. No nested transaction
or parent-database access is introduced.

| Boundary | Ownership after this change |
| --- | --- |
| Single diary operation through a root DAO | Entry, affected day caches, and food usage succeed or roll back together. |
| `NutritionDao.inTransaction` | The outer caller owns commit/rollback; all dependent reads/writes use its executor. |
| Provider `addFoodsBatch` | Existing item-by-item calls are retained. A failed later item does not undo earlier successful items, and requests are not automatically replayed. |
| Food customization | Existing caller-owned transaction and recipe-cache participation remain intact. |
| Direct recipe creation/editing and other catalog operations | Existing boundaries remain: for example, root recipe shell/ingredient writes precede a separate cache rebuild. This pass does not claim all Nutrition DAO operations are atomic. |

Qualification: **44 focused tests passed**, including all eight new SQL cases,
food-customization rollback, provider import/synchronization and food-logging
behavior across themes. Scoped analysis and formatting pass. An AST-token
comparison confirms that all **80 pre-existing method bodies**, including the
four moved private bodies, are unchanged apart from formatting, line endings
and optional trailing commas. Public signatures and schema are preserved.

Local logs: `pass6-diary-red.log`, `pass6-diary-tests.log`,
`pass6-diary-analysis.log` and `pass6-diary-body-parity.log`, under
`.build/maintainability/`. No live or preview database was used.

Nutrition checkpoint: **f02540f**.

## Shared rule editing values

`FlowMethodDraft` is an immutable, widget-independent editing model with typed
weight, rep, explicit-set, copied-set and delete-set variants. Both default-rule
and preset-rule save paths use its shared parser and legacy parameter encoder.
Persisted `FlowMethod` decoding, repository APIs, save transactions and rule
propagation are unchanged. There is no database-format migration.

Compatibility tests protect JSON keys and numeric types, name trimming, blank
and invalid-field fallbacks, ignored unrelated fields, negative legacy copy
indices, Expressive copy-source overrides, delete-set encoding and detached
parameter maps. Parsing retains existing non-finite handling; validation stays
with the existing callers, preserving theme-specific behavior. Controllers,
prefill text and every rendering method remain unchanged in this batch.

Qualification: **36 focused model/dialog/flow-page tests passed**, including
Classic/Neo controls, Expressive light/dark styling, copy-source validation,
large-text/keyboard layouts, saved values and scope/plan grouping. Scoped
analysis and formatting pass. Logs: `pass6-rule-model-tests.log` and
`pass6-rule-model-analysis.log` under `.build/maintainability/`.

Typed model checkpoint: **a691b0e**.

## Preset-rule dialog extraction

The preset-rule dialog now lives in
`lib/screens/profile/settings/flow_methods/add_preset_method_dialog.dart`.
Its controllers, copy-source selection and save lifecycle remain local to the
dialog. `rule_editor_controls.dart` owns the anchored choice menu, its animation
and overlay lifecycle, and the shared add-set mode control. The page retains
scope loading, default-rule editing and rule propagation. The original page
re-exports `AddPresetMethodDialog`, its state and `AddSetMode`, preserving
existing import paths. Neither extracted file imports the page.

An AST-token comparison confirms **61 function/method/constructor bodies** are
unchanged except the three necessary helper renames and formatting. A key
parameter was added to the newly public choice widget; rendering, dimensions,
text, colors, gestures and animation constants are unchanged.

Source-reading contracts now inspect the actual standalone owners rather than
following every import. Two exact-file inventory rules retain the moved
recipes' existing status and kind restrictions. The **56 migrated Flow Methods
recipes** retain their exact kind totals across the three files. Five pending
findings move to their actual owners; their combined snippet digest is identical
to the old page's digest. No debt was approved or removed: inventory remains
**4,382 candidates: 3,595 migrated, 144 allowlisted, 643 pending**.

Qualification: **125 focused checks passed**, including rule parsing, dialog
behavior, large-text/keyboard layouts, existing import compatibility, field
ownership and inventory contracts. Scoped analysis is clean; the inventory
check and unchanged **18-file** style ratchet pass. Local logs:
`pass6-rule-extraction-tests.log`, `pass6-rule-extraction-analysis.log`,
`pass6-rule-extraction-parity.log`, `pass6-inventory.log`, `pass6-ratchet.log`.

Dialog/control checkpoint: **29acde1**.

## Further-extraction decision

The reassessment does not justify another mandatory controller, ViewModel or
DAO layer in this pass. The pure editing model has independently testable data
rules; the dialog owns its transient controllers and save lifecycle; the menu
owns its overlay/animation lifecycle. The page's remaining scope loading and
default-rule propagation still share page state and navigation. Moving them
solely to reduce line counts would introduce interfaces without demonstrating
a second caller or simpler testing seam.

Likewise, Nutrition's scoped executor now supplies a small, explicit transaction
boundary with failure-injection coverage. A wholesale DAO split would add
delegation without resolving a demonstrated defect. Direct recipe/catalog
atomicity remains a separately bounded future topic, not an implied guarantee
from the diary fix. Reconsider a split when a specific responsibility gains a
second consumer, independent lifecycle, or a failure that existing seams cannot
test clearly. The two approved Train presentations and their existing shared
launch services are retained. Nutrition/Train2 floating-action coordination is
still deferred at the user's request.

## Android compatibility batch

This is an independent tooling change after the Dart checkpoints. The selected
versions match the actual Flutter **3.47.5** templates in the pinned local SDK:

| Component | Before | Selected |
| --- | --- | --- |
| Gradle wrapper | 8.14.5 | 9.3.1, official distribution SHA-256 pinned |
| Android Gradle Plugin | 8.11.1 | 9.1.0 |
| Kotlin Gradle Plugin | 2.2.21 | 2.4.0 |
| Java/Kotlin output target | 11 | 11, unchanged; typed `compilerOptions` replaces `kotlinOptions` |
| CI Java / local Java | 17 / 21 | Unchanged |
| NDK | 28.2.13676358 | Unchanged |

The [AGP compatibility table](https://developer.android.com/build/releases/agp-9-1-0-release-notes)
requires Gradle 9.3.1 and JDK 17 for this AGP series. The
[Kotlin compatibility table](https://kotlinlang.org/docs/gradle-configure-project.html)
includes AGP 9.1.0 and Gradle 9.3.1 within KGP 2.4.0's supported ranges.
The exact Flutter template combination was preferred over upgrading to unrelated
newer releases. The official Gradle distribution checksum is
`b266d5ff6b90eada6dc3b20cb090e3731302e553a27c5d3e4df1f0d76beaff06`.

`android.builtInKotlin=false` and `android.newDsl=false` are intentionally
retained. Locked scanner, package-info and preferences plugins still apply
legacy KGP. The file-picker module opts in individually as described below.
[Flutter's migration guidance](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
documents this compatibility mode; fully enabling the new DSL requires auditing
and migrating the complete native-plugin set together. This is a future
compatibility limit, not a reason to edit the Pub cache or upgrade dependencies
in this batch. Package locks, SDK levels, application IDs, isolation checks and
signing policy remain unchanged.

Gradle's previous potential 8 GB heap plus 4 GB metaspace was disproportionate
to this 12 GB workstation. The selected defaults bound the heap to 3 GB,
metaspace to 1 GB and workers to two; code-cache reservation is 256 MB. The
separate Kotlin compiler daemon is limited to a 1 GB heap and 512 MB metaspace,
instead of inheriting Gradle's larger limits, using the
[documented Kotlin daemon property](https://kotlinlang.org/docs/gradle-compilation-and-caches.html#kotlin-daemon-jvmargs-property).
Heavy whole-suite and native builds run sequentially. Build and Pixel 7 results will
be recorded below after validation; configuration alone is not qualification.

Wrapper generation is confirmed successful with the downloaded Gradle 9.3.1
distribution runner. The initial Gradle task succeeded, but updating the running
Windows batch file produced a trailing shell error; repeating through the cached
distribution executable exited zero (**2m 22s**, all five tasks up-to-date).
The regenerated wrapper independently reports version 9.3.1. Wrapper scripts
and JAR remain generated/ignored under the repository's existing Android policy;
the tracked properties pin version and distribution checksum.

The first Java download timed out; the official distribution was fetched into
the local cache and verified against the pinned SHA-256. Native validation uses
process-local `JAVA_TOOL_OPTIONS=-Djava.net.preferIPv6Addresses=true`, after
read-only HTTPS probes to Google, Maven Central and Gradle succeeded. No TLS
verification, dependency validation or security check was disabled, and no
global network configuration was changed.

The first preview build exposed Kotlin incremental-cache failures when
`package_info_plus` and `mobile_scanner` sources on C: were relativized against
the checkout on E:. That run failed; its log is preserved as
`pass6-preview-incremental-failure.log`. The documented
[`kotlin.incremental=false` setting](https://kotlinlang.org/docs/gradle-compilation-and-caches.html#incremental-compilation)
now avoids this cross-volume cache path. Gradle task up-to-date checks still
apply; when native Kotlin sources change, compilation is non-incremental.
This favors reliable Windows builds over partial native-source compilation.
No manual cache deletion, Pub-cache edits or dependency upgrades are involved.

A second build cleared the incremental-cache failure but exposed a mixed-mode
plugin issue (`pass6-preview-picker-failure.log`): file_picker **11.0.2** declares
legacy KGP on its build classpath, yet deliberately does not apply it on AGP 9.
It therefore expects built-in Kotlin, which the global compatibility flag had
disabled. Its Kotlin entry class was absent, breaking the generated registrant.
The root Android script now opts **only `file_picker`** into
`com.android.built-in-kotlin` after its Android library plugin is applied, using
[AGP's documented module-by-module migration](https://developer.android.com/build/migrate-to-built-in-kotlin#module-by-module-migration).
Other plugins keep legacy KGP. The hook is conditional on the global opt-out;
remove it when the plugin set is fully migrated. This uses the same pinned AGP
implementation and does not patch third-party sources or package locks.
The opt-in plugin has its own implementation artifact, declared explicitly at
AGP **9.1.0** in settings. The initial hook-only attempt could not resolve that
plugin (`pass6-preview-built-in-failure.log`); declaring it follows the documented
same-version requirement.

The first arm64 release check reused the prior debug registrant because it used
`--no-pub` (`pass6-release-stale-registrant-failure.log`). In the pinned SDK,
`FlutterCommand.regeneratePlatformSpecificToolingIfApplicable` returns early
when Pub is disabled. Gradle correctly excluded the dev-only integration-test
plugin from release, while the stale Java registrant still referenced it.
The corrected workflow first runs `flutter pub get --offline --enforce-lockfile`,
then the normal Pub-enabled release build to regenerate release-specific
platform files. The lock hash is checked unchanged. No test plugin is added to
release dependencies, and no generated registrant or SDK source is patched.

## Preservation and qualification

The final whole Flutter suite passed **2,601 tests with zero failures**, in
**18m 12s** on the test clock. This includes **23 new cases** over the clean
baseline: eight transaction cases and fifteen editing-model cases. Full
`dart analyze --fatal-infos lib test integration_test test_driver tools`
reports **zero errors, warnings and infos**. Formatting of all nine changed
Dart files is clean. Four Android workflow/manifest/signing/identity checks,
all three compile-time variants (locked development content, valid Neo opt-in,
malformed Neo opt-in), development and locked-production content preflights,
the **8/8** Node relay suite, inventory and the unchanged **18-file** ratchet
also pass. These focused/variant counts overlap the whole suite and are not
additional unique tests.

Logs use `pass6-final-*`, `pass6-android-contracts.log`, `pass6-content-*.log`,
`pass6-relay.log`, `pass6-inventory.log` and `pass6-ratchet.log` under
`.build/maintainability/`. Native build/device validation is recorded separately.

### Native build and physical-device results

| Check | Result |
| --- | --- |
| Expressive debug preview | Pass: pinned build-only runner, `--no-pub`, **723.2s** after compatibility fixes. Flutter engine libraries cover arm64-v8a, armeabi-v7a and x86_64. |
| Preview identity/isolation | Pass: `com.tonos.expressivepreview`, preview/non-internal Dart defines, `tonos_expressive_preview.db`. |
| In-place Pixel 7 install | Pass: `adb install -r`; installed APK SHA-256 matches the validated build: `8e09889a721252580a5e6910dbdb8b0ebaf98a6276c3421933ad6e6b27bf4d0b`. |
| Internal signed release | Pass: normal Pub-enabled build, arm64 only, the CI content/Neo/experimental flags, **301.3s**, 47.5 MB. Manifest is `com.tonos.internal`; `apksigner verify` passes. Built, not installed or published. |
| Release artifact | SHA-256 `2f4494bd06fbd2b694cc65968fff1708eaf7eddbd19fc457dca0639225739858`. |
| Locks and credentials | `pubspec.lock` and the existing signing-properties file retain their pre-build hashes; no package upgrades or signing-material changes. |
| Final Android source contracts | **4/4** pass after the complete Android changes. |

Physical testing used **Pixel 7 `28021FDH200228`, Android 16 / API 36**, not an
emulator. The updated debug APK cold-started with the existing Expressive dark
presentation, selected gym and active workout. The existing workout opened and
returned without set edits, completion or discard. The plan-specific Add Rule
dialog rendered correctly; rule-type and Last/First/Specific copy-source menus
opened downwards, and the specific-set form remained usable. The dialog was
cancelled without saving. The native document picker opened from Database
Settings and returned on cancel without selecting or importing a file. The
barcode scanner opened, switched front/back cameras and returned without logging
food. Automatic logging was disabled only in transient form state for that
check. No screenshot of the live camera or personal file list was captured.

A fresh, stopped-app pre-install snapshot and a stopped-app post-check snapshot
were compared read-only. **All 87 table names and row counts match; 83 table
row digests are identical.** The four changed tables contain only:

- `active_workout_draft.updated_at`; workout content is identical.
- `app_meta.updated_at`.
- `exercise_media.last_accessed_at`.
- `sqlite_sequence` counters for equipment and measurement-definition seeding;
  those definition tables themselves have identical rows.

The only changed Flutter preference is
`flutter.diagnostics.content_sync.events`, the normal content-sync event log.
User settings, profiles, plans, rules, nutrition/measurement records and workout
contents are preserved. Integrity check is **ok**; schema version remains **62**.
No runtime Flutter exception, missing-plugin error or fatal exception appeared
in the checked app-process log. The app was cold-reopened and left on
**Train → Overview**, with its ongoing workout retained.

Local evidence: `pass6-preview-build.log`, `pass6-internal-release-build.log`,
`pass6-offline-pub-get.log`, `pass6-pixel7-install.log`,
`pass6-android-contracts-final.log`, `pass6-pixel7-*.jsonl` and
`pass6-pixel7-runtime-errors.log` in `.build/maintainability/`. Archives,
`pass6-20261031-data-comparison.json` and the one dark rule-dialog screenshot
are under `.build/maintainability/pixel7-smoke-20261030/`. Earlier snapshots
and failure logs are retained. Generated/private evidence is not staged.

Qualification limits: the release APK was not installed; release device behavior,
other Android OS/device combinations and Linux/Java 17 CI execution were not
verified here. Native nutrition failure injection remains in real SQLite FFI
tests rather than against user data on the phone. Native SDK/plugin deprecation
warnings remain, including legacy Kotlin/DSL and Jetifier limits before AGP 10;
the entire plugin set must be migrated together before that future upgrade.
These are distinct from the clean Dart analyzer result. Visual approvals are
unchanged; this is not a new visual-approval or release certification campaign.

### Changed files and checkpoint map

| Checkpoint | Tracked implementation / checks |
| --- | --- |
| `ac5f504` | Baseline report and combined maintenance index; no production/test edits. |
| `f02540f` | `lib/db/nutrition_dao.dart`, `test/db/nutrition_diary_transaction_test.dart`. |
| `a691b0e` | `lib/models/flow_method_draft.dart`, `test/models/flow_method_draft_test.dart`, both save paths in `flow_methods_page.dart`. |
| `29acde1` | `flow_methods_page.dart`, `flow_methods/add_preset_method_dialog.dart`, `flow_methods/rule_editor_controls.dart`; field/inventory source contracts and the two inventory ownership/baseline JSON files. |
| Final Android compatibility commit | `android/settings.gradle.kts`, `android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/gradle.properties`, `android/gradle/wrapper/gradle-wrapper.properties`; this report and the combined index. |

No further mandatory controller/DAO split was added in the conditional fourth
batch. Nutrition/Train2 floating-action coordination remains deferred. Local
checkpoints were created without pushing.

Success-state visuals, labels, field geometry, theme roles, navigation and
existing rules remain unchanged. Structural moves retain legacy entry points
where needed. Any changed failure behavior must have a targeted regression
test. Technical checks, physical-device observations and visual approval are
separate claims; this pass does not reopen approved layouts.

Unrelated paths remain untouched: `android/build/`, `flutter_06.png`,
`incoming/`, `test/theme/widgets/failures/` and `tmp/`. Existing local Codex
checkpoint-ref damage reported previously is not repaired; commits use
command-local `gc.auto=0`.
