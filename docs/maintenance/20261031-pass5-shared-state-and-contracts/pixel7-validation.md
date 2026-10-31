# Pass 5 — physical Pixel 7 smoke check

Validated on 2026-10-31 against production changes through `6cb89b1` on
`codex/codebase-maintainability`. The later food-logging change corrects a test
expectation only. This supplements [the combined report](README.md).

## Build and installation

- Physical Pixel 7 (`28021FDH200228`), existing `com.tonos.expressivepreview`
  installation, version 1.0.1+6 and `tonos_expressive_preview.db`.
- Built debug using `tools/run_expressive_preview.ps1`, Flutter 3.47.5,
  bundled Dart 3.13.4 and `--no-pub`. The runner verified the APK package and
  database/preview defines. Gradle completed in 317.6 seconds.
- Installed in place using `adb install -r`. No app clear, reset, fixture
  reseed, database replacement or new installation identity was used.
- Existing Gradle/AGP/Kotlin future-support warnings remain; dependency
  validation was not bypassed and no Android toolchain upgrade was included.

## Observed workflows

| Workflow | Observation |
| --- | --- |
| Cold launch | Expressive dark theme, Home Gym, active plan and ongoing-workout action restored. |
| Ongoing-workout action | Tapping opened Resume/Exit; tapping the noninteractive weekly heading closed the actions. The existing Train placement remained above Optimize. |
| Shared quick start | Train's Start Workout resumed the existing workout rather than replacing it. Turkish Get Up's five sets, existing weights/reps and 0/5 completion state loaded; Back returned to Train. No set was modified or completed. |
| Optimization settings | Opened the existing 45-minute, 1–1 sets, Mixed, 6-rep settings. Returned without Save, Reset or Start Now. |
| Preset/settings | Opened Quads, Hips and Automatic Settings. Values and Methods loaded, including independent Per set and 1 set radio selections. Closed without saving or changing options. |
| Typed analytics | Progress → Exercise progress → Ab Wheel showed estimated 27 lbs. Its 1RM Progress graph and dated recordings loaded through the typed trend boundary. |
| Final state | Cold-launched again and left on Train → Overview, Home Gym, dark mode, ongoing workout retained. |

These are focused smoke observations, not a new visual approval campaign.
Physical checks did not cover Train2, light mode, alternate screen settings,
cardio/stretch restoration, destructive import/failure injection, iOS or release
builds. Focused automated tests cover the shared launch, codec, radio groups,
theme/layout matrix and injected failures.

## Data comparison

The app was stopped for consistent `run-as` database/preference snapshots
before installation and after navigation. Local evidence remains under
`.build/maintainability/pixel7-smoke-20261030/`:

- `pass5-20261031-before.tar`: SHA-256
  `ba43f60f5ac9823ed9ff079746975d36499abed0162555796c1ca27979e8b460`.
- `pass5-20261031-after.tar`: SHA-256
  `ba1b340770e80d915e42e4de48d2e8047a2d7eef3ab73e9d9f1023a6d2c224d6`.
- `pass5-20261031-data-comparison.json` and `pass5-*.png` captures.

Both snapshots retain schema **62** and the same **87 tables**. Integrity check
returns **ok**. **82 tables have identical complete row hashes**, including
workouts/sets, presets, profiles, measurements, diary records and the active
workout draft. The draft also matches when ignoring its update timestamp.

The five changed tables retain the same keys and counts. Changes are confined
to `app_meta.updated_at`, content-manifest check/download timestamps,
exercise-media access/update timestamps, shared-media update timestamps, and
`sqlite_sequence` counters for equipment/measurement definitions. No user
records were added, removed or edited. The only changed preference key was
`flutter.diagnostics.content_sync.events`; theme, profile and workout settings
were unchanged. Startup's existing content checks were allowed to run normally.

The captured app-process log excerpt contains no fatal exception, unhandled
exception or Flutter exception report. That excerpt is a smoke check, not
comprehensive error or performance monitoring. Snapshots and captures are local
ignored evidence and were not added to Git or the visual-review gallery.
