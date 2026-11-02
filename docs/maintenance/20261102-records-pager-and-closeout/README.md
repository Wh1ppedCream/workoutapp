# Records pager and maintainability closeout

Branch: `codex/codebase-maintainability`. Starting checkpoint: `dfdecb2`.
This implements the four accepted follow-ups to the
[architecture qualification](../20261102-architecture-qualification/README.md).
Approved presentation and unrelated working-tree files remain protected.

| Step | Scope | State |
| --- | --- | --- |
| 1 | Extract the Exercise Details Records history pager | Complete; 16 controller regression cases |
| 2 | Verify shared sheet integration and its callers | Complete automated coverage; 135 focused tests across two disjoint batches |
| 3 | Close bounded physical minified-release evidence gaps | Bounded run complete: signed startup, restoration, session return, paging and actual camera switching verified; native import blocked and decoding waived; data preserved and QA removed |
| 4 | Consolidate evidence, checkpoint and remaining maintenance scope | Complete: current guides, index and backlog updated; scoped documentation checkpoint accompanies this report |

## Code and ownership

Code checkpoint: `07c637f981b7be55d3495f665681bff239d947ca`.

- `lib/widgets/exercise_detail/exercise_history_controller.dart` is an independent
  library that owns records, the cursor, has-more state, loading exclusion, safe
  failures and request generations. It receives AppRepository and has no
  BuildContext, navigation, theme or rendering dependencies.
- `lib/models/exercise_history_record.dart` owns the hydrated record model.
  ExerciseDetailSheet re-exports HistoryRecord for existing import compatibility.
  The record list and each set list are unmodifiable containers; ExerciseSet
  remains the existing mutable domain type, not a new durability format.
- The sheet observes the controller and retains session navigation, localized
  feedback, tabs, charts, media, form guides, safe areas and every rendering
  recipe. Returning from a session refreshes records **and badges** together.

Each refresh captures the exercise and badges for its generation. Stale success,
failure and cleanup cannot alter newer loading state. Duplicate page requests are
excluded. A page is committed only after all its hydration succeeds; a failure
retains records/cursor and offers the existing Load more action again, with safe
localized Snackbar feedback. The cursor advances from the raw page even when an
individual hydration result is missing, avoiding repeated rows after the last
renderable entry. Repository ordering, timestamp/calendar-day semantics, page
size ten and the raw virtual override seam are preserved.

This is a bounded feature extraction, not a whole-sheet ViewModel migration or a
claim that total source line count decreased. Caller routes and approved style
tokens are unchanged. Nutrition/Train2 floating-action coordination remains
explicitly deferred.

## Automated evidence

- `records-pager-qualified-20261102.log`: **51 tests passed**. This includes 16
  direct controller cases; 15 new rendered integration cases; existing typed
  projection/SQLite cursor tests; Records presentation and source/inventory
  contracts. The source contract now follows controller ownership instead of
  requiring the removed screen-owned older-record list.
- The six theme/brightness paging cases exercise failure/retry, session opening,
  return-to-sheet refresh and renewed badges. Eight Expressive cases check Catalog
  scoping from Catalog, Progress, Logbook and Analytics parent contexts. One checks
  safe initial-error copy. These are shared-API context tests, not a claim that
  every complete caller page was navigated manually.
- `records-pager-callers-20261102.log`: **84 tests passed** across the existing
  responsive Catalog/browser details, actual bodypart/muscle routes and expanded
  exercise-media layout coverage. These do not overlap the 51-case batch.
- Strict application/test/integration/driver analysis reports **No issues found**.
  Formatting of all six changed Dart files, theme inventory, the 18-file ratchet
  and `git diff --check` pass. No inventory ownership approvals were changed.

Private logs are under `.build/maintainability/`. Earlier development reruns are
not added to these counts. The uninterrupted full-suite/release result for this
code belongs to [CI run 41530871885](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41530871885).
Both jobs are green: quality job `125570389741` passed **2,667 Flutter tests**,
strict analysis, localization, inventory/ratchet, Linux goldens, content/Neo
variants, seven Python guard tests and eight Node relay tests. Release job
`125576151798` built its Linux/Java 17 APK and verified all three ML Kit reflection
names/constructors. Focused/variant counts overlap the full suite and are not
added to it. No production release workflow or deployment was dispatched.

## Device evidence

The connected Pixel 7 is `28021FDH200228`, Android 16/API 36. Its working preview
was observed on Train → Overview without a pending editor, then stopped and
archived. Unique package `com.tonos.recordsqa20261102` was checked absent from
installed **and retained** package lists in users 0 and 10. Its database is
`records_release_qa_20261102.db`; the normal application entry point is used.
Temporary Gradle identity/label overrides were removed immediately after the
build. The tracked Gradle file and dependency lock were verified unchanged before
installation.

