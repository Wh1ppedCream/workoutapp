# Maintenance Backlog

Last updated: 2026-08-12.

This is Tonos's maintained, prioritized engineering backlog. Historical
roadmap snapshots live in `docs/archive/roadmaps/`; do not use them to plan new
work. Cloud-media publishing state and commands live in
`cloud-content-roadmap.md`, `content-production-setup.md`, and
`content-release-playbook.md`.

## Current Status

The latest committed work is `b43ab90` on `origin/updates/backlog`, based on
`f14eee0` from `origin/master`. The cloud-content boundary and active-workout
durability batches both passed their focused coverage; the full suite passes
200 Flutter tests. The diagnostics relay is implemented but disabled.
Development media remains at 127 of 313 exercise thumbnails (40.6%);
production remains at 62 and intentionally waits for a custom domain.

## Recently Completed

1. Hosted automation and release safeguards are verified. The automatic
   [Pages deployment](https://github.com/Wh1ppedCream/workoutapp/actions/runs/31333490317)
   passed, and the manually dispatched
   [Android emulator workflow](https://github.com/Wh1ppedCream/workoutapp/actions/runs/31428848661)
   passed all setup, build, KVM, and device-driven core-flow phases on commit
   `3dfd47a`.
2. The Android device suite now scrolls to lazily built historical record
   badges before asserting them, making its Logbook coverage independent of
   emulator viewport size.
3. The privacy-preserving diagnostics relay design and local implementation
   are complete. Direct Sentry delivery has been removed; the typed relay
   client, receipt-based deletion, no-egress Worker/D1 template, retention
   job, privacy documentation, and regression tests are present. Distributed
   builds remain relay-disabled unless a future release explicitly supplies an
   approved relay URL.
4. Production media readiness is audited. Development manifest version 9 has
   127 assets; production version 5 has 62. All 62 production and 65 pending
   development URLs are reachable, but production has no custom domain and
   needs 65 asset uploads before its canonical manifest can be promoted.
5. Device visual QA is complete for Bangla, Chinese, Hindi, and Spanish across
   onboarding, training, session completion, records, reports, catalog and
   anatomy surfaces, diagnostics, settings, and representative long-copy
   layouts. The pass added localized anatomy labels, locale-aware dates and
   digits, responsive layout fixes, and regression coverage.
6. The cloud-content trust and cache boundary is hardened. Remote manifests and
   media now require HTTPS, enforce content-type and response-size limits,
   restrict redirects, and verify declared byte counts and SHA-256 hashes before
   acceptance. Downloads remain atomic, corrupt and interrupted temporary files
   are removed, stale manifest cache references and orphaned files are pruned,
   and a bounded least-recently-used policy limits cache growth. Environment
   changes trigger an immediate observable synchronization, with focused tests
   covering valid, corrupt, oversized, interrupted, redirected, and downgraded
   responses.
7. Active-workout durability failures are recoverable. Draft restore and save
   operations use bounded retries and show a non-disruptive retry banner when
   protection remains unavailable. Completing a workout atomically records any
   automatic plan progression as a durable pending job, so history remains
   saved even when progression fails; the job retries safely after restart.
   Focused coverage exercises process-death restoration, transient and
   persistent write failures, restore failures, retry UI, progression failure,
   and idempotent transaction behavior.
8. Local-data backup and export privacy is explicit. Android automatic backup
   and device transfer exclude Tonos database and preference data; releases
   disallow cleartext traffic. Exports require an explicit plaintext-data
   warning, and imports have byte, row, field, table, schema, and foreign-key
   validation before their atomic replacement transaction. Encrypted exports
   remain a deliberate future product decision.

## Ranked Backlog

1. **Remove fabricated health data from selectable UI.**
   `CurrentMetricsSection` currently displays invented body-fat, waist, and hip
   values and its add button creates another fake metric. Replace it with real
   repository data or an honest empty state. Remove the unreachable sample-data
   `DefaultTrendPage`, or rebuild it on the real measurement model. No Tonos
   surface should present demonstration values as if they belong to the user.

2. **Retire the alternative Train hub.**
   Compare `Train2Page` with the primary Train experience, preserve any unique
   behavior that is still wanted, migrate saved navigation settings, remove
   `TabItem.train2`, then delete the duplicate route and screen.

3. **Rework the Exercise Editor.**
   Decide the final creator/editor flow, expose starter-load controls where
   they belong, remove legacy and unused form state, validate destructive
   edits, and split the 2,000-line screen into focused, testable sections.

4. **Improve starter-weight calibration.**
   Add first-working-set feedback for too easy, appropriate, and too hard.
   Persist conservative per-exercise adjustments, respect equipment increments
   and safety bounds, explain the next recommendation, and allow calibration
   to be reset or corrected.

5. **Validate generated plans and automatic progression as a product system.**
   Add deterministic scenarios for new users, sparse history, bodyweight work,
   limited gym equipment, incompatible substitutions, deloads, failed sets,
   and repeated sessions. Surface why a plan, load, or progression was chosen
   and prevent silent fallback from producing implausible workouts.

6. **Use one duration model everywhere.**
   Session detail includes seconds, while completion, Logbook totals, and some
   reports collapse sub-minute workouts to `0m`. Centralize formatting and
   aggregation so the same session has the same nonzero duration on completion,
   history, detail, and report surfaces, with locale-aware tests.

7. **Audit the exercise catalog for safety and data quality.**
    Review all 313 definitions for duplicate or inconsistent names, equipment
    compatibility, bodypart and muscle rankings, starter-load metadata, and
    setup/execution/tip accuracy. Add schema and content checks so an invalid
    catalog update cannot silently change exercise identity or recommendations.

8. **Localize catalog entities, not only interface messages.**
    Exercise, equipment, muscle, stretch, instruction, and built-in plan data
    are still English-backed and often use names as lookup identity. Introduce
    stable language-neutral codes, migrate existing rows without breaking user
    history or media slugs, and add localized display metadata with English
    fallback. Store structured measurement qualifiers instead of English notes
    such as `With pump`, `Overall`, and `Onboarding`.

9. **Strengthen localization enforcement and language review.**
    The literal-copy contract catches only a narrow set of widget arguments and
    excludes all nutrition, cardio/stretch, placeholder, and Train2 paths.
    Expand it to cover dialogs, conditional strings, empty states, semantics,
    and deferred surfaces as they become active. Remove remaining English
    fallbacks and raw exception text, then complete native-speaker linguistic,
    pluralization, terminology, and tone review for every locale.

10. **Strengthen body-measurement validation and lifecycle.**
    Enforce positive and plausible values, feet/inches ranges, unit conversion,
    duplicate-definition rules, and safe custom units. Complete edit/delete and
    correction flows, ensure trends refresh consistently, and add repository,
    widget, and device tests for create, edit, delete, and invalid input.

11. **Decide the offline-media experience.**
    Either accept fallback visuals on an offline first launch or bundle a small,
    useful core media collection. Test first install, airplane mode, partial
    cache, cache clearing, and returning online.

12. **Continue exercise and anatomy media.**
    Development covers 127 of 313 exercise thumbnails (40.6%). Continue
    reviewed thumbnail batches, finish equipment coverage, and establish one
    bodypart and muscle illustration or heatmap system with documented source,
    license, cropping, accessibility, and versioning rules.

13. **Finish production media when a custom domain is ready.**
    Keep development as the default until then. After connecting the domain,
    visually validate batches 004 through 007, upload the 65 missing assets,
    publish the 127-asset canonical manifest, perform clean-install and offline
    recovery tests against a release build, then switch the default deliberately.

14. **Expand device, visual-regression, and accessibility coverage.**
    Keep the strength core flow, then add focused device scenarios for media
    first sync/offline recovery, measurements, onboarding branches, backup
    failures and rollback, locale switching, and navigation migrations. Add a
    small golden matrix for phone/tablet, portrait/landscape, light/dark, long
    locales, and large text, plus manual TalkBack/VoiceOver release checks.

15. **Align CI and branch protection with feature-branch development.**
    Remove the stale `local-db` push trigger, ensure pull requests to `master`
    require localization cleanliness, analyzer, tests, and release compilation,
    and protect `master` from accidental direct or force pushes. Decide whether
    active feature branches should receive push CI before a pull request.

16. **Establish release versioning and store-delivery governance.**
    Replace the static `1.0.1+5` release habit with a documented version/build
    policy, approved-commit gate, release tag and changelog, artifact hashes or
    provenance, signing-key recovery procedure, and staged Play internal-test
    rollout. A manually selected workflow ref must not accidentally become an
    unlabeled production release.

17. **Review visible incomplete navigation and plan complete implementations.**
    Keep Nutrition Log, Combined History, and Form and Posing selectable as
    requested. Replace generic placeholder copy with intentional status/design
    surfaces, then define each tab's user journey, data model, privacy needs,
    dependencies, migration plan, and acceptance criteria before implementation.
    Decide whether Nutrition Log should route into the existing nutrition flow
    rather than remain a second disconnected entry point.

18. **Choose and wire the production food-catalog strategy.**
    The active seed intentionally installs only four starter foods, while a
    1.2 MB compressed catalog and a `FoodCatalogRepository` boundary exist but
    are not selected or bundled. Decide the authoritative sources, licenses,
    update cadence, barcode coverage, offline footprint, duplicate resolution,
    and localization policy. Then either integrate the compressed catalog with
    startup/performance tests or remove the misleading unused asset path.

19. **Complete nutrition as a coherent product stream.**
    Replace remaining prototypes and hardcoded copy, finish daily logging and
    goal behavior, and connect dashboard metrics to real data. Complete custom
    food photo/file handling, nutrition-label and barcode workflows, density
    and portion conversion, recipes and favorites, error states, and nutrition
    data-integrity tests before treating the tab as complete.

20. **Restore cardio and stretch as a complete vertical feature.**
    Reintroduce creation, plans, active sessions, completion, repeat, history,
    analytics, records, and Save as plan together. Restore the intentionally
    removed data paths only after their models, duration semantics, UI states,
    migrations, localization, and device tests are designed end to end.

21. **Remove obsolete badge and active-session implementations.**
    Move any still-useful assertions from `session_record_badges_dao_test.dart`
    to the current record-event path, delete the obsolete DAO and model surface,
    and reduce `active_session.dart` to the durable-provider export after the
    commented implementation has remained unnecessary through a release.

22. **Continue focused database decomposition alongside related work.**
    `DatabaseHelper` remains a 5,000-plus-line compatibility facade. Extract
    backup/import, migration repair, food seeding/search, and maintenance
    responsibilities only when the related feature changes and focused tests
    can establish ownership. Keep transactions and upgrade behavior explicit;
    avoid a broad mechanical split.

23. **Decompose non-database hotspots alongside feature work.**
    Onboarding, exercise detail, preset generation, workout charts, nutrition
    logging/customization, and several analytics widgets are each roughly
    1,500-3,200 lines. Extract cohesive controllers, query models, formatters,
    and sections when changing them so business rules can be tested without
    rendering an entire screen.

24. **Standardize safe error handling and recovery UI.**
    Audit broad `catch (_)` blocks and direct `error.toString()` messages.
    Distinguish expected optional-media fallback from database corruption or
    failed writes, provide retryable user states, retain privacy-safe local
    diagnostic categories, and never expose raw SQL, paths, or implementation
    details as localized user copy.

25. **Create performance and resource baselines.**
    Measure release startup, database creation and upgrades, catalog seeding,
    plan generation, large Logbook/report scrolling, image decoding, cache
    growth, and memory on representative low- and mid-range Android devices.
    Add budgets and repeatable profiling instructions before larger catalogs or
    bundled media materially increase install and startup cost.

26. **Perform a controlled Flutter and dependency upgrade.**
    Move beyond Flutter 3.29.3 to pick up the upstream Android pointer-ID fix,
    then revisit pinned `fl_chart` and `mobile_scanner` versions. Regenerate
    localization, run analyzer and all tests, build release artifacts, and run
    the Pixel 7 and hosted device suites. Add a recurring dependency/security
    review without automatically merging major upgrades.

27. **Define the supported-platform matrix.**
    Android is the verified runtime; other Flutter platform shells now have
    Tonos branding but not equivalent storage, file-picker, networking,
    entitlement, build, or device coverage. Document which platforms are
    supported today. Before releasing another platform, validate its database
    implementation, import/export behavior, permissions/entitlements, media
    sync, privacy behavior, and CI artifact.

28. **Remove tracked build artifacts and repair repository hygiene.**
    Four APKs totaling roughly 136 MB are committed, old source snapshots remain
    under `NOTES/`, and `.gitignore` contains a malformed APK entry. Move release
    binaries to GitHub artifacts/releases, archive only uniquely useful notes,
    fix ignore rules, and decide separately whether the roughly 240 MB packed
    Git history warrants a coordinated history cleanup.

29. **Prune merged branches and document branch ownership.**
    The local tips for `local-db`, `dependency/maintenance`,
    `hybrid-food-catalog`, `feature/ui-redesign`, `plugin_ver`, and the backup
    branch are ancestors of `master`. Confirm remote tips and preservation
    needs, then delete or archive merged branches so `master` and active feature
    branches communicate current work clearly.

30. **Provision the diagnostics relay only when remote diagnostics become a
    release need.** The approved no-egress Worker and D1 design is intentionally
    disabled. When needed, create isolated staging resources, validate schema,
    consent, receipt deletion, retention, abuse controls, no-egress, and
    no-logging behavior with synthetic events, then complete release-candidate
    gates before configuring any production relay URL.

31. **Rename the internal Dart package only as a dedicated migration.**
    Platform identities already use Tonos and `com.tonos`, but the package is
    still `env_test` and is referenced by more than 100 package imports. Rename
    it only when the churn is worthwhile, update all imports and tooling in one
    change, and rely on analyzer and the complete test matrix to catch misses.

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

The strongest near-term sequence is: **remove fabricated health data -> harden
backup and export privacy -> retire Train2 -> rework the Exercise Editor ->
implement starter feedback**.
