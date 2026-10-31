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

Progress and exact qualification results will be recorded as each batch completes.
Preserve schema/data formats, preview databases and unrelated worktree files.
No device installation, release qualification or visual reapproval is implied
by automated checks.
