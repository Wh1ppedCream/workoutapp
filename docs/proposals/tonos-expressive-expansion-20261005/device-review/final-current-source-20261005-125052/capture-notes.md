# Final current-source device captures

## Build and source identity

- Repository: `E:\projects\env_test`
- Branch: `feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Working tree was dirty before the final build: 351 entries (101 modified, 250 untracked). Pre-build status SHA-256: `9FF796F1CE6723005A45AD8FDE78D9BE3447C58B191976FA6098164216E613EE`; tracked diff SHA-256: `8DFB7BBFC61D57BE696E0920AD6222E9D0EF535D23EDCC42F8C9A1D9ED9113D0`.
- Flutter: 3.47.5 (`E:\tools\flutter_sdks\3.47.5\flutter`); bundled Dart: 3.13.4.
- Build: `tools/run_expressive_preview.ps1 -BuildMode profile`; `--no-pub`; profile APK manifest package `com.tonos.expressivepreview`, versionCode 6, versionName 1.0.1. Defines validated by the runner: `TONOS_EXPRESSIVE_PREVIEW=true`, `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`, `TONOS_ANDROID_INTERNAL_BUILD=false`, `TONOS_DATABASE_NAME=tonos_expressive_preview.db` (plus preview controls enabled by the runner).

## Device and data boundary

- Device runtime identity: Pixel 7, serial `28021FDH200228`.
- Installed package: `com.tonos.expressivepreview`; Package Manager reports data directory `/data/user/0/com.tonos.expressivepreview` (work profile path also listed by Android).
- Database: `tonos_expressive_preview.db` in the preview package.
- The `com.tonos` and `com.tonos.internal` installed APK paths matched their pre-install paths. Neither package was launched or opened. No app data was cleared.
- Expressive, Curated, and Light/Dark were set through preview controls only. No global display size or density was changed, no fixtures were altered, and no flow/editor edits were saved.
- C: free space was 2.54 GiB after the profile build/install and eight route captures, 1.42 GiB after the two Food Customization captures, and 0.92 GiB at final review closure. The 1.5 GiB stop threshold is now crossed; no further builds/device actions or cleanup were performed.

## Requested route captures

All PNGs are fresh captures from this build, 1080 × 2400 pixels. Timestamps use America/Toronto local time (UTC−04:00), recorded immediately after each capture.

| File | Route and state | Captured |
|---|---|---|
| `auto-preset-flow-expressive-light-app-default.png` | Profile → Gym & Workout Settings → Workout Progress Flows → App defaults → App default flow; Expressive, Curated, Light; app-default starter graph; not saved | 2026-10-05 12:56:21.500 -04:00 |
| `auto-preset-flow-expressive-dark-app-default.png` | Same app-default flow route/state; Expressive, Curated, Dark; not saved | 2026-10-05 13:15:45.172 -04:00 |
| `body-part-ranking-expressive-light.png` | Profile → Gym & Workout Settings → Workout Settings → Body Part Rankings; default ordering; Expressive, Curated, Light | 2026-10-05 13:00:29.858 -04:00 |
| `body-part-ranking-expressive-dark.png` | Same route/default ordering; Expressive, Curated, Dark | 2026-10-05 13:04:53.457 -04:00 |
| `muscle-ranking-expressive-light.png` | Profile → Gym & Workout Settings → Workout Settings → Muscle Rankings; default ordering; Expressive, Curated, Light | 2026-10-05 13:00:48.457 -04:00 |
| `muscle-ranking-expressive-dark.png` | Same route/default ordering; Expressive, Curated, Dark | 2026-10-05 13:05:30.184 -04:00 |
| `exercise-editor-expressive-light-ab-wheel.png` | Profile → Gym & Workout Settings → Workout Settings → Exercise Definitions → Exercise Editor; selected existing Ab Wheel for display; no fields changed or saved; Expressive, Curated, Light | 2026-10-05 13:18:12.250 -04:00 |
| `exercise-editor-expressive-dark-ab-wheel.png` | Same route and transient Ab Wheel selection; no fields changed or saved; Expressive, Curated, Dark | 2026-10-05 13:14:29.631 -04:00 |

## Visual QA and caveats

- UI hierarchy dumps confirmed each requested destination before capture. Ranking rows retained their names and rank fields; no keyboard or edit state was open. Exercise Editor shows the existing Ab Wheel definition and associated muscles.
- The app-default flow graph has its loopback inside the canvas edge on both captures. The header subtitle is visually ellipsized after “new…” in both modes; the remaining text is not visible in these screenshots.
- No requested route was blocked or missing. Three extra PNGs in this folder (`route-map-start.png`, `exercise-catalog-selection-state.png`, `exercise-current-route.png`) are navigation-only diagnostic states, not part of the eight requested captures.

## Food Customization follow-up captures

Captured on the already-installed final-source profile APK; no rebuild was performed. Device/package/database and source identity are the same as above. Route: Nutrition Dashboard → Add Meal → Search → `Banana` → Customize food, opening the `Edit Food` Food Customization screen. The `Portion Info` group and `Portioning basis for the nutritional values` subsection were expanded; the two existing portion rows (100 g and 118 g) are visible. No form values were changed and Save was not pressed. All image placeholders remain empty.

| File | State | Captured |
|---|---|---|
| `food-customization-expressive-light-banana.png` | Expressive, Curated, Light; Banana; Portion Info and portioning basis expanded | 2026-10-05 13:38:34.693 -04:00 |
| `food-customization-expressive-dark-banana.png` | Same route and state; Expressive, Curated, Dark | 2026-10-05 13:45:56.795 -04:00 |

Both PNGs were verified nonempty at 1080 × 2400. Preview brightness was changed only through the preview controls; the screen was reopened for the dark capture, and no data was saved.
