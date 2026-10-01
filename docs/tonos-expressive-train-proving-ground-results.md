# Tonos Expressive Train Proving Ground — Results

**Current status (2026-10-01): TRAIN + SHELL EXPRESSIVE REFERENCE BASELINE QUALIFIED.** The user-approved visual and motion language for Train → Overview, Train → Plans, and the existing navigation shell is technically qualified for continuation. Expressive remains isolated and preview-only; no stored family, production rollout, app-wide theme completion, or other-destination visual approval is implied. TalkBack was not tested. At native 2×, horizontal navigation scrolling is required to reveal Profile and long plan names can ellipsize. Classic and Neo remain the stored theme families. The isolated preview retains Curated/Generated, light/dark, locale, text-scale, and motion controls.

## Qualification record — 2026-09-30 (historical checkpoint; superseded by section 25)

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

### Evidence and status as of 2026-09-30

- Final matched-focus Overview/Plans light/dark comparisons and five motion clips are indexed in [review-final/README.md](proposals/tonos-expressive-train-proving-ground/review-final/README.md). Historical static boards remain unqualified because of the old focus/DEBUG-ribbon mismatch; use the final matched set for preference decisions.
- Native 2× text and navigation, preview Back, plan-menu Back, Workout Timer modal Back, focused numeric-field keyboard dismissal, and the disposable Workout exit were checked on the Pixel. Profile requires a horizontal navigation swipe at 2×; some long Plans labels ellipsize.
- Native TalkBack/screen-reader announcements remain **NOT TESTED**. The host widget semantics tests are recorded separately and do not stand in for TalkBack.
- The canonical profile app `com.tonos.expressivepreview` / `tonos_expressive_preview.db` was confirmed running. The device is left on Train → Overview, Expressive / Curated / Light / 1×, reduced motion and effects off, system scale 1.15, and no active session.
- At this checkpoint, human keep/tune/reject feedback was **PENDING**. The user's later approval and the final technical qualification are recorded in section 25.

[Manual user-review checklist](proposals/tonos-expressive-train-proving-ground/qualification/manual-review.md). The user decides keep/tune/reject; technical qualification does not approve the design.

### Scope and known-issue ownership

| Classification | Issue / boundary |
|---|---|
| PRE-EXISTING | Orange plan-name light-mode contrast and Classic Train-tab touch allocation. Domain colors and Classic geometry remain unchanged. |
| PRE-EXISTING / DEFERRED | Chart accessibility debt, plus the documented Classic inactive/reduced-motion `RenderAnimatedSize` SDK case. These do not become claims of chart qualification. |
| TUNING | Human judgment of surfaces, purple action hierarchy, spring character, the 8 dp ordinary Train-header increase, 2× horizontal navigation, long-label ellipsis, and higher Expressive rapid synthetic build cost. These are user review observations, not technical blockers. |
| DEFERRED | TalkBack announcements/focus order, landscape, child-route visual qualification, full Workout/Progress visual review, and unsupported RTL-language shaping. Widget semantics and RTL layout stress do not establish those device capabilities. |
| BLOCKER | None for the Train + shell review. The earlier stalled smoke and stale-coordinate failures were harness limitations; direct physical target/workout behavior is documented. |
| PENDING AT CHECKPOINT | Human keep/tune/reject feedback; native TalkBack checks if the user wants them. Section 25 records the later approval and technical status; TalkBack remains untested. |

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

### 23. User-directed Train polish follow-up — 2026-10-01 (historical iteration; superseded by section 25)

This is the current review evidence for the explicitly requested polish to plan heatmap backgrounds, Weekly Overview composition, Focused Sets progress, and the Train action bar. It supersedes the previous stop rule only for this named Train + shell refinement; no other destination or theme work is authorized by this follow-up.

The user's local refinements were preserved in the narrow checkpoint `f192b0bd33e0105e0ed4ac908719d0b377b88b67` (`Checkpoint user Expressive layout refinements`) before implementation. Existing unrelated tracked changes and untracked artifacts remain outside this task's staging scope.

#### Current visual and interaction decisions

- Plan anatomy backgrounds blend each plan identity accent into the neutral media-placeholder surface at 8%. The blue, orange, and green identity frame remains stronger; anatomy colors and semantic meaning are unchanged.
- Weekly Overview's anatomy field blends 10% toward its plum inset tone in light mode and 16% in dark mode. The heatmap palette is resolved against that field.
- The Focused Sets active segment is a 2.2 dp rounded sinusoidal stroke with 1.5 dp amplitude and 20 dp wavelength, over a straight 1.5 dp inactive track. Its horizontal extent remains exactly `width × value`; a quiet 3 dp terminal marker closes the track. Phase is shared with the existing Overview ambient controller. Reduced Motion fixes the phase at zero while retaining the static wave.
- At normal text size, the anatomy and Focused Sets stay side by side, vertically centered, and wrap to the natural height of the taller child. They stack below 340 dp available width or from 1.35× text scale. The existing 2× stack remains covered.
- Start, Optimize, and gear retain their existing callbacks, hit bounds, and resting placement. Only their release overshoot is capped at the fixed rounded action-bar paint bounds; the inward press response is preserved.
- The approved Weekly Overview breathing and accent motion remain unchanged. The Overview, plan ordering, identity geometry, and five-destination shell are retained.

