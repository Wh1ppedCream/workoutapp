# Theming Batch Playbook

## Current Pre-Q2 Status

[Pre-Q2 Closeout Ledger](theme-pre-q2-closeout.md) is the current status summary.
It supersedes older pending-test labels in the historical implementation records
below. The latest user run passed 200 scoped theme/configuration tests and
verified the review corrections. Device, manual, visual-parity, accessibility, and broader production-enrollment
qualification remain Q2 work.

## C3-D3 Review Correction (2026-09-09)

Source review found Classic color drift in D2/D3 and lost responsive corner
scaling in exercise progress. Those fixes passed the user-reported 168-test
scoped run; device qualification remains open.

- Register and consume AppProgressColors for progress accent, estimated series,
  grid, labels, and distinct exercise/workout/health direction recipes. Do not
  substitute generic data-visualization colors just because names seem similar.
- Preserve legacy health cardColor and dividerColor; keep neutral health text
  and sparse icons inherited. The generic info-card surface is not equivalent.
- Multiply exercise hero/stat/selector/add-tile shape tokens by layout.scale.
  Tooltip geometry was not scaled previously and must remain unscaled.
- Preserve each outer corner of the history segmented selector independently,
  including when a future theme supplies asymmetric corners.
- Run progress_classic_parity_test, health token/source tests, and measured-items
  rendered tests alongside the complete theme suite. Token tests cover both
  Classic modes, fallback, copying, and interpolation; source contracts are only
  adoption checks, not visual or interaction proof.

No data, navigation, unit-conversion, or chart-range changes are intended.
Device visual checks and full-release qualification remain pending. This review
correction supersedes older statements below about generic progress palettes
and shared health-card surfaces.

Updated 2026-09-08. This is the execution guide for forthcoming work under
[the theme plan](theme-design-plan.md). Paths below are repository-relative to
E:\projects\env_test. Search anchors are preferable to line numbers, which change
after formatting. All targets must be read again before editing.

## Current Status And Evidence

B1-C2 review follow-up and C2-D3 are now scoped-verified. The user reported
clean scoped analysis and 168 passing scoped tests for the C3-D3 follow-up.
The current pre-Q2 closeout also passed clean analysis and 200 scoped tests.
These results supersede the pending verification labels in the historical
implementation records below. Device and full-release qualification remain
pending and are tracked separately in the closeout ledger.
The review found and corrected the C2 handle's accidental 0.55-to-0.50 opacity
change with an independent exercise-detail handle opacity role. It also removed
an unused C2 test import, made extension fallbacks lazy, and refreshed existing
flow-node/arrow paint on dependency changes. Flow refresh retains node objects,
positions, labels, destinations, pivots, and zoomed arrow dimensions. The new
flow presentation regression test checks those data invariants.
Prior batch test results below describe the earlier revisions. The 157-test
run verifies these follow-up fixes. C2 source-string assertions only establish source
adoption: rendered tab selection, scroll preservation, loading/error states,
and matched device appearance remain pending evidence.

- Classic is the only registered family. No alternate family is authorized by
  this migration guide; Step 19 still gates Step 13 implementation.
- Foundations, Material ownership, preference queue, and shared primitives exist.
  Adoption and release qualification are incomplete. Do not rebuild the foundation.
- The latest B6 user run passed 141 tests from test/theme and
  test/providers/app_configuration_test.dart. Analysis covered the B6 route
  callers, lib/theme, and test/theme. It was not a full-repository analyzer
  run, full application test suite, or device review.
- C1 is scoped-verified with clean analysis and 148 focused tests. It adds
  separate catalog selection, catalog usage, catalog outline, media frame,
  media placeholder, and media outline owners while preserving the existing
  Classic recipes. This is scoped automated evidence; device review and
  full-repository qualification remain pending.
- C2 is implemented-awaiting-verification. It migrates the exercise-detail
  sheet's form-guide, metrics, records, chart, selector, and sheet-shell
  recipes to focused roles while preserving tab selection, expansion, scroll,
  record identity, and empty/loading/error states. C3 still owns zoom and
  media-overlay decisions.
- The latest swap actions, equipment filter, match badge, and match marker are
  implemented with scoped verification. Preserve these components and tests.
- Step 12B is in progress. B1 is scoped-verified with clean analysis and 134
  passing tests. B2 is scoped-verified with clean analysis and 136 passing
  tests. B3 is scoped-verified with clean analysis and 143 passing tests.
  B4 is scoped-verified with clean analysis and 144 passing tests. B5 is
  scoped-verified with clean analysis and 143 passing tests. B6 is now
  scoped-verified with clean analysis and 141 passing tests. C1 is now
  scoped-verified with clean analysis and 148 focused tests.
  A candidate can be closed by a justified keep decision as well as an edit.
- Step 12A retains residual classification/reachability work. Its many settings
  migrations do not prove all settings expressions are qualified.
- Steps 12C-12E have some earlier token adoption, but the batches below are still
  planned. Steps 2, 3, 17, 18 and 19 retain evidence or qualification work.

The earlier Step 17 bug descriptions are historical repair specifications.
Current source has outlineVariant for SettingsStatusBadge, a dedicated drawer
heading foreground, and a shared provider mutation queue. Recheck their tests
when relevant; do not introduce a second repair merely because old prose says
"currently broken." A new failure must identify the failing behavior and evidence.

## Mandatory Rules For Every Batch

1. Read AGENTS.md, the selected consumer, its callers, and the actual Classic
   factory output. Preserve unrelated working-tree changes. Include untracked
   theme files in inspection; git diff alone cannot show their contents.
2. Record the original recipe before editing: base color, alpha operation,
   radius, padding/margin, font source and overrides, enabled/selected states,
   Material inheritance, and callbacks. Record the current source baseline and
   link earlier evidence when claiming pre-extraction parity.
3. Assign each candidate one disposition: keep Material-owned, reuse a role,
   add a justified role, extract a shared recipe, or document a fixed exception.
   A search hit is not automatically a defect. No change is a valid reviewed result.
4. Match semantic purpose AND resolved Classic output before reusing a role.
   Equal radii or colors alone are insufficient. Read Classic copyWith overrides
   as well as fromColorScheme defaults. Never repair a local mismatch by changing
   a global token relied on by other consumers.
5. Extract presentation only. Keep scoring, IDs, persistence, navigation results,
   provider ownership, async ordering, focus, controller lifetime, and business
   timing in their existing owners. A discovered behavior bug gets its own
   explicit fix and regression evidence, not a silent theme refactor.
