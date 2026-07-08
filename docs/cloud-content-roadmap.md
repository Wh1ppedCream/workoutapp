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

Outside-code dependencies:

- [ ] Create final production bucket or CDN domain.
- [ ] Update production manifest URL once the final URL exists.
- [ ] Switch the app default to production only after production content is
  ready.

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

- [ ] Create/collect Batch 001 thumbnail or animation files.
- [ ] Upload Batch 001 media files to R2.
- [ ] Validate Batch 001 with remote checks after upload.
- [ ] Merge Batch 001 into the canonical source file after media exists.
- [ ] Upload the expanded manifest.
- [ ] Sync in-app and spot-check new media plus missing-media fallbacks.

## Phase 8 - Media Quality

- [x] Add optional dimension and byte-size release gates.
- [x] Auto-read dimensions from local PNG, JPEG, GIF, and WebP files.
- [x] Document asset standards.

Product/content decisions still needed:

- [ ] Final thumbnail dimensions and aspect ratio.
- [ ] Final animation/video format, dimensions, duration, and size limits.

## Phase 9 - Production Hosting

Outside-code dependencies:

- [ ] Create production R2 bucket or custom CDN setup.
- [ ] Configure production CORS.
- [ ] Upload production media assets.
- [ ] Upload production manifest.
- [ ] Update `assets/content/content_environments.json` with the production
  URL.
- [ ] Switch the app default environment to production.

## Phase 10 - App UX And Resilience

- [x] Cache media locally.
- [x] Clean abandoned temporary downloads.
- [x] Avoid direct network-image fallback paths that bypass cache rules.
- [x] Show subtle loading state while thumbnails resolve.
- [x] Show retry affordance when a known media asset fails to cache.
- [x] Keep heatmap fallback behavior for missing media.

Potential future option:

- [ ] Add a Wi-Fi-only media download preference if users need it.

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
