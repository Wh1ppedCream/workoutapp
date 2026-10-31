# Pass 4 — physical Pixel 7 validation

Validated on 2026-10-31 against the uncommitted Pass 4 working tree based on
`efe3f22`. This supplements the [Pass 4 overview](README.md) and
[technical report](technical-report.md); it is a focused device smoke test.

## Device and build

- Physical Pixel 7, Android 16 / API 36; existing app package
  `com.tonos.expressivepreview`, version 1.0.1+6.
- Built debug with the pinned Flutter 3.47.5 runner, `--no-pub`, using the
  regular app entry point and existing `tonos_expressive_preview.db`. The
  runner verified the package and compile-time database/preview defines.
- Installed over the existing app with `adb install -r`; no app clear, second
  installation, reset or fixture reseed. Source/dependency hashes matched
  before and after the build.
- Took local `run-as` snapshots of databases and preferences immediately
  before installation and after the exercised workflows. The app was
  backgrounded and stopped for each consistent snapshot.

## Exercised on device

| Flow | Observed result |
| --- | --- |
| Cold startup | App opened with the original Home Gym profile, Expressive light theme, active plan and ongoing workout available. |
| Automatic preset | Opened `Quads, Hips`: summary, exercises, set values and thumbnails loaded. Automatic Settings displayed its existing increment and values; the Methods tab opened. No settings were saved. |
| Edit/discard/reload | In edit mode, changed a weight from 10 to 11 in the in-memory draft. Save Changes appeared; Back prompted for confirmation. Discarded, reopened the plan and observed the original 10. |
| Existing workout | Resumed the unfinished session and observed the existing exercises, set values and completion state. Returned without completing, exiting or changing the workout. |
| Extracted report queries | Opened Workout Report, changed to 1 month and Volume, observed the updated report, then restored All and Workouts. Opened Ab Wheel's 1RM progress and recordings. |
| Profile/other preset | Switched temporarily to Expressive Preview, opened non-automatic `Active Review 2` and saw its exercises/sets, then restored Home Gym. |
| Reopen | Cold-launched again after the final snapshot; Train → Overview, Home Gym, active plan and the ongoing-workout control remained available. |

The composition root explicitly selects `SqlitePresetReadSource`, so opening
these presets through the installed build exercises the new production SQLite
path. Device logging was not instrumented to count individual SQL statements;
query-count and mixed-cardio/stretch parity evidence remains the automated
in-memory coverage in the technical report.

## Data and logs

- Both snapshots have schema **62**; final `PRAGMA integrity_check` returned
  **ok**. The same 87 tables were present.
- 80 tables have identical complete row hashes, including saved sessions,
  sets, presets, preset sets, measurements, diary entries and gym profiles.
- The one active-workout draft retains the same contents; its update timestamp
  changed. The selected profile ID was 201 in both snapshots.
- Normal metadata differences affected selected-profile timestamp, content
  manifest checked/download timestamps, media update/access timestamps, and
  SQLite sequence counters for equipment and measurement definitions. The
  equipment and measurement-definition rows themselves are unchanged.
- `day_totals_cache` gained two derived cache rows and lost none during the
  profile switch. The only changed SharedPreferences key was content-sync
  diagnostics events; the theme and onboarding settings remain as before.
- The 58 retained logcat lines for the exercised app process had no matching
  Flutter unhandled exception, Android fatal exception, ANR, or RenderFlex
  overflow. Logcat is bounded; this is not complete historical log coverage.

Private backups, comparison JSON, build log and device log remain under the
ignored `.build/maintainability/` directory. The final comparison was taken
before the last cold launch, which can itself update routine metadata/caches.

## Limits and final state

No preset was saved or created, no session completed, no measurement edited,
and no database import or destructive test was run on the user's data. Existing
device plans contained weight exercises only, so physical cardio/stretch preset
coverage remains outstanding. Transaction rollback, mixed-type presets,
chunking, and simulated failure/retry were tested with isolated SQLite fixtures
in the automated suite, not failure-injected into the user's device database.

No iOS or release-build qualification, latency benchmark, accessibility audit,
or exhaustive theme/size sweep is claimed. The existing active-workout FAB
overlap remains outside this task; its overlap with Train's Optimize area was
still visible. Android Gradle/Kotlin future-support warnings were emitted by
the debug build; no build-tool versions were changed.

The device is left on **Train → Overview**, Expressive light, Home Gym selected,
with the unfinished workout resumable.
