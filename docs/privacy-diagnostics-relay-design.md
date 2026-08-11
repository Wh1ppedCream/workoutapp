# Privacy-Preserving Diagnostics Relay Design

Status: Approved architecture. The relay implementation is present in the
repository, but no production endpoint is provisioned and distributed builds
remain unable to send remote diagnostics.

Last updated: 2026-08-10

## Decision Summary

Tonos must not restore direct device-to-Sentry reporting. A Cloudflare Worker
must also not proxy diagnostics to Sentry or another external origin: Cloudflare
documents that Worker subrequests to a non-Cloudflare origin can carry the
original client IP address. That would repeat the privacy failure found during
direct-Sentry validation.

The recommended first relay is a Tonos-operated Cloudflare Worker with an
isolated D1 database. It accepts only a small, structured diagnostics schema
and has no outbound `fetch` calls. It does not send events to Sentry. The
Worker stores only allowlisted columns, returns an anonymous deletion receipt,
and deletes primary event rows automatically after 14 days.

This design does not promise that a network provider sees no connection
metadata. Cloudflare necessarily processes the connection to operate the
endpoint and rate limits. Tonos must not store the client IP address, request
headers, user agent, country, or Cloudflare request metadata in the diagnostics
database, logs, analytics events, or any downstream system.

## Goals

1. Help identify release regressions by app build and a small set of approved
   fault or content-sync codes.
2. Keep diagnostics opt-in, local-first, and useful without accounts, device
   identifiers, free-form text, stack traces, or a third-party error-tracking
   endpoint.
3. Give a person who opted in a practical way to remove each remote report
   without supplying identity, health data, or a backup.
4. Keep remote diagnostics nonessential: an outage, rate limit, or deletion
   failure must never block app startup, a workout, or media synchronization.

## Non-Goals

1. Reconstructing a full crash stack trace, user journey, or device profile.
2. Tracking unique installs, users, sessions, advertising identifiers, or
   repeat behavior.
3. Collecting workout, nutrition, body metric, profile, database, barcode,
   media URL, or locale data.
4. Reintroducing Sentry, a Sentry DSN, analytics SDKs, direct device egress to
   a diagnostics vendor, or a Worker proxy to an external diagnostics vendor.
5. Making a deletion request locate a person who has no saved receipt. Reports
   expire automatically instead.

## Recommended Architecture

```
Opted-in Tonos app
        |
        | HTTPS POST: strict JSON schema only
        v
Tonos Diagnostics Worker
        |
        | D1 binding only; no outbound fetch and no payload logging
        v
Isolated diagnostics D1 database
        |
        | read-only, audited operator query during incident review
        v
Aggregated release troubleshooting
```

The diagnostics Worker and D1 database must be separate from public media R2
buckets and from the app's local SQLite schema. Production, staging, and
development each require separate Workers and D1 databases. Staging accepts
only synthetic test events.

The production Worker must not bind an external error-tracking secret, make an
outbound HTTP request, use Workers Logs/Logpush for request bodies, or emit raw
custom analytics events. A source contract test must reject `await fetch(` in
the production Worker implementation unless a future privacy review changes
this decision.

## Client Consent And Behavior

1. Rename the production setting to **Share anonymous diagnostics**. The
   current name, **Share crash reports**, implies a fuller crash capture than
   this design permits.
2. Keep the control off by default. Enabling it requires an explicit toggle and
   clear copy describing the exact fields, 14-day primary retention, deletion
   receipt, and Cloudflare connection processing.
3. Do not reuse an earlier Sentry consent value. Introduce a new
   `diagnostics.relay.consent.v1` preference, defaulting to `false` for every
   installation and upgrade.
4. When consent is off, the app opens no relay connection, keeps no pending
   remote event queue, and leaves local sync history local.
5. When consent is withdrawn, stop future sends immediately. The app should
   offer to delete locally retained remote receipts before clearing them. If the
   device is offline, retain only the deletion requests and retry on a future
   app launch; do not retry diagnostic submissions.
6. A public production build must not expose a general-purpose controlled-test
   button. A release-candidate-only test mode may send one fixed synthetic
   event to staging or production for validation, then must be disabled in the
   distributable production artifact.

## Event Allowlist

