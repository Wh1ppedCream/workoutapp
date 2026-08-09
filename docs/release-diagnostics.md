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

The repository also provides a manually triggered **Production Android
release** workflow. It is protected by the GitHub `production` environment and
uploads a signed APK for device validation plus the signed AAB intended for
distribution. It requires these environment secrets:

- `TONOS_SENTRY_DSN`
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Do not add those values to workflow YAML, Dart source, Gradle files, artifacts,
logs, or repository variables. Require an environment reviewer before allowing
the production workflow to access them.

## Privacy contract

`DiagnosticsService` creates a dedicated, unscoped Sentry pure-Dart client only
after stored user consent. It does not install Sentry's automatic
Flutter/platform error handlers, and it does not use Sentry's global scope;
every remote capture must pass through the app's redaction boundary. The
service also configures these release safeguards:

- default PII, failed-request capture, logs, tracing, and profiling are
  disabled; accepted events remove user/IP data and trace context before
  transmission, and the unscoped client prevents an envelope trace header from
  being created. Screenshots and view hierarchy capture are not installed;
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
3. Download the workflow's signed `tonos-production-apk-*` artifact, install
   it on a dedicated test device, and confirm crash reporting is off on first
   launch.
4. Confirm Profile > Diagnostics & Privacy shows the expected app version and
   build number.
5. Exercise remote and bundled media sync and inspect the local event fields.
6. Enable reporting on a test device and choose **Send a controlled test
   report**. Verify that Sentry receives exactly one
   `ControlledDiagnosticsTestException` event in the `production` environment.
7. Inspect the event and confirm that it contains no name, profile value,
   workout or nutrition content, database field, URL, attachment, screenshot,
   view hierarchy, log, trace identifier, IP-derived geography, or original
   exception message.
8. Disable reporting and confirm the controlled action becomes unavailable and
   no new event can be submitted.
9. Confirm the Sentry organization retains error events for no more than 90
   days. The Developer plan currently deletes them after 30 days; paid plans
   may retain them for up to 90 days. Recheck this after any plan or
   organization-policy change.
10. Confirm the **Publish privacy pages** workflow succeeds and that
    `privacy.html` and `data-deletion.html` are publicly reachable.

The policy workflow publishes only `docs/index.html`, `docs/privacy.html`, and
`docs/data-deletion.html`; internal engineering documents are not included in
the Pages artifact.

Never trigger a deliberate crash in a public production project using a real
user profile or populated health database.
