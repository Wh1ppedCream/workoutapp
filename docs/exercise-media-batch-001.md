# Exercise Media Batch 001

Phase 7 starts by expanding exercise thumbnail coverage from the 5 test
thumbnails to a repeatable first production-style batch.

## Batch Scope

Create one `thumbnail` image for each exercise below and upload it to the listed
R2 object path. The tracked batch source lives at
`tools/content_pipeline/exercise_media_batch_001.source.json`.

Place the local files under `build/content/exercise_media_batch_001/` using the
same nested paths. The batch source uses these `localFile` paths so the pipeline
can read image dimensions, byte size, and SHA-256 before upload.

| Exercise | Object path |
| --- | --- |
| Ab Wheel | `exercises/ab_wheel/v1/thumb.webp` |
| Arm Circles | `exercises/arm_circles/v1/thumb.webp` |
| Arnold Press | `exercises/arnold_press/v1/thumb.webp` |
| Back Extension | `exercises/back_extension/v1/thumb.webp` |
| Ball Slam | `exercises/ball_slam/v1/thumb.webp` |
| Bench Press - Barbell (Close Grip) | `exercises/bench_press_barbell_close_grip/v1/thumb.webp` |
| Bench Press - Dumbbells | `exercises/bench_press_dumbbells/v1/thumb.webp` |
| Bench Press - Smith Machine | `exercises/bench_press_smith_machine/v1/thumb.webp` |
| Bench Press - Cable Machine | `exercises/bench_press_cable_machine/v1/thumb.webp` |
| Bicep Curl - Barbell | `exercises/bicep_curl_barbell/v1/thumb.webp` |

## Quality Targets

- Use WebP for production-ready thumbnails when possible; PNG is still allowed
  for dev thumbnails or assets that need lossless transparency.
- Keep the visual style consistent across the batch.
- Use square `512 x 512` images so the app can display thumbnails in small cards
  without awkward clipping.
- Keep each thumbnail under `300 KB`.
- Use only media Tonos owns, has licensed, or is allowed to redistribute.

## Promotion Checklist

1. Create the 10 thumbnail files.
2. Copy/rename them into the local staging paths above.
3. Validate local metadata before upload:

   ```powershell
   dart run tools/content_pipeline.dart validate-exercise-media `
     --source tools/content_pipeline/exercise_media_batch_001.source.json `
     --strict `
     --require-licenses `
     --quality-preset exercise-thumbnail
   ```

4. Build the batch manifest and upload script:

   ```powershell
   dart run tools/content_pipeline.dart build-exercise-media `
     --source tools/content_pipeline/exercise_media_batch_001.source.json `
     --output build/content/exercise_media_batch_001_manifest.json `
     --upload-script build/content/upload_exercise_media_batch_001.ps1 `
     --bucket tonos-public-content-dev `
     --manifest-object manifests/exercise_media_batch_001.preview.json
   ```

5. Upload the batch files using the generated script:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\build\content\upload_exercise_media_batch_001.ps1
   ```

6. Validate the uploaded batch with `--check-remote`:

   ```powershell
   dart run tools/content_pipeline.dart validate-exercise-media `
     --source tools/content_pipeline/exercise_media_batch_001.source.json `
     --check-remote `
     --strict `
     --require-licenses `
     --quality-preset exercise-thumbnail
   ```

7. Merge the batch source into the canonical source:

   ```powershell
   dart run tools/content_pipeline.dart merge-exercise-media-source `
     --base tools/content_pipeline/exercise_media_source.example.json `
     --batch tools/content_pipeline/exercise_media_batch_001.source.json `
     --output tools/content_pipeline/exercise_media_source.example.json `
     --bump-version `
     --strip-local-files
   ```

8. Run `release-check-exercise-media` with `--quality-preset exercise-thumbnail`
   to build and remote-check the manifest.
9. Upload the manifest.
10. Sync Cloud Content in the app and confirm thumbnails render.

Do not merge this batch into the canonical source until the remote files exist
and validation passes.

## Legacy Test Thumbnail Upgrade

The first five dev thumbnails were uploaded as large PNG files. Before publishing
the expanded release manifest, replace those remote objects with smaller WebP
versions using the tracked upgrade source:

`tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json`

The upgrade keeps each original `assetId`, bumps the asset `version`, and moves
the object path to `v2/thumb.webp`. Keeping the same `assetId` lets
`merge-exercise-media-source --replace-assets` update the existing records
instead of creating duplicate thumbnail assets.

1. Create the local folders and download the current PNGs:

   ```powershell
   $root = "build\content\exercise_media_legacy_thumb_upgrade\exercises"
   $baseUrl = "https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev"
   $slugs = @(
     "barbell_squat",
     "bench_press_barbell",
     "bicep_curl_dumbbell",
     "deadlift_barbell",
     "lat_pulldown_lat_pulldown_machine"
   )

   foreach ($slug in $slugs) {
     $dir = Join-Path $root "$slug\v2"
     New-Item -ItemType Directory -Force $dir | Out-Null
     Invoke-WebRequest `
       -Uri "$baseUrl/exercises/$slug/v1/thumb.png" `
       -OutFile (Join-Path $dir "thumb.png")
   }
   ```

2. Convert the PNG files to 512 x 512 WebP thumbnails:

   ```powershell
   $magick = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"

   Get-ChildItem $root -Recurse -Filter thumb.png | ForEach-Object {
     $png = $_.FullName
     $webp = Join-Path $_.DirectoryName "thumb.webp"

     & $magick $png `
       -resize "512x512^" `
       -gravity center `
       -extent 512x512 `
       -strip `
       -quality 82 `
       $webp
   }
   ```

3. Confirm the generated WebP files are comfortably under 300 KB:

   ```powershell
   Get-ChildItem $root -Recurse -Filter thumb.webp |
     Select-Object FullName, @{Name="KB";Expression={[math]::Round($_.Length / 1KB, 1)}}
   ```

4. Validate, upload, and remote-check the upgrade batch:

   ```powershell
   dart run tools/content_pipeline.dart validate-exercise-media `
     --source tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json `
     --strict `
     --require-licenses `
     --quality-preset exercise-thumbnail

   dart run tools/content_pipeline.dart build-exercise-media `
     --source tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json `
     --output build/content/exercise_media_legacy_thumb_upgrade_manifest.json `
     --upload-script build/content/upload_exercise_media_legacy_thumb_upgrade.ps1 `
     --bucket tonos-public-content-dev `
     --manifest-object manifests/exercise_media_legacy_thumb_upgrade.preview.json

   powershell -ExecutionPolicy Bypass -File .\build\content\upload_exercise_media_legacy_thumb_upgrade.ps1

   dart run tools/content_pipeline.dart validate-exercise-media `
     --source tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json `
     --check-remote `
     --strict `
     --require-licenses `
     --quality-preset exercise-thumbnail
   ```

5. Replace the legacy PNG records in the canonical source:

   ```powershell
   dart run tools/content_pipeline.dart merge-exercise-media-source `
     --base tools/content_pipeline/exercise_media_source.example.json `
     --batch tools/content_pipeline/exercise_media_legacy_thumb_upgrade.source.json `
     --output tools/content_pipeline/exercise_media_source.example.json `
     --bump-version `
     --strip-local-files `
     --replace-assets
   ```

6. Run the full release check again before publishing the manifest.
