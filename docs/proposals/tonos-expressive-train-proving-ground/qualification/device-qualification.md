# Expressive Pixel Device Qualification

**Status: Pixel review preparation complete with TalkBack deferred.** The direct device checks subsequently confirmed the real collapse target and workout completion behavior, and the final matched Train comparisons, motion clips, native 2× reachability checks, and canonical review setup are saved under `review-final/`. The integration harness was corrected to reacquire and remeasure the same card's outer collapse IconButton after the menu closes; only scoped Dart analysis is required for this test-only correction. Earlier failed integration attempts are retained as historical harness evidence, not production failures.

The canonical preview package is installed and left on Train → Overview in the intended review state. Native TalkBack announcements were not tested. The complete scope and exact assets are indexed in [the final review evidence](../review-final/README.md).

## Source and build checkpoint

- Starting checkpoint: branch `feature/classic-m3e`; verified HEAD and `origin/feature/classic-m3e` at qualification start: `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9`.
- Toolchain: Flutter 3.47.5 with bundled Dart 3.13.4. Device commands used Pixel 7 serial `28021FDH200228`.
- The only source file changed in this lane is `integration_test/expressive_preview_device_test.dart`. Its current SHA-256 is `3564A5B6299466D372F01CD99245F4F8D323045807349EE1B3CD80B63B819CAC`. Changes are limited to device-qualification harness coverage: runtime display metadata, light/dark idle and matched timing phases, rapid retargeting, session-menu settle/hit-test checks, measured outer IconButton targets and edge taps, bounded app-start readiness checkpoints, cleanup route settling, and the default-off `TONOS_PREVIEW_DEVICE_SMOKE_ONLY` selector.
- Focused Dart analysis of the harness exited 0 with “No issues found!”; `git diff --check` exited 0. The repository-wide post-harness analyzer log is in `validation/logs/dart-analyze-post-device-harness-machine.txt` and its metadata companion.
- The current APK was built with the normal profile/isolated-preview defines plus `TONOS_PREVIEW_DEVICE_SMOKE_ONLY=true`, using `--no-pub`. Build exited 0 in 163.7 seconds. APK: `build/app/outputs/flutter-apk/app-profile.apk`, 172,994,990 bytes; package `com.tonos.expressivepreview`, versionCode 6/versionName 1.0.1; SHA-256 `A493D82CFCAAD26783BB5190B5958FBCA8A30627C549146954A335683AB46D3B`. Build details are in `logs/profile-smoke-build-2026-09-30.txt`.
- The earlier outer-target-correction all-matrix APK (`40D4133EEFD93E3D1ADC092ED73C119477A3E698CC13F2768FCBE71ACB32E68D`) was verified but never installed or driven after the scope change. The smoke-only APK above replaced it for the narrow attempt.

## Pixel and installed-package state

- Pixel 7, Android 16/API 36; display 1080 × 2400 physical px, 420 dpi, 411.43 × 914.29 logical dp, DPR 2.625. Active refresh rate was 60 Hz (90 Hz supported), giving a 16,667 µs frame budget.
- Font scale was 1.15 when inspected. The device was unlocked. Battery was 80% and USB powered; thermal status was 0 before the timing rerun. Cached BIG/MID/LITTLE readings were stale at 54/53/54 °C; current HAL readings were 30/31/31 °C. No persistent stay-awake or font-scale setting was changed.
- The smoke driver installed only `com.tonos.expressivepreview`. Read-only package inspection afterward reported versionCode 6/versionName 1.0.1, `lastUpdateTime=2026-09-30 11:03:17`, and the expected preview package path. This package remains installed. After stopping the stalled attempt, `pidof com.tonos.expressivepreview` returned no process. The test setup used the isolated `tonos_expressive_preview.db`; the normal and internal app packages/data were not targeted.
- Flutter retained the normal C: TEMP/TMP locations. No cache or filesystem cleanup was performed. Build-start disk context was C: 2.50 GiB free and E: 70.1 GiB free.

## Timing evidence

