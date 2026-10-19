# Measurement Trend detail — Pixel 7 review evidence

**Status: unapproved Expressive candidate for visual review.** This evidence is not a qualification, approval, or release claim.

## Source and build

- Repository: `E:\projects\env_test`
- Branch / source HEAD: `feature/classic-m3e` / `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- The working tree was dirty with extensive unrelated work; no files were staged, committed, or pushed.
- Task code/test files: `lib/widgets/health_trends_section.dart` and `test/theme/widgets/health_trends_chart_accessibility_test.dart`.
- Toolchain: Flutter 3.47.5, bundled Dart 3.13.4.
- Fresh debug preview APK: `E:\projects\env_test\build\app\outputs\flutter-apk\app-debug.apk` (233,369,598 bytes at capture time).
- Installed preview package: `com.tonos.expressivepreview`; isolated database: `tonos_expressive_preview.db`.
- Device: Pixel 7, serial `28021FDH200228`, product/device `panther`; screenshot resolution 1080 × 2400.
- Captures were made October 6, 2026 from the rebuilt current-source preview. The preview was set to Expressive presentation, Curated data, and the named light/dark mode. Profile theme-family preference remained Classic; it does not control the isolated preview's rendered recipe.

## Captures

### Populated Weight

| State | Light | Dark |
| --- | --- | --- |
| Route top: summary, chart, Entries, pinned Log entry | [Light](weight-detail-top-light-final.png) | [Dark](weight-detail-top-dark-final.png) |
| Scrolled history / app-bar state | [Light](weight-detail-scrolled-light-final.png) | [Dark](weight-detail-scrolled-dark-final.png) |
| Log Weight dialog, keyboard visible | [Light](weight-log-dialog-light-final.png) | [Dark](weight-log-dialog-dark-final.png) |
| Log Weight dialog, keyboard hidden | [Light](weight-log-dialog-light-hidden-final.png) | [Dark](weight-log-dialog-dark-hidden-final.png) |

The preview's Weight metric already had three records. Their existing values were preserved; no records were created or deleted for capture. The chart retains all three actual points, including two points on Oct 7, while displaying one Oct 7 axis tick.

### Genuine empty metric representative

Weight was not cleared to manufacture an empty state. Height had no records and is used to show the same empty-summary, chart, Entries, and logging-modal states without destructive preview-data edits.

| State | Light | Dark |
| --- | --- | --- |
| Empty metric route | [Light](height-detail-empty-light-final.png) | [Dark](height-detail-empty-dark-final.png) |
| Empty metric Log dialog | [Light](height-log-dialog-empty-light-final.png) | [Dark](height-log-dialog-empty-dark-final.png) |
| Empty metric Log dialog, keyboard hidden | [Light](height-log-dialog-empty-light-hidden-final.png) | — |

`progress-root-light-final.png` is included as surrounding destination context; it predates the final route-specific recapture and is not evidence for changed Measurement Trend behavior.

## Review notes

- The summary foregrounds Latest, with Change and Records as supporting values. Expressive Records is a count and therefore has no measurement-unit suffix; populated Weight reads `3`, and empty Height reads `0`.
- The chart uses an analytical cool surface and Progress-colored series. Y-axis ticks remain distinct at tested close/large values. Repeated same-day measurements preserve separate accessible data points while duplicate date labels are suppressed.
- Historical entries use a quieter warm surface; the persistent Log entry remains the page-level action.
- The logging modal keeps Weight, Unit, Variation, Note, date/time, Cancel, Save, validation, and current persistence callbacks.
- The final route captures were visually inspected for hierarchy, mode pairing, label separation, and clipping. No obvious clipping or horizontal overflow was observed in these Pixel-width captures.
- Compact 320 dp and 1.5×/2× text behavior was exercised in focused widget tests; this evidence folder does not contain physical-device captures at those configurations.

## Validation

- `flutter test --no-pub test/theme/widgets/health_trends_chart_accessibility_test.dart`: **22 passed, 0 failed**, exit 0.
- Scoped `dart analyze` on the task source and test: **No issues found**, exit 0.
- Check-only format: **2 files checked, 0 changed**, exit 0.
- Scoped `git diff --check`: exit 0 (Git emitted existing line-ending warnings).
- Full repository test suite: intentionally deferred; this remains a visual candidate.
- No normal `com.tonos` app/database was targeted. No commit or push was made.
