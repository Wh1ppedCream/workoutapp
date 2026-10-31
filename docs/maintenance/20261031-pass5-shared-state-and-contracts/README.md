# Pass 5 — shared training state and safer boundaries

Branch: `codex/codebase-maintainability`. Starting committed checkpoint:
`1826ffc`. The existing uncommitted Train/FAB work is retained.

Authorized sequence:

1. Reliable workspace SDK commands and editor configuration.
2. **Deferred by the user:** remaining floating-action coordination on Nutrition
   and Train2. Preserve the existing Train FAB improvements.
3. Shared Train/Train2 settings and launch state, cancellation, and blocked-start
   classification, preserving both presentations.
4. Typed 1RM reads and a backward-compatible active-workout codec.
5. Targeted recovery fixes supported by failure cases.
6. Deprecation migrations in tested API groups and a clean analyzer gate.
7. Further structural extraction only where responsibility and testability
   improve; no page redesign or mechanical file splitting.

## SDK and shared-training batch

- `tools/tonos.ps1` reads the CI Flutter pin, validates Flutter and its bundled
  Dart, scopes PATH to the invoked command and forwards its exit status. Missing
  SDKs fail before executing the requested tool. VS Code uses the matching SDK.
- Training defaults are refreshed when opening settings or launching an
  optimized workout. Open form drafts remain local, avoiding external updates
  overwriting unsaved input. Preference writes retain their existing serialization.
- `ActiveSession` owns one preparation reservation shared by both launch callers.
  The coordinator releases it on every return/error and the existing busy visuals
  observe this state in both pages. Actual session startup remains atomic.
- Start-block reasons distinguish failed restoration, imports, finishing and an
  existing workout. Cancellation is rechecked after rest checks, generation and
  active-plan migration. Unsupported-only plans do not start empty workouts.
- Both separate tabs and all approved appearance are preserved. Existing Train
  FAB positioning and outside-tap dismissal are retained; remaining FAB work is
  explicitly deferred.

Focused qualification: **65 tests passed**, including shared preparation,
cancellation, default refresh, settings persistence, manual creation, Train
appearance, viewport/reduced-motion cases and durable sessions. Scoped analysis
is clean.

Checkpoint qualification before typed-boundary changes:

| Check | Result |
| --- | --- |
| Full unit/widget suite | **2,552 passed**, zero failures; 12m 45s test clock. |
| Full source/test/tool analysis | Zero errors/warnings; the existing **75 deprecation infos** remain for item 6. |
| Theme inventory | **4,382 candidates**, zero unassigned; 367 Dart files. |
| Theme ratchet | All **18** protected files pass enforcement. |
| Content environments | Development and locked production checks pass. |
| Diagnostics relay | **8/8 passed**. |
| SDK safeguards | Version check, argument forwarding and missing-SDK rejection pass. |
| Compile-time variants | Locked content, explicit Neo opt-in and malformed Neo opt-in: **3/3 passed**. |

These counts overlap focused checks and are not additive. The checkpoint commit
is **bf57e56**. It includes the earlier approved Train FAB refinements. No push
was made. Git's automatic GC reported an existing malformed Codex checkpoint
ref; the commit succeeded, the ref was not repaired, and subsequent commits
use command-local `gc.auto=0`.

## Typed analytics and draft batch

- `ExerciseOneRmPoint` now crosses the repository/UI boundary. The raw virtual
  method remains for compatibility with existing overrides. SQL, limits,
  ordering, unit values and temporal fallbacks are unchanged.
- `ActiveWorkoutDraftCodec` owns the existing version-1 JSON format. Weight,
  cardio, stretch, source IDs, child sets and completion state round-trip.
  Unversioned drafts and optional-field defaults remain supported.
- Invalid object/list/value shapes and unsupported versions/types fail before
  live-state assignment. Restoration failure blocks replacement and retains
  the original stored draft for retry/recovery; no automatic reset or migration.
- `CardType` is a workout model. The widget library re-exports it to preserve
  existing imports; domain providers/services no longer depend on the widget
  library solely to name an exercise type.

Qualification: **65 focused tests passed**, covering codec compatibility and
invalid data, provider recovery, typed queries, SQLite query ownership, chart
layout/semantics, launches and preset lifecycle. Full analysis retains only the
same **75 existing deprecation infos**; no errors, warnings or new infos. Theme
ratchet enforcement passes for all 18 protected files. Full-suite qualification
will be repeated after the remaining batches; the earlier 2,552 count belongs
to the checkpoint, not these later edits.

Typed-boundary checkpoint: **1d4833c**.

## Targeted recovery batch

- Diary mutations now reject with `SafeFailure` instead of completing
  successfully after failed writes. Barcode logging already catches failures;
  recent-recipe logging and entry deletion now also show failure rather than
  false success. Reconciliation still runs; writes are never automatically
  replayed, including partially completed item-by-item batches.
- Quick-start callers open the session screen only after `startOrResume`
  succeeds. Restoration, finishing and database replacement failures remain
  distinct from an already-active workout and expose existing retry feedback.
