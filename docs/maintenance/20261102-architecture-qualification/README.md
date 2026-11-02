# Architecture patch: review, checkpoint, CI and Pixel 7 qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `ff24670`.
The user authorized these four follow-ups in order. This report supplements the
[original five-batch report](../20261101-architecture-boundary-follow-up/README.md).
The existing dirty patch is reviewed and checkpointed in place; unrelated untracked
paths are excluded. No frozen visual approval or deferred floating-action work is
reopened.

| Step | Scope | State |
| --- | --- | --- |
| 1 | Edge-case review of editor requests/saves, launch races/source IDs, read-only equipment lookup and calendar arithmetic | Complete: 66 focused tests, two explicit DST query-range checks, zero analyzer issues, inventory and 18-file ratchet pass |
| 2 | Checkpoint the scoped patch, push this branch and obtain uninterrupted CI results | Ready to checkpoint; local checks pass |
| 3 | Focused Pixel 7 smoke test with original data protected | Device connected; execution follows checkpoint qualification |
| 4 | Assess the exercise-editor controller pilot and choose the next bounded candidate | Pending qualification |

## Review findings and corrections

1. A late catalog response could clear a newer exercise selection. Catalog reads
   now retain the selection request they started with; they may update equipment
   but cannot clear a newer selection or its draft. Invalidating an older detail
   read also clears its obsolete spinner. Two gated regression tests cover both
   interleavings.
2. A nonempty unknown equipment name could fall through to a same-named definition
   without equipment. Read-only lookup now returns no match for unknown equipment,
   retaining the optional thumbnail fallback without any insert. Primary and
   secondary equipment matching remain covered by real SQLite tests.
3. The preset route could respond twice to rapid Start taps even though the shared
   provider prevents replacing a workout. A route-local guard now excludes duplicate
   navigation until replacement finishes. Source exercise/set IDs remain preserved
   for presets; clone assertions also verify detached sets and change-set IDs.
4. Civil-day addition still used 24-hour durations in the shared calendar-day helper,
   selected-day query bounds, month-week bounds and weekday labels. These now use
   calendar constructors through LocalCalendarDay. Day-query regressions check late
   workouts on spring/autumn transition dates and the exact inclusive range end.
   Storage formats, UI palettes, shapes and navigation are unchanged.

Existing tests also cover stale successes/failures, disposal, duplicate saves,
failed-save draft retention, save/reload ordering, blocked imports/restoration,
unsupported-only plans, typed history cursor ordering and existing raw override
compatibility. Cardio/stretch remain deliberately unsupported by these launch
paths; this review does not enable unfinished features.

Local evidence is retained under `.build/maintainability/` with prefix
`architecture-edge-review-20261102-`: `tests.log`, `dst-ranges.log`, `analysis.log`,
`inventory.log` and `ratchet.log`. The two DST cases overlap the 66-case focused
batch and are not added to it as unique cases. The source contract continues to
check the actual extracted default-rule form and its page owner.

## Checkpoint and CI

Results and commit/run identities will be recorded after the checks finish.
No production release workflow, deployment or merge is authorized by this task.

## Device scope and data protection

The connected Pixel 7 is `28021FDH200228`. Its working package is
`com.tonos.expressivepreview`; other installed or retained packages/profiles are
not removed. Before any install, a fresh backup and package/user preflight must
protect the original database, preferences and active draft. Smoke-test writes
must be confined to disposable QA data, not existing user records. No fixture
reseed or reset is permitted.

Requested checks: both Train tabs and resume; preset start and history repeat;
Exercise Editor select/save/cancel/reopen; app/profile default rules; exercise
history pagination and missing-thumbnail fallback. Record actual evidence and
any unexercised states separately from automated coverage.

## Controller pilot assessment

Assessment will follow source review and qualification. This step evaluates and
chooses a bounded next candidate; it does not authorize wholesale controller
migration, facade removal or changes to approved presentation.
