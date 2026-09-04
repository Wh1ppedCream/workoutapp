# Localization Handoff Review

Last updated: 2026-09-03.

This document records the catalog-localization work in the current uncommitted
working tree. The exact point at which the active coding model changed could
not be established from repository state, so this handoff begins with the
work presently visible in the branch. Treat it as a review checklist, not as
evidence that every item is release-ready.

## Current Handoff Snapshot (2026-09-03)

This section is authoritative for the current mode switch. The dated entries
under `Change Log` preserve historical details, including older entries that
said verification was still pending at the time they were written.

### Repository State And Safety

- Repository: `E:\projects\env_test`.
- Branch: `updates/backlog`.
- Current `HEAD`: `3283966` (`Localize and validate exercise catalog content`),
  based on the branch's existing `origin/master` base at `f14eee0`.
- The three latest commits relevant to this handoff are `d8b7a56` for UTC
  timestamp/local-calendar semantics, `8136dcb` for database backup scope and
  restore policy, and `3283966` for exercise-catalog content localization and
  audit coverage.
- The stable catalog-entity localization, broader ARB presentation changes,
  generated localization output, tests, and related CI contract changes are
  currently uncommitted in the working tree. Do not assume they are included
  in `HEAD` or on the remote branch.
- `flutter_01.png`, `flutter_02.png`, `flutter_03.png`, and `tmp/` are
  untracked development artifacts. Do not stage them unless the owner
  explicitly requests them.
- No commit or push is part of this handoff update. Review the combined diff
  before deciding whether to split or commit the work.

### Recent Timeline

#### 2026-08-30: Timestamp And Local-Calendar Semantics

Commit `d8b7a56` introduced the explicit distinction between an absolute UTC
instant and the user's stable local calendar day. Database version 61 and the
temporal model/migration code canonicalize legacy and imported values while
preserving historical display days. Workout, measurement, nutrition, report,
record, badge, chart, session, and calendar queries now choose an explicit
instant or local-day contract instead of relying on mixed ISO-text comparisons.
Midnight, travel, DST, migration, import, and inclusive/exclusive range
behavior are covered by focused tests and documented in
`docs/timestamp-calendar-semantics.md`.

#### 2026-08-31: Backup Scope And Restore Equivalence

Commit `8136dcb` defined the database export policy and created
`docs/database-backup-scope.md`. Export format v3 identifies complete database
snapshots and records the backup-policy version. Every permanent schema table
has an explicit restored, rebuilt, or discarded classification. Complete v3
snapshots can replace the database atomically; incomplete legacy exports use a
safe merge path. Derived caches are rebuilt and the bundled catalog is synced
after recovery without discarding personal allocation overrides or durable
active-workout recovery state. The policy, privacy, export, import, and
transaction behavior are covered by contract tests.

#### 2026-09-01: Exercise Catalog Content Localization

Commit `3283966` added the exercise content localization foundation. The
canonical `assets/exercises.json` catalog remains the source for IDs, matching,
history, media, plan references, and persistence. The new
`assets/exercise_content_localizations.json` bundle provides display names and
concise setup, execution, and tip guidance for all 300 active exercises in
Spanish, French, Bangla, Simplified Chinese, and Hindi. Canadian French falls
back to French. The catalog audit contract protects stable identity, ordering,
aliases, retirement, structured guidance, encoding, and media references.

#### 2026-09-02 to 2026-09-03: Uncommitted Localization And Identity Pass

The current worktree extends the committed exercise-content work to the rest
of the durable, release-visible catalog presentation boundary:

- Stable lookup identities were added for 40 equipment entries, 56 muscles,
  and 137 stretches in `assets/catalog_entity_registry.json`. IDs use typed
  prefixes such as `tonos.equipment.####`, `tonos.muscle.####`, and
  `tonos.stretch.####`; canonical names remain the source-owned values.
- Database version 62 adds nullable `catalog_id` columns and partial unique
  indexes to the equipment, muscle, and stretch lookup tables. Seeding assigns
  IDs to shipped rows and backfills only exact canonical-name matches. A null
  ID deliberately means custom or legacy data and must not be guessed from
  translated text.
