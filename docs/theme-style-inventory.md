# Theme Style Inventory

Opt-in enforcement infrastructure is documented in [Theme Style Ratchet](theme-style-ratchet.md).
Latest verified inventory state (2026-09-26): Food Customization's six form
fields and Food Logging's six text-input call sites now use shared Tonos field
primitives while retaining native form validation, save, callbacks, and
decoration behavior. The 2026-09-26 repository-wide analyzer and full 797-test
Flutter suite passed. The Train-tab classification follow-up changed only the
inventory and its count-pinned contract; its focused widget/inventory tests,
inventory `--check`, and all three approved ratchet scopes passed afterward.
The latest scan reports 278 Dart files / 2,286 candidates: 92 allowlisted,
1,568 migrated, and 626 pending. Queue coverage is 1,013 uniquely assigned, 1,273 outside queues,
zero overlaps, and zero pending without a review queue. Six Food Customization
and six Food Logging decoration findings are no longer pending. No protected
source or ratchet manifest changed. A report-only probe
found 18 TonosDialog fingerprints and did not enroll that file. The exact History Summary
rule owns ten migrated findings. Current Metrics has five fixed category colors
plus one circular series marker under separate, count-pinned data allowlists,
with no pending style candidates in that widget. Its no-measurements message
uses `TonosSurfaceVariant.panelRaised` with four-mode token, Classic-parity,
and full-width assertions; Train's profile avatar uses the semantic contrast
token. The 12 local-theme findings remain migrated. Train now also has an exact
seven-finding four-mode action/avatar owner; both Train and WeightCard have no
pending style candidates.
`weight_card.dart` has an exact kind-limited rule for 23 token-backed color,
transform, decoration, geometry, and shadow findings plus three migrated
text-style findings for the popup label and workout-field hint/suffix roles.
The four-mode rendered tests cover completion surfaces, row shapes and borders,
effects, change-set fields, optional Classic outline, popup contrast, tokenized
hint opacity, suffix foreground, and Classic input-theme inheritance.
`workout_dashboard.dart` and `data_records_section.dart` now have exact,
kind-limited D2 rules for 8 and 4 already token-backed findings, respectively;
inventory contracts pin both counts and their unclassified kinds continue to
fall through to the broad rule. `presets_loaded.dart` has a separate exact
rule for six migrated findings, verified by a four-mode rendered contract for
archived empty-state ink and the progressive Show More action/reveal. These
classifications do not imply broader device or release acceptance. The
The final `TonosSurfaceTheme`/`Builder` foreground-scope and text assertions
are included in the verified source state; no ratchet scope changed.
`meal_plan_add_bar.dart` has zero findings. The exact
`tonos-bottom-navigation` rule covers four migrated candidates; the two
separate `tonos-train-tabs` rules cover its four geometry findings and four
surface/effect/color findings. Their four-mode rendered contract and the user's
Train visual acceptance qualify this exact selector. Navigation support has
19 candidates (5 allowlisted, 12 migrated, 2 pending);
exercise planning has 161 pending. The 12 `local_theme` findings remain
migrated. The user accepted Train and WeightCard visually in Classic and Neo,
light and dark; this closes only those exact scopes, not all styles in those
files: the latest scan leaves no pending candidates in `train_page.dart`,
`tonos_train_tabs.dart`, or `weight_card.dart`. Four-mode visual review of the new MealPlanAddBar
and Neo Current Metrics empty-state appearances remains pending. MealPlanAddBar's
automated tests pass; visual acceptance remains a separate review. The
three-scope ratchet passed report/enforce after the
final source verification on 2026-09-25; no new scope was enrolled.

An accessibility follow-up was subsequently made in
`TonosSegmentedActionBar`: it preserves the compact row when labels fit and
stacks them only when measured text exceeds the segment width or height. Focused
formatting, analysis, 118 focused tests, and inventory refresh passed. Treat
the 2026-09-26 TonosFormField scan above as the current inventory snapshot.

WeightCard follow-up verification (user-run 2026-09-24): formatting completed
for the two focused test files, targeted analysis reported no issues, and the
four-file widget/inventory batch passed all 30 tests. The inventory `--check`
and JSON report also completed with the same 2,295-candidate totals. The first
test run found a stale expectation for the already-migrated Settings child
themes; the contract was corrected and the rerun passed. At that checkpoint,
WeightCard's visual review was still pending; the user accepted it in all four
theme/brightness modes on 2026-09-25.

Local-theme owner reconciliation (refreshed scan 2026-09-25):

| Source scope | Findings | Current status | Owned behavior / next evidence |
| --- | ---: | --- | --- |
| `train_page.dart` | 1 | migrated | Four-mode TrainPage contract covers Overview Active Plans and Plans-tab Active, Archived, and Premade sections; the user accepted Train in Classic/Neo light/dark on 2026-09-25 |
| `settings_tiles.dart` | 2 | migrated | `SettingsSection` and `SettingsExpansionSection` child roles; prior four-mode checks passed; the 2026-09-25 49-test batch passed after isolating ExpansionTile state per theme |
| `seven_day_focus_card.dart` | 1 | migrated | Rendered Weekly Overview progress indicators and inherited foreground/track roles covered in the passing four-mode widget batch |
| `weight_card.dart` | 1 | migrated | Four-mode field-role contract checks input, label, border, hint, suffix, selection, and Classic inheritance; the user accepted WeightCard in Classic/Neo light/dark on 2026-09-25 |
| `theme_lab_page.dart`, `tonos_action_depth.dart`, `tonos_dialog.dart`, `tonos_expansion_tile_scope.dart`, `tonos_surface.dart` | 5 | migrated | Shared theme/primitive scopes |
| `exercise_progress_section.dart` | 2 | migrated | Chart foreground and selector-state scopes |

