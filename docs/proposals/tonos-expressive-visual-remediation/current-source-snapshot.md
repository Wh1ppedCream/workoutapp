# Current-source candidate snapshot

## Current working-tree supplement — 2026-10-12

This supplement records the live repository state after the focused C/D
implementation follow-up. The October 10 build, screenshots, device data
hashes, and validation below remain accurate for their recorded point in time,
but they are **historical** and do not prove the current dirty source tree was
built or captured. This is a local candidate record, not a release or approval
record.

- Branch: `feature/expressive-visual-polish`.
- HEAD: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`; no upstream is configured.
- `origin/feature/classic-m3e` was rechecked with `git ls-remote` and still
  points to that baseline. No remediation commit or push was made.
- Working tree at this update: **61 modified tracked paths, 2,194 untracked
  paths, and 0 staged paths**. Preserve all of them; no cleanup was performed.
- Current Dart source/test manifest: **56 paths** (52 modified tracked Dart
  files and 4 untracked Dart files). Its fingerprint uses sorted
  `path<TAB>lowercase-file-SHA256` records, LF terminated and UTF-8 encoded:
  `62e10fc222ec639839fe76836764647b3f3331835e4e92993952b9b82112bfc0`.

| Current Dart path | SHA-256 |
| --- | --- |
| `lib/l10n/generated/app_localizations.dart` | `e96bd31e0e6e28d8c4ff70505209266d7d1bf6698b82ec8cfb49cffd4f5e1d58` |
| `lib/l10n/generated/app_localizations_bn.dart` | `3fba7e4f39172c1c69147e45439e67937f8d354c65cc78e77b8e751b651fe4d0` |
| `lib/l10n/generated/app_localizations_en.dart` | `42733b813f577aa2314bf975501ec41b3a078a241ae78b91f77e1c2bc4c1842b` |
| `lib/l10n/generated/app_localizations_es.dart` | `86c1bc81c510bf783448206d206bcf6c9e5c3caf64846cb199e64d8471e77ed9` |
| `lib/l10n/generated/app_localizations_fr.dart` | `a9572d2204149009e04c3be75ff0311f36c240fa90b09a9e6e8d9af365f9aa7d` |
| `lib/l10n/generated/app_localizations_hi.dart` | `fb65d900061555263a5462ebefd8a727b02d6fb727db6b323df22d4e12b418bf` |
| `lib/l10n/generated/app_localizations_zh.dart` | `82d9e7b7bf7d1296facfba3b7b437afebd1539ca7f1f58f29930c6f3fc423c67` |
| `lib/screens/dashboard_page.dart` | `bfee219115e003726c4ae95259c26803a54c72a593d4dfc2e0d4bc60b343e205` |
| `lib/screens/exercise/analytics_dashboard_screen.dart` | `1f5de13de33c71db65cb1744b96cc45f68fc0e80875ad9210144ea19748b480a` |
| `lib/screens/exercise/auto_preset_flow_screen.dart` | `4cc929d0ead968e7687b00a2d04564307e0ff834e9c25668ebb005fdc3391b9b` |
| `lib/screens/exercise/definitions_by_bodypart_page.dart` | `e2bd3097c97c305a8c016616d4dcfa73b2549cefad3890ee8535546116510443` |
| `lib/screens/exercise/definitions_by_muscle_page.dart` | `13d59bcbc032551ef0c9ace1399b63562b0eed4c5e5361540c8f6123b73df40f` |
| `lib/screens/exercise/exercise_catalog_page.dart` | `0d4c74a2ba975736b1ee88d9e88995ab859272564e393999909320e6aaf03bd0` |
| `lib/screens/exercise/optimized_workout_settings_page.dart` | `a16ab744d8e1ef38e1fcf8b8dbd2bf44337880be34d16bdf398407b36796bf34` |
| `lib/screens/exercise/preset_detail_screen.dart` | `90b56a7c015de2a61873d8ddee4c57ed5a9cee14fec0dfa1b1b3c2c6c2c738c6` |
| `lib/screens/exercise/train2_page.dart` | `d94701bc2bffea909abd6951ee9049703942ba24c3acdc94b0cddbd32d36c609` |
| `lib/screens/onboarding_flow.dart` | `58a4f56e4862edc7b36ae786a96bac355373e7e5c0495869f87ae0c6035ee09d` |
| `lib/screens/profile/settings/analytics_destination_surfaces.dart` | `60f31b19ed2c247d3b3c29d12f64ae2c334e94d879aa7b17418034c2952431be` |
| `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart` | `49c30dc281d7932b15621584f2a64e8d7683abd68bb26ea760621cffad0e693d` |
| `lib/screens/profile/settings/bodypart_ranking_screen.dart` | `5670d025727d0509c24bf79a3a0065e5977bb000b7b6a24071db98313a7bd82d` |
| `lib/screens/profile/settings/database_settings_page.dart` | `3fc1dbce43e461c1a2ca28265dfbaf7ff2690747ceecd0a34effef68cf7a10d1` |
| `lib/screens/profile/settings/exercise_analytics_screen.dart` | `f549daecfa690baaa47b5a694d447e7dc97de70b90e56be3ad77e5805eeee7d2` |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | `6109c2e78dba7d42bc3d1d82ff0d6ede6011a2cb7dc23f39dd9756b229c5183e` |
| `lib/screens/profile/settings/flow_methods_page.dart` | `bee8c05d0943848f7c7c6960a5e5660ee2b2f5dd9958884c8d755092f5a48f81` |
| `lib/screens/profile/settings/muscle_ranking_screen.dart` | `ee2c1b121015205fc0197475970b32ffab7565fb6ae00f82342508735bc30f9b` |
| `lib/theme/widgets/tonos_dialog.dart` | `342ac5fb41899183363817366512d1aee685517b668d720fd02d818a5346c883` |
| `lib/widgets/add_exercise_fab.dart` | `42310ff18b5a7ac06e01614911bb11521e64853d607c3a7751f266a7b4207c66` |
| `lib/widgets/dashboard_sections.dart` | `cb9f8ea61dd3dbbeb1382fb671261c76ab94706f705ca0e18a8d38dadd336ea5` |
| `lib/widgets/exercise_definition_info_tile.dart` | `eb5ccb7bfe1530bbbf07db506b926f0d3adea091621f6e40ba71d624d2f673ab` |
| `lib/widgets/exercise_progress_section.dart` | `85ffc6e33ba870353fcda142cae7b6c2331c6f98e2e28358503cd3cb69646838` |
| `lib/widgets/health_trends_section.dart` | `0f8ff4bce380029687817646b0bd4fbf6d5c1b9e772c0797feb8033d3f5895ba` |
| `lib/widgets/settings_tiles.dart` | `01b99c2bd6acb8e6677a691aedd8781db69bd18258a56a7ffd1ad4d35ce2c4e0` |
| `lib/widgets/swap_exercise_sheet.dart` | `dd189f5b4dc47e149b41dad9dab75f2027167309f265b6d366a9c390c30b2e05` |
| `lib/widgets/weight_card.dart` | `3e545ec510601bf442452a2f978b16a84902643770de931c881fe48fbd1555dd` |
| `test/expressive_catalog_browser_presentation_test.dart` | `e73f0c6392192b8b8f267050d305fa8ad3cbc76800d2b3548b5b293b5b0ad77f` |
| `test/theme/expressive_interaction_route_contract_test.dart` | `a4502b90dea838ecebe6c4f22d151e20f8e94246abbe39685a5fa8648db2720c` |
| `test/theme/widgets/analytics_destination_routes_test.dart` | `b1d4f577d16e46f19652ab43adab8ae67a0f6664264be2f8577e65c61207e40e` |
| `test/theme/widgets/analytics_ranking_label_contract_test.dart` | `765b0371e76c24116c971f92e15c99e3a0cfe1035cbfc3168243d1257d7ff2c5` |
| `test/theme/widgets/analytics_ranking_label_responsive_test.dart` | `40cd67799b2ecd2a3fb0f480f1331106acf30fa9e1183c8455b63464c3f631be` |
| `test/theme/widgets/anatomy_routes_theme_test.dart` | `4c83819a1532798dd3f632b90c9a4db6a227b588e0c46e17c39074ba1efb6b45` |
| `test/theme/widgets/auto_preset_flow_panels_golden_test.dart` | `15a3a6923e45d3124158ea127c7891b739963a0effe43f9d378cfe6d1db04b7a` |
| `test/theme/widgets/auto_preset_flow_screen_theme_test.dart` | `2941ec4c83072eb0c4e4dd05b97314cdb07ca55a14fc18585b024e33b80181e2` |
| `test/theme/widgets/exercise_analytics_screen_theme_test.dart` | `93e2ca93260e01d2bace22b908f2f86819ab6e0f8aef5e8a5b68b670f1e55c71` |
| `test/theme/widgets/exercise_editor_expressive_interaction_test.dart` | `f04f14f9683bdb4b144e5648adaebcac157bef8a0f91b556c7a04fe813340c17` |
| `test/theme/widgets/exercise_editor_expressive_presentation_test.dart` | `a1535cedc65ba2a57df28216d97981f47d1f0938fc1df51b2300f50c8f085899` |
| `test/theme/widgets/exercise_progress_catalog_route_test.dart` | `731eecbb2a83450924e9244b5e6597980e0d7e376337b035eb6720bc887c856a` |
| `test/theme/widgets/flow_methods_page_refinement_test.dart` | `520a1d098f98dd398a35fdf299dec67968e26cf16eff051e4f19fa2a0896dad0` |
| `test/theme/widgets/health_trends_chart_accessibility_test.dart` | `590fd873c3007a8c243e98c5ed80fb017255204956d36c7108ad2cc9c413df05` |
| `test/theme/widgets/onboarding_expressive_presentation_test.dart` | `d1e3220fd963aece828e120edfa804bba00c1f72f71c5344cf67c19d16f2046c` |
| `test/theme/widgets/optimized_workout_settings_fields_theme_test.dart` | `e1adc593750612d12f6fada5a59d31fdb993cbec1153b0c75fd920210f2ece1d` |
| `test/theme/widgets/preset_detail_screen_theme_test.dart` | `f345ec77700223d177ad1535ecb3bd36b1531c7d224a92e03d9f6fc8bf1af286` |
| `test/theme/widgets/profile_analytics_dropdown_interaction_test.dart` | `1cd1ad2d50a4e5cd1d1bbe1530a5249746d85f671633ccbe11a64c9928f4da2b` |
| `test/theme/widgets/settings_pending_routes_theme_test.dart` | `15132afe901f0b561590602c15e99f406da7fae5b9ed9d909a6db6577292c3cb` |
| `test/theme/widgets/tonos_dialog_test.dart` | `d6b721e2c631f2e7cd3a5fe255297e065e9d033b5ed5cf83b2b4a5943dac4075` |
| `test/theme/widgets/weekly_set_analytics_theme_test.dart` | `43e01dc3adb7c5cd9e67c71ebf4678984fd2d113cba6b121a20996ce2f1b966e` |
| `test/theme/widgets/weight_card_theme_scope_test.dart` | `a26ad5854baf794b0767fe60e3ac05083bfca812ecd6b06acc9efe6b95db195d` |

The October 12 source delta since the October 10 snapshot is limited to
`lib/screens/onboarding_flow.dart`,
`test/theme/widgets/onboarding_expressive_presentation_test.dart`, and the
tracked route-component ledger. Other dirty and untracked files are retained;
the manifest above describes all changed/untracked Dart paths, not authorship
or a claim that every path belongs to one remediation change.

### Build, device, data, and validation status

- Latest known preview/device build: October 11, APK SHA-256
  `91AFB3AE4E7171D2F2A7E1E144756A6C75C88B89B9161D66EF7E41C39345DCB3`, package
  `com.tonos.expressivepreview` on Pixel 7 `28021FDH200228`. It predates the
  October 12 onboarding source change and is **not current-source evidence**.
- The latest fully indexed standard screenshot set remains the October 10
  build documented below. No build or screenshot was made after the onboarding
  change; therefore the current dirty tree has no matching device evidence.
- The isolated preview database and preferences were backed up, restored, and
  hash-verified after the October 11 device audit. They were not re-read on
  October 12, so that is the latest verified preservation point, not a new
  verification today. The production package/data were not touched.
- Latest focused follow-up: **67 tests passed across seven files**. Onboarding
  scoped analysis was clean; Flow Methods reported two informational Radio
  deprecation notices and no errors/warnings. No full suite, full analyzer,
  build, or device run followed that source change.
- Five current B visual-review candidates remain in order: Onboarding; Preset
  Generation QA; Analytics Dashboard / Weekly Sets Overview; Dashboard root;
  plan-specific Flow Methods editor. The 55-archetype aggregate remains
  unreconciled because the existing C/D route tables do not map uniquely to
  the denominator. The separate 24-route dossier remains 15 approved / 9
  pending. No approval changed in the October 12 follow-up.

## Historical candidate snapshot — 2026-10-10

The following details describe the October 10 state only.

### Git state at the historical snapshot

- Original branch: `feature/classic-m3e`.
- Original HEAD before the preservation checkpoint:
  `ab18ed8cab5582c8449e13724afae3c4b74ebeea`.
- Pushed preservation checkpoint:
  `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f` — `checkpoint: preserve Tonos
  Expressive visual review and audit baseline`.
- `origin/feature/classic-m3e` was verified at that checkpoint after push.
- Candidate branch: `feature/expressive-visual-polish`, at the same baseline
  HEAD; no upstream is configured.
- Candidate source tree is dirty with 10 production source and 9 focused test
  files (19 modified tracked Dart files total). The index is empty. Numerous
  unrelated/untracked user artifacts remain in place and were preserved. No
  reset, clean, stash, remediation commit, or remediation push was performed.
- The malformed local Codex checkpoint ref was not touched.

### Candidate input fingerprint at the historical snapshot

Fingerprint algorithm: sort the 19 repository-relative changed Dart paths,
write each `path<TAB>lowercase-file-SHA256` record followed by LF, then
SHA-256 the UTF-8 manifest bytes. This is a fingerprint of the listed source
and test inputs, not the full repository.

`185de3f7a36a5c38c1ee41e76079295b5450e950f6c089f33b27032a683712b4`

| File | SHA-256 |
| --- | --- |
| `lib/screens/exercise/analytics_dashboard_screen.dart` | `1f5de13de33c71db65cb1744b96cc45f68fc0e80875ad9210144ea19748b480a` |
| `lib/screens/exercise/definitions_by_bodypart_page.dart` | `e2bd3097c97c305a8c016616d4dcfa73b2549cefad3890ee8535546116510443` |
| `lib/screens/exercise/definitions_by_muscle_page.dart` | `13d59bcbc032551ef0c9ace1399b63562b0eed4c5e5361540c8f6123b73df40f` |
| `lib/screens/exercise/optimized_workout_settings_page.dart` | `a16ab744d8e1ef38e1fcf8b8dbd2bf44337880be34d16bdf398407b36796bf34` |
| `lib/screens/onboarding_flow.dart` | `f5db0bd3c0f4695ac9f6edf2742442fa30e6abee47578088ca99010c4a7c6ea8` |
| `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart` | `a3fe7f41d255e980c8ce0fc46f0396976b79e85c1ffe51a45ca196ac467420ff` |
| `lib/screens/profile/settings/database_settings_page.dart` | `0aaa4924b498f2994514d7a608696014d676b9a63189a92e438a98c5f6b61a6d` |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | `19e0095ba378117d428201eb3fc16783ac142533b69b5ccbcdbba277fa77a4a4` |
| `lib/screens/profile/settings/muscle_ranking_screen.dart` | `d4ecc5f1caa5f058e510201d1596d42c41ecc849a550d43b7e2b4f3f830829dc` |
| `lib/widgets/exercise_definition_info_tile.dart` | `eb5ccb7bfe1530bbbf07db506b926f0d3adea091621f6e40ba71d624d2f673ab` |
| `test/theme/widgets/analytics_destination_routes_test.dart` | `8b21bd344d747c54120caf6b4edfd03fdd66e875ae3a5a9e925d79d20fafa966` |
| `test/theme/widgets/analytics_ranking_label_contract_test.dart` | `34eec788bb244004ac80c891b1728b760a7857e88face6663d7b80edd54e8e71` |
| `test/theme/widgets/analytics_ranking_label_responsive_test.dart` | `40cd67799b2ecd2a3fb0f480f1331106acf30fa9e1183c8455b63464c3f631be` |
| `test/theme/widgets/anatomy_routes_theme_test.dart` | `4c83819a1532798dd3f632b90c9a4db6a227b588e0c46e17c39074ba1efb6b45` |
| `test/theme/widgets/exercise_editor_expressive_presentation_test.dart` | `8e2f214055c95cb86e5e897da5874c020ff5a9a6552c52df22ea5bb34e9ada94` |
| `test/theme/widgets/onboarding_expressive_presentation_test.dart` | `9aff512ea527ae1790869672f3b6e7cdf6a4f8a7f68e083312775b82d0869306` |
| `test/theme/widgets/optimized_workout_settings_fields_theme_test.dart` | `e1adc593750612d12f6fada5a59d31fdb993cbec1153b0c75fd920210f2ece1d` |
| `test/theme/widgets/settings_pending_routes_theme_test.dart` | `0e486a2a41d1f61cc2726969db7e862a8f4f8c43b53a217885530874b09bc170` |
| `test/theme/widgets/weekly_set_analytics_theme_test.dart` | `43e01dc3adb7c5cd9e67c71ebf4678984fd2d113cba6b121a20996ce2f1b966e` |

## Standard candidate APK — 2026-10-10 historical build

- Flutter 3.47.5; bundled Dart 3.13.4. Subprocess PATH placed the bundled Dart
  3.13.4 directory first; TEMP/TMP remained under `C:\Users\talh7\AppData\Local\Temp`.
- Device verified at runtime: Pixel 7, ADB serial `28021FDH200228`, model
  `Pixel_7`, 1080×2400 physical pixels at 420 dpi (approximately 411×914 dp).
- Debug APK built from the dedicated isolated preview entrypoint
  `lib/expressive_preview_main.dart` and candidate source. Preview defines:
  `TONOS_EXPRESSIVE_PREVIEW=true`,
  `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`,
  `TONOS_ANDROID_INTERNAL_BUILD=false`,
  `TONOS_DATABASE_NAME=tonos_expressive_preview.db`, and
  `TONOS_PREVIEW_SHOW_CONTROLS=true`.
- Installed APK: `E:\projects\env_test\build\app\outputs\flutter-apk\app-debug.apk`.
  APK size: 233,544,099 bytes. SHA-256:
  `2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7`.
- Installed with `adb install -r` as `com.tonos.expressivepreview`, using
  database define `tonos_expressive_preview.db`. The normal Tonos package and
  database were not launched or modified.
- The earlier build `bbd53b9c` used the wrong entrypoint and is retained only
  as a labeled diagnostic; it is excluded from current evidence. The final
  build-2e4a2bd4 Pixel 7 captures are indexed in
  [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).

## Onboarding bootstrap evidence — 2026-10-10 historical capture

The preview database bypasses the first-run gate. A separate capture-only APK
used a temporary route hook in `main.dart` to enter onboarding; its UI source
was the candidate `onboarding_flow.dart` listed above. No fixtures were seeded
and no data-reset callback was used. The route hook was removed and
`main.dart` has no diff. Bootstrap APK SHA-256:
`4de75f5e0ebbb8b79385519a033f5b7722731cfa3f0c9e981910ec29de7b4ca1`.
Onboarding images are kept in a clearly separate subfolder and are not claimed
to come from the standard APK's normal launch path.

## Preview data restoration — 2026-10-10 historical verification

Before app interaction, the isolated preview database files and preferences
were backed up under
`%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\preview-state-before-latest-20261010\`.
After captures, the preview process was force-stopped and the saved bytes were
restored through `adb exec-in`/`run-as`; the app was not relaunched afterward.
Device SHA-256 verification matched each backup:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `databases/tonos_expressive_preview.db` | 1,572,864 | `36d3898d86661262e543865068ee9e727d7a8adbe76c23b02aff0a502f81384c` |
| `databases/tonos_expressive_preview.db-shm` | 32,768 | `32fb8898a7a4f95cd09d8e4f2c4e56218bd2b36f32702f503676ec9b5c5f7a8a` |
| `databases/tonos_expressive_preview.db-wal` | 391,432 | `c5b7d859406b807ad84a0793c0295a61b2257819f6ee8ee94ac668df54b94c0e` |
| `shared_prefs/FlutterSharedPreferences.xml` | 12,193 | `15b968b0a17bb72d0b3990da7e8c597ad088132f9fb54e6fb1cf50af68a343ff` |

## Validation result — 2026-10-10 historical run

- Final focused combined run: 63 passed, 0 failed across five test files.
  Additional individually targeted runs covered onboarding, Database
  Settings, Exercise Editor, analytics route ownership, and Optimized Workout
  Settings; do not sum overlapping runs as unique tests.
- Full `flutter test --no-pub`: 1,809 passed, 20 failed, 0 skipped, exit code
  1. Seventeen inventory/ownership contract tests, two Flow Editor goldens,
  and one Profile Analytics dropdown interaction assertion failed. The full
  test log is local under `%LOCALAPPDATA%\Temp\tonos-expressive-visual-remediation\`.
- Full Flutter analysis: 0 errors, 0 warnings, 79 informational deprecation
  notices; exit code 1 because info diagnostics are present.
- Focused `dart analyze` over 11 selected changed Dart files: 0 errors, 0
  warnings, 4 informational deprecation notices.
- Formatting check across 19 changed Dart files returned exit 1 because four
  long-form files would be reformatted; they were left otherwise narrowly
  scoped. `git diff --check`: passed with existing Git line-ending notices.
- Theme-style inventory `--check`: exit code 0, 0 unassigned candidates.
  The report shows 16 pending candidates without a review queue and 2,110
  candidates outside configured queues; those coverage gaps are not enforced
  by this check mode.
- Theme-style ratchet enforcement: exit code 64 with 22 fingerprint
  mismatches (15 bottom navigation, 7 `exercise_definition_info_tile.dart`).
  No baseline update was performed.
- No remediation commit or push was made. Candidate routes remain unapproved
  unless separately recorded by the user in the authoritative approval ledger.
