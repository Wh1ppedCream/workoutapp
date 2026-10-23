# Test stabilization follow-up — 2026-10-22–23

## Scope

This follows the [initial full validation](tonos-expressive-full-test-validation-20261022.md)
and the user's authorization to investigate the Android failure, reconcile stale
theme contracts, review inventory/ratchet ownership, and reconcile Flow goldens.
It preserves the existing dirty worktree and the approved Expressive layouts.

Validation completed on Flutter 3.47.5 / Dart 3.13.4. Final results are
recorded below after the last production fix; intermediate runs are not added
together.

## Confirmed application defect

Manual plan creation could run before `SelectedProfile` finished loading the
persisted gym selection. A deterministic delayed-repository regression reproduced
creation with `profileId: null` before the fix. This was a functional race, not
just an obsolete theme expectation.

- `lib/providers/selected_profile.dart` exposes its initialization future as
  `ready`.
- Train and both Train2 manual-plan entry points await that future and stop if
  their page has been disposed.
- Six regression cases cover Train, Expressive Train2, and Classic Train2, each
  with the page retained or left before loading completes. They verify no early
  write, correct persisted profile assignment, and no write after leaving.
- The affected four-file focused batch passes all **22 cases**.

These application edits do not change visual design, labels, sizes or navigation
destinations. The Android harness separately waits for real provider/session
readiness and verifies the actual created row rather than guessing its identity.
The first Pixel run passed Classic and reached saved-measurement verification in
Expressive, then exposed a harness synchronization gap: it issued consecutive
Back actions without waiting for route transitions, and could find the still
onstage library beneath a closing entry dialog. A global animation-settle attempt
was interrupted because Expressive intentionally repeats its resumable-workout
motion. The final harness waits only for the popped route's animations, asserts
that the entry Save control is gone, and scrolls the lazily built Profile list
back to UI & Appearance. A later run reached navigation settings and exposed the
same lazy-list assumption inside the longer Expressive appearance page. The
final harness explicitly reveals its navigation and language options. It does
not require intentional motion to stop or all settings to be built offscreen.
With those changes, Expressive completed the full Pixel flow. The same attempt's
Classic setup hit a 15-second connection timeout fetching a live R2 media
manifest. That attempt is retained; the identical APK was rerun without changing
or suppressing assertions. **Both Classic and Expressive passed that final
rerun**, exit 0, in 3m02s. Live manifest availability remains an external dependency
of this device suite.

## Test-contract and fixture repairs

Reviewed assertions now describe the approved implementation: shared Catalog
details, anatomy thumbnails, anchored selectors, compact Current Metrics,
Dashboard compositions, nested generation headers, conditional preset floating
actions, current planning colors, and Expressive navigation controls.

Tests expressly describing Classic/Neo recipes are scoped to those families.
Shared behavior matrices continue to include Expressive, with its dedicated
interaction, contrast and responsive tests retained. This removes 20 accidental
Expressive registrations of legacy-only assertions; it does not skip failing
tests. Four disposable-benchmark guard tests and two populated Expressive Current
Metrics tests were added, followed by the six profile-readiness regressions.

Repository fakes and provider fixtures now implement the operations the current
widgets actually use. SharedPreferences is mocked before loading the unit
provider; Dashboard history fixtures return the current report model. Tutorial
overlays are completed only in fixtures that need to interact with controls
beneath them.

Before the production readiness fix, the complete host rerun passed **2,140
cases in 305 files, with zero failures or skips** (18m07s). This intermediate
result is kept separate from the final-tree rerun.

## Golden and source-style qualification

The four light/dark, expanded/collapsed Flow-control masters were reconciled with
the approved current source. The current expanded image is 430×570 rather than
the historical 430×588. Previous masters were copied into the ignored validation
artifacts before regeneration; original comparison failures remain available.
No app UI was changed to produce these replacements.

The report-only inventory contains **4,349 candidates across 305 library files**:
**3,564 migrated, 144 allowlisted, 641 pending**. All pending findings have queue
owners and none has overlapping ownership. The pending findings remain technical
debt; they were not relabeled as migrated to make tests pass.

`docs/theme-style-pending-baseline.json` pins pending file/kind counts and
normalized-snippet digests. Tests use that explicit backlog instead of incorrectly
requiring zero pending findings globally. Broad Exercise Editor divider and
Current Metrics marker rules were narrowed to their actual expressions; obsolete
anatomy-header rules were removed. Two approved Swap decorations have narrow
owners.

The ratchet retains its **18 protected scopes**. Seven reviewed fingerprints
were reconciled, with implementation-specific reasons; eleven scopes are
unchanged. It contains **199 approval records / 227 occurrences**. Fixed CLI
expectations were updated and mutation/rejection checks remain enforced.

## Android and benchmark safety