6. Test the changed risk: an independent Classic expectation and an injected
   theme expectation serve different purposes. Preserve meaningful behavior
   tests. Avoid tests that merely compare a token to the same token it supplies.
7. Follow the user-run verification procedure below. Correct failures before
   starting another code batch. Record source-inspected, user-tested, and
   manually-reviewed evidence separately.
8. Update the batch record, plan, and inventory only to the extent demonstrated.
   Do not mark an entire file migrated when any expression or reachable state
   remains unclassified. Keep pending debt visible.

Specific traps already encountered:

- Classic divider/subtleOutline are fixed gray overrides. They do not equal
  outlineVariant with alpha 0.55. The swap filter uses swapFilterBorder for this
  reason. The premade action-bar outlineVariant alpha 0.6 is also intentional.
- withAlpha(n) replaces alpha with n/255. withValues(alpha: x) also sets alpha;
  multiplying an existing alpha is a different recipe. Preserve nullable color
  behavior such as bodySmall?.color?.withAlpha(184).
- A Card with no explicit style inherits Material/CardTheme. Replacing it with
  a generic Container or setting an explicit color can change tint, elevation,
  margin, clipping, and shape. Keep the Card unless a documented variant needs it.
- TextTheme role names do not establish equivalence. The Train pill already had
  a font-size regression. Compare resolved size, weight, height, spacing and
  inheritance; preserve scale multipliers and accessibility scaling.
- Moving GestureDetector outside padding changes the tap target. Altering an
  InkWell/Material boundary changes ink behavior. Preserve both deliberately.
- A Duration may control tutorial readiness or business logic. Only visual
  animation durations belong in motion roles; do not tokenize every Duration.
- Keep keys and stateful widget positions stable during extraction. Theme
  replacement must not recreate a session, controller, route, or provider.

## Token And Recipe Changes

Owners: lib/theme/tokens/, lib/theme/widgets/, lib/theme/classic_theme.dart,
lib/theme/theme_extensions.dart, and lib/theme/app_material_theme.dart.

Before adding a field, search existing roles and document why none represents
the same meaning. Prefer a role name describing purpose over a numeric value.
For each field implement constructor/default or factory initialization, storage,
copyWith retention/replacement, and lerp. Verify both Classic brightness modes
and fallback accessors. An optional Classic default must not disappear during
copyWith or interpolation; it still needs explicit alternate-theme assignment
when that future family is built. Update any independent completeness fixtures
that enumerate fields. Preserve unrelated extensions in injected test themes.

Place standard component behavior in Material component themes. Place repeated
Tonos presentation in a narrowly scoped widget. Keep localized labels supplied
by the consumer when the component does not own domain formatting. Keep fixed
layout dimensions where they express layout rather than family styling.
Do not add speculative knobs, family switches in feature widgets, or new global
fonts just to make a migration larger.

## Step 12B Queue

### B1. Plan Thumbnail And Secondary Copy

Status: scoped-verified; 134 tests passed with clean analysis.

Targets: lib/widgets/preset_bar.dart (_heatmap thumbnail build, _AutomaticBadge),
lib/widgets/swap_exercise_sheet.dart (_ExerciseSwapBox equipment TextSpan),
lib/screens/exercise/preset_detail_screen.dart (remaining TextStyle), and their
existing workout tests in test/theme/widgets/ and workout_token_regression_test.dart.

The current batch adds `AppSurfaceTokens.presetFocus`, initialized as the
scheme surface at alpha 0.35, and uses it through `WorkoutThumbnailFrame` in
`PresetBar`. It preserves 60 * scale size, 3 * scale padding, the 10 * scale
corner radius, and the heatmap's available size. `swapSecondaryTextOpacity`
preserves the swap equipment `bodySmall` color with alpha 184/255 without
replacing inherited typography.

Inspect surface alpha 0.35 and radius 10 * scale around the preset heatmap.
The scaled radius, dimensions and padding remain in the frame because they are
layout/scale-sensitive; `mediaThumbnail` is not silently reused. Preserve the
heatmap's available size.
The automatic badge already consumes semantic colors: review its scaled text,
do not change its identity color or replace its 12 * scale font by a larger role.
Review the swap equipment text's nullable alpha 184 override. The numeric
opacity is now token-backed while null inheritance remains intact.
Inspect the preset-detail TextStyle in context before deciding it is structural.

Exit: changed recipes resolve identically under Classic and respond to injected
roles; scale and null-style cases are accounted for. Existing action, selection,
heatmap and text truncation behavior is preserved. Record any intentional kept style.

### B2. Train Header And Plan List States

Status: scoped-verified; clean analysis and 136 focused tests passed.

Targets: lib/screens/exercise/train_page.dart, lib/widgets/presets_loaded.dart,
lib/widgets/preset_info_card.dart. Search the lightGreen profile avatar,
panelRaised alpha 0.75, outline alpha 0.18, primary alpha 0.45 and plan palette.

Classify the profile/plan identity palettes before moving them. A stable identity
color is not success/error state; use a domain palette or a documented exception.
Review selected/unselected surfaces, empty lists, edit controls and collapsed
plan sections. Transparent paint may intentionally expose a parent and can stay.
Preserve Overview/Plans text sizing, scale behavior, plan order, selected profile,
scroll position, popup actions and the split Start Workout/Optimize callbacks.

Exit: every changed state has a Classic comparison; a theme replacement preserves
tab, plan selection and scroll state. Palette disposition has a rationale.

B2 implementation record (2026-09-08, scoped-verified): train tab surface,
split workout divider, and plan reveal border opacities now have named surface
roles with the original 0.75, 0.18, and 0.45 values. The repeated plan palette
and profile avatar identity value now have dedicated fixed identity owners rather
than feature-local declarations; they remain intentionally outside semantic
success/error roles. PresetInfoCard was audited and kept its existing
data-visualization, surface, semantic-content, inherited-card, and standard
Material ownership. Plan order, active filtering, reveal state, selected
profile, navigation callbacks, popup actions, and split workout callbacks were
not changed. Focused source, palette, and token interpolation tests were added;
user-run analysis and tests passed with 136 focused tests. No device review or
full-repository qualification is implied.

### B3. Premade And Automatic Plan Presentation

Status: scoped-verified; clean analysis and 143 focused tests passed.

