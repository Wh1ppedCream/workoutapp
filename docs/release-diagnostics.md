# Release diagnostics

Tonos crash reporting is deliberately opt-in twice: the release must include a
Sentry DSN, and the user must enable **Share crash reports** in **Profile >
Diagnostics & Privacy**. Without either condition, no remote crash SDK is
started.

## Production build configuration

Keep the DSN outside source control and pass it as a build-time define:

```powershell
$env:TONOS_SENTRY_DSN = "<production Sentry DSN>"

flutter build appbundle --release `
  --dart-define=TONOS_ENVIRONMENT=production `
  --dart-define=TONOS_SENTRY_DSN=$env:TONOS_SENTRY_DSN
```

Builds without `TONOS_SENTRY_DSN` remain valid. Their diagnostics page explains
that remote crash reporting is unavailable and disables the consent switch.
The DSN selects the Sentry project but is not an authentication secret; still,
supplying it from release configuration prevents accidental use of the wrong
project or environment.

## Privacy contract

`DiagnosticsService` initializes Sentry's pure Dart client only after stored
user consent. It does not install Sentry's automatic Flutter/platform error
handlers; every remote capture must pass through the app's redaction boundary.
The service also configures these release safeguards:

- default PII, failed-request capture, logs, tracing, and profiling are
  disabled; screenshots and view hierarchy capture are not installed;
- the original exception message is replaced by its runtime type before remote
  capture;
- automatic isolate capture is removed and a final `beforeSend` gate rejects
  any event that did not pass through the redaction boundary;
- sync breadcrumbs contain only operation/source categories, outcome, duration,
  manifest version, item count, and redacted error type;
- a maximum of 30 sync events is retained locally and can be cleared in-app.

Do not add database rows, exercise names, profile fields, URLs, free-form error
messages, or exported files to diagnostic events. Any expansion of captured
fields requires a privacy-policy update and an explicit product review.

## Release checklist

1. Run localization generation, analyzer, the full test suite, and a release
   build.
2. Confirm `test/release_diagnostics_contract_test.dart` passes.
3. Install the production-configured build and confirm crash reporting is off
   on first launch.
4. Confirm Profile > Diagnostics & Privacy shows the expected app version and
   build number.
5. Exercise remote and bundled media sync and inspect the local event fields.
6. Enable reporting on a test device, submit a controlled non-user-data test
   error, and inspect the received Sentry event for unexpected fields.
7. Disable reporting, clear sync history, and confirm no new remote event is
   submitted.
8. Publish `docs/privacy.html` and `docs/data-deletion.html` with the release.

Never trigger a deliberate crash in a public production project using a real
user profile or populated health database.
