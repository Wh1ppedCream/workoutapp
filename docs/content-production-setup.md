# Tonos Production Content Setup

Phase 5 separates development content from production content so test assets can
move through a repeatable promotion path before users see them.

## Environments

The app reads bundled content environments from:

```text
assets/content/content_environments.json
```

Current environments:

- `development`: points at the R2 dev public bucket used for testing.
- `production`: reserved for the production bucket or custom CDN domain.

The production bucket exists as `tonos-public-content-prod`. Until a custom
domain is purchased and connected, production points at the temporary R2 public
URL:

```text
https://pub-3e431bbfeef5400c9ccbea926ea9904f.r2.dev
```

This is good enough for internal testing and pipeline validation. Before a broad
public release, prefer replacing it with a stable custom domain such as
`https://content.tonos.app`.

Current temporary production manifest:

```text
https://pub-3e431bbfeef5400c9ccbea926ea9904f.r2.dev/manifests/exercise_media_manifest.json
```

The production bucket was seeded for pipeline validation, but it is not yet an
approved release source. The canonical development source is manifest version
10 with 154 of 310 exercises covered (49.7%) across batches 001 through 008.
Production was last audited at version 5 with 62 assets. Recalculate the exact
promotion delta from the current manifests before release instead of relying on
the older 65-asset estimate. Promote the complete canonical asset set and
manifest before approving production content for distribution.

## Build Contract

Release routing is selected at compile time rather than by editing the bundled
default:

- `TONOS_CONTENT_ENVIRONMENT` selects an environment ID from
  `content_environments.json`.
- `TONOS_CONTENT_ALLOW_OVERRIDES=false` locks release artifacts to that target.
- `defaultEnvironment` remains the safe fallback for debug/internal builds that
  omit an explicit target. It is not a production release switch.
- Locked builds ignore saved environment choices and custom manifest URLs.
- Unlocked development builds preserve the existing precedence: a valid HTTPS
  custom exercise manifest, then a valid saved environment, then the build
  target.
- Every configured manifest host must be listed in that environment's
  `allowedManifestHosts`; production and non-production hosts must be distinct.

A content scope includes the selected environment and resolved manifest URLs.
When that scope changes, Tonos clears only exercise/shared cloud metadata and
prunes its media cache before resynchronizing. User workouts, plans, nutrition,
measurements, preferences, and media licenses are not deleted.

Run both preflights before approving a content configuration:

```powershell
dart run tools/content_environment_check.dart `
  --source assets/content/content_environments.json `
  --target development

dart run tools/content_environment_check.dart `
  --source assets/content/content_environments.json `
  --target production `
  --locked
```

Unknown targets, invalid HTTPS URLs, missing host allowlists, multiple production
environments, or an unlocked production target fail before an artifact is
built. Runtime policy applies the same fail-closed checks.

## Current Environment Decision

`assets/content/content_environments.json` intentionally keeps
`defaultEnvironment` set to `development`. This is now only the safe fallback
for ordinary debug/internal builds; official artifacts select their target
explicitly.

The production environment can be preflighted and used for controlled internal
validation, but it is not approved for broad distribution while cloud content
is incomplete and its host is a temporary `r2.dev` URL. Cloudflare reserves
`r2.dev` public URLs for development and applies variable rate limits, so a
stable custom domain is still preferred before a broad release.

TODO before broad release:

1. Buy/connect a stable content domain, for example `content.tonos.app`, to
   the `tonos-public-content-prod` bucket.
2. Complete development spot checks for batches 004 through 008 and uncovered
   exercise fallbacks.
3. Upload all current canonical media assets to the production bucket.
4. Rebuild and upload the production manifest with the final production
   `--base-url`.
5. Update the production manifest URLs and `allowedManifestHosts` if the host
   changes.
6. Run a clean-install production sync, offline fallback, and recovery check.
7. Run the locked production preflight and use the protected production release
   workflow. Do not edit `defaultEnvironment` to route a release.

## Recommended Cloud Layout

Use separate dev and production object stores or prefixes:

```text
tonos-public-content-dev/
  manifests/exercise_media_manifest.json
  exercises/<exercise_slug>/v<asset_version>/<asset_file>

tonos-public-content-prod/
  manifests/exercise_media_manifest.json
  exercises/<exercise_slug>/v<asset_version>/<asset_file>