Targets: lib/screens/exercise/premade_plans_page.dart,
lib/screens/exercise/auto_preset_flow_screen.dart,
lib/screens/exercise/optimized_workout_settings_page.dart,
lib/widgets/flow_widgets.dart and lib/widgets/flow_screen_widgets.dart.

Inspect premade duration animation (180ms), detail text overrides and alpha 0.55
labels; retain the already-correct action-bar outlineVariant alpha 0.6. Inspect
the automatic-flow grid and error/expansion-card recipes at alpha 0.6, 0.46,
0.05, 0.04 and 0.16. Keep flow category/loopback meaning in flow tokens. Inspect
both expanded and collapsed cards and all branch/loopback creation paths.
Decide whether the 180ms transition is a motion-token candidate from its use,
not its value. Do not alter generator inputs, durations used for workout planning,
network requests, equipment compatibility, sorting, or creation results.

Exit: light/dark collapsed, expanded, loading, unavailable and enabled action
states are accounted for; motion override affects animation only. Shared-widget
callers outside 12B are inspected if their presentation can change.

B3 implementation record (2026-09-08, scoped-verified): the premade plan
expansion now reads `motion.quick`, preserving Classic's 180ms visual transition
without moving planning or generator timing. The swapped-exercise badge reads a
named `planSwapBadgeOpacity` surface role, preserving alpha 0.55 and the shared
pill geometry. Automatic-flow initialization and dashboard rebuilds now use the
flow canvas and data-visualization grid roles consistently, preserving the
recorded Classic light and dark grid colors. The destructive border and flow-card
border, collapsed, expanded, and icon opacity recipes now have named surface
roles with the original 0.6, 0.46, 0.05, 0.04, and 0.16 values. Success, failure,
and loopback meaning remains in flow tokens. Optimized-workout settings and the
shared flow widgets were inspected and retained their existing semantic,
surface, shape, and standard Material ownership where no B3 extraction was
justified. Plan creation, sorting, compatibility, callbacks, flow mutation,
branch/loopback behavior, keys, and stateful expansion behavior were unchanged.
Token default, copy, interpolation, source-adoption, and Classic grid-parity
coverage was added or extended. User-run verification passed with no analyzer
issues and 143 focused tests; no device review or full-repository qualification
is implied. B4 implementation is recorded below and is now scoped-verified.

### B4. Active Session Consumer Audit

Targets: lib/screens/exercise/session_screen.dart, lib/widgets/exercise_card.dart,
lib/widgets/weight_card.dart, lib/widgets/add_exercise_fab.dart,
lib/widgets/ongoing_session_fab.dart, lib/widgets/active_session_durability_banner.dart,
and lib/theme/widgets/workout_actions.dart.

Most WeightCard and exit-action recipes already migrated. Inventory what remains
before editing. Exercise unfinished/completed and collapsed/expanded sets,
change sets, read-only states, units, add/remove actions and an empty session.
Retain the tested text-controller/focus/selection preservation across theme
replacement, and the exact save/discard/remember results. Retain finish busy
behavior and its button key. The 420ms tutorial delay in SessionScreen is a
readiness candidate for review, not automatically theme animation.

Exit: classify residual styling and extend existing tests only for uncovered
behavior or changed recipes. Do not rewrite the working session lifecycle to
make a widget test easier. Record any unresolved full-consumer evidence.

B4 implementation record (2026-09-08, scoped-verified): the
active-session audit found the existing WeightCard completion/read-only/unit,
controller/focus, change-set, and add/remove recipes already token-backed or
intentionally local to the control. SessionScreen keeps inherited timer
typography with deliberate 20px and 48px display sizes, and keeps the 420ms
tutorial readiness delay because it is onboarding timing rather than theme
animation. ExerciseCard remains a delegation wrapper; cardio and stretch are
explicitly deferred by its existing product TODO. AddExerciseFab uses the
semantic primary-action roles while retaining the standard FAB and catalog
callback flow. OngoingSessionFab uses semantic ongoing-session action roles,
focused dialog surface/shape roles, shared exit actions, and existing keys;
save/discard/remember behavior is unchanged. ActiveSessionDurabilityBanner uses
ColorScheme feedback colors plus effect and shape tokens while retaining its
retry/live-region behavior. Shared workout actions retain their standard
Material defaults and focused semantic/surface/shape ownership. No new
production token was justified. A source-adoption contract now protects these
boundaries and the intentional keep decisions. Existing focused behavior tests
remain the evidence for callbacks, busy state, state preservation, accessibility,
and dialog behavior. User-run scoped formatting, analysis, tests, and git diff
check passed; the focused suite completed with 144 tests and no analyzer issues.
The printed restore StateError was the expected simulated failure from the
durability-banner test, followed by a passing retry path. No device review or
full-repository qualification is implied. B5 is now scoped-verified.

### B5. Completion And Saved History Audit

Status: scoped-verified; clean analysis and 143 focused tests passed.

Targets: lib/widgets/session_complete_sheet.dart,
lib/screens/exercise/session_detail_screen.dart, lib/widgets/workout_record_badges.dart,
lib/theme/widgets/workout_sheet_handle.dart, lib/widgets/set_stat_chip.dart.

Review the already-tokenized withValues expressions before adding more fields.
Check summary tiles, metric groups, record/no-record variants, Done action,
editable/read-only states and empty/missing values. Keep distinct opacity roles
for metric, set, exercise and record surfaces. Preserve record-tier identity,
date/duration formatting, unit conversion, edit commits and sheet dismissal.

Exit: account for every residual expression in the selected scope; verify any
changed rendered composition under Classic plus injected roles. A no-change
audit with evidence is preferable to duplicating existing roles.

B5 implementation record (2026-09-08, scoped-verified): the
completion and saved-history audit confirmed that completion metric, set-marker,
and exercise-group opacity remain independent surface roles. Completion metrics
retain separate data-visualization accents, the Done action retains its shared
48px filled recipe, and the sheet handle retains its dedicated surface role and
pill geometry. Session-detail summary tiles use the independent
`sessionSummary` surface and metric shape; heatmap colors remain owned by data
visualization tokens; saved-session editing, unit conversion, date/duration
formatting, empty states, callbacks, and dismissal behavior are unchanged.
Record badges retain separate first-record and monthly/all-time meanings,
dedicated full/compact geometry, and independent fill/border opacity roles.
SetStatChip retains the metric surface and shape, while standard Material
dialogs/buttons and compact badge typography remain local or framework-owned.
No new token was justified. A source-adoption contract now protects the B5
boundaries and preserves the distinction between structural surfaces and data
meaning. Existing rendered tests cover injected metric-chip, handle, badge,
and action recipes; the B5 source contract adds explicit coverage for the
completion and saved-history owners. User-run scoped formatting, analysis,
tests, and git diff check passed; the focused suite completed with 143 tests and
no analyzer issues. No device review or full-repository qualification is
implied. B6 route/evidence closure is now scoped-verified.

