# Tonos Expressive major amplification — review candidate

**Status: source validation complete; Pixel visual evidence pending.** This folder tracks a working-tree candidate, not an approved design or release. The goal is to retain Tonos information, data meaning, actions, workflows, and accessibility while giving candidate pages a clearly distinct Expressive presentation.

## Source/build identity

| Item | Recorded value |
| --- | --- |
| Branch / source checkpoint | `feature/classic-m3e` / `ab18ed8cab5582c8449e13724afae3c4b74ebeea` (starting HEAD) |
| Working tree | Dirty, frozen for integration validation; no commit created for this pass |
| Toolchain | Flutter 3.47.5 / Dart 3.13.4 |
| Visual device | Pixel 7, `28021FDH200228` |
| Preview package / database | `com.tonos.expressivepreview` / `tonos_expressive_preview.db` |
| Preview entry point | `lib/expressive_preview_main.dart` |

The source is frozen and focused integration validation has completed. The fresh device APK and Pixel captures for this dated review are still **pending**. Do not use older capture folders as evidence for the current source. See [source snapshot](source-snapshot.md), [route ledger](route-ledger.md), [known issues](known-issues.md), and the [screen-by-screen review list](visual-review-list.md).

## Evidence status

| Evidence | Status | Location |
| --- | --- | --- |
| Focused integration tests | **529 passed, 0 failed, 0 skipped** across 95 files | Validation run; no full suite |
| Analyzer | **0 errors, 0 warnings, 54 infos**; exit 1 because infos are reported | Validation run |
| Dart formatting check | Five task-owned Dart files still pending formatting | Follow-up required |
| `git diff --check` | Pass | Validation run |
| Theme inventory check | Pass | Validation run |
| Ratchet enforcement | Pending | Intentional `exercise_definition_info_tile.dart` fingerprints need explicit handling |
| Fresh source-matched preview build | Pending | — |
| Pixel 7 light/dark captures | Pending | `captures/` (to be populated after validation) |
| Narrow / large-text captures | Pending | `responsive/` (to be populated after validation) |
| Motion clips | Pending motion audit | `motion/` if a clip is needed |
| Focused tests, analysis, format, inventory/ratchet | Partial; results above | Ratchet remains pending |

## Review boundary

Train Overview/Plans, the navigation shell, and normal-width Active Workout remain the approved visual references and are protected from redesign in this pass. Candidate changes are not yet user-approved. No full repository suite, commit, or push is part of this review checkpoint. Visual review readiness still depends on formatting follow-up, ratchet disposition, a fresh isolated preview build, and current Pixel evidence.
