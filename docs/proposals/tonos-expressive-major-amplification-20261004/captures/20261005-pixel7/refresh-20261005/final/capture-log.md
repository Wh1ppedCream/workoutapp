HEAD=ab18ed8cab5582c8449e13724afae3c4b74ebeea
BRANCH=feature/classic-m3e
SOURCE_MANIFEST_SHA256=f086be49f58fe0de1f830eb429434742af53fcb8924346d6b1052338e363e96e
MIRROR_MANIFEST_SHA256=f086be49f58fe0de1f830eb429434742af53fcb8924346d6b1052338e363e96e
COPIED_FILES=1693
SYNCED_PATHS=lib/widgets/tonos_bottom_navigation_bar.dart;test/expressive_navigation_presentation_test.dart
DEVICE_ID=28021FDH200228
PACKAGE=com.tonos.expressivepreview
DATABASE=tonos_expressive_preview.db
APK_SHA256=72d698a44a6b7de1d038286e94941be61e9c9269e50614d1c0ceb51cc2df8f27
SOURCE_MANIFEST_SHA256=f086be49f58fe0de1f830eb429434742af53fcb8924346d6b1052338e363e96e
Flutter=3.47.5; Dart=3.13.4; profile; --no-pub
TEMP=C:\Users\talh7\AppData\Local\Temp; TMP=C:\Users\talh7\AppData\Local\Temp
Device=28021FDH200228 / Pixel_7
Physical size=1080x2400; density=420; system font scale=1.15
Old set A and refresh provisional attempts are historical/untrusted for this source revision.

## Final targeted responsive captures

The current device state was restored after capture: `wm size reset` verified 1080x2400, density 420, and system font scale 1.15. The isolated preview remains installed and its database is `tonos_expressive_preview.db`.

Valid states captured in this refresh include Profile root at normal size and 320dp at 1x/system 1.15x, User Information in light and dark, Plan Management at 320dp/2x light, and Logbook 4Y at 320dp/2x light. The Logbook capture is correctly route-identified and includes 2026 selected with session summaries showing duration, exercise count, set count, and volume. However, the 320dp/2x navigation labels wrap inside words; mark that responsive image diagnostic until the separate navigation-label fix is rebuilt and captured.

The file previously named `active-workout-320-2x-light.png` was actually an Exercise Catalog screen with Ab Wheel selected, not Active Workout. It has been retained under `diagnostics/exercise-catalog-ab-wheel-selected-320-2x.png` and is not review evidence. No valid Active Workout responsive capture was obtained in this attempt. The preview-only session flow was left with no exercises and did not provide a reliable route to the intended logging state.

This capture pass did not touch the normal Tonos package or data. It did not modify source, commit, or push.

## Bottom-navigation follow-up capture

Capture time: 2026-10-05, approximately 04:15-04:16 local. Rebuilt from the current live workspace using the E: mirror; source/mirror manifest SHA256 `5b31b62f2cfce0c256c88dc195a5e49c4716975ff1711484789f97529ba47223`; APK SHA256 `405b4c30c9b50d785c1edfc11c210458b5208483953978fcf835a364882903e8`. Flutter 3.47.5 / Dart 3.13.4, profile, `--no-pub`; package manifest verified `com.tonos.expressivepreview`, DB define `tonos_expressive_preview.db`.

Fresh follow-up files are under `followup-bottom-nav-20261005/`. The Profile root screenshot shows all five vertical nav rows and Profile selected. The Logbook screenshot shows 4Y with 2026 selected and the scrolled summary alongside all five nav rows; labels no longer break inside words. Session summary fields remain readable, though line wrapping is still dense at 2x. A genuine Active Workout was reached via Train > Plans > Active Review 1 > Start Session, with Ab Wheel and set controls; its screenshot is retained for review, but marked diagnostic because the exercise name and Weight/Reps labels wrap awkwardly at 320dp/2x.

After captures, the Pixel display was restored and verified: physical 1080x2400, density 420, system font scale 1.15. Only the isolated preview app/database was used. No source edits, commit, or push were made.
