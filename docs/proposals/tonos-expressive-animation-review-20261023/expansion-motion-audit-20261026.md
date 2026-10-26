# Expressive expansion-motion audit

Date: 2026-10-26. Requested after the plan/preset collapse-end fix.

## Confirmed issues corrected

| Area | Reproduced issue | Correction |
| --- | --- | --- |
| Active-workout exercise cards | Material corners continued moving after height had settled. The outer radius tween repeatedly retargeted Material's own shape animation. | Extended the preset fix to animated active-workout cards: one Material shape transition, without the second tail. Layout/header/chevron timing stays 288ms; set feedback stays 308ms and the final-set confirmation pause stays 200ms. |
| Generate Plans and Premade Plans source/category accordions | The closing controller played the settling curve backwards, leaving about 21dp of a 500dp disclosure for the last 16ms. | Use a stable flipped reverse curve for these ExpansionTiles, so closure decelerates. Opening and closing durations stay 360ms. Chip-selection callers retain their existing curve. |
| Generate Plans inset header | The outline retained full thickness/opacity until the inset reached zero, then disappeared in one step. | Interpolate border thickness and opacity with the inset. Fully open and closed appearances remain the same. |

These are motion corrections. Existing palettes, resting shapes, card proportions, actions, saved values and approval classifications are preserved. Classic and Neo do not opt into the changed Expressive motion.

## Other instances inspected

| Implementation | Result |
| --- | --- |
| Gym Profile / Equipment groups; individual Premade Plan previews | Their AnimatedCrossFade uses AnimatedSize for height. It already decelerates on closure and does not reverse the spatial height curve. Kept unchanged. |
| Workout Report additional details | Existing cross-fade height settles with easeOutCubic. Preserved the static fallback for muted/reduced-motion regions. |
| Exercise Details sections | A single AnimatedSize owns the resize, with a static outer shape. No duplicate corner animation found. |
| Train overview active plans and Plans-tab section contents | Separate resize instances, with easeOutCubic and static outer shapes. No duplicated animation of the same height found. |
| Daily nutrition mode resize; shared Expressive resize wrapper | Single size animation; no second changing outer shape found. Kept unchanged. |
| Settings, Flow Methods, Workout Progress Rules, automatic Plan Progression controls, food-customization groups | These use default ExpansionTile motion, without the custom reversed settling curve or per-frame outer-shape retargeting. Kept unchanged. |

This inventory is a source review, supplemented by the focused checks below. It is not a claim of frame-time qualification on every route/device.

## Focused validation

- Before fixes, the new checks reproduced active-workout corner tails in both themes, abrupt custom-accordion closure in both themes, and Generate header-outline popping in both themes.
- **88 widget tests passed:** expansion/disclosure regressions (including rapid reversal, parent rebuild and reduced motion), Generate Plans responsiveness, Premade Plans, Equipment, exercise-header geometry/controls, food customization, Flow Methods, Workout Progress Rules and shared ExpansionTile scopes. Both light/dark and existing Classic/Neo checks are included where those suites provide them.
- Scoped analysis: no errors or warnings; two existing Generate Plans Radio API deprecation infos.
- Changed Dart files formatted; `git diff --check` passed.

## Pixel 7 spot check

- Offline debug rebuild succeeded and was installed over `com.tonos.expressivepreview`. Backed up the current database/preferences first; file hashes matched before and immediately after installation.
- In the device's current light mode, resumed the existing workout, cycled exercise headers, and exercised Generate Plans, Premade source/category accordions, individual plan previews and plan-detail cards. Included interrupted open/close taps. No sets, plan values, equipment selections or saved settings were edited; the Premade route's temporary equipment-filter toggle was discarded on leaving.
- Reviewed samples of the active-workout recording and the settled Generate/plan screenshots. No obvious residual corner tail was visible in the sampled closure. The bounded app-log check found zero Flutter errors, fatal exceptions or overflows.
- Left **Quads, Hips** plan detail open, with **Turkish Get Up collapsed** and **Overhead Squat - Dumbbell expanded**.
- Dark mode was covered by widget checks, without changing the device's current preference. This was a debug-device spot check, not an exhaustive frame-time/profile-mode qualification of every disclosure.

Motion checklist status remains **7 approved / 10 pending / 17 original groups**, with M07a/M07b still separate pending follow-ups. No new visual or release approval is granted by these checks.
