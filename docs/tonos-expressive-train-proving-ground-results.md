# Tonos Expressive Train Proving Ground — Results

**Status: READY WITH KNOWN LIMITATIONS for user review (2026-09-30).** The final matched Train Overview/Plans captures, five motion clips, bounded native checks, and canonical Pixel review setup are ready. TalkBack is untested; native 2× navigation needs a horizontal swipe to reveal Profile and some long plan names ellipsize. This proving ground renders the production Train page and app shell with an in-memory Expressive preview identity. Classic and Neo remain the stored theme families. The preferred visual treatment is Curated purple; Generated, light/dark, locale, text scale, and motion controls remain available in the isolated preview.

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

The initial profile driver collected its idle/interaction phases and later failed a separate route/menu assertion. The second driver passed that route and collected the matched timing phases, then failed because the harness measured the 40 dp inner Tooltip/Material instead of the padded outer `IconButton`. Pinned Material button sources confirm the separate `_InputPadding` hit-region owner. A bounded smoke retry then exposed a stale-coordinate weakness after menu dismissal. The harness now reacquires and measures the same card's outer control after the menu closes; no production code changed. Direct Pixel checks subsequently confirmed the actual outer target and its edge behavior, the real Workout final-set flow, and menu isolation. The corrected harness receives scoped analysis; the full timing matrix was not restarted.

**Direct Pixel outcome:** collapse target 48 × 48 dp; center, left, and right edge taps changed the intended state; adjacent menu edge opened only the menu; non-final completion stayed expanded; final-set completion auto-collapsed and retained both completed states on reopen. Native 2× scrolling exposed Overview/Plans content and their controls. A horizontal nav swipe exposed Profile and its target opened the Profile destination. The canonical profile preview is installed and was left running at Train → Overview with the normal review settings and no active workout.

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

### Evidence and remaining user review

- Final matched-focus Overview/Plans light/dark comparisons and five motion clips are indexed in [review-final/README.md](proposals/tonos-expressive-train-proving-ground/review-final/README.md). Historical static boards remain unqualified because of the old focus/DEBUG-ribbon mismatch; use the final matched set for preference decisions.
- Native 2× text and navigation, preview Back, plan-menu Back, Workout Timer modal Back, focused numeric-field keyboard dismissal, and the disposable Workout exit were checked on the Pixel. Profile requires a horizontal navigation swipe at 2×; some long Plans labels ellipsize.
- Native TalkBack/screen-reader announcements remain **NOT TESTED**. The host widget semantics tests are recorded separately and do not stand in for TalkBack.
- The canonical profile app `com.tonos.expressivepreview` / `tonos_expressive_preview.db` was confirmed running. The device is left on Train → Overview, Expressive / Curated / Light / 1×, reduced motion and effects off, system scale 1.15, and no active session.
- Human keep/tune/reject feedback remains **PENDING**. Technical qualification does not approve Expressive or authorize expansion to another destination.

[Manual user-review checklist](proposals/tonos-expressive-train-proving-ground/qualification/manual-review.md). The user decides keep/tune/reject; technical qualification does not approve the design.

### Scope and known-issue ownership

| Classification | Issue / boundary |
|---|---|
| PRE-EXISTING | Orange plan-name light-mode contrast and Classic Train-tab touch allocation. Domain colors and Classic geometry remain unchanged. |
| PRE-EXISTING / DEFERRED | Chart accessibility debt, plus the documented Classic inactive/reduced-motion `RenderAnimatedSize` SDK case. These do not become claims of chart qualification. |
| TUNING | Human judgment of surfaces, purple action hierarchy, spring character, the 8 dp ordinary Train-header increase, 2× horizontal navigation, long-label ellipsis, and higher Expressive rapid synthetic build cost. These are user review observations, not technical blockers. |
| DEFERRED | TalkBack announcements/focus order, landscape, child-route visual qualification, full Workout/Progress visual review, and unsupported RTL-language shaping. Widget semantics and RTL layout stress do not establish those device capabilities. |
| BLOCKER | None for the Train + shell review. The earlier stalled smoke and stale-coordinate failures were harness limitations; direct physical target/workout behavior is documented. |
| PENDING | Human keep/tune/reject feedback; native TalkBack checks if the user wants them. No other destination should be added before user review. |

Expressive remains explicitly rendered and nonpersisted. Normal root/default-null behavior, Classic/Neo stored selection, generic Material fallback, and domain data ownership remain subject to the retained regression gates. Workout is only a compatibility smoke target: its adopted controlled 180 ms reveal, 48×48 completion target, anchored menu, and final-set collapse are preserved rather than redesigned.

### Resume and publishing

Commit only the qualification-owned harness correction, current device/review notes, final screenshots/clips, and handoff/results docs. The 15 protected user Dart files and five unrelated untracked groups remain excluded. Verify the normal branch push with `git ls-remote origin refs/heads/feature/classic-m3e`; no force push, master merge, or malformed-ref repair.

The existing Train + shell Expressive proving ground is ready for user keep/tune/reject feedback. Do not expand Expressive to another screen before that review.

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