The raw logs are [`profile-driver-2026-09-30.txt`](logs/profile-driver-2026-09-30.txt) and [`profile-driver-rerun-2026-09-30.txt`](logs/profile-driver-rerun-2026-09-30.txt). Each emitted four quiet-idle and sixteen interaction batches before its later functional failure. The first run overlapped the host suite. The second run's idle windows began at 2026-09-30 14:29:14.554Z, about 65 seconds after the host suite ended, so its timing windows did not overlap the suite. No screen video was active during either run.

Saved console transcripts have trailing whitespace removed for the Git whitespace gate; timing values and diagnostic content are preserved.

Run 2 recorded four ~3.004-second idle windows with `idleFrameCount=0` for each Classic/Expressive × light/dark pairing. This is an observation from those windows, not a requirement that the OS render zero frames.

| Run 2 interaction phase | Theme | Frames | Build over budget | Raster over budget | Slow-frame clusters | Per-batch build p95 range | Per-batch raster p95 range |
|---|---|---:|---:|---:|---:|---:|---:|
| Settled mixed interactions | Classic | 915 | 98 | 326 | 171 | 41,892–50,378 µs | 19,382–20,247 µs |
| Settled mixed interactions | Expressive | 911 | 103 | 330 | 174 | 46,156–49,722 µs | 19,423–20,482 µs |
| Rapid tab/navigation retargeting | Classic | 212 | 34 | 2 | 34 | 16,671–23,248 µs | 14,529–15,561 µs |
| Rapid tab/navigation retargeting | Expressive | 212 | 50 | 1 | 51 | 21,470–25,754 µs | 13,254–15,252 µs |

P95 columns are the minimum and maximum of four per-batch p95 values for that theme and phase, not a pooled percentile. Settled phases pump and settle each interaction. Rapid phases retarget at an 80 ms cadence, assert the selected state after each input, then settle after the sequence. These are Flutter frame build/raster observations, not physical input-to-pixel or callback-latency measurements. The settled Start measurement presses then cancels the pointer; the actual Start → Session/discard flow is separate functional coverage, not a latency result. The raw run ended before `binding.reportData` assignment, so the table is a transcription of emitted phase records; [`profile-rerun-summary-2026-09-30.json`](logs/profile-rerun-summary-2026-09-30.json) records the pooled counts and provenance.

The second run reached the real disposable-session route/discard flow, then failed at a harness assertion that measured an inner Tooltip/Material box as 40 dp. Review established that the harness had selected the inner visual bounds instead of the Material 3 IconButton's padded 48 dp tap target. The source now measures outer IconButton bounds and exercises edge taps, but the physical proof has not run.

## Smoke-only attempt and evidence limits

The smoke-only driver log is [`profile-smoke-driver-2026-09-30.txt`](logs/profile-smoke-driver-2026-09-30.txt). It started at `2026-09-30T11:03:04.7126206-04:00`, installed the APK above, and ran the test named `smoke-only Workout compatibility on the isolated preview database`. The log shows fixture seeding and `fixtures.reviewPreferences` completed at +3,511 ms, followed only by a GC line. It contains no runtime viewport metadata, Workout geometry, outer-target measurements, or compatibility-phase output. Filtered logcat showed no Flutter exception. After more than five minutes without progress, the PowerShell driver was interrupted with Ctrl-C and returned exit code 1; the raw driver log has no terminal exit marker because the pipeline stopped with the process. The preview app was then force-stopped; package metadata confirms it remains installed. This is a stalled/incomplete attempt, not a pass or a demonstrated application defect.

### Bounded startup and Workout smoke rerun

The harness now logs checkpoints around the identity guard, theme load, fixture setup, app mount, route readiness, and smoke presentation setup. It replaces the initial unbounded `pumpAndSettle()` with a bounded wait for the concrete `TrainPage` route (up to 120 pumps at 250 ms), because `MainScreen` can show an indeterminate progress indicator while `NavBarConfig` loads. The smoke presentation change uses one fixed 250 ms pump. This makes startup completion explicit; it does not establish that the previous stall was definitively caused by that spinner.

