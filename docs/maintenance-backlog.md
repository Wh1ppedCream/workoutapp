# Maintenance Backlog

This is the current prioritized engineering backlog. It replaces the stale
"unfinished areas" list that was previously embedded in the routing map.

## Active Priorities

1. **Consolidate the alternative Train hub.** Migrate any remaining unique
   behavior from `Train2Page`, remove it from navigation configuration, then
   delete its route and duplicate UI.
2. **Revisit the Exercise Editor workflow.** Decide the final creator/editor
   experience and simplify the deferred staged UI around that decision.
3. **Choose the production media environment.** Decide whether the temporary
   R2 URL is acceptable for releases or connect a permanent domain, then make
   production the default only after a fresh-install sync check.
4. **Continue exercise media coverage.** Publish verified thumbnail batches and
   retain the heatmap fallback for uncovered exercises.
5. **Finish shared media direction.** Complete equipment coverage, then define
   a consistent illustration and/or heatmap approach for body parts and
   muscles.
6. **Improve starter-weight calibration.** Add a first-set feedback loop so
   generated workout recommendations can learn whether a suggested load was
   too easy, appropriate, or too hard.

## Reliability And Cleanup

1. Remove `session_record_badges_dao.dart` after retaining any useful test
   cases under the persisted workout-record-event system.
2. Remove the commented legacy provider implementation in
   `lib/providers/active_session.dart` after the durable-session migration has
   remained stable through another release.
3. Keep database coordination small: extract lifecycle, migration, and
   maintenance responsibilities from `DatabaseHelper` only when they have a
   clear owner and focused test coverage.
4. Run a responsive and screen-reader regression pass whenever a core layout,
   localization, or navigation component changes. The current baseline covers
   French and enlarged text on onboarding, Train, sessions, completion,
   reports, tutorials, and settings.

## Platform Maintenance

1. Upgrade Flutter and dependencies in a dedicated branch. Validate unit,
   widget, Android integration, and release-bundle builds before merging.
2. Keep localization generation in CI or release verification after changing
   ARB files.
3. Keep the routing map, this backlog, and the cloud publishing playbook up to
   date as part of relevant feature changes.

## Deferred Areas

Nutrition, cardio/stretch, and unfinished alternate bottom-tab work remain
intentionally deferred until their product direction is revisited.
