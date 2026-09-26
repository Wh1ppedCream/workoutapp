# Exercise Media Batch 009

This batch stages 15 user-supplied exercise thumbnails that were previously
missing from the active catalog. The original JPG/PNG files are preserved in
`incoming/exercise_media_batch_009/`; normalized WebP copies are staged under
`build/content/exercise_media_batch_009/`.

## Batch Contents

| Exercise | Catalog ID | Object path |
| --- | ---: | --- |
| External Rotation - Dumbbell | 60 | `exercises/external_rotation_dumbbell/v1/thumb.webp` |
| Front Squat - Cable Machine | 69 | `exercises/front_squat_cable_machine/v1/thumb.webp` |
| Glute Bridge - Dumbbell | 74 | `exercises/glute_bridge_dumbbell/v1/thumb.webp` |
| Glute Ham Raise | 75 | `exercises/glute_ham_raise/v1/thumb.webp` |
| Glute Kickback | 76 | `exercises/glute_kickback/v1/thumb.webp` |
| Glute Kickback - Cable Machine | 77 | `exercises/glute_kickback_cable_machine/v1/thumb.webp` |
| Hack Squat - Hack Squat Machine | 79 | `exercises/hack_squat_hack_squat_machine/v1/thumb.webp` |
| Hammer Curl - Cable Machine | 80 | `exercises/hammer_curl_cable_machine/v1/thumb.webp` |
| Leg Extension - Leg Extension Machine | 142 | `exercises/leg_extension_leg_extension_machine/v1/thumb.webp` |
| Leg Raise Twist (Hanging) | 147 | `exercises/leg_raise_twist_hanging/v1/thumb.webp` |
| Mountain Climber (Crossbody) | 157 | `exercises/mountain_climber_crossbody/v1/thumb.webp` |
| Row - Cable Machine | 219 | `exercises/row_cable_machine/v1/thumb.webp` |
| Overhead Tricep Extension - Cable Machine | 287 | `exercises/overhead_tricep_extension_cable_machine/v1/thumb.webp` |
| Overhead Tricep Extension - Dumbbell | 288 | `exercises/overhead_tricep_extension_dumbbell/v1/thumb.webp` |
| Overhead Tricep Extension - Barbell | 289 | `exercises/overhead_tricep_extension_barbell/v1/thumb.webp` |

## Local Quality Check

The staged copies are square `512x512` WebP files and each is below the
`300 KB` exercise-thumbnail gate. The batch source is
`tools/content_pipeline/exercise_media_batch_009.source.json`.

Run the repository validator from PowerShell:

```powershell
Set-Location E:\projects\env_test

dart run tools\content_pipeline.dart validate-exercise-media `
  --source tools\content_pipeline\exercise_media_batch_009.source.json `
  --strict `
  --require-licenses `
  --quality-preset exercise-thumbnail
```

## Promotion Status

- Local strict validation passed for all 15 assets.
- The batch preview manifest and all 15 objects were uploaded to
  `tonos-public-content-dev`.
- Remote validation passed for all 15 assets.
- The batch was merged into the canonical source as version 11.
- The canonical development manifest was uploaded and publicly verified at
  `https://pub-7eb72a1a315f4da3b30100ff6e694651.r2.dev/manifests/exercise_media_manifest.json`.
- Current development coverage is 169 of 300 exercises (56.3%), with 131
  exercises still missing thumbnails.

Production promotion remains separate and has not been performed.