These scopes are not interchangeable recipes: Train explicitly uses
`onPrimaryContainer` without changing inherited icon roles; `TonosSurfaceTheme`
resolves ink against an explicit surface and also scopes surface/icon roles.
Seven-Day Focus additionally owns progress-indicator colors, Settings preserves
category-control accent policy, and WeightCard owns input/selection behavior.
Keep those differences until a shared API can represent them without changing
their resolved output. The refreshed 2026-09-25 scan confirms 12 migrated and
zero pending `local_theme` candidates. Subsequent exact four-mode contracts
migrated the seven Train action/avatar findings and the WeightCard popup text
style. The input hint/suffix roles, temporarily removed during that pass, are
now restored using the hint-opacity token and workout foreground, with tests
preserving Classic inheritance. Both files have zero pending findings. Retain
their distinct recipes unless a shared API can preserve their resolved behavior.

The exact manifest rules and inventory-contract expectations record both
scopes as migrated based on four-mode regressions and 2026-09-25 user visual
acceptance. The user-run 49-test batch passed, including the inventory contract
and isolated Settings test, and the full inventory report is refreshed above.

Earlier verified inventory checkpoint (2026-09-24; superseded by the latest scan summary above): the settings-tile rule is
kind-limited and classifies the 99 audited shared recipe findings as migrated
while retaining the two caller-descendant local Theme scopes as pending. An
exact rule classifies 29 audited Health Trends findings as migrated, based on
existing token/effect ownership, focused regressions, and the user's accepted
light/dark review. Six new disjoint review queues route the 309 pending findings
that were outside the original queues; the scanner contract reports and
requires zero pending findings without a queue. The user-run inventory
confirmed 1,356 migrated / 853 pending, 1,043 uniquely queued / 1,252 candidates
outside queues, zero pending outside, and zero overlaps.

Responsive correction follow-up (2026-09-24; focused automated checks and
Classic light/dark device review accepted): Classic returns to its 7:3 hero at standard width and
stacks only below the combined content-width threshold. The selector retains
its previous minimum height when content fits and can grow for longer localized
labels. The regression test locks in the Classic row at 393px and 420px, plus
the narrow stack at 320px. Enlarged text is also expected to trigger reflow.
The 12-suite run had 73 passes and exposed a vertical overflow in the 393px
Classic row due to its fixed hero height; inventory check/report passed at 278
Dart files / 2,295 candidates (86 allowlisted, 1,470 migrated, 739 pending;
zero review or unassigned). The follow-up keeps the row side-by-side while
allowing it to grow for wrapped title/stat text. The user then reported no
format changes, clean analysis, and all two tests in the focused responsive
suite passing. The user confirmed that this card looks good in Classic light
and dark on device; broader Android qualification remains open. The flow rules
do not close the separately deferred nested persistence/editing-state review.

The separate ratchet manifest protects three exact production scopes; this is
not repository-wide styling qualification. The inventory remains report-only;
queue coverage is triage metadata and does not change candidate classifications
or the CI check boundary. The `settings-category-accents` rule allowlists only
the 16 literal findings for stable `SettingsAccent` data colors. Transforms,
decorations, geometry, local themes, and text styling are classified separately
from that narrow data-color exception. The working-tree settings-tiles-recipes
rule covers only its audited presentation kinds; the two local_theme findings
are migrated under the exact settings-tiles-local-theme rule, with passing
four-mode descendant-widget contracts. Contract and stable-value tests protect
these scopes. The
Workout Report trend-color contrast passed in the 27-test chart/theme batch.
The analyzer's two unused-import findings were fixed afterward; the user
subsequently ran targeted analysis for the chart widget and responsive test
twice, with no issues in either run. The later four-file health/history analysis
also reported no issues, and the user accepted the rendered Neo light/dark
health and selected-period history appearance on 2026-09-24. The TonosDialog
picker-surface fix and strengthened tests subsequently passed targeted analysis
and the user's 38-test focused run.

