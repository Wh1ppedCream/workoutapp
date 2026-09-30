# Expressive Pixel Device Qualification

**Status: stopped at the bounded device checkpoint.** Two full profile runs emitted their idle and interaction timing batches, but both ended in functional harness failures. A later smoke-only build installed successfully; its driver stalled after isolated fixture and review-preference setup and was interrupted. The smoke did not reach the runtime viewport or Workout geometry checks, so the corrected outer-target and edge-activation proof remains pending. No production issue is established by the stalled run.

The latest instruction stopped further visual, motion, native accessibility, and canonical interactive-app work. There are no fresh comparison boards, screen recordings, OS 2× text captures, or canonical installed review app from this lane. Existing screenshots remain historical evidence only.

## Source and build checkpoint

- Starting checkpoint: branch `feature/classic-m3e`; verified HEAD and `origin/feature/classic-m3e` at qualification start: `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9`.
- Toolchain: Flutter 3.47.5 with bundled Dart 3.13.4. Device commands used Pixel 7 serial `28021FDH200228`.
- The only source file changed in this lane is `integration_test/expressive_preview_device_test.dart`. Its final SHA-256 is `85E57EC942ED03637FC3AB957CD7B862C2C9499663DE1CD7C094ED423F777CCB`. Changes are limited to device-qualification harness coverage: runtime display metadata, light/dark idle and matched timing phases, rapid retargeting, session-menu settle/hit-test checks, measured outer IconButton targets and edge taps, cleanup route settling, and the default-off `TONOS_PREVIEW_DEVICE_SMOKE_ONLY` selector.
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

The corrected harness source and smoke APK passed the scoped source/build checks, but this device lane does not prove the following:

- 48 dp outer-target geometry and edge activation for the workout collapse/menu controls.
- Fresh focus-matched Classic/Expressive screenshots or user visual review.
- Motion clips, reduced-motion comparison, keyboard/focus/Back checks, native TalkBack/accessibility, or OS font scale 2 with native nonlinear scaling.
- A canonical interactive preview install for user review, or a full end-to-end pass after the harness correction.

The older `evidence/profile-rerun-collapse-target-failure.png` is a diagnostic integration-test failure screen, not a product screenshot or visual comparison. Focus highlights in old captures were inconsistent between treatments; they remain historical and should not be used to decide preference. The visual and motion choices remain for the user to review when fresh matched evidence is available.
