# Testing Tonos

The automated suite is organized by the behavior it protects, rather than by
screen name:

Flutter owns the formatting of files under `lib/l10n/generated`. Regenerate
them with `flutter gen-l10n` and check for drift directly; do not run
`dart format` on that directory before the cleanliness check.

- `test/models` verifies immutable models and manifest parsing.
- `test/utils` verifies unit conversion, generated-weight helpers, flow
  traversal, and concurrency behavior.
- `test/providers` verifies SharedPreferences-backed app configuration.
- `test/theme/app_theme_tokens_test.dart` verifies complete Classic token
  registration, focused flow/nutrition roles, and ThemeExtension behavior.
- `test/theme/app_material_theme_test.dart` verifies the shared Material
  baseline and its light/dark surface, sheet, dialog, divider, and FAB roles.
- `test/theme/app_colors_compatibility_contract_test.dart` scans all production
  code and prevents any legacy `AppColors` or `context.colors` dependency from
  returning.
- `test/theme/theme_style_inventory_contract_test.dart` validates the
  report-only structural-style manifest and confirms every production style
  candidate has an explicit classification and migration destination.
- `test/theme/widgets/tonos_segmented_action_bar_test.dart` verifies the
  shared shell action-bar shape, semantics, and callback behavior.
  surface/shape recipes, value-text styling, form-decoration token
  resolution, save-bar/status-badge recipes, callback/surface behavior, and
  action callbacks.
- `test/theme/widgets` verifies Tonos primitive recipes, callbacks, semantics,
  and token-driven rendering.
- `test/providers/durable_active_session_test.dart` covers workout-draft
  restoration and bounded save retries, including progression recovery after a
  completed session survives a storage failure.
- `test/services` verifies content configuration and platform-download policy.
- `test/services/safe_failure_test.dart` verifies privacy-safe failure
  classification and retryability without retaining exception details.
- Cloud-content boundary tests also cover HTTPS/redirect policy, integrity
  metadata, corrupt and interrupted streams, orphan pruning, and LRU limits.
- `test/db` runs selected DAO contracts against in-memory SQLite.
- `test/db/gym_profile_equipment_query_test.dart` verifies that profile
  equipment hydration retains the stable catalog ID needed by localized UI.
- `test/db/definition_dao_equipment_hydration_test.dart` verifies that full
  and by-ID detailed definition loads retain stable equipment and muscle IDs,
  and that immutable exercise catalog IDs resolve detailed definitions.
- `test/db/catalog_entity_identity_migration_test.dart` verifies v62 identity
  schema behavior and that real equipment/muscle renames become custom values
  without stripping identity from no-op saves.
- `test/widgets/localized_catalog_entity_name_test.dart` verifies built-in
  muscle translation, custom-name fallback, and locale switching.
- `test/widgets` smoke-tests reusable user-interface components and their
  accessibility actions. `visual_layout_contract_test.dart` exercises the
  release layout matrix across representative phone/tablet, locale, and
  enlarged-text configurations.
- `test/widgets/safe_error_view_test.dart` verifies localized recovery copy,
  semantic retry actions, non-retryable states, and redacted action snackbars.
- `test/localization/hardcoded_ui_copy_contract_test.dart` rejects direct
  user-facing English literals in active screens and widgets. Deliberately
  deferred nutrition, cardio/stretch, and placeholder surfaces are narrowly
  excluded until those product areas are rebuilt.
- `test/localization/reviewed_english_values_contract_test.dart` keeps the
  reviewed-identical-English policy synchronized with every ARB locale and
  rejects newly copied English values without an explicit review reason.
- `test/localization/arb_structure_contract_test.dart` keeps message keys,
  locale tags, non-empty values, and runtime placeholders aligned across every
  ARB file.
- `test/utils/localized_formatters_test.dart` verifies locale-aware calendar
  periods, dates, times, numbers, percentages, compact values, and the
  Western-digit Bangla policy.
- `test/widgets/workout_record_badges_test.dart` verifies visible record-badge
  labels refresh when an already-open widget changes locale.
- `test/utils/weight_unit_formatter_locale_test.dart` verifies localized
  display separators without changing canonical input formatting.
- `test/localization/safe_error_handling_contract_test.dart` rejects raw
  exception interpolation, `toString()` rendering, and raw load/save error
  state in active UI code.
- `test/premade_plan_exercise_catalog_contract_test.dart` verifies every
  built-in premade-plan exercise and equipment row resolves to the current
  catalog by stable identity, while
  `test/localization/premade_plan_arb_contract_test.dart` protects the
  parameterized derived-plan message in every supported locale.