Historical user-run inventory/identity-color verification (2026-09-24, before the
current SettingsAccent classification): inventory
`--check` and JSON report passed for 278 Dart files / 2,293 candidates (70
allowlisted, 1,224 migrated, 999 pending, zero review, and zero unassigned).
All 11 fixed profile/plan identity-color findings are now allowlisted. There
are 14 local-theme findings (9 pending, 5 migrated), and all six
workout-record-badge findings resolve to the exact migrated rule. The scan
includes the SettingsExpansionSection divider-scope edit. Formatting reported
no changes and analysis reported no issues for the palette source and focused
contract/widget tests. The initial contract/drawers Flutter run failed on the
obsolete phrase `stable palette identifiers`, which was corrected. Its rerun
passed 36 tests and failed one assertion because it expected `contrast-qualified
swatches`, while the rationale says `contrast-qualified theme-aware swatches`.
The test now checks `contrast-qualified` and `theme-aware swatches` separately,
along with `ThemePaletteId` and `IdentityPaletteId`. The corrected follow-up
passed all 37 tests; formatting reported no changes and analysis found no
issues. The SettingsExpansionSection integration assertion was included in
`settings_tiles_test.dart` and passed. The prior five-file focused suite
passed all 26 tests, including the four-mode inherited ListTile/Icon styling
regression; two-file ratchet report/enforce also passed for its tested source
state.
On 2026-09-24, the user accepted the current Flow Methods and Workout Progress
Flows appearance, the Exercise Progress chart, and the Preset Generation QA /
Food Customization ExpansionTiles. The darker Neo-dark settings validation-error
style passed formatting, clean analysis, and the focused 32-test run; the user
accepted its device appearance on 2026-09-24.
The follow-up review of TonosExpansionTileScope changed compact/dense recipes
to preserve inherited ListTile and icon styling and added regression checks.
The prior focused 26-test suite qualifies those recipe edits; the latest
inventory above supersedes interim 2,288- and 2,296-candidate totals.
A subsequent source edit moved SettingsExpansionSection's transparent divider
into `TonosExpansionTileScope` while retaining the section's color/text Theme.
The latest inventory scan includes this edit and no longer reports the former
pending divider candidate. Its focused integration assertion passed in the
latest user-run settings suite.
The user accepted the matched Classic light/dark comparisons for Weekly
Overview, Train sections/actions, settings, Progress selectors, Workout Report,
workout completion, and record badges, including the agreed 1.15 and 2.0 scale
checks (2026-09-24). No new capture bundle was attached; this is recorded as
user-confirmed visual acceptance.

The 11 review findings in the pre-decision report were fixed profile/plan
identity data shared across theme families, not status colors. On 2026-09-24,
the user accepted retaining the current identity mapping. The machine-readable
rule classifies this dedicated owner as an intentional data-color allowlist;
the latest report confirms all 11 are allowlisted and none remain in review.
Model a
future app-wide color choice as a persisted `ThemePaletteId`, independent from
theme family and brightness, resolving semantic roles through curated
light/dark theme recipes. If identity palettes later become selectable, persist
a separate `IdentityPaletteId` and resolve stable identity slots to curated,
contrast-qualified swatches rather than persisting raw colors or reusing status
roles.

Earlier pre-review audit snapshot (2026-09-23):
the report-only manifest has 26 path rules and six review queues. The refreshed
user-run scan covers 277 Dart files / 2,293
candidates: 59 allowlisted, 1,212 migrated, 1,011 pending, and 11 review. The
supplied focus grouping reports 20 pending findings in
`flow_methods_page.dart`, 18 in `workout_progress_flows_page.dart`, and 12
migrated findings in `tonos_surface.dart`. The 11 review findings remain in
the fixed identity-color palette. The tutorial recipe's kind-limited allowlist
is included in the machine-readable inventory and reflected in the refreshed
allowlisted total.
The surface-aware chart/error resolvers added candidates after that historical
snapshot. The later current-tree totals and verification status are summarized
at the top of this document.

The enforcement manifest protects `lib/theme/widgets/tonos_expansion_tile_scope.dart`,
`lib/theme/widgets/tonos_surface.dart`, and
`lib/widgets/workout_record_badges.dart`. The badge file has 13 reviewed
fingerprints; its earlier report/enforce checks and 15 focused ratchet/badge
tests passed. The ExpansionTile file has three reviewed count-1 fingerprints;
the current focused inventory/ratchet/CLI/settings/ExpansionTile suite passed
52 tests, and the current three-scope report/enforce matched the manifest. For
the current TonosSurfaceTheme edit, formatting changed two files, analysis was
clean, and an initial focused batch passed 46 tests. A later
suite passed 44 tests and failed the exact production-ratchet contract because
three new fingerprints in tonos_surface.dart had no approvals. They were mapped
to exact statements and narrowly approved before the current report/enforce
rerun passed. The user accepted Flow Methods and Workout Progress Flows
appearance, the Exercise Progress chart, and the Preset Generation QA / Food
Customization ExpansionTiles on 2026-09-24. Dark Neo settings-error styling
passed formatting, analysis, and 32 focused tests; the user accepted its device
appearance on 2026-09-24.
Nested flow-state review is deferred.
Further enrollment still requires file-specific ownership,
parity, lexer eligibility, and rendered/state evidence.

Earlier user-run snapshots on 2026-09-23 include 2,319 records (49
allowlisted, 1,211 migrated, 1,038 pending, 21 review), 2,312 records before
the Train helper consolidation and tutorial disposition, 2,310 records after
those updates, and 2,308 records after shared-settings foreground
consolidation. The 2,308 scan recorded 19 local Theme candidates (16 pending,
3 migrated) and 115 pending findings in `settings_tiles.dart`; these are
lexical records, not unique declarations or a signoff. Before the series-token
change, `settings_tiles.dart` had 116 pending records: 35 color transforms,
24 decorations, 20 geometry, 14 text styles, 8 literals detected by each of
two overlapping literal rules, 3 local themes, 2 gradients, 1 color, and 1
shadow.

