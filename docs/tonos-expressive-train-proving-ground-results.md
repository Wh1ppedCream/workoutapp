# Tonos Expressive Train Proving Ground — Results

**Status: safe resumable qualification checkpoint; final device/user review remains pending (2026-09-30).** The user stopped the broader campaign to preserve usage. This proving ground renders the production Train page and app shell with an in-memory Expressive preview identity. Classic and Neo remain the stored theme families. The preferred visual treatment is Curated purple; Generated, light/dark, locale, text scale, and motion controls remain available in the isolated preview.

## Qualification record — 2026-09-30

Qualification started at `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9`, synchronized with `origin/feature/classic-m3e`. The SDK remains Flutter 3.47.5 / bundled Dart 3.13.4, with locked `material_ui` 1.5.0. No production source, palette, spring recipe, stored family, dependency, or SDK changed in this qualification pass.

### Host gates

- Initial uninterrupted full suite: **1,254 passed, 1 failed, 0 skipped, exit 1**, 834.154 seconds. Classification: **TEST HARNESS ISSUE**. The source-rule test expected a direct `panelRaised` assignment; the proving ground intentionally selects Expressive `card` versus the retained `panelRaised` branch. The corrected test asserts all three explicit branches and retains the other semantic/data ownership checks. Its focused rerun passed **18/18**, exit 0. This failed initial full run is not reported as a pass.
- Final uninterrupted full suite: **1,255 passed, 0 failed, 0 skipped, exit 0**, **1,274.075 seconds** (21m 14.075s). It used `flutter test --no-pub --reporter json`, default concurrency, normal C: TEMP/TMP, and frozen source. The 239 hidden suite-load events are excluded from the test total. The initial failed run remains separately recorded above.
- Latest repository-wide pinned `dart analyze`: **0 errors, 0 warnings, 84 infos, exit 0**, **49.135 seconds**, after the outer-target harness correction. Existing informational diagnostics were retained. The later test-only smoke selector receives scoped analysis/build verification; it does not change production or normal-suite inputs.
- Direct inventory: **294 files, 2,294 candidates, 130 allowlisted, 2,164 migrated, 0 pending/unassigned**, exit 0. Ratchet: **18 files, 139 approvals, 137 unique hashes, 156 occurrences**, exit 0.
- Accessibility focused runs: **28 existing tests + 1 new test**, zero failures, exit 0 in their separate runs. The added 320 dp test uses 11 long French labels, RTL layout direction, one semantic action per destination, selected-state assertions, reachable 48 dp targets, and a monotonic nonlinear stress curve. That curve is not Android's exact OS scaling model.

Raw host results and command metadata: [validation summary](proposals/tonos-expressive-train-proving-ground/qualification/validation/validation-summary.md). Accessibility scope and limitations: [accessibility review](proposals/tonos-expressive-train-proving-ground/qualification/accessibility-review.md).

### Device gates

The isolated profile integration APK rebuilt successfully, with manifest `com.tonos.expressivepreview`. The initial driver collected all four quiet-idle windows and 16 matched light/dark interaction phases, then exited 1 after a missed tap in the separate returned-home ongoing-session menu smoke. The second driver passed that route after a narrow settle/hit-test correction, collected all timing phases again, then exited 1 because its collapse-control assertion measured the 40 dp inner Tooltip/Material rather than the padded outer `IconButton`. The pinned Material button sources (`material_ui` 1.5.0 `lib/src/button_style_button.dart` and the matching Flutter SDK implementation) confirm the separate `_InputPadding` hit-region owner; the harness now measures the outer control and contains edge-tap assertions without lowering its 48 dp requirement. No production edit was made for either finding. Both failed attempts remain preliminary phase observations, not end-to-end passes. Only the bounded Workout target/compatibility proof was attempted afterward, through a test-only smoke selector that skips all timing/warm-up loops and extra routes. Final matched visual captures, recordings, native accessibility checks, and the canonical installed user-review build remain pending under the user-directed checkpoint.

**Bounded follow-up outcome:** the smoke-only selector builds in profile mode, passes scoped analysis, and retains the safety guard and 48 dp requirements. Its Pixel attempt stalled after fixture setup for over five minutes, before runtime/Workout geometry output, with no Flutter exception observed in the inspected logcat. It was interrupted under the checkpoint instruction (observed exit 1); no new device campaign was started. The outer-control size and edge-tap proof are therefore **PENDING**, not a device pass. The actual stall cause remains unclassified; this is not evidence of a production 40 dp target. Host Workout regressions remain green, but the corrected device integration assertions have not yet completed.

The installed artifact is an **integration-test profile APK**, not the canonical interactive user-review app. Its identity/hash, stopped-run log, and installation state are recorded in the device qualification note. It must not be presented as a finished review setup.

### Preserved matched Pixel profile measurements

