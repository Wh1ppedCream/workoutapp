# Preset-loading read contracts at efe3f22

Historical P4-A baseline companion to the [combined Pass 4 overview](README.md).
The [technical report](technical-report.md) describes the implemented typed
boundary and SQLite snapshot path. C1–C10 below retain the original raw API
contracts, which remain available for compatibility. Field names describe the stored row or
existing projection. SQL constraints and current consumer fallbacks are listed
separately because several fake repositories intentionally return partial rows.

## C1 — Preset definition (already typed)

`fetchPresetById(int presetId) -> Future<PresetDefinition?>`.
The helper delegates to `PresetDefinitionDao.getPresetById`, returning null for
no row. Otherwise it decodes `id: int`, `name: String`, `created_at: String`
through `DateTime.parse`, `profile_id: int?`, and `is_draft: int?` through
`(value ?? 0) == 1`. The stored `created_at` has a UTC text default; this path
does not normalize an arbitrary supplied timestamp beyond `DateTime.parse`.

`PresetSession` uses name/profile/draft, defaulting to `''`/null/false if the
definition is missing. It still attempts remaining reads; absence alone is not
currently a load error. Preserve this in a typing-only change. No unit or list
ordering applies. Existing `PresetDefinition` remains the domain result.

Sources: [helper](../../../lib/db/database_helper.dart),
[definition DAO](../../../lib/db/preset_definition_dao.dart#L100),
[schema v6/v7/v55](../../../lib/db/schema.dart).

## C2 — Preset exercise rows

`fetchPresetExercises(int presetId) -> Future<List<Map<String, dynamic>>>`.
The DAO selects all `preset_exercises` columns by `preset_id`, ordered only by
`order_index` ascending. No rows produces an empty list.

| Stored field | Storage shape | Current loading semantics |
| --- | --- | --- |
| `id` | Integer primary key | Required `int`; identifies a preset exercise, not a definition |
| `preset_id` | Required integer | SQL owner; not read by the loader; omitted by several fakes |
| `exercise_def_id` | Nullable integer | Read as `int?`; null weight definition uses empty name/equipment without a lookup |
| `type` | Required text | Loader reads `String?`; handles `weight`, `cardio`, `stretch`; null/unknown strings are skipped |
| `order_index` | Required integer | Zero-based write position; SQL determines list order; loader doesn't read the key, progression does |

Unknown rows are not validated for unused set/cardio/stretch fields. No eager
strict enum conversion or positional renumbering belongs in a typing-only pass.
Other consumer: `AutoIncrementService._buildProgression`, which uses `id`, `type`
and `order_index`, including legacy matching to session exercise positions.

Sources: [DAO](../../../lib/db/preset_exercise_dao.dart#L42),
[loader](../../../lib/providers/preset_session.dart#L216),
[progression](../../../lib/services/auto_increment_service.dart#L123).

## C3 — Definition identity projection

`fetchDefinitionInfo(int definitionId) -> Future<Map<String, String?>>`.
This is also a string-key boundary even though it does not use `dynamic`.

| Returned key | DAO value | Consumer policy |
| --- | --- | --- |
| `name` | Required `String` from `exercise_definitions.name` | Preset loader falls back to `''`; session detail falls back to `Exercise` for a partial fake |
| `equipmentName` | Nullable `String` from a left join on legacy `equipment_id` | Preset/session detail use `''`; swap trims it and treats null/empty as unavailable |

Missing definition throws `Exception('Definition $defId not found')`; it does not
return an empty row. This projection is not the full many-to-many equipment
list and should not be replaced with a different catalog lookup implicitly.
No units/order apply. Other consumers are session-detail loading and swap-sheet
hydration; the helper also calls `DefinitionDao.getDefinitionInfo` directly in
its detailed-exercise path, outside the repository-method call count.

Source: [DefinitionDao](../../../lib/db/definition_dao.dart#L575).

## C4 — Preset weight sets

`fetchPresetSets(int presetExerciseId) -> Future<List<Map<String, dynamic>>>`.
Selects all `preset_sets` columns for that owner; `orderBy: 'order_index'` only.

| Stored field | Storage shape | Current loading semantics |
| --- | --- | --- |
| `id` | Integer primary key | Required `int`; carried as `sourcePresetSetId` |
| `preset_exercise_id` | Required integer | SQL owner; not consumed by loader; often absent in fakes |
| `weight` | Required REAL | Required `num`, converted with `toDouble`; canonical pounds |
| `reps` | Required integer | Loader requires `int`; progression accepts `num.toInt()` |
| `order_index` | Required integer | Zero-based position within parent/child lists; progression reads it, loader preserves returned list order |
| `parent_set_id` | Nullable integer | Null/missing means parent; non-null must cast to `int` for a child |

Parents are first collected from the whole result. A child can precede its
parent in the returned list and still attach by parent ID. Orphan children are
ignored. Child maps are keyed by the parent's **list index**, while persisted
child IDs remain separate. Parent/child `order_index` values can overlap; ties
have no explicit secondary SQL order. No `rpe` field exists in this contract.

Other consumer: progression, including parent selection and construction of
`_WorkingSet`. The nullable parent relation is not a declared self-FK in the
preset-set table. Do not invent repairs/default IDs in a row decoder.

Sources: [DAO](../../../lib/db/preset_detail_dao.dart#L91),
[loader](../../../lib/providers/preset_session.dart#L232),
[weight conversion](../../../lib/widgets/weight_card.dart#L296).

## C5 — Optional cardio detail

`fetchPresetCardio(int presetExerciseId) -> Future<Map<String, dynamic>?>`.
Selects one row by its unique `preset_exercise_id`; absence returns null and
the loader skips this exercise, preserving alignment of retained entries.

| Stored field | Storage shape | Current loading semantics |
| --- | --- | --- |
| `id`, `preset_exercise_id` | Required integer identities | Not consumed by loader; omitted by its mixed-type fake |
| `cardio_name` | Required text | Required `String`, also used as exercise title |
| `note` | Nullable text | `String?`; absent remains null |
| `planned_minutes` | Required integer | Required `num.toInt()`; minutes |
| `elapsed_seconds` | Required integer, SQL default 0 | Required `num.toInt()` for a present row; seconds |

Missing-row handling is distinct from a present malformed row, which currently
fails loading. No list ordering applies.
Source: [DAO](../../../lib/db/preset_detail_dao.dart#L123).

## C6/C7 — Stretch items and optional stretch name

`fetchPresetStretchItems(int presetExerciseId)` returns a list of full
`preset_stretch_items` rows ordered only by `order_index`; absent items yield `[]`.

| Stored field | Storage shape | Current loading semantics |
| --- | --- | --- |
| `id`, `preset_exercise_id` | Required integer identities | Not consumed by loader; omitted by its mixed-type fake |
| `stretch_id` | Nullable integer | `int?`; definition lookup is only for the first loaded item's non-null ID |
| `is_custom` | Required integer, SQL default 0 | Required `int`; exactly 1 becomes true |
| `custom_name`, `custom_desc` | Nullable text | `String?`; retained unchanged |
| `order_index` | Required integer | Required `num.toInt()`; zero-based position |

There is **no `is_checked` column** on these preset rows. Loading explicitly
supplies 0 to `StretchInstance.fromMap` and starts with empty completion state.
Empty items still produce a stretch exercise. Its title starts as `Stretch`;
first-item definition/custom-name lookup may replace it.

C7, `fetchStretchDefinitionNameById(int stretchId) -> Future<String?>`, reads
`stretch_definitions.name` by ID, returns null for no row, and otherwise casts
the name to `String`. A null result leaves the title fallback intact. Session
detail also uses C7. No selected test override implements this name lookup; the
mixed-type loader fake exercises a custom stretch rather than a catalog one.

Sources: [item DAO](../../../lib/db/preset_detail_dao.dart#L160),
[name DAO](../../../lib/db/lookup_dao.dart#L315),
[StretchInstance](../../../lib/models/workout_models.dart#L52).

## C8 — Optional global automatic settings

`fetchPresetAutoSettings(int presetId) -> Future<Map<String, dynamic>?>`.
Selects one complete `preset_auto_settings` row by its primary-key `preset_id`;
absent row returns null. A list order is not applicable.

| Stored field | Schema shape | PresetSession interpretation |
| --- | --- | --- |
| `preset_id` | Integer primary key | Not read from the returned row |
| `is_automatic` | Required integer, default 0 | `(value as int? ?? 0) == 1` |
| `global_increment` | Required REAL, default 5 | Present row requires `num.toDouble()`; absent row uses 5.0 pounds |
| `skip_first_set` | Required integer, default 1 | `(value as int? ?? 1) == 1` |
| `weight_check`, `rep_check` | Required integer, default 1 | Same default/equals-one rule |
| `volume_check` | Required integer, default 0 | Default 0, equals-one rule |
| `adjust_all_sets` | Required integer, default 0 | Default 0, **nonzero** rule |
| `use_manual_select` | Required integer, default 0 | Default 0, equals-one rule |
| `manual_selection_json` | Nullable text | Null/empty/invalid/non-map JSON yields empty map; only integer-parsable keys with bool values survive |
| `success_count_mode` | Required text, default `set` | Recognized `session`/`exercise`/`set`; null/unknown falls back to `set` |
| `flow_definition` | Required text, default `{}` | Not read by this loader; separate flow APIs and settings writes preserve it |

`AutoIncrementService._loadAutoSettings` additionally requires equals-one
`is_automatic` before consuming the row. It requires several flags that the
loader tolerates as missing, and interprets `adjust_all_sets` with `== 1`, not
`!= 0`. For a noncanonical stored value such as 2 these paths differ. Preserve
storage values/caller policy in the first typed-row pass; unifying validation or
behavior requires a separate decision and regression cases.

Weight/increment UI conversion uses canonical pounds; it must not be repeated
inside a DTO. Scope/manual-selection decoding can reuse existing behavior but
must not mutate the stored JSON representation as a side effect of reading.

Sources: [DAO](../../../lib/db/preset_auto_settings_dao.dart#L11),
[loader defaults](../../../lib/providers/preset_session.dart#L353),
[progression defaults](../../../lib/services/auto_increment_service.dart#L234),
[increment UI conversion](../../../lib/widgets/automatic_settings_sheet.dart#L240),
[scope parsing](../../../lib/models/preset_models.dart#L84).

## C9/C10 — Optional increment overrides

Both DAOs query one row by its owner primary key and return null if missing.

| Contract/field | Storage shape | Consumer meaning |
| --- | --- | --- |
| C9 `preset_exercise_id` | Integer primary key | Owner from the request; absent in partial fakes |
| C9 `increment_amount` | Nullable REAL | Null means inherit, `num.toDouble()` otherwise; pounds; zero is explicit |
| C9 `last_set_index` | Required integer, SQL default 1 | One-based rotating parent-set pointer; loader fallback is 2 when skipping first, otherwise 1 |
| C9 `last_node` | Nullable text | Opaque flow position; not consumed during initial load, but `saveExerciseOverride` reads and preserves it |
| C10 `preset_set_id` | Integer primary key | Owner is a parent or child set ID; absent in partial fakes |
| C10 `increment_amount` | Nullable REAL | Null means inherit, numeric value becomes double pounds; zero is explicit |

SQL defaults apply when a row is inserted, not when it is absent. Progression
starts with a last-index fallback of 1 and normalizes against actual parent
count/skip-first policy. The provider's save helper has its own fallback chain.
Do not turn these caller-specific policies into an unconditional DAO default.
Increment precedence in progression is **set override → exercise override →
global increment**. Initial loading reads overrides for every retained exercise
and all attached parent/child sets. No list ordering applies to these lookups.

Sources: [exercise DAO](../../../lib/db/preset_exercise_auto_dao.dart#L25),
[set DAO](../../../lib/db/preset_set_auto_dao.dart#L16),
[save preservation](../../../lib/providers/preset_session.dart#L808),
[progression precedence](../../../lib/services/auto_increment_service.dart#L491).

## Direct production consumers and runtime invariants

| Consumer | Selected contracts | Why it matters during migration |
| --- | --- | --- |
| `PresetSession._loadPreset` | C1–C10 | 11 syntactic read sites: C10 appears in both parent/child loops; conditional calls depend on exercise type |
| `PresetSession.saveExerciseOverride` | C9 | Preserves last node and rotation state while changing an increment |
| `AutoIncrementService` | C2/C4/C8/C9/C10 | Progression, legacy positional matching, numeric conversions and override inheritance; 6 direct read sites |
| `SessionDetailScreen` | C3/C7 | Definition labels/equipment and catalog stretch names; 2 sites |
| `SwapExerciseSheet` | C3 | Hydrates missing equipment; 1 site |

Together these are 21 direct production consumer sites in four files, excluding
ten repository-to-helper forwarding sites. Helpers delegate to the named DAOs;
their direct DAO calls have different method names and are not extra instances
of the selected public contracts.

Loading publishes the aligned `_entries` and automatic settings only after all
staged reads succeed and the load version is still current. Disposal invalidates
publication. Initial failure completes `ready` with a classified `SafeFailure`
retained for recovery; `requireLoaded` prevents editing/saving/starting an
unloaded plan. A failed `discardChanges` reload rethrows and retains prior edits.
Current independent reads do not establish a transaction-wide snapshot.

## Fake implementations and affected test surfaces

The following are the 58 selected override declarations in 14 classes/12 files.
Contract IDs refer to the inventory above. These are declarations, not test
counts; subclasses may inherit additional methods.

| Test file | Repository class | Overrides |
| --- | --- | --- |
| `test/support/preset_repository_fixture.dart` | `PresetRepositoryFixture` | C1/C2/C3/C4/C8/C9/C10 |
| `test/providers/preset_session_lifecycle_test.dart` | `_FailedInitialPresetRepository` | C2; extends the shared fixture and delegates via `super` when not failing |
| same | `_AlignedPresetRepository` | C1/C2/C3/C4/C5/C6/C8/C9/C10 |
| same | `_ReloadRacePresetRepository` | C1/C2/C8 |
| `test/screens/onboarding_and_plan_flow_test.dart` | `_PlanEditorRepository` | C1/C2/C8 |
| `test/screens/train2_settings_and_preset_edit_test.dart` | `_Train2FixtureRepository` | C1/C2/C8 |
| `test/services/auto_increment_service_test.dart` | `_FakeProgressionRepository` | C2/C4/C8/C9/C10 |
| `test/widgets/numeric_editing_regression_test.dart` | `_NumericRepository` | C1/C2/C3/C4/C8/C9/C10 |
| `test/theme/widgets/automatic_settings_sheet_theme_test.dart` | `_PresetRepository` | C1/C2/C3/C4/C8/C9/C10 |
| `test/theme/widgets/preset_detail_screen_theme_test.dart` | `_PresetRepository` | C1/C2/C3/C4/C8/C9/C10 |
| `test/theme/widgets/plan_and_goal_state_regression_test.dart` | `_PlanRepository` | C1/C2/C8 |
| `test/expressive_logbook_destination_scope_test.dart` | `_LogbookRepository` | C3 |
| `test/theme/widgets/full_history_screen_expressive_test.dart` | `_FullHistoryRepository` | C3 |
| `test/theme/widgets/session_detail_theme_ownership_test.dart` | `_SessionDetailRepository` | C3 |

All listed classes extend `AppRepository` except `_FailedInitialPresetRepository`.
`test/widgets/automatic_settings_draft_test.dart` also uses the shared fixture
without redeclaring these methods. A no-argument fake constructor still inherits
an initialized helper reference; it is not permission to call that helper.

Important fixture differences from complete SQL rows:

- Shared/numeric/theme fakes omit owner IDs and `order_index` from weight rows,
  and owner/order fields from exercise rows when their consumer doesn't read them.
- Mixed-type lifecycle data deliberately includes missing cardio and an unknown
  exercise type; its valid cardio row omits storage IDs, and stretch is custom.
- Auto-setting rows commonly omit owner IDs, flow JSON, and optional/defaulted
  fields. A null row is commonly used to mean automatic behavior is absent.
- Race/failure fakes use completers, timeouts and synchronous exceptions. A new
  adapter must preserve those override paths and cannot turn a read failure into
  a successful empty plan.

Intentionally migrate fixtures if a new API requires a larger projection; do
not force all existing raw fakes to supply every storage column accidentally.

## Validation map for the subsequent implementation

| Existing test surface (not rerun in P4-A) | Behavior to retain |
| --- | --- |
| `test/providers/preset_session_lifecycle_test.dart` | Failed-load guard/retry, mixed-type entry alignment, overlapping reloads, disposal, edits retained on failure |
| `test/services/auto_increment_service_test.dart` | Stable source links, positional fallback, progression scopes and override behavior |
| `test/widgets/automatic_settings_draft_test.dart` | Shared-fixture settings save/cancel behavior |
| `test/widgets/numeric_editing_regression_test.dart` | Editing precision and unit conversion |
| Onboarding/Train2 and listed theme test files | Route results, manual-plan opening, dirty-state/UI ownership |

Focused additions should characterize child-before-parent/orphan ordering,
int-versus-double decoding, missing/null required values, catalog stretch lookup,
zero-versus-null overrides and noncanonical flag values as the corresponding
typed contracts are migrated. These are proposed checks, not claims of existing
or newly passing tests. Source-reading contracts affected by implementation moves
also need their real behavior/ownership assertions preserved.