- `Equipment`, `Muscle`, and `StretchDefinition` now carry optional stable
  catalog IDs. Lookup and detailed-definition DAO paths hydrate those IDs,
  including primary equipment, secondary equipment, muscles, and stretches.
- `assets/catalog_entity_localizations.json` adds complete display-name maps
  for all 40 equipment and 56 muscle IDs in Spanish, French, Bangla,
  Simplified Chinese, and Hindi. Stretch IDs exist for future work, but stretch
  names and descriptions are not localized yet.
- `CatalogEntityLocalizer`, `LocalizedCatalogEntityName`, and the plural name
  builder resolve built-in labels by stable ID. The canonical stored name is
  used for English, missing translations, malformed/loading failures, and
  custom rows. The resolver never changes database values.
- Equipment and muscle display resolution now reaches the active catalog,
  catalog filters, onboarding, gym profiles, exercise editor, swap flows,
  anatomy filters and details, body-part mapping, dashboard usage, analytics,
  volume boundaries, muscle ranking, percentages, weekly views, and relevant
  completed-workout detail. Canonical names still drive matching and
  persistence.
- `assets/premade_plan_localizations.json` and `PremadePlanLocalizer` add
  source, group, plan-name, and description presentation for 21 direct built-in
  plan IDs in the five base locales. All 25 runtime plan objects are covered
  through those direct IDs plus four derived one-hour variants. One-hour copy
  uses the localized duration label, plan name, and ARB-backed parameterized
  message. Plan exercise rows resolve their 117 authored references through
  stable exercise IDs, covering 36 unique exercises; equipment rows resolve
  through the shared equipment identity boundary.
- `premade_plans_page.dart` now renders localized source/group/name/description,
  exercise, and equipment labels while continuing to use canonical values for
  filtering, adaptation, copying, persistence, and saved-plan behavior.
- The ARB resources and checked-in generated Dart API were synchronized across
  English, Spanish, French, Canadian French, Bangla, Simplified Chinese, and
  Hindi. Every resource has the same 1,933 canonical message keys and runtime
  placeholders. The latest correction pass fixed Canadian-French placeholder
  wording in logbook week/month messages, anatomy target/set messages, and
  ranking messages.
- `LocalizedFormatters`, the weight-unit formatter, and localization extension
  helpers now centralize locale-aware dates, times, numbers, percentages,
  compact values, unit names, allocation-source labels, and the Western-digit
  Bangla policy. Active history, calendar, report, dashboard, measurement,
  analytics, database-health, onboarding, and workout-detail presentation paths
  use these helpers where they were audited.
- Navigation preferences now write stable storage IDs instead of
  `TabItem.toString()` values while still reading legacy enum strings. Widget
  test keys use the stable storage ID, so display-language changes cannot alter
  persisted navigation or test identity.
- The CI workflow now has an explicit localization contract step covering
  hardcoded-copy detection, reviewed-identical-English policy, ARB structure,
  localization smoke, media accessibility, and record-badge locale switching.

### Current Test And Verification Evidence

The latest user-run deterministic verification on 2026-09-03 reported:

- `flutter gen-l10n` completed successfully. The `l10n.yaml` informational
  message is expected because the project intentionally owns those options.
- Generated localization sources were formatted; seven generated files were
  changed by formatting and then confirmed clean against the generator output.
- The targeted analyzer reported `No issues found!`.
- The focused Flutter run covering ARB structure, reviewed-English policy,
  localization smoke, premade-plan localization, locale-aware formatters,
  record badges, and workflow policy passed: `00:09 +31: All tests passed!`.
- `git diff --check` passed with no content errors. Git printed only expected
  LF-to-CRLF working-tree warnings.
- Earlier recorded foundation checks include 21 passing catalog-identity
  migration/registry tests, passing catalog-entity localizer and localization
  contract tests, remote validation of 154 exercise-media assets, and a
  previously recorded full suite of 337 Flutter tests. Those results should be
  treated as historical evidence until the combined current worktree is run
  again.

The current handoff update itself changes documentation only. It does not
rerun Dart or Flutter commands from the agent environment.

### Before/After User-Visible Behavior

