# Pixel 7 destination color review

Captured 2026-10-04 on Pixel 7 (`28021FDH200228`, 1080 × 2400) from the current `feature/classic-m3e` working tree. The isolated preview controls were Expressive, Curated, Light/Dark as named, reduced motion off, effects on, and OS/app-default text scale. The first set was static visual evidence; supplemental captures and focused tests were added after the Profile destination surface-scope correction described below.

## Build and install

- Build: `tools/run_expressive_preview.ps1 -BuildMode profile`, which pins Flutter 3.47.5 / bundled Dart 3.13.4, uses `--no-pub`, sets the preview-only entry point and required defines, and verifies the APK manifest before install.
- APK: `build/app/outputs/flutter-apk/app-profile.apk`, profile version 1.0.1 / versionCode 6, package `com.tonos.expressivepreview`, SHA-256 `C8ABA69D98E8DC995DCBF5FE57C586DBF70ACBFBCC1F702CA49DF209E3277477`.
- Install: `adb -s 28021FDH200228 install -r build/app/outputs/flutter-apk/app-profile.apk` (success), followed by the launcher intent for `com.tonos.expressivepreview`.
- The build runner validated `TONOS_EXPRESSIVE_PREVIEW=true`, `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`, `TONOS_ANDROID_INTERNAL_BUILD=false`, and `TONOS_DATABASE_NAME=tonos_expressive_preview.db`. Package Manager reports data under `/data/user/0/com.tonos.expressivepreview`. `com.tonos` remained installed and was not installed, launched, or otherwise targeted.

## Captures

| State | Screenshot |
|---|---|
| Catalog root, light / dark | `expressive-light-catalog-root.png` / `expressive-dark-catalog-root.png` |
| Logbook root, light / dark | `expressive-light-logbook-root.png` / `expressive-dark-logbook-root.png` |
| Progress root, light / dark | `expressive-light-progress-root.png` / `expressive-dark-progress-root.png` |
| Profile root, light / dark | `expressive-light-profile-root.png` / `expressive-dark-profile-root.png` |
| Read-only Logbook session detail, light / dark | `expressive-light-session-detail.png` / `expressive-dark-session-detail.png` |
| Train Overview and shell, light | `expressive-light-train-overview-shell-settled.png` and `expressive-light-train-overview-shell-quiet.png` (an earlier adjacent capture is `expressive-light-train-overview-shell.png`) |
| Profile root after destination-scope correction, light / dark | `expressive-light-profile-top-after-fix.png` / `expressive-dark-profile-root-after-fix.png` |
| Profile Data section after correction, light / dark | `expressive-light-profile-data-after-fix.png` / `expressive-dark-profile-data-after-fix.png` |
| Database Settings, light / dark | `expressive-light-database-settings.png` / `expressive-dark-database-settings-after-fix.png` |
| Diagnostics & Privacy, light / dark | `expressive-light-diagnostics-privacy.png` / `expressive-dark-diagnostics-privacy-top-after-fix.png` |

## Visual findings

- **Catalog:** Purple and mint section surfaces, blue exercise cards, and peach anatomy cards make each grouping distinct. Exercise names, counts, and target-anatomy labels have readable contrast in both modes. The long Back Extension equipment subtitle is ellipsized; the anatomy section continues below the fold and is safely scrollable. No shell or tab changes were visible.
- **Logbook:** The selected day outline and selected period remain easy to identify in both modes. Session summary, volume, duration, and focused-set colors are legible; the existing body map keeps its data colors. The date-grid and selected-session states showed no clipping at their visible edges. The shared session detail keeps its fixed bottom actions readable while the lower exercise list continues below the fold.
- **Progress:** Report totals, chart series, range selection, and positive-change green remain readable in both modes. The chart's month tick labels crowd together around August/September (`AUGSEP`), so that date axis is the remaining visible legibility concern; color contrast does not resolve the overlap.
- **Profile:** The latest after-fix root captures show Account in the purple family and Training in teal in both modes. The Data section is blue in light and dark, while Nutrition remains visibly disabled and muted. Database Settings carries blue Backup & Restore grouping while preserving green database-health semantics. Diagnostics & Privacy uses blue for app information and rose for diagnostics/privacy semantics. The anonymous-diagnostics control remains disabled in this preview build. No import, export, deletion, or privacy toggle action was triggered. `expressive-light-profile-root.png` and `expressive-dark-profile-root.png` are the earlier captures from before the Profile destination scope was installed around section-surface resolution; use the `*-after-fix` root captures for review.
- **Train/shell reference:** The five-tab shell, selected indicator, Overview/Plans control, and Start/Optimize actions look aligned with the pre-task reference. The current Active Plans rows use broad tinted fills with dark titles, while `docs/proposals/tonos-expressive-train-proving-ground/amplified-review/overview-expressive-light-final.png` shows neutral row fills with colored outlines/titles. Focused Sets meter strokes are wavy here versus straight in that reference; the wavy shape persisted in three captures, including one after a quiet 12-second interval, so it is not a single-frame capture timing difference. These are visible current-preview differences to adjudicate. No active workout existed in the preview (`Start Workout` was shown), so no session was started and a current Active Workout screen was not inspected; existing captures remain in `docs/proposals/tonos-expressive-active-workout/review/`.

The preview was left on Train → Overview in Light mode with Expressive/Curated selected, no active workout, and no modal open. Review navigation did not edit workout, import/export, cache, or privacy data.

## Supplemental review and validation

- The Profile section containers initially resolved their surface roles before the destination theme scope was installed. The Profile root now evaluates its section surfaces from a `Builder` inside that scope. The post-fix light/dark captures above show the corrected Account, Training, and Data containers.
- The dark Data, Database Settings, and Diagnostics & Privacy screens were reopened on the same isolated preview install and visually inspected. The only dark-mode appearance change in this review was confirming that the existing semantic success/error/privacy colors remain intact alongside the destination palette.
- After the Profile correction, the focused Profile presentation, Measured Items, pending-settings-route, and route-ledger test batch completed with **23 passed, 0 failed**. Scoped Dart analysis exited 0 with three informational `TickerMode.of` deprecation notices and no warnings or errors. `git diff --check` exited 0; Git printed only its existing LF/CRLF conversion notices. This was not a full repository test run.
- `current-before-dark-data.png` and the earlier `expressive-dark-diagnostics-privacy-after-fix.png` are exploratory captures; the named `expressive-dark-profile-data-after-fix.png` and `expressive-dark-diagnostics-privacy-top-after-fix.png` are the clean review captures.
