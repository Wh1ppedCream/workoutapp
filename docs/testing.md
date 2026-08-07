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
- `integration_test` runs device-level core flows against an isolated database.

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

For every new user-visible feature, add at least one test at the lowest useful
level: pure model/utility first, then DAO/service, then widget or integration
coverage when interaction or persistence is involved. Avoid network calls,
real device storage, and production content URLs in ordinary tests; use bundled
assets, SharedPreferences mocks, in-memory SQLite, or a mocked platform channel.
The profile-mode release-networking verification above is the intentional
exception and uses the configured development content environment.
