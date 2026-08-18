# Verified Media Library Plan

## Status

This is an approved design and deferred implementation plan. The current
cloud-content cache remains in use. Do not treat the work described here as
implemented until its delivery checklist is complete.

## Why This Exists

Exercise thumbnails currently download on demand and are stored in Android's
temporary cache directory. Android may remove that directory while SQLite still
contains the old local path. The app now recovers from a missing file at render
time, but that is a safety net rather than the desired user experience.

The current release manifest contains 127 exercise thumbnail assets totaling
about 1.65 MiB. Prefetching that small thumbnail set can make normal exercise
browsing fast and available offline after initial synchronization. The same
system must scale safely to future food thumbnails, full-size images, and
exercise videos without downloading all future content at startup.

## Current Behavior

- Exercise and shared-media widgets load files independently when visible.
- Media is verified using HTTPS, content type, byte count, SHA-256, restricted
  redirects, and atomic writes.
- Files live under the platform temporary cache directory.
- A missing or corrupt local file is treated as a cache miss.
- A failed initial download exposes a manual retry control.
- Cache pruning and bounds exist, but there is no shared request queue,
  background prefetch policy, file lease, or durable media-library store.

## Target Architecture

Create a generic verified media library for exercise thumbnails, food
thumbnails, detail images, and user-requested videos.

### 1. Durable Content-Addressed Storage

- Store verified media in app-managed durable storage, not the operating
  system's purgeable temporary cache.
- Exclude the media directory from platform backup.
- Use SHA-256-derived filenames so a file identity is its verified content,
  not a mutable remote filename.
- Keep SQLite as an index and performance cache, not the only source of truth.
- On startup and manifest updates, reconcile the manifest, index, and disk:
  remove stale paths, discover valid completed files, and clear abandoned
  temporary downloads.

### 2. Atomic Download Lifecycle

1. Download to a uniquely named `.download` file.
2. Enforce response size and validate content type while streaming.
3. Verify final byte count and SHA-256.
4. Atomically rename the verified file to its content-addressed final path.
5. Update SQLite only after the rename succeeds.
6. Periodically prune unindexed completed files after a grace period.

If the process dies at any point, the next reconciliation pass deletes partial
files or indexes a completed verified file. A database migration failure must
not make valid on-disk media permanently inaccessible.

### 3. Media Download Coordinator

Introduce one shared `MediaDownloadCoordinator` used by every media widget,
screen, and background task.

- Deduplicate concurrent requests for the same asset.
- Limit concurrent network transfers and verification work.
- Let high-priority visible requests join or promote existing work instead of
  opening duplicate connections.
- Preserve queued work across normal app interruptions by recomputing missing
  assets from the current manifest on the next launch.
- Do not repeatedly cancel in-flight requests during rapid scrolling; reorder
  pending work instead.

Priority order:

1. Current workout and active-plan exercise media.
2. Visible media on the current screen.
3. Recently used and current-plan media.
4. Background exercise-thumbnail prefetch.
5. Detail images.
6. Explicit user-requested videos.

### 4. Prefetch Policy By Media Class

| Media class | Default policy |
| --- | --- |
| Exercise thumbnails | Prefetch the current verified manifest in the background after first meaningful paint. |
| Food thumbnails | Fetch visible, searched, recent, and favorite items only. Do not prefetch the full food catalog. |
| Detail images | Fetch when the relevant detail page opens. |
| Exercise videos | Stream or download only after explicit user intent. |

Background prefetch must honor the existing Wi-Fi-only preference. It should
start only while the app is idle, pause during active user interaction or known
network loss, and use conservative concurrency, such as two low-priority
transfers. Visible requests always take priority.

### 5. Retry and Failure Policy

- Retry transient failures at most twice using short backoff and jitter.
- Retry only timeouts, connection failures, HTTP 408, HTTP 429, and HTTP 5xx.
- Do not automatically retry invalid HTTPS, redirects, response content type,
  byte count, or SHA-256 failures.
- Use a circuit breaker: pause automatic work after network loss or repeated
  failures and resume on connectivity restoration, app foreground, or a later
  normal launch.
- Keep manual refresh only for final failures.

### 6. Safe Eviction and Storage Controls

- Separate thumbnail, image, and video storage budgets.
- Retain thumbnails most aggressively; use least-recently-used eviction for
  images; give video a smaller user-visible quota.
- Before eviction, ensure a file has no active UI lease. Widgets acquire a
  short lease while a file is being decoded or displayed.
- Detect low available storage before starting downloads.
- Provide settings for media usage plus separate clear actions for thumbnails,
  images, and videos.

### 7. UI Behavior

- Keep fixed media bounds and aspect ratios.
- Show semantic local fallbacks while media is unavailable.
- Notify interested widgets as a shared download completes.
- Precache the decoded image and cross-fade to it in a short animation so the
  fallback replacement does not cause flicker or layout shift.
- Existing render-time fallback/retry remains a last-resort safeguard.

### 8. Performance and Privacy

- Keep network I/O asynchronous.
- For larger images and videos, move expensive completed-file verification or
  metadata processing off the UI isolate.
- Do not log URLs, file paths, exercise history, or user data in diagnostics.
- Record only privacy-safe aggregate local synchronization outcomes if needed.

## Delivery Plan

1. Add media classes, priorities, quotas, and durable no-backup storage.
2. Add disk/index reconciliation and safe migration from the current temporary
   cache. Existing valid files may be copied after verification; invalid paths
   are cleared without blocking startup.
3. Implement the shared coordinator with deduplication, priority promotion,
   concurrency limits, and transient retry classification.
4. Move exercise thumbnail widgets onto the coordinator and enable background
   prefetch after first meaningful paint.
5. Add file leases, cache-budget eviction, storage controls, and UI cross-fade.
6. Reuse the system for shared anatomy media, then food thumbnails, detail
   images, and finally explicit video downloads.

## Required Tests

- Atomic write, process interruption, and orphan cleanup.
- Disk/index reconciliation and database rebuild from valid files.
- Stale path repair, corrupt file rejection, and manifest hash upgrades.
- Shared request deduplication, queue priority, concurrency limits, and
  visibility promotion.
- Retry classification, retry limits, circuit breaking, and offline resume.
- Lease-aware eviction, quotas, low-storage behavior, and clear-media actions.
- Widget fallback, automatic replacement, no layout shift, and manual final
  retry behavior.
- Wi-Fi-only behavior for prefetch and explicit video download behavior.

## Completion Criteria

The work is complete only when exercise thumbnails are verified, durable,
prefetched without blocking startup, safe during eviction, automatically
recovering from transient failures, and backed by the required tests. Food
thumbnails and videos must use the same coordinator with their stricter
on-demand policies.
