# Pass 6 follow-up — release gates, CI and device qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fc635c5`.
This follows the user's authorization to complete four bounded follow-ups.
Approved presentation, the existing preview package/data and unrelated working
files are preserved. This does not authorize a production deployment or merge.

| Order | Work | State |
| --- | --- | --- |
| 1 | Match production app/content analyzer gates to strict CI policy; add a focused contract | Complete: 11 focused tests and clean scoped analysis |
| 2 | Push local checkpoints and verify the existing Linux/Java 17 CI run | Complete: corrected checkpoint `0153482`, both jobs green |
| 3 | Smoke-test the signed arm64 release on Pixel 7 using isolated QA data | Complete within the bounded scope below; scanner initialization corrected; preview files unchanged |
| 4 | Record native-plugin migration stages and retirement criteria for compatibility settings | Complete: [scheduled migration plan](android-migration-plan.md); upgrades remain future work |

The catalog-builder's separate analysis policy is unchanged in both workflows.
No broader UI, controller, DAO or dependency rewrite is included. Nutrition and
Train2 floating-action coordination remains deferred.

The corrected code checkpoint passes **2,605 Flutter tests, seven Python guard
tests and eight Node relay tests**, plus the Linux/JDK 17 release build and its
generated-output reflection check. No Dart application UI or approved layout was
changed. The native release correction and the older-internal-install caveat are
recorded below; this is bounded technical qualification, not release certification.

## Strict release analysis

The production source/test and content-pipeline steps now use `--fatal-infos`,
matching their normal CI counterparts. A four-case contract checks the actual
named run steps in both workflows, their required scopes and strict flag,
without accepting the flag solely in a shell comment or an explicit opt-out.
That analyzer-policy checkpoint did not change application code, package locks,
signing configuration or deployment triggers. A subsequent native-only scanner
correction was necessary during physical release testing, as recorded below.

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

The combined local focused run passes **17 tests**, with clean fatal-info
analysis of all three modified Dart test files and clean formatting. On
`f965ee687f89e0dca850410504a2351b9aa5a440`,
[run 41342124655](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41342124655)
now passes the complete quality job: **2,605 tests, zero failures**, strict
source/tools analysis, localization, inventory/ratchet, content checks, exact
Linux goldens, Neo variants and **8/8 Node relay tests**. Focused and variant
counts overlap the full suite and are not added to it. The dependent Ubuntu /
Temurin Java 17 native job also passes: **436.4s** Gradle build, **105.0 MB**
internal release APK, uploaded as artifact **13098317408** (seven-day retention).
That run established buildability; the device test then exposed the runtime issue
below. The corrected checkpoint is **`0153482cc73211294af9c838026c46b3c03ceb28`**:
[run 41347399961](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41347399961)
passes both jobs, including **2,605 Flutter tests / zero failures**, seven Python
cases, **8/8 Node tests**, clean analysis/guardrails and the minified-output check
for **all three ML Kit reflection constructors**. Its Java 17 release build took
**452.4s**, produced a **105.0 MB** internal APK and uploaded artifact
**13100187541**, with seven-day retention.

CI APKs use a disposable CI signing key, not production credentials. The
production-release workflow was not dispatched, and no merge/deployment occurred.

## Physical release check and isolation correction

The Pixel 7 is `28021FDH200228`, Android 16 / API 36. The working
`com.tonos.expressivepreview` app was stopped and its databases/preferences
archived before testing and remained stopped until the final comparison finished.

The initial attempt reused the existing signed `com.tonos.internal` APK from
Pass 6 (SHA-256 `2f4494bd06fbd2b694cc65968fff1708eaf7eddbd19fc457dca0639225739858`).
The initial ordinary package list showed it absent. This was an insufficient
isolation check: investigation found retained older user-0 data and an internal
installation in another Android profile. The preflight had not recorded every
profile's installed/retained state. Installation updated the shared package binary
and made the retained user-0 data available. Its first-install timestamp was September 22.
The existing-session guard correctly kept/resumed its older workout instead of
replacing it when the newly copied QA plan was started. No sets were edited,
completed or discarded.

