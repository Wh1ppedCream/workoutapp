# Maintenance Backlog

Last updated: 2026-08-19.

This is Tonos's maintained, prioritized engineering backlog. Historical
roadmap snapshots live in `docs/archive/roadmaps/`; do not use them to plan new
work. Cloud-media publishing state and commands live in
`cloud-content-roadmap.md`, `content-production-setup.md`, and
`content-release-playbook.md`.

## Current Status

`updates/backlog` contains the active release-preparation work and remains ahead
of `origin/master`. The latest reported verification passed analyzer and all
252 Flutter tests. Stable exercise-catalog identities and standardized safe
error recovery are implemented, and development media manifest version 10
contains 154 of 313 exercise thumbnails (49.2%). Production media and the
diagnostics relay remain intentionally disabled. Production was last audited at
62 thumbnails and must be re-audited before promotion.

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

## Ranked Backlog

1. **Resolve the visible unfinished release surfaces.**
   Keep Nutrition Log, Combined History, and Form and Posing selectable as
   requested, but replace their literal placeholder pages with approved product
   plans and honest designed states. Decide whether Nutrition Log should route
   into the existing nutrition flow instead of remaining a duplicate entry.

2. **Audit the exercise catalog for safety, encoding, and content quality.**
   Review all 313 definitions for unsafe or misleading guidance, duplicates,
   equipment compatibility, ranking quality, starter metadata, and terminology.
   Fix the confirmed mojibake in the Ab Wheel notes and add Unicode, schema,
   identity, alias, retirement, ordering, and semantic content contracts.

3. **Retire the alternative Train hub.**
   Compare `Train2Page` with the primary Train experience, preserve wanted
   behavior, migrate saved navigation preferences to versioned stable codes,
   remove `TabItem.train2`, then delete the duplicate route and screen.

4. **Rework the Exercise Editor.**
   Finalize the creator/editor workflow, expose starter-load controls where
   appropriate, validate destructive edits and identity changes, remove legacy
   form state, and split the roughly 2,000-line screen into testable sections.

5. **Improve starter-weight calibration.**
   Add first-working-set feedback for too easy, appropriate, and too hard.
   Persist conservative per-exercise adjustments, respect equipment increments
   and safety bounds, explain recommendations, and allow reset or correction.

6. **Validate generated plans and automatic progression as a product system.**
   Keep the internal deterministic rules already added, then review each
   user-visible policy separately. Cover sparse history, bodyweight movements,
   limited equipment, substitutions, failed sets, repeated sessions, deloads,
   recovery from pending progression, and explanations for every fallback.

7. **Complete health-product legal and store-readiness review.**
   Add approved fitness and injury disclaimers, decide age/eligibility rules,
   publish Terms of Use, review health claims, and complete Google Play Data
   Safety and Health Apps declarations. Document camera/barcode use, local
   health data, plaintext exports, privacy URLs, and deletion behavior.

8. **Finish production media when a custom domain is ready.**
   Re-audit production against development manifest v10, visually validate
   batches 004 through 008, upload every missing asset, publish the canonical
   manifest, run clean-install/offline/recovery release checks, and only then
   switch the default from development. Do not rely on stale 65-asset counts.

9. **Complete native-speaker localization review.**
   Qualified reviewers should approve French, Canadian French, Bangla,
   Simplified Chinese, Hindi, and Spanish terminology, pluralization, tone, and
   regional usage. Record findings and approval in `localization-review.md`.

10. **Localize catalog entities using stable codes.**
    Exercise identity is now stable, but equipment, muscles, bodyparts,
    stretches, instructions, and built-in plans remain English-backed. Add
    language-neutral codes and localized display metadata with English fallback
    without changing history, media slugs, or user-created content.

11. **Decide the offline-first media experience.**
    Choose whether release builds accept anatomy fallbacks on a first offline
    launch or bundle a small core thumbnail set. Define first-sync messaging,
    data and battery behavior, retry policy, and low-storage behavior.

12. **Expand device, visual-regression, and accessibility coverage.**
    Split the single stateful core integration test into isolated scenarios with
    reusable fixtures. Add stable-screen goldens, navigation migration and
    release-upgrade tests, more failure/offline coverage, and recorded manual
    TalkBack and VoiceOver passes across long locales and large text.

13. **Align CI, tooling checks, and branch protection with feature branches.**
    Remove the stale `local-db` push trigger, protect `master`, and make required
    PR checks explicit. Analyze and test repository tools and the nested catalog
    builder, validate catalog/media fixtures in CI, and pin or regularly review
    third-party Actions and dependency security.

14. **Establish release versioning and store-delivery governance.**
    Replace the static `1.0.1+5` habit with a version/build policy, release tags,
    changelog, approved-commit gate, hashes or provenance, signing-key recovery,
    and staged internal testing. A manually selected ref must not silently
    become an unlabeled production release.

15. **Make optional hardware and platform permissions explicit.**
    Android currently declares camera permission without declaring camera
    hardware optional. Add the appropriate optional feature declaration and
    test installation on no-camera devices. Review permission timing and repeat
    permission, entitlement, and privacy checks for every supported platform.

16. **Create a complete licensing, attribution, and data-provenance inventory.**
    Record licenses and sources for exercise guidance, thumbnails, anatomy art,
    food catalogs, fonts, packages, and generated datasets. Add in-app or
    published notices where required and make CI reject unlicensed media rows.

17. **Decide the local sensitive-data security model.**
    The database is app-private, excluded from Android backup, and exports are
    explicitly plaintext. Before release, document the threat model and decide
    whether device protection is sufficient or whether database encryption,
    encrypted exports, app lock, or additional deletion controls are needed.

