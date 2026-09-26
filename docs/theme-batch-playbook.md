# Theming Batch Playbook

## Current Status And Ownership (updated 2026-09-25; development evidence through 2026-09-25)

The [Consolidated Theming Roadmap](theme-consolidated-roadmap.md) is the current
task/status checklist. This playbook preserves batch scopes and historical
evidence. Q3 supersedes older pending labels for its accepted scope; later
refinements still need affected-route verification. Do not restart completed
batches solely from an older status paragraph below.

D2 Dashboard/DataRecords source-contract closeout (2026-09-25): added exact,
kind-limited ownership rules for the eight existing token-backed
`WorkoutDashboard` findings and four `DataRecordsSection` findings. The
inventory contract pins both scopes; the existing progress-record source and
token contracts continue to verify roles, Classic recipes, scale, and
navigation/callback paths. Targeted analysis was clean; the inventory contract
passed 18 tests, the progress-record source contract passed 1, the progress
token suite passed 2, and the dashboard/history contract and token suites each
passed 2. Inventory check/refresh passed at 278 files / 2,301 candidates
(92 allowlisted, 1,555 migrated, 654 pending; 1,029 uniquely queued, 1,272
outside queues, zero overlaps/unassigned). No production widget, protected
ratchet file, or ratchet manifest changed, so no new visual or ratchet approval
is claimed.

Resumed verification follow-up (2026-09-25): `PresetsLoaded` now has an exact
rule for six migrated findings and a four-mode rendered contract for archived
empty-state contrast plus the progressive Show More recipe and reveal behavior.
The initial failure was a finder matching the exact runtime type instead of
Flutter's private `OutlinedButton.icon` subtype; the test now uses a subtype
predicate. Formatting made no changes; targeted analysis was clean; the
Train/PresetsLoaded suite passed 7 tests, inventory/ratchet suites passed 30,
and progress/history contracts passed 7. Inventory check/refresh passed at
2,301 candidates (92 allowlisted, 1,561 migrated, 648 pending; 1,029 uniquely
queued, 1,272 outside queues, zero overlaps/unassigned). No production source
or ratchet scope changed in this follow-up; fresh report/enforce checks matched
all three approved ratchet scopes.

Latest Step 3/7/9/10/18 batch (2026-09-25): removed WeightCard's unused input
hint/suffix styles and added rendered popup contrast coverage in all four modes;
then added a four-mode Train split-action-bar contract and exact seven-finding
inventory owner. WeightCard and Train now have no pending style candidates.
Format/analysis passed, the combined Train/WeightCard/inventory/workout/ratchet
suite passed 57 tests, and inventory check reported 278 files / 2,301 candidates
(92 allowlisted, 1,543 migrated, 666 pending; 1,029 uniquely queued, 1,272
outside queues, zero overlaps/unassigned). The three-scope ratchet passed
report/enforce and `git diff --check` passed. The preceding responsive
action-bar batch separately passed 118 tests. Neo Current Metrics and
MealPlanAddBar still need user visual acceptance; broader style queues remain
open.