### B6. Close The 12B Route And Evidence Ledger

Status: scoped-verified; clean analysis and 141 focused tests passed. The route
ledger and source contract are in place; no production route behavior changed.

Targets: all B1-B5 paths plus `lib/main.dart`,
`lib/screens/exercise/train2_page.dart`, and
`lib/screens/exercise/preset_generation_qa.dart`.

Route ledger:

| Entry point | Reachable states | B6 disposition | Automated evidence | Manual evidence |
| --- | --- | --- | --- | --- |
| `main.dart` startup and `/main` | startup gate, onboarding, current app shell | release-owned; Theme Lab is not a release fallback | `b6_route_evidence_test.dart`, existing app-configuration tests | cold launch, saved light/dark mode, onboarding decision |
| `MainScreen` Train tab | current `TrainPage`, cached tab state, active-session FAB | B1-B5 release caller | B6 route contract plus existing Train/consumer contracts | switch tabs with and without an active session |
| `TabItem.train2` | legacy `Train2Page` when enabled in navigation settings | release-reachable today; not debug-only because the build policy does not classify it as experimental | B6 policy and route contract | enable the tab in a release-like build and inspect Train/History, drawers, and optimized flow |
| `TrainPage` | Overview/Plans, manual plan, generated plan, premade plan, optimized settings, active session | B1-B5 caller; remaining unclassified consumers stay in later slices | existing B1-B5 contracts and B6 caller contract | exercise every action in light/dark Classic |
| `Train2Page` | legacy Train/History, plan detail, generated plan, optimized workout, catalog drawer | included for reachability; do not call the legacy route fully migrated | B6 caller contract; existing consumer tests | compare legacy route states with current Train route |
| `PresetGenerationQaScreen` | normal generation and `onboardingMode` generation, validation/error, body-part/muscle branches | release-reachable from Train, legacy Train2, dashboard, and onboarding | B6 caller contract and existing plan-generation tests | generate one and multiple plans from each entry point |
| `SessionScreen` and completion sheet | new, resumed, optimized, and completed workout paths | B4/B5 release caller | existing session/completion tests plus B6 caller contract | finish, save, dismiss, and reopen a session |
| saved-session detail | history, dashboard, progress, and exercise-detail entry points | B5 caller; detail styling remains split with C2/C3 where applicable | existing history/detail tests plus B6 caller contract | open an empty, normal, and editable saved session |
| Theme Lab | compile-time debug entry and debug-only named route | developer-only and fail-closed outside debug | B6 route contract and Theme Lab widget test | run only with the explicit debug define |

Trace release callers, not only tab visibility. `Train2Page` is legacy but is
currently reachable in release builds if a user enables its tab, so it must not
be described as developer-only without a separate product decision. The
unfinished nutrition/history/form tabs remain denied by
`NavigationBuildPolicy` in release builds. Theme Lab has both a debug-only
route registration and a widget-level debug guard.

The shared catalog/detail sheet is assigned to C1-C3, and tutorial overlay,
spotlight, scrim, and readiness behavior are assigned to E1. Step 12A settings
residue remains outside B6. These dependencies are named here so reachability
does not get mistaken for complete visual qualification.

Exit: all B6 route findings have a named disposition, all B1-B5 callers are
traced, and remaining cross-phase dependencies are explicit. The inventory
manifest is unchanged because B6 adds evidence rather than a new ownership
classification. Step 12B cannot be called fully complete with unexplained debt
or missing required parity evidence. Do not estimate completion by test count.

B6 verification command:

```powershell
dart format test\theme\b6_route_evidence_test.dart
dart analyze lib\main.dart lib\providers\nav_bar_config.dart lib\theme lib\screens\exercise\train_page.dart lib\screens\exercise\train2_page.dart lib\screens\exercise\preset_generation_qa.dart lib\screens\onboarding_flow.dart lib\widgets\dashboard_sections.dart lib\screens\exercise\session_screen.dart lib\widgets\past_sessions_list.dart test\theme
flutter test test\theme test\providers\app_configuration_test.dart
git diff --check
```

User-run B6 verification (2026-09-08): formatting reported no changes,
analysis reported no issues, the focused suite passed with 141 tests, and
`git diff --check` reported only existing line-ending warnings. This is scoped
verification only; no device review or full-repository qualification is
implied.

## Following Migration Batches

### C1. Catalog Search, Filters And Cards

Targets: lib/screens/catalog_page.dart,
lib/screens/exercise/exercise_catalog_page.dart,
lib/screens/exercise/muscle_filter_page.dart,
lib/widgets/exercise_media_thumbnail.dart and shared_entity_media_thumbnail.dart.

Inspect current 14/12/16px frame variants and selected-card alpha 0.45; choose
roles by purpose. Preserve search query, filters, exercise identity, list position,
loading/empty/error states, image aspect ratio and fallback rendering. Check the
real card in both modes with an available image and a missing image. Do not
change catalog localization, database identities or manufacture missing artwork.
Exit: card/filter owners and media exceptions are explicit; state survives a
theme replacement and long localized labels remain usable.

C1 implementation record (2026-09-08, scoped-verified):
`AppSurfaceTokens` now owns separate `catalogSelection`, `catalogUsage`, and
`catalogOutline` roles for catalog structure, plus `mediaFrame`,
`mediaPlaceholder`, and `mediaOutline` roles for the two thumbnail owners.
`ExerciseCatalogPage` keeps its selected-row alpha 0.45, border widths,
selection callback, filtering, and exercise-detail action while resolving the
selected and unselected catalog treatments through the focused roles.
`CatalogPage` keeps the usage-row alpha 0.65 and its border through catalog
roles. `ExerciseMediaThumbnail` and `SharedEntityMediaThumbnail` keep their
sizes, caller-supplied radii, padding, fit/scale, cache refresh, missing-file
recovery, fallback, Wi-Fi-only, retry, and localized semantics behavior while
moving frame and transient media-overlay colors to media roles. `MuscleFilterPage`
continues to own the bodypart/muscle-specific fallback content and sizes.