18. **Choose and wire the production food-catalog strategy.**
    The app installs four starter foods while larger generated catalogs remain
    unused. Choose authoritative licensed sources, update cadence, barcode and
    locale coverage, offline size, and duplicate policy, then integrate one
    production path with startup, migration, and search-performance tests.

19. **Complete nutrition as a coherent product stream.**
    Finish logging and goal behavior, real dashboard data, custom-food photos
    and files, label/barcode flows, density and portion conversion, recipes,
    favorites, failure states, integrity tests, and all deferred localization.

20. **Restore cardio and stretch as complete vertical features.**
    Implement creation, plans, sessions, completion, repeat, history, analytics,
    records, and Save as plan together. Unify their taxonomy and duration rules
    with strength training and cover migrations, localization, and devices.

21. **Continue exercise and anatomy media.**
    Development covers 154 of 313 exercise thumbnails. Continue reviewed
    batches and establish one licensed, accessible, versioned illustration or
    heatmap direction for equipment, bodypart, and muscle media.

22. **Remove obsolete, fabricated, and unreachable implementations.**
    Delete or rebuild the unreferenced sample-data `DefaultTrendPage`, preserve
    useful assertions before removing the obsolete badge DAO, and reduce
    `active_session.dart` to the durable provider export by deleting its large
    commented legacy implementation.

23. **Continue focused database decomposition alongside related work.**
    `DatabaseHelper` remains over 5,000 lines. Extract backup/import, migration
    repair, food seeding/search, and maintenance only when focused tests can
    establish ownership; keep transactions and upgrades explicit.

24. **Decompose other oversized feature files alongside feature work.**
    Onboarding, exercise detail, preset generation, nutrition DAO/logging,
    analytics, and chart widgets remain 1,400-3,200 lines. Extract cohesive
    controllers, query models, formatters, and sections rather than mechanically
    splitting files.

25. **Create performance, battery, and storage baselines.**
    Measure release startup, database creation/upgrades, catalog seeding, plan
    generation, large lists and reports, image decoding, sync bandwidth, cache
    growth, memory, and battery on low- and mid-range Android devices. Establish
    budgets before larger food, image, or video catalogs ship.

26. **Perform a controlled Flutter and dependency upgrade.**
    Move beyond Flutter 3.29.3, revisit pinned chart/scanner dependencies, and
    run localization generation, analyzer, tests, release builds, and physical
    and hosted device suites. Add recurring dependency and vulnerability review.

27. **Define and enforce the supported-platform matrix.**
    Android is the only verified runtime. Do not advertise web, desktop, or iOS
    until database, file, networking, permission, media, privacy, signing, store,
    and real-device behavior are implemented and tested for that platform.

28. **Remove tracked artifacts and repair repository hygiene.**
    Move four tracked APKs (about 130 MB) to GitHub releases/artifacts, remove or
    regenerate tracked catalog-builder databases, review the 38 MB seed SQL and
    stale root notes, and fix the malformed APK ignore entry. Decide separately
    whether coordinated history cleanup is worth the disruption.

29. **Prune branches after preserving unique work.**
    `updates/backlog` is the active branch and is 12 commits ahead of `master`.
    Archive or delete fully merged maintenance branches, but inspect the unique
    commits on `feature/ui-redesign` and `plugin_ver` before removing them.
    Document branch ownership and the merge/release flow.

30. **Make content status documentation generated or mechanically verified.**
    Production-media documents still contain v9/127/65 figures while the
    development source is v10/154. Generate coverage and promotion scope from
    canonical manifests so roadmap, setup, changelog, and release reports cannot
    silently disagree.

31. **Rehearse release-candidate installation, upgrade, and rollback.**
    Install a signed clean build and upgrade from the last approved build using
    realistic data, active drafts, preferences, media cache, and imports. Verify
    schema migrations, catalog aliases/retirements, data preservation, downgrade
    policy, backup recovery, and store-delivered artifact identity.

32. **Define user support and feedback without remote diagnostics.**
    Provide an intentional support path, version/build and privacy-safe export
    instructions, response ownership, and a way to report sync/import failures
    while the diagnostics relay remains disabled.

33. **Provision the diagnostics relay only when remote diagnostics are needed.**
    When justified, create isolated staging Worker/D1 resources and validate
    consent, schema, receipt deletion, retention, abuse controls, no-egress, and
    no-logging behavior before any production relay URL is configured.

34. **Rename the internal Dart package only as a dedicated migration.**
    Platform identities use Tonos, but package imports still use `env_test`.
    Rename them together only when the churn is worthwhile and verify every
    tool, test, generated source, and platform integration in one change.

35. **Implement the planned durable media library when scale requires it.**
    Keep the verified temporary-cache recovery for current thumbnails. Before
    food images or exercise videos expand materially, follow
    `media-library-architecture-plan.md`: content-addressed no-backup storage,
    disk/index reconciliation, atomic writes, deduplication, adaptive prefetch,
    leases, quotas, bounded retries, and non-jarring image replacement.

## Working Rules

1. Keep Nutrition Log, Combined History, and Form and Posing selectable until
   their implementation plans are approved; do not silently hide them.
2. Keep production media and the diagnostics relay disabled until their listed
   release gates are complete.
3. Every active user-facing feature change must include localization,
   responsive layout, semantics, failure states, and focused regression tests.
4. Update the routing map for navigation changes and all cloud-content
   documentation for every media promotion.
5. Archive superseded planning snapshots instead of leaving competing
   roadmaps, and preserve unrelated local screenshots.

## Recommended Sequence

The strongest near-term sequence is: **resolve release scope -> audit catalog
safety -> retire Train2 -> rework the Exercise Editor -> implement starter
feedback -> validate generated plans**.
