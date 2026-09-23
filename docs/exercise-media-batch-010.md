# Exercise Media Batch 010

This batch stages 20 user-supplied exercise thumbnails that are currently
listed as missing from the development catalog. The source manifest is
tools/content_pipeline/exercise_media_batch_010.source.json. The original
source images should remain in the local batch staging folder, while the
normalized WebP files are written under
build/content/exercise_media_batch_010/.

## Batch Contents

| Exercise | Catalog ID | Object path |
| --- | ---: | --- |
| Hammer Curl - Dumbbell (Crossbody) | 82 | exercises/hammer_curl_dumbbell_crossbody/v1/thumb.webp |
| Hip Adductor - Cable Machine | 89 | exercises/hip_adductor_cable_machine/v1/thumb.webp |
| Hip Frog Extension | 92 | exercises/hip_frog_extension/v1/thumb.webp |
| Hip Raise | 93 | exercises/hip_raise/v1/thumb.webp |
| Hip Thrust - Cable Machine | 95 | exercises/hip_thrust_cable_machine/v1/thumb.webp |
| Incline Bench Press - Cable Machine | 102 | exercises/incline_bench_press_cable_machine/v1/thumb.webp |
| Inverted Row (Reverse Grip) | 115 | exercises/inverted_row_reverse_grip/v1/thumb.webp |
| Kneeling Crunch - Cable Machine | 124 | exercises/kneeling_crunch_cable_machine/v1/thumb.webp |
| Leg Curl - Cable Machine (Standing) | 139 | exercises/leg_curl_cable_machine_standing/v1/thumb.webp |
| Pull Up - Reverse Grip | 183 | exercises/pull_up_reverse_grip/v1/thumb.webp |
| Pull Up - Assisted Dip/Pull-Up Machine | 184 | exercises/pull_up_assisted_dip_pull_up_machine/v1/thumb.webp |
| Pullover - Cable Machine | 185 | exercises/pullover_cable_machine/v1/thumb.webp |
| Push Away | 189 | exercises/push_away/v1/thumb.webp |
| Push-up (Close Grip) | 193 | exercises/push_up_close_grip/v1/thumb.webp |
| Reverse Fly - Dumbbell (Lying) | 201 | exercises/reverse_fly_dumbbell_lying/v1/thumb.webp |
| Reverse Crunch - Cable Machine | 203 | exercises/reverse_crunch_cable_machine/v1/thumb.webp |
| Reverse Lunge | 207 | exercises/reverse_lunge/v1/thumb.webp |
| Reverse Plank | 214 | exercises/reverse_plank/v1/thumb.webp |
| Row - Landmine Attachment | 216 | exercises/row_landmine_attachment/v1/thumb.webp |
| Row - Kettlebell | 218 | exercises/row_kettlebell/v1/thumb.webp |

## Source Filename Exception

The catalog name is Pull Up - Assisted Dip/Pull-Up Machine, but / is not
valid in a Windows filename. The preparation command therefore expects the
source image as Pull Up - Assisted Dip Pull-Up Machine and maps it to the
canonical catalog name before conversion.

## Promotion Status

- The source manifest and batch documentation are complete.
- All 20 normalized thumbnail objects were uploaded to the development bucket.
- The batch preview manifest was uploaded and remote validation passed for all
  20 assets.
- The preparation block accepts .png, .jpg, and .jpeg source images, converts
  them to square 512x512 WebP files, and runs strict local validation.
- The canonical source is now version 12 with 189 exercise entries.
- The canonical development manifest was uploaded and publicly verified.

Current development coverage is 189 of 300 exercises (63.0%), with 111 still
missing thumbnails.