Neo N1/N2 are complete, N3 implementation and automatable coverage are
complete, and original N4 development checks were accepted. The current
21-item Neo visual review is user-accepted as good for now, including the
specialized Profile/settings routes. The route ledger is closed, and the user
has now accepted the current N5 route-state and N6 human/device qualification.
The latest supplied corrected-scope run reported 135 files formatted with 0
changes, clean analysis, 321 theme tests, 6 responsive tests, 46 route-boundary
tests, and a passing enforce-mode style ratchet. This is current development
qualification, not broad/open release approval. The signed Android internal/closed
candidate was subsequently accepted on 2026-09-23 after six focused device checks;
its tested source and APK hash are linked in the
[current roadmap](theme-consolidated-roadmap.md#step-15-qualify-themes-for-release).
This does not approve open testing or a Play Store release.

Earlier working-tree snapshot (2026-09-23, before final verification): the TonosSurfaceTheme routes were
formatted (two files changed), analysis was clean, and the first focused batch
passed 46 tests. The refreshed inventory covers 277 Dart files / 2,293
candidates (59 allowlisted, 1,212 migrated, 1,011 pending, 11 review); the
supplied grouping reports 20 pending in FlowMethodsPage, 18 in
WorkoutProgressFlowsPage, and 12 migrated in tonos_surface.dart. A later
focused suite passed 44 tests and failed only the production ratchet contract,
which found three unapproved fingerprints in tonos_surface.dart. Those exact
statements were subsequently mapped and narrowly approved; the current
report/enforce rerun passed. At that checkpoint, the affected Neo visual
recheck remained open.
Earlier TonosField and ratchet passes remain valid for their tested source
states only.

Prior user-run follow-up (2026-09-24): after correcting the scope test's
TextTheme baseline and preserving inherited ListTile/Icon styling, formatting
reported no changes, analysis was clean, and the five-file Flutter suite passed
all 26 tests. Ratchet report/enforce passed for the two protected files. The user
accepted the current Flow Methods and Workout Progress Flows appearance,
including the dropdown contrast correction, the Exercise Progress chart, and
the Preset Generation QA / Food Customization ExpansionTiles. The darker
Neo-dark settings validation-error style passed its focused 32-test run and
device review. Nested flow-state review remains explicitly deferred.
Inventory follow-up checkpoint (2026-09-24, before the SettingsAccent rule and
ExpansionTile manifest enrollment): check/report passed for 278 Dart files /
2,293 candidates (70 allowlisted, 1,224 migrated, 999 pending, zero
review/unassigned). All 11 identity-color findings were allowlisted. The scan
included the SettingsExpansionSection divider-scope change and no longer
included its former pending divider finding. The corrected contract/drawers/
settings run passed all 37 tests; formatting reported no changes and analysis
found no issues. The SettingsExpansionSection integration assertion passed in
that run. At this checkpoint, the ratchet protected two files. The current
manifest has a third ExpansionTile scope, and the SettingsAccent classification
has since changed the inventory rules; current inventory and three-scope
report/enforce verification passed on 2026-09-24; see the consolidated roadmap for current counts and remaining analyzer follow-up.

Focused inventory/theme follow-up (2026-09-23): the shared settings form's Neo
error message and borders first moved to `ColorScheme.error`; its focused
28-test run passed. Review then found that dark Neo's luminous error role was
not readable on the bright field, so the current patch resolves a contrast-
checked negative role against the field and its containing section. The
estimated-1RM chart series first moved to an explicit progress role; its
47-test analysis/behavior
batch passed, and a Pixel 7 screenshot shows the
marker and legend in Neo dark. Cross-mode visual approval for that color remains
separate. In workout details, rep-best and volume-best badges now use a
shrink-wrapped stack instead of the overflow-prone fixed-height box. The user
reports formatting changed 2 of 3 files, clean analysis, 16 passing tests, and
a refreshed report-only scan of 277 Dart files / 2,320 findings (1,039 pending;
zero unassigned). The device screenshot confirms the badges stay inside their
cards with no overflow. These focused changes do not classify whole files as
migrated or add ratchet scopes.

Local-theme boundary audit (2026-09-23): SettingsInfoCard no longer wraps
its explicitly colored, closed subtree in a local Theme; a cross-family,
cross-brightness regression test is added. The section and expansion scopes in
the same file remain because they own inherited roles for caller-provided
controls. Static inspection likewise retained local scopes around Material
controls, editable fields, selectors, progress indicators, and open child
content in health trends, workout history, workout cards, seven-day focus,
exercise progress, and settings flow cards. No token manifest classification
or ratchet scope changed. The user-run formatter changed one of two files,
analysis was clean, the two focused suites passed all 57 tests, and the
report-only inventory returned 2,319 findings / 1,038 pending / zero
unassigned.

Follow-up primitive review found the first-record and weighted-record badge
widgets duplicated their fill/border contrast, shape, and text-density
renderer while differing in semantic token values and compact spacing. They
now delegate that rendering to one private visual owner without changing those
inputs. The 2026-09-23 user run passed the focused seven-suite batch (37 tests),
refreshed the report-only inventory to 2,312 findings / 1,031 pending / zero
unassigned, and passed ratchet report and enforce modes. The user screenshot
confirms the workout-detail badges no longer overflow. The analyzer reported
three interpolation-style infos in the new chart test key; the key was
converted to interpolation, then passed formatting, clean focused analysis, and
all four responsive chart tests. The user confirmed the Measurement Trends
graphs pass in all four Classic/Neo light/dark modes on 2026-09-23. No inventory
classification or ratchet scope changed.

Step 7 token follow-up: WorkoutMetricChartCard previously used hard-coded
Material green/red for Neo direction labels despite brightness-aware
workoutIncrease/workoutDecrease roles already existing in AppProgressColors.
It now uses those roles for Classic and Neo. The rendered regression test checks
up/down labels and role colors in all four theme modes; the 2026-09-23 focused
batch passed all 37 tests, and the follow-up interpolation cleanup passed clean
analysis and all four responsive tests. The user confirmed that the Measurement
Trends graphs pass in all four Classic/Neo light/dark modes on 2026-09-23.

Step 18 candidate review: `lib/widgets/workout_record_badges.dart` has six
pending inventory findings. A rendered regression covers first-record and
weighted-record badge fill, border, shape, compact/regular padding, and Classic
versus Neo density in all four theme modes. The first run sampled a
theme-transition frame; setting its `themeAnimationDuration` to zero made the
matrix deterministic. The expanded test also checks monthly and all-time
legend dots. The user-run formatter, analyzer, and focused test passed on
2026-09-23, and the user confirmed the workout-detail badges do not overflow.
After manual source review, the 13 exact report fingerprints were added to the
canonical ratchet manifest as count-1 approvals. The user-run post-enrollment
report and enforce checks passed with two protected files, and the focused
ratchet and badge tests passed all 15 tests. The user then ran analysis on
the formatted CLI test and reported no issues. This continuation assigns the
six badge findings to the exact migrated component rule based on token
ownership, the rendered four-mode contract, user-reviewed layout, and existing
ratchet. The interim inventory check/report passed with 278 files and 2,288
candidates; after correcting the test baseline, the initial contract/widget
suite passed all 25 tests. The later September 24 2,294-candidate inventory and
follow-up 26-test suite superseded those interim results; the 2,293-candidate
report was the current checkpoint at that time. The current 2,297-candidate
report is recorded in `theme-style-inventory.md`. Broader file styling debt
remains open. The current
continuation also replaces five repeated ExpansionTile Theme scopes in Preset
Generation QA and Food Customization with the standard/compact/dense
`TonosExpansionTileScope`.
The helper preserves the prior divider, density, and icon-size values; its
four-mode tests and refreshed inventory scan passed. The user accepted the
Preset Generation QA and Food Customization ExpansionTiles on 2026-09-24; the
separate Flow Methods and Workout Progress Flows appearance was accepted that
day as well.

Latest settings primitive follow-up (2026-09-23): the user converted 12
flow-editor fields and one database JSON-import field to TonosField while
preserving controllers, numeric input, and the import field's explicit
outline. The user-run formatter changed 2 of 7 files, analysis was clean, and
the focused field/settings/route batch passed 13 tests. The refreshed
pre-extraction report covered 277 files / 2,294 candidates (59 allowlisted,
1,211 migrated, 1,013 pending, 11 review, zero unassigned); its six queues
assigned 731 candidates (690 pending, 18 migrated, 23 allowlisted). It showed
21 pending findings in flow_methods_page.dart and none in app_settings_page.dart.

Subsequent current-tree edits added TonosSurfaceTheme to the already-protected
tonos_surface.dart and replaced the local foreground Theme wrappers in
FlowMethodsPage and WorkoutProgressFlowsPage. Those edits are not covered by
the earlier field-batch run. The subsequent inventory check/report and
two-file ratchet report/enforce passed; after correcting the test baseline, the
initial five-file focused suite passed 25 tests. The follow-up preserving
inherited ListTile/Icon styling passed formatting, analysis, and all 26 tests
on 2026-09-24. The user accepted the current Flow Methods and
Workout Progress Flows appearance on 2026-09-24, including the dropdown contrast
correction, and accepted the Exercise Progress chart and the Preset Generation
QA / Food Customization ExpansionTiles. The darker Neo-dark settings
validation-error change passed formatting, analysis, and 32 focused tests; its
device appearance was accepted by the user on 2026-09-24, and nested flow-state
review is deferred.
These results do not broaden ratchet enrollment.

Step 14 implementation (2026-09-16): UI Appearance now contains a localized
capability-filtered family selector with compact active-brightness previews,
backed by `ThemeProvider.setFamily` and `TonosChoiceDialog`. Focused coverage
exercises eligible selection, independent brightness, preview presence,
failed-save retry, Classic-only hiding, restart, downgrade fallback, and bundled
locale copy. The user-run selector, full-theme, responsive, and ratchet checks
are recorded above. At this 2026-09-16 checkpoint Neo remained unavailable in
release builds; the subsequently accepted Step 15 opt-in enables Neo only for
Android internal/closed testing.

Automatable completion pass (2026-09-15): the Neo pilot gallery now covers the
second workout fixture, selected navigation, dialog cancellation, live reduced
motion, a large-text stacked WeightCard set editor, and narrow/2.0x mounting.
The theme-ready Classic fallback and Neo surface ownership have a focused test,
and pre_q2 route evidence records the secondary consumer boundaries.
scripts/verify_neo_refinement.ps1 is the user-run entry point for this expanded
scope. Visual/device/accessibility review remains separately recorded; the
current development qualification is accepted and later changes require
focused rechecks.

Current qualification confirmation (2026-09-17): the user confirmed that every
item in the consolidated human/device/N6 checklist passed for the current
working tree. This closes the current development route-state, accessibility,
device, persistence, switching/effects, scanner/media, and affected Classic-
parity checks, and supplies the human/device input for E2.4. It does not enroll
new style-ratchet files, resolve retained placeholder product decisions, or
authorize open/Play release. The internal Step 15 Android
candidate was accepted later on 2026-09-23; its source/hash association is
recorded in the current roadmap.

Automatable non-human follow-up (2026-09-17): the verifier now analyzes the
remaining catalog/media, history, measurements, scanner, nutrition, and
settings route owners. It runs the existing provider, screen, widget,
localization, media, scanner, health, and safe-error evidence outside the broad
theme suite, and the nutrition presentation suite now includes a Neo light/dark
320x640 at 2x text food-editor smoke test. This automated evidence does not
replace visual, keyboard, TalkBack, camera, or physical-device evidence.

The first expanded rerun reached the new smoke test and found a 129 px right
RenderFlex overflow in both Neo brightness modes. The food editor action bar
now wraps its extended buttons on narrow layouts. The focused checks and an
earlier expanded user rerun passed afterward: the full theme suite passed 302 tests,
the responsive run passed 6 tests, the route-boundary batch passed, and the
enforce-mode ratchet passed.

12A/N5 visual-review closure (2026-09-16): the consolidated roadmap records
the accepted 21-item Neo visual review and its Profile/settings route ledger.
The reachable Language and Workout Exit preference dialogs pass through
`TonosDialogFrame`; Classic keeps its prior result and appearance because the
frame is inert outside the outlined Neo surface recipe. Database, Flow Methods,
and Exercise Editor dialog entry points use the same boundary. The final
bright-field dropdown correction is user-verified with formatting, clean
analysis, and 63 focused tests. The remaining settings work is non-happy-path,
reachability, accessibility, and device evidence, not another ordinary visual
route review.

Automatable E2.3 follow-up (2026-09-16): GoalManualEntryPage now preserves the
form and presents localized safe guidance when NutritionProfile.setGoals fails,
while successful saves retain the existing return behavior. The focused
`test/theme/nutrition_goals_behavior_test.dart` covers both paths. StretchCard
add/remove, Train2 drawer/profile, and Food Logging action controls use
existing localized tooltip labels where the action is unambiguous. This
narrows known behavior/accessibility gaps; the current user confirmation records
the E2.3 and N6 route/device qualification. Recheck these paths if the affected
implementation changes.

Theme-ready secondary-surface extension (2026-09-15): evolving non-default
exercise-definition, history, cardio, stretch, measurement, trend, food
customization, and food-logging consumers now have a shared compatibility
boundary. `TonosThemeReadyCard` keeps the original Classic `Card` path and
uses a semantic Neo `TonosSurface` path; focused Neo accents use existing
semantic or data-visualization roles. This remains an interim presentation
boundary, not a final route-specific Neo design decision. The user supplied
clean post-fix analysis for `current_metrics_section.dart` and 32 focused
tests passed; current route and device qualification is recorded above.

## First Alternate Family

Step 13 now targets Neo-Brutalism first. Follow the detailed
[N1-N6 implementation plan](theme-neo-brutalism-plan.md). The agreed Q3 gate
permits development. N2 shared capabilities are complete and automated-
verified; the N3 family/recipe implementation has passed scoped automated
verification and its Theme Lab smoke review is accepted. The current reviewed
pilot and screen refinements are accepted for now. The full rendered,
accessibility, and device qualification matrix is user-accepted for the current
development scope. Visual recipes remain starting recipes for any unreviewed
route.
Expressive is a later candidate.

N1 is complete: the user approved the revision 5 HTML proposal board after
visual revisions. N2 is now complete and automated-verified
batch. The plan records
the four pilot owners, confirmed shared-component gaps, locked starting recipe,
font decision, eight pilot view proposals and the bounded N2 input list. N2 is
the first runtime batch; N1 did not register or expose Neo-Brutalism.

## N2 Implementation Record (2026-09-11)

N2 added reusable, Classic-compatible shared capabilities without registering
Neo-Brutalism or changing feature behavior. `AppSurfaceDecorationTokens` now
owns typed outline/depth policies for Tonos surfaces and sheets; Classic keeps
input-only outlines, compact-card explicit shadows, card/sheet effect-token
depth, and the previous flat roles. `TonosSurface` and `TonosSheet` retain
Material, InkWell, clipping, semantics, callbacks and close behavior, while
effects-off removes visible explicit shadows and leaves outlines intact.

`AppSettingsPresentationTokens` now owns settings hero gradient/solid choice,
hero hard-depth policy, category-control primary inheritance, repeated border
alpha values, icon fills and save-bar border alpha. Classic values match the
prior implementation, and settings borders use the existing outline-width
shape role. Focused tests cover registration, fallback, copy/lerp, rendered
injected borders/shadows, override precedence, effects-off behavior and
settings category inheritance.

Status: complete and automated-verified. N3's family, factory, Theme Lab
preview and recipes are scoped-verified; N3's rendered preview review remains
pending. N4 owns route adoption and device pilot review.

The first user-run N2 verification on 2026-09-11 found two compile-time
`num`-to-`double` elevation errors, one unused test import and one generic
extension-list construction error. Those source and test issues were fixed.
The final user-run verification then reported clean analysis, 218 passing tests,
clean diff-check apart from existing line-ending warnings, and matching ratchet
report and enforcement output. The protected manifest now records the reviewed
current fingerprints. N2 is complete; Neo visual approval and device
qualification remain N3/N4 work.

User verification commands for this batch:

```powershell
Set-Location E:\projects\env_test
dart format lib\theme\tokens\app_surface_decoration_tokens.dart lib\theme\tokens\app_settings_presentation_tokens.dart lib\theme\theme_extensions.dart lib\theme\classic_theme.dart lib\theme\widgets\tonos_surface.dart lib\theme\widgets\tonos_sheet.dart lib\widgets\settings_tiles.dart test\theme\app_surface_decoration_tokens_test.dart test\theme\app_theme_tokens_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\widgets\settings_tiles_test.dart
dart analyze lib\main.dart lib\theme lib\widgets\settings_tiles.dart test\theme\app_surface_decoration_tokens_test.dart test\theme\app_theme_tokens_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\widgets\settings_tiles_test.dart
flutter test test\theme\app_surface_decoration_tokens_test.dart test\theme\app_theme_tokens_test.dart test\theme\widgets\tonos_surface_test.dart test\theme\widgets\tonos_sheet_test.dart test\theme\widgets\settings_tiles_test.dart test\theme test\providers\app_configuration_test.dart
git diff --check
dart run tools\theme_style_ratchet.dart docs\theme-style-ratchet.json --report
```

The formatter may report unchanged files; that is expected. Analyzer/test
success plus matching ratchet report and enforcement output is the completed
automated N2 gate. For future edits to the protected
`lib/theme/widgets/tonos_surface.dart`, run the report and review it before
changing the manifest; do not auto-approve a new fingerprint or count.

## N3 Implementation Record (2026-09-11)

Current review status: corrective contrast, disabled-action and test changes
passed 230 user-run theme/provider tests. The paste reports no analyzer issues
but omits the analyzer command. The 228-test result below is historical. The
four development-only pilot compositions are now implemented, and the focused
pilot test plus the combined theme/provider run have since passed 9 and 233
tests respectively. N3 remains scoped-verified, not manually accepted or
release-qualified.

Execution contract: [N3-R1 through N3-R8](theme-neo-brutalism-plan.md#n3-implementation-specification-and-evidence)
defines fixture architecture, exact approved color/foreground pairs, per-role
borders and shadow offsets, all four compositions, interaction requirements,
shared ownership and evidence gates. The implementation now supplies those
previews; pass the new automated gate before requesting the eight light/dark
pilot captures. Real-route persistence remains N4 work.

N3 registered the development-only Neo-Brutalism family, added cached light and
dark factory definitions, supplied the complete Material and app-extension
recipe, and exposed the family in Theme Lab without changing stored user
preferences or release availability. Theme Lab effects-off handling removes
the Neo tooltip shadow while retaining its border and surface styling.

Status: scoped-verified from user-run output; Theme Lab smoke review accepted.
Formatting made no changes,
analysis reported no issues, the requested theme/provider suite passed all 228
tests, and `git diff --check` reported only existing LF/CRLF conversion
warnings. The first test attempt exposed and then led to fixes for an
unsupported Finder guard and unsettled/incorrectly scoped Theme Lab assertions.

The user then manually smoke-tested Theme Lab on-device: Neo was selectable,
light and dark previews rendered, effects could be enabled and disabled, and
the Tonos surface gallery remained readable in all four shown
brightness/effects combinations. The newly implemented N3 pilot gallery's
focused user-run automated verification now passes; manual rendered review of
the eight documented pilot states in light and dark modes, including
effects-off and reduced-motion states, remains open. This record does not approve a public
selector, route migration, or release enrollment; those remain later N4 and
release-qualification decisions.

## N4 Implementation Record (2026-09-11)

The code portion of N4 and its real-route functional acceptance are complete
for the current development scope. A debug-only DebugThemeFamilyControl now sits
beside the existing debug light/dark switch when
kDebugMode && TONOS_THEME_SWITCH is enabled. It uses the provider's
capability-filtered family list and cycles through it with a direct button,
then awaits ThemeProvider.setFamily; it does not create a second preference
mechanism or require a root Overlay. It is hidden when experimental families
are disabled and is absent from release builds.

Focused tests cover the enabled Neo selection, persisted neo_brutalism code,
return to Classic, root-builder placement without an Overlay exception, and
unavailable-family hiding. The user confirmed the real Train, active-workout,
User Information and Weight Units routes, local state preservation, restart
and disabled-family fallback, both brightness modes, and 1.15 and 2.0 text
scales. N4 is functionally accepted for development; it is not release
qualified.

The initial device run exposed an Overlay assertion from the first popup and
tooltip implementation. The control was changed to a direct family-cycle
button, and the user confirmed the corrected debug build works as intended.
The route and state matrix is now recorded as passed. The user noted that the
rendered Neo-Brutalism appearance differs from the original proposal, so exact
visual parity remains a design follow-up and is not silently marked complete.

The 2026-09-11 proposal-realignment checkpoint begins that follow-up at the
shared recipe and visible route-owner layers. Neo now keeps saturated role
colors in dark mode, uses black ink on colored surfaces, separates cyan plan
fills from preserved identity rails, and applies proposal-style hard outlines
and zero-blur offset shadows to Train, weekly overview, active plans, workout
completion rows, settings sections, and Weight Units choices. The weekly
heatmap, plan thumbnails, exercise thumbnails, navigation semantics, state
persistence, and Classic theme remain unchanged in ownership. This checkpoint
also gives Optimize its purple secondary-action surface, gives the selected
bottom tab a purple cue, keeps the overview heatmap/progress ink readable on
yellow, and moves the debug-only controls into the status-bar area so they do
not cover the selector. GenericBar uses a uniform rounded outline with an
interior identity rail, avoiding Flutter runtime border assertions. This
checkpoint now also separates dark-canvas warm-paper text from near-black
structural edge ink: colored-panel outlines, dividers and selector rails use
`#161616`, while dark-mode hard shadows remain `#000000`. Neutral controls,
sheet handles and data indicators retain contrasting colors. The 2026-09-12
follow-up is covered by the expanded 2026-09-17 user-run analysis and tests.
The current 21-item Neo visual review and N5/N6 development qualification are
accepted; Step 15 release qualification remains a separate gate.

## Current Pre-Q2 Status

[Pre-Q2 Closeout Ledger](theme-pre-q2-closeout.md) is the current status summary.
It supersedes older pending-test labels in the historical implementation records
below. The latest supplied corrected-scope run (2026-09-22) formatted 135
files with 0 changes and passed clean analysis, 321 theme/configuration tests,
6 responsive tests, 46 route-boundary tests, and the enforce-mode ratchet.
The user has accepted the
current device, manual, visual-parity, accessibility, and route qualification;
broader production enrollment and Step 15 release qualification remain
separate.

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
The 2026-09-17 pre-Q2 closeout run passed clean analysis, 315
theme/configuration tests, 6 responsive tests, 46 route-boundary tests, and
the enforce-mode ratchet. The corrected-scope run on 2026-09-22 passed the
updated verifier batch.
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
- C2 is automated-verified in the expanded 2026-09-17 user run. It migrates
  the exercise-detail sheet's form-guide, metrics, records, chart, selector,
  and sheet-shell
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

The profile/plan identity palette disposition is recorded: preserve the current
stable mapping across Classic/Neo and light/dark. Identity colors are not
success/error states and are owned by the dedicated data-color allowlist; do not
move them into theme-primary roles. Any future selectable identity palette must
use a stable palette identifier and curated, contrast-qualified swatches.
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

C2 implementation record (2026-09-08; automated-verified in the expanded
2026-09-17 user run): the
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
paths. The expanded user run passed; device review and full-repository
qualification remain pending.

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

Status: automated-verified in the expanded 2026-09-17 user run. User authorized
C3 before the B1-C2 review fixes were verified; the combined automated scope is
now recorded, while device qualification remains separate.

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
and are unchanged. Added media token and missing-file widget checks. The
expanded user-run tests passed; real-image device inspection, pan/zoom/dismissal
checks and rendered effects-disabled overlay evidence remain pending, so C3 is
not device-qualified.

Target: exercise_detail_sheet.dart zoom/modal paths, thumbnail consumers and
body_heatmap.dart only where those paths depend on it. Inspect black scrims,
white zoom controls, black87 barriers, shadow alpha 0.30 and frame clipping.
Decide whether each is a media-viewing constant or family presentation. Preserve
pan/zoom, dismissal, background contrast, fallback images and overlay semantics.
Exit: image and missing-image states plus an effects-disabled path are covered;
fixed media treatment has a narrow exception. No blanket file exemption.

### D1. Dashboard And Logbook Structure

Status: automated-verified in the expanded 2026-09-17 user run. The implementation is limited to
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

D1 implementation record (2026-09-08; automated-verified in the expanded
2026-09-17 user run):
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
override, and interpolation coverage. The expanded user-run formatting,
analysis, tests, and diff-check passed; device review and full-repository
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

Status: automated-verified in the expanded 2026-09-17 user run. The implementation is limited to
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

D3 implementation record (2026-09-08; automated-verified in the expanded
2026-09-17 user run):
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
that evidence limitation. The pending label below is historical for this batch.
The 2026-09-17 Q3 confirmation and accepted 21-item visual review close the
requested current development checks, including Guided Tutorials, TalkBack, and
motion/effects. These are user-reported results, not new Codex-run tests or
wider release qualification.

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

Historical requalification checklist: matched light/dark Classic captures;
TalkBack focus order and announcements; system-back behavior; long text/RTL at
1.0, 1.3, 1.6 and 2.0 scales; keyboard/rotation during target measurement; live
theme switch while a tutorial is open. These cases are not current development
blockers after the accepted Q3 confirmation. The exact result for each subcase
was not recorded individually, so rerun affected cases if the code changes or a
future release scope requires more granular evidence. Existing locale-specific
tutorial reflow is not redesigned here; broader responsive remediation remains
part of Q2.

Run formatting and analysis for `lib/theme`, all three consumers below, and
the two changed test files; run the theme suite, onboarding flow suite,
responsive accessibility suite, tutorial state-store suite, and app configuration
suite. Until the user returns clean output, this is implementation evidence only.

Targets: lib/screens/onboarding_flow.dart, lib/widgets/guided_tutorial_overlay.dart,
onboarding_plan_builder_coach.dart and tutorial entry points in Train/Session.
Classify spotlight, scrim, focus, dismissal and readiness timing. Route visual
motion/effects through appropriate roles while retaining the tutorial progression
and stored completion state. Current development-scope exit criteria are
accepted; requalify affected accessibility/effects behavior after later changes.

### E2. Remaining Reachable Features And Settings Residue

Status: E2.1 route/residue ledger is complete as of 2026-09-16. The initial
migration passed 181 user-run scoped tests, and the current 21-item Neo visual
review is accepted. E2.2 nutrition slices, E2.3 settings residue, N6 device
evidence, and E2.4 closeout are user-accepted for the current development
scope. Follow the detailed [E2 execution
guide](theme-e2-qualification-guide.md#e2-remaining-reachable-features). Each
remaining slice requires independent evidence; do not combine the entire
nutrition/settings tree into an unverified replacement pass.

The canonical route inventory is guarded by
test/theme/e2_route_ledger_contract_test.dart. This protects inventory
integrity only and does not close the independent route-state, visual,
accessibility, device, or release gates.

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
Exit: the current route inventory is complete and every discovered route is
qualified, experimental, placeholder, source-ready, or unreferenced with a
narrow reason. Focused E2.2/E2.3 implementation and source contracts have
since been added, and the user has confirmed the current development route,
N6, and E2.4 qualification. Step 15 release approval remains separate.

#### Theme-Ready Compatibility Extension (2026-09-15)

Status: implemented as a bounded compatibility step; targeted post-fix
verification is clean and current route/device qualification is user-accepted.
Final route-specific Neo recipes remain a separate design/implementation
decision for evolving product surfaces.

The extension covers:

- exercise definition headers and metadata, exercise-definition info tiles, and
  full exercise-history cards;
- cardio timer cards and stretch add-action cards;
- current measurement metric colors;
- nutrition bar foregrounds, generic trend placeholders/series, food
  customization cards, and food-logging cards;
- the shared `TonosThemeReadyCard` boundary that preserves Classic `Card`
  behavior and resolves Neo `TonosSurface` presentation.

No navigation, persistence, query, unit, repository, or product-flow behavior
changed. Do not mark these routes fully Neo-complete from wrapper adoption
alone; final route-specific recipes belong after the evolving product areas
stabilize.

## Qualification Batches

### Q1. Inventory Ratchet (Steps 3 And 18.1)

Status: Q1 established and verified the first exact qualified production scope.
The later Step 18 badge enrollment passed report and enforcement checks on
2026-09-23, bringing the then-current manifest to two protected files. The
ExpansionTile scope was enrolled afterward as the third; its current
report/enforce rerun passed on 2026-09-24. Broader enrollment remains pending. Follow
[Q1 implementation details](theme-e2-qualification-guide.md#q1-inventory-enforcement)
and [the ratchet usage contract](theme-style-ratchet.md).
The existing inventory validator remains report-only and continues to detect
unassigned candidates. The separate ratchet now validates exact approved scopes;
its fixture and deliberate-failure behavior passed in the latest user run,
which also passed 302 theme tests and 6 responsive tests.
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

Status: scoped-verified for the prior and expanded non-human scope. The
corrected-scope user-reported run (2026-09-22) formatted 135 files with 0
changes, passed clean analysis, 321 theme tests, 6 responsive tests, 46
route-boundary tests, and the enforce-mode ratchet. The user has separately
accepted the current manual/device qualification; later changes require
focused rechecks.
Follow [Q2 runtime and evidence details](theme-e2-qualification-guide.md#q2-runtime-and-accessibility-qualification).

Completed in this pass:

- Added a complete-extension replacement matrix covering each registered
  extension, including media, progress and tutorial extensions, while preserving
  all other extensions.
- Added a reduced-motion resolver and applied it to the remaining visual
  durations, including chart page navigation with a zero-duration jump path.
- Added tutorial reflow coverage for English at text scales 1.0, 1.3, 1.6 and
  2.0 on a narrow viewport, and removed the locale-only large-text assumption.
- Moved the tutorial focus-glow recipe, progress-remove-badge shadow and
  swap-sheet geometry/elevation into theme-owned roles; effects-off now omits
  optional shadows rather than merely drawing transparent shadows.
- Added Theme Lab assertions for every motion role and the newly covered
  effects-off roles.

The following qualification checklist is satisfied for the current development
scope and is retained for future changes:

- Automated rerun complete: 213 scoped tests passed. Revalidate after relevant edits.
- Matched Classic light/dark captures against the approved baseline.
- User-confirmed TalkBack traversal and announcements, keyboard focus and
  selection, screen-reader dismissal, constrained-height/keyboard layouts, and
  physical-device motion/scroll performance.
- User-confirmed physical camera/permission checks for scanner-owned platform
  behavior where applicable.

Include newly added media/progress/tutorial extensions, in-place state
preservation, all visual durations/effects, and the documented manual checks.

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

Status: complete for agreed scope (2026-09-11); clean analysis, 226 passing
tests and manual-plan phone confirmation recorded. The current
[Q3 readiness gate](theme-q3-readiness-gate.md) reconciles the dirty working
tree, prerequisite evidence, and exact blockers. The Q2 corrective patch passed
the user's 213-test rerun and clean analysis. Subsequent device results and
accepted limitations and passing final verification are recorded in the gate.
Its commands are retained for future relevant changes. Record a specific blocker or
approved exception for every unresolved item; neither documentation completion
nor a test count grants Step 13 readiness.

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
