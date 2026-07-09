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

The temporary production manifest has passed release checks for the current
15 exercise thumbnail assets.

## Current Environment Decision

`assets/content/content_environments.json` intentionally keeps
`defaultEnvironment` set to `development` for now.

Development is still the safest default while cloud content is expanding and
while production uses a temporary `r2.dev` public URL instead of a custom domain.
The production environment is configured and release-checked, so it can be used
for validation, internal tests, or manual app-side sync checks.

TODO before broad release:

1. Buy/connect a stable content domain, for example `content.tonos.app`, or
   explicitly decide that the temporary R2 public URL should be used for the
   current release.
2. Rebuild and upload the production manifest with the final production
   `--base-url`.
3. Update the production `exerciseMediaManifestUrl` if the host changes.
4. Change `defaultEnvironment` from `development` to `production`.
5. Run app-side sync and thumbnail fallback checks again.

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

Before publishing a production manifest, upload the current media batches to the
production bucket. These commands reuse the local batch sources that already
contain `localFile` paths:

```powershell
dart run tools/content_pipeline.dart build-exercise-media `
  --source tools/content_pipeline/exercise_media_batch_001.source.json `
  --output build/content/exercise_media_batch_001_prod_preview_manifest.json `
  --upload-script build/content/upload_exercise_media_batch_001_prod.ps1 `
  --bucket tonos-public-content-prod `
  --manifest-object manifests/exercise_media_batch_001.preview.json

powershell -ExecutionPolicy Bypass -File .\build\content\upload_exercise_media_batch_001_prod.ps1

dart run tools/content_pipeline.dart build-exercise-media `
  --source tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json `
  --output build/content/exercise_media_legacy_thumb_upgrade_prod_preview_manifest.json `
  --upload-script build/content/upload_exercise_media_legacy_thumb_upgrade_prod.ps1 `
  --bucket tonos-public-content-prod `
  --manifest-object manifests/exercise_media_legacy_thumb_upgrade.preview.json

powershell -ExecutionPolicy Bypass -File .\build\content\upload_exercise_media_legacy_thumb_upgrade_prod.ps1
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

## App Release Checklist

Before a Play Console release with production cloud content:

1. Create or confirm the production bucket/domain.
2. Upload the production media files.
3. Build and upload the production manifest using the production base URL.
4. Update `assets/content/content_environments.json` with the production
   `exerciseMediaManifestUrl`.
5. Set `defaultEnvironment` to `production` when production content is ready for
   real users. Keep it on `development` during active media iteration or while
   production is only using a temporary R2 public URL.
6. Run format/analyze.
7. Build a release app bundle.

During development or internal testing, keep the default environment as
`development` so the app points at the safe test bucket.
