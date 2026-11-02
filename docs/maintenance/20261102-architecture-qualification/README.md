# Architecture patch: review, checkpoint, CI and Pixel 7 qualification

Branch: `codex/codebase-maintainability`. Starting checkpoint: `ff24670`.
The user authorized these four follow-ups in order. This report supplements the
[original five-batch report](../20261101-architecture-boundary-follow-up/README.md).
The existing dirty patch is reviewed and checkpointed in place; unrelated untracked
paths are excluded. No frozen visual approval or deferred floating-action work is
reopened.

| Step | Scope | State |
| --- | --- | --- |
| 1 | Edge-case review of editor requests/saves, launch races/source IDs, read-only equipment lookup and calendar arithmetic | Complete: 66 focused tests, two explicit DST query-range checks, zero analyzer issues, inventory and 18-file ratchet pass |
| 2 | Checkpoint the scoped patch, push this branch and obtain uninterrupted CI results | Complete: `a66bce4` pushed; quality and release jobs green; 2,636 full-suite tests passed |
| 3 | Focused Pixel 7 smoke test with original data protected | Complete in isolated cloned data; seven original files byte-identical; temporary app removed |
| 4 | Assess the exercise-editor controller pilot and choose the next bounded candidate | Complete: retain pilot; Records history paging selected as the next bounded candidate, not implemented here |

## Review findings and corrections

1. A late catalog response could clear a newer exercise selection. Catalog reads
   now retain the selection request they started with; they may update equipment
   but cannot clear a newer selection or its draft. Invalidating an older detail
   read also clears its obsolete spinner. Two gated regression tests cover both
   interleavings.
2. A nonempty unknown equipment name could fall through to a same-named definition
   without equipment. Read-only lookup now returns no match for unknown equipment,
   retaining the optional thumbnail fallback without any insert. Primary and
   secondary equipment matching remain covered by real SQLite tests.
3. The preset route could respond twice to rapid Start taps even though the shared
   provider prevents replacing a workout. A route-local guard now excludes duplicate
   navigation until replacement finishes. Source exercise/set IDs remain preserved
   for presets; clone assertions also verify detached sets and change-set IDs.
4. Civil-day addition still used 24-hour durations in the shared calendar-day helper,
   selected-day query bounds, month-week bounds and weekday labels. These now use
   calendar constructors through LocalCalendarDay. Day-query regressions check late
   workouts on spring/autumn transition dates and the exact inclusive range end.
   Storage formats, UI palettes, shapes and navigation are unchanged.

Existing tests also cover stale successes/failures, disposal, duplicate saves,
failed-save draft retention, save/reload ordering, blocked imports/restoration,
unsupported-only plans, typed history cursor ordering and existing raw override
compatibility. Cardio/stretch remain deliberately unsupported by these launch
paths; this review does not enable unfinished features.

Local evidence is retained under `.build/maintainability/` with prefix
`architecture-edge-review-20261102-`: `tests.log`, `dst-ranges.log`, `analysis.log`,
`inventory.log` and `ratchet.log`. The two DST cases overlap the 66-case focused
batch and are not added to it as unique cases. The source contract continues to
check the actual extracted default-rule form and its page owner.

## Checkpoint and CI

The complete original architecture patch plus the edge-case corrections is
checkpointed and pushed as **`a66bce469b291b1230efceef44c3aa4a13b69873`**. Its
[Flutter CI run 41498618318](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41498618318)
completed successfully in both jobs:

- Quality job `125460031518`: uninterrupted **2,636 Flutter tests passed**; strict
  application/content analysis, localization contracts and generation checks,
  inventory/ratchet checks, host-specific Linux goldens, content-policy and Neo
  compile-time variants all passed. Seven Python guard tests and eight Node relay
  tests passed. Focused/variant runs overlap the main suite and are not added to it.
- Release job `125466478992`: Linux/Java 17 release APK built; the generated-output
  guard verified all three ML Kit reflection names and no-argument constructors.

Local formatting verification covered 26 Dart files without further edits;
`git diff --check` passed. The previously interrupted local full-suite run is
superseded for code qualification by this uninterrupted CI result. Documentation
written after the run describes this exact code SHA and does not alter app code.
No production release workflow, deployment or merge was dispatched.

## Device scope and data protection

The Pixel 7 is `28021FDH200228`, Android 16 / API 36. Its working package is
`com.tonos.expressivepreview`; other installed or retained packages/profiles are
not removed. The original was observed on Train → Overview without a pending edit,
stopped, and its databases/preferences archived before installing anything.

A unique debug package, **`com.tonos.archqa20261102`**, was absent from every
installed/retained package list for users 0 and 10. The current checkpoint was
built for that identity with database **`architecture_qa_20261102.db`** and label
"Tonos (Architecture QA)". The temporary Gradle identity/label overrides were
removed immediately after the build, and the tracked Gradle file was verified
identical to the checkpoint. No QA identity or special entry point is committed.
The APK was installed for user 0 only and its installed hash verified:
`3aecd56dab6e952a4a9dfc64b15a7f2cfcc51feee8923eed7b0331872584e593`.