Testing against that package stopped. The QA-added Full Body plan was deleted;
the observed original Classic/light theme and five-tab selection were restored.
The user-0 install registration was removed with `-k`, retaining its data; the
other profile's installation/data were not removed. Its older APK binary was not
archived before the install and was not restored. This first attempt is not
counted as a fresh-data QA result or proof of byte-identical internal-app state.

The corrected smoke test uses a unique package, `com.tonos.releaseqa20261101`,
and database `release_qa_20261101.db`. The install guard checks **every Android
user, including `pm list packages -u` retained/uninstalled entries**, before
installing for user 0 only. It refuses to reuse any existing namespace.
The one-off package/label override was removed after each build. Only the native
R8 correction below is retained; no QA identity override or signing-policy change
is committed. Database Settings confirmed `release_qa_20261101.db`, schema v62.

### Release-only ML Kit initialization defect

The unique signed release built in **731.5s**, with APK SHA-256
`62f59af84688421eea1be77f1cce65c555576f1524f957d09ad182d6622aee1d`.
First-run onboarding and schema/path checks confirm fresh data isolation.
A copied QA Full Body plan starts successfully. Its completed first set and
eight reps survive force-stop/relaunch. A typed 22.5 lb load redisplays as 23 lb
under the existing whole-pound working-load formatting policy; the subsequent
completion summary correctly reports **180 lb volume**, proving the fractional
canonical value survived. No formatting policy was changed.

