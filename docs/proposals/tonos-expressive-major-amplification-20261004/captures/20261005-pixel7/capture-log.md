# Pixel 7 Capture Log

## Capture set A — previous candidate build

- Capture date: 2026-10-05 (local device time)
- Repository HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Build mirror: `E:\tonos-expressive-review-build-20261005-004610`
- Flutter/Dart: Flutter 3.47.5 / Dart 3.13.4
- Device: Pixel 7, `28021FDH200228`, API 36
- Display during standard captures: 1080×2400, density 420, text scale 1.15
- Isolated package/database: `com.tonos.expressivepreview` / `tonos_expressive_preview.db`
- APK SHA-256: `CD2E3513D2C7E4B70D0A9778CFA3880E6E69B4352913CC831CC9BE5B91E8B4D8`
- Mirrored source manifest SHA-256 (567 production/test/build-input files): `F3220B8DEB2832616889B36FA2FCE8CD39692419961E759BC15D18EC9588DB05`
- Generated Android plugin registrant SHA-256: `AC928447E398E77B1AC1CF0261AF175CF2621A7111125E3CB7E952B1BAAAFCC9`
- Runtime verification: package version 1.0.1, version code 6; isolated database files present.
- Normal Tonos (`com.tonos`) was not installed, launched, cleared, or modified by this capture run.

### Source delta discovered after build A

Workspace production Dart hashes no longer match build A's mirror for:

- `lib/screens/exercise/plan_management_page.dart`
- `lib/screens/exercise/preset_detail_screen.dart`
- `lib/screens/profile/settings/user_information_settings_page.dart`

The first set of captures for those routes is therefore provisional with respect to the current workspace. Preset Detail images under `planning/preset-detail-*` were correctly navigated by Train → Plans → tap the center/body of an Active Plan row, but are not current-source review evidence. Plan Management and User Information captures should also be refreshed if the corresponding current diffs remain in the frozen source snapshot.

Other route captures and motion clips in this folder were taken from build A. Their route labels were checked against visible titles or UI Automator hierarchy; they are valid for the mirrored build snapshot above, not for later source deltas.

### Responsive device overrides and restoration

For narrow evidence, Android display override was temporarily set to 840×2400 at density 420 (320 dp logical width); system font scale was set to 1.5 and 2.0. The device was restored and verified at 1080×2400, density 420, font scale 1.15 after capture.

### Route and state mapping

Image and video filenames describe the captured route/state. `*-diagnostic*` and files under the earlier sibling `device/` directory are not review evidence. The root-level `debug-*` screenshots and `current.xml` are capture diagnostics. The `planning/preset-detail-*` and the Plan Management/User Information images are provisional pending a current-source rebuild.

Reduced-motion screenshots/clips were produced through the isolated preview controls. The controls screenshot confirms the preview's Reduced motion toggle was on for the reduced-motion recording.