The second run used Pixel 7 **`28021FDH200228`**, Android 16, **60 Hz active** / **16,667 µs** budget (90 Hz supported), 411.43×914.29 dp at DPR 2.625. Both looks were warmed before sampling, with matched seeded data and Classic / Expressive / Expressive / Classic batches in both light and dark. No screen recording ran during timing. All measured windows began after the host suite ended; the first idle window began 65 seconds later. Thermal status was 0, USB power was connected, and GC events occurred during the run.

Four batches per look/phase are pooled below. p95 ranges are the minimum–maximum of the four **batch** p95 values, not a pooled percentile. Counts are build/raster `FrameTiming` budget exceedances; they are not a measured count of compositor missed presentation deadlines. Clusters group consecutive samples whose build or raster cost exceeds budget.

| Look / phase | Frames | Build p95 range | Build over budget | Raster p95 range | Raster over budget | Slow clusters |
|---|---:|---:|---:|---:|---:|---:|
| Classic settled | 915 | 41.89–50.38 ms | 98 (10.71%) | 19.38–20.25 ms | 326 (35.63%) | 171 |
| Expressive settled | 911 | 46.16–49.72 ms | 103 (11.31%) | 19.42–20.48 ms | 330 (36.22%) | 174 |
| Classic rapid | 212 | 16.67–23.25 ms | 34 (16.04%) | 14.53–15.56 ms | 2 (0.94%) | 34 |
| Expressive rapid | 212 | 21.47–25.75 ms | 50 (23.58%) | 13.25–15.25 ms | 1 (0.47%) | 51 |

All four Classic/Expressive × light/dark idle actions observed **zero frame timings**. Each action lasted approximately three seconds; the timing callback remained attached for a further two-second flush, so the observation covers about five seconds. This is a bounded idle observation, not proof that all offscreen states are animation-free.

Settled costs are comparable and materially exceed budget in both looks. Expressive had more rapid build-budget exceedances in this run; that finding is retained, not tuned away. These samples do not prove zero jank, faster Expressive performance, or physical input latency. The rapid **80 ms** value is configured `WidgetTester` pump cadence, not measured touch latency. Start press/cancel is included in the mixed timing loop; the real Start callback/route is a separate untimed functional smoke. The driver later failed its inner-box measurement assertion, so the timing phases are completed observations from a failed functional attempt, not a successful complete driver.

Raw logs: [initial profile attempt](proposals/tonos-expressive-train-proving-ground/qualification/logs/profile-driver-2026-09-30.txt), [matched second attempt](proposals/tonos-expressive-train-proving-ground/qualification/logs/profile-driver-rerun-2026-09-30.txt). Device build/runtime detail and bounded proof: [device qualification](proposals/tonos-expressive-train-proving-ground/qualification/device-qualification.md).

### Evidence and unfinished review work

- Existing [static capture set](proposals/tonos-expressive-train-proving-ground/static/) retains 19 PNGs from the implementation checkpoint, including Overview/Plans light/dark raw captures and five boards. They are historical visual/structure evidence. The Profile focus/highlight mismatch and DEBUG ribbon are retained and disclosed; the boards are **not final matched-focus comparisons**.
- Fresh matched-focus Overview/Plans/shell comparisons: **PENDING**. No cosmetic recapture campaign was started after the course change.
- Motion clips for tabs, navigation, Start, rapid retargeting, and reduced motion: **PENDING; none captured**. No video was recorded during timing.
- Actual Android OS large/nonlinear text, soft-keyboard/focus/IME, native Back, TalkBack/screen-reader smoke, and the canonical installed interactive user-review build: **PENDING**. Widget-test accessibility and automated integration callbacks are not represented as those native checks.
- Human motion/design keep/tune/reject feedback: **PENDING**. This checkpoint does not approve Expressive or make it ready for manual review.

[Manual user-review checklist](proposals/tonos-expressive-train-proving-ground/qualification/manual-review.md). The user decides keep/tune/reject; technical qualification does not approve the design.

### Scope and known-issue ownership

| Classification | Issue / boundary |
|---|---|
| PRE-EXISTING | Orange plan-name light-mode contrast and Classic Train-tab touch allocation. Domain colors and Classic geometry remain unchanged. |
| PRE-EXISTING / DEFERRED | Chart accessibility debt, plus the documented Classic inactive/reduced-motion `RenderAnimatedSize` SDK case. These do not become claims of chart qualification. |
| TUNING | Human judgment of surfaces, purple action hierarchy, spring character, the 8 dp ordinary Train-header increase, and extreme configured-navigation density. The five-item 2× navigation remains the corrected approximately 72 dp; no implementation change required a new measurement. |
| DEFERRED | Child-route visual qualification, landscape, native screen-reader announcements/focus order, and unsupported RTL-language shaping. Widget semantics and RTL layout stress do not establish those device capabilities. |
| BLOCKER (device proof only) | The smoke-only integration attempt stalled after fixture setup and was interrupted. Its cause is not diagnosed. It blocks a passing corrected native target/Workout smoke, not saving the checkpoint; no production-design fix is implied. |
| PENDING / DEFERRED QUALIFICATION | Bounded outer-target device proof, final matched-focus captures/recordings, physical OS-scale/keyboard/TalkBack checks, canonical interactive user-review build, and human motion/design feedback. The broader campaign was stopped by user instruction. |