- Before, active release-visible catalog labels generally rendered canonical
  English lookup names. After this pass, built-in exercise, equipment, muscle,
  and premade-plan presentation can follow the selected supported locale.
- Before, many date, time, number, unit, allocation-source, quick-action,
  empty-state, and record-label paths assembled English-oriented presentation
  directly. After this pass, audited paths use ARB messages or shared locale
  formatters, including locale refresh for already-open widgets in the tested
  cases.
- Before, saved navigation order/enabled-tab values used enum string forms.
  After this pass, new writes use stable language-neutral keys and legacy
  values remain readable.
- Canonical exercise/lookup names, stable IDs, media slugs, history, saved
  plans, imports, exports, matching, and user-created names are intentionally
  unchanged. This is a presentation localization boundary, not a data rewrite.
- A stable-ID resolver may briefly show a canonical fallback while its asset
  bundle is loading, and translated labels can be longer than English. This is
  why layout, locale-switch, accessibility, and page-level review remain open.

### File Map For Review

Use this map with `git diff` when reviewing the current uncommitted pass:

- Canonical exercise content: `assets/exercises.json`,
  `assets/exercise_content_localizations.json`,
  `lib/services/exercise_content_localizer.dart`, and
  `lib/widgets/localized_exercise_name.dart`.
- Stable entity identity: `assets/catalog_entity_registry.json`,
  `assets/catalog_entity_localizations.json`,
  `lib/services/catalog_entity_registry.dart`,
  `lib/services/catalog_entity_localizer.dart`, and
  `lib/widgets/localized_catalog_entity_name.dart`.
- Database identity plumbing: `lib/db/schema.dart`, `lib/db/seed.dart`,
  `lib/db/lookup_dao.dart`, `lib/db/definition_dao.dart`,
  `lib/db/database_helper.dart`, `lib/db/gym_profile_dao.dart`,
  `lib/models/definition_models.dart`, and `lib/models/workout_models.dart`.
- Premade plans: `assets/premade_plan_localizations.json`,
  `lib/services/premade_plan_localizer.dart`,
  `lib/data/premade_training_plans.dart`, and
  `lib/screens/exercise/premade_plans_page.dart`.
- Shared localization and formatting: `lib/l10n/app_*.arb`,
  `lib/l10n/generated/`, `lib/l10n/app_localization_extensions.dart`,
  `lib/utils/localized_formatters.dart`,
  `lib/utils/weight_unit_formatter.dart`, and the active history, report,
  dashboard, measurement, analytics, onboarding, settings, and workout-detail
  consumers shown in `git status`.
- Navigation persistence: `lib/providers/nav_bar_config.dart` and
  `lib/main.dart`; stable storage keys are read alongside legacy enum strings
  and written for new preferences.
- Enforcement and regression tests: `.github/workflows/ci.yml`,
  `test/localization/`, `test/services/`, `test/db/`,
  `test/premade_plan_exercise_catalog_contract_test.dart`,
  `test/widgets/`, `test/utils/`, and `test/providers/app_configuration_test.dart`.
- Review records: `docs/localization-remaining-inventory.md`,
  `docs/localization-review.md`, `docs/localization-reviewed-english.json`,
  `docs/exercise-catalog-localization.md`,
  `docs/exercise-catalog-audit.md`, `docs/exercise-catalog.md`,
  `docs/testing.md`, and this handoff.

### Open Review Items And Known Boundaries

1. Native-speaker review has not been completed for French, Canadian French,
   Spanish, Bangla, Simplified Chinese, or Hindi. This includes exercise
   guidance, equipment, muscle, plan, terminology, pluralization, tone, and
   Canadian regional usage. Keep every row in `docs/localization-review.md`
   marked Pending until a qualified review is recorded.
2. Page-level widget tests are still needed for premade-plan grouping,
   copying, duplicate-name handling, loading/fallback behavior, and live locale
   switching. Similar page-level coverage remains limited for catalog filters,
   anatomy screens, and long translated labels.
3. Search and filtering still use canonical stored names in several paths.
   Decide whether translated labels should also be searchable, then implement
   that deliberately rather than silently changing matching semantics.
