# Planning accordion styling follow-up

**Status: reverted at the user's request on 2026-10-25.** The user preferred the previous Premade Plans and Gym Profile Equipment designs. Their source/tests and the Generate Plans reference were restored exactly from `c9c95a7`; the experiment-only shared component and its test were removed. The implementation and screenshots described below are historical, not the current presentation.

## Checkpoint

Before these styling changes, the current source, focused tests and review records were committed locally as **`c9c95a7` - Checkpoint Expressive motion refinements and review approvals**. This preserves the previous Premade Plans and Gym Profile Equipment implementations. Generated build files, failure images and scratch captures were left untouched outside the commit. No push was requested or performed.

## Styling changes

- Extracted Generate Custom Plans' existing surface into a shared Expressive accordion: rounded outer material, a subtly tinted header, a visible header outline when inset, and the existing 10dp inset with coordinated 360ms settling motion.
- Generate Custom Plans uses that shared surface with its existing layout, colors, header padding and content alignment preserved.
- Premade Plans uses the surface for source sections, plan categories and individual plan previews. Existing palette hierarchy, plan descriptions, exercise details, duration and equipment filters, and Add actions remain.
- Gym Profile Equipment uses the same inset header, outlined surface and icon-tile treatment for equipment categories. Equipment rows, thumbnails, counts, selection actions, profile form and conditional Save action remain.
- Header feedback is confined to the header shape. Nested Add/Clear/Select All actions retain their own activation; body actions do not trigger the enclosing header.
- Classic and Neo retain their prior rendering branches. No plan-generation, adaptation, filtering or persistence logic changed.

## Focused validation

- **37 distinct widget tests passed** across the shared accordion tests, Generate Plans responsiveness, Premade Plans, Gym Profile theme/draft behavior, and Equipment refinements. This includes two added normal-phone-width cases after the device review.
- New checks cover light/dark modes, 320dp width, 1x/2x text, expanded inset geometry, independent header/body actions, state across parent rebuilds and reduced motion.
- Existing page checks cover filter state/counts, responsive Add actions, selection/reset, keyboard and Save behavior, and Classic/Neo presentation.
- Scoped analysis found no errors or warnings. Two pre-existing Radio API deprecation notices remain in Generate Plans (`groupValue` and `onChanged`); those controls were not changed.
- The Pixel 7 check exposed a nested-width breakpoint that unnecessarily stacked the plan's Add button. The Expressive breakpoint was adjusted and covered at 411dp and 600dp, light/dark, with 1.15x text. Narrow and larger-text layouts retain their stacked fallback. The directly affected source/tests then passed clean scoped analysis.
- Changed Dart files were formatted and `git diff --check` passed.

## Pixel 7 review

- The offline debug build passed and was installed over `com.tonos.expressivepreview`, preserving its existing data. The final phone-width adjustment was hot reloaded successfully after the rebuild.
- Navigated through Train > Plans > Browse Premade Plans, expanded Full Body and its first plan, and checked the outlined source/category/plan headers and the Add button's final inline placement.
- The active Home Gym profile has no matching complete premade plans, so its route-local equipment filter was temporarily disabled to inspect the headers. Leaving the route discards that local view state; no profile equipment or saved preference was changed, and no plan was added.
- Navigated through the active-profile drawer > Home Gym > Edit. Verified Basics collapse/reopen, checked the new icon/header treatment and retained equipment rows, and left Basics and Free Weights expanded. The profile still has 8 of 40 options selected, and no unsaved-change Save action is present.
- The device check used its existing dark presentation. Light/dark and larger-text comparisons were exercised in widget tests. A fresh device screenshot was retained locally for each updated page; the unapproved-review gallery was not changed.
- The Pixel 7 is left on **Edit Gym Profile > Home Gym**, with the updated equipment accordions visible.

## Approval scope

This was the user's authorized M07 styling iteration. It did not approve M07 or alter other animation decisions. The experiment was not committed and has been reverted. The checklist remains **6 approved / 11 pending / 17 total**.

## Rollback validation

The six affected screen/test files match checkpoint `c9c95a7`. The experiment-only component and its test are removed; the comparison images remain available as archived evidence.

- All **29 focused widget tests passed** across Premade Plans, Gym Profile Equipment, Gym Profile theme behavior and Generate Plans responsiveness.
- Formatting required no further changes. Scoped analysis found no errors or warnings; the two existing Radio deprecation notices remain in Generate Plans.
- The offline debug build passed and was installed over the existing Pixel 7 app without resetting its data.
- Checked the restored Premade Plans and Equipment layouts in the device's existing dark mode. Light mode was covered by focused widget tests, not a fresh device comparison.
- Left the Pixel 7 on **Edit Gym Profile > Home Gym**, with Basics and Free Weights expanded and its existing **8 of 40** equipment selections preserved.

No preview database, preferences or fixture records were reset or reseeded.
