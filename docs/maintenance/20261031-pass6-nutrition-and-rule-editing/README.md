# Pass 6 — nutrition safety, rule editing and Android compatibility

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fe6ed3e`.
Work is performed in the existing checkout, preserving approved presentation,
stored formats, preview/user data and unrelated files. No push is included.

## Authorized sequence

| Batch | Scope | State |
| --- | --- | --- |
| 1 | Full pinned-SDK baseline and failure investigation before production edits | Complete: 2,578 tests pass; clean analysis |
| 2 | Focused Nutrition transaction/failure tests; correct demonstrated single-entry failure risks while retaining item-by-item batches | Complete: 44 focused tests pass |
| 3a | Shared typed Flow Methods editing parameters with compatibility tests | Queued |
| 3b | Standalone preset-rule dialog and properly scoped shared controls, preserving rendering and public imports | Queued |
| 4 | Reassess further extraction against demonstrated responsibility/testability benefits | Queued; conditional |
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

## Preservation and qualification

Success-state visuals, labels, field geometry, theme roles, navigation and
existing rules remain unchanged. Structural moves retain legacy entry points
where needed. Any changed failure behavior must have a targeted regression
test. Technical checks, physical-device observations and visual approval are
separate claims; this pass does not reopen approved layouts.

Unrelated paths remain untouched: `android/build/`, `flutter_06.png`,
`incoming/`, `test/theme/widgets/failures/` and `tmp/`. Existing local Codex
checkpoint-ref damage is not repaired; commits use command-local `gc.auto=0`.