4. Some persisted exercise/workout/plan snapshots still contain only display
   text or incomplete catalog identity. Built-in labels should be localized
   only when a stable ID is present; legacy and user-created snapshots must
   retain their saved names until a separate migration policy is approved.
5. Stretch display localization is deferred even though stretch IDs now exist.
   Nutrition catalog entities, nutrients, foods, and related product copy are
   also deferred. Do not mark those bundles complete because the registry
   exists.
6. Dynamic error/result prose and some plugin/native-facing strings remain an
   open localization boundary outside the current widget and ARB contracts.
   Continue using typed safe-failure results rather than exposing raw
   exceptions.
7. Automated tests do not replace physical-device TalkBack/VoiceOver review,
   large-text checks, visual regression baselines, or signed-release locale
   switching. The supported-platform decision determines the VoiceOver gate.
8. The combined working tree is broad. Review the full diff for accidental
   behavior changes, generated-file drift, and unrelated edits before staging;
   do not assume a clean commit boundary from the current file list.

### Recommended Review Order For The Next Model

1. Read this current snapshot, then inspect `git status --short` and the full
   diff. Start with the catalog registry/localizer, database v62 migration,
   premade-plan resolver/page, and ARB/generated-file changes.
2. Verify the JSON assets structurally and confirm that every referenced stable
   ID maps to the intended canonical row. Pay special attention to custom rows,
   aliases, legacy names, `fr_CA` fallback, and one-hour derived plans.
3. Run the single PowerShell verification block in this document. If anything
   fails, fix the smallest boundary and rerun the focused test before the full
   suite. Do not stage screenshots or `tmp/`.
4. Perform a manual locale switch on the catalog, anatomy, premade-plan,
   history/report, measurements, settings, and onboarding surfaces. Repeat the
   highest-risk screens at increased text size and with TalkBack enabled.
5. Have native speakers review the translations and record findings in
   `docs/localization-review.md`. Keep product decisions such as translated
   search and copied-plan naming separate from mechanical fixes.
6. Only after review should the owner decide whether to commit the combined
   pass or split database identity, catalog localizers, ARB presentation, and
   premade-plan work into separate commits.

## Objective

Localize shipped catalog entities by immutable identity while preserving
canonical English database values for matching, imports, exports, media,
existing plans, and user-created records. Custom or legacy rows without a
shipped identity must remain verbatim.

## Completed And Verified

### Stable lookup identities

- Added `assets/catalog_entity_registry.json` with immutable IDs for all
  shipped lookup rows: 40 equipment entries, 56 muscles, and 137 stretches.
- Added nullable `catalog_id` storage for `equipment`, `muscles`, and
  `stretch_definitions` in database migration 62.
- Seeding assigns registry IDs to shipped rows and backfills matching legacy
  rows without rewriting their canonical names.
- DAO hydration exposes the nullable ID through `Equipment`, `Muscle`, and
  `StretchDefinition` models.
- Added registry, migration, schema-upgrade, seed, and source-parity tests.

Verification already reported for this foundation: analyzer passed and 21
targeted Flutter tests passed.

### Equipment and muscle display resolver

- Added `assets/catalog_entity_localizations.json`.
- Added `CatalogEntityLocalizer` and the reusable
  `LocalizedCatalogEntityName` / `LocalizedCatalogEntityNamesBuilder` widgets.
- Equipment has translations for Spanish, French, Bangla, Simplified Chinese,
  and Hindi.
- Muscles have translations for Spanish, French, Bangla, Simplified Chinese,
  and Hindi. The localization contract requires all 56 shipped muscle IDs in
  each of these locales.
- The exercise catalog row and exercise-detail sheet now resolve equipment and
  muscle labels through stable IDs. Canonical names remain the loading,
  English, missing-translation, and custom-row fallback.

Latest deterministic evidence: generated localization output was regenerated,
the targeted analyzer passed, and the focused localization/workflow run passed
31 tests. Earlier focused catalog-registry and catalog-localizer tests also
passed. Re-run the verification commands below before commit.

## Implemented With Review Open: Premade Plans

- `PremadeTrainingPlan.catalogId` now derives `tonos.plan.<id>` from its
  existing immutable `id`.
