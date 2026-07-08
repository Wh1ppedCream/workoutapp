# Media Asset Standards

These standards keep cloud media lightweight, consistent, and safe to publish
while Tonos gradually expands exercise and nutrition media coverage.

## Exercise Thumbnails

- Preferred format: WebP for production; PNG is allowed for early dev batches
  and assets that need lossless transparency.
- Required shape: square, `1:1`.
- Recommended target size: `512 x 512`.
- Minimum release-check size: `512 x 512`.
- Suggested max size: `300 KB` per thumbnail.
- Use stable object paths: `exercises/<exercise_slug>/v<version>/thumb.png`.
- Keep thumbnails visually useful at small sizes in catalog rows.

## Exercise Animation / Video

- Use separate assets from thumbnails so the app can choose the right display.
- Preferred video format: MP4, H.264, no audio.
- Required shape: square, `1:1`.
- Recommended target size: `720 x 720`.
- Recommended duration: `5-8 seconds`.
- Suggested max size: `4 MB`.
- Keep animation/video clips short and tightly cropped around the movement.
- Use stable object paths such as
  `exercises/<exercise_slug>/v<version>/animation.mp4`.

## Metadata

For production batches, prefer including:

- `licenseId`
- `width`
- `height`
- `bytes`
- `sha256` when media files are local during build

The pipeline can enforce these with release-check flags when a batch is mature
enough:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source build/content/exercise_media_source.merged.json `
  --output build/content/exercise_media_manifest.release.json `
  --require-licenses `
  --quality-preset exercise-thumbnail
```

Do not require full metadata for early dev experiments unless the referenced
assets actually have that information available.

For animation-only batches, use:

```powershell
dart run tools/content_pipeline.dart release-check-exercise-media `
  --source build/content/exercise_media_source.merged.json `
  --output build/content/exercise_media_manifest.release.json `
  --require-licenses `
  --quality-preset exercise-animation
```

## Missing Media

Cloud media is additive. Exercises without media should stay absent from the
manifest and continue using the in-app body heatmap fallback.