- `test/services/premade_plan_localizer_test.dart` verifies direct plan-ID
  parity, exact regional fallback, malformed-bundle rejection, safe fallback
  behavior, and localized one-hour plan descriptions.
- `integration_test` runs device-level core flows against an isolated database.
  Its core suite drives plan creation, workout start/resume/exit/completion,
  record presentation, Save as plan, profile editing, and database
  export/import through the real UI. Repository calls are limited to fixture
  setup and persisted-result assertions.

Run the complete suite from the repository root:

```powershell
flutter test
```

Generate the structural-style inventory from the repository root:

```powershell
dart run tools\theme_style_inventory.dart --check
dart run tools\theme_style_inventory.dart --format json --output build\theme-style-inventory.json
```

The inventory is report-only while existing release-surface migration is in
progress. CI rejects malformed inventory configuration or unassigned findings
but does not reject the existing `pending` style candidates.

Run a focused test file while developing a feature:

```powershell
flutter test test\services\flow_executor_test.dart
```

## Latest Neo Visual-Review Verification

On 2026-09-16, the user accepted all 21 entries in the current Neo visual
review. The final bright-field selector contrast correction was then verified
with successful formatting of its three changed sources, clean targeted
analysis, and 63 passing tests across `settings_tiles_test.dart`,
`neo_refinement_regression_test.dart`, `step17_consumer_parity_test.dart`, and
`pre_q2_route_evidence_test.dart`. This is scoped automated evidence plus
manual visual acceptance, not a substitute for the remaining N5 route-state or
N6 device/accessibility qualification.

On 2026-09-17, the user confirmed item 20, Guided Tutorials, after Neo light's
tutorial-card icon and progress count were corrected for the cream surface.
Items 1-21 are now visually accepted. The fix is covered by
tutorial_presentation_test.dart.

The user subsequently confirmed every item in the consolidated human/device/N6
qualification checklist for the current working tree. This records current
development qualification for route states, accessibility, keyboard and
large-text behavior, switching, persistence, media/scanner lifecycle, and
affected Classic parity. It is user-reported evidence, not a new automated run
or signed-release approval; Step 15 remains separate.

## Latest deterministic localization verification

On 2026-09-03, the recorded localization verification regenerated the ARB
sources, formatted the generated Dart output, and passed the targeted analyzer
run. The focused Flutter run covered ARB structure, reviewed-identical-English
policy, localization smoke, premade-plan localization, locale-aware
formatters, record badges, and workflow policy: `00:09 +31: All tests passed!`.
`git diff --check` reported no content errors; its only output was the expected
LF-to-CRLF working-tree warning. This proves deterministic resource and code
contracts, not native-speaker approval or the final physical-device review.

## Experimental navigation

`Nutrition Log`, `Combined History`, and `Form and Posing` remain available
for development, but cannot appear in a release build. Debug builds expose
them through **Profile > UI & appearance > Edit bottom tabs**. Profile builds
start with them hidden unless explicitly enabled:

```powershell
flutter run --profile `
  --dart-define=TONOS_ENABLE_EXPERIMENTAL_TABS=true