- Added `assets/premade_plan_localizations.json` with direct translations for
  all 21 non-derived built-in plan IDs in Spanish, French, Bangla, Simplified
  Chinese, and Hindi.
- Added `PremadePlanLocalizer` and `LocalizedPremadePlan` data model.
- The resolver parses a plan bundle and falls back to canonical plan fields.
- The default asset-loader initializer initially failed Dart analysis because
  its closure was not parenthesized in the constructor initializer; this was
  corrected on 2026-09-01 and later analyzer/test runs passed.
- `premade_plans_page.dart` now resolves localized source, group, name, and
  description fields while retaining canonical plan data for persistence,
  filtering, adaptation, and exercise writes.
- Derived one-hour plans inherit localized source, group, and name fields and
  receive a localized one-hour description from the resolver.

Premade-plan localization is implemented for the current release-visible
surface and has locale, parity, fallback, and integration coverage. Keep the
page-level widget review and native-speaker review open before calling it
release-ready.

## Explicitly Deferred

- Stretch names and descriptions: IDs exist, but no localization content or
  display integration has been added.
- Native-speaker review and page-level widget coverage for built-in muscle
  labels remain required; active consumers now resolve through stable IDs.
- Stable-ID equipment display integration is complete for the current
  release-visible consumers, including premade-plan previews and completed
  workout detail; legacy free-text snapshots still use their canonical names.
- Built-in plan exercise names now resolve through exercise `catalogId` in plan
  previews. Copied/custom plan snapshots intentionally keep their saved
  display names.
- Nutrition catalog entities are not part of this current implementation.
- Native-speaker terminology review remains required before release.

## Sol Review Checklist

1. Validate migration 62 and seed backfill cannot incorrectly claim a
   user-created row that happens to share a shipped canonical English name.
2. Confirm all definition DAO query paths select and hydrate lookup
   `catalog_id` fields, not only the main detailed-definition query.
3. Review every translation in `catalog_entity_localizations.json` for
   terminology, spelling, locale appropriateness, and UTF-8 integrity.
4. Confirm the asynchronous label widgets do not cause layout shifts,
   duplicate semantics, stale labels after locale changes, or visible fallback
   flashes that would harm the catalog experience.
5. Audit catalog filtering/search: stored canonical values are intentionally
   retained for matching, but translated-label search behavior still needs a
   product decision and implementation.
6. Review the plan resolver and page integration, including the loader
   injection constructor, direct-ID parity, derived one-hour inheritance, and
   regional fallback (for example `fr_CA -> fr`).
7. Extend tests for custom lookup rows, unknown IDs, empty or malformed
   bundles, locale switching, database upgrades, and page-level rendering.
8. Do not commit screenshots (`flutter_01.png` through `flutter_03.png`) or
   `tmp/` unless deliberately requested.

## Required Verification Before Commit

```powershell
Set-Location E:\projects\env_test

flutter gen-l10n

dart format `
  lib\data\premade_training_plans.dart `
  lib\services\catalog_entity_registry.dart `
  lib\services\catalog_entity_localizer.dart `
  lib\services\premade_plan_localizer.dart `
  lib\screens\exercise\premade_plans_page.dart `
  lib\widgets\localized_catalog_entity_name.dart `
  lib\screens\exercise\exercise_catalog_page.dart `
  lib\widgets\exercise_detail_sheet.dart `
  test\services\catalog_entity_registry_test.dart `
  test\services\catalog_entity_localizer_test.dart `
  test\catalog_entity_registry_contract_test.dart `
  test\catalog_entity_localization_contract_test.dart `
  test\db\catalog_entity_identity_migration_test.dart `
  test\services\premade_plan_localizer_test.dart `
  test\localization\arb_structure_contract_test.dart `
  test\localization\reviewed_english_values_contract_test.dart `
  test\localization\localization_smoke_test.dart `
  test\utils\localized_formatters_test.dart `
  test\widgets\workout_record_badges_test.dart `
  test\github_workflow_contract_test.dart

dart analyze lib test integration_test test_driver

flutter test

git diff --check
git status --short
```

