# Expressive Exercise Catalog Browser Review

Current-source visual review for the Exercise Catalog browser and its filter dialog. These are review candidates, not user-approved design decisions.

## Capture provenance

- Repository: `E:\projects\env_test`
- Branch / base HEAD: `feature/classic-m3e` / `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Source was captured from a dirty working tree. The Catalog browser page used for this build is `lib/screens/exercise/exercise_catalog_page.dart` (SHA-256 `2E29FF6153E3CE3212F0BDFA49721F69000B45373B493ACEA81ACBB98FA0DA3F`). The protected Catalog root file remained unchanged (SHA-256 `0B01AAF8FC47FC5755E016F58A7F2BCE0A8F9A76C1E0AD6BCE59F30EE45E641C`).
- Toolchain: Flutter 3.47.5, Dart 3.13.4.
- Preview build: debug, package `com.tonos.expressivepreview`, version `1.0.1` (version code 6), using `tonos_expressive_preview.db` and the isolated Expressive preview defines.
- Device: physical Pixel 7, adb ID `28021FDH200228`, Android 16.
- Final-source captures: 2026-10-06, approximately 02:24–02:36 local time (UTC−04:00), after the filter action-wrap fix was built and installed.
- Normal device captures: 1080×2400, density 420 dpi (about 411×914 dp), system font scale 1.15.
- Compact capture: 840×2400 at the same density (320×914 dp), system font scale 2.0. Device size and text scale were restored afterward to 1080×2400 and 1.15.
- Database isolation: only the Expressive preview package/database was used; normal Tonos data was not opened or changed.

## Current layout represented

The production Exercise Catalog route is reached from the existing Catalog destination. Its app bar, search field, distinct filter action, and exercise result list remain in their current order. Result rows still present the exercise name, equipment summary, and exercise media/fallback. Search, workspace-profile selection, equipment/area/muscle filters, and Cancel/Save retain their current controls and behavior.

The visual treatment adds Expressive destination surfaces and mixed-corner result geometry, lets long exercise/equipment names wrap within the result, keeps the media artwork on a neutral framed well, and gives the filter dialog warm/cool tonal grouping. The 48 dp filter action changes to its mint selected state only when equipment, area, or muscle filters are active. Expressive filter selectors wrap long values and the action row wraps at compact widths/larger text. The filter popup uses the Expressive light/dark menu surface. Classic and Neo keep their prior browser presentation and filter controls.

## Final-source evidence

| Capture | Mode / state | What to review |
| --- | --- | --- |
| [21-browser-light-all.png](21-browser-light-all.png), [45-browser-restored-light-all.png](45-browser-restored-light-all.png) | Light, all results | Current result silhouettes, neutral media wells, search/filter grouping, and warm canvas against blue result surfaces. `45` records the final restored device state. |
| [24-browser-bench-light.png](24-browser-bench-light.png) | Light, `bench` query | Matching result density, wrapping equipment summary, media alignment, and focused search treatment. |
| [46-browser-preacher-light.png](46-browser-preacher-light.png) | Light, `preacher` query | Long exercise title and anatomy fallback remain inside the mixed-corner media well without forcing a tall empty result surface. |
| [22-filter-light.png](22-filter-light.png) | Light, filter dialog defaults | Workspace profile, equipment, area, muscle, warm/cool grouping, and Cancel/Save hierarchy. |
| [23-equipment-options-light.png](23-equipment-options-light.png) | Light, equipment popup open | Expressive blue-slate menu surface/foreground and selected `All` row. |
| [28-filter-barbell-selected-light.png](28-filter-barbell-selected-light.png) | Light, Barbell selected in draft | Draft selector value before Save. |
| [29-browser-active-barbell-filter-light.png](29-browser-active-barbell-filter-light.png) | Light, saved Barbell filter | Filter action switches to mint selected treatment and the saved filter narrows the results. |
| [32-browser-dark-all.png](32-browser-dark-all.png) | Dark, all results | Plum chrome, blue-slate rows, lavender filter action, and neutral media wells. |
| [35-browser-bench-dark.png](35-browser-bench-dark.png) | Dark, `bench` query | Dense matching list, long equipment values, and dark search state. |
| [33-filter-dark.png](33-filter-dark.png) | Dark, filter dialog defaults | Chromatic brown/plum dialog, teal profile group, blue selectors, and readable actions. |
| [34-equipment-options-dark.png](34-equipment-options-dark.png) | Dark, equipment popup open | Blue-slate popup with pale foreground and selected `All` row. |
| [36-browser-compact-320dp-2x-dark.png](36-browser-compact-320dp-2x-dark.png) | Dark, 320 dp width at 2× system text | Long titles/equipment wrap while media remains separate; no horizontal overlap. |
| [37-filter-compact-320dp-2x-dark.png](37-filter-compact-320dp-2x-dark.png), [38-filter-compact-320dp-2x-dark-scrolled.png](38-filter-compact-320dp-2x-dark-scrolled.png) | Dark filter dialog, 320 dp / 2×, initial and scrolled | Initial scroll position keeps actions visible; the filter fields scroll independently so the final selector can be reached. The scrolled hierarchy XML confirms Cancel and Save remain exposed. |
| [43-filter-compact-320dp-2x-light.png](43-filter-compact-320dp-2x-light.png), [44-filter-compact-320dp-2x-light-scrolled.png](44-filter-compact-320dp-2x-light-scrolled.png) | Light filter dialog, 320 dp / 2×, initial and scrolled | Large-text title/field wrapping, visible primary Save action, and independent scrolling through all selectors. |

The numbered `00`–`20` files in this folder are setup, earlier inspection, or prior-source captures. Use the final-source evidence table above for visual review. Accessibility hierarchy snapshots are paired as `.xml` files where captured.

## Validation on this source snapshot

- Focused Flutter tests: **32 passed, 0 failed** across `expressive_catalog_browser_presentation_test.dart` (17), `expressive_catalog_browser_detail_responsive_test.dart` (8), `exercise_catalog_theme_ownership_test.dart` (3), and `exercise_catalog_material_states_test.dart` (4).
- Scoped Dart analysis: no issues found in the browser page and four relevant presentation/theme tests.
- Changed-file format check: 4 changed source/test files, 0 changes required. An unrelated clean Material-states test file was not reformatted.
- `git diff --check`: passed for the four changed source/test files.
- Responsive widget coverage includes 320 dp at text scales 1.0, 1.15, 1.5, and 2.0, plus an explicit long title/equipment wrapping check at 320 dp / 2×.
- Full repository suite: intentionally deferred for this focused refinement.
- No commit or push was made.

## Review limits

The Pixel capture includes the standard Flutter debug banner. The browser result set uses the isolated preview database; the `bench` result count reflects that preview data. The 320 dp / 2× check was performed on the Pixel 7 with a temporary display-size/font-scale override, then restored to 1080×2400, 420 dpi, and 1.15. A separate out-of-scope Catalog-root inventory contract test was attempted and remains failing against the pre-existing dirty `lib/screens/catalog_page.dart` change (expected 15 findings, saw 16); that protected route was not modified. These captures establish layout behavior on this device; they do not replace review on every physical screen size.
