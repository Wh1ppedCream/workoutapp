# Tonos Expressive Global Rendering Audit

**Audit date:** 2026-10-08 (local time)

**Branch / HEAD:** `feature/classic-m3e` / `ab18ed8cab5582c8449e13724afae3c4b74ebeea`

**State:** the primary rendering correction is implemented and the current-source preview is ready for user review. This is not a release qualification or an approval-ledger update.

## Findings and correction

### Workout Progress Flow Editor

On **Profile → Gym & Workout Settings → Workout Progress Flows → App Default Progression**, `_FlowControlCard` put its Expressive outline in a `BoxDecoration` behind an `ExpansionTile`. The tile paints an opaque Material surface after the parent decoration, so it covered parts of the independently painted outline. The artifact was most apparent around the panel perimeter as its contents expanded.

For Expressive only, the outline now uses the same `ShapeBorder` as the tile and is painted in a `CustomPaint.foregroundPainter` above the clipped card. The card still uses the approved asymmetric shape, fill, dimensions, and `Clip.antiAlias`; the legacy BoxDecoration border remains for Classic/Neo. No shadow, layout, color, progression logic, or data behavior was changed.

### Shared Profile ink surfaces

- Profile `SettingsSection` now gives its transparent Material the existing Profile Expressive sheet radius and anti-aliased clip, containing descendant ink ripples within the rounded section.
- The shared Profile Expressive choice field gives its InkWell the radius of the existing `OutlineInputBorder`, containing selection ripples within the field silhouette.
- These are interaction-only clipping changes. Static fills, outlines, shapes, spacing, and row geometry are unchanged. The conditions are explicit to Profile Expressive tokens; Classic and Neo retain their existing behavior.

## Audit coverage

Source-level reviews covered the route families and surfaces listed in [route-ledger.md](route-ledger.md). The only confirmed shape/ink containment defects found were the Flow Editor outline paint order and the two shared Profile ink boundaries above. No other confirmed static fill, border, corner, clipping, or shadow defect was reported in the inspected routes. This is not a claim that every app surface is artifact-free: the detailed route and device-coverage limits are recorded in the ledger.

No visual approval status was changed. Approved screens touched by the shared Profile interaction fix retain their static approved presentation; only transient ink effects are now clipped to the existing silhouette.

## Pixel 7 evidence

Fresh captures were made from the rebuilt current-source isolated preview on Pixel 7 `28021FDH200228` (1080×2400 px, 420 dpi; Android 16), package `com.tonos.expressivepreview`. The preview database is `tonos_expressive_preview.db`.

| Evidence | State |
| --- | --- |
| `flow-editor-before.png` | Before: both panels collapsed. |
| `flow-editor-before-expanded-light.png` | Before: Add a branch expanded. |
| `flow-editor-current-light-collapsed.png` | Current: both panels collapsed, light. |
| `flow-editor-current-light-branch-expanded.png` | Current: Add a branch expanded, light. |
| `flow-editor-current-light-attach-expanded.png` | Current: Attach a progression action expanded, light. |
| `flow-editor-current-dark-collapsed.png` | Current: both panels collapsed, dark. |
| `flow-editor-current-dark-branch-expanded.png` | Current: Add a branch expanded, dark. |
| `flow-editor-current-dark-attach-expanded.png` | Current: Attach a progression action expanded, dark. |
| `flow-editor-current-dark-both-expanded.png` | Current final handoff: both panels expanded, dark. |
| `flow-editor-dark-expansion-transition.mp4` | Dark-mode expansion recording. The clip was captured but not frame-sampled. |
| `profile-ui-appearance-current-dark.png` | Representative dark Profile section composition from the current preview. |

The final device hierarchy reports both **Add a branch** and **Attach a progression action** as expanded. The final capture shows continuous outlines following the rounded silhouettes. The final device page was left at App Default Progression with both panels expanded.

The before/after captures are native device screenshots. Several earlier exploratory files in this folder have misleading filenames (`logbook-root-before.png`, `logbook-before.png`, and `logbook-before-v2.png`); they are not evidence for this audit and should not be used to infer route state.

## Validation

- Focused AutoPresetFlow widget tests: **15 passed**; the isolated dark outline test also passed **1/1** (included in that focused file run).
- Focused AutoPresetFlow panel goldens: **2 passed**, covering four light/dark collapsed/expanded reference images. A repeat run left all four images byte-identical. Goldens use the test font and validate surface/outline geometry, not typography or icon fidelity.
- Focused Settings Tiles tests: **34 passed**.
- Focused Profile Expressive settings/selection tests: **18 passed**.
- Full analyzer (`flutter analyze --no-pub`): **exit 1; 0 errors, 3 warnings, 78 infos**. The warnings are unnecessary non-null assertions in `nav_bar_settings_page.dart:308` and `ui_appearance_settings_page.dart:264,283`; the infos are existing deprecation and style notices. Log: `C:\Users\talh7\AppData\Local\Temp\tonos_full_analyze_final_20261008_215042.log`.
- Full Flutter suite: one uninterrupted normal `flutter test --no-pub` run completed in **1068.9 s**: **1,789 passed, 21 failed, 0 skipped; exit 1**. Failures were in hardcoded-copy, source-owner/state, exact style-inventory, and ratchet contracts (including the shared settings-route inventory contract). No Flow outline test failed. Because the checkout already contained extensive unrelated dirty source, this run does not establish which unrelated contract failures predated this audit. Log: `C:\Users\talh7\AppData\Local\Temp\tonos_full_test_shape_audit_20261008_215247.log`.
- Scoped Dart formatting check on seven changed Dart files: **0 files changed**.
- `git diff --check`: **exit 0**; Git printed line-ending warnings only.
- Android debug preview build and `adb install -r`: **succeeded**. The database remained present at **1,572,864 bytes**; it was not cleared or replaced. Its runtime modification time advanced during preview use.

The broad 320–1024 dp, landscape, 1.5×/2× text-scale, and multiple-pixel-ratio matrix was not completed. The focused golden viewport is 430×1400 logical pixels and the device check is Pixel 7 portrait. The recorded motion clip was not inspected frame by frame. These are open verification limits, not claims of observed defects.

## Working tree and preservation

The branch and HEAD remain unchanged, the index is empty, and nothing was staged, committed, pushed, reset, cleaned, or stashed. A hash comparison against the pre-task tracked-file snapshot found expected edits only in the Flow Editor source, shared settings tiles, and the Flow Editor theme test; the Profile choice source and related tests were untracked user work already present in the working tree. All other tracked files in that snapshot retained their hashes.

One process issue should be recorded: the Dart formatter was applied to the full dirty `lib/widgets/settings_tiles.dart` and to `test/theme/widgets/settings_tiles_test.dart`, so those directly touched files contain unrelated formatter churn alongside the narrow clipping change/test. The original dirty Settings Tiles source had no byte-for-byte backup; that churn has been preserved rather than risking loss of user edits. No inventory JSON or ratchet baseline was edited for this audit.

The exact source/build identity and current hashes are in [current-source-snapshot.md](current-source-snapshot.md).
