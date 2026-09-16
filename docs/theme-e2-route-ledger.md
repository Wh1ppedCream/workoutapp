# E2 Route Disposition And Current Slice

Status: initial migration slice passed 181 user-run scoped tests; the
theme-ready compatibility extension and its source-boundary contract are
recorded. The current 21-item Neo visual review is accepted; E2 closeout
remains pending.
See [current pre-Q2 follow-ups](theme-pre-q2-closeout.md) for subsequent unverified
changes and remaining automated work.
This is not a complete release-reachability proof. Do not advance to Q3 on this
record alone.

## Current Neo Visual Review Update (2026-09-16)

The user accepted all 21 entries in the current Neo visual review. The
Profile/settings portion includes UI and Appearance, Weight Units, User
Information, Edit Gym Profile, Database Settings, Guided Tutorials, body-part
and muscle rankings, Volume Boundaries, Anatomy Mapping, Exercise Set
Allocation, Exercise Editor, Flow Methods, and Workout Progress Flows. The
final bright-field selector correction passed user-run formatting, clean
analysis, and 63 focused tests.

This is normal-route visual acceptance only. It does not supply the complete
E2 evidence for loading/error/editing/destructive states, route reachability,
scanner/media lifecycle, device accessibility, or release behavior. Keep those
items open below until their own evidence is recorded.

| Entry or group | Destination / shared consumer | Current disposition |
| --- | --- | --- |
| Configurable main tabs | nutrition/nutrition_page.dart | Retains existing Material and shared nutrition recipes. |
| Configurable Nutrition Log tab | nutrition_log_page.dart | Existing placeholder; retained, not declared release-qualified. |
| Nutrition drawer | food_logging_page.dart | Migrated residual food-action colors and control frames; theme-ready card ownership is now explicit. Search/debounce and writes unchanged. |
| Food results / food editor action | food_customization_page.dart | Migrated photo backgrounds/icons, density help, borders and frames; theme-ready card ownership is now explicit. Existing photo-picker TODOs retained. |
| Nutrition log entry action | log_entry_page.dart | Migrated grid/border/card geometry; meal ColorScheme mapping and date arithmetic unchanged. |
| MealPlanAddBar | pantry_log_page.dart; plan_meal_page.dart | Both are reachable placeholders. No new feature or gating implemented. |
| Food logging scanner | barcode_scanner_page.dart | Black/white camera contrast, viewfinder and hint retained as fixed viewing chrome; device/lifecycle verification pending. |
| Nutrition measurements action | measured_items_page.dart | Reuses D3 health presentation; not remigrated. |
| Profile / training settings | analytics_setting_screen.dart and linked editors | Existing SettingsSection/SettingsActionTile ownership retained; the current Neo visual review is accepted for the listed Profile/settings routes. |
| Exercise editor media grid | exercise_editor_screen.dart | Two legacy grey surfaces and 12px geometry moved to AppMediaTokens. |
| Exercise analytics save action | exercise_analytics_screen.dart | Existing advanced-category accent and white foreground retained; the current allocation visual review is accepted, while broader contrast/accessibility qualification belongs to Q2/N6. |
| Generic trend page | default_trend_page.dart | Neo series/placeholder presentation is theme-ready, but the page still contains placeholder data and all release callers need final reachability audit. |
| Exercise definitions and history | definitions_by_bodypart_page.dart, definitions_by_muscle_page.dart, exercise_definition_info_tile.dart, full_history_screen.dart | Theme-ready surface compatibility and semantic positive metadata are in place; final Neo route recipes and state/device evidence remain pending. |
| Cardio and stretch cards | cardio_card.dart, stretch_card.dart | Theme-ready surface boundary plus semantic timer/add-action colors; full product flows and final Neo design remain deferred. |
| Current measurements | current_metrics_section.dart | Neo metric accents resolve through data-visualization roles; Classic keeps its original palette; route/state qualification remains pending. |

## Theme-Ready Compatibility Extension (2026-09-15)

The newly covered consumers are prepared for both families without being
declared fully Neo-complete. `TonosThemeReadyCard` keeps the original Classic
`Card` behavior and resolves a semantic Neo `TonosSurface`; targeted
measurement, timer, add-action, and nutrition foreground colors use existing
semantic or visualization roles. No route, persistence, query, unit,
repository, or product-flow behavior changed.

Final route-specific geometry, loading/empty/error states, accessibility,
device evidence, and complete product flows remain deferred until the affected
features stabilize. The compatibility boundary is not an inventory-ratchet
enrollment decision. test/theme/pre_q2_route_evidence_test.dart now verifies
that each listed wrapper consumer retains TonosThemeReadyCard and that the
measurement/nutrition semantic consumers retain their token accessors.

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
- Preserve the accepted 21-item visual review; request only focused rechecks if
  a later change affects one of those presentations.
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