#### Pixel 7 review evidence

The preview uses package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`; normal `com.tonos` data is separate. Pixel 7 `28021FDH200228` is connected, with the preview activity currently resumed. Evidence is under `docs/proposals/tonos-expressive-train-proving-ground/amplified-review/expressive-polish-20261001/`:

- matched Overview and Plans light/dark captures;
- blue, orange, and green plan heatmap close-ups in light/dark;
- Weekly Overview heatmap, Focused Sets wave, and resting action-bar close-ups in light/dark;
- untouched Focused Sets/ambient and Weekly Overview idle clips, action tactile clip, and Reduced Motion clip with paired stills.

The action clip includes the Optimize recovery warning (dismissed), settings route, and Start into the isolated preview session and return. It does not alter the normal Tonos package or database. At this iteration the proposal was still awaiting user review; section 25 records the later reference-baseline approval. Production rollout remains unapproved.

#### Focused validation and stop condition

- Flutter 3.47.5 / bundled Dart 3.13.4 focused Train, plan, motion, and layout batch: **51 passed, 0 failed, 0 skipped, exit 0**.
- Scoped Dart analysis: **No issues found**.
- Full Flutter suite: **not run at this iteration**, intentionally deferred until review. Section 25 records the later final full-suite run.
- This was not a production promotion or SDK/theme migration. The current continuation boundary is recorded in section 25.

### 24. User tint-strength adjustment — 2026-10-01 (historical iteration; superseded by section 25)

After reviewing the previous captures, the user requested a small increase because the plan and Weekly Overview heatmap differences were hard to see. The current implementation changes only these blends:

- Plan heatmaps: 12% identity accent over the existing media-placeholder surface for blue, orange, and green plans.
- Weekly Overview anatomy field: 15% toward the plum inset tone in light mode and 20% in dark mode.

The actual anatomy data colors, plan-card colors and geometry, screen layout, action bar, wave, ambient motion, and Reduced Motion behavior remain unchanged.

The updated Preview was freshly built with Flutter 3.47.5 and installed on Pixel 7 `28021FDH200228` as `com.tonos.expressivepreview`, using the isolated `tonos_expressive_preview.db`. Normal `com.tonos` data was not targeted. Latest matched-state captures are under `docs/proposals/tonos-expressive-train-proving-ground/amplified-review/tint-adjustment-20261001/`:

- [Overview light](proposals/tonos-expressive-train-proving-ground/amplified-review/tint-adjustment-20261001/overview-light.png) and [dark](proposals/tonos-expressive-train-proving-ground/amplified-review/tint-adjustment-20261001/overview-dark.png).
- [Plans light](proposals/tonos-expressive-train-proving-ground/amplified-review/tint-adjustment-20261001/plans-light.png) and [dark](proposals/tonos-expressive-train-proving-ground/amplified-review/tint-adjustment-20261001/plans-dark.png), each showing the blue, orange, and green active-plan rows.

The directly affected plan/Weekly Overview tests passed **10/10**, with scoped Dart analysis reporting no issues. At that point the full suite was still deferred and the adjustment awaited review. Section 25 records the user's later approval and final full-suite qualification; section 23 preserves the preceding tint values.

### 25. Final Train + shell qualification — 2026-10-01

The user approved the Train + shell visual/motion language as the current reference baseline. This final gate freezes that language for continuation. It does not approve production rollout, persistence, app-wide Expressive, or a visual redesign of Active Workout, Progress, Catalog, Logbook, or Profile.

#### Host gates

- Pinned Flutter **3.47.5** / bundled Dart **3.13.4**.
- Final uninterrupted `flutter test --no-pub --reporter compact`: **1,295 passed, 0 failed, 0 skipped, exit 0**, elapsed **00:11:53.386**. Log: `C:\Users\talh7\AppData\Local\Temp\tonos-full-test-final-20261001.log`.
- Repository-wide pinned `dart analyze`: **0 errors, 0 warnings, 81 informational notices, exit 0**. Existing informational deprecation notices were not expanded into unrelated cleanup. Log: `C:\Users\talh7\AppData\Local\Temp\tonos-final-dart-analyze-20261001.log`.
- Inventory: **296 Dart files, 2,440 candidates, 130 allowlisted, 2,310 classified/migrated, 0 pending, 0 unassigned, 0 overlaps**; 992 candidates are in exactly one review queue and 1,448 outside configured queues. Ratchet enforcement passed for **18 protected files, 158 fingerprint entries, and 180 current occurrences**, with exact maps. Theme contracts, extension completeness, Classic/Neo/default-root parity, preview persistence boundaries, reduced-motion and Workout compatibility tests passed in the suite.
- Focused gates also passed: **75** Train/shell/motion/presentation tests, **53** inventory-contract tests, **3** ratchet CLI tests, and **1** ambient visibility qualification test. The integration-test source passed scoped analysis after its last harness correction.
- `git diff --check` passed before final staging; the qualification commit repeats the staged diff check.

An early full-suite run exposed stale source-rule expectations and `pumpAndSettle` assumptions around intentionally continuous ambient motion. Those were corrected in tests/harness only, narrowly preserving Classic, Neo, and explicit Expressive contracts. The final complete run above is the authoritative suite result.

#### Motion, accessibility, parity, and persistence

- Automated lifecycle coverage exercises visibility threshold, selected Overview versus Plans, inactive TickerMode, app inactive/resumed lifecycle, route visibility, and disposal. Plans retains its existing scroll position. The Focused Sets phase is shared; repainting remains local to the ambient/progress layers.
- Reduced Motion coverage confirms ambient/accent movement stops, the wave phase freezes while its static wavy geometry remains, nonessential motion resolves immediately, callbacks remain responsive, and static Expressive identity remains present.
- Responsive/accessibility widget coverage spans 1×, 1.15×, 1.5×, 2× and 320 dp, including long French labels, RTL layout direction, semantics/value stability and reachable navigation targets. Native Android 2× text/navigation and key Back/keyboard checks are recorded below. **TalkBack was not tested**; landscape and unsupported RTL-language shaping remain deferred.
- Classic, Neo, and generic-root behavior remain separate. Expressive uses explicit in-memory preview identity. Saved Classic/Neo values and preference sentinels remain unchanged; no Expressive preference, migration, Appearance choice, or promotion was added.
- Workout remains a compatibility smoke only. The adopted 180 ms reveal, 48 × 48 dp completion target, anchored menu, non-final-set-open/final-set-collapse rule, completion retention on reopen, and isolated data path remain intact; no Workout visual adaptation occurred.

#### Pixel 7 and performance

- Pixel 7 `28021FDH200228`, Android 16, 60 Hz, 411.43 × 914.29 dp at DPR 2.625. The successful smoke-only profile drive returned exit 0: the outer Collapse target and exercise menu each measured **48 × 48 dp** and were hit-testable; the same collapse target was reacquired after menu dismissal; expansion/collapse changed card height from **96 dp to 400 dp** and back; the completed-session menu was reachable. The drive reported no active draft after its cleanup. Its smoke selector explicitly sets `timingsMeasured:false`; it is functional compatibility evidence, not a profile timing run.
- The prior matched profile data remains the only timing matrix. Settled frame-cost results were comparable but above budget in both looks; the synthetic 80 ms rapid retargeting produced more Expressive build-budget exceedances (50/212 vs 34/212). Four approximately five-second quiet-idle observation windows recorded zero Flutter frame timings. These are bounded Flutter `FrameTiming` observations; they do not establish zero jank, compositor deadlines, or physical input latency. No runaway idle frame stream was observed.
- The canonical profile preview was rebuilt from `lib/expressive_preview_main.dart`, manifest-verified, installed only to `com.tonos.expressivepreview`, and visually checked running at Train → Overview in Light / Expressive / Curated / 1×, Reduced Motion and Effects Off disabled, no overlay or workout. APK SHA-256: `63C1202CF793FF5CB38568A43255D0C119B858B09059AA888C71C2F47646CD42`. Database remains `tonos_expressive_preview.db`; normal/internal Tonos data was not targeted.

#### Review assets and handoff

The final Focused Sets wave captures and normal/reduced-motion clips remain indexed in [the wave refinement review](proposals/tonos-expressive-train-proving-ground/amplified-review/manual-review.md#focused-sets-wave-polish--2026-10-01). Earlier matched Overview/Plans stills, plan identity/heatmap evidence and tactile clips remain in that guide and [review-final index](proposals/tonos-expressive-train-proving-ground/review-final/README.md). The current specification is summarized in [the Expressive reference baseline](tonos-expressive-reference-baseline.md).

The approved Train + shell slice is technically qualified for continuation. It is not production released or a completed app-wide theme. The next phase is documentation/planning for adapting this approved language to Active Workout; this qualification did not begin that implementation.
