# Current Source and Preview Snapshot

Snapshot for the Pixel evidence in this folder. This identifies the dirty working tree used to build the preview; it is not a source archive.

## Repository identity

- Repository: `E:\projects\env_test`
- Branch: `feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Upstream: `origin/feature/classic-m3e`
- Capture/build source: current working tree at that HEAD, including uncommitted changes.
- Index: empty; no commit or push was made.
- Tracked state at task entry: 134 modified tracked files and 528 untracked status entries, per the initial repository audit. At closeout, expanded `git status --porcelain --untracked-files=all` listed 135 modified tracked paths and 1,536 untracked paths; the expanded untracked count includes nested files and is not directly comparable to the initial collapsed status count. The final four untracked paths include the Profile evidence capture and three audit documents created during closeout; most other paths are pre-existing user work/artifacts.
- A pre-task SHA-256 manifest was compared at closeout. The only mismatches among its tracked entries were the three intended tracked files: `auto_preset_flow_screen.dart`, `settings_tiles.dart`, and `auto_preset_flow_screen_theme_test.dart`. `settings_tiles_test.dart` was clean at entry and now contains focused tests plus formatter changes. Existing untracked Profile Expressive source/tests were preserved and extended for this task.

## Toolchain and device

- Flutter: `E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat`, Flutter **3.47.5**.
- Dart: `E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin\dart.exe`, Dart **3.13.4**.
- Device: Pixel 7 `28021FDH200228`; runtime `wm size` = **1080×2400**, `wm density` = **420 dpi**, Android **16**.
- Package: `com.tonos.expressivepreview`.
- Database: `tonos_expressive_preview.db`, still present after `adb install -r`, observed at **1,572,864 bytes**. It was not cleared/replaced; the file modification time advanced during normal preview interaction.
- Final device route: Profile → Gym & Workout Settings → Workout Progress Flows → App Default Progression; **Add a branch** and **Attach a progression action** both expanded; dark mode.
- Local evidence capture time: 2026-10-08, approximately 22:15–22:30 America/Toronto (timestamps are recorded on the evidence files).

## Build recipe

The installed artifact was built from the current source with the isolated entry point and database:

```powershell
$env:PATH='E:\tools\flutter_sdks\3.47.5\flutter\bin;E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin;' + $env:PATH
$env:TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD='true'
flutter.bat build apk --debug --no-pub -t lib/expressive_preview_main.dart --dart-define=TONOS_EXPRESSIVE_PREVIEW=true --dart-define=TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true --dart-define=TONOS_ANDROID_INTERNAL_BUILD=false --dart-define=TONOS_DATABASE_NAME=tonos_expressive_preview.db
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

Build and install succeeded. No production Tonos package was launched or changed.

## Current task source and test hashes

SHA-256 values recorded after final source validation:

| Path | SHA-256 |
| --- | --- |
| `lib/screens/exercise/auto_preset_flow_screen.dart` | `C350EFAB528BDE6AF0EB8F6093DEEA52947DDA63EE679E6D98B167E5DB77BA26` |
| `lib/screens/exercise/flow_editor_expressive_widgets.dart` (pre-existing untracked source used by the preview; not changed in this audit) | `23D8B15B9F3F0CAB6203B50C54EFC1CDB49BF6CCEB47F3DB42379A8E53696C34` |
| `lib/widgets/settings_tiles.dart` | `4FC65CBD8CADD5AEC5608C5B6C49660234A62B4E5B3B9CC77A10E3BFEE65557A` |
| `lib/screens/profile/settings/profile_expressive_selection.dart` | `A55136166AC8DD95086DE3F0507EF32063E1B83C5A8D58239B13DA835EA45667` |
| `test/theme/widgets/auto_preset_flow_screen_theme_test.dart` | `D680419CD9532010EB53B1200E51CC3C4407E4C8F871E3874F1325EA519618D5` |
| `test/theme/widgets/auto_preset_flow_panels_golden_test.dart` | `15A3A6923E45D3124158EA127C7891B739963A0EFFE43F9D378CFE6D1DB04B7A` |
| `test/theme/widgets/settings_tiles_test.dart` | `7A8632C4E5ADA3F483CD32E6EB91A48A15F5CAFFA1BB0E958A064015476659BE` |
| `test/theme/widgets/profile_settings_expressive_test.dart` | `346BCF99B288398524D33FD64D0C0276EABEA6DADAAE488725760E532864519E` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `CB49A75771FE1C3E06CFAD953C70F5DA4CEDB3CA45EE25E24E7A6A20B7F5C9FD` |

Four Flow Editor golden hashes:

| Path | SHA-256 |
| --- | --- |
| `test/goldens/expressive_flow_editor/controls_dark_collapsed.png` | `B4CA88A0CE33E45F263361E8F9C4F5C9B6E58B1B54309E3D4F3F82FD09E75B2D` |
| `test/goldens/expressive_flow_editor/controls_dark_expanded.png` | `0E2D986D085C60BC222DCF9433D96EBABF50580E5428A3B1632E08D05C403E7B` |
| `test/goldens/expressive_flow_editor/controls_light_collapsed.png` | `138BBF93B27F1611909E7E16BE6A2177339361D3E93D005AF4D619A8FD9A3085` |
| `test/goldens/expressive_flow_editor/controls_light_expanded.png` | `50762F6905617E7D40EA1A2952E5DFAB6697A3F3BBCEE74D7EBCBA38C24C83CF` |
