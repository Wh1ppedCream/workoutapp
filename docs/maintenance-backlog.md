# Maintenance Backlog

Last updated: 2026-08-31.

This is Tonos's maintained, prioritized engineering backlog. Historical
roadmap snapshots live in `docs/archive/roadmaps/`; do not use them to plan new
work. Cloud-media publishing state and commands live in
`cloud-content-roadmap.md`, `content-production-setup.md`, and
`content-release-playbook.md`.

## Current Status

`updates/backlog` contains the active release-preparation work based on
`origin/master` at `f14eee0`. The latest reported verification passed analyzer
and all 306 Flutter tests, plus locked development and production
content-target tests and release APK builds. Experimental navigation is now
explicitly excluded from release artifacts while remaining available to
development builds for future product work. Stable
exercise-catalog identities and standardized safe
error recovery are implemented, and development media manifest version 10
contains 154 of 301 exercise thumbnails (51.2%). Production media and the
diagnostics relay remain intentionally disabled. Production was last audited at
62 thumbnails and must be re-audited before promotion. Catalog revision 5,
its concise instruction format, premade-plan, alias-migration, media-source,
and quality contracts are verified locally with project-owner audit sign-off.

## Recently Completed

1. Hosted Pages, release safeguards, Android emulator, and device-flow
   automation are verified. The automatic
   [Pages deployment](https://github.com/Wh1ppedCream/workoutapp/actions/runs/31333490317)
   passed, and the manually dispatched
   [Android emulator workflow](https://github.com/Wh1ppedCream/workoutapp/actions/runs/31428848661)
   passed all setup, build, KVM, and device-driven core-flow phases on commit
   `3dfd47a`.
2. Locale visual QA is complete for Bangla, Chinese, Hindi, and Spanish across
   onboarding, training, session completion, records, reports, catalog and
   anatomy surfaces, diagnostics, settings, and representative long-copy
   layouts. The pass added localized anatomy labels, locale-aware dates and
   digits, responsive layout fixes, and regression coverage.
3. The cloud-content trust and cache boundary is hardened. Remote manifests and
   media now require HTTPS, enforce content-type and response-size limits,
   restrict redirects, and verify declared byte counts and SHA-256 hashes before
   acceptance. Downloads remain atomic, corrupt and interrupted temporary files
   are removed, stale manifest cache references and orphaned files are pruned,
   and a bounded least-recently-used policy limits cache growth. Environment
   changes trigger an immediate observable synchronization, with focused tests
   covering valid, corrupt, oversized, interrupted, redirected, and downgraded
   responses.
4. Active-workout durability failures are recoverable. Draft restore and save
   operations use bounded retries and show a non-disruptive retry banner when
   protection remains unavailable. Completing a workout atomically records any
   automatic plan progression as a durable pending job, so history remains
   saved even when progression fails; the job retries safely after restart.
   Focused coverage exercises process-death restoration, transient and
   persistent write failures, restore failures, retry UI, progression failure,
   and idempotent transaction behavior.
5. Local-data backup and export privacy is explicit. Android automatic backup
   and device transfer exclude Tonos database and preference data; releases
   disallow cleartext traffic. Exports require an explicit plaintext-data
   warning, and imports have byte, row, field, table, schema, and foreign-key
   validation before their atomic replacement transaction. Encrypted exports
   remain a deliberate future product decision.
6. Completed-workout duration semantics are unified. Persisted workout seconds
   remain the source of truth across completion, session detail, dashboard,
   history, Logbook, and report summaries. Durations below one hour retain
   seconds, aggregates sum raw seconds before formatting, and hour-scale
   summaries compact only their remaining seconds. Planned workout estimates
   and the active stopwatch intentionally retain their separate display roles.
7. The privacy-preserving diagnostics relay design and local implementation
   are complete. Direct Sentry delivery has been removed; the typed relay
   client, receipt-based deletion, no-egress Worker/D1 template, retention
   job, privacy documentation, and regression tests are present. Distributed
   builds remain relay-disabled unless a future release explicitly supplies an
   approved relay URL.
8. Production media readiness is audited. Development manifest version 10 has
   154 assets; production version 5 has 62. Production has no custom domain,
   and its promotion scope must be recalculated against the latest development
   manifest before it becomes the app default.
9. Fabricated health data is removed from selectable UI. Current Metrics now
   reads the latest persisted measurements or presents an honest empty state;
   it no longer invents body-fat, waist, hip, or placeholder metric values.
   The legacy `NewMeasurementItemPage` is retired in favor of one Measurements
   hub built on Health Trends. The hub retains bodyweight variation, height
   feet/inches or centimeters, and body-part pump context, and presents its
   trend cards as a two-column grid while the Nutrition dashboard retains its
   compact horizontal layout.
10. Localization enforcement now covers direct and conditional text,
    `SelectableText`, dialog fields, empty states, tooltips, and semantic
    labels across active screens and shared widgets. The active quick-action
    labels and remaining empty-state copy now use ARB resources. The review
    process and native-speaker sign-off log live in `localization-review.md`.
11. Body-measurement validation and lifecycle behavior is implemented. Database
    version 59 migrates known legacy qualifier notes into structured context,
    definitions and entries validate units and plausible ranges, duplicate
    definitions are rejected, and invalid input receives localized UI feedback.
12. Concurrent thumbnail downloads no longer race with cache cleanup. The
    media coordinator coalesces duplicate requests, limits optional transfers,
    and preserves active temporary files while stale interrupted downloads are
    cleaned up. Exercise/shared thumbnails and detail previews recover from a
    missing cached file once, and a cleared-cache Pixel 7 run confirmed the
    catalog loads available cloud thumbnails automatically without manual retry.
13. Exercise catalog rows now have immutable language-neutral `catalogId`
    values, stable legacy media identities, aliases, and explicit retirement
    metadata. Database version 60 migrates existing installs without changing
    visible exercise names, preserves history and media links, and adds strict
    catalog migration and identity contracts.
14. Exercise media batch 008 added 27 reviewed thumbnails and raised the
    development canonical manifest to version 10 with 154 covered exercises.
    The batch source is committed and the development app was visually checked.
15. Safe error handling and recovery UI are standardized. Required read
    failures retain privacy-safe categories and use one accessible localized
    retry surface; action failures preserve current state and show redacted
    guidance. Raw exception interpolation and retained load/save exceptions are
    blocked by focused service, widget, localization, and source-contract tests.
16. Catalog revision 2 reconciles the current lying-leg-curl name with its
    historical alias, updates every bundled plan reference, repairs copied curl
    instructions on four leg-curl variants, and keeps the canonical media source
    on the stable exercise identity. Analyzer, 14 focused catalog tests, all 260
    Flutter tests, and remote quality validation of all 154 thumbnails passed.

17. Release content selection is explicit and fail-closed. Build-time targets,
    release override locking, manifest-host allowlists, environment-scoped cloud
    metadata/cache resets, read-only release settings, a pure-Dart preflight,
    and development/production workflow contracts are implemented without
   changing ordinary debug behavior or deleting user-owned data.
18. Experimental navigation is build-gated. Nutrition Log, Combined History,
    and Form and Posing remain available for development work, while release
    builds exclude them from saved navigation, bottom navigation, and tab
    editing even if a build define is misconfigured. CI and production-release
    workflows explicitly disable the gate, and policy/workflow contracts cover
    the fail-closed behavior.
19. The final release-navigation smoke test passed on a clean signed APK
    install. Nutrition Log, Combined History, and Form and Posing were absent
    from both bottom navigation and Edit bottom tabs after restart.
20. Every catalog exercise now has concise, consistent instruction content:
   three numbered setup steps, three numbered execution steps, and three
   short safety or technique tips. Catalog revision 5 is seeded dynamically
   from the bundled source rather than through a stale test fixture, and a
   contract rejects future entries that do not retain the structured format.
21. The exercise-catalog safety, encoding, and quality audit is complete for
   the 301 active entries. Stable identities, aliases, retirement, ordering,
   lookup references, instruction structure, text encoding, and 154 thumbnail
   mappings are covered by contracts; the revision 5 baseline has project-owner
   approval recorded in `exercise-catalog-audit.md`.
22. Timestamp and local-calendar semantics are normalized. Database version 61
   stores workout and measurement instants as UTC epoch milliseconds while
   preserving separate stable local-day keys for history and calendar grouping.
   Legacy rows and imported backups are canonicalized without rewriting their
   historical display day; session, measurement, nutrition, report, record,
   badge, and chart queries now use explicit instant or calendar contracts.
   Migration, import, midnight, travel, DST, and inclusive/exclusive range
   behavior are covered by focused tests and documented in
   `timestamp-calendar-semantics.md`.
23. Backup scope and restore equivalence are defined and enforced. Export format
   v3 marks complete database snapshots and records the backup-policy version;
   a registry classifies every schema table as restored, rebuilt, or discarded.
   Full imports replace only complete v3 snapshots, while legacy partial
   exports safely merge. Recovered databases rebuild derived caches and sync
   the current bundled catalog without losing personal allocation overrides or
   durable active-workout recovery state. Transactional export, policy
   coverage, snapshot completeness, and import behavior are contract-tested.

## Findings Added By The August 23 Audit

1. Resolved: release workflows now pass `TONOS_CONTENT_ENVIRONMENT`, runtime
   consumes and validates it, and locked artifacts ignore saved/custom
   overrides. Development and production targets are separately preflighted.
2. Resolved: database version 61 separates UTC instants from stable local-day
   keys, canonicalizes legacy and imported rows, and moves workout,
   measurement, nutrition, report, and record queries off mixed ISO-text
   comparisons.
3. Resolved: export scope is defined by a versioned table-policy registry.
   Every permanent schema table has an explicit restore, rebuild, or discard
   decision; complete v3 snapshots can replace the database atomically, while
   incomplete legacy exports cannot destructively replace it.
4. Localization enforcement does not cover native plugin labels or typed domain
   results. File-picker titles, database maintenance results, and import warnings
   can still reach users as raw English strings.
5. Tonos documents operating-system clear-data and uninstall behavior, but has
   no single in-app reset that removes the database, preferences, drafts, cached
   media, and local diagnostics with one verified lifecycle.
6. Preferences use unrelated ad hoc keys and formats. Navigation still persists
   `TabItem.toString()` without a schema version, while only some dashboard and
   navigation changes have migration behavior.
7. Some active code logs raw exception text or stack traces through
   `debugPrint`, including preset generation and seed fallbacks. Remote
   diagnostics are disabled, but release-log privacy still needs a policy.
8. Signed-release localization verification differs from normal CI: CI formats
   generated localization before checking cleanliness, while the production
   workflow checks immediately after generation.

## Ranked Backlog

1. **Retire the alternative Train hub.**
   Compare `Train2Page` with the primary Train experience, preserve wanted
   behavior, migrate saved navigation preferences to versioned stable codes,
   remove `TabItem.train2`, then delete the duplicate route and screen.

2. **Rework the Exercise Editor.**
   Finalize the creator/editor workflow, expose starter-load controls where
   appropriate, validate destructive edits and identity changes, remove legacy
   form state, and split the roughly 2,000-line screen into testable sections.

3. **Improve starter-weight calibration.**
   Add first-working-set feedback for too easy, appropriate, and too hard.
   Persist conservative per-exercise adjustments, respect equipment increments
   and safety bounds, explain recommendations, and allow reset or correction.

4. **Validate generated plans and automatic progression as a product system.**
   Keep the internal deterministic rules already added, then review each
   user-visible policy separately. Cover sparse history, bodyweight movements,
   limited equipment, substitutions, failed sets, repeated sessions, deloads,
   recovery from pending progression, and explanations for every fallback.

5. **Complete health-product legal and store-readiness review.**
   Add approved fitness and injury disclaimers, decide age/eligibility rules,
   publish Terms of Use, review health claims, and complete Google Play Data
   Safety and Health Apps declarations. Document camera/barcode use, local
   health data, plaintext exports, privacy URLs, and deletion behavior.

6. **Finish production media when a custom domain is ready.**
   Re-audit production against development manifest v10, visually validate
   batches 004 through 008, upload every missing asset, publish the canonical
   manifest, run clean-install/offline/recovery release checks, and only then
   approve the explicit production release target. Do not rely on stale
   65-asset counts.

7. **Complete native-speaker localization review.**
   Qualified reviewers should approve French, Canadian French, Bangla,
   Simplified Chinese, Hindi, and Spanish terminology, pluralization, tone, and
   regional usage. Record findings and approval in `localization-review.md`.

8. **Close localization boundaries outside widget literals.**
    Replace file-picker dialog titles, maintenance result prose, import warning
    strings, domain exceptions, and other platform/plugin-facing text with typed
    codes rendered through ARB messages. Extend contracts to named plugin
    arguments and dynamic result types without exposing internal exceptions.

9. **Localize catalog entities using stable codes.**
    Exercise identity is now stable, but equipment, muscles, bodyparts,
    stretches, instructions, and built-in plans remain English-backed. Add
    language-neutral codes and localized display metadata with English fallback
    without changing history, media slugs, or user-created content.

10. **Decide the offline-first media experience.**
    Choose whether release builds accept anatomy fallbacks on a first offline
    launch or bundle a small core thumbnail set. Define first-sync messaging,
    data and battery behavior, retry policy, and low-storage behavior.

11. **Expand device, visual-regression, and accessibility coverage.**
    Split the single stateful core integration test into isolated scenarios with
    reusable fixtures. Add stable-screen goldens, navigation migration and
    release-upgrade tests, more failure/offline coverage, and recorded manual
    TalkBack and VoiceOver passes across long locales and large text.

12. **Align CI, tooling checks, and branch protection with feature branches.**
    Local enforcement is implemented: approved feature prefixes receive push
    CI, `local-db` is removed, tools and fixtures are checked, Actions are pinned
    to immutable SHAs, and Dependabot reviews Actions and Dart dependencies.
    Make signed-release localization normalization match CI, then activate the
    documented `Protect master` ruleset with the two stable required checks
    after the pull request is green.

13. **Establish release versioning and store-delivery governance.**
    Replace the static `1.0.1+5` habit with a version/build policy, release tags,
    changelog, approved-commit gate, hashes or provenance, signing-key recovery,
    and staged internal testing. A manually selected ref must not silently
    become an unlabeled production release.

14. **Version and migrate the preference schema.**
    Inventory every SharedPreferences key, replace enum `toString()` persistence
    with stable codes, add a preference schema version, and centralize migrations
    for tabs, dashboard layout, locale, units, theme, tutorials, workout exit,
    diagnostics, and content settings. Test corrupt, removed, and future values.

15. **Make optional hardware and platform permissions explicit.**
    Android currently declares camera permission without declaring camera
    hardware optional. Add the appropriate optional feature declaration and
    test installation on no-camera devices. Review permission timing and repeat
    permission, entitlement, and privacy checks for every supported platform.

16. **Create a complete licensing, attribution, and data-provenance inventory.**
    Record licenses and sources for exercise guidance, thumbnails, anatomy art,
    food catalogs, fonts, packages, and generated datasets. Add in-app or
    published notices where required and make CI reject unlicensed media rows.

17. **Complete the local-data reset and retention lifecycle.**
    Decide whether to add an in-app Delete All Local Data action. If approved,
    require typed confirmation and atomically clear the database, preferences,
    active drafts, media/cache files, local diagnostics, and relay receipts while
    explaining that user-exported files must be deleted separately. Test restart,
    partial failure, and operating-system clear-data behavior.

18. **Decide the local sensitive-data security model.**
    The database is app-private, excluded from Android backup, and exports are
    explicitly plaintext. Before release, document the threat model and decide
    whether device protection is sufficient or whether database encryption,
    encrypted exports, app lock, or additional deletion controls are needed.

19. **Choose and wire the production food-catalog strategy.**
    The app installs four starter foods while larger generated catalogs remain
    unused. Choose authoritative licensed sources, update cadence, barcode and
    locale coverage, offline size, and duplicate policy, then integrate one
    production path with startup, migration, and search-performance tests.

20. **Complete nutrition as a coherent product stream.**
    Finish logging and goal behavior, real dashboard data, custom-food photos
    and files, label/barcode flows, density and portion conversion, recipes,
    favorites, failure states, integrity tests, and all deferred localization.

21. **Restore cardio and stretch as complete vertical features.**
    Implement creation, plans, sessions, completion, repeat, history, analytics,
    records, and Save as plan together. Unify their taxonomy and duration rules
    with strength training and cover migrations, localization, and devices.

22. **Continue exercise and anatomy media.**
   Development covers 154 of 301 exercise thumbnails. Continue reviewed
    batches and establish one licensed, accessible, versioned illustration or
    heatmap direction for equipment, bodypart, and muscle media.

23. **Remove obsolete, fabricated, and unreachable implementations.**
    Delete or rebuild the unreferenced sample-data `DefaultTrendPage`, preserve
    useful assertions before removing the obsolete badge DAO, and reduce
    `active_session.dart` to the durable provider export by deleting its large
    commented legacy implementation.

24. **Continue focused database decomposition alongside related work.**
    `DatabaseHelper` remains over 5,000 lines. Extract backup/import, migration
    repair, food seeding/search, and maintenance only when focused tests can
    establish ownership. Remove duplicate schema ownership between helper and
    `Schema`, and keep transactions and upgrades explicit.

25. **Decompose other oversized feature files alongside feature work.**
    Onboarding, exercise detail, preset generation, nutrition DAO/logging,
    analytics, and chart widgets remain 1,400-3,200 lines. Extract cohesive
    controllers, query models, formatters, and sections rather than mechanically
    splitting files.

26. **Define privacy-safe release logging.**
    Replace raw exception and stack-trace `debugPrint` calls with a build-aware,
    allowlisted logger or suppress them outside development. Ensure logs never
    contain user-entered food, profile, health, file-path, URL, or database data,
    and add a source contract for release-sensitive paths.

27. **Create performance, battery, and storage baselines.**
    Measure release startup, database creation/upgrades, catalog seeding, plan
    generation, large lists and reports, image decoding, sync bandwidth, cache
    growth, memory, and battery on low- and mid-range Android devices. Establish
    budgets before larger food, image, or video catalogs ship.

28. **Perform a controlled Flutter and dependency upgrade.**
    Move beyond Flutter 3.29.3, revisit pinned chart/scanner dependencies, and
    run localization generation, analyzer, tests, release builds, and physical
    and hosted device suites. Add recurring dependency and vulnerability review.

29. **Define and enforce the supported-platform matrix.**
    Android is the only verified runtime. Do not advertise web, desktop, or iOS
    until database, file, networking, permission, media, privacy, signing, store,
    and real-device behavior are implemented and tested for that platform.

30. **Remove tracked artifacts and repair repository hygiene.**
    Move four tracked APKs (about 130 MB) to GitHub releases/artifacts, remove or
    regenerate tracked catalog-builder databases, review the 38 MB seed SQL and
    stale root notes, and fix the malformed APK ignore entry. Decide separately
    whether coordinated history cleanup is worth the disruption.

31. **Prune branches after preserving unique work.**
    `updates/backlog` is the active release-preparation branch.
    Archive or delete fully merged maintenance branches, but inspect the unique
    commits on `feature/ui-redesign` and `plugin_ver` before removing them.
    Document branch ownership and the merge/release flow.

32. **Make content status documentation generated or mechanically verified.**
    Historical production audit/changelog entries retain v9/127/65 figures while the
    development source is v10/154. Generate coverage and promotion scope from
    canonical manifests so roadmap, setup, changelog, and release reports cannot
    silently disagree.

33. **Rehearse release-candidate installation, upgrade, and rollback.**
    Install a signed clean build and upgrade from the last approved build using
    realistic data, active drafts, preferences, media cache, and imports. Verify
    schema migrations, catalog aliases/retirements, data preservation, downgrade
    policy, backup recovery, and store-delivered artifact identity.

34. **Define user support and feedback without remote diagnostics.**
    Provide an intentional support path, version/build and privacy-safe export
    instructions, response ownership, and a way to report sync/import failures
    while the diagnostics relay remains disabled.

35. **Provision the diagnostics relay only when remote diagnostics are needed.**
    When justified, create isolated staging Worker/D1 resources and validate
    consent, schema, receipt deletion, retention, abuse controls, no-egress, and
    no-logging behavior before any production relay URL is configured.

36. **Rename the internal Dart package only as a dedicated migration.**
    Platform identities use Tonos, but package imports still use `env_test`.
    Rename them together only when the churn is worthwhile and verify every
    tool, test, generated source, and platform integration in one change.

37. **Implement the planned durable media library when scale requires it.**
    Keep the verified temporary-cache recovery for current thumbnails. Before
    food images or exercise videos expand materially, follow
    `media-library-architecture-plan.md`: content-addressed no-backup storage,
    disk/index reconciliation, atomic writes, deduplication, adaptive prefetch,
    leases, quotas, bounded retries, and non-jarring image replacement.

## Working Rules

1. Keep Nutrition Log, Combined History, and Form and Posing available for
   development only. Release builds must exclude them until their implementation
   plans are approved and their complete product flows are ready.
2. Keep production media and the diagnostics relay disabled until their listed
   release gates are complete.
3. Every active user-facing feature change must include localization,
   responsive layout, semantics, failure states, and focused regression tests.
4. Update the routing map for navigation changes and all cloud-content
   documentation for every media promotion.
5. Archive superseded planning snapshots instead of leaving competing
   roadmaps, and preserve unrelated local screenshots.

## Recommended Sequence

The strongest near-term sequence is: **retire Train2 -> rework the Exercise
Editor -> implement starter feedback -> validate generated plans**.
