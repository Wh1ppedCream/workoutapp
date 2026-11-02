# Tonos application boundaries

This describes the current application and the direction for incremental changes.
Preserve the approved Classic, Neo and Expressive presentations. Train and Train2
are separate presentations of shared capabilities, not competing data owners.

## Responsibilities and ownership

| Boundary | Owns | Must leave to its caller |
| --- | --- | --- |
| Screen / feature container | Navigation, dialogs, route lifetime, layout and localized feedback | Database lifecycle and durable write algorithms |
| Presentational widget | Rendering supplied data and invoking callbacks | Creating records as a side effect of rendering |
| Controller | A cohesive feature's loading, request ordering and operation lifecycle | BuildContext, navigation and theme selection |
| Provider | Shared observable state, such as the active workout or selected profile | Unrelated page presentation |
| Application service | Multi-step feature operations and typed outcomes | Navigation and widget layout |
| AppRepository | Application-facing reads/writes and conversion to typed results | SQL details in UI consumers |
| DatabaseHelper | Connection, schema, migrations, import/export and compatibility delegation | New unrelated feature queries |
| DAO | Queries and transactions using the supplied executor | Owning or closing the shared connection |
| Models / domain helpers | Values, projections, validation and calculations | UI and navigation dependencies |

Screens and feature containers may read AppRepository through dependency injection
for bounded reads. A provider is useful when state is shared; a controller is useful
when request ordering or editing has its own lifecycle. Do not insert forwarding
layers solely to make every feature follow an identical chain. Pass values and
callbacks to leaf widgets when practical.

## Persistence and read boundaries

- New SQL belongs in a focused DAO, exposed through AppRepository. New UI code
  should not reach through `repository.dbHelper`. Existing public forwarding APIs
  may remain as compatibility seams for callers and test overrides.
- SQLite row maps and JSON maps are appropriate inside decoding boundaries. Expose
  named, typed results to application consumers when fields have stable semantics.
  Decode once and preserve query ordering, nullability and pagination cursors.
- A detached query projection and a mutable active workout serve different needs.
  The versioned workout draft codec remains the durability boundary; a DTO cleanup
  must not change its persisted format or restoration behavior.
- Resolve thumbnails and optional display metadata without inserting data. Record
  creation belongs to explicit creation/import/save operations.
- SharedPreferences access belongs in the relevant preference service for shared
  settings. Pages can keep transient drafts; they are not another durable owner.
- Multi-row writes must remain atomic. Failed reads must not clear valid saved
  records. Preserve injected repositories and executor/transaction ownership.

## Dependencies and compatibility

Depend on capabilities, not directory names alone. A database boundary may reuse
Flutter-independent domain validation. Database-aware allocation/query helpers
may use DAOs and supplied executors. Neither should acquire a page/provider or call
back into AppRepository. Investigate concrete import cycles before moving files.

Domain enums live in models. Compatibility re-exports, such as ExerciseCard's
CardType export, do not move ownership back into UI; new non-UI callers should
import the model directly.

Part files are organization within one Dart library. Keep them for closely related
presentation when useful. Extract a controller when it gives async state or editing
a clear owner and permits meaningful tests, rather than to meet a line-count limit.

## Workouts

ActiveSession owns restoration, start exclusion, draft persistence and completion.
WorkoutLaunchCoordinator prepares and clones launch inputs and classifies outcomes.
Screens retain their existing resume/navigation decisions. A blocked restore,
database replacement or finishing operation is not an already-active workout.

Plan/repeat/generated launches currently support weight cards only. Do not silently
enable incomplete cardio/stretch paths during refactoring. Do not start an empty
workout when filtering leaves no eligible exercises. Full cardio/stretch restoration
remains a separate vertical feature in the maintenance backlog.

## Errors and temporal values

Follow [Safe Error Handling](error-handling.md): distinguish required reads, actions
and optional enhancements. Use SafeFailure or the shared safe presentation helpers;
do not render raw errors. Keep user input on failed saves. Optional thumbnail
fallbacks may remain unobtrusive. Catch-block token counts are not a compliance test.

Use LocalizedFormatters for display. Use LocalCalendarDay.storageKey and
TemporalSemantics for persisted day keys and instants. Never localize database keys
or infer a historical calendar day from the device's current timezone unnecessarily.

## Change and validation policy

Make one independently reviewable boundary change at a time. Preserve approved
layout, palette, motion and route behavior unless a confirmed defect requires a
specific correction. Prefer failure, stale-result, disposal, pagination and rollback
tests over tests that repeat implementation text. Keep compatibility contracts and
test fakes working while callers migrate. Run focused tests per batch and repository
qualification after the combined work. Theme inventory entries are review candidates,
not proof of a defect or authorization to change frozen visuals.
