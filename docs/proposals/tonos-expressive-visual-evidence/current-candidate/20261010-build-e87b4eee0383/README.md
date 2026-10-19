# Tonos Expressive current-candidate evidence — 2026-10-10

## Authority and status

This dated folder is the only current-build evidence pool for the candidate described below. A screenshot is current only when `manifest.csv` records the exact candidate fingerprint and its verification status is `VERIFIED`. **92 valid in-app screenshots are recorded.** The first attempted capture is an Android lockscreen probe and is excluded; one redundant Diagnostics & Privacy checkpoint screenshot is also explicitly excluded from canonical coverage. The evidence refresh now has current references across Train/planning, Catalog, Profile/Analytics, Logbook, Progress, and Dashboard, but route-state and responsive qualification remain incomplete. After capture, the isolated preview database and preferences were restored and verified against the saved snapshot; the app is stopped.

Older proposal screenshots are preserved in their original locations and inventoried in `stale-evidence-cleanup.csv`. They are historical or unverified relative to this candidate and must not be used as current visual evidence. No old evidence was moved or deleted.

## Candidate provenance

- Repository: `E:/projects/env_test`
- Branch / upstream: `feature/classic-m3e` / `origin/feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Working tree: heavily modified before this task; 412 short-status entries at baseline, with no staged files. A temporary dev-only capture entrypoint and this evidence directory were added afterward. No production source, tests, approvals, or user files were changed for capture setup.
- Flutter / Dart: 3.47.5 / 3.13.4
- Build target: `lib/dev/expressive_visual_capture_main.dart` (temporary dev-only entrypoint; its hash is recorded in `build-provenance.json`)
- Source/build-input fingerprint: `e87b4eee03832c8036a89ad6ce1337d3ec8c68c8adb2348ac8d42e7aeb950073` (370 hashed inputs; see `source-files-sha256.csv`)
- Post-capture source-input check: 369 of 370 listed files still match; the only absent file is the intentionally removed temporary capture entrypoint. No other listed build input changed.
- Production-tree fingerprint excluding the capture entrypoint: `9c4dae8f328fc3dee0fc411028b4e051da6a3fc7a5200f745460b2a09a708cf4`
- APK: debug, SHA-256 `54c07578ccf8d6f8d9c32314878128d4a0ccc1e4a0aeb49c547f1466d62cdd47`; package `com.tonos.expressivepreview`; version 1.0.1 / code 6
- Isolated database name: `tonos_expressive_preview.db`
- Device: Pixel 7 `28021FDH200228`, 1080×2400 physical px at 420 dpi (approximately 411×914 logical dp)
- Build completed and `adb install -r` succeeded. The user-data-preserving install did not clear app data.
- Before first launch, the preview database files and app preference files were pulled to the host-local snapshot `C:/Users/talh7/AppData/Local/Temp/tonos-expressive-capture-backup-20261010T125718Z`. After capture, the DB, WAL, SHM, Flutter preferences, and MLKit preferences were restored and their device hashes matched the snapshot exactly: DB `36d3898d86661262e543865068ee9e727d7a8adbe76c23b02aff0a502f81384c`, WAL `c5b7d859406b807ad84a0793c0295a61b2257819f6ee8ee94ac668df54b94c0e`, SHM `32fb8898a7a4f95cd09d8e4f2c4e56218bd2b36f32702f503676ec9b5c5f7a8a`, Flutter preferences `15b968b0a17bb72d0b3990da7e8c597ad088132f9fb54e6fb1cf50af68a343ff`, and MLKit preferences `db7d9c816deef2a8b9055671ec72b6ea7afcd106560fe2cb38cd467b58187a02`. The snapshot path is temporary and host-local, not a durable package dependency.
- Tests, analyzer, and full suite were not run for this evidence-only task.

## Current capture set

`manifest.csv` contains 92 `VERIFIED` app captures (47 Expressive light, 45 Expressive dark), one `FAILED_EXCLUDED` Android-lockscreen probe, and one `EXCLUDED_REDUNDANT_PROBE` Diagnostics & Privacy checkpoint. The original 65-capture checkpoint gained 15 verified captures in the preceding continuation (8 Catalog, 6 Weekly Sets / Analytics Dashboard states, and 1 Dashboard large-text stress reference), then 12 verified Logbook/Progress captures in this continuation. Each new screenshot has a SHA-256 entry and a matching parseable UI hierarchy dump; every manifest screenshot path and hierarchy reference was checked. Fresh light/dark references now include Train → Plans, Plan Management, Premade Plans, Preset Detail, Optimized Workout Settings, Gym Profile, Logbook root empty/populated selected days, Full History, read-only Session Detail, and top/scrolled Progress root states. Planning captures remain default/read-only; interaction, persistence, dialog, keyboard, and other meaningful states remain incomplete. Catalog now has light scrolled/root, browser search/filter/no-results/scrolled, and exercise detail Metrics/Records/Form Guide states; paired dark search/filter and Metrics/Records evidence is present, but media fallback, dark lower-page/detail states, and complete caller parity remain open. The user-configured Dashboard page/card and its separate Weekly Sets / Analytics Dashboard destination are both captured; the destination screenshots do not stand in for the Dashboard page/card itself.

The in-app preview controls were explicitly set to Expressive for each light/dark capture. The preview presentation overrides the saved `ThemeProvider` family for rendered evidence; the saved preference remains Neo and was preserved. Theme evidence is based on the active preview controls and captured output, not on that stored preference.

**Capture caveat:** the newly captured images show a thin lime-green line around the screenshot perimeter. Its source was not identified; captures were not edited or cropped, and route/theme verification uses the matching UI hierarchy dumps. Do not interpret that perimeter as an application surface or styling change.

If capture resumes, use this installed isolated APK only. Verify route and theme from the preview controls and screenshot/UI hierarchy before marking a manifest row `VERIFIED`. Do not seed/reset fixtures or alter saved workout, plan, profile, or measurement data to manufacture content. The isolated preview remains stopped after restoring the saved pre-capture snapshot.

## Inventory and count boundaries

- Existing proposal collections examined: 1,302 image/video files (1259 PNG and 43 MP4), 444,011,507 bytes, across 73 prior leaf folders. The path-level cleanup manifest classifies 1,162 as historical and 140 as unverified relative to this build. It also identifies 36 exact-byte duplicate groups (82 members, 46 excess copies), including empty files; these are retained and were not deleted. Of the 1,302 assets, 243 are linked from proposal Markdown and explicitly flagged as protected references. All 1,302 are excluded from this new candidate index.
- Separate protected collections were left untouched: 4 Flutter golden images under `test/goldens/` and 16 ordinary visual/media assets under `assets/`; neither collection is part of the proposal-evidence count or stale cleanup manifest.
- The expansion ledger reports 55 archetypes with `A20/B19/C10/D1/E0/F5/G0`. The visible section tables do not reconcile to those totals: the A table includes shell/child-state rows, B lists a sheet, C lists only one page plus grouped shared dialogs while claiming C10, and D lists three routes while claiming D1. The crosswalk preserves the ledger rows and flags the boundary mismatch; it does not silently rewrite approvals or totals.
- `route-crosswalk.csv` contains 59 literal ledger table rows across A–H, including grouped shared components, state boundaries, and protection notes; it is not a claim of 59 page archetypes. The reported 55-page count and approval totals are preserved as documented, with the visible-row mismatch called out for the next audit to reconcile.
- The separate 24-route dossier currently reports 15 approved / 9 pending. This evidence task does not change approval status.
- Dialogs, sheets, popups, and expanded states are recorded as route states unless the authoritative ledger explicitly counts them as an archetype.

## Files

- `manifest.csv` — screenshot-to-route/theme/state/provenance records, including failed captures.
- `coverage.md` — current capture coverage and missing states.
- `route-crosswalk.csv` — route/owner and archetype-boundary crosswalk from the current expansion ledger.
- `stale-evidence-cleanup.csv` — path-level classification of every pre-existing proposal image/video; all retained in place.
- `build-provenance.json` and `source-files-sha256.csv` — reproducible build-source record.
- `next-audit-handoff.md` — instructions for consuming this evidence set without promoting old captures.

## Integrity rule

If any hashed build input changes after this APK was built, stop capture. Keep completed screenshots but mark any potentially affected rows `STALE_CANDIDATE`, rebuild, and recapture the affected routes under a new fingerprinted folder. Do not use `HEAD` or file timestamps alone as proof that a screenshot matches source.
