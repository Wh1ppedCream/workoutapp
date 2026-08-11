import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

import relayWorker from '../src/index.js';
import { validateEvent } from '../src/schema.mjs';

const validEvent = {
  schema_version: 1,
  kind: 'content_sync',
  app_version: '1.2.3',
  build_number: 45,
  platform: 'android',
  code: 'content_manifest_fetch_failed',
  source: 'remote_media',
  outcome: 'failed',
  duration_bucket: '1_to_5s',
  item_count_bucket: 'unknown',
};

test('accepts exactly the approved relay event schema', () => {
  assert.deepEqual(validateEvent(validEvent), validEvent);
});

test('rejects payloads with raw exception data or unexpected fields', () => {
  assert.equal(
    validateEvent({
      ...validEvent,
      error_message: 'private workout data',
      stack_trace: 'stack data',
    }),
    null,
  );
});

test('rejects an invalid version or noncategorical duration', () => {
  assert.equal(validateEvent({ ...validEvent, app_version: 'version 1' }), null);
  assert.equal(validateEvent({ ...validEvent, duration_bucket: '420ms' }), null);
});

test('rejects invalid diagnostic code, kind, source, and outcome combinations', () => {
  assert.equal(
    validateEvent({ ...validEvent, kind: 'app_fault', source: 'remote_media' }),
    null,
  );
  assert.equal(
    validateEvent({ ...validEvent, outcome: 'skipped' }),
    null,
  );
});

test('rejects an oversized event while streaming before schema processing', async () => {
  const database = createRecordingDatabase();
  const response = await relayWorker.fetch(
    new Request('https://relay.example.test/v1/events', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ ...validEvent, unexpected: 'x'.repeat(4096) }),
    }),
    {
      DIAGNOSTICS_DB: database,
      DIAGNOSTICS_RELAY_WRITES_ENABLED: 'true',
      DELETION_TOKEN_HMAC_KEY: 'diagnostics-relay-test-secret-value-1234567890',
    },
  );

  assert.equal(response.status, 413);
  assert.equal(database.calls.length, 0);
});

test('worker source does not make an outbound request or log request data', () => {
  const source = readFileSync(new URL('../src/index.js', import.meta.url), 'utf8');

  assert.equal(source.includes('await fetch('), false);
  assert.equal(source.includes('request.text()'), false);
  assert.equal(source.includes('console.'), false);
  assert.equal(source.includes('sentry'), false);
});

test('worker writes only validated rows, issues a receipt, and accepts deletion', async () => {
  const database = createRecordingDatabase();
  const environment = {
    DIAGNOSTICS_DB: database,
    DIAGNOSTICS_RELAY_WRITES_ENABLED: 'true',
    DELETION_TOKEN_HMAC_KEY: 'diagnostics-relay-test-secret-value-1234567890',
  };
  const submitted = await relayWorker.fetch(
    new Request('https://relay.example.test/v1/events', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(validEvent),
    }),
    environment,
  );

  assert.equal(submitted.status, 202);
  assert.equal(submitted.headers.get('cache-control'), 'no-store');
  const receipt = await submitted.json();
  assert.equal(typeof receipt.receipt_id, 'string');
  assert.equal(typeof receipt.deletion_token, 'string');
  assert.equal(database.calls.length, 1);
  assert.equal(database.calls[0].values.includes('remote_media'), true);
  assert.equal(database.calls[0].values.includes('private details'), false);

  const deleted = await relayWorker.fetch(
    new Request(`https://relay.example.test/v1/events/${receipt.receipt_id}`, {
      method: 'DELETE',
      headers: { 'x-tonos-deletion-token': receipt.deletion_token },
    }),
    environment,
  );

  assert.equal(deleted.status, 204);
  assert.equal(database.calls.length, 2);
});

test('daily handler deletes rows past the primary retention period', async () => {
  const database = createRecordingDatabase();

  await relayWorker.scheduled(null, {
    DIAGNOSTICS_DB: database,
    DELETION_TOKEN_HMAC_KEY: 'diagnostics-relay-test-secret-value-1234567890',
  });

  assert.match(database.calls[0].query, /DELETE FROM diagnostic_events/);
  assert.equal(typeof database.calls[0].values[0], 'number');
});

function createRecordingDatabase() {
  const calls = [];
  return {
    calls,
    prepare(query) {
      return {
        bind(...values) {
          return {
            async run() {
              calls.push({ query, values });
              return { success: true };
            },
          };
        },
      };
    },
  };
}
