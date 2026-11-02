# Architecture boundary follow-up

Branch: `codex/codebase-maintainability`. Committed baseline: `ff24670`.
The user authorized the five recommendations in sequence. The initial working
tree already contained a partial launch/thumbnail/Catalog patch and its tests;
that work was reviewed and completed in place. Unrelated untracked paths remain
untouched. This report describes the combined patch, not five new commits.

| Order | Completed implementation | Focused validation |
| --- | --- | --- |
| 1 | Read-only thumbnails, primary/additional equipment lookup, shared plan/repeat launch preparation, blocked/cancelled/empty outcomes and Catalog repository access | 33 tests passed; scoped fatal-info analysis clean |
| 2 | Application boundary specification linked from the existing codebase guide | Manual comparison with actual ownership and error/temporal contracts |
| 3 | Typed ExerciseHistoryEntry results for detail-sheet history; raw override compatibility and existing typed 1RM API retained | 31 projection, DAO pagination and existing detail presentation tests passed; scoped analysis clean |
| 4 | Standalone default-rule dialog owns its field controllers and returns FlowMethodDraft; shared controls and existing defaults/save/propagation semantics retained | 35 draft/rule presentation and interaction tests passed; scoped analysis clean |
| 5 | Exercise editor controller owns async request ordering, selection, save exclusion and reload/disposal lifecycle; screen retains field drafts and presentation | Initial 15 controller/editor tests passed; the additional overlapping-selection regression also passed in the broad run |

## Behavior and compatibility

- Loading a thumbnail no longer creates an exercise definition. Missing/custom
  definitions retain the optional fallback. Read-only lookup accepts secondary
  equipment links as well as primary equipment.
- ActiveSession remains the owner of restoration, competing starts and durability.
  WorkoutLaunchCoordinator clones saved-plan/repeated-session inputs and filters
  unsupported cards consistently. Preset starts preserve source IDs; repeated
  sessions clear them and start with unchecked sets. Blocked restoration/import/
  completion is reported through safe failure guidance rather than being mislabeled
  as an ongoing workout. Unsupported-only inputs cannot start an empty workout.
- Weight-only plan/repeat/generation support remains intentional. Full cardio and
  stretch restoration is a separate feature, not enabled by this refactor.
- Exercise history retains ordering, cursor arguments, the extra-row pagination
  probe, persisted calendar days and legacy timestamp interpretation. Existing raw
  repository overrides still dispatch virtually. No SQL/schema/draft-format change
  accompanies the typed projection.
- Default-rule UI keeps its existing controls, dimensions, theme treatment and
  numeric/copy-index defaults. Persistence and propagation remain page-owned; the
  extracted dialog owns controller disposal. Plan-specific dialog behavior remains
  unchanged and shares the existing draft and choice controls.
- The exercise editor keeps its editable field state, selected tabs, validation,
  dialogs and layout in the screen. The controller suppresses stale success and
  failure responses, excludes duplicate saves and stops notifications after
  disposal. Failed saves retain the user's draft. A failed selection returns to
  the last successfully loaded definition rather than exposing unloaded fields.

## Files and responsibilities

- [Application boundaries](../../architecture.md) and
  [codebase guide](../../codebase-guide.md): ownership and compatibility rules.
- `lib/services/workout_launch_coordinator.dart`: plan/repeat outcomes and cloning;
  `preset_detail_screen.dart` / `session_detail_screen.dart`: caller-specific feedback
  and navigation.
- `weight_card.dart`, `definition_dao.dart`, `database_helper.dart`: read-only media
  lookup; `exercise_catalog_page.dart`: existing repository forwarding APIs.
- `lib/models/exercise_history_entry.dart`, `models.dart`,
  `repositories/parts/workout_repository_part.dart`, `exercise_detail_sheet.dart`:
  typed history boundary and consumer.
- `flow_methods/default_flow_method_dialog.dart` and `flow_methods_page.dart`:
  default-rule presentation extraction.
- `exercise_editor/exercise_editor_controller.dart`, `exercise_editor_screen.dart`
  and `exercise_editor/selection_dialogs.dart`: controller pilot and creation flag.
- Regression tests: `test/controllers/exercise_editor_controller_test.dart`,
  `test/repositories/exercise_history_projection_test.dart`,
  `test/services/workout_launch_coordinator_test.dart`,
  `test/widgets/weight_card_thumbnail_readonly_test.dart`,
  `test/db/definition_dao_equipment_hydration_test.dart`.

## Qualification follow-ups

The default-rule extraction also moves the source contract's form/control checks
to `default_flow_method_dialog.dart`. The route still must reference that dialog;
the actual form still must use TonosField and FlowMethodsChoiceField. These checks
were relocated rather than removed or replaced with import-only matches.

The first full run exposed a pre-existing DST-dependent calendar defect on November
1 in the local Toronto timezone. Calendar cells were generated by adding 24-hour
durations, which repeated the selected November 1 date after the clock changed.
`workout_history_calendar.dart` now counts civil dates using UTC calendar fields
and creates each local day with DateTime's calendar constructor. Styling and
interaction are unchanged. Two widget regressions assert complete, unique day cells
and one selected date in March and November. Calendar/Logbook presentation checks
passed; the relocated settings contract passes all four checks. The initial full
run was interrupted to apply this confirmed correction before final qualification.

## Combined qualification

Repository-wide fatal-info analysis and theme inventory/ratchet checks passed.
The inventory remains report-only with 643 pending candidates and zero unassigned
candidates. No ratchet approvals, inventory classifications or visual approvals
were changed.

The final full Flutter command ran for 25 minutes with **2,613 passes and zero
reported failures** before a tool-session interruption stopped it near the end.
This is not an uninterrupted full-suite pass. Its output is retained at
`.build/maintainability/architecture-boundary-tests.log`; the earlier diagnostic
run is preserved separately as `architecture-boundary-initial-tests.log`.

A **110-file completion batch passed all 489 tests**, covering every test file
absent from the interrupted output plus the entire final `test/widgets` group,
including expansion, menu and record-badge checks. Its exact file list is retained
at `.build/maintainability/architecture-completion-files.txt` and its output at
`architecture-completion-tests.log`. These counts overlap the broad run and the
focused batches; they must not be summed into a unique total.

Final repository-wide `dart analyze --fatal-infos` reports **no issues** (output:
`.build/maintainability/architecture-boundary-analysis.log`). Formatting verification
covered all **24 changed Dart files with zero changes**, and `git diff --check`
passed. Theme inventory and all 18 ratcheted file checks passed without approval
updates. The local test sweep lacks an uninterrupted final full-suite exit;
the interrupted run itself reported no failures, and the explicit
completion batch exited successfully.

No device build, device navigation, screenshot campaign, data reset, dependency
upgrade, staging, commit or push is part of this task. Existing editor/detail/rule
presentation tests provide automated layout coverage; fresh Pixel 7 visual review
and Linux CI qualification have not been performed for this uncommitted patch.

## Deliberately deferred

Nutrition/Train2 floating-action coordination, wholesale facade splitting, global
ViewModel conversion, further screen decomposition, broad theme-token conversion
and full cardio/stretch feature restoration remain separate work. The pilot does
not require replacing remaining presentation parts. Existing approved presentations
and both Train tabs are preserved.