The client sends one object no larger than 2 KiB. The Worker rejects unknown
fields, invalid types, invalid enum values, and unsupported schema versions.
It stores parsed columns rather than the raw request JSON.

| Field | Accepted values | Purpose |
| --- | --- | --- |
| `schema_version` | Literal integer `1` | Safe protocol evolution |
| `kind` | `app_fault`, `content_sync` | Broad diagnostic category |
| `app_version` | App version string matching the release format | Release comparison |
| `build_number` | Non-negative integer | Release comparison |
| `platform` | `android`, `ios`, `windows`, `macos`, `linux`, `web` | Platform regression grouping |
| `code` | Approved code enum below | Fault classification |
| `source` | `app`, `remote_media`, `bundled_media`, `media_cache` | Approved subsystem only |
| `outcome` | `failed`, `skipped` | Result classification |
| `duration_bucket` | `under_1s`, `1_to_5s`, `5_to_30s`, `over_30s`, `unknown` | Performance signal without exact timing |
| `manifest_version` | Non-negative integer or omitted | Media compatibility only |
| `item_count_bucket` | `zero`, `one_to_nine`, `ten_to_ninety_nine`, `one_hundred_or_more`, `unknown` | Sync scale without exact count |

Version 1 `code` values are:

```
flutter_framework_error
async_uncaught_error
startup_error
content_manifest_fetch_failed
content_manifest_decode_failed
content_asset_fetch_failed
content_cache_write_failed
content_sync_skipped
```

`source` must be `app` for an `app_fault`. Content-sync codes may use only the
three media sources in the table. The server must validate these combinations.

The following are permanently excluded from the v1 payload: exception message,
stack trace, runtime-type string, breadcrumbs, timestamp supplied by the
device, route, screen title, URL, request header, IP address, user agent,
locale, timezone, device model, device identifier, advertising identifier,
profile data, health data, database content, file path, attachment, screenshot,
view hierarchy, and free-form note.

The Worker creates the received-at timestamp, report identifier, and deletion
token. The client does not provide a stable identifier or timestamp.

## Header, IP, And Logging Rules

1. The Worker accepts only `POST /v1/events` and anonymous deletion requests
   to `DELETE /v1/events/{receipt_id}`. It returns `Cache-Control: no-store`.
2. For submission it reads only the JSON body and `Content-Type`. For deletion
   it additionally reads the `X-Tonos-Deletion-Token` header. It must ignore
   every other incoming header, including `CF-Connecting-IP`,
   `X-Forwarded-For`, `X-Real-IP`, `User-Agent`, `Referer`, and location
   headers.
3. It must not log the request body, parsed fields, headers, IP address,
   receipt, deletion token, or database query values. Operational logs contain
   only fixed event names and HTTP status classes.
4. Do not configure Logpush, request-body logging, user-level Workers
   observability, or Analytics Engine writes for this Worker. If Cloudflare
   product-level request analytics cannot be disabled for the chosen plan, the
   public privacy policy must identify Cloudflare as an infrastructure processor
   of connection metadata and state the applicable provider retention.
5. The Worker has no outbound network calls. This prevents forwarding client
   headers to a vendor and avoids deriving location from a diagnostics vendor's
   view of the connection.
6. Native app clients do not need CORS. Do not add permissive CORS headers in
   v1. A future web client requires a separate browser threat-model review.

## Storage, Retention, And Deletion

The D1 table stores typed columns for the allowlist, a server-generated
`receipt_id`, a received-at timestamp, and an HMAC of a server-generated
deletion token. The token itself is returned only once to the app and is never
stored by the Worker. The HMAC key is a versioned Worker secret, not a client
secret.

1. Primary event rows expire after 14 days. A scheduled Worker deletes them at
   least daily. Version 1 retains no long-lived per-event aggregate table.
2. Cloudflare D1 Time Travel can retain database history for up to 30 days.
   A deleted primary row can therefore remain recoverable in provider-managed
   recovery history for up to 30 additional days. The effective maximum
   retention must be disclosed as 44 days for a normally expiring row and up to
   30 days after a user-requested deletion.
3. The app stores the receipt and deletion token locally only while remote
   report retention is possible. They are not personal identifiers and are
   removed with local app data or after the deletion request succeeds.
