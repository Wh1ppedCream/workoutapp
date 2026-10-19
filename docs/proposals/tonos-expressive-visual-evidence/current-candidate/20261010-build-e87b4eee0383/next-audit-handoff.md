# Next visual-readiness audit handoff

## Authoritative evidence source

Use only `docs/proposals/tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/manifest.csv` rows whose verification is `VERIFIED` and whose build fingerprint equals `e87b4eee03832c8036a89ad6ce1337d3ec8c68c8adb2348ac8d42e7aeb950073`. The package README, coverage report, route crosswalk, cleanup manifest, and source-file hashes are part of the same evidence package.

At this checkpoint, `manifest.csv` contains **92 verified current-build screenshots** (47 Expressive light and 45 Expressive dark), one excluded Android-lockscreen probe, and one excluded redundant Diagnostics & Privacy checkpoint. Since the original 65-capture checkpoint, 27 verified images were added: 8 Catalog, 6 Weekly Sets / Analytics Dashboard, 1 Dashboard 2× stress reference, and 12 Logbook/Progress captures. The preview was installed on Pixel 7 `28021FDH200228`. Current-build paired references cover Catalog, Profile/Analytics, Train → Plans and planning routes, Logbook root/Full History/read-only Session Detail, Progress root, and the Weekly Sets destination. The planning captures remain default/read-only; route-state coverage is still partial. Use `coverage.md` and the crosswalk to continue without implying qualification.

## Build and data provenance

The source was the dirty working tree at HEAD `ab18ed8cab5582c8449e13724afae3c4b74ebeea`, branch `feature/classic-m3e`, Flutter 3.47.5 / Dart 3.13.4. The isolated package is `com.tonos.expressivepreview`, using `tonos_expressive_preview.db`. A no-fixture development entrypoint was used because the standard preview entrypoint resets/seeds fixture-tracked database rows. The database, WAL/SHM, Flutter preferences, and MLKit preferences were restored after capture and device hashes matched snapshot `C:/Users/talh7/AppData/Local/Temp/tonos-expressive-capture-backup-20261010T125718Z`: DB `36d3898d86661262e543865068ee9e727d7a8adbe76c23b02aff0a502f81384c`; WAL `c5b7d859406b807ad84a0793c0295a61b2257819f6ee8ee94ac668df54b94c0e`; SHM `32fb8898a7a4f95cd09d8e4f2c4e56218bd2b36f32702f503676ec9b5c5f7a8a`; Flutter preferences `15b968b0a17bb72d0b3990da7e8c597ad088132f9fb54e6fb1cf50af68a343ff`; MLKit preferences `db7d9c816deef2a8b9055671ec72b6ea7afcd106560fe2cb38cd467b58187a02`. The preview is stopped. Never use the production package or database.

## Old collections

All 1,302 pre-existing proposal images/videos are enumerated in `stale-evidence-cleanup.csv`; they remain in place and are not current evidence for this fingerprint. Entries with documented earlier builds are `HISTORICAL`; entries without exact source/build provenance are `UNVERIFIED`. Exact byte duplicates are identified by SHA-256 only; they were not deleted. Known wrong-mode, wrong-route, Android-system, diagnostic, and misleadingly named images remain preserved but must not be cited as successful route evidence.

Use old approved-screen images only as historical design context. User approvals remain valid independently of whether fresh reference screenshots were captured.

## Capture queue and exclusions

Follow `coverage.md` for current route/state gaps and safe navigation. Never create/delete/update persisted workouts, plans, rankings, rules, measurements, profiles, preferences, or cloud media to manufacture screenshot content. Destructive or persistence dialogs were not opened. Deferred Nutrition and placeholder routes were not enabled. Captures added here show selected empty/populated Logbook dates, Full History, read-only Session Detail, and top/scrolled Progress root; no workouts, plans, measurements, profiles, or other records were edited. Catalog interaction captures are documented per route in `route-crosswalk.csv`. The source-file hash inventory was rechecked: 369 of 370 listed inputs still match; the sole missing input is the intentionally removed temporary capture entrypoint. No other listed input changed.

The newly added screenshots show a thin lime-green perimeter. Its origin remains unconfirmed; screenshots were not altered, and route/state identity was corroborated by the UI hierarchy dumps. In-app preview controls were explicitly set to Expressive in each theme; this preview override determines the rendered theme even though the saved ThemeProvider preference remains Neo.

## Readiness and remaining gaps

This evidence refresh is sufficiently current and broad to begin the next visual-readiness audit. It is not a claim that all 55 archetypes or every route state are covered, approved, or technically qualified. Important remaining evidence gaps include Catalog media fallback and dark lower/detail states; planning validation, keyboard, persistence, and dialog flows; Profile child-page edit/error/dialog states; Logbook M / 3M / Y / 4Y variants and historical edit/dialog states; Exercise Progress 1RM and Measurement Trend detail routes; and 320 dp, wide/tablet, landscape, and systematic text-scale coverage. The one Dashboard 2× dark stress reference visibly records crowding/clipping and is a gap, not a pass. The six Weekly Sets captures are the `AnalyticsDashboardScreen` destination opened from Dashboard or Train → Weekly Overview → Focused Sets, not captures of the Dashboard page/card.

The 55-archetype ledger reports A20/B19/C10/D1/E0/F5/G0, while its visible route tables and state boundaries do not reconcile to those totals. `route-crosswalk.csv` preserves each listed route and identifies the missing/misclassified row boundaries. Keep that discrepancy visible for the next audit; do not recategorize approvals based on screenshot availability.

## Do not infer

- A screenshot timestamp or folder date does not prove it matches source.
- The installed APK’s successful build/install does not mean a route has been captured.
- A page approval does not imply responsive, accessibility, automated-test, or release qualification.
- A missing screenshot does not reverse a user’s existing visual approval.
- The 411×914 dp Pixel view does not qualify 320 dp, tablet, landscape, or large text.

No source, tests, approval statuses, or Git state should be changed as part of consuming this evidence package. The temporary capture entrypoint should be removed only with a targeted patch after capture, with its build hash retained in provenance.
