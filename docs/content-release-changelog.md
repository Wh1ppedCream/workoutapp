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

## 2026-09-22 - exercise_media v15 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 253 of 300 exercises, 253 thumbnail assets (84.3%)
- Added assets: 15 supplied thumbnails from batch 013
- Changed assets: none
- Removed assets: none
- Quality gates: strict local validation with licenses and the
  exercise-thumbnail preset; remote batch validation; canonical release
  check; manifest diff +15/-0/~0; public coverage verification
- Previous manifest: development version 14
- Notes: development canonical state only. Production promotion and clean-install
  synchronization remain pending.

## 2026-09-21 - exercise_media v14 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 238 of 300 exercises, 238 thumbnail assets (79.3%)
- Added assets: 23 supplied thumbnails from batch 012
- Changed assets: none
- Removed assets: none
- Quality gates: strict local validation with licenses and the
  exercise-thumbnail preset; remote batch validation; canonical release
  check; manifest diff +23/-0/~0; public coverage verification
- Previous manifest: development version 13
- Notes: development canonical state only. Production promotion and clean-install
  synchronization remain pending.

## 2026-09-20 - exercise_media v13 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 215 of 300 exercises, 215 thumbnail assets (71.7%)
- Added assets: 26 supplied thumbnails from batch 011
- Changed assets: none
- Removed assets: none
- Quality gates: strict local validation with licenses and the
  exercise-thumbnail preset; remote batch validation; canonical release
  check; manifest diff +26/-0/~0; public coverage verification
- Previous manifest: development version 12
- Notes: development canonical state only. Production promotion and clean-install
  synchronization remain pending.

## 2026-09-19 - exercise_media v12 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 189 of 300 exercises, 189 thumbnail assets (63.0%)
- Added assets: 20 supplied thumbnails from batch 010
- Changed assets: none
- Removed assets: none
- Quality gates: strict local validation with licenses and the
  exercise-thumbnail preset; remote batch validation; canonical release
  check; manifest diff +20/-0/~0; public coverage verification
- Previous manifest: development version 11
- Notes: development canonical state only. Production promotion and clean-install
  synchronization remain pending.

## 2026-09-18 - exercise_media v11 development canonical

- Environment: `tonos-public-content-dev`
- Manifest URL:
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`
- Coverage: 169 of 300 exercises, 169 thumbnail assets (56.3%)
- Added assets: 15 supplied thumbnails from batch 009
- Changed assets: none
- Removed assets: none
- Quality gates: strict local validation with licenses and the
  `exercise-thumbnail` preset; remote batch validation; canonical release
  check; public manifest status `200` verification
- Previous manifest: development version 10
- Notes: development canonical state only. Production promotion and clean-install
  synchronization remain pending.

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
