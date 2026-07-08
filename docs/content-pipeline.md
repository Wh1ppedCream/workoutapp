# Tonos Content Pipeline

Tonos keeps large shared media out of the app bundle. The app syncs a small JSON
manifest, downloads only the media it needs, and caches files locally.

Production environment setup and promotion rules live in
`docs/content-production-setup.md`.

Media size, format, and metadata targets live in
`docs/media-asset-standards.md`.

## Current Flow

1. Put media in Cloudflare R2 using stable object keys.
2. Describe those media files in a source JSON file.
3. Build an app-ready manifest with `tools/content_pipeline.dart`.
4. Upload the generated manifest to R2.
5. Sync the manifest from Database Settings in the app.

The app-ready manifest lives at:

```text
manifests/exercise_media_manifest.json
```

## Build The Exercise Media Manifest

The pipeline uses `package:crypto` for SHA-256 hashes. If this is the first
time after pulling these changes, run:

```powershell
flutter pub get
```

Run this from the repository root:

```powershell
dart run tools/content_pipeline.dart build-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.json `
  --check-remote
```

The source file validates exercise IDs against `assets/exercises.json`. Because
exercise IDs are assigned from the JSON list order during seeding, each entry
should include both `exerciseId` and `exerciseName` so reorders are caught.

## Generate An Upload Script

If source assets include `localFile`, the tool can create a repeatable Wrangler
upload script:

```powershell
dart run tools/content_pipeline.dart build-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.json `
  --upload-script build/content/upload_exercise_media.ps1 `
  --bucket tonos-public-content-dev
```

Then inspect and run:

```powershell
powershell -ExecutionPolicy Bypass -File build/content/upload_exercise_media.ps1
```

The generated script uploads local media files first, then uploads the manifest
to `manifests/exercise_media_manifest.json`.

## Source File Shape

```json
{
  "namespace": "exercise_media",
  "version": 1,
  "baseUrl": "https://example.r2.dev",
  "exercises": [
    {
      "exerciseId": 7,
      "exerciseName": "Bench Press - Barbell",
      "slug": "bench_press_barbell",
      "assets": [
        {
          "assetId": "bench_press_barbell_thumb_v1",
          "type": "image",
          "path": "exercises/bench_press_barbell/v1/thumb.png",
          "localFile": "media/exercises/bench_press_barbell/thumb.png",
          "title": "Bench Press - Barbell thumbnail",
          "sortOrder": 0,
          "version": 1,
          "licenseId": "tonos_original"
        }
      ]
    }
  ]
}
```

If `localFile` exists, the tool fills `bytes` and `sha256`. If only remote URLs
exist, the manifest is still valid; add `--check-remote` to verify the URLs.

## Validation Only

```powershell
dart run tools/content_pipeline.dart validate-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --check-remote `
  --strict
```

Use `--strict` when preparing release content so warnings fail the command.

For release batches, also add metadata gates once local media files or licensed
assets are being tracked:

```powershell
dart run tools/content_pipeline.dart validate-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --check-remote `
  --require-hashes `
  --require-licenses `
  --strict
```

## Release Check Before Publishing

Before uploading a manifest that users will sync, run the release check. This
command always checks every referenced media URL remotely and fails on any
warning or error, so missing R2 objects cannot be promoted accidentally:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.release.json `
  --coverage-output build/content/exercise_media_release_coverage.json `
  --release-report build/content/exercise_media_release_report.json
```

See [content-release-playbook.md](content-release-playbook.md) for the full
publish, verification, rollback, and changelog process.

Optional stricter gates can be layered in as the media library matures:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_manifest.release.json `
  --coverage-output build/content/exercise_media_release_coverage.json `
  --release-report build/content/exercise_media_release_report.json `
  --require-licenses `
  --quality-preset exercise-thumbnail `
  --min-coverage 25
```

Use `--min-coverage` only when intentionally enforcing a rollout target. Partial
coverage is allowed by default so exercises without cloud media can keep using
the app's body heatmap fallback.

## Compare Manifest Versions

Before replacing the live manifest, compare the current version with the newly
generated version:

```powershell
dart run tools/content_pipeline.dart diff-exercise-media `
  --old https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json `
  --new build/content/exercise_media_manifest.json `
  --report build/content/exercise_media_diff.json
```

This reports added, removed, changed, and unchanged assets. Use the JSON report
as a quick audit artifact before uploading to production.

## Track Exercise Media Coverage

As the exercise library grows, use the coverage command to see how many bundled
exercises have media attached:

```powershell
dart run tools/content_pipeline.dart coverage-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_coverage.json `
  --missing-output build/content/exercise_media_missing.json
```

Use `--manifest <path-or-url>` instead of `--source` when checking an app-ready
manifest that is already uploaded:

```powershell
dart run tools/content_pipeline.dart coverage-exercise-media `
  --manifest https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json `
  --media-type thumbnail
```

The report includes total exercises, covered exercises, missing exercises,
coverage percent, media-type counts, and JSON lists for covered/missing rows.

## Scaffold The Next Media Batch

To prepare placeholder source entries for the next batch of missing exercise
media, run:

```powershell
dart run tools/content_pipeline.dart scaffold-exercise-media `
  --source tools/content_pipeline/exercise_media_source.example.json `
  --output build/content/exercise_media_missing_source.json `
  --limit 10 `
  --base-url https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev `
  --license-id tonos_original
```

This writes source JSON entries for missing exercises only. The generated paths
follow this pattern:

```text
exercises/<exercise_slug>/v1/thumb.png
```

After replacing placeholders with real uploaded files, validate without remote
checks first:

```powershell
dart run tools/content_pipeline.dart validate-exercise-media `
  --source build/content/exercise_media_missing_source.json `
  --strict
```

Only add `--check-remote` after the referenced objects have been uploaded.

The first Phase 7 batch checklist lives in
`docs/exercise-media-batch-001.md`.

## Merge A Completed Batch

After the scaffolded media files have been created, uploaded, and validated with
remote checks, merge the completed batch into the canonical source file:

```powershell
dart run tools/content_pipeline.dart merge-exercise-media-source `
  --base tools/content_pipeline/exercise_media_source.example.json `
  --batch build/content/exercise_media_missing_source.json `
  --output build/content/exercise_media_source.merged.json `
  --bump-version
```

Then build and diff the merged manifest before replacing the live manifest:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source build/content/exercise_media_source.merged.json `
  --output build/content/exercise_media_manifest.json `
  --coverage-output build/content/exercise_media_release_coverage.json `
  --release-report build/content/exercise_media_release_report.json `
  --upload-script build/content/upload_exercise_media_release.ps1 `
  --bucket tonos-public-content-dev

dart run tools/content_pipeline.dart diff-exercise-media `
  --old https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json `
  --new build/content/exercise_media_manifest.json `
  --report build/content/exercise_media_diff.json
```

If the diff looks right, replace the canonical source file with the merged
source, upload the manifest, and sync Cloud Content in the app.

## Source Schema

The source JSON contract is documented in:

```text
tools/content_pipeline/exercise_media_source.schema.json
```

Editors that support JSON Schema can use this to catch missing fields before the
pipeline runs.
