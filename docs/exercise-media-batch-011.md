# Exercise Media Batch 011

## Source Filename Exception

The catalog name is Tricep Dip - Assisted Dip/Pull-Up Machine, but / is not
valid in a Windows filename. The preparation command therefore expects the
source image as Tricep Dip - Assisted Dip Pull-Up Machine and maps it to the
canonical catalog name before conversion.

## Promotion Status

- The source manifest and batch documentation are complete.
- All 26 normalized thumbnail objects were uploaded to the development bucket.
- The batch preview manifest was uploaded and remote validation passed for all
  26 assets.
- The preparation block accepts .png, .jpg, and .jpeg source images, converts
  them to square 512x512 WebP files, and runs strict local validation.
- The canonical source is now version 13 with 215 exercise entries.
- The canonical development manifest was uploaded and publicly verified.

Current development coverage is 215 of 300 exercises (71.7%), with 85 still
missing thumbnails.
This batch stages 26 user-supplied exercise thumbnails that are currently
listed as missing from the development catalog. The source manifest is
tools/content_pipeline/exercise_media_batch_011.source.json. The original
source images should remain in the local batch staging folder, while the
normalized WebP files are written under
build/content/exercise_media_batch_011/.

## Batch Contents

| Exercise | Catalog ID | Object path |
| --- | ---: | --- |
| Row - Resistance Band | 217 | exercises/row_resistance_band/v1/thumb.webp |
| Row - Smith Machine | 220 | exercises/row_smith_machine/v1/thumb.webp |
| Row - Dumbbell | 225 | exercises/row_dumbbell/v1/thumb.webp |
| Squat - Landmine Attachment | 271 | exercises/squat_landmine_attachment/v1/thumb.webp |
| Squat - Barbell | 272 | exercises/squat_barbell/v1/thumb.webp |
| Squat - Dumbbell | 273 | exercises/squat_dumbbell/v1/thumb.webp |
| Stiff Leg Deadlift - Barbell | 280 | exercises/stiff_leg_deadlift_barbell/v1/thumb.webp |
| Tricep Dip | 285 | exercises/tricep_dip/v1/thumb.webp |
| Tricep Dip - Assisted Dip/Pull-Up Machine | 286 | exercises/tricep_dip_assisted_dip_pull_up_machine/v1/thumb.webp |
| Tricep Kickback - Cable Machine | 291 | exercises/tricep_kickback_cable_machine/v1/thumb.webp |
| Tricep Kickback - Dumbbell | 292 | exercises/tricep_kickback_dumbbell/v1/thumb.webp |
| Tricep Pushdown - Cable Machine | 293 | exercises/tricep_pushdown_cable_machine/v1/thumb.webp |
| Tuck Crunch | 294 | exercises/tuck_crunch/v1/thumb.webp |
| Tuck Crunch - Dumbbell | 295 | exercises/tuck_crunch_dumbbell/v1/thumb.webp |
| Turkish Get Up | 296 | exercises/turkish_get_up/v1/thumb.webp |
| Up-Down Twist - Cable Machine | 297 | exercises/up_down_twist_cable_machine/v1/thumb.webp |
| Upright Row - Cable Machine | 298 | exercises/upright_row_cable_machine/v1/thumb.webp |
| Upright Row - Barbell | 299 | exercises/upright_row_barbell/v1/thumb.webp |
| Upright Row - Dumbbell | 300 | exercises/upright_row_dumbbell/v1/thumb.webp |
| V Up | 301 | exercises/v_up/v1/thumb.webp |
| V Up - Dumbbell | 304 | exercises/v_up_dumbbell/v1/thumb.webp |
| Windshield Wipers | 305 | exercises/windshield_wipers/v1/thumb.webp |
| Wrist Curl - Cable Machine | 308 | exercises/wrist_curl_cable_machine/v1/thumb.webp |
| Wrist Curl - Barbell | 309 | exercises/wrist_curl_barbell/v1/thumb.webp |
| Wrist Curl - Dumbbell | 310 | exercises/wrist_curl_dumbbell/v1/thumb.webp |
| Wrist Curl - Dumbbell (Reverse Grip) | 311 | exercises/wrist_curl_dumbbell_reverse_grip/v1/thumb.webp |