The Android core-flow suite runs Classic and Expressive with a fresh, explicitly
named integration database and preferences per case. It must run only on a
disposable emulator or dedicated test installation. At the user's request, this
pass switched from `TonosValidation20261022` / `emulator-5580` to the physical
Pixel 7. Package preflight found only `com.tonos.expressivepreview`; `com.tonos`
was absent, allowing a separate temporary integration installation. The review
package and its data are not test targets. The offline debug build caps Gradle
workers and heap to avoid the repository's much larger default heap on this
machine. The interrupted emulator attempt is not counted as a completed pass.

The legacy Expressive profile benchmark now pins tab identities/order, requires
`TONOS_DISPOSABLE_DEVICE=true`, and refuses an existing unmarked preferences
store before fixture creation. Its guard has four focused tests. A fresh
dedicated physical installation and profile-mode measurement are still required
for performance qualification; an emulator/debug flow is not a substitute.

## Final validation — 2026-10-23

| Check | Result |
| --- | --- |
| Complete host Flutter coverage on the updated app code | **2,146 passed / 0 failed / 0 skipped, 306 files**; split execution verified by exact case identity |
| Locked development compile-time content policy | Passed, exit 0 |
| Locked production compile-time content policy | Passed, exit 0 |
| Neo release opt-in, including stable Expressive availability | Passed, exit 0 |
| Invalid Neo release opt-in rejection | Passed, exit 0 |
| Final offline ARM64 integration APK build | Passed, exit 0; 5m36s |
| Physical Pixel 7, Android 16 / API 36 | **Both core-flow cases passed**, Classic and Expressive; exit 0, 3m02s |
| Global app/test/integration/tool analysis | **0 errors / 0 warnings / 79 informational findings**, exit 0 |
| Structural style inventory check | Passed; 4,349 candidates, including 641 explicitly pending technical findings |
| Protected style ratchet | Passed in enforce mode; all 18 scopes |
| Development and locked production content configuration validators | Both passed |
| Diagnostics relay schema suite | **8 passed / 0 failed / 0 skipped** |
| `git diff --check` | Passed; repeated after final documentation updates |

The final whole-suite process was interrupted after recording 1,511 successful
cases. Only **1,476 cases in 214 completed files** were retained. All unfinished
files and the last four loaded suites were rerun: **670 cases in 92 files passed**
with a successful completion record. The combined per-file multisets of test
names/counts match every current test file and all 2,140 previous cases plus the
six new readiness cases. Overlapping partial cases are not counted twice. This
is complete host coverage assembled across runs, not an uninterrupted final
whole-suite process.

The authoritative device log is `integration-device-pixel-confirmed-final.txt`.
It used the unchanged APK with SHA-256
`9F5CF05B00A282EFDB2DE5BE7FB1D7E040C0EA13E09D10DB3D1ED7C5BCA08E16`.
The temporary `com.tonos` test app was removed afterward. Package inspection
again shows only the original `com.tonos.expressivepreview` review app. Its
database and preferences were not test targets.

## Main files changed

- Application race fix: `lib/providers/selected_profile.dart`,
  `lib/screens/exercise/train_page.dart`, `lib/screens/exercise/train2_page.dart`.
- Regression and contract coverage: `test/theme/widgets/`, the directly related
  theme/inventory/CLI tests under `test/theme/`, and the four masters under
  `test/goldens/expressive_flow_editor/`.
- Inventory/ratchet records: `docs/theme-style-inventory.json`, its generated
  Markdown report, `docs/theme-style-pending-baseline.json`,
  `docs/theme-style-ratchet.json` and its documentation; shared assertions in
  `test/theme/theme_inventory_assertions.dart`.
- Device harnesses: `integration_test/core_flows_test.dart`,
  `integration_test/expressive_preview_device_test.dart`,
  `integration_test/support/disposable_benchmark_guard.dart`, and its test under
  `test/integration/`.
- Qualification documentation: this report, the initial validation report's
  follow-up notice, and `docs/testing.md`.

## Evidence and limits

Machine logs, summaries, build/device logs, retained golden masters and the
isolated database reproduction are in
`E:\projects\env_test\.build\codex_test_stabilization_20261022` (ignored local
artifacts). The original baseline remains in
`E:\projects\env_test\.build\codex_full_suite_20261022`.

The 49 implemented Expressive archetypes' visual approval classifications are
unchanged. Visual approval, source-style ownership, automated correctness,
responsive/accessibility coverage, performance and release qualification are
different claims. Neither a green suite nor reconciled goldens certify every
device, locale, accessibility setting, content state or release artifact.
The 79 analyzer infos and 641 pending style findings remain visible. The
physical-device profile benchmark was not run against the review installation;
its safety guard and harness modernization are covered, but frame performance
is still unqualified. Android backup/import checks simulate file-picker
responses, so they verify app data handling rather than the native document
picker. The debug build also emits existing Gradle/AGP/Kotlin support and
deprecation notices; build-tool migration and signed release qualification are
separate work.
Nutrition behavior is covered by the host suite, not this Android core-flow
script. The device run does not establish offline media-download behavior.

No staging, commits, pushes, resets, preview reseeding or destructive cleanup is
part of this follow-up. Existing app data, preferences, original evidence and
unrelated working-tree changes are preserved.