A private database export was prepared from the stopped preview archive for the
normal native file-selection/import flow in the disposable QA app: schema 62,
integrity `ok`, 67 authoritative tables, 5,225 rows. No fixtures were reseeded.
The original preview database/preferences are never the target of these checks.
The export was **not imported**: Android's native picker returned empty local
folders, including Downloads and the internal-storage root, despite the known QA
file being present. Its external-storage provider logged `NoSuchFileException`
for `/storage/emulated` while filtering/querying documents. Import selection is
blocked in the native picker in this run; the warning is a diagnostic lead, not
an established root cause or proof that Tonos's importer is defective or qualified.
Picker opening/cancellation was observed; file selection, pre-import backup and
post-import provider reload remain physically unverified here. No system storage
permissions or filesystem mounts were changed to bypass it.

The local signed arm64 release built in **726.9s**. Signature verification and the
generated-release registrar guard passed before installation. The installed
non-debuggable APK hash is
`1dbd5985692efc20e0f26f1d5032e85a97a34710494a8ff60d67d26216e58601`.

| Check | Actual observed scope |
| --- | --- |
| Fresh startup / preferences | Skipped setup/tutorials normally in the disposable app, selected Expressive through Settings, and later changed dark to light mode. |
| Cold workout restore | Added Ab Wheel through Catalog, entered 25 lbs / ten reps and completed its set. Force-stop/relaunch/resume retained the exercise, checked set and values. Completion reported 250 lbs volume. |
| Records and session return | Opened Ab Wheel Records from Catalog and opened its saved session. Repeating/completing workouts returned to that session; returning to the sheet refreshed its history. |
| Actual older-page load | Created eleven disposable completed sessions through the normal repeat-workout flow. Records initially showed ten; Load 10 more sessions loaded the oldest 6:15 PM first record and then disappeared. No history error surfaced. |
| Light/dark | Dark Records, the older-page result and light Records were captured. The light screenshot was inspected; rendering recipes were unchanged. This grants no new visual approval. |
| Camera | Granted a fresh one-time camera permission; camera service recorded the QA package opening device 0. USB/ADB then stalled. After the user reconnected USB, a fresh QA process recorded actual device 0 → device 1 → device 0 connections, with no scanner error in the checked UI. No live camera screenshot was captured. Actual barcode decoding is explicitly left unverified at the user's request. |
| Bounded runtime sample | The fresh QA process log had zero matches for unhandled exceptions, fatal exceptions, missing plugins, RenderFlex overflow or widget-exception headers. This is not continuous whole-session tracing. |
| Original preview preservation | All seven original archived database/preferences files remained byte-identical; changed files `[]`. Both TAR hashes are `a70ac46a4b62cd4d558d779e594cb0051fb8f372fb99d138df86abc863c0878f`. Source integrity was `ok`, schema 62. |
| Cleanup / final screen | Removed the newly created QA package and exact owned phone-side files only. Confirmed the QA identity has no installed/retained entries in users 0 or 10. Cold-reopened the original preview and verified Train → Overview. Its APK was not updated. |

The camera service log recorded both camera devices being removed/re-added around
the transport interruption. In the original QA process, reopening/tapping switch
after reconnection did not establish another camera connection; the fresh-process
retry did. Camera recovery across a system-camera-service/USB disruption remains
unqualified and merits a separate bounded check. The observation does not establish
the cause of the USB stall or justify a plugin upgrade/state-management rewrite.

One native-picker search-history entry was accidentally cleared while navigating
the picker; no file was deleted. The QA helper's native matching was tightened to
exclude delete/clear/remove history actions and require exact native labels.
Preview database/preferences preservation claims are scoped to those files, not
to an unchanged entire device or picker-history store.

Private evidence is retained in
`.build/maintainability/records-releaseqa-20261102/`: install/preflight/export
metadata, before/after archives, `preservation.json`, verified Records/restoration
screenshots, camera-service snapshots, a bounded process log and `final-screen.json`.
The native file-provider warning is retained separately. The build log is
`records-releaseqa-20261102-build.log` in the parent directory. Private exports,
archives, temporary QA identity and phone inspection helpers are not staged.

## Closing scope

The combined maintenance index, codebase guide and current backlog point to this
checkpoint and distinguish current evidence from the September historical status.
Remaining bounded work is requalifying native file import on a working provider
and camera recovery after a service/transport disruption, the separately scheduled
native dependency/Kotlin migration, and explicitly deferred Nutrition/Train2
floating-action coordination. Fresh-process camera switching is now verified.
Actual barcode decoding remains waived for this run. No global ViewModel
conversion, wholesale file splitting or further controller extraction is queued.
No dependency upgrade, production deployment, merge or new visual approval is part
of this batch. This closes the broad maintainability pass with its documented
qualification limits; it does not claim production release certification.
