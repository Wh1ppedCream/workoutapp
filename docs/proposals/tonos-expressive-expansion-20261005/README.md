# Tonos Expressive expansion — current-source review

This folder tracks the current uncommitted Expressive expansion candidate on `feature/classic-m3e`. It is a review package, not an approval or release record. The approved Train, Active Workout, and navigation shell remain the reference boundary.

## Current-source checkpoint

- Branch: `feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea` (`Add Expressive planning route previews`)
- Candidate state: dirty working tree; the new source and tests have not been committed.
- Final closure validation: 180 focused tests passed across 32 targets, with 0 failures. Scoped analysis reported 0 errors, 2 warnings, and 12 deprecation infos. Check-only formatting made no writes; `git diff --check` passed. The earlier 162-test result is historical and superseded in [current-source-snapshot.md](current-source-snapshot.md).
- Device evidence: final current-source profile preview build and Pixel 7 captures are recorded in [device-review/final-current-source-20261005-125052/](device-review/final-current-source-20261005-125052/). They use the isolated preview package/database and represent the dirty candidate source, not a committed build.

## Current pass coverage

The current candidate adds or strengthens Expressive route treatment for:

- Dashboard and Analytics Dashboard;
- the Nutrition family (nutrition home, food logging/customization, barcode scanner, diary, goals, and nutrition settings);
- onboarding;
- Auto Preset Flow and Preset Generation QA.

Focused follow-ups address Dashboard large-text/compact layouts, Nutrition diary collisions at large text, compact portion controls, and barcode reticle contrast. Classic and Neo behavior is guarded by route/theme tests in the changed families. These are source/test claims; they do not substitute for device review.

## Review files

- [Route and component ledger](route-component-ledger.md): current reachability inventory, dispositions, and this pass's status update.
- [Current-source snapshot](current-source-snapshot.md): branch, validation evidence, changes, and known boundaries.
- `device-review/`: reserved for fresh Pixel 7 captures and their capture notes. Do not treat older proposal screenshots elsewhere in `docs/proposals/` as evidence for this dirty source.

## Still deferred or intentionally uncovered

- Flow Methods, Workout Progress Flows, and shared workout/health dialogs have not received a route-specific visual redesign in this pass.
- Several Profile child routes and existing Catalog, Progress, Logbook, planning, and Analytics Settings candidates still need current-source route/device review; the ledger identifies their individual gaps.
- Nutrition Log, Combined History, Form and Posing, Pantry Log, and Plan Meal remain placeholders or release-denied surfaces. Their visual treatment was not expanded into invented product workflows.
- Train2 remains frozen. Shared component behavior outside an explicitly scoped Expressive caller remains caller-sensitive.

No commit, push, or full repository suite is represented by this review package.

## Closure addendum — 2026-10-05

The final narrow fixes addressed the Flow canvas left inset, the clipped `Rank` field label on Muscle Ranking, Expressive destination-token scoping in Food Customization helpers, and the Exercise Editor's destination-specific hierarchy. The Nutrition correction also fixed the repro test to expand its intentionally collapsed “Usual portion” section before asserting both rows; the app's default expansion state remains unchanged. Classic/Neo behavior and product data/workflows were preserved.

The final-source Pixel review captured Auto Preset Flow, Body Part Ranking, Muscle Ranking, Exercise Editor, and Food Customization in light and dark. Exact routes, states, build identity, device, and times are in the capture notes. This is candidate evidence for user review, not approval or release qualification.

### Remaining Expressive backlog

- Auto Preset Flow still uses its existing chart grid and blue connector handles; the app-default subtitle is ellipsized after “new…” at the captured device size.
- Food Customization's fixed Cancel/Save actions obscure part of the lower portion row in the initial viewport, and the narrow Amount field label displays as “Amo…”. These were recorded after the closure boundary and were not changed.
- Responsive and large-text device captures for the broad route set are not complete. Widget tests cover selected compact/ranking cases; the route ledger retains the other route/state gaps.
- Flow Methods, Workout Progress Flows, shared dialogs, and several existing Catalog, Progress, Logbook, Profile, and planning states remain route-specific visual-review work. Placeholder/release-denied routes remain intentionally incomplete.

The full repository suite, inventory/ratchet re-enforcement, commit, and push remain deferred. The current candidate is ready only for targeted visual review of its captured states.