Standard `Card`, `TextField`, filter-dialog, and tab recipes remain
Material-owned because C1 found no app-specific override that needed a Tonos
replacement; their behavior and layout were not changed.

The C1 source contract covers role adoption, Classic-derived defaults,
copy/interpolation, and the preserved fallback/retry paths. The inventory
manifest remains report-only and unchanged; this batch does not alter catalog
localization, database identities, artwork, or route behavior. User-run
formatting and analysis reported no issues, the focused suite passed with 148
tests, and diff-check reported only existing line-ending warnings. C1 is
scoped-verified at the scoped automated level; device review of real and
missing media, full-repository qualification, and broader visual parity remain
pending.

C1 verification command:

```powershell
dart format lib\theme\tokens\app_surface_tokens.dart lib\screens\catalog_page.dart lib\screens\exercise\exercise_catalog_page.dart lib\screens\exercise\muscle_filter_page.dart lib\widgets\exercise_media_thumbnail.dart lib\widgets\shared_entity_media_thumbnail.dart test\theme\app_theme_tokens_test.dart test\theme\catalog_media_contract_test.dart test\theme\widgets\settings_tiles_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\widgets\tonos_surface_test.dart
dart analyze lib\main.dart lib\theme lib\screens\catalog_page.dart lib\screens\exercise\exercise_catalog_page.dart lib\screens\exercise\muscle_filter_page.dart lib\widgets\exercise_media_thumbnail.dart lib\widgets\shared_entity_media_thumbnail.dart test\theme
flutter test test\theme test\widgets\media_accessibility_contract_test.dart test\exercise_catalog_audit_contract_test.dart test\providers\app_configuration_test.dart
git diff --check
```

### C2. Detail Tabs, Form Guide, Metrics And Records

Target: lib/widgets/exercise_detail_sheet.dart and its actual child consumers.
Search 18/12px frames, accent alpha 0.32/0.16, metric badges (0.13/0.28), and
later selected/tab/filter recipes. Split this large file by section and state.
Preserve tab selection, sheet expansion, scroll, record identity and empty metrics.
The anatomy image/data palette and surrounding chrome require separate decisions.
Exit: each migrated section has a state list and an independent Classic check;
unreviewed sections remain pending rather than inheriting the section's status.

C2 implementation record (2026-09-08, implemented-awaiting-verification): the
detail sheet now routes its custom form-guide cards, tags, metrics selector,
metric summaries, rep-best list, loading/error/empty state card, saved-record
cards, record actions, chart surfaces, chart grid/tooltip treatments, and
sheet elevation/geometry through focused surface, shape, motion, and effect
roles. Classic values are unchanged: the existing 0.52/0.58/0.42/0.44/0.26/
0.28/0.96 surface recipes, detail opacities, 9/10/11/13/15/16/18px radii,
160ms selector/chart motion, and elevation 12 are represented by tokens.
Material `TabBar`/`TabBarView` ownership remains intact. Data-series colors,
the anatomy heatmap, image preview, zoom viewer, scrims, and media fallback
chrome remain outside this batch for C3 or data-visualization ownership.
The contract test protects role adoption, Classic-derived defaults,
copy/interpolation, tab/state evidence, and the preserved empty/loading/error
paths. User-run verification is still required; device review and
full-repository qualification remain pending.

C2 verification command:

```powershell
Set-Location E:\projects\env_test
$ErrorActionPreference = 'Stop'
dart format lib\theme\tokens\app_surface_tokens.dart lib\theme\tokens\app_shape_tokens.dart lib\theme\tokens\app_motion_tokens.dart lib\theme\tokens\app_effect_tokens.dart lib\widgets\exercise_detail_sheet.dart test\theme\exercise_detail_contract_test.dart test\theme\widgets\settings_tiles_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
dart analyze lib\main.dart lib\theme lib\widgets\exercise_detail_sheet.dart test\theme
if ($LASTEXITCODE -ne 0) { throw 'Analyzer failed.' }
flutter test test\theme test\widgets\workout_record_badges_test.dart test\providers\app_configuration_test.dart
if ($LASTEXITCODE -ne 0) { throw 'C2 tests failed.' }
git diff --check
```

### C3. Zoom And Media Overlays

Status: implemented-awaiting-verification. User authorized C3 before the
B1-C2 review fixes were verified; verify both together before another batch.

Implementation: AppMediaTokens owns detail preview (18px), heatmap overlay
(12px), and viewer (20px) shapes, overlay opacity (0.96), and overlay shadows
(black at 0.30, blur 10, offset 0/3). Classic registers the extension and plain
ThemeData has a fallback. An empty overlayShadow list disables this effect.
Existing media surface/outline roles own the surrounding frame colors.
MediaViewingColors narrowly preserves the black image backdrop, black87 modal
barrier, black 0.45 zoom indicator, white icon and white70 hint. These constants
serve image contrast and do not exempt other styling in the detail sheet.
Full-size image decoding now has a broken-image fallback; preview failure and
thumbnail retry/cache behavior retain their existing owners. Image cover versus
contain, min/max zoom, boundary margin, scrolling and dismiss actions are kept.
BodyHeatmap and its anatomy palette were inspected as data/illustration owners
and are unchanged. Added media token and missing-file widget checks. User-run
tests, real-image device inspection, pan/zoom/dismissal checks and rendered
effects-disabled overlay evidence remain pending; C3 is not qualified.

Target: exercise_detail_sheet.dart zoom/modal paths, thumbnail consumers and
body_heatmap.dart only where those paths depend on it. Inspect black scrims,
white zoom controls, black87 barriers, shadow alpha 0.30 and frame clipping.
Decide whether each is a media-viewing constant or family presentation. Preserve
pan/zoom, dismissal, background contrast, fallback images and overlay semantics.
Exit: image and missing-image states plus an effects-disabled path are covered;
fixed media treatment has a narrow exception. No blanket file exemption.

### D1. Dashboard And Logbook Structure

Status: implemented-awaiting-verification. The implementation is limited to
actual dashboard/logbook hosts; the non-default `CombinedHistoryPage` remains
an explicit placeholder and was not turned into a second history product flow.

Targets: lib/screens/dashboard_page.dart, combined_history_page.dart,
lib/screens/exercise/history_screen.dart, full_history_screen.dart,
lib/widgets/dashboard_sections.dart, history_content.dart, history_summary_widget.dart,
past_sessions_list.dart and workout_history_calendar.dart.
Trace actual hosts first. Migrate structural surfaces, headers, period selection
and empty states while retaining date selection, list/calendar position and
record navigation. Calendar data meaning stays distinct from structural selection.
Exit: populated/empty states and date/scroll preservation are covered.