- Focused Dart analysis passed with no issues using Flutter 3.47.5 / Dart 3.13.4. Log: [`device-startup-bounded-analyze-2026-09-30.txt`](logs/device-startup-bounded-analyze-2026-09-30.txt).
- A first rebuild exited 1 in 13.559 seconds because the Android preview environment flags were omitted. The corrected profile build set `TONOS_ANDROID_INTERNAL_BUILD=false` and `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`; it exited 0 in 215.482 seconds. Log: [`profile-smoke-bounded-build-retry-2026-09-30.txt`](logs/profile-smoke-bounded-build-retry-2026-09-30.txt).
- The fresh APK was verified before installation: package `com.tonos.expressivepreview`, versionCode 6/versionName 1.0.1, 172,994,990 bytes, SHA-256 `F9622BCF14A03A452DEAB08B11FB4638387D5E424B44EF4C068C789785B04E9C`.
- On Pixel 7 serial `28021FDH200228`, startup reached `TrainPage ready` at +2,575 ms and logged Android, 60 Hz, 411.43 × 914.29 dp, DPR 2.625. Session and exercise-card workflow became reachable.
- Collapse control: Tooltip inner box 40 × 40 dp, glyph 24 × 24 dp, outer IconButton 48 × 48 dp, `hitTestable=true`.
- Exercise menu: glyph 24 × 24 dp, outer IconButton 48 × 48 dp, `hitTestable=true`; a tap at the outer target's left edge opened the menu, and Back dismissed it.
- A subsequent tap at the cached collapse target's left edge did not yield the expected `weightExpandSets` tooltip; the driver failed at `integration_test/expressive_preview_device_test.dart:714` with “Expected: exactly one matching candidate; Actual: ... Found 0 widgets”. The smoke ended exit 1 before set completion, final-set auto-collapse, reopen, or session-discard assertions. Therefore only the menu left-edge interaction passed; collapse edge activation is unresolved. No retry was made.
- The isolated preview app was force-stopped after the run; `pidof com.tonos.expressivepreview` returned no process. The integration APK remains installed. Log: [`profile-smoke-bounded-driver-2026-09-30.txt`](logs/profile-smoke-bounded-driver-2026-09-30.txt).

The corrected harness source passed scoped analysis and its profile APK built successfully. This device lane still does not prove the following:

- Collapse-control edge activation, set completion, final-set auto-collapse, reopen, or workout-discard completion in the real device smoke. The menu left-edge tap did pass; the smoke stopped at the collapse-tooltip assertion.
- Fresh focus-matched Classic/Expressive screenshots or user visual review.
- Motion clips, reduced-motion comparison, keyboard/focus/Back checks, native TalkBack/accessibility, or OS font scale 2 with native nonlinear scaling.
- A canonical interactive preview install for user review, or a full end-to-end pass after the harness correction.

The older `evidence/profile-rerun-collapse-target-failure.png` is a diagnostic integration-test failure screen, not a product screenshot or visual comparison. Focus highlights in old captures were inconsistent between treatments; they remain historical and should not be used to decide preference. The visual and motion choices remain for the user to review when fresh matched evidence is available.

## Final qualification resume — 2026-09-30

The narrow harness change in `integration_test/expressive_preview_device_test.dart` reacquires the same card's Collapse IconButton after menu dismissal, measures the refreshed outer target, logs its movement, requires at least 48 × 48 dp, checks hit-testability, and taps the refreshed left edge. It does not lower the contract or alter production UI. Pinned Dart analysis of this file passed with **no issues found**; the current run log is [dart-analyze-final-harness-2026-09-30.txt](validation/logs/dart-analyze-final-harness-2026-09-30.txt). Direct device taps independently cover center, left, and right edges, so the full timing/profile matrix was not restarted.

### Physical collapse target and Workout compatibility

