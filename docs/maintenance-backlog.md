# Maintenance Backlog

Last updated: 2026-08-09.

This is Tonos's maintained, prioritized engineering backlog. Historical
roadmap snapshots live in `docs/archive/roadmaps/`; do not use them to plan new
work. Cloud-media publishing state and commands live in
`cloud-content-roadmap.md`, `content-production-setup.md`, and
`content-release-playbook.md`.

## Active Priorities

1. **Confirm hosted automation and release safeguards.** Check the latest CI
   run, manually run the scheduled Android emulator workflow, publish the
   privacy pages, and run the protected production-release workflow.
2. **Design a privacy-preserving diagnostics relay.** Direct device-to-Sentry
   reporting is disabled in production after validation showed service-derived
   geography could still appear. Define the relay, its retention, consent,
   deletion, and event-allowlist contract before re-enabling remote reporting.
3. **Hide unimplemented navigation.** Remove Nutrition Log, Combined History,
   and Form and Posing from selectable navigation until their flows are usable.
4. **Finalize the production media environment.** Validate development batches
   004 through 007, promote the current canonical manifest and assets, choose
   the permanent content host, perform a clean-install sync test, then switch
   the app default deliberately.
5. **Run visual locale QA.** Test Bangla, Chinese, Hindi, and Spanish on a
   device across onboarding, Train, plans, sessions, records, reports,
   tutorials, diagnostics, settings, and enlarged text.
6. **Retire the alternative Train hub.** Migrate any remaining unique behavior
   from `Train2Page`, migrate saved navigation settings, remove `TabItem.train2`,
   then delete the duplicate route and UI.
7. **Rework the Exercise Editor.** Decide the final creator/editor flow,
   expose starter-load controls where they belong, remove legacy form state,
   and split the screen into focused sections.
8. **Improve starter-weight calibration.** Add a first-set feedback loop for
   too easy, appropriate, and too hard recommendations, with conservative
   persisted adjustments and clear user-facing explanations.

## Product And Content Work

1. **Decide the offline media experience.** Either accept fallback visuals on
   an offline first launch or bundle a small, useful core media collection.
2. **Continue exercise and anatomy media.** The current development canonical
   source covers 127 of 313 exercises (40.6%). Continue thumbnail batches, then
   establish the bodypart and muscle illustration or heatmap direction.
3. **Restore cardio and stretch as a complete vertical feature.** Reintroduce
   creation, plans, sessions, completion, repeat, history, and Save as plan
   together rather than as isolated screens.
4. **Complete nutrition as its own product stream.** Replace fake-data and
   placeholder surfaces before adding the intended media and logging workflows.

## Reliability And Cleanup

1. Preserve useful record assertions, then remove the old
   `session_record_badges_dao.dart` implementation.
2. Reduce `lib/providers/active_session.dart` to the durable-provider export
   after the commented legacy implementation has remained unnecessary through a
   release.
3. Extract backup, import, or maintenance responsibilities from
   `DatabaseHelper` only when the related feature changes and focused tests can
   establish ownership.
4. Run a responsive and screen-reader regression pass whenever core layout,
   localization, navigation, or diagnostics UI changes.
5. Keep any internal Dart package rename (`env_test`) as a dedicated all-import
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
