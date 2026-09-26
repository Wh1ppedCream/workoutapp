# Review Findings 1-13: Follow-up Audit

Source audit: 2026-09-12. This record supersedes earlier statements that all
thirteen fixes had already been verified. Source inspection found additional
gaps and the fixes below have been applied. The user later accepted items 1-13
as part of the current 21-item Neo visual review. That closes this record's
ordinary visual-review request; N5 route-state and N6 device/accessibility
qualification remain separate.

## Disposition

| Finding | Source disposition and owner |
| --- | --- |
| 1. Workout input contrast | Transparent numeric-field fill and dark value/label/underline recipe are present in `weight_card.dart`. The local theme now also gives cursors, selection handles and selection highlights a readable ink treatment. |
| 2. Completion count | Completed count and check icon resolve to `onWorkoutContainer`, separate from the green completion fill. |
| 3. Dropdown popup contrast | All four production User Information dropdowns explicitly pair pale field/popup fill with dark text and icons. The pilot uses the same field ink and allows variable item height. |
| 4. Hidden labels | The real overview more action and selected generator choices use dark foregrounds. Corrected the overview role back to bright yellow after the pale-field palette change had affected it. |
| 5. Weight Units | Production and preview now use `TonosChoiceDialog`: bright-yellow selected row, pink alternative, dark text/radios, 3px selected and 2px unselected outlines. Selection returns through Navigator; the production caller still owns persistence. |
| 6. Classic regression | Classic overview retains Card plus 16px padding. Settings keep their inherited field styles, gradient hero and category accents. The new dialog frame passes Classic through without a custom shadow. |
| 7. Neutral borders | Neutral controls use ColorScheme outline; colored panels retain the near-black structural edge. Health Trends uses the neutral edge. Explicit colored-surface overrides must still be chosen according to their actual background. |
| 8. Focus | Pale settings fields use the darker purple focus ring. Entered values/cursors are dark. Disabled and error outlines now have explicit colored-field recipes instead of inheriting dark-canvas borders. |
| 9. Preview ownership | Added shared `SevenDayFocusPresentation` for the full overview, including heatmap/more action. User Information now uses production SettingsHeroCard, SettingsSection, field helpers and SettingsSaveBar. Both dialog callers share TonosChoiceDialog. Navigation, plan rows, the interactive workout and the full completion summary now use production presentation widgets. Removed the independent mock workout header and its no-op expansion button. Reset remains fixture-only. |
| 10. Shadow bounds | The old outer Align/DecoratedBox did not bound the shadow to the visible modal because AlertDialog contains its own route-padding/alignment layout. TonosDialogFrame now supplies a ShapeBorder that paints the exposed translated silhouette at the actual dialog Material. It retains the original inner/outer path and draws no shadow inside the modal. Raised panels use (4,4); completed rows use (3,3); effects-off suppresses depth. |
| 11. Navigation | Continuous yellow rail, purple selected segment, dark underline, frame and shadow are present. Added trailing/bottom space for the rail shadow. Neo Overview/Plans now allocates height for scaled text and touch targets, retaining explicit selected semantics and individual outlines. |
| 12. User Information | Yellow hero/save, pale-yellow #FFF0A6 fields, pink category labels, near-black boundaries and explicit hero/save depth are present. Solid-hero icons now use readable foreground ink. |
| 13. Workout structure | 4px exercise-card radius, square green completed rows, 3px left marker, thin remaining edges and inter-row separators are present. The geometry test now lives inside main(), imports its extensions and expands only when collapsed. |

## Test Repairs And Limits

The save-shadow test previously matched both the save wrapper and the hero's
generated DecoratedBox because both use (4,4). It now scopes the lookup to the
save button's ancestors.

The previous dialog test compared outer widget sizes and could pass while the
shadow still framed the route. Its replacement checks the actual Material shape,
the exterior shadow path, choice colors/outlines, selection results and the
Classic/effects-off paths. These tests have been authored, not executed here.

Theme Lab shares the presentation owners described above, including
`WorkoutCompletionPresentation` for the completion header, metrics, legend,
result cards and Done action. Fixture-only Start/Finish/feedback controls and
limited fixture content do not constitute a full replica of production
workflows. Final visual acceptance must use the real routes, including actual
exercise thumbnails, all profile dropdowns, persistence, keyboard interaction
and the complete workout. This audit does not close N5/N6.

## User Verification