```

Release builds always exclude those tabs, even if that define is passed. This
protects restored navigation preferences as well as the visible bottom bar.

## Device, visual, and accessibility QA

Use [device-visual-accessibility-qa.md](device-visual-accessibility-qa.md) for
the automated layout matrix, TalkBack/device release checklist, and the
reviewed process for introducing stable pixel baselines. The first layer uses
layout and semantic contracts rather than screenshot comparisons so ordinary
design work does not cause device-specific golden churn.

## Locale visual QA

Automated localization tests prove that messages resolve and that selected
high-risk layouts can reflow. They cannot judge readability, clipping within
real scrolling screens, font rendering, or visual hierarchy on a device. Run
this manual pass before calling a new locale release-ready.

Use a physical Android device at its normal display size, then repeat the
high-risk screens with Android font size increased to the largest practical
setting. Start the app with:

```powershell
flutter run -d <android-device-id>
```

Select each language from **Profile > UI & appearance > Language**. For the
onboarding check, enable **Replay onboarding** in the same settings page,
return to the app root, and restart the app. Test Bangla (Bangladesh),
Simplified Chinese, Hindi, and Spanish individually. After each language, use
English briefly as a visual baseline: localization must not change the
established English layout or interaction behavior.

| Surface | Verify |
| --- | --- |
| Onboarding | Welcome-language dropdown, personal information fields, gym/equipment choices, plan overview, and summary remain readable, scroll correctly, and keep the primary action reachable. |
| Train and plans | Overview/Plans tabs, generated-plan cards, plan editor, and long exercise names have no overlap, clipped controls, or inaccessible actions. |
| Session and completion | Set inputs, exercise thumbnails, record badges, completion sheet, and Save as plan show complete labels and values. |
| Logbook, records, and reports | Newest-first session list, historical record badges, workout-detail rows, charts, and range controls remain legible and tappable. |
| Profile and settings | Profile sections, UI & appearance language dialog, tutorials, database settings, and Diagnostics & privacy retain hierarchy and allow scrolling to every action. |
| Accessibility | At enlarged text size, no essential control is hidden, labels are not unintentionally truncated, and TalkBack names still describe icon-only actions. |

Record the locale, device model, Android version, font-size setting, affected
screen, and a screenshot for every issue. A locale passes when the normal and
enlarged-text checks complete without visual defects or functional regressions.

Run the Android core-flow suite on a connected device:

```powershell
flutter test integration_test\core_flows_test.dart `
  -d <android-device-id> `
  --dart-define=TONOS_INTEGRATION_TEST=true `
  --dart-define=TONOS_DATABASE_NAME=tonos_integration_test.db
```

## Neo internal Android release candidate

The 2026-09-22 candidate adds `TONOS_ENABLE_NEO_RELEASE=true` and uses
`1.0.1+6`. It targets Android internal/closed testing with the already verified
development media manifest v15 (253 thumbnails and 47 heatmap fallbacks).
Classic remains the initial family; both Neo brightness modes are selectable.
The internal APK uses the separate `com.tonos.internal` application ID and
`Tonos (Internal)` launcher label so it installs alongside a differently
signed `com.tonos` app without replacing or erasing its data.
The user authorized implementing the opt-in and accepted the signed internal
candidate on 2026-09-23 after confirming all six focused device checks below.
Existing visual, N5/N6, route, and locale acceptance applies to unchanged
surfaces. This acceptance is limited to the identified Android internal/closed
candidate and is not approval for open testing or a Play Store release.

### Build and automated evidence

Run this in PowerShell and paste the complete result:

```powershell
Set-Location E:\projects\env_test
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify_neo_release.ps1 -BuildOnly
```

The script formats/analyzes the changed Dart files, exercises the family policy,
settings selector, persistence, Classic restoration, renderer and workflow
contracts, and verifies actual compiled enabled/disabled/invalid flag values.
The theme-policy tests and analysis passed in the previous run. `-BuildOnly`
reuses that result, restarts idle Gradle daemons so the internal package setting
is read by a fresh daemon, and builds a signed release APK with a separate
internal application ID and:

- `TONOS_ENABLE_NEO_RELEASE=true`
- `TONOS_ENABLE_EXPERIMENTAL_THEMES=false`
- `TONOS_ENABLE_EXPERIMENTAL_TABS=false`
- `TONOS_CONTENT_ENVIRONMENT=development`
- `TONOS_CONTENT_ALLOW_OVERRIDES=false`
- Gradle environment `TONOS_ANDROID_INTERNAL_BUILD=true`

The script verifies the APK signature, internal package/label/version,
non-debuggable status, and Internet permission. It records the base commit,
working-tree status, flags, APK SHA-256, and device status at build time in
`build/content/neo_internal_release_candidate.json`. Unit/widget tests inject
release policy; only the resulting APK provides actual Android release-mode
evidence. No upload, installation, uninstall, or Play Store publication occurs.

Local `android/key.properties` exists at preparation time. The build must use
the established release key. If signing fails, supply only the error message;
do not paste passwords, signing configuration contents, or keystore files.

### Install and identify

Install the candidate beside the existing app. The distinct internal ID keeps
the existing `com.tonos` package and its data intact. Re-running this install
updates only the internal candidate, signed with the same established release
key:

```powershell
Set-Location E:\projects\env_test
& 'E:\Android\Sdk\platform-tools\adb.exe' devices
& 'E:\Android\Sdk\platform-tools\adb.exe' install -r 'build\app\outputs\flutter-apk\app-release.apk'
if ($LASTEXITCODE -ne 0) { throw 'Internal candidate install failed. Keep the existing app and paste the error.' }
& 'E:\Android\Sdk\platform-tools\adb.exe' shell dumpsys package com.tonos.internal |
  Select-String 'versionCode=|versionName=' | Select-Object -First 2
& 'E:\Android\Sdk\platform-tools\adb.exe' shell getprop ro.product.model
& 'E:\Android\Sdk\platform-tools\adb.exe' shell getprop ro.build.version.release
& 'E:\Android\Sdk\platform-tools\adb.exe' shell getprop ro.build.version.sdk
```

