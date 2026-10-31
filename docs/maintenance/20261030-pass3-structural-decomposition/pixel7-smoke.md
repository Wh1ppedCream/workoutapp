# Pass 3 — physical Pixel 7 smoke test

Tested on 2026-10-30 against `efe3f22` on `codex/codebase-maintainability`.
This supplements the automated qualification in [README.md](README.md).
No application source was changed during this check; no commit or push was made.

## Device and installation

- Physical Pixel 7, Android 16 / API 36, 1080 × 2400, density 420,
  existing text scale 1.15.
- Built debug with the pinned Flutter 3.47.5 SDK through
  `tools/run_expressive_preview.ps1 -BuildMode debug`.
- Updated the existing `com.tonos.expressivepreview` package in place using
  `adb install -r`; did not install a second variant or clear app storage.
- The review entry point opens the regular app with persisted settings.
  No fixture reseed, database reset, or automated integration-test setup ran.
- Captured a private local database/preferences backup before installation and
  a second snapshot after testing. Backups, logs and screenshots remain ignored
  under `.build/maintainability/pixel7-smoke-20261030/`.

## Exercised flows

These are manual UI smoke checks through normal navigation, not end-to-end
qualification of every feature or approval of new visuals.

| Area | Actions and observed result |
| --- | --- |
| Startup and appearance | Existing database opened; Expressive remained selected. Dark mode persisted across reopening; original light mode restored. |
| Active workout | Resumed the existing unfinished workout; original exercise/set values appeared. Expanded and collapsed an exercise, then returned without completing or discarding the workout. |
| Catalog detail, light | Opened Ab Wheel from its browser thumbnail, expanded the sheet, viewed Details, Metrics and Records; changed metric range. Opened enlarged media and scrolled the expanded Form guide through Set-up, Execution and Tips. |
| Exercise Editor, light | Selected Ab Wheel through the catalog picker, confirmed Add, viewed loaded definition, Equipment and Guide, entered edit mode and cancelled without saving. |
| Health Trends, dark | Opened Weight detail from Nutrition; chart and existing entries rendered. Opened an existing entry's edit dialog and cancelled. |
| Workout Report, dark | Switched Time/Volume/Workouts and date ranges; expanded Additional Details. Restored All/Workouts and collapsed the details. |
| Exercise Progress, dark | Opened Ab Wheel's progress detail; viewed chart, legend and records and tapped a chart point. |
| Plan detail/edit, dark | Viewed an existing plan. Save Changes was initially absent; changing a weight in the draft revealed it. Back prompted for unsaved changes; Discard returned without persisting the draft. |
| Custom generation, dark | Opened the existing generation form and expanded Training focus; returned without generating plans. |
| Premade Plans, dark | Equipment-filtered empty state rendered. Temporarily disabled the filter, expanded Full Body and an individual plan; description and explicit sets × reps labels rendered. Restored the filter without adding a plan. |
| Gym equipment, dark | Opened the active profile's editor with its existing 8/40 equipment selections; collapsed Basics and returned without saving. |
| Onboarding replay, dark | Enabled Replay Onboarding, cold-launched, navigated Welcome → Basics → Focus without entering data, and confirmed Skip setup. Returned to the app; completion true and replay false were restored. |

## Confirmed issue: ongoing-workout action overlaps page actions

When a workout is active, the root `OngoingSessionFab` overlays the selected
page's own action controls:

- **Nutrition:** both Add food or measurement and Workout Session have native
  bounds `[891,1996][1038,2143]`. Tapping that area opens Resume / Exit instead
  of the Nutrition action menu.
- **Train:** the same root button visibly covers the right side of Optimize,
  including its settings action.

The root Scaffold always supplies this FAB while `session.isActive`
(`lib/main.dart`, around line 688). Its implementation is in
`lib/widgets/ongoing_session_fab.dart`. Both files are unchanged between
`e152d88` and `efe3f22`, so this is evidence of an existing UI collision rather
than a change introduced by the Pass 3 extraction. The exact earliest
introducing commit was not investigated.

Local evidence: `nutrition-fab-collision.png` and `final-train-light.png` in
the ignored evidence directory above. No UI fix was made during this smoke test.
Follow-up should coordinate the root resume action with page-owned actions and
cover the active-session state on Train and Nutrition.

## Data and settings verification

The final read-only SQLite comparison reports schema **62** and
`PRAGMA integrity_check = ok`.

- All **87 table row counts** match the pre-installation snapshot; **81 tables**
  have identical complete row hashes, including saved sessions/sets, presets and
  preset sets, measurements, diary entries, nutrition goals, and gym profiles.
- The active workout draft differs only in `updated_at`; its remaining columns,
  including workout contents, are identical.
- `app_meta` differs only in the selected-profile timestamp; its selected ID
  and all other values are unchanged.
- Content manifests differ only in checked/download timestamps. Exercise and
  shared media differ only in update/access timestamps; media identities and
  assets are unchanged.
- `sqlite_sequence` counters advanced for equipment and measurement definitions;
  their actual rows are unchanged. Existing lookup initialization uses ignored
  inserts, which can advance these counters without adding rows.
- SharedPreferences differ only in content-sync diagnostics events. Theme,
  units, language, selected-profile preferences and onboarding settings match
  the baseline.

Retained application logs show no matched Flutter exception, fatal Android
exception, ANR, or RenderFlex overflow. Logcat is a bounded buffer, so this is
not a claim of complete historical log coverage. SVG metadata notices were
observed without a corresponding rendering failure.

## Qualification limits and final state

- No destructive database-import test, workout finish, measurement save, plan
  save/add/generation, camera scan, or fixture reset was performed against the
  user's existing data.
- Pinch-to-zoom, frame pacing, accessibility services, rotation, other widths,
  larger text scales and exhaustive light/dark coverage remain unverified here.
- Normal replay's Nutrition setup remains labelled for later setup; its complete
  alternative onboarding branches were not exercised.
- The debug build emitted future Flutter-support warnings for Gradle 8.14.5,
  AGP 8.11.1 and Kotlin 2.2.21. No build-tool versions were changed.
- The automated suite was not repeated: its checkpoint results remain separate
  from this device smoke test. No new visual or release approval is implied.
- Final device state: **Train → Overview, Expressive light**, original Home Gym
  selected and unfinished workout still resumable.

Tracked changes from this check are this report and its link in the audit
README. Existing unrelated untracked paths were preserved.
