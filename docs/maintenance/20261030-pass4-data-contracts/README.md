# Maintainability Pass 4 — combined overview

- Branch: `codex/codebase-maintainability`.
- Starting checkpoint: `efe3f22`.
- Scope: P4-A through P4-D for preset loading and selected remaining inline SQL.
- Status: **P4-A through P4-D complete and validated.**
- Preservation: approved UI, schema 62, stored identifiers, units, exports, existing preview data, and unrelated worktree changes retained.

This is the main Pass 4 entry point. The
[technical report](technical-report.md) combines architecture, exact changes,
regression coverage, validation evidence, limitations, and remaining work.
The [baseline contract inventory](preset-loading-contracts.md) preserves the
P4-A field/default/consumer/fake analysis at `efe3f22`.
The [maintenance index](../README.md) links the earlier passes and device report.

## Completed batches

| Batch | Result |
| --- | --- |
| P4-A — inventory | Documented ten repository reads, eight map-shaped results, nullable/partial projections, ordering, consumers and 58 existing test overrides. |
| P4-B — typed reads | Preset loading now consumes eight immutable named read projections through `PresetReadSession`. Existing raw APIs and fake overrides remain compatible. |
| P4-C — SQL ownership | Moved five read queries and three workout-edit transactions into existing DAOs; retained facade signatures, SQL and record rebuilding. |
| P4-D — batching | Explicit production SQLite source loads the preset graph in one read transaction with chunked queries and per-load snapshot ownership. |

The user authorized continuing past the original P4-A-only scope. No Train
presentation consolidation, UI decomposition, theme changes, migration split,
dependency upgrades or bulk deprecation cleanup was included.

## What improved

- Preset loading uses named typed fields instead of SQL/JSON-key indexing.
  Row decoding lives in one model file and preserves partial/ignored-row behavior.
- The production path avoids per-exercise/per-set SQLite round trips; the fake
  compatibility path still dispatches through existing public overrides.
- Related report/preset queries and atomic workout edits live with their domain
  DAOs rather than executable SQL in `DatabaseHelper`.
- A fresh read session is created for every load/retry; an older snapshot cannot
  silently become the source for a later refresh.
- Existing provider staging, dirty-state behavior, failure classification and
  load-version/disposal guards remain in place.

## Qualification

| Gate | Result |
| --- | --- |
| Full Flutter unit/widget suite | **2,531 passed, zero failures**; baseline 2,515 plus 16 new regression cases. |
| Contract coverage | All 172 cases pass in the full suite; the isolated first run found one stale no-argument constructor assertion, corrected and rechecked. |
| Focused final recheck | **10 passed**: SQLite preset reads plus repository injection, after the test-only brace-style cleanup. |
| Full static analysis | **Zero errors, zero warnings, 75 existing deprecation infos**; no new findings. |
| Theme inventory | **4,382 candidates across 366 Dart files**: 3,595 migrated, 144 allowlisted, 643 pending, zero unassigned. |
| Theme ratchet | All **18** protected source files unchanged; enforcement passed. |
| Extraction comparison | **313 public helper signatures and eight moved execution bodies** preserved, ignoring formatting/trailing commas and removing only local connection acquisition from the DAO bodies. |
| Development and locked-production content checks | Both passed. |
| Node relay checks | **8 passed**. |
| Compile-time variants | **3 passed**: locked development content, explicit Neo opt-in, and malformed Neo opt-in. |
| Documentation/whitespace | Link, inventory consistency and whitespace verification passed. |
| Physical Pixel 7 | Focused in-place debug build/install and preset/workout/report smoke test passed; see [device validation](pixel7-validation.md) for data comparison and limits. |

Counts from focused, contract, variant and full-suite runs overlap and must not
be added together. No executable production behavior changed after the full
suite started. A later edit added braces around an existing test-helper
assignment; its affected tests were rerun.

## Measured query behavior

The query-count tests use actual in-memory SQLite with the production schema.
They count reads performed by `PresetReadDao`, excluding transaction control.

| Weight-only fixture | Read statements |
| --- | ---: |
| Empty or missing preset | 3 |
| 1 exercise / 1 set | 7 |
| 40 exercises / 40 sets | 7 |
| 801 exercises / 801 sets | 10 |

The nonempty fixtures reuse one exercise definition. Mixed-type or many-definition
plans have additional query groups/chunks. The bound is by query groups and
800-parameter chunks; returned-row processing remains proportional to data size.
This is query-count evidence, not a device latency/frame-time benchmark.

## Boundaries and remaining work

This completes the agreed P4-A–D scope, **not** removal of every map in the app
or all SQL from the helper. Existing progression, export and other raw APIs are
still available. Their migrations should follow measured consumer boundaries.

The lazy typed read projections deliberately preserve ignored malformed orphan
rows, unknown exercise types, partial fakes and existing flag/default policy.
They are not new eager schema validators. Detailed tradeoffs and follow-ups are
in the technical report.

The later [Pixel 7 validation](pixel7-validation.md) exercised the new backend
in place without resetting or reseeding preview data. Physical cardio/stretch
preset, iOS, release-build and device performance coverage remain outstanding.
The earlier [Pixel 7 smoke report](../20261030-pass3-structural-decomposition/pixel7-smoke.md)
predates this implementation; its ongoing-workout FAB collision remains a
separate known issue. At qualification, no staging, commit or push had been made.
