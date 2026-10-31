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
is recorded in the next batch update.

Progress and exact qualification results will be recorded as each batch completes.
Preserve schema/data formats, preview databases and unrelated worktree files.
No device installation, release qualification or visual reapproval is implied
by automated checks.