### Review Queue Coverage (latest report, 2026-09-24)

Matching the six configured review-queue patterns against the latest inventory
report assigns 729 candidate records: 672 pending, 18 migrated, 39 allowlisted,
and zero review. The patterns do not overlap. Queue totals are:

| Queue | Findings | Pending | Other recorded status |
| --- | ---: | ---: | --- |
| Application shell and navigation | 46 | 30 | 16 migrated |
| Shared settings and form controls | 240 | 224 | 16 allowlisted |
| Active workout and completion | 50 | 48 | 2 migrated |
| Catalog and exercise detail | 92 | 79 | 13 allowlisted |
| Dashboard, progress, and health trends | 181 | 181 | none |
| Onboarding and development-only routes | 120 | 110 | 10 allowlisted |

Another 309 pending records fall outside these six queues. They remain assigned
to inventory rules, not unassigned; they still need a feature queue or a
documented deferral before their slices can close. The earlier report's 11
review-status records were in the fixed identity-color palette; the subsequent
user decision and allowlist update are recorded above and confirmed by the
latest inventory report.

The scanner's `reviewQueueCoverage` output reports per-queue candidate/status
counts plus unique, outside-queue, and overlapping candidate totals. These
counts are routing aids, not approvals or migration evidence. The current queue
patterns are disjoint; if a later route intentionally belongs to more than one
queue, record that decision and update the disjointness contract explicitly.

The 2026-09-24 rule-order audit found that the exact exercise-editor hotspot was
shadowed by the broader `profile-settings` rule. The exact-file rule now comes
first, preserving `pending` status while making the intended review destination
observable. A contract test guards both the selected rule and the editor's
actual findings; this is an ownership correction, not a migration claim.

Focused ownership review found that the eight `SettingsAccent` colors preserve
stable account/training/progress/data roles rather than mirror theme primary;
the exact `settings-category-accents` classification now records this as
category identity data without exempting other styles in the file. Its refreshed
inventory report confirms all 16 SettingsAccent findings are allowlisted while other styles in the file remain classified independently.
surface, shape, settings-presentation, semantic-color, and `ColorScheme` recipes
already own much of the remaining styling. Its local `Theme` scopes set
inherited control roles within sections. Neo input validation's three hard-coded
light error colors first moved to `ColorScheme.error`; the focused settings-tile
run passed 28 tests. Review found that luminous dark-Neo error red did not
contrast with the bright input, so the current patch resolves a semantic
negative color against the painted field and containing section, with 4.5:1
regression assertions for both. For the
`AppProgressColors.estimatedOneRm` slice, the user reports formatting
changed 2 of 8 files, analysis was clean, and all 47 targeted tests passed. The
current patch keeps that role as the Classic fallback while resolving both
exercise-history series against Neo's bright chart surface. The supplied Pixel
7 screenshot shows the earlier estimated-1RM marker and legend in Neo dark; it
does not establish cross-mode visual approval for the current correction.
Separately, the user
identified the earlier 26-pixel overflows in workout-detail rows where
rep-best/volume-best labels wrapped inside a fixed-height box. The new
`WorkoutRecordBadgeStack` shrink-wraps those labels. Its follow-up formatter
changed 2 of 3 files, analysis was clean, all 16 focused tests passed, and the
inventory check/report succeeded with 2,320 candidates and zero unassigned.
The new Pixel 7 screenshot confirms the badges remain inside their cards with
no overflow, and the follow-up run reports no `RenderFlex` overflow. These
focused changes do not certify the entire file as migrated. At that
checkpoint, no inventory classification or ratchet approval changed; the
later exact badge-file ratchet enrollment is recorded above.

The supplied file-level focus grouping reports 20 pending findings in
`lib/screens/profile/settings/flow_methods_page.dart`, 18 in
`lib/screens/profile/settings/workout_progress_flows_page.dart`, and 12
migrated findings in `lib/theme/widgets/tonos_surface.dart`. The report is
current for the TonosSurfaceTheme extraction; finding-level ownership decisions
and the broader per-control override audit remain open.

The app-shell finding was also reviewed against `lib/main.dart`: the sole
pending row in the supplied scan is `statusBarColor: Colors.transparent` in
`AnnotatedRegion<SystemUiOverlayStyle>`. The adjacent status-bar icon and
brightness values already follow the active theme. Transparency is an OS
overlay invariant that lets the app surface show through, not a palette role;
replacing it with a surface token could make the system bar opaque. Keep the
path-level rule pending because marking the whole file migrated would also
classify future matching findings without review. No manifest change is
justified until the scanner can represent this as a candidate-specific
exception.

### Local Theme Boundary Audit (2026-09-23)

