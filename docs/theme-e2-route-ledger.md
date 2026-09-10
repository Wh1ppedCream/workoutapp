# E2 Route Disposition And Current Slice

Status: initial migration slice passed 181 user-run scoped tests; E2 closeout pending.
See [current pre-Q2 follow-ups](theme-pre-q2-closeout.md) for subsequent unverified
changes and remaining automated work.
This is not a complete release-reachability proof. Do not advance to Q3 on this
record alone.

| Entry or group | Destination / shared consumer | Current disposition |
| --- | --- | --- |
| Configurable main tabs | nutrition/nutrition_page.dart | Retains existing Material and shared nutrition recipes. |
| Configurable Nutrition Log tab | nutrition_log_page.dart | Existing placeholder; retained, not declared release-qualified. |
| Nutrition drawer | food_logging_page.dart | Migrated residual food-action colors and control frames. Search/debounce and writes unchanged. |
| Food results / food editor action | food_customization_page.dart | Migrated photo backgrounds/icons, density help, borders and frames. Existing photo-picker TODOs retained. |
| Nutrition log entry action | log_entry_page.dart | Migrated grid/border/card geometry; meal ColorScheme mapping and date arithmetic unchanged. |
| MealPlanAddBar | pantry_log_page.dart; plan_meal_page.dart | Both are reachable placeholders. No new feature or gating implemented. |
| Food logging scanner | barcode_scanner_page.dart | Black/white camera contrast, viewfinder and hint retained as fixed viewing chrome; device/lifecycle verification pending. |
| Nutrition measurements action | measured_items_page.dart | Reuses D3 health presentation; not remigrated. |
| Profile / training settings | analytics_setting_screen.dart and linked editors | Existing SettingsSection/SettingsActionTile ownership retained. |
| Exercise editor media grid | exercise_editor_screen.dart | Two legacy grey surfaces and 12px geometry moved to AppMediaTokens. |
| Exercise analytics save action | exercise_analytics_screen.dart | Existing advanced-category accent and white foreground retained; contrast qualification belongs to Q2. |
| Generic trend page | default_trend_page.dart | Contains placeholder data; all release callers still need final reachability audit. |

## This Slice's Boundaries

AppNutritionTokens now owns foodBorder, photoPlaceholder, mutedAction,
favoriteAction, addFoodAction, densityHelp, selectedLabel, logGrid and
compact/section/portion/quantity shapes. Constructor defaults, copyWith and lerp
include every added field. Both Classic modes retain the previous literals;
existing factory behavior is unchanged.

The quantity helper receives BuildContext only to resolve presentation.
No portion arithmetic, meal mapping, favorite persistence, query behavior,
navigation, save/cancel result, repository contract or localization text changed.
Transparent expansion dividers suppress double borders and remain intentional.
The commented-out quick-log button is not an active migration target.

AppMediaTokens owns editorAddSurface, editorItemSurface and editorShape.
The media editor still retains its original taps, edit controls and content.

Tests in test/theme/nutrition_presentation_test.dart cover defaults,
copy/interpolation, a real food customization theme rebuild retaining unsaved
text, and save/cancel payload behavior. The newer food logging behavioral test
also exercises search, favorite state, portion selection, quantity and the
actual diary payload. These tests require a fresh user run and do not replace
real-device or full nutrition persistence evidence.

## Required Before E2 Closeout

- Run the provided formatter/analyzer/theme suite, including the new tests.
- Exercise food result selection, quantity increment/decrement, portion editing,
  log/save/cancel, favorite state and log-entry rendering with representative data.
  Add route-level fake-repository coverage where absent; token tests alone do not
  close behavioral qualification.
- Finish the release caller ledger for all settings/nutrition routes and catch-all
  inventory entries. Review inherited styling and transforms as well as literals.
- Record a product decision for the reachable placeholders. Do not delete/gate
  them without approval, and do not label them excluded merely because incomplete.
- Verify scanner permissions, repeated detections, navigation dismissal and
  background/resume on a real device. An injectable session boundary and
  hardware-independent route tests now supplement, not replace, that evidence.
- Record Classic light/dark visual evidence and Q2 contrast/accessibility gaps,
  especially the legacy light greys and black54 help text on dark surfaces.
- Keep the inventory report-only until Q1. This migration does not approve every
  expression in the nutrition or settings directories.