## Ongoing Logging Rule

For every subsequent localization pass, add a dated entry under this heading:

### Entry Template

- Date:
- Scope and locale(s):
- Stable IDs/data changed:
- UI consumers changed:
- Tests added or updated:
- Verification result:
- Remaining risk or reviewer question:

### Change Log

#### Latest Verification

- Date: 2026-09-03
- Scope and locale(s): Deterministic localization resources and runtime
  placeholder handling across English, Spanish, French, Canadian French,
  Bangla, Simplified Chinese, and Hindi.
- Stable IDs/data changed: No canonical catalog names, IDs, history, media,
  or stored user values changed. All 1,933 ARB keys remain present in every
  locale, and the Canadian-French logbook, anatomy, and ranking placeholder
  corrections are synchronized with generated Dart output.
- UI consumers changed: No additional consumer boundary was introduced in
  this verification pass; the previously added stable-code exercise,
  equipment, muscle, and premade-plan resolvers remain the active boundaries.
- Tests added or updated: ARB structure, reviewed-English, locale smoke,
  formatter, record-badge, premade-plan, and workflow contracts were run;
  generated localization output was regenerated and formatted.
- Verification result: Targeted analyzer passed and the focused Flutter run
  passed 31 tests. `git diff --check` reported no content errors beyond
  expected line-ending warnings.
- Remaining risk or reviewer question: Native-speaker review, page-level
  rendering review, accessibility review, and signed-device locale switching
  remain open. Historical entries below preserve the state recorded when
  those earlier passes were first completed.

- Date: 2026-09-03
- Scope and locale(s): Built-in muscle display names in Spanish, French,
  Bangla, Simplified Chinese, and Hindi.
- Stable IDs/data changed: No canonical names, ranks, filters, or stored values
  changed. Confirmed all 56 registry muscle IDs have translations in each
  supported locale. Both detailed definition DAO query paths now hydrate
  `catalog_id` for muscles (and preserve the same identity for equipment).
- UI consumers changed: Muscle labels now resolve through the shared stable-ID
  localizer in the anatomy filter/search list, exercise catalog filter,
  body-part and muscle detail pages, catalog/dashboard/weekly analytics,
  muscle percentages, body-part mapping, volume boundaries, muscle ranking,
  exercise analytics, and the exercise editor. Canonical names remain the
  fallback and continue to drive matching and persistence.
- Tests added or updated: Extended the detailed DAO hydration test for full and
  by-ID loads, and added a widget test covering translated built-in labels,
  custom-name fallback, and locale switching. Existing registry/localization
  parity contracts remain the data gate.
- Verification result: Awaiting the user-run formatter, analyzer, focused
  localization/DAO/widget tests, and full suite for this pass.
- Remaining risk or reviewer question: Native-speaker review remains required;
  the async resolver should be checked on real devices for any unacceptable
  fallback flash or text reflow in long translated labels.

- Date: 2026-09-01
- Scope and locale(s): Built-in plan metadata in Spanish, French, Bangla,
  Simplified Chinese, and Hindi.
- Stable IDs/data changed: Added `sourceName`, `groupName`, `name`, and
  `description` for all 21 direct `tonos.plan.*` IDs. One-hour derived IDs
  continue to inherit their base plan by stable ID.
- UI consumers changed: None in this pass; `premade_plans_page.dart` still
  needs resolver integration before users see the translated plan metadata.
- Tests added or updated: Added shipped-asset parity coverage for all five
  locales and all direct plan IDs in
  `test/services/premade_plan_localizer_test.dart`.
- Verification result: Awaiting the user-run analyzer and focused Flutter
  test commands.
- Remaining risk or reviewer question: Native-speaker review is still needed,
  and the UI integration must be tested for loading, fallback, and locale
  changes before this work is release-ready.

- Date: 2026-09-02
- Scope and locale(s): Premade-plan presentation integration for Spanish,
  French, Bangla, Simplified Chinese, and Hindi.
- Stable IDs/data changed: No canonical IDs or exercise contents changed;
  the page resolves all 25 runtime plan objects, including four derived
  one-hour plans, from the 21 direct localized IDs.