Source review found one inert local Theme wrapper in SettingsInfoCard
(lib/widgets/settings_tiles.dart): its closed subtree already assigns its
text and icon colors explicitly, and exposes no caller-provided descendants.
The wrapper was removed and a regression test was added to assert the card has
no descendant Theme in Classic/Neo light/dark. The user reported formatting
changed one of two files, analysis found no issues, the settings and Neo
refinement suites passed all 57 tests, and the inventory check returned zero
unassigned candidates.

The adjacent SettingsSection and SettingsExpansionSection scopes remain:
they wrap arbitrary section children, controls, and ExpansionTile. The
reviewed health-trend and history cards wrap inherited Material consumers;
weight cards own text-field decoration/selection; seven-day focus owns
inherited progress-indicator and text roles; exercise-progress and flow scopes
wrap selectors, controls, or caller content. These are deliberate local
ownership boundaries, not redundant palette copies. At that earlier audit
checkpoint, no inventory rule or ratchet scope changed. Follow-up source edits consolidated the duplicate badge
renderer in lib/widgets/workout_record_badges.dart and changed
lib/widgets/workout_metric_chart_card.dart to use the brightness-aware
workoutIncrease/workoutDecrease progress roles rather than hard-coded Neo
colors. Focused tests for both changes were subsequently run by the user and
passed. The 2,310-, 2,312-, and 2,319-finding reports are historical
snapshots. The 2,308-finding report followed shared-settings foreground
consolidation; the 2,294-finding report followed the TonosField adoption
described below and predates the TonosSurfaceTheme and ExpansionTile-scope
edits. The subsequent user-run 2,288-candidate inventory check includes those
edits and passed with no unassigned findings; the 2026-09-24 2,294-candidate
report superseded that interim total at the time. The 2,293-, 2,294-, and
2,297- and 2,295-candidate reports are historical checkpoints; the 2,307-
candidate report was the pre-refactor baseline; the 2,299-candidate refresh is
a historical checkpoint, superseded by the 2,303-candidate report and then the
latest 2,286-candidate scan at the top of this document.

### Local Theme Ownership Audit (earlier 2026-09-24 checkpoint)

The report before ExpansionTile extraction contained 14 pending and 4 migrated
local Theme candidates. At this earlier checkpoint, the user-run report
contained 9 pending and 5 migrated candidates (14 total): the five QA/nutrition
wrappers were removed and the shared helper was assigned to the existing
migrated theme-system rule. The table below is the pre-extraction owner map; its
QA and food-customization rows are historical rather than current pending
findings. That earlier report contained 12 local-theme candidates (7 pending, 5
migrated); the health-trend and workout-history rows below are now historical
wrappers replaced by `TonosSurfaceTheme` consumers.

| Source scope | Count | Owning purpose |
| --- | ---: | --- |
| `preset_generation_qa.dart` | 1 | Hide the ExpansionTile divider in a development-only QA section |
| `train_page.dart` | 1 current (3 before consolidation) | Set inherited text and surface foreground for outlined plan panels; the identical Theme recipe is centralized in one private helper |
| `food_customization_page.dart` | 4 | Hide ExpansionTile dividers and apply compact ListTile/icon density to nested portion editors |
| `exercise_progress_section.dart` | 2 | Adapt panel text/progress roles and selector tile ink for outlined surfaces |
| `health_trends_section.dart` | 1 | Supply inherited foreground roles to widgets inside a health card |
| `settings_tiles.dart` | 2 | Scope section control/accent roles and the expandable section's caller-owned children |
| `seven_day_focus_card.dart` | 1 | Set progress indicator colors on its outlined surface |
| `weight_card.dart` | 1 | Scope the workout card's Material controls and editable fields |
| `workout_history_calendar.dart` | 1 | Set text and scheme foreground roles for content on its resolved card surface |

The source edit replaces the QA divider-only wrapper and four nutrition
ExpansionTile wrappers with `TonosExpansionTileScope`'s standard, compact, and
dense variants. It preserves the original divider, ListTile density, and icon
size values and adds four-mode theme-inheritance tests. The inventory maps the
new helper to the already-migrated `theme-system` rule. The user-run format,
analysis, inventory check/report, and ratchet checks passed. The initial widget
test failures were due to comparing against the raw factory TextTheme; after
changing the test to compare with the resolved parent, the five-file suite
passed 25 tests. A follow-up preserving inherited ListTile and Icon styling
then passed format, analysis, and the five-file suite with 26 tests on
2026-09-24.

The preceding TonosSurfaceTheme edit replaced the two flow-card local Theme
wrappers with that shared surface boundary in `lib/theme/widgets/tonos_surface.dart`.
Its focused tests and analysis passed; the three exact protected-file
fingerprints are reviewed and approved, and report/enforce passed. The user
accepted the current Flow Methods and Workout Progress Flows appearance on
2026-09-24, including the dropdown contrast correction. The Exercise Progress
chart and the Preset Generation QA / Food Customization ExpansionTiles were
also accepted. Nested interaction-state review is explicitly deferred; the
darker Neo settings validation-error change passed format, analysis, and 32
focused tests; its device appearance was accepted by the user on 2026-09-24.
The subsequent health-trend and selected-period workout-history consumer
changes use that shared boundary and are included in the latest inventory.
Four-file formatting changed only `workout_history_calendar.dart`; targeted
analysis was clean and six focused suites passed 23 tests. The user accepted
both surfaces in Neo light and dark on 2026-09-24; no visual check remains for
these unchanged consumers.