Expected installed version: `1.0.1`, code `6`. With multiple connected
devices, add `-s DEVICE_SERIAL` immediately after each adb executable.
If installation fails, stop and report the error. The original `com.tonos` app
should remain installed and usable; do not uninstall it.

### Focused signed-device acceptance

1. [x] Open **Tonos (Internal)**. On a fresh test installation, Classic is the
   default. On an update of the internal app, the saved eligible family/mode
   should return. Confirm no debug banner or floating debug theme toolbar, no
   blank startup, and that the original app and its data remain intact.
2. [x] Open Profile > UI & Appearance > Theme family. Select Neo-Brutalism through
   this normal settings control. Turn the Dark mode switch off for Light and
   on for Dark. Confirm both render, the selected family radio state is correct,
   and no restart is required. This screen currently exposes a Dark mode switch,
   not a System-mode selector.
3. [x] With Neo selected, force-stop Tonos through Android App info, then reopen it.
   Confirm family and mode persist. Switch back to Classic, repeat the restart,
   and confirm Classic persists too. Select Neo again and enable airplane mode:
   family/mode switching must work without a network connection.
4. [x] Restore connectivity and open Catalog > Exercise Catalog. Inspect a known
   thumbnail entry (for example External Rotation - Dumbbell) and its expanded
   anatomy heatmap. Inspect Cuban Rotation or another uncovered entry's
   fallback. Check visible target highlights in Neo dark/light, image loading,
   and the same routes after returning to Classic. A heatmap for an exercise
   among the 47 missing thumbnails is expected.
5. [x] In Train, start a short test session, edit a set, and complete it. Confirm the
   completion sheet works and the result is visible in Logbook. Scroll the
   catalog and switch families several times: report crashes, hangs, new
   clipping, or noticeably worse switching/scrolling than the accepted build.
6. [x] Return to UI & Appearance with large Android font size and TalkBack enabled.
   Open the family dialog, confirm options and selected state are announced,
   choose each family, close the dialog, and verify controls remain reachable.
   Restore your normal accessibility settings afterward.

These are checks of the signed artifact and the changed eligibility path; the
previous 21-item visual review does not need to be repeated. Keep existing
placeholder routes/navigation gating and owner-accepted translations as the
documented internal limitations.

User confirmation received on 2026-09-23: all six focused device checks passed
with no failures reported. The accepted APK is `com.tonos.internal`, version
`1.0.1+6`, SHA-256
`549BE2C9EDD96E44840C7E42976BDF436C29B3F53DC9C946FA043EB3EC68615D`. The build
was based on source commit `55b0222071645392e1c66d5e01c5f8b3eaf10f11` with
additional working-tree changes. Commit the exact tested source and associate
that commit with the APK hash before closing the internal Step 15 gate. The
user-supplied install output reported successful v1/v2 signature checks and
installation alongside the original app. Any source change after acceptance
requires a fresh APK and affected checks.
Open testing, Play Store launch, and production-content promotion remain later
decisions.

## Release networking verification

Flutter Driver does not support release mode on Android. Verify release cloud
networking with two complementary checks instead:

1. Build the release APK and inspect its packaged permissions:

```powershell
flutter build apk --release `
  --dart-define=TONOS_CONTENT_ENVIRONMENT=development `
  --dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false

$apkanalyzer = "E:\Android\Sdk\cmdline-tools\latest\bin\apkanalyzer.bat"
& $apkanalyzer manifest permissions `
  build\app\outputs\flutter-apk\app-release.apk |
  Select-String "android.permission.INTERNET"
```

2. Run the core-flow suite in profile mode. The suite resets only
   `tonos_integration_test.db` and requires nonempty exercise and shared-media
   rows after startup, proving that a fresh database can fetch both configured
   remote manifests:

```powershell
flutter drive `
  --driver=test_driver\integration_test.dart `
  --target=integration_test\core_flows_test.dart `
  -d <android-device-id> `
  --profile `
  --dart-define=TONOS_INTEGRATION_TEST=true `
  --dart-define=TONOS_DATABASE_NAME=tonos_integration_test.db `
  --dart-define=TONOS_CONTENT_ENVIRONMENT=development `
  --dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false