- Failed optimization-settings saves keep the submitted values in their Retry
  callback; the existing preference writer's rollback/serialization is retained.
- Database replacement waits for in-flight preparation/temporary-plan cleanup
  before replacing tables and potentially reusing IDs. New preparation is
  rejected while replacement is reserved. This prevents cleanup touching an
  imported preset that reused an old temporary ID.

Qualification: **77 focused tests passed** for recovery, imports, sessions,
training/nutrition presentation, settings and preference rollback. Scoped
analysis is clean. Success-state appearance and all user data remain unchanged;
only failure/concurrency paths change. No device data was used for failure
injection.

Recovery checkpoint: **829bf6d**.

## Flutter API migration batch

- Tutorial visibility checks use `TickerMode.valuesOf(context).enabled`.
- Reorderable lists use `onReorderItem`, whose destination is already adjusted
  for removal. Ranking/navigation handlers no longer adjust twice. Preset lists
  use the new final-index `moveExercise`; the old `reorderExercise` method keeps
  its original insertion-index contract for existing callers.
- Radio choices use `RadioGroup` around each logical choice set. Independent
  settings have separate accessibility groups; keyboard arrows change only the
  focused group. Existing labels, tile geometry, colors and callbacks remain.
- Semantics assertions use typed `flagsCollection`, retaining distinctions
  between checked states, toggled states, selection and unavailable states.
- CI explicitly treats analyzer infos as failures. Full source/test/tool analysis
  has **zero errors, warnings and infos**, down from the 75 baseline infos.

Qualification: **155 focused API/theme tests**, **37 reorder/preset/navigation
tests**, and **6 automatic-settings theme cases** with additional keyboard and
independent-group assertions passed. These overlapping counts are not additive.
All 18 theme-ratchet files pass with the original manifest unchanged. Format and
whitespace checks pass. A full-suite run follows these focused checks.

API-migration checkpoint: **6cb89b1**.

## Structural decision

The shared launcher, isolated draft codec and typed analytics model are the
cohesive extractions needed here. Moving `CardType` to the workout model also
removes widget-library imports from the domain code while preserving its public
re-export. Each boundary now has focused failure/compatibility tests.

Further UI splitting, a blanket ViewModel conversion and broad nutrition-DAO
decomposition are deferred: no additional independent responsibility justifies
their regression risk in this pass. Existing transaction ownership and both
approved Train presentations remain intact. This completes the conditional
structural review, rather than treating file length as a reason to restructure.

## Final qualification

| Check | Result |
| --- | --- |
| Full unit/widget run | **2,577 passed; one stale assertion failed** in `food_logging_behavior_test.dart`, which still expected a failed diary write to resolve. |
| Corrected failure contract | The affected file then passed **12/12** tests, explicitly asserting `SafeFailure`, no logged entry and a retained provider error. No production code changed after the full run; there was no second whole-suite run. All 2,578 cases are covered across the full run and this focused recheck; overlapping passes are not added. |
| Static analysis | Full source/tests/integration/tools and catalog-builder analysis: **zero errors, warnings and infos**. The corrected test also has clean scoped analysis. |
| Theme inventory | **4,382 candidates**, 368 Dart files; 3,595 migrated, 144 allowlisted, 643 pending ownership candidates, zero unassigned. Inventory ownership is separate from visual approval. |
| Theme ratchet | All **18** protected files pass with the original manifest. |
| Content/relay | Development and locked-production content checks pass; **8/8** relay tests pass. |
| Compile-time variants | **3/3 passed**: locked development content, Neo release opt-in, malformed opt-in rejection. |

Schema, data formats, preview databases and unrelated worktree files are
preserved. Automated checks do not imply release qualification or new visual
approval. [Physical Pixel 7 validation](pixel7-validation.md) passed the focused
restore/settings/preset/typed-chart smoke check. The app is left on Train →
Overview, Home Gym, dark mode, with the ongoing workout retained. All user-data
tables and settings matched the pre-install snapshot; documented startup
metadata/diagnostic changes are separate.

Re-run from the existing checkout with the pinned SDK:

```powershell
.\tools\tonos.ps1 check
.\tools\tonos.ps1 dart analyze --fatal-infos lib test integration_test test_driver tools
.\tools\tonos.ps1 flutter test --no-pub
.\tools\tonos.ps1 dart run tools/theme_style_inventory.dart --check
.\tools\tonos.ps1 dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json
git diff --check 1826ffc..HEAD
```

No push is part of this pass. The unrelated untracked paths (`android/build/`,
`flutter_06.png`, `incoming/`, `test/theme/widgets/failures/`, and `tmp/`) are
left untouched.

Remaining boundaries: item 2 is explicitly deferred. Existing raw repository
APIs remain for compatibility; this is not a mechanical conversion of all maps.
Android builds still report future-support warnings for Gradle 8.14.5, AGP
8.11.1 and Kotlin 2.2.21. Those upgrades need a separate compatibility pass;
the build's validation was not bypassed. iOS/release qualification and device
performance benchmarks are outside this pass.