The three report candidates in `food_logging_page.dart` are one local
`ButtonStyle`: the Add All to Diary action uses 14-pixel vertical padding and
the nutrition portion shape with a primary-colored outline. Its busy/empty
activation behavior is feature-owned; no existing TonosAction variant
expresses that exact shape and padding. Keep it as a documented local variant
until its rendered states are qualified rather than flattening it into a
different shared button recipe.

### Tutorial Recipe Disposition (2026-09-23)

The old `tutorial-scrim` review status was stale. The user accepted the full
21-item visual review, including Guided Tutorials, and separately reported the
requested accessibility and motion/effects checks passing in the Q3 gate.
Automated tutorial coverage exercises token copying/interpolation, effects-off,
reduced motion, and dismissal behavior. The ten matching lexical findings stay
an `intentional_one_off` allowlist: the overlay uses `AppTutorialTokens` and
semantic `ColorScheme` roles, while a few recipe-specific alpha/border values
remain local. This is not a claim that the entire file was migrated or a blanket
approval for other surfaces. The refreshed 2026-09-23 scan confirms the
allowlisted classification. At the time of this 2026-09-23 entry, the separate
identity-color palette review remained open; its 2026-09-24 disposition is
recorded at the top of this document.

## Next Migration And Enforcement Work

See [E2 And Qualification Execution Guide](theme-e2-qualification-guide.md)
for route disposition, narrow exceptions, stable finding identity, duplicate
handling, scanner fixtures and CI acceptance criteria. The inventory artifact
remains report-only; the separate ratchet manifest is the only enforcement
baseline and does not reclassify the broader debt.
The latest supplied corrected-scope verification (2026-09-22) formatted 135
files with 0 changes and passed clean analysis, 321 theme/configuration tests,
6 responsive tests, 46 route-boundary tests, and enforce-mode ratchet. The
user's 2026-09-17 confirmation accepts current-tree development human/device/N6
qualification; it does not change inventory classification or qualify a public
release. Older pending labels below describe earlier checkpoints and are
superseded for the current working tree by the consolidated roadmap and Q3 gate.

Post-review non-human implementation pass (2026-09-17; verified again by the
2026-09-22 corrected-scope user run): the
route ledger now has exact row/path/caller checks, and dedicated source
contracts cover N5 state owners plus nested settings residue. Focused behavior
and parity tests cover nutrition failure/rollback, stable log-entry ordering,
food-editor validation/layout, health delta contrast, large-text settings
values, Classic/Neo compatibility-boundary ownership, and custom rounded
surface outline/shadow geometry. The existing
report-only inventory remains unchanged, and no additional production file
was enrolled in the ratchet.

The 2026-09-15 theme-ready compatibility extension is recorded separately from
full inventory migration. TonosThemeReadyCard is a migrated theme-system
primitive. Its exercise-definition/history, cardio/stretch, measurement/trend,
and nutrition consumers remain reportable inventory entries, while their current
development route/state/device qualification is accepted. Reportability does
not imply incomplete visual review or whole-file migration; final
product-specific Neo recipes remain a separate design choice. This note does
not change the manifest or enroll those consumers in the ratchet.

The [Q3 readiness gate](theme-q3-readiness-gate.md) is the current
cross-prerequisite record. Current development qualification is accepted.
Wider/open release qualification, optional future native-speaker review,
selected product/design decisions, and evidence for any additional ratchet
enrollment remain distinct work. Inventory classification and ratchet
enrollment do not replace that evidence.

## C3-D3 Review Correction (2026-09-09)

C3-D3 follow-up: user-run analysis was clean and all 168 scoped tests passed.
E1 now assigns onboarding and tutorial geometry, scrims, optional shadows, and
visual durations to AppTutorialTokens. Material colors/text, content identity,
readiness delays and completion state remain with their existing owners. The
inventory remains report-only. The historical note that manual qualification
was pending is superseded by the accepted 21-item review and Q3 accessibility/
motion/effects confirmation recorded later.

Source review found Classic color drift in D2/D3 and lost responsive corner
scaling in exercise progress. The user subsequently reported clean analysis and
168 passing scoped C3-D3 tests; device qualification remains separate.

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

C2-D3 and the B1-C2 review fixes are scoped-verified: the user reported clean
analysis and 168 passing scoped tests for the C3-D3 follow-up. This supersedes
older pending labels below. Device and full-release qualification remain
pending; newer pre-Q2 follow-up changes have separate fresh evidence
requirements.

C3 implementation is scoped-verified: exercise-detail preview/viewer frames
and overlay effects have media-token ownership; fixed image-viewing contrast
has a narrow constant owner. The report-only manifest remains unchanged, and
real-image, interactive viewer and effects-disabled rendering evidence is pending.

B1-C2 review fixes are scoped-verified: exercise-detail handle opacity restored
to 0.55 through a dedicated role; existing flow graph paint refreshes when theme
dependencies change; fallback token creation is lazy. The report-only manifest
is unchanged. Source-adoption assertions are not rendered state/parity evidence.

