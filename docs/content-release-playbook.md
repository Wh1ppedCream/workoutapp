# Cloud Content Release Playbook

Use this checklist for exercise media releases and adapt the same process for
future nutrition content releases.

## Pre-Release

1. Confirm new media files are uploaded to the target R2 bucket.
2. Run the release check against the source file. For production releases, add
   `--base-url <production public URL>` so the manifest points at the
   production content host:

   ```powershell
   dart run tools/content_pipeline.dart release-check-exercise-media `
     --source tools/content_pipeline/exercise_media_source.example.json `
     --base-url https://YOUR_PRODUCTION_CONTENT_HOST `
     --output build/content/exercise_media_manifest.release.json `
     --coverage-output build/content/exercise_media_release_coverage.json `
     --release-report build/content/exercise_media_release_report.json `
     --upload-script build/content/upload_exercise_media_release.ps1 `
     --bucket tonos-public-content-prod `
     --require-licenses `
     --require-hashes `
     --quality-preset exercise-thumbnail
   ```

3. Review the generated release report and coverage report.
4. Diff the release manifest against the currently published manifest.
5. Keep a copy of the previously published manifest before replacing it.

## Publish Order

1. Upload media assets first.
2. Verify public asset URLs work.
3. Upload the manifest last.
4. Sync content from the app.
5. Spot-check at least one exercise with new media and one missing-media
   exercise that should still fall back to the heatmap.

Publishing the manifest last prevents the app from discovering assets before
their files are available.

## Rollback

1. Re-upload the previous manifest to the same manifest object key.
2. Do not delete newly uploaded assets immediately; keeping them is safer and
   avoids broken cache references if some devices already downloaded them.
3. Open the app, run content sync, and confirm the previous manifest version is
   active again.
4. Record the rollback reason in the content changelog.

If a specific asset is bad but the rest of the manifest is good, publish a new
manifest that removes or replaces only that asset.

## Changelog Process

Each content release should record:

- Release date and manifest version.
- Bucket/environment published to.
- Number of covered exercises and assets.
- Added, changed, and removed asset IDs.
- Any quality gates used, such as dimension or max-byte checks.
- Rollback instructions or the previous manifest file path.

Generated release reports are machine-readable; keep the short human history in
[content-release-changelog.md](content-release-changelog.md) for app-store and
support context.

## Post-Release Checks

- Confirm the app can sync the manifest.
- Confirm cached thumbnails continue to load offline.
- Confirm missing media falls back to body heatmaps.
- Confirm stale metadata from removed manifest entries is pruned locally.
- Confirm release coverage matches expectations.
