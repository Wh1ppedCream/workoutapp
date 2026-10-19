# Source snapshot

This records the starting checkpoint and frozen-source validation. It is not a build manifest. Capture metadata must be updated when fresh evidence is produced.

## Starting repository state

- Repository: `E:\projects\env_test`
- Branch: `feature/classic-m3e`
- Starting HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea` — `Add Expressive planning route previews`
- Upstream: `origin/feature/classic-m3e`; the branch was synchronized at the read-only audit.
- Starting working tree: 56 modified tracked files, 528 untracked paths, 0 staged files. Those counts describe the initial snapshot, before this dated review documentation and parallel implementation work. The integrated source was subsequently frozen for the recorded checks.
- No commit or push has been made for this pass. The malformed local Codex ref is outside scope and remains untouched.
- Toolchain: Flutter 3.47.5 and its bundled Dart 3.13.4. Device/build validation must use these explicit SDK binaries.
- C: had approximately 6.35 GiB free at initial validation; E: approximately 78 GiB. Use the normal C: temp configuration for validation.

## Preview safety identity

The isolated preview startup guard in `lib/dev/expressive_preview_safety.dart` requires all of the following:

- Android application ID `com.tonos.expressivepreview`;
- database filename `tonos_expressive_preview.db`;
- `TONOS_EXPRESSIVE_PREVIEW=true`;
- `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`;
- `TONOS_ANDROID_INTERNAL_BUILD=false`;
- `TONOS_DATABASE_NAME=tonos_expressive_preview.db`.

Fresh evidence is valid only after checking the runtime package/database identity and confirming the installed app was built from the working-tree source after source validation. Existing screenshots and clips in other proposal folders predate some current edits; they are historical references only and are excluded from this evidence set.

## Candidate source areas

This pass has overlapping task-owned and pre-existing dirty source. Read the live files before comparing diffs; starting HEAD is not the visual baseline.

| Family | Principal owners in the working tree |
| --- | --- |
| Train responsive regression only | `lib/screens/exercise/train_page.dart`, `lib/widgets/seven_day_focus_card.dart` |
| Active Workout responsive regression only | `lib/widgets/weight_card.dart` |
| Planning | `lib/screens/exercise/preset_detail_screen.dart`, `gym_profile_screen.dart`, `optimized_workout_settings_page.dart`, `plan_management_page.dart`, `premade_plans_page.dart`; `lib/theme/expressive_planning_tokens.dart` |
| Catalog | `lib/screens/catalog_page.dart`, `lib/screens/exercise/exercise_catalog_page.dart`, `muscle_filter_page.dart`, `definitions_by_bodypart_page.dart`, `definitions_by_muscle_page.dart`; `lib/widgets/exercise_definition_info_tile.dart`, `exercise_detail_sheet.dart` |
| Progress | `lib/screens/measurement_trends_page.dart`, `lib/widgets/exercise_progress_section.dart`, `health_trends_section.dart`, `workout_metric_chart_card.dart` |
| Logbook | `lib/screens/exercise/history_screen.dart`, `full_history_screen.dart`, `session_detail_screen.dart`; `lib/widgets/history_content.dart`, `workout_history_calendar.dart` |
| Profile/settings | `lib/screens/profile/settings/profile_page.dart` and the affected settings route owners; shared `lib/widgets/settings_tiles.dart` is pre-existing shared work and must not be changed casually |
| Analytics Settings | seven routes under `lib/screens/profile/settings/`; new `analytics_destination_surfaces.dart`; destination token/theme files under `lib/theme` |

## Validation/capture record

Validation was run against the frozen working tree on the starting branch/HEAD listed above. The repository-wide test suite was intentionally not run at this candidate stage.

| Check | Result |
| --- | --- |
| Focused integration tests | 529 passed, 0 failed, 0 skipped across 95 files |
| Analyzer | 0 errors, 0 warnings, 54 informational notices; exit 1 because infos are reported |
| Dart format check-only | Five task-owned Dart files pending formatting; no formatting was applied by the check |
| `git diff --check` | Pass |
| Theme inventory | Pass |
| Ratchet enforcement | Pending disposition for intentional `exercise_definition_info_tile.dart` fingerprints |
| Full repository suite | Not run |

| Field | Value |
| --- | --- |
| Capture source HEAD | Pending fresh build |
| Working-tree summary at capture | Pending |
| Build artifact hash/path | Pending |
| Device/runtime identity | Pixel 7 `28021FDH200228`, package/database verification pending |
| Capture date/time | Pending |
| Screen/state map | See [visual review list](visual-review-list.md); pending actual captures |
