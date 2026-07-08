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
- `production`: reserved for the future production bucket or custom CDN domain.

Until production storage is created, the production manifest URL is intentionally
blank. This avoids silently shipping an invalid or accidental content endpoint.

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
  --require-dimensions `
  --min-width 256 `
  --min-height 256 `
  --max-bytes 250000
```

5. Upload media files first, then upload the manifest last.

The manifest should be the final object uploaded so users never sync references
to media files that are not available yet.

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
2. Upload the production manifest and media files.
3. Update `assets/content/content_environments.json` with the production
   `exerciseMediaManifestUrl`.
4. Set `defaultEnvironment` to `production` when production content is ready for
   real users.
5. Run format/analyze.
6. Build a release app bundle.

During development or internal testing, keep the default environment as
`development` so the app points at the safe test bucket.