4. `DELETE /v1/events/{receipt_id}` requires the matching deletion token. On a
   match, the Worker deletes the primary row and returns `204`; on a mismatch
   or missing row, it returns the same response to avoid revealing whether a
   report exists.
5. Profile > Diagnostics & Privacy needs a **Delete shared diagnostics** action
   that sends deletion requests for retained receipts, reports any offline
   requests queued locally, and explains the D1 recovery-history limit.
6. If a person cleared the app before retaining a receipt, Tonos cannot find a
   report without collecting identity. The report expires automatically under
   the retention rule. Public deletion documentation must state this plainly.

## Abuse And Availability Controls

1. Enforce a 2 KiB body limit before parsing, strict JSON content type, fixed
   route/methods, enum validation, and no batching.
2. Apply Cloudflare DDoS and WAF protection. Add a conservative edge rate
   limit for this nonessential endpoint. It may use the connection at the edge
   for enforcement but must never write the IP address or a derivative to D1.
3. Treat rate limiting as best-effort abuse resistance, not authentication or
   accounting. Do not create an install ID just to rate-limit diagnostics.
4. Do not add app-embedded API secrets, CAPTCHA, or device attestation in v1.
   If abuse requires them, perform a separate privacy review because each adds
   another processor or identifier.
5. Return small generic error responses and do not echo rejected payloads.
   Failed submissions are dropped without automatic retries.
6. Keep a server-side emergency disable flag. During abuse or an incident, it
   must stop new writes while continuing to honor authenticated deletion
   requests.

## Operational Ownership

1. The Tonos maintainer is accountable for the Worker, D1 database, retention
   job, privacy text, deletion endpoint, and access review. Before public
   rollout, record a backup maintainer and escalation contact in the private
   release runbook.
2. Use separate development, staging, and production Cloudflare resources.
   Production deployment credentials are protected-environment secrets with
   only the Worker/D1 permissions required for deployment and migration.
3. Require multi-factor authentication for production operator accounts and
   least-privilege read access for incident review. Review operator access and
   secrets at least quarterly and immediately after a maintainer change.
4. Query data only for a documented release regression or operational incident.
   Use aggregate SQL grouped by release, platform, code, and source. Do not
   export primary rows unless the Tonos maintainer approves a time-limited incident
   investigation.
5. The release runbook must cover disabling writes, testing deletion, rotating
   versioned deletion-token HMAC keys, retention-job failure, and a public
   privacy incident response. Retain an older HMAC key only while matching rows
   can still exist.

## Implementation And Validation Gates

The maintainer approved this design on 2026-08-10. Implementation is present,
but remote delivery stays disabled until the remaining provisioning and
release-candidate gates are complete.

1. Create a separate relay package with Worker schema tests, D1 migrations,
   retention-job tests, deletion-token tests, and a contract that forbids
   outbound `fetch` and raw request logging. The source package, migration,
   schema tests, and no-egress contract are now present; environment-backed
   retention and deletion tests remain a staging gate.
2. Replace direct Sentry client code in `DiagnosticsService` with a narrowly
   typed relay client. Remove the Sentry package and all DSN configuration from
   distributed builds once the relay client exists. Completed; the relay URL is
   empty by default and the new consent key remains off by default.
3. Add client tests proving a stack trace, exception message, runtime type,
   profile value, URL, and database value cannot enter the relay payload.
4. Deploy staging resources and submit one fixed synthetic event. Verify the
   stored D1 columns, request logs, receipts, deletion flow, retention job, and
   absence of outbound traffic.
5. Update `privacy.html`, `data-deletion.html`, release diagnostics guidance,
   and in-app consent copy before any production endpoint is enabled.
6. Create a signed release candidate with relay consent off by default. Test
   opt-in, one approved synthetic event, direct D1 inspection, receipt-based
   deletion, opt-out, local data clearing, and the documented recovery-history
   behavior.
7. Roll out only after the Tonos maintainer accepts the release-candidate evidence.
   Keep a server-side disable switch and review the first 30 days of aggregate
   results and deletion requests before treating the relay as routine.

## Future Vendor Integration

Sentry or another external diagnostics vendor is out of scope for this design.
Any future vendor integration needs a new privacy review, a data-processing
agreement review, a fixed-region non-edge egress design, header-stripping proof,
and a fresh signed-device validation. The current Worker must not be converted
into a vendor proxy by adding a `fetch` call.
