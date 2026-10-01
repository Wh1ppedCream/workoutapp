# Expressive proving-ground validation

**Current status (2026-10-01): final Train + shell reference qualification passed.** Final uninterrupted host suite, repository analyzer, inventory/ratchet, focused contracts, Pixel sanity and the isolated Workout-compatibility smoke all passed. The user-approved design is a continuation reference only; it is not a production rollout or app-wide theme release. TalkBack remains untested. Earlier records below preserve intermediate qualification history.

## Final host qualification — 2026-10-01

- Flutter **3.47.5** / bundled Dart **3.13.4**, normal C: TEMP/TMP, default concurrency.
- Final uninterrupted `flutter test --no-pub --reporter compact`: **1,295 passed, 0 failed, 0 skipped, exit 0**, elapsed **00:11:53.386**. Transcript: `C:\Users\talh7\AppData\Local\Temp\tonos-full-test-final-20261001.log`.
- Repository-wide pinned `dart analyze`: **0 errors, 0 warnings, 81 infos, exit 0**. Transcript: `C:\Users\talh7\AppData\Local\Temp\tonos-final-dart-analyze-20261001.log`.
- Inventory: **296 files, 2,440 candidates, 130 allowlisted, 2,310 classified/migrated, 0 pending, 0 unassigned, 0 overlaps**. Ratchet enforcement passed for **18 protected scopes** with exact approval maps. Theme contracts and extension completeness passed.
- Focused UI/motion/presentation set: **75 passed**; inventory contract: **53 passed**; ratchet CLI: **3 passed**; ambient visibility qualification: **1 passed**. Final scoped analysis of the device harness found no issues.
- Full suite passed after narrow source-rule and infinite-ambient test-harness corrections. Production theme/UI source did not change during these corrections.
- The successful Pixel smoke-only profile drive is detailed in [device qualification](../device-qualification.md). Its report sets `timingsMeasured:false`; the prior matched profile measurements remain the only timing evidence.

## Checkpoint and environment

- Branch and remote tip were both `feature/classic-m3e` at `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9` before validation.
- Flutter 3.47.5 and bundled Dart 3.13.4 were used. The full suite ran as `flutter test --no-pub --reporter json`, with default concurrency and normal `C:\Users\talh7\AppData\Local\Temp` TEMP/TMP.
- The 15 protected tracked files matched their handoff SHA-256 values before and after the full suite (15/15). All five unrelated untracked groups remain present. The approved profile build may have written generated content under `android/build/`; byte-for-byte equality for that group was not established from a pre-build digest. Nothing was cleaned or staged by this validation lane.

## Earlier repository analysis and theme gates — 2026-09-30

- Final repository-wide analysis against the frozen device-harness correction completed in 49.135 seconds: **exit 0, 0 errors, 0 warnings, 84 informational notices**. The machine output and observed timing/count metadata are in `logs/dart-analyze-post-device-harness-machine.txt` and `logs/dart-analyze-post-device-harness-metadata.txt`. The prior 41.597-second repository analysis remains as the earlier source snapshot in `logs/dart-analyze-final-postfix-machine.txt` and `logs/dart-analyze-final-postfix-metadata.txt`; an earlier clean analysis of the frozen preview/accessibility sources took 77.757 seconds and its separate log is retained.
- One earlier analysis run caught an undefined `TextScaler` shown name in the new accessibility test. The test import was corrected to keep only `Tristate` from `dart:ui`; the new test then passed and the post-freeze repository analysis was clean for errors and warnings. The earlier diagnostic remains in `logs/dart-analyze-final-machine.txt` and `logs/dart-analyze-final-metadata.txt` as historical evidence.
- `tools/theme_style_inventory.dart --check` exited 0: 296 Dart files, 2,440 candidates, 130 allowlisted, 2,310 migrated, 0 pending, and 0 unassigned. Review queues cover 992 candidates exactly once, 1,448 outside configured queues, and 0 overlaps.
- Ratchet report and enforcement both exited 0: 18 protected files, 158 per-file fingerprint entries, and 180 current occurrences, matching the exact approval maps.

## Full regression results

The uninterrupted initial run took **834.154 seconds** and returned **exit 1**: **1,254 passed, 1 failed, 0 skipped** visible tests. The JSON reporter emitted 1,494 `testDone` events; 239 hidden load events were excluded. Raw output and observed metadata are in `logs/full-flutter-test-reporter-json.jsonl` and `logs/full-flutter-test-metadata.txt`.

The sole failure was `test/theme/app_theme_tokens_test.dart:187`, in “Train and workout completion consumers use focused theme roles.” Its source-text assertion expected the exact substring `variant: TonosSurfaceVariant.panelRaised`, which no longer matched the conditional source expression. The `panelRaised` branch belongs to the established `usesInkRecipe` (Neo) surface; Classic still uses its ordinary `Card` fallback, while Expressive selects `TonosSurfaceVariant.card`. This was a **test-harness issue**, not a demonstrated runtime or Classic-family regression. The lead changed the matcher to assert all three Expressive-card / panelRaised conditional branches and retained the other semantic-ownership assertions. The focused post-fix file passed **18/18, exit 0**.

The uninterrupted post-fix full suite took **1,274.075 seconds** and returned **exit 0**: **1,255 passed, 0 failed, 0 skipped** visible tests. It emitted 1,494 `testDone` events, with 239 hidden load events excluded. Separate post-fix reporter and metadata files are `logs/full-flutter-test-postfix-reporter-json.jsonl` and `logs/full-flutter-test-postfix-metadata.txt`.

Focused accessibility checks also passed: the new accessibility test passed **1/1**, and the existing accessibility/navigation/overlay/Train group passed **28/28**, both with exit 0.

After the 1,255-pass host suite ended at **2026-09-30 10:28:09.939 local (14:28:09.939Z)**, Pixel made a final integration-test-only harness correction: geometry now targets the outer icon button, while all 48 requirements, edge taps, route settlement, and numeric logging remain covered. No production or unit-test source changed after the host-suite snapshot. The device idle windows began at **14:29:14Z**, about 65 seconds after the host suite ended, so the runs did not overlap. The final repository analysis above includes the frozen integration harness; a second full host suite was not run because `flutter test` does not include `integration_test`.

## Family and fallback parity review

The current tests assert that persisted `AppThemeFamily` values remain Classic and Neo only; preview controls leave shared-preference keys and sentinel values unchanged; and the default `buildTonosApp` seam renders identically to explicit `previewPresentation: null`. The overlay root test also exercises the production Train flow under persisted Classic defaults and verifies Classic identity, no Expressive/Neo identity, unchanged preferences, providers, and actions. Generic `ThemeData` tests preserve a null family identity with ordinary Material colors. Workout compatibility tests keep the Expressive reveal opt-in separate from Neo and retain Classic timing. These checks passed in the post-fix full suite.

Evidence resides in `test/expressive_preview_architecture_test.dart`, `test/expressive_overlay_qualification_test.dart`, `test/theme/app_theme_identity_test.dart`, `test/theme/app_theme_family_test.dart`, `test/theme/theme_family_selector_test.dart`, and `test/expressive_preview_workout_compatibility_test.dart`. The post-fix full suite exercised these tests.
