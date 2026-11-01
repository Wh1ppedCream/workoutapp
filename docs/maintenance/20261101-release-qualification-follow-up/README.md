# Pass 6 follow-up — release gates, CI and device qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fc635c5`.
This follows the user's authorization to complete four bounded follow-ups.
Approved presentation, the existing preview package/data and unrelated working
files are preserved. This does not authorize a production deployment or merge.

| Order | Work | State |
| --- | --- | --- |
| 1 | Match production app/content analyzer gates to strict CI policy; add a focused contract | Complete: 11 focused tests and clean scoped analysis |
| 2 | Push local checkpoints and verify the existing Linux/Java 17 CI run | Queued |
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