```

The integration setup clears app SharedPreferences, so run it on a development
device or emulator where resetting Tonos settings is acceptable.

## Content environment verification

The bundled configuration and build target are separate contracts. Validate the
configuration directly before building:

```powershell
dart run tools/content_environment_check.dart `
  --source assets/content/content_environments.json `
  --target development

dart run tools/content_environment_check.dart `
  --source assets/content/content_environments.json `
  --target production `
  --locked
```

The focused compile-time test is run once for locked development and once for
locked production. It proves saved/custom preferences cannot redirect a release
artifact:

```powershell
flutter test test/services/content_environment_compile_time_test.dart `
  --dart-define=TONOS_CONTENT_ENVIRONMENT=development `
  --dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false `
  --dart-define=TONOS_EXPECTED_CONTENT_ENVIRONMENT=development `
  --dart-define=TONOS_EXPECTED_CONTENT_OVERRIDES=false

flutter test test/services/content_environment_compile_time_test.dart `
  --dart-define=TONOS_CONTENT_ENVIRONMENT=production `
  --dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false `
  --dart-define=TONOS_EXPECTED_CONTENT_ENVIRONMENT=production `
  --dart-define=TONOS_EXPECTED_CONTENT_OVERRIDES=false
```

Ordinary debug tests intentionally retain runtime overrides so developer UX does
not change. CI builds its disposable release APK against locked development;
the protected production workflow preflights and builds locked production.

## Continuous integration

`.github/workflows/ci.yml` runs for pull requests targeting `master`, pushes to
`master` and the approved feature-branch prefixes, and manual dispatches. It
installs the pinned Flutter SDK, regenerates localization sources, fails if the
tracked generated files change after canonical Dart formatting, analyzes application and test code, analyzes
the content pipeline and nested catalog builder, validates catalog and media
fixtures, preflights the development content target, runs the complete
unit/widget suite, verifies the locked compile-time policy, and builds an
explicitly locked development release APK.

External Actions are pinned to immutable commit SHAs, checkout credentials are
not retained, and Dependabot reviews Action pins weekly. The stable checks
required before merging are `Localization, analyzer, and tests` and `Release
APK`. See [branch-and-ci.md](branch-and-ci.md) for branch naming, the pull
request workflow, and the exact `master` ruleset.

The CI release APK is signed with a disposable key generated during the job. It
proves that the release variant compiles, but it is not a production-signed or
distributable artifact. Successful APKs are retained as workflow artifacts for
seven days to aid investigation.

`.github/workflows/android-device.yml` runs weekly and can also be started with
`workflow_dispatch`. It boots a clean API 35 Android emulator and runs
`integration_test/core_flows_test.dart` against the isolated integration-test
database. The emulator job uses debug mode because Android emulators do not
support Flutter's profile/release device-test modes. Continue using the
physical-device profile command above when validating release networking and
performance before a release.

For every new user-visible feature, add at least one test at the lowest useful
level: pure model/utility first, then DAO/service, then widget or integration
coverage when interaction or persistence is involved. Avoid network calls,
real device storage, and production content URLs in ordinary tests; use bundled
assets, SharedPreferences mocks, in-memory SQLite, or a mocked platform channel.
The profile-mode release-networking verification above is the intentional
exception and uses the configured development content environment.

## Localization review

The literal-copy contract test covers active screens and shared widgets,
including direct and conditional text, dialogs, empty states, tooltips, and
semantic labels. Incomplete product surfaces remain narrowly excluded until
they are ready for localization as a complete feature: nutrition, cardio,
stretch, the alternate Train hub, combined history, and form/posing.

Automated checks and visual QA do not constitute linguistic approval. Follow
the native-speaker scope, acceptance criteria, and review log in
`docs/localization-review.md` before describing a non-English locale as
release-ready. The source-by-source remaining work and release completion gate
live in `docs/localization-remaining-inventory.md`. The latest automated pass
also corrected and contract-checked Canadian-French placeholders in logbook,
anatomy, and ranking messages; those corrections still require linguistic
review.

## Release diagnostics verification

Production builds intentionally do not configure direct remote crash reporting.
The unit and contract tests verify the disabled default, bounded local sync
history, the absence of a remotely routable DSN in the signed-release workflow,
and the retained redaction boundary for any future privacy-relay integration.
See `docs/release-diagnostics.md` for the current release posture and relay
requirements.