For executable batch scope and acceptance rules, see
[Theming Batch Playbook](theme-batch-playbook.md). Its B1-B6 queue continues
Step 12B; candidate presence does not itself require a source edit.

Latest scoped user verification: B6 passed with a clean scoped analyzer and
141 focused tests. B1, B2, B3, B4, and B5 are also scoped-verified. C1 is
scoped-verified with clean analysis and 148 focused tests; Step 12B remains in
progress.
C2 is automated-verified in the expanded 2026-09-17 user run for the
exercise-detail form guide, metrics, records, chart, selector, and sheet-shell
recipes. Its zoom, image, scrim, heatmap, and media-overlay decisions remain
assigned to C3, with rendered state and device qualification still pending.
Swap actions, filter, match badge and marker now have shared recipes. B1 is now
scoped-verified for the preset thumbnail frame and swap secondary copy opacity,
with clean analysis and 134 scoped tests. This does not change
the report-only manifest or qualify all expressions in the swap sheet. Older
batch-count paragraphs below are historical evidence.

B2 is scoped-verified for train header and plan-list consumers. Its named
opacity roles and fixed identity-palette ownership do not change the
report-only manifest. That historical verification preceded the 2026-09-24
decision that classifies the identity owner as an intentional data-color
allowlist.

B3 is scoped-verified for premade and automatic-plan presentation. The named
motion and opacity roles preserve Classic's 180ms, 0.55, 0.6, 0.46, 0.05, 0.04,
and 0.16 recipes, while flow category and loopback colors remain flow-token
meaning. The automatic-flow grid now resolves through the existing
data-visualization role in both initialization paths. Optimized-workout settings
and shared flow widgets were reviewed without speculative extraction. This does
not qualify the full plan/workout routes, device rendering, or the inventory
manifest outside the B3-owned scope.

D2 is scoped-verified for progress charts, data records, workout metric charts,
and the workout dashboard. Structural frames and tooltip
geometry now have focused surface/shape ownership, while series, grid, labels,
selection, trend meaning, and record-today meaning remain in data-visualization
roles. The report-only manifest is unchanged. Source contracts cover role
adoption, Classic recipes, state-path evidence, copy, and interpolation. The
user reported clean analysis and 158 passing focused tests; long values,
zero/missing-record rendering, device behavior, and full-release qualification
remain pending.

D3 owns health trend card and measurement detail presentation. Dedicated
`AppProgressColors.healthCard` preserves legacy `theme.cardColor`; the generic
info-card surface is not equivalent. The
health-specific 18px card and 14px entry geometry now have named shape roles.
Measurement grid and direction colors use focused progress recipes; the tertiary
series retains data-visualization ownership and neutral text stays inherited.
Compact/full-page layout, metric identity, units,
entry editing/deletion, refresh/session invalidation, and settings navigation
remain behavior-owned by their existing callers. The report-only manifest is
unchanged. Focused source/token tests are covered by the expanded user run;
rendered empty/populated/edit-state evidence and device qualification remain
pending.

The structural-style inventory is the mechanical starting point for Step 3 of
the theme plan. It detects style-bearing Dart expressions, records their
source file and line, and assigns each candidate to an explicit path rule in
[`theme-style-inventory.json`](theme-style-inventory.json).

## Run It

From the repository root:

```powershell
dart run tools\theme_style_inventory.dart --check
dart run tools\theme_style_inventory.dart --format json --output build\theme-style-inventory.json
```

The first command validates the manifest, scans `lib`, and prints a concise
report. The second writes the complete deterministic finding list. The tool
does not write to `lib` and does not fail because a candidate is still marked
`pending` or `review`.

`--check` fails only when the manifest is malformed, the scan root is missing,
or a candidate has no matching rule. This makes the inventory safe to run in
CI while existing migration work is still in progress.

## Candidate Kinds

The scanner reports direct Material/Dart styling evidence rather than trying
to decide whether every expression is wrong:

- `color`, `color_literal`, and `color_literal_candidate`
- `color_transform`
- `geometry`
- `decoration`
- `gradient`
- `shadow`
- `local_theme`
- `text_style`
- `component_style`

Comments and string literals are masked before matching so documentation and
localized copy do not become style findings. Findings retain the original
source line as a review aid.

## Rule And Exception Policy

Rules are evaluated from top to bottom. More specific paths must appear before
broader `lib/screens/**`, `lib/widgets/**`, and `lib/**` rules. A rule supplies
the classification, status, rationale, and migration target that every
finding must carry.

- `migrated` identifies the theme boundary and shared recipes already owning
  the styling.
- `pending` identifies structural work that still belongs in a future
  vertical-slice migration.
- `allowlisted` is reserved for fixed data visualization, stable entity
  identity colors, or asset/media treatment. It does not exempt the surrounding
  application chrome.
- `review` is reserved for a named one-off with an unresolved accessibility,
  effect-fallback, or product decision. It does not imply file-wide approval.
- `excluded` is limited to generated source.

An allowlist entry must include a non-empty rationale and a destination. Fixed
anatomy, chart, illustration, and identity values remain visible in the report
so their contrast and non-color meaning can be reviewed independently. This
classification records ownership, not a blanket contrast/accessibility signoff.
The manifest is not a subjective approval record: human parity, accessibility,
and product decisions remain in the relevant QA and theme-plan documents.

