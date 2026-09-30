# Tonos Expressive Train Proving Ground — Results

**Status: recovered implementation checkpoint, not final qualification (2026-09-30).** This proving ground renders the production Train page and app shell with an in-memory Expressive preview identity. Classic and Neo remain the stored theme families. The preferred visual treatment is Curated purple; Generated, light/dark, locale, text scale, and motion controls remain available in the isolated preview.

## What the current preview demonstrates

- Train Overview uses the existing seven-day focus card followed by active presets. Plans uses real active/archive sections and the existing premade, generated, and manual plan actions.
- The production five-destination shell is preserved. At 2x text, its corrected five-destination bar measures 72 dp in the 320 dp and Pixel logical-width cases. The configurable 11-destination matrix passes, but its exact post-fix height was not remeasured.
- Curated surfaces, Train tabs, navigation selection, and the Start corner response are implemented. Selection uses `mass=1`, stiffness 650, damping ratio 0.8; Start recovery uses `mass=1`, stiffness 800, damping ratio 0.72. These are current code values, not human-qualified motion results.
- Pixel 7 static captures are in `docs/proposals/tonos-expressive-train-proving-ground/static/`. They include Overview and Plans in light/dark plus comparison boards. The boards have a focus/hover mismatch on the Profile destination, so they are not final matched-state evidence.

## Validation status

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

## Device and known limits

The Pixel 7 (`28021FDH200228`, Android 16, 1080×2400 at 420 dpi) has the isolated preview package `com.tonos.expressivepreview`. The last verified installed update was debug APK SHA-256 `6942579267B697B2EE89F49F4E921A77322A168C7EC359A051B6B3A904E64CC3`; device APK bytes were not independently rehashed. The profile integration APK SHA-256 `D404DFBB2022FE056611F756BDB37B08C831862EDD91824CEAC2021FFEE5CE08` was manifest-verified but never installed, and predates the navigation measurement correction and final startup guard.

Human-speed spring visibility, refresh/thermal-aware profile frame metrics, and focus-matched recaptures remain unqualified. The orange plan-name light-mode contrast is pre-existing and unchanged. A narrow Expressive-only fallback handles the Flutter 3.47.5 inactive/reduced-motion chart disclosure case; the corresponding Classic `RenderAnimatedSize` issue is recorded as pre-existing. Child routes are real production pages that inherit the Expressive root theme and ordinary Tonos/Material widgets; their layouts were not redesigned and their visual quality has not been qualified.

See [the handoff](tonos-expressive-train-proving-ground-handoff.md) for the exact runner/build commands, architecture and file map, protected working-tree hashes, pending gate procedure, and continuation steps.

Implementation checkpoint: `9cd78807922e57602f4d9bbf32d417afc40386f9` — `Add isolated Tonos Expressive proving ground`. This results document and the retained 19 PNGs accompany `Record Expressive proving-ground checkpoint`; resolve that commit and the current remote using the handoff's section 2 commands.
