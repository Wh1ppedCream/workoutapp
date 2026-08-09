# Testing Tonos

The automated suite is organized by the behavior it protects, rather than by
screen name:

- `test/models` verifies immutable models and manifest parsing.
- `test/utils` verifies unit conversion, generated-weight helpers, flow
  traversal, and concurrency behavior.
- `test/providers` verifies SharedPreferences-backed app configuration.
- `test/services` verifies content configuration and platform-download policy.
- `test/db` runs selected DAO contracts against in-memory SQLite.
- `test/widgets` smoke-tests reusable user-interface components and their
  accessibility actions.
- `test/localization/hardcoded_ui_copy_contract_test.dart` rejects direct
  user-facing English literals in active screens and widgets. Deliberately
  deferred nutrition, cardio/stretch, and placeholder surfaces are narrowly
  excluded until those product areas are rebuilt.
- `integration_test` runs device-level core flows against an isolated database.
  Its core suite drives plan creation, workout start/resume/exit/completion,
  record presentation, Save as plan, profile editing, and database
  export/import through the real UI. Repository calls are limited to fixture
  setup and persisted-result assertions.

Run the complete suite from the repository root:

```powershell
flutter test
```

Run a focused test file while developing a feature:

```powershell
flutter test test\services\flow_executor_test.dart
```

Run the Android core-flow suite on a connected device:

```powershell
flutter test integration_test\core_flows_test.dart `
  -d <android-device-id> `
  --dart-define=TONOS_INTEGRATION_TEST=true `
  --dart-define=TONOS_DATABASE_NAME=tonos_integration_test.db
```

## Release networking verification

Flutter Driver does not support release mode on Android. Verify release cloud
networking with two complementary checks instead:

1. Build the release APK and inspect its packaged permissions:

```powershell
flutter build apk --release

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
  --dart-define=TONOS_DATABASE_NAME=tonos_integration_test.db
```

The integration setup clears app SharedPreferences, so run it on a development
device or emulator where resetting Tonos settings is acceptable.

## Continuous integration

`.github/workflows/ci.yml` runs for pull requests, pushes to `local-db`, and
manual dispatches. It installs the pinned Flutter SDK, regenerates localization
sources, fails if the tracked generated files change, analyzes application and
test code, runs the complete unit/widget suite, and builds a release APK.

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

## Release diagnostics verification

Production builds intentionally do not configure direct remote crash reporting.
The unit and contract tests verify the disabled default, bounded local sync
history, the absence of a remotely routable DSN in the signed-release workflow,
and the retained redaction boundary for any future privacy-relay integration.
See `docs/release-diagnostics.md` for the current release posture and relay
requirements.
