# Pass 6 follow-up — release gates, CI and device qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fc635c5`.
This follows the user's authorization to complete four bounded follow-ups.
Approved presentation, the existing preview package/data and unrelated working
files are preserved. This does not authorize a production deployment or merge.

| Order | Work | State |
| --- | --- | --- |
| 1 | Match production app/content analyzer gates to strict CI policy; add a focused contract | Complete: 11 focused tests and clean scoped analysis |
| 2 | Push local checkpoints and verify the existing Linux/Java 17 CI run | In progress: pushed; repairing host-specific test assumptions |
| 3 | Smoke-test the signed arm64 release on Pixel 7 using isolated QA data | Queued |
| 4 | Record native-plugin migration stages and retirement criteria for compatibility settings | Queued |

The catalog-builder's separate analysis policy is unchanged in both workflows.
No broader UI, controller, DAO or dependency rewrite is included. Nutrition and
Train2 floating-action coordination remains deferred.

Final commands, results, CI identifiers and device-data preservation evidence
will be recorded here as each step completes.

## Strict release analysis

The production source/test and content-pipeline steps now use `--fatal-infos`,
matching their normal CI counterparts. A four-case contract checks the actual
named run steps in both workflows, their required scopes and strict flag,
without accepting the flag solely in a shell comment or an explicit opt-out.
No application code, package lock, signing configuration or deployment trigger
changed.

Validation: formatting and fatal-info analysis pass for the new contract;
**11 focused tests** pass across analyzer policy, content-release policy and
release/privacy contracts. Logs are in `.build/maintainability/` with prefix
`followup-analyzer-gates-`. Focused counts overlap and are not added to the
existing whole-suite count.

## Remote CI and portable checks

The initial 11 local checkpoints were pushed through `e2c17f9`. The first
[Linux run](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41340210855)
passed analysis and inventory/ratchet gates, but its full suite reported
**2,602 passed / 3 failed**, preventing the dependent release build.
The failures were one scanner fixture and two golden cases, not analyzer errors.

The fixture supplied an absolute temporary path while the scanner reports a
repository-relative path. Different-drive Windows behavior had hidden the error.
It now constructs the expected relative path using the same public path API and
asserts the emitted file identifier as well as all three finding classifications.
The scanner itself is unchanged.

The next [diagnostic run](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41341614065)
confirmed the fixture repair and retained all four golden comparison outputs.
Inspection showed host-specific Ahem glyph-edge differences, with matching card
geometry and styling. Reviewed Linux references are added alongside the unchanged
Windows originals; [reference provenance](../../../test/goldens/expressive_flow_editor/README.md)
is recorded with the images. Both hosts retain exact comparison without skips or
tolerance changes. A small CI preflight checks these cases before the full suite;
failed comparisons are retained for seven days for diagnosis.

The combined local focused run passes **17 tests**. Whole-suite and native CI
results for the repaired checkpoint will be recorded below once complete.
