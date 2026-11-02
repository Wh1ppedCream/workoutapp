# Tonos maintenance — combined index

Work continues on `codex/codebase-maintainability`. Pass 4 builds on checkpoint
`efe3f22`. This index connects the detailed
reports; it does not replace their evidence or imply release qualification.

| Pass | Scope | Authoritative report |
| --- | --- | --- |
| Pass 1 | Broad maintainability inventory, safety/reliability corrections and initial boundaries | [Codebase maintainability](20261029-codebase-maintainability/README.md) |
| Pass 2 | Reliability, transactions, provider/import reconciliation, lifecycle and repository structure | [Reliability and structure](20261029-pass2-reliability-and-structure/README.md) |
| Pass 3 | Structural decomposition, library-aware contracts and preserved UI/SQL behavior | [Structural decomposition](20261030-pass3-structural-decomposition/README.md) |
| Device follow-up | In-place Pixel 7 smoke test, data comparison and existing FAB collision | [Pixel 7 evidence](20261030-pass3-structural-decomposition/pixel7-smoke.md) |
| Pass 4 | Typed preset read boundary, residual DAO extraction, explicit chunked SQLite snapshot backend | [Combined overview](20261030-pass4-data-contracts/README.md), [technical report](20261030-pass4-data-contracts/technical-report.md), [Pixel 7 validation](20261030-pass4-data-contracts/pixel7-validation.md) |
| Pass 5 | Shared training state, SDK safeguards, typed analytics/drafts, targeted recovery and deprecations; remaining FAB coordination deferred | [Progress and qualification](20261031-pass5-shared-state-and-contracts/README.md) |
| Pass 6 | Clean baseline, atomic Nutrition diary writes, typed rule editing/dialog extraction, tested Android compatibility and Pixel 7 preservation | [Combined report and qualification](20261031-pass6-nutrition-and-rule-editing/README.md) |
| Release follow-up | Strict release analysis, green Linux/Java 17 CI, signed Pixel 7 checks, native scanner correction and compatibility retirement plan | [Completed follow-up](20261101-release-qualification-follow-up/README.md), [native migration plan](20261101-release-qualification-follow-up/android-migration-plan.md) |

The Pass 6 report owns its complete local qualification results. The release
follow-up records subsequent CI and release-device evidence, including its
retained-internal-install caveat and bounded camera coverage. Earlier reports
retain their checkpoint-specific counts. Static analysis, unit/widget checks, physical
device testing, visual approval and release qualification are separate claims.

The remaining roadmap includes the explicitly deferred floating-action
coordination on Nutrition/Train2 and further typed boundaries or component
extractions when evidence justifies them. Shared Train orchestration, targeted
recovery and the existing deprecation backlog are addressed in Pass 5.
Pass 6 retains a documented mixed Kotlin compatibility mode; the native plugin
set still needs coordinated migration before AGP 10, following the scheduled
native migration plan above. The follow-up's ML Kit constructor rule fixes the
confirmed strict-R8 initialization failure without upgrading that plugin cohort.
This does not authorize changing frozen
visuals, replacing state management, resetting user data, or removing live tabs.