D1 implementation record (2026-09-08, implemented-awaiting-verification):
`AppSurfaceTokens` now owns the dashboard hero, dashboard section/editor/usage,
history period selector, calendar mode/day-empty, selected-period, and history
divider recipes. `AppShapeTokens` owns the distinct dashboard hero, section,
editor, action, usage, row, footer, and selected-period geometry. Classic keeps
the original 0.54, 0.34, 0.46, 0.60, 0.35, 0.45, and 0.22 resolved recipes and
the original 13/14/16/18/20/22/24px radii.

`DashboardPage` and `dashboard_sections.dart` now resolve their structural
containers and interaction geometry through those roles. The history summary
period selector, calendar mode controls, empty calendar days, selected-period
summary, and summary dividers do the same. Calendar intensity remains a
data-driven primary-alpha treatment, while Material `Card` recipes in the
past-session/full-history owners remain framework-owned. No route, callback,
date-range, selected-period, list/calendar position, refresh, tutorial, or
session-navigation behavior was changed. `HistoryContent`, `HistoryScreen`,
`PastSessionsList`, and `FullHistoryScreen` received source-parity coverage for
those boundaries. The report-only inventory manifest remains unchanged.

Added `dashboard_history_contract_test.dart` for consumer ownership/state
evidence and `dashboard_history_tokens_test.dart` for Classic light/dark,
override, and interpolation coverage. User-run formatting, analysis, tests,
and diff-check are still required; device review and full-repository
qualification remain pending.

D1 verification command:

```powershell
Set-Location E:\projects\env_test
$ErrorActionPreference = 'Stop'
dart format lib\theme\tokens\app_surface_tokens.dart lib\theme\tokens\app_shape_tokens.dart lib\screens\dashboard_page.dart lib\widgets\dashboard_sections.dart lib\widgets\history_summary_widget.dart lib\widgets\workout_history_calendar.dart test\theme\widgets\settings_tiles_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\dashboard_history_contract_test.dart test\theme\dashboard_history_tokens_test.dart
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
dart analyze lib\main.dart lib\theme lib\screens\dashboard_page.dart lib\widgets\dashboard_sections.dart lib\widgets\history_summary_widget.dart lib\widgets\history_content.dart lib\widgets\past_sessions_list.dart lib\widgets\workout_history_calendar.dart lib\screens\exercise\history_screen.dart lib\screens\exercise\full_history_screen.dart test\theme
if ($LASTEXITCODE -ne 0) { throw 'Analyzer failed.' }
flutter test test\theme test\providers\app_configuration_test.dart
if ($LASTEXITCODE -ne 0) { throw 'D1 tests failed.' }
git diff --check
```

### D2. Progress Charts And Records

Status: scoped-verified. The scoped implementation is in place for progress
charts, data records, workout metrics, and the workout dashboard. The user
reported clean analysis and 158 passing focused tests; device review and
full-release qualification remain pending.

Targets: lib/widgets/exercise_progress_section.dart, data_records_section.dart,
workout_metric_chart_card.dart and workout_dashboard.dart.
Separate frame/label/selection roles from series, thresholds and record-tier
colors. Reuse data-visualization roles only for the same measure/meaning.
Preserve units, selected period/exercise, tooltips, interactions and zero/no-data
semantics. Exit: representative long values, zero and missing records, and
theme replacement are covered; meaning is available beyond color alone.

D2 implementation record (2026-09-08, scoped-verified):
`AppSurfaceTokens` now owns the progress hero/stat/selector/tooltip surfaces and
the workout-metric stat/chart/tooltip/range/details/insight surfaces.
`AppShapeTokens` owns the corresponding progress and metric geometry, including
chart tooltip and range-option radii. Classic preserves the existing 10/12/14/
16/18px recipes and the original surface alpha recipes.

`ExerciseProgressSection` now separates structural surfaces and geometry from
data-visualization series, grid, labels, selection, and positive/negative/neutral
delta meaning. `DataRecordsSection` keeps record-today container, border, and
content colors in data-visualization roles and uses the shared divider for
ordinary days; the existing today alpha is preserved in the token itself.
`WorkoutMetricChartCard` now routes stat/chart/range/details/insight frames and
tooltip geometry through focused surface/shape roles while keeping chart series,
grid, labels, selection, and trend meaning in data-visualization roles.
`WorkoutDashboard` now uses the existing dashboard section/action and settings
input roles while preserving scale-aware geometry and session callbacks.
Units, selected exercise/range, chart selection, tooltips, empty chart paths,
and callback/state code were not changed. Added
`progress_records_contract_test.dart` and `progress_records_tokens_test.dart`
for ownership, Classic recipes, copy/interpolation, and preserved state-path
evidence. User-run scoped verification passed with no analyzer issues and 158
focused tests. These source contracts do not replace rendered long-value,
zero/missing-record, device, or full-release checks.

D2 verification command:

```powershell
Set-Location E:\projects\env_test
$ErrorActionPreference = 'Stop'
dart format lib\theme\tokens\app_surface_tokens.dart lib\theme\tokens\app_shape_tokens.dart lib\widgets\exercise_progress_section.dart lib\widgets\data_records_section.dart lib\widgets\workout_metric_chart_card.dart lib\widgets\workout_dashboard.dart test\theme\widgets\settings_tiles_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\progress_records_contract_test.dart test\theme\progress_records_tokens_test.dart
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
dart analyze lib\main.dart lib\theme lib\widgets\exercise_progress_section.dart lib\widgets\data_records_section.dart lib\widgets\workout_metric_chart_card.dart lib\widgets\workout_dashboard.dart test\theme
if ($LASTEXITCODE -ne 0) { throw 'Analyzer failed.' }
flutter test test\theme test\providers\app_configuration_test.dart
if ($LASTEXITCODE -ne 0) { throw 'D2 tests failed.' }
git diff --check
```

### D3. Health And Measurements

Status: implemented-awaiting-verification. The implementation is limited to
health-trend presentation recipes and evidence; it does not rewrite the
measurement repository, validation rules, or navigation contracts.