```

For production, prefer a stable CDN/custom domain when ready:

```text
https://content.tonos.app/manifests/exercise_media_manifest.json
```

If a custom domain is not ready yet, use the production bucket's Cloudflare R2
public URL once public access is enabled in the Cloudflare dashboard.

## Production Bucket Setup

The production R2 bucket is:

```text
tonos-public-content-prod
```

Recommended production CORS policy is tracked in:

```text
docs/r2-production-cors-policy.json
```

Apply it in the production bucket's Cloudflare dashboard CORS settings after
public access or a custom domain is configured. The policy only allows public
`GET` and `HEAD` reads, which is appropriate for static public content.

## Promotion Flow

1. Add or update media files in the source batch.
2. Build and remote-check a dev manifest through the release gate:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.json `
  --coverage-output build/content/exercise_media_release_coverage.json `
  --release-report build/content/exercise_media_release_report.json `
  --upload-script build/content/upload_exercise_media_release.ps1 `
  --bucket tonos-public-content-dev
```

3. Compare generated content against the currently published manifest:

```powershell
dart run tools/content_pipeline.dart diff-exercise-media `
  --old https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json `
  --new build/content/exercise_media_manifest.json `
  --report build/content/exercise_media_diff.json
```

4. Add stricter release gates before promoting mature production batches:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.json `
  --coverage-output build/content/exercise_media_release_coverage.json `
  --release-report build/content/exercise_media_release_report.json `
  --require-licenses `
  --quality-preset exercise-thumbnail
```

5. Upload media files first, then upload the manifest last.

The manifest should be the final object uploaded so users never sync references
to media files that are not available yet.

## Production Manifest Build

Use the same canonical source file for development and production. Override the
base URL at build time so production manifests point at the production CDN/R2
public URL:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --base-url https://YOUR_PRODUCTION_CONTENT_HOST `
  --output build/content/exercise_media_manifest.production.json `
  --coverage-output build/content/exercise_media_production_coverage.json `
  --release-report build/content/exercise_media_production_report.json `
  --upload-script build/content/upload_exercise_media_production.ps1 `
  --bucket tonos-public-content-prod `
  --require-licenses `
  --require-hashes `
  --quality-preset exercise-thumbnail
```

Only run the production manifest upload after every referenced media object is
already uploaded to `tonos-public-content-prod` and the production public URL
successfully serves those objects.

## Production Media Uploads

Before publishing a production manifest, upload every current media batch to
the production bucket. The following pattern reuses a local batch source that
already contains `localFile` paths; replace `007` with each batch that has not
yet been promoted:

```powershell
$batch = "007"

dart run tools/content_pipeline.dart build-exercise-media `
  --source "tools/content_pipeline/exercise_media_batch_$batch.source.json" `
  --output "build/content/exercise_media_batch_$batch.prod_preview_manifest.json" `
  --upload-script "build/content/upload_exercise_media_batch_$batch.prod.ps1" `
  --bucket tonos-public-content-prod `
  --manifest-object "manifests/exercise_media_batch_$batch.preview.json"

powershell -ExecutionPolicy Bypass -File "./build/content/upload_exercise_media_batch_$batch.prod.ps1"
```

The preview manifests are useful for upload verification only. The app should
sync from `manifests/exercise_media_manifest.json`, which is produced by the
production release-check command after the production base URL is known.

## Versioning Rules

- Increase the top-level manifest `version` for every production manifest
  release.
- Increase an asset `version` when the file at that logical asset changes.
- Prefer immutable object keys for changed files, for example:

```text
exercises/bench_press_barbell/v2/thumb.png
```

- Do not overwrite production media in place unless it is a correction before
  public use.

## Cache Rules

Suggested production cache behavior:

- Media files: long cache lifetime because object keys include versions.
- Manifest JSON: short cache lifetime so app clients can discover updates.

The app already stores downloaded media locally and can clear its cache from
Database Settings.

Database Settings also includes a Wi-Fi-only media download preference. When it
is enabled, the app still syncs manifests and shows already-cached media, but it
waits for Wi-Fi or ethernet before downloading new remote thumbnails or videos.

## App Release Checklist

Before a Play Console release with production cloud content:

1. Create or confirm the production bucket and stable domain.
2. Upload every canonical production media file before its manifest.
3. Build and upload the production manifest using the production base URL.
4. Update the production URLs and `allowedManifestHosts` in
   `assets/content/content_environments.json`.
5. Run the locked production content preflight.
6. Run the protected production workflow, which builds with
   `TONOS_CONTENT_ENVIRONMENT=production` and
   `TONOS_CONTENT_ALLOW_OVERRIDES=false`.
7. Install the signed artifact and verify clean-install sync, cached media,
   offline fallbacks, recovery, and that content controls are read-only.

Keep `defaultEnvironment` on `development` as the safe no-define fallback. A
release target is approved through its explicit build contract, not by changing
that fallback.
