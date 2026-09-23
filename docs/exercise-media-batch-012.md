# Exercise Media Batch 012

## Promotion Status

- The source manifest and batch documentation are complete.
- All 23 normalized thumbnail objects were uploaded to the development
  bucket.
- The batch preview manifest was uploaded and remote validation passed for all
  23 assets.
- The canonical source is now version 14 with 238 exercise entries.
- The canonical development manifest was uploaded and publicly verified.

Current development coverage is 238 of 300 exercises (79.3%), with 62 still
missing thumbnails. This batch stages 23 user-supplied exercise thumbnails
that were previously listed as missing from the development catalog. The
source manifest is tools/content_pipeline/exercise_media_batch_012.source.json.
The original source images remain in the local batch staging folder, while
the normalized WebP files are written under
build/content/exercise_media_batch_012/.

## Batch Contents

| Exercise | Catalog ID | Object path |
| --- | ---: | --- |
| Reverse Lunge - Barbell | 210 | exercises/reverse_lunge_barbell/v1/thumb.webp |
| Russian Twist | 227 | exercises/russian_twist/v1/thumb.webp |
| Russian Twist - Dumbbell | 228 | exercises/russian_twist_dumbbell/v1/thumb.webp |
| Seated Chest Press | 229 | exercises/seated_chest_press/v1/thumb.webp |
| Seated Leg Curl | 230 | exercises/seated_leg_curl/v1/thumb.webp |
| Seated Leg Press | 231 | exercises/seated_leg_press/v1/thumb.webp |
| Shrug - Cable Machine | 232 | exercises/shrug_cable_machine/v1/thumb.webp |
| Shrug - Barbell | 233 | exercises/shrug_barbell/v1/thumb.webp |
| Shrug - Dumbbell | 234 | exercises/shrug_dumbbell/v1/thumb.webp |
| Side Bend - Cable Machine | 235 | exercises/side_bend_cable_machine/v1/thumb.webp |
| Side Bend - Dumbbell | 236 | exercises/side_bend_dumbbell/v1/thumb.webp |
| Side Bridge | 237 | exercises/side_bridge/v1/thumb.webp |
| Side Bridge - Dumbbell | 238 | exercises/side_bridge_dumbbell/v1/thumb.webp |
| Side Lunge | 239 | exercises/side_lunge/v1/thumb.webp |
| Side Lunge - Dumbbell | 241 | exercises/side_lunge_dumbbell/v1/thumb.webp |
| Single Arm Row - Cable Machine | 246 | exercises/single_arm_row_cable_machine/v1/thumb.webp |
| Single Arm Row - Dumbbell (Kneeling) | 247 | exercises/single_arm_row_dumbbell_kneeling/v1/thumb.webp |
| Single Arm Lat Pull-down - Lat Pulldown Machine | 249 | exercises/single_arm_lat_pull_down_lat_pulldown_machine/v1/thumb.webp |
| Single Arm Lat Pull-down - Cable Machine | 250 | exercises/single_arm_lat_pull_down_cable_machine/v1/thumb.webp |
| Single Arm Lat Raise - Cable Machine | 251 | exercises/single_arm_lat_raise_cable_machine/v1/thumb.webp |
| Single Arm Lat Raise - Dumbbell | 252 | exercises/single_arm_lat_raise_dumbbell/v1/thumb.webp |
| Zercher Carry - Barbell | 312 | exercises/zercher_carry_barbell/v1/thumb.webp |
| Zercher Squat - Barbell | 313 | exercises/zercher_squat_barbell/v1/thumb.webp |

## Preparation And Upload

Run this block from PowerShell. It pauses so the 23 source images can be
pasted into the staging folder, then converts, validates, builds the preview
manifest, uploads the normalized objects, and remotely validates the batch.

~~~powershell
Set-Location E:/projects/env_test
$ErrorActionPreference = 'Stop'

$batchRoot = 'build/content/exercise_media_batch_012'
$sourceImages = Join-Path $batchRoot 'source_images'
$sourceFile = 'tools/content_pipeline/exercise_media_batch_012.source.json'

New-Item -ItemType Directory -Force -Path $sourceImages | Out-Null
Write-Host "Paste the 23 source images into: $((Resolve-Path $sourceImages).Path)"
Read-Host 'Press Enter after the files are pasted'

$batch = Get-Content -Raw $sourceFile | ConvertFrom-Json
$expectedBases = @($batch.exercises | ForEach-Object { $_.exerciseName })
$files = @(Get-ChildItem -LiteralPath $sourceImages -File |
  Where-Object {
    @('.png', '.jpg', '.jpeg') -contains $_.Extension.ToLowerInvariant()
  })
$actualBases = @($files | ForEach-Object { $_.BaseName })

"Expected: $($expectedBases.Count) file(s)"
"Found: $($files.Count) file(s)"
"Missing:"
$missing = @($expectedBases | Where-Object { $_ -notin $actualBases })
$missing
"Unexpected:"
$unexpected = @($actualBases | Where-Object { $_ -notin $expectedBases })
$unexpected

if ($missing.Count -gt 0 -or $unexpected.Count -gt 0) {
  throw 'Source images do not exactly match batch 012. Fix the list above, then rerun.'
}

foreach ($exercise in $batch.exercises) {
  $inputFile = @($files | Where-Object {
    $_.BaseName -eq $exercise.exerciseName
  })[0]
  $asset = @($exercise.assets | Where-Object { $_.type -eq 'thumbnail' })[0]
  $output = $asset.localFile

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $output) | Out-Null
  magick $inputFile.FullName -resize '512x512!' -strip -quality 85 $output

  if ($LASTEXITCODE -ne 0) {
    throw "Image conversion failed: $($exercise.exerciseName)"
  }
}

$outputs = @(Get-ChildItem -LiteralPath (Join-Path $batchRoot 'exercises') -Recurse -Filter thumb.webp)
"Built: $($outputs.Count) WebP file(s)"

if ($outputs.Count -ne $expectedBases.Count) {
  throw "Expected $($expectedBases.Count) WebP files but built $($outputs.Count)."
}

dart run tools/content_pipeline.dart validate-exercise-media --source $sourceFile --strict --require-licenses --quality-preset exercise-thumbnail
if ($LASTEXITCODE -ne 0) { throw 'Local batch validation failed.' }

dart run tools/content_pipeline.dart build-exercise-media --source $sourceFile --output 'build/content/exercise_media_batch_012_manifest.json' --upload-script 'build/content/upload_exercise_media_batch_012.ps1' --bucket tonos-public-content-dev --manifest-object 'manifests/exercise_media_batch_012.preview.json'
if ($LASTEXITCODE -ne 0) { throw 'Batch manifest build failed.' }

powershell -ExecutionPolicy Bypass -File './build/content/upload_exercise_media_batch_012.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Development upload failed.' }

dart run tools/content_pipeline.dart validate-exercise-media --source $sourceFile --check-remote --strict --require-licenses --quality-preset exercise-thumbnail
if ($LASTEXITCODE -ne 0) { throw 'Remote batch validation failed.' }
~~~

Promotion completed with the release check, a manifest diff of +23/-0/~0,
canonical manifest upload, and public coverage verification. The generated
reports remain under build/content for release accounting.
