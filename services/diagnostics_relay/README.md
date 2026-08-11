# Tonos diagnostics relay

This Worker is the only planned remote diagnostics endpoint for Tonos. It has
no outbound network calls and stores only the categorical schema in
`src/schema.mjs`; it must never proxy a device event to Sentry or another
vendor.

Remote diagnostics remain disabled in distributed builds until the staging
rollout gates in [the relay design](../../docs/privacy-diagnostics-relay-design.md)
are completed. The checked-in `wrangler.example.jsonc` is deliberately not
deployable: copy it to the ignored `wrangler.jsonc` and replace each D1 ID only
after creating isolated staging and production D1 databases.

## Required operational controls

- Set `DELETION_TOKEN_HMAC_KEY` with `wrangler secret put`; use a unique random
  value for each environment and do not print or commit it.
- Keep `DIAGNOSTICS_RELAY_WRITES_ENABLED` set to `false` until staging is
  validated. It is an emergency submit kill switch; deletion stays available.
- Apply `migrations/0001_initial.sql` before writes are enabled.
- Keep the daily cron and 14-day primary row retention. D1 Time Travel may
  retain recovery history for up to a further 30 days.
- Do not enable request-body logging, Logpush, analytics, or outbound service
  integrations for this Worker.
