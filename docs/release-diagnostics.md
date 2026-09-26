# Release diagnostics

## Current production posture

Tonos production builds intentionally do not send diagnostics directly from a
device to Sentry or another remote service. The signed production workflow does
not require, read, or inject a diagnostics DSN, so **Share anonymous
diagnostics** and **Send a controlled diagnostics event** are unavailable in
released builds.

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
distribution. It explicitly sets `TONOS_CONTENT_ENVIRONMENT=production` and
`TONOS_CONTENT_ALLOW_OVERRIDES=false`, but it must not receive or pass
`TONOS_SENTRY_DSN`. Builds without a remote diagnostics endpoint are valid and
are the only approved production artifacts today.

## Future remote diagnostics requirements

Remote diagnostics can return only after the approved
[privacy-preserving relay design](privacy-diagnostics-relay-design.md) has its
staging resources provisioned and all release-candidate gates completed. The v1
design does not proxy to Sentry or another external diagnostics vendor: a
Cloudflare Worker stores a small allowlisted schema in isolated D1 storage and
makes no outbound request.

The design defines the consent migration, schema, header and logging rules,
14-day primary retention, receipt-based deletion, D1 recovery-history
disclosure, abuse controls, operational ownership, and required release gates.
It is deliberately inactive until those gates are complete.

`DiagnosticsService` now uses a typed relay payload and receipt-based deletion
boundary. It must not be changed to restore direct device-to-Sentry reporting.

## Release checklist

1. Run localization generation, analyzer, the full test suite, and a signed
   release build.
2. Confirm `test/release_diagnostics_contract_test.dart` passes.
3. Download and hash-check the signed `tonos-production-apk-*` artifact, then
   install it on a dedicated test device.
4. Confirm Profile > Diagnostics & Privacy shows the expected app version and
   build number, local sync history, and unavailable anonymous-diagnostics
   controls.
5. Exercise remote and bundled media sync and inspect only the local sync
   history fields.
6. Confirm the app has no configured remote diagnostics endpoint and that a
   controlled diagnostics event cannot be submitted.
7. Confirm the **Publish privacy pages** workflow succeeds and that
   `privacy.html` and `data-deletion.html` are publicly reachable.

If the relay staging and release-candidate gates are completed, replace steps 4
through 6 with its consent, schema, retention, deletion, and event-inspection
checks.