Expressive remains explicitly rendered and nonpersisted. Normal root/default-null behavior, Classic/Neo stored selection, generic Material fallback, and domain data ownership remain subject to the retained regression gates. Workout is only a compatibility smoke target: its adopted controlled 180 ms reveal, 48×48 completion target, anchored menu, and final-set collapse are preserved rather than redesigned.

### Resume and publishing

Commit only the qualification harness, accessibility test, exact theme-role contract correction, and these evidence/docs. Resolve the latest checkpoint SHA with `git log -1 --format='%H %s' -- docs/tonos-expressive-train-proving-ground-handoff.md`; verify the normal branch push with `git ls-remote origin refs/heads/feature/classic-m3e`. No protected user work belongs in that commit. The final chat report records the verified commit/remote values.

Resume from this qualification checkpoint. Complete only any remaining Pixel evidence/native accessibility checks, then present the existing Train + shell Expressive proving ground to the user for keep/tune/reject feedback. Do not expand Expressive to another screen before user review.

## What the current preview demonstrates

- Train Overview uses the existing seven-day focus card followed by active presets. Plans uses real active/archive sections and the existing premade, generated, and manual plan actions.
- The production five-destination shell is preserved. At 2x text, its corrected five-destination bar measures 72 dp in the 320 dp and Pixel logical-width cases. The configurable 11-destination matrix passes, but its exact post-fix height was not remeasured.
- Curated surfaces, Train tabs, navigation selection, and the Start corner response are implemented. Selection uses `mass=1`, stiffness 650, damping ratio 0.8; Start recovery uses `mass=1`, stiffness 800, damping ratio 0.72. These are current code values, not human-qualified motion results.
- Pixel 7 static captures are in `docs/proposals/tonos-expressive-train-proving-ground/static/`. They include Overview and Plans in light/dark plus comparison boards. The boards have a focus/hover mismatch on the Profile destination, so they are not final matched-state evidence.

## Implementation-checkpoint validation (historical)

| Gate | Current evidence |
|---|---|
| Root/overlay qualification | 13/13 passed in the current bounded run. |
| Train presentation + navigation | 14/14 passed in the current bounded run; includes five-destination density cases and the 11-destination matrix. |
| Chart, preview architecture, Workout compatibility | 15/15 passed in the current bounded run (1 + 11 + 3). |
| Motion / accessibility | 13/13 passed in the current bounded run (12 + 1). |
| Targeted analyzer | Exit 0: 0 errors, 0 warnings, 4 existing informational notices in Train/WeightCard. Earlier reference-file analysis had 11 informational deprecations; that is historical, not this run. |
| Direct theme inventory / ratchet | 294 inventory files, 2,294 candidates, 0 pending; enforcement passed for 18 files, 139 approvals, 137 hashes, 156 occurrences. |
| Current combined bounded run | **163 passed, 0 failed, 0 skipped, exit 0**, 140.66 seconds, Flutter 3.47.5 / bundled Dart 3.13.4, default concurrency and normal C: TEMP/TMP. The four stale inventory/ratchet fixture expectations were corrected exactly; no allowlist expansion or enforcement weakening. |
| Diff whitespace | `git diff --check` passed, exit 0. |
| Full Flutter suite | Pending; not run. |
| Profile-mode Pixel performance | Pending; no profile driver run, profile measurements, or interaction video. |

## Implementation-checkpoint device evidence (historical)

The Pixel 7 (`28021FDH200228`, Android 16, 1080×2400 at 420 dpi) has the isolated preview package `com.tonos.expressivepreview`. The last verified installed update was debug APK SHA-256 `6942579267B697B2EE89F49F4E921A77322A168C7EC359A051B6B3A904E64CC3`; device APK bytes were not independently rehashed. The profile integration APK SHA-256 `D404DFBB2022FE056611F756BDB37B08C831862EDD91824CEAC2021FFEE5CE08` was manifest-verified but never installed, and predates the navigation measurement correction and final startup guard.

Human-speed spring visibility, refresh/thermal-aware profile frame metrics, and focus-matched recaptures remain unqualified. The orange plan-name light-mode contrast is pre-existing and unchanged. A narrow Expressive-only fallback handles the Flutter 3.47.5 inactive/reduced-motion chart disclosure case; the corresponding Classic `RenderAnimatedSize` issue is recorded as pre-existing. Child routes are real production pages that inherit the Expressive root theme and ordinary Tonos/Material widgets; their layouts were not redesigned and their visual quality has not been qualified.

See [the handoff](tonos-expressive-train-proving-ground-handoff.md) for the exact runner/build commands, architecture and file map, protected working-tree hashes, pending gate procedure, and continuation steps.

Implementation checkpoint: `9cd78807922e57602f4d9bbf32d417afc40386f9` — `Add isolated Tonos Expressive proving ground`. This results document and the retained 19 PNGs accompany `Record Expressive proving-ground checkpoint`; resolve that commit and the current remote using the handoff's section 2 commands.
