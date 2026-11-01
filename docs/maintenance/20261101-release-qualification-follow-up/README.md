# Pass 6 follow-up — release gates, CI and device qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `fc635c5`.
This follows the user's authorization to complete four bounded follow-ups.
Approved presentation, the existing preview package/data and unrelated working
files are preserved. This does not authorize a production deployment or merge.

| Order | Work | State |
| --- | --- | --- |
| 1 | Match production app/content analyzer gates to strict CI policy; add a focused contract | Complete: 11 focused tests and clean scoped analysis |
| 2 | Push local checkpoints and verify the existing Linux/Java 17 CI run | Earlier checkpoint green; native scanner correction awaiting requalification |
| 3 | Smoke-test the signed arm64 release on Pixel 7 using isolated QA data | In progress: release-only scanner defect identified |
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
That APK uses a disposable CI signing key, not production credentials. The
production-release workflow was not dispatched, and no merge/deployment occurred.

## Physical release check and isolation correction

The Pixel 7 is `28021FDH200228`, Android 16 / API 36. The working
`com.tonos.expressivepreview` app was stopped and its databases/preferences
archived before testing; it remains stopped during the QA work.

The initial attempt reused the existing signed `com.tonos.internal` APK from
Pass 6 (SHA-256 `2f4494bd06fbd2b694cc65968fff1708eaf7eddbd19fc457dca0639225739858`).
The ordinary current-user package list showed it absent. This was an insufficient
isolation check: the phone retained its earlier user-0 data and also had it in
another Android profile. Installation updated the shared package binary and made
the retained user-0 data available. Its first-install timestamp was September 22.
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
The one-off package/label override is temporary, with no retained application
source or signing-policy changes. Final device results and preview comparison
will be recorded after this isolated check completes.

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
The guard has been demonstrated to fail on the broken APK's actual mapping for
all three registrars. Rebuild, device retest and corrected-checkpoint CI results
remain to be recorded.
