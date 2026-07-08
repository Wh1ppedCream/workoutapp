# Exercise Media Batch 001

Phase 7 starts by expanding exercise thumbnail coverage from the 5 test
thumbnails to a repeatable first production-style batch.

## Batch Scope

Create one `thumbnail` image for each exercise below and upload it to the listed
R2 object path.

| Exercise | Object path |
| --- | --- |
| Ab Wheel | `exercises/ab_wheel/v1/thumb.png` |
| Arm Circles | `exercises/arm_circles/v1/thumb.png` |
| Arnold Press | `exercises/arnold_press/v1/thumb.png` |
| Back Extension | `exercises/back_extension/v1/thumb.png` |
| Ball Slam | `exercises/ball_slam/v1/thumb.png` |
| Bench Press - Barbell (Close Grip) | `exercises/bench_press_barbell_close_grip/v1/thumb.png` |
| Bench Press - Dumbbells | `exercises/bench_press_dumbbells/v1/thumb.png` |
| Bench Press - Smith Machine | `exercises/bench_press_smith_machine/v1/thumb.png` |
| Bench Press - Cable Machine | `exercises/bench_press_cable_machine/v1/thumb.png` |
| Bicep Curl - Barbell | `exercises/bicep_curl_barbell/v1/thumb.png` |

## Quality Targets

- Use PNG for this first batch to match the current test thumbnails.
- Keep the visual style consistent across the batch.
- Prefer square or near-square crops so the app can display thumbnails in small
  cards without awkward clipping.
- Use only media Tonos owns, has licensed, or is allowed to redistribute.

## Promotion Checklist

1. Create the 10 thumbnail files.
2. Upload them to `tonos-public-content-dev` using the object paths above.
3. Validate the batch with `--check-remote`.
4. Merge the batch source into the canonical source.
5. Run `release-check-exercise-media` to build and remote-check the manifest.
6. Upload the manifest.
7. Sync Cloud Content in the app and confirm thumbnails render.

Do not merge this batch into the canonical source until the remote files exist
and validation passes.
