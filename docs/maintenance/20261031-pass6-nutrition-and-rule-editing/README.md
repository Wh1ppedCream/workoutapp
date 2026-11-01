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
| 5 | Independent Android compatibility review/change and build/native validation | Queued |

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

## Preservation and qualification

Success-state visuals, labels, field geometry, theme roles, navigation and
existing rules remain unchanged. Structural moves retain legacy entry points
where needed. Any changed failure behavior must have a targeted regression
test. Technical checks, physical-device observations and visual approval are
separate claims; this pass does not reopen approved layouts.

Unrelated paths remain untouched: `android/build/`, `flutter_06.png`,
`incoming/`, `test/theme/widgets/failures/` and `tmp/`. Existing local Codex
checkpoint-ref damage is not repaired; commits use command-local `gc.auto=0`.
