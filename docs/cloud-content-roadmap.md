# Cloud Content Roadmap

This checklist tracks the cloud content rollout for exercise media first, then
future nutrition content.

## Phase 1 - Architecture Baseline

- [x] Decide on public cloud-hosted shared content instead of bundling all media
  in the app.
- [x] Use manifests as the app-facing contract.
- [x] Keep local heatmap fallbacks for missing exercise media.

## Phase 2 - App Integration

- [x] Add content models, DAO, repository, manifest service, and media cache.
- [x] Show exercise media thumbnails where available.
- [x] Fall back to body heatmaps when media is missing.
- [x] Add manual sync/status tools in database settings.
- [x] Sync the configured exercise media manifest during app startup so first
  installs can show cloud thumbnails without visiting settings.

## Phase 3 - Development Bucket

- [x] Create development R2 bucket.
- [x] Configure CORS.
- [x] Upload first test thumbnails.
- [x] Upload first exercise media manifest.
- [x] Verify app sync and thumbnail replacement.

Outside-code dependencies:

- [ ] Continue uploading real media files as they are produced.

## Phase 4 - Local Pipeline

- [x] Validate exercise media source files.
- [x] Build release manifests from source files.
- [x] Diff local manifests against published manifests.
- [x] Check remote URLs before publishing.
- [x] Generate coverage reports.
- [x] Scaffold missing exercise media batches.
- [x] Merge completed batches back into canonical source.

## Phase 5 - Environment Strategy

- [x] Support content environment configuration.
- [x] Keep development content isolated from production readiness.
- [x] Create production R2 bucket: `tonos-public-content-prod`.

Outside-code dependencies:

- [x] Configure production public access with temporary R2 public URL.
- [x] Update production manifest URL once the temporary public URL exists.
- [ ] Switch the app default to production after a custom production domain is
  connected, or after deciding the temporary R2 URL should be used for app
  builds before a custom domain exists.

## Phase 6 - Coverage Workflow

- [x] Report covered and missing exercises.
- [x] Generate missing-exercise source batches.
- [x] Validate scaffolded batch files.

## Phase 7 - Batch Publishing

- [x] Generate release-ready manifests.
- [x] Generate release reports.
- [x] Generate upload scripts.
- [x] Preserve heatmap fallback for exercises without cloud assets.

Outside-code dependencies:

- [x] Create/collect Batch 001 thumbnail files.
- [x] Upload Batch 001 media files to development R2.
- [x] Validate Batch 001 with remote checks after upload.
- [x] Merge Batch 001 into the canonical source file after media exists.
- [x] Upload the expanded development manifest.
- [x] Sync in-app and spot-check new media plus missing-media fallbacks.

## Phase 8 - Media Quality

- [x] Add optional dimension and byte-size release gates.
- [x] Auto-read dimensions from local PNG, JPEG, GIF, and WebP files.
- [x] Document asset standards.

Product/content decisions:

- [x] Final thumbnail dimensions and aspect ratio: `512 x 512`, square `1:1`,
  WebP preferred, PNG allowed, max `300 KB`.
- [x] Final animation/video format, dimensions, duration, and size limits:
  MP4 H.264, no audio, `720 x 720`, square `1:1`, `5-8 seconds`, max `4 MB`.

## Phase 9 - Production Hosting

Outside-code dependencies:

- [x] Create production R2 bucket: `tonos-public-content-prod`.
- [x] Configure production public access with temporary R2 public URL.
- [x] Configure production CORS.
- [x] Upload production media assets.
- [x] Upload production manifest.
- [x] Update `assets/content/content_environments.json` with the production
  URL.
- [ ] Switch the app default environment to production after a custom production
  domain is connected, or after deciding the temporary R2 URL should be used for
  app builds before a custom domain exists.

## Phase 10 - App UX And Resilience

- [x] Cache media locally.
- [x] Clean abandoned temporary downloads.
- [x] Avoid direct network-image fallback paths that bypass cache rules.
- [x] Show subtle loading state while thumbnails resolve.
- [x] Show retry affordance when a known media asset fails to cache.
- [x] Keep heatmap fallback behavior for missing media.
- [x] Add a Wi-Fi-only media download preference for new remote media
  downloads.

## Phase 11 - Nutrition Cloud Foundation

- [x] Define future food content namespace and entry contract.
- [x] Add example food content source.
- [x] Add food content source schema.
- [x] Document release rules for future food data and images.

Deferred until nutrition work resumes:

- [ ] Choose final food dataset source and license.
- [ ] Add food content DAO/repository/service sync.
- [ ] Add food image caching and UI fallback.
- [ ] Build first production nutrition cloud sync.

## Phase 12 - Release Operations

- [x] Add release report generation.
- [x] Add upload script generation.
- [x] Add release playbook.
- [x] Add rollback process.
- [x] Add content changelog template.
- [x] Document post-release checks.
