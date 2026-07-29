# Codebase Guide

This guide is a quick orientation map for future work in the app. It focuses on
where the important logic lives and how the major workout features fit together.

## App Layers

- `lib/screens/` contains full pages and route-level flows. Screens should own
  navigation, loading state, and page layout.
- `lib/widgets/` contains reusable UI pieces such as workout cards, heatmaps,
  preset summaries, charts, and bottom sheets.
- `lib/providers/` contains mutable UI/session state that multiple widgets need
  to read or update.
- `lib/services/` contains feature logic that is bigger than one page, such as
  preset generation and automatic progression.
- `lib/repositories/app_repository.dart` is the main app-facing data facade.
  Screens, providers, and services generally call the repository instead of
  individual DAOs directly.
- `lib/db/` contains SQLite setup and DAO files. `database_helper.dart` owns
  database lifecycle, schema creation, maintenance, import/export, and shared
  helpers. DAO files keep table-specific queries smaller.
- `lib/models/` contains the typed objects passed between database, services,
  providers, and widgets.

## Workout Generation

- `lib/models/training_plan_models.dart` defines `SessionSpec`, the input object
  for both Generate Custom Preset and Start Optimized Workout.
- `lib/services/preset_generation_service.dart` converts a `SessionSpec` into a
  selected workout plan. It loads targets, scores exercises, allocates sets,
  staggers exercises, and optionally generates reps/weights.
- Generate Custom Preset persists the selected plan through
  `PresetGenerationService.generatePresetWithDetails`.
- Start Optimized Workout should reuse the selection path without creating a
  saved preset. That distinction matters so optimized sessions do not pollute
  the user's preset list.

## Presets And Sessions

- `lib/providers/preset_session.dart` is the source of truth for the preset
  detail/edit screen. It mirrors database row IDs beside in-memory exercises so
  edits can be saved accurately.
- `lib/widgets/weight_card.dart` is the reusable card for weight exercises in
  both workouts and presets. It handles set editing, completion tinting,
  collapsing, change sets, details, and swap entry points.
- `lib/widgets/preset_info_card.dart` summarizes a preset with estimated time,
  volume, focused sets, and a body heatmap.
- `lib/widgets/swap_exercise_sheet.dart` recommends similar replacements by
  comparing bodypart, muscle, and equipment overlap.

## Analytics And History

- `lib/widgets/body_heatmap.dart` owns the shared SVG body heatmap and caching.
  Reuse it for any bodypart intensity visualization instead of making a new
  renderer.
- `lib/widgets/history_summary_widget.dart` shows quick range-based workout
  history and bodypart heatmap summaries.
- `lib/widgets/workout_metric_chart_card.dart` builds the swipeable workout,
  minutes, and volume chart from completed session data.
- `lib/widgets/workout_history_calendar.dart` renders calendar-style history.

## Database Notes

- Prefer adding repository methods in `app_repository.dart` that delegate to DAO
  methods. This keeps UI and services from depending on table details.
- Add new SQLite queries to the most specific DAO file when possible.
- If a database change affects startup, check `database_helper.dart` carefully:
  it has schema creation, migrations, seeding, maintenance markers, and startup
  timing logs.
- For repeated SQL list placeholders, use helpers from `lib/db/db_query_utils.dart`.

### DatabaseHelper Boundary

`DatabaseHelper` is still the public database lifecycle coordinator and a
compatibility facade for existing callers. New work should not add unrelated
feature SQL there. Put table-specific queries in a focused DAO, expose them
through `AppRepository`, and extract lifecycle or maintenance behavior only
when that behavior can be covered by focused database-upgrade tests.

## Performance Patterns

- Use `BodyHeatmap.preload()` before screens that show many heatmaps.
- Use `mapWithConcurrency` from `lib/utils/async_pool.dart` for batches of
  database-heavy async work.
- Keep expensive summaries cached by a signature string when a widget can be
  rebuilt often but its inputs have not actually changed.
- Avoid rebuilding or reloading chart/heatmap data while scrolling unless the
  underlying input changed.

## Documentation Style

- Prefer short class-level comments that explain responsibility and boundaries.
- Add method comments only when the method coordinates multiple systems or has
  non-obvious business rules.
- Avoid comments that restate a single line of code.
- When documenting generation, analytics, or database code, explain where inputs
  come from and what downstream feature depends on the output.
- Keep `screen-routing-map.md` for active navigation, `maintenance-backlog.md`
  for prioritized engineering work, and the cloud-content documents for
  publishing operations.