SQLite's backup API copied the stopped preview database into the QA namespace;
preferences were copied only into that new app. No fixtures were reseeded. All
workout completions, editor saves, rules, theme/tab changes and the active draft
below belong exclusively to the disposable copy.

| Check | Actual Pixel evidence |
| --- | --- |
| Train / preset launch | Opened the active preset and started its five-set exercise. Completing one set, returning to Train and using quick start retained `1/5 done`; starting the preset again also kept that existing workout. |
| History repeat | Completed the disposable workout, opened its Logbook record and chose Do workout again; the repeated workout contained one unchecked set (`0/1 done`). |
| Train2 | Enabled through Edit Bottom Tabs in QA only. Its Train/History selector, preset list and empty Start Workout flow worked. Both training presentations remained distinct. |
| App/profile rules | Created an app default and a profile default in their respective dialogs; confirmed separate propagation prompts and declined propagation. App default reopened with its saved name, Weight type, plus operation and factor `1.0`; cancel returned normally. Profile count updated independently. |
| Exercise Editor | Selected Ab Wheel through the normal catalog picker. Keep editing retained a changed name; Discard restored it. A QA-only rating change from 90 to 91 saved, left edit mode, and remained `91/100` after leaving/reopening the editor and selecting the exercise again. |
| Records paging | Opened the copied Ab Wheel history, scrolled the initial page and tapped Load 10 more sessions. Additional older entries rendered through April 28 without a load error. The source copy contains 17 history rows for this definition. |
| Missing media | Added a catalog exercise without an exercise-media row to the QA workout; its existing anatomy fallback rendered in place of an image. |
| Cold restore | Force-stopped/reopened QA and resumed the newly added exercise with its unchecked set and values intact. |
| Runtime sample | The checked cold-launch/resume process log had zero matches for unhandled exceptions, fatal exceptions, missing plugins, widget exceptions or RenderFlex overflow. This is a bounded log sample, not continuous whole-session tracing. |
| Original-data preservation | All seven archived database/preferences files remained byte-identical. Before/after TAR SHA-256 is `59424d1ff697ab5fb3c8ae72f329cd9d512cd05e0b0942f0acfa09652f8024b3`; backup integrity is `ok`, schema 62, 87 tables. |
| Cleanup / final screen | Removed only the newly created QA package and its temporary phone-side files. Reopened the original preview and confirmed Train → Overview. Its APK was not replaced by the QA build. |

Private evidence remains under
`.build/maintainability/architecture-pixel7-20261102/`: before/after archives,
`preview-preservation.json`, install/clone/preflight records, selected screenshots
and the bounded runtime log. The build output is
`.build/maintainability/architecture-qa-20261102-build.log`. These artifacts are
gitignored and are not staged. The local debug APK is QA-only and must not be
mistaken for a production artifact.

Limits: this physical test uses a debug clone, not a production-signed minified
installation. Device races, injected storage failures and legacy unresolvable
definition IDs were covered by automated tests rather than forced into phone
data. Profile-rule reopening was not separately exercised; its scoped save/count
and propagation prompt were observed. No new visual approval is granted.

## Controller pilot assessment

**Retain the pilot.** The controller now owns request ordering, stale-result
suppression, selected/last-loaded definitions, save exclusion and reload/disposal
lifecycle without BuildContext or navigation. Twelve direct controller tests can
exercise failures and interleavings without constructing a widget tree. Existing
editor interaction tests and the Pixel check confirm that screen-owned field
drafts, validation, dialogs and approved presentation still work.

The screen still owns editable maps/text controllers and its presentation parts.
That is intentional; this is not a complete ViewModel conversion. The pilot adds
an explicit lifecycle boundary and tests, not a claim that total line count fell.
Its catalog boolean result also distinguishes stale work through caller behavior
and a separate failure field; future reuse should document that distinction.

**Next candidate selected: the Exercise Details Records history pager only.**
The current `_loadHistoryPage`, `_loadMoreHistory` and return-from-session refresh
share cursor, badge, loading and generation state. Extracting those operations
would have a similar measurable benefit while leaving media, form guides, metrics,
sheet resizing, tabs and rendering local to the approved sheet.

Proposed boundary and acceptance criteria for that separate future batch:

- Inject AppRepository and definition ID; reuse the typed history projection and
  preserve the raw virtual override seam. Do not import a widget-library model into
  the controller merely to reuse its name.
- Own initial/older pages, the cursor, has-more state, errors, request generation and
  generation-aware cleanup. Capture badges and exercise identity per request.
- Prove duplicate Load more taps cannot append twice, old success/failure/finally
  work cannot alter a newer exercise, failed hydration preserves the cursor and
  existing records, refresh invalidates old work, and disposal stops notifications.
- Preserve query ordering, timestamp/day semantics and every shared caller's
  appearance. Keep all theme tokens, navigation and render trees unchanged.

No further controller extraction was implemented in this task. Whole-sheet/facade
rewrites and Nutrition/Train2 floating-action coordination remain deferred.
