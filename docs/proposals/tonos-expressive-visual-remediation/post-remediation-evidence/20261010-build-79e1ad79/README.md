# Tonos Expressive post-remediation evidence — 2026-10-10

This folder contains local-only Pixel 7 captures for the dirty-tree candidate
as it stood on 2026-10-10. “Current” in older descriptions means current at
that capture time; later source changes are not represented. The evidence
supports user visual review of its recorded build; it does not grant approval
or technical qualification. No image was edited or cropped.

## Candidate and build provenance

- Branch: `feature/expressive-visual-polish`.
- HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f` (the pushed preservation
  baseline); the candidate source tree was dirty with the 11 tracked source and
  test files listed in [`../../current-source-snapshot.md`](../../current-source-snapshot.md).
- Standard preview APK: `app-debug-standard-79e1ad79.apk` in the local temp
  directory; SHA-256
  `79e1ad795542bc93dd163046040a051ecc90a3ffeeb03c3bea5d1cf6b1aa5ce2`.
- Flutter 3.47.5; bundled Dart 3.13.4.
- Physical device: Pixel 7, ADB serial `28021FDH200228`, 1080×2400 at 420 dpi
  (approximately 411×914 logical dp).
- Isolated package: `com.tonos.expressivepreview`; database define:
  `tonos_expressive_preview.db`. The normal Tonos package and database were
  not used. The preview database, WAL, SHM, and preferences were backed up;
  their final restoration and SHA-256 verification are recorded in the source
  snapshot.
- Capture date: 2026-10-10. The app was run in debug mode, so the diagonal
  DEBUG banner is runtime decoration.

## Captures from the standard source APK

| Route / state | Light | Dark | Notes |
| --- | --- | --- | --- |
| Muscle Rankings | [image](muscle-rankings-light.png) · [hierarchy](muscle-rankings-light.xml) | [image](muscle-rankings-dark.png) · [hierarchy](muscle-rankings-dark.xml) | Long `Transverse Abdominis` label wraps to two lines; it is not truncated. |
| Body Part / Muscle Mapping | [image](bodypart-muscle-mapping-light.png) · [hierarchy](bodypart-muscle-mapping-light.xml) | [image](bodypart-muscle-mapping-dark.png) · [hierarchy](bodypart-muscle-mapping-dark.xml) | Read-only state. |
| Body Part / Muscle Mapping — edit | [image](bodypart-muscle-mapping-edit-light.png) · [hierarchy](bodypart-muscle-mapping-edit-light.xml) | [image](bodypart-muscle-mapping-edit-dark.png) · [hierarchy](bodypart-muscle-mapping-edit-dark.xml) | Edit state; persisted mapping values were not changed. |
| Exercise Editor | [image](exercise-editor-light.png) · [hierarchy](exercise-editor-light.xml) | [image](exercise-editor-dark.png) · [hierarchy](exercise-editor-dark.xml) | Landing state. |
| Exercise Editor → Choose exercise | [image](exercise-editor-picker-light.png) · [hierarchy](exercise-editor-picker-light.xml) | [image](exercise-editor-picker-dark.png) · [hierarchy](exercise-editor-picker-dark.xml) | Caller-scoped Catalog presentation. |
| Weekly Sets Overview — Bodyparts | [image](weekly-sets-overview-bodyparts-light.png) · [hierarchy](weekly-sets-overview-bodyparts-light.xml) | [image](weekly-sets-overview-bodyparts-dark.png) · [hierarchy](weekly-sets-overview-bodyparts-dark.xml) | Open from Train Overview by tapping the Focused Sets card. |
| Weekly Sets Overview — Muscles | [image](weekly-sets-overview-muscles-light.png) · [hierarchy](weekly-sets-overview-muscles-light.xml) | [image](weekly-sets-overview-muscles-dark.png) · [hierarchy](weekly-sets-overview-muscles-dark.xml) | Selected tab state. |
| Dashboard root | [image](dashboard-root-light.png) · [hierarchy](dashboard-root-light.xml) | [image](dashboard-root-dark.png) · [hierarchy](dashboard-root-dark.xml) | XML confirms Dashboard selected in both captures. |
| Workout Settings (reference capture) | [bottom state](workout-settings-bottom-light.png) · [hierarchy](workout-settings-bottom-light.xml) | [main](workout-settings-dark.png) · [hierarchy](workout-settings-dark.xml); [bottom](workout-settings-bottom-dark.png) · [hierarchy](workout-settings-bottom-dark.xml) | Context reference only; no approval change. |
| Gym & Workout Settings and Train root (reference captures) | — | [Gym & Workout Settings](gym-workout-settings-dark.png) · [hierarchy](gym-workout-settings-dark.xml); [Train root](train-root-dark.png) · [hierarchy](train-root-dark.xml) | Context references only. |

## Onboarding captures from a separate bootstrap APK

The first-run gate is normally bypassed on the preview database. To capture
onboarding, a temporary route-only entrypoint was added to `main.dart` for a
separate build, then removed. It used the same current onboarding source and
did not seed or reset preview data. This bootstrap APK is **not** the standard
79e1ad79 APK above and should not be used as proof of the standard app entry
route.

- Temporary onboarding bootstrap APK SHA-256:
  `4de75f5e0ebbb8b79385519a033f5b7722731cfa3f0c9e981910ec29de7b4ca1`.
- Capture directory: [`onboarding-bootstrap-build-4de75f5e/`](onboarding-bootstrap-build-4de75f5e/).
- Captures include Welcome, Basics, Focus, Gym Profile, Equipment, Workout Plan,
  Workout Space review, and Summary states across the two available onboarding
  variants and themes. These states are not a fully state-matched light/dark
  matrix.
- `onboarding-skip-setup-dialog-light.png` is the Skip setup confirmation
  overlay on the Focus step; it is not an Exercise Setup page capture.
- The temporary entrypoint change is absent from the current source diff.

## Limits and review boundary

- Device screenshots cover the Pixel 7's normal viewport only. They do not
  establish 320 dp, tablet, landscape, or a systematic text-scale matrix.
- These captures do not cover every dialog, validation, error, persistence,
  keyboard, drag, or selected state. The onboarding bootstrap images include a
  specific first-run route, not the normal preview launch path.
- Dashboard root and Weekly Sets Overview remain unapproved unless the
  authoritative approval ledger independently says otherwise. The review
  queue is not an approval record.
- `live-route-probe.*` and `profile-root-light-exploratory.*` are navigation
  probes, excluded from the curated review set.
- All media remains local per user instruction; nothing in this directory was
  staged, committed, pushed, or published.
