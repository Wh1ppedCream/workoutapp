# Exercise Details tab - inset disclosures

Requested 2026-10-27, following the five-page accordion finishing pass.

[Open the before-and-after review images](exercise-details-inset-20261027/REVIEW.html).

The shared Expressive Exercise Details sheet now applies the refined inset-header treatment to **Form guide, Equipment and Target anatomy**. This covers the unified Expressive sheet used by Catalog, anatomy, plan/workout, History and Progress callers.

- Existing section colors, icon tiles, type styles, instruction content, tags and outer asymmetric shapes are retained.
- Closed headers keep comfortable padding. Expanded headers move inward with their icon, title and chevron, keep 16dp internal horizontal gutters, and use the shared smaller inner corners and quieter outline.
- The outer frame and inset header have a clear border hierarchy. Expanded content starts 12dp below the header, with 26dp side gutters and 16dp bottom padding. Guide icons and text align with their header columns.
- The sheet owns expansion state as before: Form guide starts open; Equipment and Target anatomy start closed. State remains correct across tab changes and resets for a different exercise.
- Only expandable Expressive Details cards use this treatment. The static Form guide in the image viewer, anatomy viewer, media, sheet header, Metrics and Records retain their existing presentation. Classic and Neo retain their rendering branches.

The shared accordion gained optional expansion notifications and a semantic label for this caller. Existing callers retain their previous behavior and layout.

## Focused checks

**69 focused checks passed** across the shared accordion, sheet media/caller tests, Catalog/detail responsive tests, Metrics/Records tests and ownership/contracts. These include light/dark, six shared callers, 320dp to tablet/landscape layouts, text up to 2x, header/body text-column alignment, section expansion and state across tab changes, image zoom/pan and the unchanged static viewer guide, plus Classic/Neo callers.

Scoped analysis: no issues found. Changed Dart files formatted; `git diff --check` passed. No full test suite was run.

The ownership guard retains its exact classifications and allowed style kinds. Its Exercise Details counts were updated for the newly owned section frame/header styles. The same test also contained stale Generate Plans kind counts; these were reconciled with that unchanged source (four color transforms and fourteen geometry occurrences). No Generate Plans UI source was changed.

## Pixel 7 review

The offline debug build succeeded and was installed over the existing preview. A fresh pre-install database/preferences archive was retained; all seven files matched SHA-256 immediately after installation. Checked the Catalog caller's Turkish Get Up sheet in light and dark modes, including the full raised sheet, guide content, expansion/collapse and Equipment/Target anatomy tags. Other callers and responsive states were checked through the focused widget suites.

Restored light mode and left the Details tab open with Form guide collapsed and Equipment/Target anatomy expanded, scrolled to show the section treatments. No exercise, workout, rule or nutrition values were changed or saved. These checks do not claim exhaustive performance or accessibility qualification.

## Files

- `lib/widgets/exercise_detail_sheet.dart`
- `lib/theme/widgets/tonos_expressive_inset_accordion.dart`
- `test/expressive_catalog_browser_detail_responsive_test.dart`
- `test/theme/widgets/exercise_detail_expressive_media_layout_test.dart`
- `test/theme/exercise_detail_generation_inventory_test.dart`

This is a requested visual refinement awaiting the user's review. It does not change page or motion approval classifications or imply release qualification. Existing worktree changes, archived reference screenshots and preview data are preserved.