- UI consumers changed: `premade_plans_page.dart` now displays localized
  source headers, group headers, plan names, and descriptions. Add/copy,
  adaptation, and saved-plan behavior continue to use canonical data.
- Tests added or updated: The shipped bundle parity test now covers all five
  locales and all direct IDs; page-level widget coverage remains to be added.
- Verification result: Analyzer passed; focused localization/database tests
  passed (5 tests); the full suite passed (337 tests); the bundle check passed
  at 5 locales x 21 direct plans; and `git diff --check` passed. Expected
  durability recovery logs were emitted without test failures.
- Remaining risk or reviewer question: The new translations need
  native-speaker review, and a manual locale-switch check should confirm that
  expanded/collapsed plan sections remain stable while labels refresh.

- Date: 2026-09-02
- Scope and locale(s): Derived one-hour plan descriptions and exercise names
  in premade-plan previews for Spanish, French, Bangla, Simplified Chinese, and
  Hindi, with English fallback behavior preserved.
- Stable IDs/data changed: Added explicit catalog IDs for all 117 built-in
  plan exercise rows covering 36 unique exercises. Added a parameterized
  `premadeOneHourDescription` ARB message to all supported locale resources,
  including French Canadian, and synchronized the checked-in generated API.
- UI consumers changed: Premade-plan preview rows now resolve exercise names
  by stable exercise ID at render time. Generated one-hour descriptions now
  use the localized duration label and localized plan name. Canonical names,
  equipment text, adaptation, copying, and saved-plan contents are unchanged.
- Tests added or updated: Added the premade exercise-to-catalog identity
  contract, ARB placeholder/key coverage, resolver-by-ID coverage, and English
  and translated one-hour builder coverage.
- Verification result: Awaiting the user-run localization generation,
  analyzer, focused tests, and full suite for this pass.
 copying, duplicate names, and live locale switching is still outstanding;
 native-speaker review remains required for the new plan-description wording.

- Date: 2026-09-02
- Scope and locale(s): Built-in equipment display names in Spanish, French,
  Bangla, Simplified Chinese, and Hindi.
- Stable IDs/data changed: No canonical equipment names or matching values
  changed. Profile equipment hydration now retains catalog_id; editor state
  also retains the ID alongside the canonical name.
- UI consumers changed: Equipment labels now resolve through the shared stable
  ID localizer in catalog filters, onboarding, gym profiles, the exercise
  editor, catalog usage, anatomy metadata, dashboard usage, and swap rows.
- Tests added or updated: Equipment bundle parity now enforces exactly 40
  entries per supported locale with non-empty values. Added a profile-query
  contract proving catalog_id survives hydration and a premade-plan contract
  proving authored equipment names resolve through the registry.
- Verification result: Awaiting the user-run formatter, analyzer, focused
  equipment/localization tests, and full suite.
- Remaining risk or reviewer question: Premade-plan previews and completed
  workout details now localize equipment when a stable definition/registry ID
  is available. Persisted WeightExercise.equipment snapshots still have no
  catalog ID, so legacy-only historical rows remain canonical until a separate
  storage migration adds that identity.

- Date: 2026-09-02
- Scope and locale(s): Built-in equipment labels in premade-plan previews and
  completed workout detail for Spanish, French, Bangla, Simplified Chinese, and
  Hindi.
- Stable IDs/data changed: Added an explicit stable-ID mapping for the 12
  equipment names used by shipped premade-plan rows. No WeightExercise snapshot
  or matching value changed.
- UI consumers changed: `premade_plans_page.dart` resolves equipment labels
  through the shared localizer. `session_detail_screen.dart` resolves labels
  from the linked exercise definition and preserves the canonical fallback for
  legacy rows without a definition.
- Tests added or updated: Extended the premade exercise catalog contract to
  verify every authored equipment label maps to the registry; existing bundle
  parity and localizer tests remain the display-data gate.
- Verification result: Awaiting the user-run formatter, analyzer, focused
  equipment/localization tests, and full suite.
- Remaining risk or reviewer question: Historical snapshots that only contain
  free-text equipment cannot be localized without a future persisted identity
  migration, and native-speaker review remains required for all new labels.
