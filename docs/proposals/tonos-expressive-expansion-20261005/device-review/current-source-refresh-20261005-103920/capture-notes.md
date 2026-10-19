# Pixel 7 Expressive Preview Capture Notes

## Build and device identity

- Captured 2026-10-05 from 10:39:20 to 11:29 local time (America/Toronto, UTC-04:00).
- Repository: `E:\projects\env_test`, branch `feature/classic-m3e`, source HEAD `ab18ed8cab5582c8449e13724afae3c4b74ebeea`.
- The working tree was already dirty before the build (348 status entries); no source files were edited for this capture pass.
- Built using `tools/run_expressive_preview.ps1 -BuildMode profile` with Flutter 3.47.5 and bundled Dart 3.13.4. Profile build completed successfully; `--no-pub` and normal C: `TEMP`/`TMP` were used.
- Build output: `build\app\outputs\flutter-apk\app-profile.apk`; Package Manager reports package `com.tonos.expressivepreview`, version code 6, version name 1.0.1. The app was installed/launched only under that preview package.
- Runtime device: ID `28021FDH200228`, model Pixel 7 (`panther`), Android 16/API 36, 1080×2400 at 420 dpi. Device-wide display settings were not changed.
- Preview defines included `TONOS_EXPRESSIVE_PREVIEW=true`, `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`, `TONOS_ANDROID_INTERNAL_BUILD=false`, and `TONOS_DATABASE_NAME=tonos_expressive_preview.db`. The preview data directory is `/data/user/0/com.tonos.expressivepreview`.
- The standard `com.tonos` and `com.tonos.internal` packages remained installed at their original package paths. Neither app was launched, installed, cleared, or modified. All route state and any app data remained within the preview package/database.
- C: had 4.75 GiB free at final verification, above the 1.5 GiB stop threshold.
- The preview controls were set to Expressive/Curated and toggled between Light and Dark for captures. The app-level Dark Mode setting was not changed. The preview-only expanded bottom navigation remained enabled.

## Captures

All PNGs are direct device screenshots at 1080×2400. The verified route captures are:

- Auto Preset Flow, App Default Progression, Light: `auto-preset-flow-expressive-light-app-default-verified.png`.
- Auto Preset Flow, App Default Progression, Dark: `auto-preset-flow-expressive-dark-app-default.png`.
- Profile → UI & Appearance, Light/Dark: `profile-ui-appearance-expressive-light.png`, `profile-ui-appearance-expressive-dark.png`.
- Food Logging with Banana search result (`1P 0F 23C • 100 g`), Light/Dark: `food-logging-expressive-light-banana-search-keyboard-hidden.png`, `food-logging-expressive-dark-banana-search.png`.
- Food Customization portion controls for the Banana result, Light/Dark: `food-customization-portion-expressive-light-verified.png`, `food-customization-portion-expressive-dark.png`.
- Nutrition → Today’s Records (`LogEntryPage`), Oct 5 with zero totals and an empty diary, Light/Dark: `todays-records-log-entry-expressive-light-empty-verified.png`, `todays-records-log-entry-expressive-dark-empty.png`.
- Analytics Settings hub (display title “Workout Settings”), Light/Dark: `analytics-settings-expressive-light.png`, `analytics-settings-expressive-dark.png`.
- Body Part Ranking, Light/Dark: `body-part-ranking-expressive-light.png`, `body-part-ranking-expressive-dark.png`.
- Muscle Ranking, Light/Dark: `muscle-ranking-expressive-light.png`, `muscle-ranking-expressive-dark.png`.
- Volume Boundaries, Light/Dark: `volume-boundaries-expressive-light.png`, `volume-boundaries-expressive-dark.png`.
- Anatomy Mapping (display route “Body Part / Muscle Mapping”), Light/Dark: `anatomy-mapping-expressive-light.png`, `anatomy-mapping-expressive-dark.png`.
- Exercise Set Allocation, Light/Dark: `exercise-set-allocation-expressive-light.png`, `exercise-set-allocation-expressive-dark.png`.

The App Default Progression route was reached through Profile → Gym & Workout Settings → Workout Progress Flows → App default flow. The plan fixture was not changed and no flow was saved. Its far-left loopback connector still reaches the viewport edge. The subtitle wraps to two lines.

Food Logging and Food Customization were inspected without adding the food or saving any customization. The Nutrition diary was empty; no diary entries or goals were created. The correct Light Food Logging capture hides the keyboard so the search result and screen are both visible. The dark capture retains the keyboard from search entry.

## Evidence caveats and unrepresented states

- `auto-preset-flow-expressive-light-app-default.png` is a Dark duplicate captured before the verified Light pass; do not treat it as Light evidence.
- `todays-records-log-entry-expressive-light-empty.png` shows the Nutrition Dashboard in Dark mode, not Today’s Records; use the `...light-empty-verified.png` file instead.
- `food-logging-expressive-light-banana-search-verified.png` is an earlier Light capture with the keyboard open. The later `...keyboard-hidden.png` is the preferred Light evidence.
- `navigation-probe.png` shows the Android home screen after an accidental visit to the OS Battery Settings page. No setting was changed; exclude it from app review.
- The verified Light Today’s Records screenshot includes a transient Android “Used for 3h 20min” banner. It still shows the correct empty LogEntry route and date; a clean Light recapture is advisable if this transient overlay matters for final presentation.
- Body Part Ranking and Muscle Ranking captures are from the pre-refinement build. The field label is visibly clipped to “Ra…”; recapture both pairs after the separate ranking-label source fix is built.
- Exercise Editor is not represented because its source refinement was pending on this installed build. Capture it after the next source build.
- No manual goal editor state was captured. The source route could not be verified as distinct from the parent Diet & Nutrition Settings screen during the earlier route pass, so no duplicate parent screenshot is labeled as an editor.
- A thin lime outline around the app viewport is visible in several Profile/Nutrition screenshots. It was not changed or attributed to an app source defect during this pass.
- The first dark Food Logging screenshot includes the search keyboard; the new Light keyboard-hidden file improves legibility. No food was added.

## PNG inventory

There are 26 PNGs in this folder. The route captures above plus the explicitly marked duplicates/probe are retained for traceability; none were overwritten.
