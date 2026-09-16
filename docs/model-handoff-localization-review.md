# Model Handoff Review

Last reset: 2026-09-04.

## Purpose

Use this document to record work performed after switching from the primary
review model to a lower-cost model. It should give the primary model a focused
review checklist when it returns without requiring it to reconstruct the work
from conversation history.

Do not add routine discussion or a complete changelog. Record only implemented
changes, important decisions, verification evidence, and unresolved risks.

## Confirmed Baseline

The localization and stable catalog-identity implementation through commit
`1a1c549`, together with the current focused correctness fixes, was reviewed on
2026-09-04.

Confirmed results:

- `flutter gen-l10n` produced no committed-output drift.
- `dart analyze lib test integration_test test_driver` reported no issues.
- The focused localization review suite passed 67 tests.
- The complete Flutter suite passed 373 tests.
- The GitHub workflow contract passed 3 tests.
- `git diff --check` passed; LF-to-CRLF notices are expected warnings.
- Exercise guidance and names cover all 300 exercises in Spanish, French,
  Bangla, Simplified Chinese, and Hindi.
- Stable catalog localization covers 40 equipment entries and 56 muscles in
  those five languages.
- Premade-plan localization covers all 21 directly authored plans in those five
  languages; generated duration variants inherit localized presentation.

The closed review fixed stable-ID plan lookup, coherent premade-plan fallback,
regional locale fallback, malformed-bundle validation, custom lookup rename
identity, missed body-part labels, localization coverage contracts, and the CI
generated-file cleanliness check.

Do not reopen this completed technical review unless later changes touch these
boundaries or a regression is observed. Native-speaker linguistic sign-off
remains a separate release activity rather than a code-correctness failure.

## Known Product Decision

The Exercise Editor can modify a shipped exercise while retaining its stable
catalog ID. Before changing that behavior, decide whether an edit represents a
local override, a custom fork, or a forbidden change. Blindly clearing the ID
could cause the next catalog synchronization to create a duplicate definition.

## Working-Tree Separation

Keep future handoff entries scoped to the work performed during that model
period. Do not accidentally include development screenshots or `tmp/`.

The maintenance backlog and `docs/theme-design-plan.md` are separate planning
work unless a future task explicitly modifies them.

## Next Lower-Model Work Period

Status: Not started.

### Scope

- Model and start date:
- Requested objective:
- Starting commit:

### Implemented Changes

- None yet.

### Files And Data Boundaries

- Files added:
- Files modified:
- Schema, persistence, or migration changes:
- Localization keys or assets changed:
- User-visible behavior changed:

### Verification Evidence

- Formatting:
- Analyzer:
- Focused tests:
- Full suite:
- Build or device checks:
- `git diff --check`:

### Review Checklist For Returning Model

- Confirm implementation matches the requested behavior.
- Review persistence, migration, stable-ID, and backward-compatibility effects.
- Check localization fallback, placeholders, custom-data preservation, and
  locale switching where relevant.
- Inspect tests for meaningful behavior coverage rather than only line coverage.
- Verify generated files and documentation match the source of truth.
- Keep unrelated working-tree files out of any fix or commit.

### Open Risks Or Questions

- None recorded yet.

## Logging Rules

For each substantial pass during the lower-model period:

1. Replace `None yet` with concise implementation bullets.
2. List exact affected files or feature boundaries.
3. Record commands and numerical test results from user-provided output.
4. Record anything the returning model must inspect or decide.
5. Do not mark uncertain behavior as verified.
6. Do not erase unresolved risks merely because tests pass.