Targets: lib/widgets/health_trends_section.dart,
lib/screens/measurement_trends_page.dart and
lib/screens/profile/settings/measurements_trends_settings_page.dart.
Inspect add/edit controls, trend cards, chart tooltips, empty states, and sheet
states with their actual callers. `AppProgressColors.healthCard` owns the
legacy `ThemeData.cardColor`; `AppSurfaceTokens.card` is a different recipe.
`AppShapeTokens`
now owns `healthTrendCard` (18px) and `healthTrendEntry` (14px), while the
existing card shape remains the 16px owner for compact/full-page trend tiles.
The tertiary series retains `AppDataVisualizationTokens`. Health grid and
direction colors use `AppProgressColors`, preserving the legacy divider and
greenAccent/redAccent values. Neutral text and sparse icons retain inherited
Material text/icon colors. Do not substitute the generic chart palette.

Preserve metric definition identity, logged values, date/context/note details,
height feet/inches and other unit conversion paths, chart range calculation,
empty/one-entry messaging, compact horizontal scrolling, full-page grid sizing,
refresh tokens, completed-session invalidation, tutorial anchors, detail-page
edit/delete return results, and settings navigation to `MeasuredItemsPage`.
Do not tokenize standard dialog/button recipes unless a future batch finds an
app-owned deviation; the entry and definition dialogs remain Material-owned.

Exit: the source contract identifies card/shape/data-visualization ownership
and all caller/state boundaries; Classic defaults and shape interpolation are
covered by focused tests; existing measured-items widget tests still cover the
two-column full-page grid and 154px compact horizontal cards. User-run
formatting, analysis, and focused tests must pass before this is marked
scoped-verified. Device checks for empty, populated, entry-edit, long localized
values, and reduced-space scrolling remain separate qualification work.

D3 implementation record (2026-09-08, implemented-awaiting-verification):
health trend cards, add cards, summary/chart cards, entry tiles, and empty
messages now resolve card surfaces and geometry through theme extensions. The
measurement series retains data-visualization ownership; the review correction
below restores the distinct grid, delta, and sparse-icon recipes. Existing
`refreshToken`, `fullPage`, `_trendsFuture`, `_entriesFuture`, `PopScope`, dialog
validation, and settings route behavior were retained. Added focused
health-measurement source and token tests plus the required shape fixture data.

D3 verification command:

```powershell
Set-Location E:\projects\env_test
$ErrorActionPreference = 'Stop'
dart format lib\theme lib\widgets\health_trends_section.dart lib\screens\measurement_trends_page.dart lib\screens\profile\settings\measurements_trends_settings_page.dart test\theme
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
dart analyze lib\main.dart lib\theme lib\widgets\health_trends_section.dart lib\screens\measurement_trends_page.dart lib\screens\profile\settings\measurements_trends_settings_page.dart test\theme
if ($LASTEXITCODE -ne 0) { throw 'Analyzer failed.' }
flutter test test\theme test\screens\measured_items_page_test.dart test\providers\app_configuration_test.dart
if ($LASTEXITCODE -ne 0) { throw 'D3 tests failed.' }
git diff --check
```

### E1. Onboarding And Tutorials

Status: scoped-verified from user output: analysis reported no issues and all
184 selected tests passed. The pasted analyzer command is truncated; retain
that evidence limitation. Device accessibility and visual qualification remain
pending. Do not interpret scoped verification as full release qualification.

Implementation:
- `AppTutorialTokens` is registered in both Classic modes, with a plain-theme
  fallback. It owns tutorial/coach frames, onboarding geometry, scrims, card
  shadows, and the existing 300/180/260/220ms visual durations. Copy and lerp
  cover every field. Material scheme colors and existing typography are retained.
- Guided spotlight clipping and its outline share one shape. Both painters
  repaint when injected scrim/shape values change, not only when targets move.
- `effectsEnabled: false` removes glow and card shadows, not the instructional
  scrim or focus outline. The interactive coach remains pointer-transparent
  outside its card; guided tutorials retain their blocking behavior.
- System reduced motion suppresses scroll, selection and page animation.
  Onboarding jumps between pages for zero duration. Theme Lab maps its reduced
  motion/effects controls into the tutorial extension without persistence.
- Target-measure retries (70ms), post-scroll readiness waits (280/240ms), Train
  readiness (650ms), Session readiness (420ms), and launcher delay (520ms) remain
  behavior-owned. Do not zero them when disabling visual motion.
- Train/Session callers, tutorial IDs, completion writes, skip-all confirmation,
  profile data, unit handling, plan generation, and navigation destinations are
  unchanged. Onboarding category colors and fixed photo contrast remain owned
  by their content, not replaced with accent colors.

Evidence added: `test/theme/tutorial_presentation_test.dart` checks Classic
defaults, all-field copy/interpolation, effects-off guided progression,
skip-all confirmation/storage, missing-target dismissal, and reduced-motion
coach interaction. The onboarding flow suite adds zero-animation advancement.
Existing responsive accessibility and tutorial storage tests must also pass.

Manual qualification pending: matched light/dark Classic captures; TalkBack
focus order and announcements; system-back behavior; long text/RTL at 1.0,
1.3, 1.6 and 2.0 scales; keyboard/rotation during target measurement; live theme
switch while a tutorial is open. Existing locale-specific tutorial reflow is
not redesigned here; broader responsive remediation remains part of Q2.

Run formatting and analysis for `lib/theme`, all three consumers below, and
the two changed test files; run the theme suite, onboarding flow suite,
responsive accessibility suite, tutorial state-store suite, and app configuration
suite. Until the user returns clean output, this is implementation evidence only.

Targets: lib/screens/onboarding_flow.dart, lib/widgets/guided_tutorial_overlay.dart,
onboarding_plan_builder_coach.dart and tutorial entry points in Train/Session.
Classify spotlight, scrim, focus, dismissal and readiness timing. Route visual
motion/effects through appropriate roles while retaining the tutorial progression
and stored completion state. Exit: reduced motion/effects-off and dismissal work;
manual accessibility checks are recorded where automation cannot establish them.

### E2. Remaining Reachable Features And Settings Residue

