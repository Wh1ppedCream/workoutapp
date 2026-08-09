# Release diagnostics

## Current production posture

Tonos production builds intentionally do not send diagnostics directly from a
device to Sentry or another remote service. The signed production workflow does
not require, read, or inject a diagnostics DSN, so **Share crash reports** and
**Send a controlled test report** are unavailable in released builds.

This is a privacy decision, not a broken configuration. Controlled validation
confirmed the app's redaction boundary and consent behavior, but Sentry still
rendered service-derived approximate geography and synthetic trace metadata for
a direct device upload. IP-address scrubbing prevents storage of the address;
it does not provide Tonos with a sufficient guarantee that this related metadata
will be absent. Do not add a direct Sentry DSN back to a distributable build.

Local sync diagnostics remain available. They are capped at 30 entries and
contain only operation/source categories, outcome, duration, manifest version,
item count, and a redacted error type.

## Current release configuration

The protected **Production Android release** workflow requires only the Android
signing secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

It produces a signed APK for device validation and a signed AAB for
distribution. It sets `TONOS_ENVIRONMENT=production`, but it must not receive
or pass `TONOS_SENTRY_DSN`. Builds without a remote diagnostics endpoint are
valid and are the only approved production artifacts today.

## Future remote diagnostics requirements

Remote crash reporting can return only after a reviewed privacy relay is
implemented. The relay design must:

1. Keep the Sentry DSN and Sentry connection off the device; Tonos clients send
   only to the relay.
2. Enforce the existing consent check and a server-side allowlist of the small,
   redacted event schema. It must reject free-form exception messages, database
   contents, profiles, health data, URLs, attachments, screenshots, and view
   hierarchy data.
3. Avoid forwarding a client IP address or forwarding headers to Sentry, and
   document the relay operator's own connection logging and retention.
4. Provide a deletion path, a retention limit, abuse protection, and monitoring
   for the relay itself.
5. Update the privacy and data-deletion pages, then repeat the signed-release,
   fresh-install, opt-in, controlled-event, and event-inspection validation.

The existing `DiagnosticsService` redaction boundary and focused unit tests are
retained as a starting point for that reviewed integration. They do not approve
direct device-to-Sentry reporting.

## Release checklist

1. Run localization generation, analyzer, the full test suite, and a signed
   release build.
2. Confirm `test/release_diagnostics_contract_test.dart` passes.
3. Download and hash-check the signed `tonos-production-apk-*` artifact, then
   install it on a dedicated test device.
4. Confirm Profile > Diagnostics & Privacy shows the expected app version and
   build number, local sync history, and unavailable crash-sharing controls.
5. Exercise remote and bundled media sync and inspect only the local sync
   history fields.
6. Confirm the app has no configured remote diagnostics endpoint and that a
   controlled test report cannot be submitted.
7. Confirm the **Publish privacy pages** workflow succeeds and that
   `privacy.html` and `data-deletion.html` are publicly reachable.

If a future relay is approved, replace steps 4 through 6 with the relay-specific
consent, redaction, retention, deletion, and event-inspection checks above.