- The actual outer collapse control was measured at 126 × 126 physical pixels on a 2.625 DPR device, i.e. **48 × 48 logical dp**; its inner visual box was smaller. Center, left-edge, and right-edge taps each changed only the intended expanded/collapsed state.
- The adjacent exercise-menu left-edge tap opened only that menu; Android Back dismissed it. No neighboring control fired during the tested edge taps.
- In a two-set exercise, completing set 1 left the card expanded. Manually collapsing and reopening retained its completion state. Completing set 2 triggered the existing final-set auto-collapse; reopening showed both sets completed.
- One Android Back returned from Session to Train while preserving the active draft. The normal ongoing-session Exit → Cancel Workout confirmation then discarded the isolated draft. The final preview has no ongoing session.
- A weight EditText received focus and opened the numeric IME. One Android Back hid the keyboard and left Session and its set row visible; no value was changed. Broader keyboard/focus-order certification was not attempted.

These physical results resolve the earlier cached-coordinate failure as a harness targeting weakness. The first corrected integration smoke was not rerun; the physical target/edge and workflow evidence is direct Pixel evidence, while the test source has scoped analysis only.

### Native 2× text, navigation, and Back

- Android `font_scale` was restored to **1.15** after each temporary **2.0** run; display size remained 1080 × 2400 at 420 dpi. Preview text scale was set to OS/app default during native OS-scale checks.
- Overview remained vertically scrollable. After one upward content swipe, lower Overview content and the Start/Optimize action area were visible.
- Plans remained vertically scrollable; Archived Plans, Show more, Premade Plans, and Generate/Manually Add actions were reached. Very long plan labels can ellipsize at 2×.
- At 2× the bottom navigation displays four destinations at once. A leftward horizontal swipe exposed Profile; tapping its measured clickable target opened the Profile screen. Before the swipe, Train/Catalog/Logbook/Progress were present and clickable. Thus all five default destinations were reached across the two scroll positions, with the noted horizontal-swipe requirement.
- Android Back dismissed the preview controls and a Train plan context menu without leaving the selected destination. It also dismissed the Workout Timer modal. Session Back/exit behavior is described above.
- The profile destination at 2× is captured in [native-os2-profile-reached-final-2026-09-30.png](../review-final/native-os2-profile-reached-final-2026-09-30.png). Run transcripts and before/after captures are in `../review-final/`.

### Matched comparisons, clips, and canonical review state

The final matched screenshot set is the eight `*-matched-2026-09-30.png` files indexed in [review-final/README.md](../review-final/README.md), with matching XML hierarchy snapshots. Five short on-device review clips are also indexed there: Overview/Plans, bottom navigation, Start press/release, rapid Train selection, and reduced motion. They are qualitative evidence, not frame-timing or physical-latency measurements.

Canonical APK: package `com.tonos.expressivepreview`, versionCode 6/versionName 1.0.1, profile build, SHA-256 `5482D46855BA3961FD82D3FB107124C7F6AD1453DEC693F93394AEDDE1281966`; build record: [canonical-profile-build-2026-09-30.txt](../review-final/canonical-profile-build-2026-09-30.txt). On reconnect, package metadata and the running process were confirmed, and the final screen showed Train → Overview, Expressive / Curated / Light / 1×, reduced motion/effects off, no overlay, and no active workout. System font scale was 1.15. Database is `tonos_expressive_preview.db`; normal/internal Tonos packages and data were not targeted. Launch/reset instructions are in [manual-review.md](manual-review.md).

### Accessibility status and limits

- Host accessibility evidence remains 28 prior focused tests plus the new 320 dp / long-French / RTL / nonlinear-stress test, all passing in their recorded runs. It is not physical Android evidence.
- Native text scaling, navigation reachability, focused weight entry, and Back dismissal were checked as described above.
- **TalkBack was not tested.** No screen-reader announcement, focus-order, or duplicate-node certification is claimed.
- Landscape, full child-route visuals, and Workout/Progress design qualification remain outside this Train + shell review.

### Profile interpretation

The existing matched Pixel timing table above remains the only performance dataset. Classic and Expressive settled costs were broadly comparable; both had substantial build/raster frame-budget exceedances. Synthetic 80 ms rapid retargeting had more Expressive build-budget exceedances (50/212 vs 34/212). These Flutter frame-cost samples do not establish compositor missed-frame counts, physical input latency, zero jank, or faster Expressive performance. No profiling was restarted while capturing motion clips.
