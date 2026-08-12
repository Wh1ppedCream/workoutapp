# Maintenance Backlog

Last updated: 2026-08-11.

This is Tonos's maintained, prioritized engineering backlog. Historical
roadmap snapshots live in `docs/archive/roadmaps/`; do not use them to plan new
work. Cloud-media publishing state and commands live in
`cloud-content-roadmap.md`, `content-production-setup.md`, and
`content-release-playbook.md`.

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
   digits, responsive layout fixes, and regression coverage. Analyzer and all
   182 Flutter tests passed after the final Spanish review.

## Active Priorities

1. **Retire the alternative Train hub.** Migrate any remaining unique behavior
   from `Train2Page`, migrate saved navigation settings, remove `TabItem.train2`,
   then delete the duplicate route and UI.
2. **Rework the Exercise Editor.** Decide the final creator/editor flow,
   expose starter-load controls where they belong, remove legacy form state,
   and split the screen into focused sections.
3. **Improve starter-weight calibration.** Add a first-set feedback loop for
   too easy, appropriate, and too hard recommendations, with conservative
   persisted adjustments and clear user-facing explanations.

## Product And Content Work

1. **Decide the offline media experience.** Either accept fallback visuals on
   an offline first launch or bundle a small, useful core media collection.
2. **Continue exercise and anatomy media.** The current development canonical
   source covers 127 of 313 exercises (40.6%). Continue thumbnail batches, then
   establish the bodypart and muscle illustration or heatmap direction.
3. **Finish production media when a custom domain is ready.** Keep development
   as the default until then. After connecting the domain, visually validate
   batches 004 through 007, upload the 65 missing assets, publish the
   127-asset canonical manifest, perform a clean-install sync, and switch the
   default deliberately.
4. **Restore cardio and stretch as a complete vertical feature.** Reintroduce
   creation, plans, sessions, completion, repeat, history, and Save as plan
   together rather than as isolated screens.
5. **Complete nutrition as its own product stream.** Replace fake-data and
   placeholder surfaces before adding the intended media and logging workflows.
6. **Review visible incomplete navigation and plan implementation.** Keep
   Nutrition Log, Combined History, and Form and Posing selectable for now;
   define each tab's complete user flow, data prerequisites, scope, and
   acceptance criteria before prioritizing implementation.

## Reliability And Cleanup

1. Preserve useful record assertions, then remove the old
   `session_record_badges_dao.dart` implementation.
2. Reduce `lib/providers/active_session.dart` to the durable-provider export
   after the commented legacy implementation has remained unnecessary through a
   release.
3. Extract backup, import, or maintenance responsibilities from
   `DatabaseHelper` only when the related feature changes and focused tests can
   establish ownership.
4. **Provision the diagnostics relay only when remote diagnostics become a
   release need.** The approved [no-egress Worker and D1 design](privacy-diagnostics-relay-design.md)
   is intentionally disabled. When it is needed, create isolated staging
   resources, validate schema, receipt deletion, retention, no-egress, and
   no-logging behavior with a synthetic event, then complete the
   release-candidate gates before configuring any production relay URL.
5. Run a responsive and screen-reader regression pass whenever core layout,
   localization, navigation, or diagnostics UI changes.
6. **Perform a controlled Flutter SDK upgrade.** Move beyond Flutter 3.29.3 to
   pick up the upstream Android pointer-ID fix, then rerun localization
   generation, analyzer, the full test suite, release builds, and the Pixel 7
   device suite. The current `MouseTracker` assertion is debug-only and does
   not block app feature work or release builds.
7. Keep any internal Dart package rename (`env_test`) as a dedicated all-import
   migration; platform release identities already use `Tonos` and `com.tonos`.

## Documentation Rules

1. Update this backlog when priorities materially change.
2. Update the routing map with navigation changes.
3. Update the content roadmap, production setup guide, playbook, and changelog
   for every media promotion.
4. Archive superseded planning snapshots instead of leaving competing root-level
   roadmaps.

## Deferred Areas

Nutrition, cardio/stretch, and unfinished alternate bottom-tab work remain
intentionally deferred unless a task above explicitly brings one back into
scope.