The following was the initial PowerShell verification procedure. No formatter,
analyzer, or Flutter command was executed by Codex, in accordance with
AGENTS.md. The visual review it requested is now accepted within the 21-item
Neo review; use these commands again only after an affected change.

```powershell
Set-Location E:\projects\env_test
$reviewSources = @(
  'lib\theme\widgets\tonos_dialog.dart'
  'lib\theme\neo_brutalism_pilot_gallery.dart'
  'lib\theme\neo_brutalism_theme.dart'
  'lib\widgets\seven_day_focus_card.dart'
  'lib\widgets\settings_tiles.dart'
  'lib\widgets\weight_card.dart'
  'lib\widgets\tonos_train_tabs.dart'
  'lib\widgets\tonos_bottom_navigation_bar.dart'
  'lib\screens\profile\settings\ui_appearance_settings_page.dart'
  'lib\screens\profile\settings\user_information_settings_page.dart'
)
$reviewTests = @(
  'test\theme\widgets\neo_workout_readability_test.dart'
  'test\theme\widgets\settings_tiles_test.dart'
  'test\theme\widgets\tonos_dialog_test.dart'
  'test\theme\widgets\tonos_train_tabs_test.dart'
  'test\theme\widgets\tonos_bottom_navigation_bar_test.dart'
  'test\theme\widgets\tonos_surface_test.dart'
  'test\theme\neo_brutalism_theme_test.dart'
  'test\theme\theme_lab_page_test.dart'
)
dart format @reviewSources @reviewTests
dart analyze @reviewSources @reviewTests
flutter test @reviewTests
```

After the command results pass, repeat in Neo light and dark:

1. Train: view the yellow overview, heatmap, more action, plan rows, tab
   selection and bottom-rail shadow. At 2.0 text scale, confirm the top tabs
   remain readable and pressable.
2. Generator: select and deselect choices; selected titles, subtitles and radios
   must remain readable.
3. User Information: type into name/height/weight, choose a date, open all four
   dropdowns, check the cursor, then save/reopen. Check pink labels, pale fields,
   dark outlines and hero/save depth.
4. Weight Units: open the real dialog, select each unit, dismiss using Back and
   outside tap, and reopen with the keyboard visible if possible. The shadow
   must hug the purple modal, with no large dark rectangle behind it.
5. Workout: edit numbers, complete one set then all sets, expand again and
   confirm count/checkmark, square green rows, markers and separators.
6. Theme Lab: exercise reset, brightness, effects-off and User Information
   error/disabled examples. Compare shared presentation with the real routes.
7. Classic light/dark: spot-check overview, settings, dialogs and navigation.
   Restore the usual phone text scale after the large-text check.

Record the analyzer/test output and any phone deviations before marking this
audit verified.

## Verification Follow-up

The first external run of the command block found three missing `yellow`
arguments in the Neo surface-token factory and one stale `TonosSurface` test
expectation. Those issues are now corrected: the factory receives the palette
role explicitly, and the neutral-outline test asserts the active
`ColorScheme.outline`. The remaining analyzer output should be clean before
the audit is marked verified.

The next external test run reported two test-only finder issues. The settings
test now scopes the save-bar container through its keyed save button, and the
Theme Lab family-selection helper now ensures the field is visible after a
reset has left the list scrolled down. That corrected suite then completed with
60 passing tests and 0 failures.

The subsequent Neo dark-mode device review found light text inherited onto
bright pink and purple surfaces in Profile/settings, the selected logbook
summary, and Exercise Progress. A shared surface-foreground helper and local
Neo presentation themes now keep dark ink on those bright surfaces while
preserving Classic and neutral dark-canvas behavior. Rerun the analyzer and
focused tests after this device-driven patch; the earlier 60-test result does
not cover these latest changes.

Current status update (2026-09-16): the user accepted all items 1-13 and the
remaining 14-21 entries in the current Neo visual review. The final selector
contrast correction received clean user-run analysis and 63 focused passing
tests. This acceptance does not close unreviewed non-happy-path, device,
accessibility, or release checks.

## Automated Verification Status

The previous follow-up analyzer completed with no issues, and the complete
focused suite in `$reviewTests` completed with 60 passing tests and 0 failures
before the later shared completion-presentation and progress-chart parity
changes. The final selector-contrast change then passed clean user-run analysis
and 63 focused tests. The current visual review is accepted; remaining status is
focused re-verification after future edits plus N5/N6 device-level evidence for
non-happy-path states, large text, real dialogs, accessibility, and Classic
spot checks.
