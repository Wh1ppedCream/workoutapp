# Tonos Content Pipeline

Tonos keeps large shared media out of the app bundle. The app syncs a small JSON
manifest, downloads only the media it needs, and caches files locally.

Production environment setup and promotion rules live in
`docs/content-production-setup.md`.

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

## Source Schema

The source JSON contract is documented in:

```text
tools/content_pipeline/exercise_media_source.schema.json
```

Editors that support JSON Schema can use this to catch missing fields before the
pipeline runs.