The native document picker opens and cancels successfully without import.
However, the barcode camera shows an error in this minified release. Its native
stack retraces to `BarcodeScanning.getClient`; all three ML Kit registrar classes
exist in the merged manifest/R8 mapping, but their no-argument constructors are
absent. This matches [ML Kit's AGP 9 report](https://github.com/googlesamples/mlkit/issues/1007)
and [AGP's documented strict keep-rule change](https://developer.android.com/build/releases/agp-9-0-0-release-notes#android-gradle-plugin-behavior-changes):
keeping a class no longer implicitly keeps its constructor.

The correction adds an app-owned release rule retaining only the no-argument
constructors of ML Kit `ComponentRegistrar` implementations. R8 optimization,
strict mode, dependency versions and Dart UI remain unchanged. A generated-output
guard reads the real merged release manifest and R8 mapping and rejects missing
or renamed reflection classes/constructors. Its **seven Python cases** include
the original stripped-constructor failure, overload-only constructors and
cross-class false positives. All seven and **10 focused Flutter workflow/native
contracts** pass locally. Both CI release workflows run the guard before
uploading build artifacts; the production workflow itself remains manual-only.
The guard fails on the broken APK's actual mapping for all three registrars,
then passes on the corrected local and CI outputs. It is not a source-text
substitute for examining the generated native artifact.

### Corrected device results and preservation

The corrected signed QA APK built in **141.5s**, verifies with `apksigner`, and
has SHA-256 **`d88b55f0a5f7a00ee38a489cceab81bdb0f50fdd3d10b8883be45d4eda9e301a`**.
The installed APK hash was checked before its eventual removal. The existing
signing-properties and package-lock hashes remain unchanged.

| Check | Evidence / scope |
| --- | --- |
| Fresh-data startup | First-run onboarding appears in the unique namespace; setup/tutorials were skipped through normal UI only in QA. |
| Expressive presentation | Selected through normal Settings; light workout and dark settings views inspected. Theme family and enabled Nutrition tab survived a cold launch. No new visual approval granted. |
| Workout persistence | QA Full Body plan started; first set at 22.5 lb / eight reps marked complete; force-stop/relaunch/resume retained completion, reps and canonical load, confirmed by 180 lb completion volume. This scenario ran before the native-only constructor correction. |
| Native document picker | Signed QA baseline opened Android's `PickActivity` and returned on cancel, without file selection/import. |
| Corrected scanner | After the corrected APK update and a fresh one-time camera grant, scanner error text was absent in three captured UI hierarchies. Switch controls were exercised twice and the page closed normally. Android's camera service confirms a QA camera-0 connection/disconnection. |
| Runtime errors after correction | Zero matches for Flutter/unhandled exceptions, missing plugins, fatal exceptions, native null-pointer exceptions or failed method calls in the checked QA process log. |
| Preview preservation | Stopped-app before/after comparison: **all 87 tables have identical rows/digests; all archived database/preferences files are byte-identical**. Table/file names match, integrity is **ok**, schema remains **62**. |
| Cleanup / final screen | Only the newly created QA package was fully uninstalled. User 0 again has only `com.tonos.expressivepreview`; retained older profiles were not deleted. The preview was cold-reopened and confirmed on **Train → Overview** after the comparison. |

The USB transport briefly stalled during the corrected camera check. Pending QA
commands were cancelled, the connection was refreshed, and the remaining checks
completed after recovery. No device reset or database reseed was used.

Limits: actual barcode decoding and an independently observed front-lens change
were not verified. Camera-switch controls produced no surfaced error, but the
retained service events only establish camera 0. Picker cancellation is not an
import/restore qualification. Transaction failure injection remains in isolated
SQLite tests, not on the phone. Other devices/OS versions, production content,
production APK/app-bundle execution and release readiness are not certified here.
No live camera or personal file-list screenshot was captured.

Local/private evidence lives under `.build/maintainability/release-qa-20261101/`:
`preview-before.tar`, `preview-after.tar`, `preview-data-comparison.json`,
`draft-restore-check.json`, the workout/camera UI hierarchies and the failing
scanner trace. Build logs are `release-qa-unique-build.log` and
`release-qa-fixed-build.log` in the parent directory. The generated local
`build/app/outputs/flutter-apk/app-release.apk` has the QA-only identity, not a
production identity. This local private evidence is not staged.

## Native migration scheduling

The [migration plan](android-migration-plan.md) records the actual locked plugin
cohort, ordered upgrade/migration batches, compatibility-setting retirement
criteria and host/device/data gates. It is scheduled before the next major
Flutter/AGP upgrade. It covers the file-picker bridge, legacy Kotlin/new-DSL
opt-outs, ML Kit constructor rule, Jetifier, cross-volume Kotlin incrementality
and retained workstation memory limits. **No dependency or SDK upgrade is included
in this follow-up.** Native/CI deprecation notices remain distinct from clean
Dart analysis. Nutrition/Train2 floating-action coordination is still deferred.

## Changed files, checkpoints and final checks

| Checkpoint | Changes |
| --- | --- |
| `e2c17f9` | Strict production analyzer gates, four-case workflow contract, initial follow-up report/index. |
| `16afe0f` | Portable scanner fixture paths; early CI guardrails and retained golden-failure artifacts. |
| `f965ee6` | Host-specific exact Linux golden references/harness and provenance; Windows originals retained. |
| `0153482` | App release ProGuard wiring and registrar-constructor rule; generated-output verifier and seven Python tests; CI/release workflow gates; qualification findings. |
| Final documentation checkpoint | This completed report, migration plan and combined maintenance index. Code qualification belongs to `0153482`; later documentation-only commits do not imply additional device coverage. |

Changed implementation/check paths are `.github/workflows/ci.yml`,
`.github/workflows/production-release.yml`, `android/app/build.gradle.kts`,
`android/app/proguard-rules.pro`, `test/analyzer_workflow_contract_test.dart`,
`test/theme/theme_style_inventory_source_rules_test.dart`,
`test/theme/widgets/auto_preset_flow_panels_golden_test.dart`, the four Linux PNGs
and reference README under `test/goldens/expressive_flow_editor/`,
`tools/verify_android_release_registrars.py` and
`tools/tests/test_android_release_registrars.py`. Documentation is linked above
and from `docs/maintenance/README.md`.

Modified Dart test files were formatted and analyzed with fatal infos. Focused
Flutter runs passed 11, 17 and 10 cases at their respective checkpoints; these
overlap the full 2,605-case CI suite. The seven Python cases and eight Node cases
are separate suites. All **15 local file links** in the changed maintenance
Markdown resolve, and `git diff --check` is clean. No extra app rebuild or test
rerun is needed solely for the concluding Markdown edits.

Unrelated `android/build/`, `flutter_06.png`, `incoming/`,
`test/theme/widgets/failures/` and `tmp/` remain untouched and unstaged. No destructive
Git/workspace cleanup, data reset, merge or production deployment was performed;
the explicitly described temporary-QA app cleanup is separate. The known local Codex
checkpoint-ref issue was not repaired; commits/pushes used command-local automatic
maintenance suppression.