## Current Boundary

The report makes the following distinctions immediately:

- `lib/theme/**` is the migrated theme-system owner.
- The application shell has started its first vertical slice: global Material
 and bottom-navigation ownership already live in the theme boundary, and
 shared quick actions use a Tonos action-bar recipe.
- Shared drawer navigation, the persistent ongoing-session action, and the
  app-level durability banner now use focused surface, shape, semantic-action,
  and effect-token roles. Fixed profile and plan identity palettes are
  intentional data-color allowlists, independent of theme roles.
- The primary Train page's Overview/Plans control now uses shared pill
 geometry, surface, and inherited typography roles.
- The split Train workout bar now uses shared sheet geometry, elevation, action
  typography, and a semantic start-action role; its Optimize side remains
  ColorScheme-owned.
- Plan-generation accents, completion headlines, session metric accents, saved
  session edit state, and workout record badges now resolve through focused
  semantic/data roles while preserving their Classic colors. Repeated workout
  metric tiles use the shared metric shape.
- The active-workout slice now keeps the session timer and completion values on
  inherited theme typography, uses shared pill/control geometry in the
  completion sheet, and routes saved-session summary/set surfaces through
  focused tokens, including dedicated full and compact record-badge geometry,
  shared premade-plan pill geometry, and repeated automatic-flow control
  surface/geometry roles, separate premade-plan filter, duration, and group
  surface roles, and focused metric-chip/plan-action/optimized-action surfaces.
  Finish/Done controls and the completion handle now have dedicated components.
  Completion and record-badge opacity recipes are token-backed, and saved-session
  summary tiles own an independent surface. Remaining completion-section
  treatments, dialog/elevation details, and other identified high-use screens
  are still pending structural migration targets. The active WeightCard now
  uses focused completion semantic/surface roles, shared set-row geometry, and
  the shared media-thumbnail radius while preserving its Classic behavior.
  The latest 12B batch also covers optimized-workout actions, plan-management surfaces, preset-detail editing, and scaled plan-list controls with focused semantic, surface, and shape roles. The first shared settings
  value/form/save-bar/status-badge recipes are now token-backed. Profile
  identity palettes are allowlisted identity data, and stable SettingsAccent
  category colors now have a separate exact-file, literal-only classification.
  Remaining local control overrides are pending inventory work; neither
  identity nor category colors are application-state colors.
- Premade plan expansion and automatic-flow controls now use named motion,
  surface, flow, shape, and data-visualization roles for their B3-owned
  presentation recipes. Classic light/dark grid parity is covered; the current
  development route/state/device qualification is accepted and recorded in the
  Q3 gate. Broader inventory migration remains partial.
- Anatomy and chart color owners have explicit data-visualization rules where
  the fixed palette is part of the data meaning.
- Exercise thumbnails and shared entity thumbnails have explicit media rules.
- C1 adds focused catalog surface roles for selected rows, usage rows, and
  catalog outlines, while the two media widgets keep separate frame,
  placeholder, and media-outline ownership. Existing media fallback, retry,
  cache, sizing, and caller-supplied geometry behavior remains unchanged.
  Its scoped automated contract is verified; the relevant current development
  visual/device scope was accepted in the 21-item review. Whole-file migration
  and wider-release qualification remain separate.
- The tutorial overlay's accepted, kind-limited recipe is an intentional
  one-off allowlist, not general approval of its surrounding application
  chrome.
- B6 traced the actual release callers for the Train, plan-generation, active
  session, completion, and saved-history surfaces. `Train2Page` is legacy but
  currently release-reachable when its navigation tab is enabled, while Theme
  Lab is protected by explicit debug-only gates. The B6 route contract is
  scoped-verified; this is route evidence, not a claim that the legacy route or
  all reachable consumers are fully migrated.
- D1 now assigns dashboard and logbook structural surfaces, selectors, empty
  calendar days, selected-period summaries, dividers, and geometry to focused
  theme roles. Calendar intensity remains data-driven, ordinary history cards
  remain Material-owned, and the non-default `CombinedHistoryPage` placeholder
  was deliberately not converted into a second history flow. D1 source and
  token contracts are added; current development visual/device qualification is
  tracked in the Q3 gate, while wider-release qualification remains separate.
- The secondary-surface compatibility extension now gives evolving
  non-default exercise-definition, history, cardio, stretch, measurement,
  trend, food-customization, and food-logging consumers an explicit
  Classic-Card/Neo-TonosSurface boundary. Semantic and data-visualization
  roles own the Neo-specific accents. Their structural styles remain pending
  full inventory migration; development visual/device qualification is accepted
  for the agreed scope, and final product-specific Neo recipes remain a
  separate design choice. Wrapper adoption alone is not a migrated inventory
  claim.
- All other screen/widget candidates remain reportable through pending
  release-surface or catch-all rules.

When a vertical slice is migrated, replace its pending rule with the narrowest
appropriate rule or update its ownership classification. Keep the broad
catch-all rules in place so newly added styling cannot disappear from the
inventory.
