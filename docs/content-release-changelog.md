# Cloud Content Release Changelog

Keep one entry per published cloud content release. Generated release reports
live in `build/content`; this file is the human-readable history.

## Template

### YYYY-MM-DD - exercise_media vN

- Environment:
- Manifest URL:
- Coverage:
- Added assets:
- Changed assets:
- Removed assets:
- Quality gates:
- Previous manifest backup:
- Notes:

## 2026-08-08 - exercise_media v9 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 127/313 exercises, 127 assets (40.6%)
- Added assets: canonical source now includes validated batches 001 through 007
- Changed assets: replacements included in the merged canonical source
- Removed assets: none
- Quality gates: licenses, hashes, remote URL checks, and exercise-thumbnail
  quality preset during release checks
- Previous manifest backup: use the prior generated manifest from the promotion
  record before replacing a published environment
- Notes: development canonical state only. Production promotion and
  clean-install validation remain pending.

## 2026-07-07 - exercise_media v1 dev seed

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 5/313 exercises, 5 assets
- Added assets: initial five test thumbnails
- Changed assets: none
- Removed assets: none
- Quality gates: remote URL release check
- Previous manifest backup: not applicable
- Notes: first development manifest used to prove sync, cache, and heatmap
  fallback behavior.
