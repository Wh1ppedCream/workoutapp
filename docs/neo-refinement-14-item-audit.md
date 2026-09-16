# Neo Refinement: 14-Item Implementation Audit

## Status

The implementation pass and source review cover all 14 items from the supplied
coordinated-refinement brief. This is not a claim of analyzer, test, or device
approval. Repository policy requires the user to run Dart/Flutter commands.
The earlier 60-test results predate this pass and do not validate these edits.

This numbering is separate from the older `theme-review-1-13.md` findings.
Classic is preserved through explicit non-Neo branches except for the requested
locale-independent completion layout improvements.

Status update (2026-09-16): the user accepted the current 21-item Neo visual
review, which includes the normal route presentations covered by this audit.
That acceptance does not turn this implementation audit into a complete
route-state, device, accessibility, or release qualification record. Keep the
remaining N5/N6 checks explicit in the consolidated roadmap.

## Item Coverage

| Item | Implementation and source-review outcome | Remaining verification |
| --- | --- | --- |
| 1. Surface foregrounds | Known colored panels use dark ink. Neutral panels resolve original semantic foregrounds even inside a bright local Theme. Arbitrary colors use composited contrast; secondary text falls back to primary when needed. | New nested-surface and alpha regression tests; inspect pink chart labels and neutral nested statistics. |
| 2. Range selectors | Calendar and report selectors resolve selected/unselected foregrounds independently from their painted fills; existing selection callbacks and Classic colors remain. Corrected a malformed named-parameter signature found during the final review. | Check every range, focus/pressed states, Spanish labels, and enlarged text. |
| 3. Completion accents | Exercise names, results, annotations and summary icons use panel foregrounds. Decorative colors remain in markers and solid numbered badges. Monthly/all-time meanings are retained, with darker green/gold record text in light mode. | New responsive completion tests; review exercises with each decorative accent and both record tiers. |
| 4. Settings values | Values inherit the enclosing foreground. Info cards, status badges, ranking names and reset pills establish or consume their actual surface pairing. Explicit ranking-name styles no longer retain a canvas foreground. | New settings tests plus units, language, rankings and database trailing controls on device. |
| 5. Settings inheritance | Every Neo section establishes text, icon, list-tile, spinner and compositing-parent defaults, with or without a category accent. Custom charcoal sections work in light mode too. Fields retain their separate pale-yellow foreground recipe. | Lavender/orange/cyan/charcoal test matrix; check custom trailing content and focused fields. |
| 6. Classic regression protection | Plan summary icon retains primary; selected Logbook subtitle retains onSurfaceVariant. Progress's local foreground Theme is Neo-only. | Classic light/dark baseline review and existing theme suite. |
| 7. Responsive completion | Metrics use content-driven 4/2/1 columns. Actual card width and text scale determine result stacking in every locale. Long titles/results wrap, numbered badges grow, legends wrap, and the footer reserves its measured height. | New English/Spanish, 320/420-width, 1x/2x tests including the last card above Done; device sheet dragging. |
| 8. Completion states | Production and Lab use the same bounded loading/error presentation and shell; error has a localized Close action. Badge loading is awaited so hydration failures cannot leave an unhandled concurrent badge Future. Success keeps the draggable controller. | New state tests; force a real delayed load and read failure before release. |
| 9. Lab parity | Shared Finish, completion header/metrics/cards/legend/Done, and loading/error widgets replace independent presentations. Fixtures include long names, several sets and record badges; Reset clears state. | Added integration test for fixture success/loading/error/reset; compare light/dark and effects-off visually. |
| 10. Action depth | Save/Finish/Done paint a shared black hard shadow from their actual Material outline, excluding touch padding. Disabled/busy/effects-off buttons have no depth. The continuous Start/Optimize bar intentionally has one container-sized shadow using the same `(4,4)` role while Start is enabled. | New shape/state tests and updated Save test; device comparison of all primary actions. |
| 11. Outline roles | Explicit neutralOutline distinguishes charcoal boundaries from dark frames on colored panels. Shared surfaces/sheets, completion, plan metrics and debug controls consume the role; purple dialogs retain dark framing. | Existing surface/sheet/dialog tests and nested-panel device review. |
| 12. Debug placement | Toolbar reserves 56px below the status inset, with 48px keyboard-focusable controls. Child top padding is removed once. Debug flag and release gating remain intact. | Rotate, open keyboard/dialogs, traverse focus, and verify the disabled-flag/release presentation. |
| 13. Stroke hierarchy | Completion shell and result panels use standard Neo outer strokes; metric tiles have matching outer strokes without shadows; set separators stay thin. Classic result borders retain their original width. | New completion matrix plus visual hierarchy review. |
| 14. Anatomy palette | Bright-panel and neutral-context inactive endpoints are selected per background; the existing low-to-high interpolation preserves intensity order. RGB conversion and cache identity use opaque colors. | Compare front/back, inactive/low/high intensity, overview, charcoal Logbook and 52px plan thumbnails. |

## Run Verification

From PowerShell:

```powershell
Set-Location E:\projects\env_test
& .\scripts\verify_neo_refinement.ps1
```

The script formats the scoped sources/tests, analyzes those sources and the
theme test directory, then runs `flutter test test/theme`. It does not launch,
install, build, migrate data, or modify Git state. It stops at the first error.
Paste the complete output; do not interpret an earlier successful subset as a
pass for this combined change set.

## Device Review After Tests

1. Compare Neo light/dark and Classic light/dark. Check Train, plan detail,
   Catalog, Logbook, Progress, Profile, User Information and Weight Units.
2. On Neo, read small values and icons on lavender, pink, cyan and neutral
   panels. Check nested neutral cards separately, including empty Progress.
3. Finish a workout with long names, multiple sets and both badge tiers. Use
   English and Spanish, normal and largest supported text sizes; scroll to the
   final result and dismiss using Done. Drag the sheet through its extents.
4. In Theme Lab, compare completion success, loading and error; reset the
   fixture and toggle effects. Check Save/Finish/Done disabled/busy states.
5. With debug switching enabled, open a modal, focus a field, rotate and use
   keyboard traversal. The toolbar must not cover tabs, back buttons or content.
6. Compare inactive, lightly active and strongly active anatomy at overview
   and thumbnail sizes. Screenshots are still required for visual acceptance;
   widget tests cannot establish that every rendered screen looks correct.
