# Tonos Expressive remediation captures — 2026-10-10

These are local-only, unaltered Pixel 7 screenshots from the dirty-tree
candidate as it stood on 2026-10-10. “Current” in the directory name means
current at that capture time; the October 12 Onboarding source refinement has
no matching build or screenshot here. These images support review of their
recorded build only; they are not approvals or release qualification. Keep the
images out of the public repository.

## Build and capture provenance

- Repository: `E:\projects\env_test`.
- Branch: `feature/expressive-visual-polish`.
- HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`; the working tree had 19
  modified tracked Dart files. Candidate input fingerprint:
  `185de3f7a36a5c38c1ee41e76079295b5450e950f6c089f33b27032a683712b4`.
- Flutter 3.47.5 and bundled Dart 3.13.4. Bundled Dart was first on the
  subprocess PATH; `TEMP`/`TMP` remained on C:.
- Debug APK built from `lib/expressive_preview_main.dart`:
  `E:\projects\env_test\build\app\outputs\flutter-apk\app-debug.apk`.
  Size: 233,544,099 bytes. SHA-256:
  `2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7`.
- Preview build defines:
  `TONOS_EXPRESSIVE_PREVIEW=true`,
  `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`,
  `TONOS_ANDROID_INTERNAL_BUILD=false`,
  `TONOS_DATABASE_NAME=tonos_expressive_preview.db`, and
  `TONOS_PREVIEW_SHOW_CONTROLS=true`.
- Installed with `adb install -r` as `com.tonos.expressivepreview` on Pixel 7
  `28021FDH200228` (1080×2400 physical pixels, approximately 411×914 dp at
  420 dpi). Capture date: 2026-10-10.
- The normal `com.tonos` package and its data were not used.
- After capture, the isolated preview process was stopped and the preview
  database, WAL, SHM, and `FlutterSharedPreferences.xml` were restored from
  their pre-capture copies. Device hashes matched the backups; the preview was
  not relaunched afterward. Details are in
  [`../../current-source-snapshot.md`](../../current-source-snapshot.md).

## Current standard-preview screenshots

| Route / state | Light capture | Dark capture |
| --- | --- | --- |
| Profile → Training → Gym & Workout Settings → Workout Settings → Training Bias → Muscle Rankings | [muscle-rankings-light.png](muscle-rankings-light.png) | [muscle-rankings-dark.png](muscle-rankings-dark.png) |
| Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Definitions → Body Part / Muscle Mapping, read-only | [bodypart-muscle-mapping-light.png](bodypart-muscle-mapping-light.png) | [bodypart-muscle-mapping-dark.png](bodypart-muscle-mapping-dark.png) |
| Profile → Training → Gym & Workout Settings → Workout Settings → Exercise Definitions → Exercise Editor, landing | [exercise-editor-light.png](exercise-editor-light.png) | [exercise-editor-dark.png](exercise-editor-dark.png) |
| Exercise Editor → Choose exercise, caller-scoped picker | [exercise-editor-picker-light.png](exercise-editor-picker-light.png) | [exercise-editor-picker-dark.png](exercise-editor-picker-dark.png) |
| Train → Overview → Focused Sets → Weekly Sets Overview | [weekly-sets-overview-light.png](weekly-sets-overview-light.png) | [weekly-sets-overview-dark.png](weekly-sets-overview-dark.png) |
| Weekly Sets Overview → body-part detail | [weekly-sets-bodypart-light.png](weekly-sets-bodypart-light.png) | [weekly-sets-bodypart-dark.png](weekly-sets-bodypart-dark.png) |
| Weekly Sets Overview → muscle detail | [weekly-sets-muscle-light.png](weekly-sets-muscle-light.png) | [weekly-sets-muscle-dark.png](weekly-sets-muscle-dark.png) |
| Profile → Data → Database Settings, initial viewport | [database-settings-light.png](database-settings-light.png) | [database-settings-dark.png](database-settings-dark.png) |
| Database Settings, scrolled health/path values | [database-settings-health-path-light.png](database-settings-health-path-light.png) | [database-settings-health-path-dark.png](database-settings-health-path-dark.png) |
| Train → Optimize → Optimized Workout Settings, default form | [optimized-workout-settings-light.png](optimized-workout-settings-light.png) | [optimized-workout-settings-dark.png](optimized-workout-settings-dark.png) |

The folder contains **20 primary screenshots**. The route/state manifest is
[`manifest.csv`](manifest.csv). There are no hierarchy XML files in this
capture folder.

## Excluded diagnostic and missing states

- `volume-boundaries-dark-navigation-probe.png` is an accidental dark-mode
  navigation probe. It is retained locally for provenance but is not primary
  remediation evidence and is not counted in the 20 above.
- Onboarding is not captured from this exact APK. Separate onboarding images
  remain under the earlier candidate's explicitly identified
  `onboarding-bootstrap-build-4de75f5e/` folder.
- These captures do not cover systematic narrow/wide/landscape layouts, all
  text scales, keyboards, drag states, validation, persistence, error states,
  or every dialog. Candidate routes remain unapproved unless separately
  approved by the user in the authoritative visual-approval records.
- An earlier wrong-entrypoint build and its diagnostic screenshot are stored
  separately under
  [`../20261010-build-bbd53b9c-wrong-entrypoint-diagnostic/`](../20261010-build-bbd53b9c-wrong-entrypoint-diagnostic/)
  and are not evidence for this candidate.
