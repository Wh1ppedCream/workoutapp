export const maxPayloadBytes = 2048;

const allowedKinds = new Set(['app_fault', 'content_sync']);
const allowedPlatforms = new Set([
  'android',
  'ios',
  'windows',
  'macos',
  'linux',
  'web',
]);
const allowedCodes = new Set([
  'flutter_framework_error',
  'async_uncaught_error',
  'startup_error',
  'content_manifest_fetch_failed',
  'content_manifest_decode_failed',
  'content_asset_fetch_failed',
  'content_cache_write_failed',
  'content_sync_skipped',
]);
const appFaultCodes = new Set([
  'flutter_framework_error',
  'async_uncaught_error',
  'startup_error',
]);
const contentSyncCodes = new Set([
  'content_manifest_fetch_failed',
  'content_manifest_decode_failed',
  'content_asset_fetch_failed',
  'content_cache_write_failed',
  'content_sync_skipped',
]);
const allowedSources = new Set([
  'app',
  'remote_media',
  'bundled_media',
  'media_cache',
]);
const allowedOutcomes = new Set(['failed', 'skipped']);
const allowedDurationBuckets = new Set([
  'under_1s',
  '1_to_5s',
  '5_to_30s',
  'over_30s',
  'unknown',
]);
const allowedItemCountBuckets = new Set([
  'zero',
  'one_to_nine',
  'ten_to_ninety_nine',
  'one_hundred_or_more',
  'unknown',
]);

const requiredFields = [
  'schema_version',
  'kind',
  'app_version',
  'build_number',
  'platform',
  'code',
  'source',
  'outcome',
  'duration_bucket',
  'item_count_bucket',
];
const optionalFields = new Set(['manifest_version']);
const semanticVersion = /^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/;
const opaqueIdentifier = /^[A-Za-z0-9_-]{16,128}$/;

export function validateEvent(value) {
  if (!isRecord(value) || !hasOnlyApprovedFields(value)) return null;
  if (!requiredFields.every((field) => field in value)) return null;

  if (
    value.schema_version !== 1 ||
    !allowedKinds.has(value.kind) ||
    typeof value.app_version !== 'string' ||
    !semanticVersion.test(value.app_version) ||
    !isNonNegativeInteger(value.build_number) ||
    !allowedPlatforms.has(value.platform) ||
    !allowedCodes.has(value.code) ||
    !allowedSources.has(value.source) ||
    !allowedOutcomes.has(value.outcome) ||
    !allowedDurationBuckets.has(value.duration_bucket) ||
    !allowedItemCountBuckets.has(value.item_count_bucket)
  ) {
    return null;
  }

  if (
    (value.kind === 'app_fault' &&
      (value.source !== 'app' ||
        value.outcome !== 'failed' ||
        !appFaultCodes.has(value.code) ||
        value.manifest_version !== undefined)) ||
    (value.kind === 'content_sync' &&
      (value.source === 'app' ||
        !contentSyncCodes.has(value.code) ||
        (value.code === 'content_sync_skipped' && value.outcome !== 'skipped') ||
        (value.code !== 'content_sync_skipped' && value.outcome !== 'failed')))
  ) {
    return null;
  }

  if (
    'manifest_version' in value &&
    !isNonNegativeInteger(value.manifest_version)
  ) {
    return null;
  }

  return {
    schema_version: value.schema_version,
    kind: value.kind,
    app_version: value.app_version,
    build_number: value.build_number,
    platform: value.platform,
    code: value.code,
    source: value.source,
    outcome: value.outcome,
    duration_bucket: value.duration_bucket,
    item_count_bucket: value.item_count_bucket,
    ...(value.manifest_version === undefined
      ? {}
      : { manifest_version: value.manifest_version }),
  };
}

export function isValidReceiptId(value) {
  return typeof value === 'string' && opaqueIdentifier.test(value);
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function hasOnlyApprovedFields(value) {
  return Object.keys(value).every(
    (field) => requiredFields.includes(field) || optionalFields.has(field),
  );
}

function isNonNegativeInteger(value) {
  return Number.isSafeInteger(value) && value >= 0;
}
