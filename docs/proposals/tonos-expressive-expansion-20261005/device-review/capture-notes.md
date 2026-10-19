# Pixel 7 device review captures

## Build and device

- Capture session: 2026-10-05, America/Toronto (UTC-04:00), 08:32–09:39. The exact artifact timestamps are the file modification times in this folder.
- APK build completed at 2026-10-05 08:09:31.524 -04:00 from the live working tree.
- Repository: `E:\projects\env_test`, branch `feature/classic-m3e`, HEAD `ab18ed8cab5582c8449e13724afae3c4b74ebeea` (`Add Expressive planning route previews`). The tree was dirty before this capture pass, with extensive user-owned source, test, and proposal changes. No source files were edited for this device pass.
- Integrated focused validation gate: 162 tests across 22 targets, 0 failures (reported by the parent task before this build).
- Toolchain: Flutter 3.47.5 and bundled Dart 3.13.4 from `E:\tools\flutter_sdks\3.47.5\flutter`.
- Build: `tools/run_expressive_preview.ps1 -BuildMode profile`; profile APK built from `lib/expressive_preview_main.dart`, `--no-pub`. The runner verified the manifest package and the requested database defines.
- Defines: `TONOS_EXPRESSIVE_PREVIEW=true`, `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`, `TONOS_ANDROID_INTERNAL_BUILD=false`, `TONOS_DATABASE_NAME=tonos_expressive_preview.db`.
- C: free space was 5,214,887,936 bytes before build, 5,212,258,304 bytes after build, and remained above 5.1 GB at the end of this pass. Normal `C:\Users\talh7\AppData\Local\Temp` was used for both `TEMP` and `TMP`.
- Device: physical Pixel 7, ADB ID `28021FDH200228`; runtime properties report model `Pixel 7`, codename `panther`, Android 16/API 36. Display reports 1080×2400 at 420 dpi. Global `wm` size/density settings were not changed.
- Package Manager after install confirmed `com.tonos.expressivepreview`, version 1.0.1 / versionCode 6. The APK was installed and launched only under this package. The app used its isolated `tonos_expressive_preview.db`; `com.tonos`, `com.tonos.internal`, and other installed packages were not launched, cleared, or modified.
- The preview controls began at Expressive / Curated / Light. Light and dark were changed only through preview controls. The preview sandbox tab configuration was temporarily expanded to show Dashboard and Nutrition so both routes could be reached.

## Captured states

All PNGs are direct device screenshots at 1080×2400. No screenshots were composited or resized.

| Route | Files | State and route evidence |
| --- | --- | --- |
| Dashboard | `dashboard-expressive-light.png`, `dashboard-expressive-dark.png` | Dashboard tab; populated Expressive Preview profile and seeded plan rows. |
| Analytics Dashboard | `analytics-dashboard-expressive-light.png`, `analytics-dashboard-expressive-dark.png` | Train → Weekly Overview → Focused Sets. The route reports 36 total sets, 2h 34m, and 7.7k lbs. |
| Nutrition root | `nutrition-root-expressive-light.png`, `nutrition-root-expressive-dark.png` | Nutrition tab. No active nutrition goal or diary food is present; totals are 0/0 and health trends are empty. |
| Food Logging | `food-logging-expressive-light-banana-search.png`, `food-logging-expressive-dark-empty.png` | Add Meal. Light shows the existing local Banana result (`1P 0F 23C`, 100 g); dark shows the empty search state. No food was added to the diary. These Nutrition child captures are pre-refinement. |
| Food Customization / portion controls | `food-customization-portion-expressive-light.png`, `food-customization-portion-expressive-dark.png` | Selected existing Banana record; default 100 g and alternate 118 g portions visible. The form was not saved. These Nutrition child captures are pre-refinement. |
| Barcode Scanner | `barcode-scanner-expressive-light-empty.png` | Food Logging → Scan → Open camera scanner. Camera permission was granted to the preview package only. Scanner frame is visible over a nearly black live camera preview; no barcode was scanned. Dark state remains unrepresented pending the source refresh. |
| Nutrition Diary | `nutrition-diary-expressive-light-empty.png`, `nutrition-diary-expressive-dark-empty.png`, `nutrition-diary-expressive-light-2x-text.png` | Nutrition drawer → Today's Records, 2026-10-05. The diary has no entries and totals remain 0/0. The 2× text-scale state was set through preview controls; it is an accessibility stress capture. These Nutrition child captures are pre-refinement. |
| Nutrition Goal settings | `nutrition-goal-settings-expressive-dark.png` | Nutrition drawer → Nutrition Goals. No saved goal exists. Light state remains unrepresented pending the source refresh. |
| Manual Nutrition Goals editor | `nutrition-goal-editor-expressive-light-empty.png`, `nutrition-goal-editor-expressive-dark-empty.png` | Verified editor route and title; empty fields, default start date 2026-10-05. No goal was saved. These Nutrition child captures are pre-refinement. |
| Auto Preset Flow | `auto-preset-flow-expressive-light.png`, `auto-preset-flow-expressive-dark.png` | Train → Plans → Active Review 1 → overflow → Plan Progression. The plan was marked automatic in the isolated preview DB to expose this route; no flow rules were changed or saved. Pre-refinement screenshots. |
| Preset Generation QA | `preset-generation-expressive-light.png`, `preset-generation-expressive-dark.png` | Train → Plans → Generate Custom Plans. Default QA form: one plan, 60 minutes, five-set maximum. No plan was generated or saved. |
| Profile / UI & Appearance | `profile-ui-appearance-expressive-light-pale-surface.png` | Profile → UI & Appearance in Expressive / Light. Captured as a pre-fix defect example. |

## Unrepresented states and visual findings

- Onboarding was not reachable from this preview build. `main.dart` selects `MainScreen` whenever a preview presentation is active, before the ordinary `showOnboarding` gate. Turning on Replay Onboarding and restarting the preview therefore returned to Train. No onboarding screen was invented or captured.
- No 320 dp compact-width screenshot was made. Preview controls do not provide a safe compact-width control; device-wide `wm` settings were left untouched. The one 2× text-scale diary capture shows wrapped and clipped time labels at the left side of the timeline.
- Profile / UI & Appearance has white labels on pale surfaces in the Expressive / Light capture. The parent reviewer confirmed this is a contrast defect; screenshots remain pre-fix.
- Auto Preset Flow shows a clipped header subtitle and the graph's incoming connector reaches the left edge. The current canvas is stark black/white in dark/light modes; parent review identified a Classic AppFlowTokens appearance leaking into Expressive. Keep this pair marked pre-fix.
- The Nutrition diary light header title is black on a deep plum surface. Parent review confirmed a contrast refinement is pending; the captured diary pair is pre-refinement.
- The Nutrition child pages and Manual Nutrition Goals editor were captured before the pending Nutrition presentation refinement. Their screenshots are retained as pre-fix evidence and must not be treated as the final current-source pair after that source update.
- The dark Food Customization capture shows lower portion controls partly behind the sticky Cancel/Save footer at the initial scroll position; the page scrolls. Review whether this is expected at the captured position.
- Nutrition diary and goals have no sandbox data. The Banana row comes from the existing local food catalog; no diary row, goal, or generated plan was created.

## Review boundary

This pass built and installed a profile APK from the dirty working source under the isolated preview identity. The screenshots document the device appearance and route reachability; they do not imply a full app release build, a clean checkout, or completion of the pending visual refinements above.
