import { isValidReceiptId, maxPayloadBytes, validateEvent } from './schema.mjs';

const retentionMilliseconds = 14 * 24 * 60 * 60 * 1000;
const noStoreHeaders = {
  'cache-control': 'no-store',
  'content-type': 'application/json; charset=utf-8',
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'POST' && url.pathname === '/v1/events') {
      return submitEvent(request, env);
    }
    if (
      request.method === 'DELETE' &&
      url.pathname.startsWith('/v1/events/')
    ) {
      return deleteEvent(request, env, url.pathname.slice('/v1/events/'.length));
    }
    return jsonResponse({ error: 'not_found' }, 404);
  },

  async scheduled(_controller, env) {
    await env.DIAGNOSTICS_DB.prepare(
      'DELETE FROM diagnostic_events WHERE received_at < ?',
    )
      .bind(Date.now() - retentionMilliseconds)
      .run();
  },
};

async function submitEvent(request, env) {
  if (env.DIAGNOSTICS_RELAY_WRITES_ENABLED !== 'true') {
    return jsonResponse({ error: 'temporarily_unavailable' }, 503);
  }
  if (!request.headers.get('content-type')?.startsWith('application/json')) {
    return jsonResponse({ error: 'unsupported_media_type' }, 415);
  }

  const body = await readCappedJsonBody(request);
  if (body.tooLarge) {
    return jsonResponse({ error: 'payload_too_large' }, 413);
  }
  const event = validateEvent(body.value);
  if (event === null) return jsonResponse({ error: 'invalid_payload' }, 400);

  const receiptId = crypto.randomUUID();
  const deletionToken = randomToken();
  const deletionTokenHash = await hashDeletionToken(deletionToken, env);
  await env.DIAGNOSTICS_DB.prepare(
    `INSERT INTO diagnostic_events (
      receipt_id,
      deletion_token_hash,
      schema_version,
      kind,
      app_version,
      build_number,
      platform,
      code,
      source,
      outcome,
      duration_bucket,
      item_count_bucket,
      manifest_version,
      received_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  )
    .bind(
      receiptId,
      deletionTokenHash,
      event.schema_version,
      event.kind,
      event.app_version,
      event.build_number,
      event.platform,
      event.code,
      event.source,
      event.outcome,
      event.duration_bucket,
      event.item_count_bucket,
      event.manifest_version ?? null,
      Date.now(),
    )
    .run();

  return jsonResponse(
    { receipt_id: receiptId, deletion_token: deletionToken },
    202,
  );
}

async function deleteEvent(request, env, receiptId) {
  const deletionToken = request.headers.get('x-tonos-deletion-token');
  if (!isValidReceiptId(receiptId) || !isValidDeletionToken(deletionToken)) {
    return new Response(null, { status: 204, headers: noStoreHeaders });
  }

  const deletionTokenHash = await hashDeletionToken(deletionToken, env);
  await env.DIAGNOSTICS_DB.prepare(
    'DELETE FROM diagnostic_events WHERE receipt_id = ? AND deletion_token_hash = ?',
  )
    .bind(receiptId, deletionTokenHash)
    .run();
  return new Response(null, { status: 204, headers: noStoreHeaders });
}

function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), { status, headers: noStoreHeaders });
}

async function readCappedJsonBody(request) {
  const declaredLength = request.headers.get('content-length');
  if (declaredLength !== null && /^\d+$/.test(declaredLength)) {
    if (Number(declaredLength) > maxPayloadBytes) {
      return { tooLarge: true, value: null };
    }
  }

  const reader = request.body?.getReader();
  if (reader === undefined) return { tooLarge: false, value: null };

  const chunks = [];
  let length = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      length += value.byteLength;
      if (length > maxPayloadBytes) {
        await reader.cancel();
        return { tooLarge: true, value: null };
      }
      chunks.push(value);
    }

    const bytes = new Uint8Array(length);
    let offset = 0;
    for (const chunk of chunks) {
      bytes.set(chunk, offset);
      offset += chunk.byteLength;
    }
    return {
      tooLarge: false,
      value: JSON.parse(new TextDecoder().decode(bytes)),
    };
  } catch {
    return { tooLarge: false, value: null };
  } finally {
    reader.releaseLock();
  }
}

function randomToken() {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return bytesToBase64Url(bytes);
}

function isValidDeletionToken(value) {
  return typeof value === 'string' && /^[A-Za-z0-9_-]{32,128}$/.test(value);
}

async function hashDeletionToken(token, env) {
  const secret = env.DELETION_TOKEN_HMAC_KEY;
  if (typeof secret !== 'string' || secret.length < 32) {
    throw new Error('diagnostics relay deletion-token key is unavailable');
  }
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(token),
  );
  return bytesToBase64Url(new Uint8Array(signature));
}

function bytesToBase64Url(bytes) {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}