Status: initial migration passed 181 user-run scoped tests. E2 closeout
and route qualification remain open. Follow the detailed [E2 execution guide](theme-e2-qualification-guide.md#e2-remaining-reachable-features).
Execute E2.1 route/residue ledger, E2.2 nutrition slices, E2.3 settings residue,
then E2.4 closeout. Each slice requires independent evidence; do not combine
the entire nutrition/settings tree into an unverified replacement pass.

Current slice: food logging/customization/log-entry colors and frames now use
AppNutritionTokens; exercise-editor media tiles use AppMediaTokens. All new
defaults preserve existing Classic values, including fixed legacy greys in dark
mode. Do not silently reinterpret this as a contrast remediation. Added token
copy/interpolation checks and an unsaved-food-name theme rebuild test.
See [E2 route disposition](theme-e2-route-ledger.md) for preserved behavior,
known placeholders and remaining qualification work. No routes were removed.

Targets: lib/screens/profile/settings/, lib/widgets/settings_tiles.dart,
lib/screens/nutrition_log_page.dart, lib/screens/nutrition/, and any routes found
by the release reachability audit. Split by real feature; this is not a single
permission to rewrite every screen. Nutrition chart/category meaning belongs
in its domain tokens. Include hidden-tab routes reachable by buttons or links.
Exit: each route is qualified or explicitly gated/deferred, with a narrow reason;
12A residue and all catch-all inventory findings have a disposition.

## Qualification Batches

### Q1. Inventory Ratchet (Steps 3 And 18.1)

Status: the ratchet is implemented and verified for one exact qualified
production scope; CI enforcement is enabled for that scope. Broader enrollment
remains pending. Follow
[Q1 implementation details](theme-e2-qualification-guide.md#q1-inventory-enforcement)
and [the ratchet usage contract](theme-style-ratchet.md).
The existing inventory validator remains report-only and continues to detect
unassigned candidates. The separate ratchet now validates exact approved scopes;
its fixture and deliberate-failure behavior passed in the latest 200-test run.
Broader enrollment still needs per-file qualification; do not use the inventory
report as a production approval.

Targets: tools/theme_style_inventory.dart, docs/theme-style-inventory.json,
docs/theme-style-inventory.md, test/theme/theme_style_inventory_contract_test.dart.
The existing inventory manifest is report-only: assigned findings can still be
pending. The separate ratchet manifest now protects only qualified scopes.
Build checks fail on new unapproved structural expressions there; retain reports
for pending scopes. Test allowed media values,
rule ordering, new migrated-scope debt, and harmless formatting changes. Use
stable expression/context identities rather than line numbers alone. Update CI
only after fixture behavior is proven. Exit: demonstrated failures/successes,
no whole-repository legacy-debt blockade, and explicit exceptions.

### Q2. Switching, Typography, Effects And Accessibility (Steps 2, 17, 18)

Status: qualification pending. Existing tests are a starting point, not proof
that this matrix is complete. Follow [Q2 runtime and evidence details](theme-e2-qualification-guide.md#q2-runtime-and-accessibility-qualification).
Include newly added media/progress/tutorial extensions, in-place state preservation,
all visual durations/effects, and the documented manual checks.

Targets: lib/theme/theme_lab_page.dart, app_theme_factory.dart,
app_theme_capabilities.dart, lib/providers/theme_provider.dart, lib/main.dart,
production consumers and the corresponding theme tests.
Use injected visibly different tokens before a real alternate family exists.
Verify open-sheet, focus, text selection, unsaved state, active-session and scroll
preservation. Keep the existing shared write queue and failed-write behavior.
Test representative small screens at text scales 1.0, 1.3, 1.6 and 2.0, with
supported long-label/RTL locales where applicable. Theme Lab must exercise real
recipes, preserve other extensions, stay development-only and avoid persistence.
Exit: automated gaps are closed; matched Classic captures, TalkBack and physical
performance checks have linked evidence or a named pending decision. Manual
checks are not silently marked passed by widget tests.

### Q3. Readiness Decision (Step 19)

Status: not ready for a decision until prior evidence is reconciled. Follow
[Q3 gate and handoff details](theme-e2-qualification-guide.md#q3-readiness-decision).
Record a specific blocker or approved exception for every unresolved item;
neither documentation completion nor a test count grants Step 13 readiness.

Targets: docs/theme-design-plan.md, classic-theme-baseline.md, inventory and the
batch ledger. Reconcile Steps 2, 3, 12A-E, 17 and 18 with the actual tree and
user results. Record revision/working-tree identity and unresolved exceptions.
Exit: every prerequisite has evidence or a specific approved exception. Only
then advance to Step 13. Steps 14-16 remain separate selector/release/future-family
work. Documentation completion alone does not pass this gate.

## Verification And Handoff

Codex must not run dart format, dart analyze, flutter test, flutter pub get,
flutter run or Flutter builds, per AGENTS.md. Give exact commands to the user;
do not use placeholders in a delivered batch handoff. Add every changed consumer
to analyzer scope, including consumers outside lib/theme. Include existing
feature tests when affected; the scoped theme suite is not a substitute for them.

For a swap-visual batch, the exact established commands are:

```powershell
Set-Location E:\projects\env_test
dart format lib\theme lib\widgets\swap_exercise_sheet.dart test\theme\widgets\workout_swap_visuals_test.dart
dart analyze lib\main.dart lib\theme lib\widgets\swap_exercise_sheet.dart test\theme
flutter test test\theme test\widgets\workout_record_badges_test.dart test\providers\app_configuration_test.dart
git diff --check
```

Expand these paths for the actual batch; do not repeat this example unchanged
when editing other consumers. Inspect exit results separately: PowerShell's
ErrorActionPreference alone does not make native executable failures throw.
The formatter may modify files; inspect overlapping changes before the next edit.
Record the exact suite and result. LF/CRLF warnings alone do not establish a
failure or require a repository-wide line-ending rewrite.

Inventory checks are separate from Flutter tests. When needed, ask the user to
run the commands in theme-style-inventory.md and inspect the resulting report;
do not describe a report-only success as migrated-scope enforcement.

## Batch Record Template

Append a concise record to the theme plan after each batch:

- ID and status: planned / implemented-awaiting-verification / scoped-verified /
  qualified. Qualified also requires the batch's outstanding evidence resolved.
- Paths and search anchors; route entry points and states examined.
- Original resolved recipes and intended owner for each changed expression.
- Changes made; kept expressions and their rationale; cross-phase dependencies.
- Tests/commands actually run, who ran them, scope, result and tree identity.
- Manual evidence supplied or still pending, with required condition/decision.
- Remaining work, next batch ID, and inventory rule changes (or why none).

A large batch may combine adjacent IDs only after checking shared dependencies.
Keep each ID's acceptance record separate. Stop expansion when a validation
failure, unresolved semantic choice or newly discovered cross-feature effect
needs resolution; finish that issue before adding more migration scope.
