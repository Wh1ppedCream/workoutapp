# Consolidated Theming Roadmap

Updated: 2026-09-26.

This is the current status and execution checklist for Tonos theming. Start
here when selecting work or checking completion. Original Steps 1-19 are
retained; Neo batches N1-N6 belong to Step 13. Do not create an independent
numbered backlog for work already represented here.

## Status And Evidence Rules

- Complete means the recorded scope has required evidence or an explicit
  accepted limitation. Later edits can require focused revalidation.
- Manually accepted for the current review scope means the user approved the
  named routes and conditions. It does not silently approve unreviewed states,
  device conditions, accessibility behavior, or release qualification.
- Implemented, verification remaining means code exists; finish the stated
  checks instead of reimplementing an old checklist.
- Partial means adoption, implementation, or coverage remains.
- Not started means the named milestone has no recorded delivery. Related
  debug tooling or earlier development tests do not constitute its delivery.

This record reconciles documentation and user-supplied verification; it is
not a fresh whole-repository source audit or device qualification. The working
tree contains changes beyond theming. HEAD alone does not identify those edits.

Historical acceptance stays valid for its reviewed scope. Subsequent changes
require checks of affected behavior; do not invalidate all earlier acceptance
or silently transfer it to a newer implementation.

## Documentation Ownership

| Document | Purpose |
| --- | --- |
| This roadmap | Current status, detailed tasks, dependencies, completion criteria, latest verification summary |
| [Original design plan](theme-design-plan.md) | Architecture and original requirements; status follows this roadmap |
| [Neo design plan](theme-neo-brutalism-plan.md) | Approved visual recipes and component specifications |
| [Catalog, Logbook, and Progress design](neo-catalog-logbook-progress-design.md) | Detailed visual specification and current-batch implementation notes; roadmap remains the status source |
| [Batch playbook](theme-batch-playbook.md) | Historical migration scopes and verification records |
| [Classic baseline](classic-theme-baseline.md) | Accepted appearance, permitted reflow differences, comparison evidence |
| [Q3 decision](theme-q3-readiness-gate.md) | Historical development approval and its accepted limitations |
| [Correction evidence](neo-correction-pass-evidence-2026-09-13.md) | Current device results, screenshots, and capture metadata |
| Style inventory and ratchet manifests | Machine-readable ownership, exceptions, exact enforced scope |

Keep specifications and raw evidence in those existing documents. Update
statuses here after results are accepted and link the evidence. Historical
issue lists remain review history, not additional active milestone lists.

## Current Status

| Step | Scope | Current assessment |
| --- | --- | --- |
| 1 | Permanent Classic contract | Complete; ongoing compatibility obligation |
| 2 | Visual/behavioral baseline | Agreed matched Classic comparisons and the Exercise Progress responsive correction in light/dark accepted by user on 2026-09-24; no capture bundle attached |
| 3 | Inventory/classification | Verified 2026-09-26 after shared food fields, WeightCard roles, and exact TonosTrainTabs ownership: 278 Dart files / 2,286 candidates (92 allowlisted, 1,568 migrated, 626 pending); 1,013 uniquely queued, 1,273 outside queues, zero overlaps, zero unqueued pending. WeightCard, TrainPage, TonosTrainTabs, WorkoutDashboard, DataRecordsSection, and PresetsLoaded have no pending candidates; broad classification remains partial |
| 4 | Classic extraction | Implemented and accepted for Q3; recheck affected parity after refinements |
| 5 | Selection/preferences | Implemented; original persistence/switching accepted; revalidate relevant changes |
| 6 | Availability policy | Internal Neo opt-in and accepted candidate source `eae77c321a7acd7ec66a77f634eec08d009d727c` linked to the APK hash |
| 7 | Focused tokens | Foundation complete; Current Metrics surface/foreground, Train avatar contrast, and WeightCard opacity/shape roles are covered by four-mode tests and token copy/interpolation contracts. TonosFormField reuses Material's existing input-theme roles without adding speculative tokens. WeightCard defaults preserve the accepted appearance. Neo Current Metrics and MealPlanAddBar visual reviews remain pending |
| 8 | AppColors retirement | Complete |
| 9 | Material ownership | Five repeated ExpansionTile scopes centralized; health/history use TonosSurfaceTheme; TonosDialogFrame owns the opted-in Neo Dark picker surface. Current Metrics delegates its empty state to TonosSurfaceTheme/TonosSurface; the shared action bar owns measured label-fit and reflow. WeightCard's input scope and completion recipe have four-mode contracts. Food Customization and Food Logging form fields now delegate common decoration to shared field owners while retaining form behavior. The broad per-control override audit remains |
| 10 | Tonos primitives | Shared ExpansionTile recipes preserve inherited ListTile/icon fields; health/history use TonosSurfaceTheme; MealPlanAddBar uses TonosSegmentedActionBar; Food Customization and Food Logging now use TonosFormField, with Food Logging search/barcode using TonosField. Responsive reflow stacks only when measured labels exceed compact segment width or height. Current Metrics uses TonosSurfaceVariant.panelRaised and preserves full-width layout; Neo Current Metrics, MealPlanAddBar, Auto Preset add-method dialog, and Nutrition form visual reviews remain pending |
| 11 | Theme Lab | Classic/Neo pilot implementation and automatable coverage complete; current visual review and current development device/stress qualification accepted |
| 12 | Surface migration | Current 21-item Neo visual route review and current route/state/device qualification accepted; route ledger remains the source of truth |
| 13 | Neo-Brutalism | N1/N2 complete, N3 implementation/automatable coverage complete, N4 and the current 21-item visual review accepted; current N5 route-state and N6 development qualification accepted |
| 14 | Public selector | Implemented and accepted; Neo is selectable in the accepted Android internal candidate, with Classic as default |
| 15 | Release qualification | Android internal/closed candidate accepted and source-linked; open/Play release is out of scope |
| 16 | Later families | Not started |
| 17 | Review closure/parity | Original Q3, the current 21-item Neo visual review, and the currently reviewed parity checks are accepted; Neo-dark settings validation and the Health Trends / selected-period history visuals were accepted on 2026-09-24. Later changes require affected rechecks |
| 18 | Enforcement/qualification | Latest inventory check on 2026-09-26 reports 2,286 candidates (92 allowlisted, 1,568 migrated, 626 pending; 1,013 queued, 1,273 outside); repository-wide Dart analysis and all 797 Flutter tests passed before the inventory-only TrainTabs rule/contract addition, whose focused tests passed afterward. The three approved ratchet scopes pass report/enforce. Neo Current Metrics, MealPlanAddBar, the Auto Preset add-method dialog, and Nutrition form appearance reviews remain; nested flow-state review is deferred |
| 19 | Development readiness | Complete for agreed Q3 scope, 2026-09-11 |

Earlier verified working-tree checkpoint (2026-09-24; superseded by the refreshed Step 3/18 scan below): the user ran
formatting (two files, one changed), targeted analysis (no issues), 60 focused
tests (all passed), and inventory `--check` plus JSON refresh. The report
confirmed 278 Dart files / 2,295 candidates: 86 allowlisted, 1,356 migrated,
853 pending, zero review/unassigned, 1,043 uniquely queued, 1,252 outside
queues, zero pending without a queue, and zero overlaps. These changes separate
99 audited settings recipes and 29 accepted Health Trends recipes from
unqualified scopes and assign disjoint queues to the 309 formerly unqueued
pending candidates.

Earlier flow/chart batch (2026-09-24; its inventory totals are superseded by the refreshed scan below): the previous layout revision passed
formatting, analysis, all 74 focused tests, and inventory `--check`/JSON refresh
at 278 Dart files / 2,295 candidates (86 allowlisted, 1,470 migrated, 739
pending, zero review/unassigned, 1,043 uniquely queued, 1,252 outside queues,
zero pending without a queue or overlaps). A subsequent user-requested
refinement restores Classic's established 7:3 hero at standard width and
preserves selector height when text fits. The user-run 393px regression caught a
vertical overflow caused by the fixed hero height; the follow-up lets the
side-by-side hero grow when content wraps. The user reran formatting (no
changes), analysis (no issues), and the responsive suite (both tests passed).
The inventory report/check passed before the geometry-only height adjustment;
the full 12-suite batch was not repeated afterward. The user confirmed that
this card looks good in Classic light and dark on device; broader Android
qualification remains open. The flow work is presentation classification only; nested
persistence/editing-state review remains deferred. No ratchet scope was
expanded and broader route qualification is not implied.

Steps 17-19 were inserted as prerequisites, so numerical order is not execution
order. Step 19 already authorized Step 13. Older statements that the initial
readiness gate is unstarted or that preference write ordering needs initial
implementation are superseded.

## Verification Already Reported

Auto Preset shared-control follow-up (verified by Codex on 2026-09-25): the
add-method dialog now uses six `TonosField` inputs and three
`TonosDialogDropdownButton` selectors, without changing save/controller logic.
Its route contract protects that ownership while leaving the separate graph
editor's route-specific decoration intact. Formatting and repository-wide Dart
analysis passed; 25 focused route/control tests and the full Flutter suite
(796 tests) passed. Inventory check reports 278 Dart files / 2,295 candidates
(92 allowlisted, 1,561 migrated, 642 pending; 1,022 uniquely queued, 1,273
outside queues, zero overlaps, and zero unqueued pending). Ratchet report and
enforce passed for all three approved scopes. A report-only probe found 18
distinct TonosDialog fingerprints, so the ratchet was not broadened without a
separate per-statement review. Visual review of the Auto Preset add-method
dialog remains pending.

Prior shared-controls follow-up (verified by Codex on 2026-09-25): app-default
and preset-method Flow Methods dialogs now use the shared
TonosDialogDropdownButton, preserving Classic's native defaults and resolving
Neo menu surface, item foreground, and arrow colors from the active dialog.
Four-mode menu tests cover both theme families and brightnesses. The segmented
action bar now stacks at a measured finite natural width when its parent gives
it unbounded horizontal space; the new horizontal-scroll regression verifies
finite layout, and the bounded-width/reflow cases remain covered. The Flow
Methods inventory contract now pins 20 findings after the duplicated local
dropdown-style candidate moved behind the shared primitive. Formatting passed
with no remaining changes across eight checked Dart files; targeted analysis
reported no issues; 55 focused tests and the full Flutter suite (795 tests)
passed. Inventory check passed at 2,301 candidates (92 allowlisted, 1,561
migrated, 648 pending; 1,028 uniquely queued, 1,273 outside queues, zero
overlaps, and zero unqueued pending). Ratchet report/enforce passed for the
three existing scopes, unchanged. git diff --check found no whitespace
errors; only normal LF/CRLF conversion notices were printed.

Previous focused follow-up (verified by Codex on 2026-09-25): the exact
`presets-loaded-recipes` inventory rule owns six migrated candidates and no
other kinds; its four-mode rendered contract checks archived empty-state ink,
the progressive Show More theme recipe, and reveal behavior. The test finder
was corrected to match `OutlinedButton` subclasses on the repository's Flutter
SDK. Formatting reported no changes, targeted analysis found no issues, and 44
focused tests passed across Train/PresetsLoaded, inventory/ratchet, and D2
progress/history contracts. Inventory `--check` and JSON refresh passed at
2,301 candidates (92 allowlisted, 1,561 migrated, 648 pending; 1,029 uniquely
queued, 1,272 outside queues, zero overlaps, and zero unqueued pending). Fresh
ratchet report/enforce checks matched all three approved scopes. No production
source, protected file, or ratchet scope changed during this verification
follow-up.

Earlier verified working-tree extension (2026-09-25; its inventory counts were
superseded by the following Train-tabs and History Summary/Current Metrics
scans): the shared bottom-navigation
widget now has a four-mode (theme family x brightness) contract covering the
Classic Material fallback and the Neo rail's ColorScheme/token-owned frame,
selected segment, outline, shadow, and activation. A kind-limited exact-path
inventory rule marks its four current `color`, `decoration`, `geometry`, and
`shadow` findings as theme-system-owned/migrated; a contract pins that exact
scope and count. User-run formatting processed two test files (one changed),
analysis reported no issues, and all 17 navigation/inventory tests passed.
Inventory `--check` and JSON refresh passed: 278 files / 2,299 candidates (86
allowlisted, 1,488 migrated, 725 pending), with 1,038 uniquely queued, 1,261
outside queues, zero overlaps, and zero pending without a queue. The navigation
rule reports exactly four migrated findings. PowerShell JSON parsing and
`git diff --check` also passed (only normal LF/CRLF notices). No production UI
implementation or ratchet manifest changed.

Verified Train-tabs slice (2026-09-25): the Neo tab-button
radius literal is replaced by `AppShapeTokens.trainTabButton`, explicitly set
to the existing 3px value; the frame and outline continue to use `trainTab` and
`outlineWidth`. Four-mode widget coverage checks the frame, selected/unselected
button shapes, fills, borders, and shadow; token tests cover copy/interpolation.
An exact geometry-only rule covers the four remaining widget geometry
candidates; replacing the 3px literal also removes that raw-literal scanner
candidate, while the token declarations remain covered by the theme-system
rule. The whole widget moved from the exercise-planning queue to navigation
support, with one-queue ownership preserved; its other four findings remain
pending. Formatting processed seven files (four changed), analysis found no
issues, and all 42 tests passed. The refreshed report shows 2,303 candidates
(86 allowlisted, 1,497 migrated, 720 pending), 1,037 uniquely queued, 1,266
outside queues, zero overlaps, and zero pending without a queue. Navigation
support has 19 candidates (5 allowlisted, 8 migrated, 6 pending); exercise
planning has 161 pending. No ratchet scope changed.

Previous Step 3/7/9/10/18 batch (verified by Codex on 2026-09-25): the Current Metrics
empty message now uses `TonosSurfaceVariant.panelRaised` inside a full-width
wrapper and a surface-scoped theme. Four-mode tests assert resolved surface,
radius, width, text foreground, and unchanged Classic surface/radius. Its five
category colors and one fixed circular marker are separately count-pinned data
allowlists. Train's profile-avatar text now reads the existing semantic
contrast role, with a four-mode rendered assertion. Final formatting reported
zero changes; targeted analysis found no issues; five focused Flutter suites
passed 59 tests, and the MealPlanAddBar suite passed all five tests. Inventory
check and JSON refresh passed at 278 files / 2,300 candidates (92 allowlisted,
1,507 migrated, 701 pending), 1,034 uniquely queued, 1,266 outside queues,
zero overlaps, and zero pending without a queue. Ratchet report and enforcement
both passed across the three existing production scopes; no manifest or scope
changed. Neo Current Metrics and MealPlanAddBar still need visual review.

Earlier WeightCard recipe follow-up for Steps 3/7/9/10/18 (verified by Codex on
2026-09-25): the existing Workout completion values are now named surface and
shape roles, preserving the accepted hint/selection opacities, Neo square row,
Classic control radius, and 1px/3px borders. Four-mode rendered tests cover the
completion card and row, optional Classic outline, change-set outline/fields,
and token-owned effects. The exact `weight-card-recipes` rule classifies 23
color, transform, decoration, geometry, and shadow findings as migrated; the
three text-style findings remain pending. The focused five-suite batch passed
60 tests; targeted analysis was clean and the final format pass made no
changes. Inventory check/refresh passed at 278 Dart files / 2,303 candidates
(92 allowlisted, 1,535 migrated, 676 pending), with 1,032 uniquely queued,
1,271 outside queues, zero overlaps, and zero unqueued pending. The three
existing ratchet scopes passed report/enforce with no manifest change. This
advances token adoption and exact classification, not shared-primitive count;
Neo Current Metrics and MealPlanAddBar visual review remain open, and the
deferred nested flow-state review is unchanged.

Subsequent WeightCard text-ownership follow-up (verified by Codex on
2026-09-25): removed the unused input hint/suffix TextStyles because no current
WeightCard field consumes them; added a rendered popup-label contrast test in
all four theme modes; and added an exact `weight-card-popup-text` inventory
rule plus a contract pinning its single migrated finding. The WeightCard file
now has zero pending candidates. Formatting and analysis passed, the focused
WeightCard/inventory/workout batch passed 40 tests, inventory check/refresh
passed at 2,301 candidates (92 allowlisted, 1,536 migrated, 673 pending), and
the existing three-scope ratchet report/enforce plus `git diff --check` passed.
No visible defaults or ratchet scopes changed.

Subsequent Train action-bar ownership follow-up (verified by Codex on
2026-09-25): the existing four-mode TrainPage test now checks action-bar
semantic text colors, token-backed frame border/shadow/elevation, divider,
compact horizontal geometry, and enabled Start/Optimize/settings controls. The
exact `train-action-bar-recipes` rule owns seven findings and its inventory
contract pins that count. Formatting/analysis were clean and the combined
Train/WeightCard/inventory/workout/ratchet batch passed 57 tests. The refreshed
inventory reports 2,301 candidates (92 allowlisted, 1,543 migrated, 666
pending); ratchet report/enforce and `git diff --check` passed. No source visual
defaults or ratchet scopes changed.

Earlier user-run health/history consumer verification (2026-09-24): formatting
processed four files and changed only `workout_history_calendar.dart`; targeted
analysis reported no issues; six focused Flutter suites passed all 23 tests.
The inventory `--check` and JSON report completed for 278 Dart files / 2,295
candidates (86 allowlisted, 1,228 migrated, 981 pending, zero review, and zero
unassigned), including 12 local-theme candidates (7 pending, 5 migrated).
Queue coverage is 729 uniquely assigned, 1,566 outside configured queues, and
zero overlaps. The subsequent TonosDialog picker fix was formatted (2 files
changed), analyzed without issues, and passed 7 focused tests. The contrast
tests were subsequently strengthened with a 4.5:1 minimum, an opt-out
regression, rendered dropdown checks, and captured date/time picker-route
themes. The first strengthened run exposed a bad test finder: Flutter 3.29
draws the dropdown background in `CustomPaint` from the captured
`Theme.canvasColor`, not an opaque `Material`. The test was corrected to inspect
the effective menu theme. The user then reported formatting unchanged, clean
analysis, and all 38 tests passing across the dialog, health/history, route-ledger,
inventory-contract, and ratchet suites.
The inventory check/report and three-scope ratchet report/enforce both passed
after the library change; the inventory is current for `lib/` because only the
test and docs changed after that scan. The user then confirmed that Health
Trends and the selected-period Workout History card look good; the previously
open visual check is closed for these surfaces.

Historical user-run inventory/identity-color verification (2026-09-24, before the
current SettingsAccent classification): inventory
`--check` and JSON report passed for 278 Dart files / 2,293 candidates (70
allowlisted, 1,224 migrated, 999 pending, zero review, and zero unassigned).
All 11 fixed profile/plan identity-color findings are now allowlisted; the
report has 14 local-theme findings (9 pending, 5 migrated). The inventory scan
includes the SettingsExpansionSection divider-scope edit. Formatting reported
no changes and analysis reported no issues for the palette source and focused
contract/widget tests. The initial contract/drawers run failed on the obsolete
phrase `stable palette identifiers`, which was corrected. Its rerun passed 36
tests and failed one assertion because it expected `contrast-qualified
swatches`, while the rationale says `contrast-qualified theme-aware swatches`.
The test now checks `contrast-qualified` and `theme-aware swatches` separately,
along with `ThemePaletteId` and `IdentityPaletteId`. The corrected follow-up
passed all 37 tests; formatting reported no changes and analysis found no
issues. The SettingsExpansionSection integration assertion was included and
passed. The prior
five-file 26-test suite, two-file ratchet
report/enforce, and inherited ListTile/icon regression passed for their tested
source state; the later current-tree reruns now pass as recorded below. All six badge findings remain migrated.
On 2026-09-24,
the user accepted the current Flow Methods and Workout Progress Flows appearance,
including the Neo-dark Add App Default Rule dropdown contrast correction, the
Exercise Progress chart, and the Preset Generation QA and Food Customization
ExpansionTiles. User-run formatting changed three files, analysis reported no
issues, and the focused settings/residue suite passed all 32 tests. The user
visually accepted the scoped darker Neo-dark validation style on device on
2026-09-24. The user explicitly
deferred the separate Flow Methods / Workout Progress Flows nested persistence
and editing-state review; keep it pending.

Prior acceptance record (2026-09-16): the user accepted all 21 entries in the
current Neo visual review. Entries 1-13 were accepted in the earlier review;
entries 14-21 cover Guided Tutorials, Bodypart Rankings, Muscle Rankings,
Volume Boundaries, Anatomy Mapping, Exercise Set Allocation, Exercise Editor,
and Flow Methods / Workout Progress Flows. This closes the current visual
route-review scope, not the exhaustive state, accessibility, device, or release
matrix.

Follow-up review confirmation (2026-09-17): the user confirmed item 20,
Guided Tutorials, after the Neo-light tutorial-card icon and progress-count
foregrounds were deepened for the cream card. Items 1-21 are now visually
accepted. AppTutorialTokens.accentForeground supplies the deeper Neo-light
accent; Classic falls back to its ColorScheme primary and Neo dark retains its
existing primary.

Latest targeted verification (2026-09-16): the user ran `dart format` on
`settings_tiles.dart`, `volume_boundaries_screen.dart`, and
`bodypart_muscle_mapping_screen.dart` successfully (two files changed); `dart
analyze` reported no issues; and the focused Flutter run passed all 63 tests:
`settings_tiles_test.dart`, `neo_refinement_regression_test.dart`,
`step17_consumer_parity_test.dart`, and `pre_q2_route_evidence_test.dart`.
This specifically verifies the final Neo selector contrast correction. It is a
scoped result, not a replacement for broader suites or N6 evidence.

Latest Step 14 verification (2026-09-16): the user also ran the focused family
selector test with 7 passing tests, the complete `test/theme` suite with 300
passing tests, the responsive accessibility suite with 6 passing tests, and
the style ratchet in enforce mode. Formatting was unchanged and analysis
reported no issues. This closes the automated implementation check for the
selector; it does not approve Neo for release or replace the consolidated
human visual, accessibility, device, and performance batch.

Earlier acceptance: the user considers the reviewed pilot screens and the
current Catalog/Logbook/Progress plus exercise-detail refinement batch good for
now. Targeted formatting and analysis passed, and
`neo_refinement_regression_test.dart` passed 28 tests. The earlier broader run
had 655 passes and two failures: the copy-contract Mg sample was subsequently
fixed, while the Canadian French Profile test still needs diagnosis under
Step 17. The later targeted copy-contract run passed 10 tests; these results
are scoped and not one combined suite.

The user also accepted the restored Classic Workout Report visually, with
clean targeted analysis and two responsive report tests passing. Historical
pending statements below are superseded for these reviewed scopes. Remaining
stress/device evidence belongs to N6; reviewed pilots need no further polish
unless another defect is found.

Steps 3, 7, 9, 10, and 18 follow-up (2026-09-23): the focused inventory work
already adopted the estimated-1RM progress-color role (47 targeted tests passed;
the supplied Pixel 7 capture shows its marker and legend in Neo dark) and the
workout-detail badge-stack primitive (16 tests passed and the user confirmed
the overflow is gone). Cross-mode visual acceptance for the chart color is
still outstanding. A source audit found the SettingsInfoCard local Theme was
redundant because its closed subtree explicitly assigns text and icon colors.
The user then reported clean analysis, 57 passing focused tests, and a
refreshed 277-file inventory (2,319 candidates, 1,038 pending, zero unassigned),
verifying the wrapper removal and four-mode regression test. SettingsSection
and SettingsExpansionSection scopes remain because they wrap caller-provided
controls. The inspected health-trend, workout-history, workout-card,
seven-day-focus, exercise-progress, and flow-card scopes also serve inherited
widgets or open child content. Follow-up changes consolidate the duplicated
FirstRecordBadge/WorkoutRecordBadgeChip renderer and route workout-trend
direction labels through AppProgressColors in both theme families. The focused
test batches were subsequently user-run and passed; the user confirmed the
Measurement Trends visuals in all four modes and the workout-detail badge
  overflow fix. The 2,319 report predates these changes. At that report
  checkpoint, no new inventory classifications or ratchet paths had yet been
  approved; the later Step 18 review added the badge file's exact fingerprints
  and narrowly approved the three mapped TonosSurfaceTheme statements inside the
  existing protected surface path. The two-scope report/enforce rerun passed
  at that checkpoint, and
an interim inventory refresh recorded 2,296 candidates; the 2026-09-24 reports
of 2,294, 2,293, and 2,297 candidates are historical checkpoints. The
2,307-candidate report was the pre-refactor baseline; the 2,299-candidate
report was a later checkpoint and has been superseded by the current
2,303-candidate reports above. The current Flow
Methods and
Workout Progress Flows appearance was accepted on 2026-09-24; nested persistence
and editing states remain separate and are explicitly deferred by the user.
The Exercise Progress chart and the Preset Generation QA / Food Customization
ExpansionTiles were also accepted that day. The darker Neo-dark
settings validation-error style passed formatting, analysis, and the focused
32-test run on 2026-09-24; the user subsequently accepted its device appearance.
Broader inventory, token/primitive adoption, and per-file evidence work remains
partial.

Classic Workout Report restoration update (2026-09-15): the metric-box
same-line correction and responsive regression test were user-verified with
clean formatting, clean analysis, and three passing focused tests. The user
also considers the current Classic report appearance visually good. Other
matrix checks remain scoped as below; no new full device pass is inferred.

Train Neo refinement update (2026-09-14): the selector frame now uses the
standard structural outline width, Active Plans/Archived Plans/Premade Plans
use the raised-panel depth role, plan rows and the archived empty state use the
compact-card depth role, and the Premade browse action uses primary-action
depth. Classic keeps its existing Card and button recipes.

Workout-card refinement update (2026-09-14): Neo WeightCard fields now use a
compact always-floated label recipe and slightly wider usable field content so
the complete Weight (lbs) label fits and the outlined border reserves its notch.
The shared WeightCard covers both preset details and active sessions; Classic's
field recipe remains unchanged. Neo set labels and the Add Set action now use
the same dark workout-container ink as the fields and exercise title instead of
inheriting a light button/text color. User-run visual and test verification is
pending.

Completion-state refinement update (2026-09-14): Neo WeightCard completion now
uses separate semantic colors for the completed exercise and completed set rows.
The whole completed exercise is the darker green (`#96B967` light,
`#A6D466` dark); completed set rows use the lighter green (`#B9D994` light,
`#C5EC91` dark) and a dedicated compact `(2,2)` hard shadow. Classic continues
to use its original completion color and effect path. User-run visual and test
verification is pending.

Completion-sheet density refinement (2026-09-14): Neo now uses the same normal
phone-width four-column metric breakpoint as Classic, so Exercises, Sets,
Duration and Volume occupy one compact row instead of an unnecessary 2x2 grid.
Neo keeps its square outlined surfaces, while normal-scale result cards reduce
outer padding, row gaps, separator space and badge spacing. Narrow and large-
text layouts still reflow; Classic completion geometry remains unchanged.
Focused regression coverage records the four metric tiles and condensed card
bounds. User-run visual and test verification is pending.

Completion-row alignment refinement (2026-09-14): Neo and Classic completion
rows now keep the ERM value inline with the matching set result at normal phone
widths. Both use a right-aligned trailing column with scale-down protection for
long values; only narrow or large-text layouts stack the ERM line, where it is
also aligned to the trailing edge. User-run visual and test verification is
pending.

Current screen-batch closure (2026-09-15): the first-pass Neo treatment for
Catalog, Logbook, Progress, and the shared exercise-detail destination is
implemented and the user considers the batch finished for now. The reviewed
fixes include compact Workout Report metrics/range/details layouts, readable
Health Trends cards, the restored Classic insight-box layout and wording,
preservation of the earlier Logbook calendar surface after a reverted yellow
experiment, and one owner for the Neo exercise-detail sheet handle. The latest
exercise-detail verification supplied by the user reported clean analysis and
four passing contract tests. This is current-batch acceptance, not N5 route
closure or N6 qualification.

Theme-ready secondary-surface extension (2026-09-15): evolving non-default
routes now have a shared compatibility boundary without being declared fully
Neo-designed. `TonosThemeReadyCard` preserves the original `Card` path for
Classic and supplies a semantic `TonosSurface` path for Neo. The extension
covers exercise definitions and info tiles, full exercise history, cardio and
stretch cards, current measurements, nutrition bar details, the generic trend
page, food customization, and food logging. Neo-specific data/action colors
use existing semantic or visualization tokens; route behavior, persistence,
units, and product flows were not changed. The user supplied clean post-fix
analysis for `current_metrics_section.dart` and 32 focused tests passed. This
is theme-ready compatibility evidence, not full Neo visual approval or N5/N6
route qualification; final recipes remain deferred until those product areas
stabilize.

Automatable Neo completion pass (2026-09-15): the development-only pilot
gallery now includes the required collapsed Bench Press fixture, data-owned
blue plan identity marker, local navigation selection, cancellable Weight
Units dismissal, live reduced-motion duration coverage, a large-text stacked
WeightCard set editor, and a 320px/2.0x pilot smoke test. The new theme-ready
boundary test preserves Classic Card ownership and confirms Neo TonosSurface
ownership. pre_q2_route_evidence_test
now records the secondary consumer boundaries, and
scripts/verify_neo_refinement.ps1 includes these sources/tests plus
git diff --check. User-run analyzer/test output, rendered screenshots,
route-by-route reachability, accessibility and physical-device qualification
are still required before N5/N6 can be called complete.

Automatable nutrition follow-up (2026-09-16): the GoalManualEntryPage save
path now distinguishes a successful repository write from a safe classified
failure. A failed save keeps the form open and shows localized recovery
guidance instead of reporting success by popping the route. The focused
`nutrition_goals_behavior_test.dart` covers both outcomes. Active StretchCard,
Train2, and Food Logging action controls now expose existing localized labels
where their action meaning is unambiguous. At the time of this implementation
note, this was behavior/accessibility evidence only; the later user
qualification confirmation records the corresponding route, keyboard/TalkBack,
and physical-device N6 checks as accepted.

Earlier expanded verifier rerun (2026-09-17): the first run reached the new Neo
food-editor smoke and exposed a 129 px right RenderFlex overflow in both
brightness modes at 320x640 with 2x text. `FoodCustomizationPage` now wraps
its bottom extended actions instead of forcing them into one row. The focused
dark/light reruns and the expanded batch then passed; the full theme suite
reported 302 tests, the responsive run reported 6 tests, the route-boundary
batch passed, and the enforce-mode ratchet passed.

Post-review non-human implementation pass (2026-09-17; verified again by the
2026-09-22 corrected-scope user run):
the route ledger now checks exact row ordering, source paths, and
constructor-level caller edges; new contracts cover N5 state owners and
settings residue; nutrition tests cover provider rollback, diary failure,
grouped/date rendering, validation, and normal-width action geometry; and
Classic parity covers health delta roles and the Classic/Neo card boundary.
The Neo compatibility surface also preserves explicit shape and elevation,
while large-text settings values can wrap without changing normal layout
behavior. The post-review pass also restores outlines and shadow geometry for
explicit custom rounded Neo shapes and tightens route-edge contract matching.
No new production files were enrolled in the style ratchet.
The 2026-09-17 run at that checkpoint reported 132 files formatted, with 1
file changed, clean analysis, 315 theme/configuration tests, 6 responsive
tests, 46 route-boundary tests, and a passing enforce-mode ratchet.

Final verifier-scope rerun (2026-09-22; user-supplied): the corrected
`scripts/verify_neo_refinement.ps1` formatted 135 files with 0 changes,
reported clean analysis, passed 321 theme tests, 6 responsive tests, and 46
route-boundary tests, and passed the enforce-mode ratchet with one protected
production file. BodyHeatmap diagnostics showed active SVG anatomy paths for
the tested palettes. This closes the previously recorded scope-only rerun;
it does not expand ratchet enrollment or qualify Neo for release.

1. Q3: clean analysis, 226 scoped tests, and user manual-plan confirmation on
   2026-09-11. Sixteen Classic images were accepted at font scale 1.15. Requested
   startup, persistence, switching, large-text, accessibility, and route checks
   were accepted subject to the Q3 record's limitations.
2. N2: shared capabilities automated-verified. N3: historical 230-test review and
   233-test pilot rerun passed; Theme Lab smoke review accepted. Current pilot
   visual review is accepted for now; final screenshot/stress-state evidence
   remains separately recorded as pending.
3. N4: original real-route development acceptance covers Train, workout, User
   Information, Weight Units, local state, restart/fallback, both brightness
   modes, and 1.15/2.0 scales. Later refinements require affected-route rechecks.
4. Subsequent verification script: user reported 37 files formatted unchanged,
   clean analysis, 274 tests passing, and six responsive tests passing. These
   results apply to that run, not automatically to subsequent edits.
5. Classic restoration: user reported 59 focused tests passing, followed by clean
   settings analysis and 25 settings tests passing.
6. Latest supplied result after compact Train-selector shadow reduction:
   tonos_train_tabs.dart formatting unchanged, analysis clean, and 51 tests
   passing across Train tabs, settings tiles, and Neo refinement regressions.
7. Latest exercise-detail result: six affected files formatted, analysis
   reported no issues, and exercise_detail_contract_test.dart passed 4 tests.

Counts are not additive and are not one combined suite. No new automated checks
were executed for this documentation update. The complete fresh-device matrix
is pending; individual screenshots and defect reports do not mean every cell
has passed. Record future results with actual command scope and source identity.

## Detailed Steps

### Step 1. Preserve The Permanent Classic Contract

Status: complete; maintain during shared changes.

Completed: permanent Classic identity, default/fallback behavior, both modes,
and compatibility requirements are documented and covered by contracts.

Remaining responsibilities:

- Preserve ordinary-scale colors, typography, geometry, density, borders, and
  elevation. Neo work must not silently restyle Classic.
- Retain approved usability changes: complete names/values, localized controls,
  accessible editing/removal, and reflow where content or large text needs it.
- Treat unexpected appearance differences as regressions or explicit review
  decisions; do not rewrite the baseline to match an accidental change.

Exit: no initial implementation remains; each shared change preserves this rule.

### Step 2. Complete Current Classic Comparison Evidence

Status: complete for the agreed comparison scope; user-confirmed on 2026-09-24.

Completed: the accepted 16-image set at 1.15, reference conditions, behavioral
results, and classification of the correction pass's Classic-visible changes.
The user has now reviewed the matched Classic light/dark comparisons for Weekly
Overview, Train sections/actions, settings, Progress selectors, Workout Report,
workout completion, and record badges, including the agreed 1.15 comparison and
2.0 accessibility reflow checks, and reported that they look good. This records
the user's acceptance; no new capture files were attached in this turn.

Remaining tasks: none for the accepted surfaces. Keep this acceptance tied to
the reviewed source state; repeat only comparisons affected by later changes.
No screenshot archive or full device/build metadata was supplied with the
confirmation, so the record is user-confirmed rather than an artifact-backed
capture bundle. Automated goldens remain a separate choice for stable surfaces.

### Step 3. Finish Style Classification And Qualified Coverage

Status: inventory and scoped enforcement implemented; broader work partial.
Latest verified inventory after shared field adoption, WeightCard hint/suffix
restoration, and exact Train-tab ownership (2026-09-26): 278 Dart files / 2,286
candidates (92 allowlisted, 1,568 migrated, 626 pending), with 1,013 uniquely queued,
1,273 outside queues, zero overlaps, and zero pending without a queue. Food
Logging uses `TonosField` for search/barcode and `TonosFormField` for four
quantity/note/tag editors; its pending findings fell by six, with 17 still
pending in that file. The
History Summary rule owns ten migrated findings. Current Metrics has five
category-color findings and one circular marker decoration under separate,
count-pinned data allowlists; its empty-state panel uses TonosSurface, leaving
no pending style candidate in that widget. `train_page.dart` has an exact
four-mode rule for its seven action/avatar findings and no pending findings;
the current-profile avatar reads the existing semantic contrast role.
`tonos_train_tabs.dart` has no pending style candidates: its four exact geometry
findings and four frame/surface/effect/color findings each have separate
kind-limited rules, pinned to the four-mode component contract. The user
accepted the Train visual review across both families and brightness modes.
`weight_card.dart` has a kind-limited
recipe for 23 migrated color/transform/decoration/geometry/shadow findings
plus three migrated popup/input text-style findings. Its hint style uses the
workout input-hint opacity token and semantic workout ink; its suffix style
uses the same semantic ink. The file has no pending inventory candidates.
The existing D2 ownership in `workout_dashboard.dart` and
`data_records_section.dart` is now represented by exact kind-limited rules for
8 and 4 findings respectively, pinned by inventory contracts alongside the
existing D2 role/state contracts. `presets_loaded.dart` has an exact four-mode
rule for six migrated findings and no pending findings. The history/measurement
queue now has 23 migrated findings and 3 pending; no broader device or release
qualification is implied.
An earlier user-run inventory check/report (before SettingsAccent allowlisting; 2026-09-24) covered 278 Dart files /
2,293 candidates: 70 allowlisted, 1,224 migrated, and 999 pending, with zero
review or unassigned findings. All 11 fixed profile/plan identity-color
findings are now allowlisted. The report includes the exact badge rule and
ExpansionTile-scope migration, and the six reviewed `workout_record_badges.dart`
entries remain migrated. At that earlier checkpoint, the local-theme grouping
was 9 pending and 5 migrated (14 total). An earlier supplied focus grouping
reported 20 pending findings in FlowMethodsPage, 18 in
WorkoutProgressFlowsPage, and 12 migrated findings in tonos_surface.dart. The
11 review findings in the earlier report were in the fixed identity-color
palette and are now allowlisted. Later inventory snapshots have superseded
those totals. The tutorial recipe's kind-limited
allowlist is present in the machine-readable inventory. The corrected
contract/drawers/settings follow-up passed all 37 tests, with clean formatting
and analysis.

Completed: machine-readable inventory, scanner, validation tests, and enforcement
for an exact qualified scope. Assigned inventory entries are not all approved.
The tutorial overlay's accepted recipe is an explicit kind-limited intentional
exception, confirmed in the refreshed report. The user accepted retaining the
identity-color mapping on 2026-09-24; the refreshed report confirms its 11
findings now have an intentional data-color allowlist. A focused contract rerun
passed all 37 tests after correcting its stale rationale assertion. The
2026-09-24 audit also found that the exact exercise-editor hotspot was shadowed
by the broad `profile-settings` rule; the rule order and regression contract
now preserve its intended pending ownership. The inventory report now includes
live review-queue counts and overlap metrics, with a contract requiring the
current six queues to remain disjoint. The new SettingsAccent rule covers only
the two literal-finding kinds; the last report showed 16 such candidates. Its
stable-value/ownership contracts, focused tests, and refreshed inventory now pass. The subsequent chart-widget analysis found two unused imports; after their removal, the user reran targeted analysis twice for the chart and responsive-test files, and both runs reported no issues. This completes that analyzer follow-up, but does not verify later source edits in this batch.
Keep future app-wide color choices as a persisted `ThemePaletteId`, independent
of theme family and brightness, with semantic roles resolved through curated
light/dark theme recipes. If identity palettes later become selectable, use a
separate `IdentityPaletteId` and curated, contrast-qualified swatches; do not
persist raw colors or map identity to status roles.

The 2026-09-25 MealPlanAddBar refactor now delegates segmented geometry and
interaction to `TonosSegmentedActionBar`, retaining the existing nutrition
surface, divider, and body-typography roles. User-run formatting processed six
files (three changed), targeted analysis reported no issues, and the focused
widget/route/inventory batch passed all 26 tests. The refreshed inventory
reports 2,303 candidates, with zero findings in `meal_plan_add_bar.dart`; that
verified slice changed no candidate classification or ratchet scope. The
subsequent exact navigation classification is now verified as recorded above.
Four-mode human visual
review remains open.

Remaining tasks:

1. Reconcile current reachable routes and changed files with inventory entries.
2. Continue classifying remaining styles as Material, semantic token, shared
   recipe, data/media, or a documented exception. The profile/plan identity
   mapping decision is complete: retain the current colors across Classic/Neo
   and both brightness modes, independent of state-semantic and theme-primary
   roles. Add surface contrast treatment only where rendered contrast evidence
   requires it.
3. Give deferred items an owner and impact, and unreachable items actual evidence.
4. Review migrated files before expanding ratchet enrollment. Keep unqualified
   legacy debt reportable rather than claiming whole-repository enforcement.
5. Verify approved exceptions and failure behavior when enforcement changes.

Exit: each in-scope surface has explained ownership; qualified scopes reject
new unapproved structural styling without forbidding legitimate media/data.

### Step 4. Preserve The Extracted Classic Factory

Status: implementation complete; current visual comparison is tracked by Step 2.

Completed: Classic definitions were extracted from main.dart; factory caching
and component contracts exist and the agreed Q3 appearance was accepted.

Remaining tasks: check shared recipe changes against Classic's accepted output;
file actual discrepancies under Step 17. Do not redo extraction or duplicate
ThemeData construction because an old heading says parity was pending.

Exit: existing factory contracts remain healthy and affected comparisons pass.

### Step 5. Maintain Stable Selection And Preferences

Status: implemented; original Q3 startup/persistence/switching accepted.

Completed: stable codes, device-local preferences, legacy brightness migration,
safe fallback, ordered writes, retry/lifetime handling, and live-state behavior.

Remaining tasks after relevant edits:

1. Recheck rapid switching, restart, and saved family/brightness on affected paths.
2. Retain focused coverage of failed writes, retry, disposal, corrupt/missing
   values, and unavailable family codes. Fix failures without replacing the system.
3. Confirm form text, selection/focus, open dialogs, workout values, and intended
   tab/scroll state survive changes of family and brightness.
4. Preserve unavailable stored codes according to the existing fallback contract.

Exit: changed paths retain the tested contract. Appearance export/import remains
a separate preference-schema decision, not an unfinished prerequisite here.

### Step 6. Maintain Availability And Release Gating

Status: internal Android availability policy, signed candidate, and source/hash
association are complete for Step 15. Wider release remains a separate decision.

Completed: Neo registration, central capability filtering, experimental opt-in,
default release denial/fallback, explicit internal release opt-in, and the
selector/persistence and device checks for the accepted candidate. Source
commit `eae77c321a7acd7ec66a77f634eec08d009d727c` is associated with the accepted
APK SHA-256 `549BE2C9EDD96E44840C7E42976BDF436C29B3F53DC9C946FA043EB3EC68615D`.

Remaining: no Step 6 work remains for this internal candidate. Broader release
decisions are tracked separately.

Exit: unfinished families cannot leak into release selection.

### Step 7. Maintain Complete Focused Tokens

Status: foundation complete; adoption follows demonstrated route needs.

Completed: semantic, surface, shape, decoration, effects, motion, data, and
feature contracts with family definitions, fallbacks, and copy/lerp coverage.

Remaining tasks:

1. Adopt existing roles where the route sweep finds unexplained local styling.
2. Define every added role for Classic/Neo light/dark and safe isolated hosts.
3. Preserve reduced motion and effects-off behavior, including layout stability.
4. Verify rendered consumers and contrast on actual backgrounds; an unused
   resolver or a property-only test is insufficient proof of adoption.

Exit: needed roles are complete and consumed. Avoid speculative token expansion.

Recent adoption uses the existing workoutIncrease/workoutDecrease roles for
chart direction in all four Classic/Neo brightness modes; the user confirmed
the Measurement Trends graphs on 2026-09-23. The subsequent settings-field and
surface-wrapper work adds no new token role; the wrapper reuses existing
contrast resolvers, and the 120-test user run passed. Focused visual rechecks of
affected routes remain.
This batch also strengthens the Weekly Overview contract to assert the
existing progress-indicator foreground and track roles in all four registered
theme modes. The user-run four-mode widget/route batch passed; it adds no token.
The 2026-09-25 nutrition action-bar slice likewise reuses existing nutrition,
shape, surface-divider, and foreground roles; its four-mode contract passed in
the user's 26-test run. No new token role was introduced. Human visual review
remains pending.
The Current Metrics no-measurements message now consumes the existing
panel-raised surface primitive. Its four-mode contract verifies resolved
surface, radius, and full-width layout while asserting that Classic retains its
prior Material surface color and 12px radius. No new token role was introduced.
Train's profile avatar text now uses the existing `onTrainProfileAvatar`
semantic role; a rendered four-mode test confirms the Classic-white and
Neo-ink values are preserved.
WeightCard completion and input recipes now consume named surface/shape roles
for the existing hint/selection opacities, Neo square completed-set shape, and
1px/3px row borders. Four-mode tests preserve rendered colors and geometry,
check change-set fields/effects, and cover the optional Classic completion
outline. Token copy/interpolation checks pass; no user-visible default changed.
The Auto Preset add-method dialog now consumes existing field and dialog
dropdown primitives. Four-mode primitive tests, the route ownership contract,
and the full suite pass; no new token role was introduced. The updated screen
still needs a focused human appearance check.

### Step 8. Keep AppColors Retired

Status: complete.

Completed: legacy extension/accessors and production consumers were removed.
Maintain the zero-consumer contract. Do not recreate a compatibility bridge.

Exit: no legacy production usage is reintroduced.

### Step 9. Complete Material Ownership Review

Status: shared boundary implemented and source inventory available. The
extracted TonosSurfaceTheme is covered by focused tests and clean analysis. Its
three fingerprints were exactly mapped and approved; the successful two-file
report/enforce was an earlier two-file pass; the current three-scope report/enforce passed. The affected Neo visual
recheck for Flow Methods and Workout Progress Flows was closed by the user's
2026-09-24 visual confirmation. Chart/theme (27 tests) and widget/settings (58 tests) batches passed; the user subsequently reran targeted chart/responsive-test analysis twice with no issues. The health-trend and selected-period workout-history shared-surface adoption passed its four-file format/analyze run, six focused suites (23 tests), and inventory refresh. The Neo Dark dialog picker correction passed formatting, analysis, and the strengthened nine-file, 38-test run. The user accepted both visuals. The broader per-control override audit remains.

Completed: Material ownership and Neo component recipes are centralized.
All 18 pending local Theme records in the pre-refactor scan were inspected;
their source owners and purposes are recorded in the inventory guide. The
latest verified pre-extraction scan has 16 pending and 3 migrated local Theme
expressions after the three repeated Train card foreground scopes became one
route-local helper. The later TonosSurfaceTheme extraction replaces the two
flow-card local wrappers. A supplied file-level grouping reports 20 pending
findings in FlowMethodsPage and 18 in WorkoutProgressFlowsPage, with 12
migrated findings in tonos_surface.dart; the subsequent refreshed scan confirms
the aggregate totals recorded in Step 3.
The tutorial-scrim exception was also reconciled with the already accepted
Guided Tutorials visual, accessibility, and effects evidence; no repeat human
review is needed for that unchanged recipe.
The shared settings foreground resolver now owns the existing disabled-ink
opacity for both text and dropdown icons. Body-part mapping and volume-boundary
screens use it instead of duplicating the 38% transform; the user-run
four-mode settings tests passed.
A prior scan after the ExpansionTile extraction recorded 9 pending and 5
migrated local Theme candidates (14 total). Five divider/density wrappers in
the preset QA and nutrition surfaces now use `TonosExpansionTileScope`. The
inventory check passed, and the corrected four-mode widget test first passed
in a 25-test suite. The follow-up inherited-style regression then passed in
the user's 26-test suite. The broader override audit remains open.
SettingsExpansionSection now delegates its transparent divider to the same
standard scope while retaining its separate local color-scheme/text theme. The
integration assertion passed in the latest `settings_tiles_test.dart` run. The
combined contract/drawers/settings batch had 36 passes and one separate failure
in the inventory-rationale contract.

The 2026-09-25 inventory scan confirms 12 local-theme candidates, all migrated:
Theme Lab, TonosActionDepth, TonosDialog, TonosExpansionTileScope, TonosSurface,
both Exercise Progress scopes, `SettingsSection`, `SettingsExpansionSection`,
Seven-Day Focus's progress-indicator scope, Train's panel-ink helper, and
WeightCard's input/selection scope. The user accepted Train and WeightCard in
Classic/Neo light/dark. The focused inventory/Train/Settings batch passed 49
tests and targeted analysis was clean, including the per-mode ExpansionTile
state-isolation fix. That checkpoint was limited to `local_theme`; the later
Train and WeightCard follow-ups migrated their exact pending action/avatar and
popup-text candidates and removed unused input hint/suffix overrides. Both
files now have zero pending inventory candidates. The exact WeightCard recipe
rule now migrates its 22 token-backed
non-text-style findings after the four-mode contract; keep the Train helper
and WeightCard field roles separate from generic shared surface recipes; further
consolidation must preserve their distinct resolved behavior rather than delete
overrides. The Train helper is
intentionally not replaced with `TonosSurfaceTheme`: it uses explicit
`onPrimaryContainer` ink and leaves icon inheritance unchanged, while that
shared primitive resolves against the actual surface and also scopes surface
and icon roles. Weekly Overview additionally owns progress-track colors.

The refreshed inventory has 12 local-theme candidates, all migrated. The
inventory contract now fails if a new local-theme candidate remains pending,
and the seven-suite Flutter rerun after adding this guard passed all 40 tests
in 22.7 seconds. This closes the local-Theme ownership gap only; broader
per-control Material override review remains open.
The latest Current Metrics pass routes its no-data panel through
`TonosSurfaceVariant.panelRaised`, retaining Classic's existing fill, radius,
padding, and width while allowing Neo's family recipe. The Train profile
avatar's contrast color now comes from `AppSemanticColors` rather than a
family conditional. Four-mode widget tests and the inventory contract cover
both scopes; the broad per-control override audit remains open.

The 2026-09-25 MealPlanAddBar slice delegates shared interaction, clipping, and
action-bar geometry to `TonosSegmentedActionBar`, preserving existing label and
divider roles. Its four-mode widget and inventory contracts passed in the
user's 26-test run and refreshed scan. Neo's family-specific action-bar shape
still needs visual review. The broader per-control override audit remains open.
The Auto Preset add-method dialog now uses `TonosField` and
`TonosDialogDropdownButton` rather than route-local text/dropdown controls.
Focused primitive and route-contract tests plus repository-wide analysis and
the full Flutter suite passed. Its separate graph-control recipe remains
route-owned because its Classic shape/defaults and Neo flow surfaces differ
from the generic settings-field recipe; the broader Material override audit
remains open.

Remaining tasks:

1. Inspect remaining local Theme subtrees and per-control overrides found in
   Step 12/N5. Health Trends and the selected-period workout-history card have
   been visually accepted; repeat only if later changes affect them.
2. Preserve valid Classic defaults and distinct variants; remove redundant
   overrides only after confirming their resolved output.
3. Move duplicated structural styling into its owning recipe or theme.
4. Check rendered selected/pressed/focused/disabled/busy/error/destructive states.
   Disabled must take precedence over focused styling and activation.
5. Recheck semantics, targets, focus order, and activation on changed controls.

Exit: local exceptions are justified and ordinary controls inherit correctly.

### Step 10. Complete Shared Primitive Adoption

Status: primitives implemented; production adoption remains route-dependent.
The 2026-09-24 audit consolidated the health-trend and selected-period
workout-history foreground scopes onto `TonosSurfaceTheme`. Four-file format and
analysis passed, all 23 focused tests passed, and the refreshed inventory
includes both consumers. The user subsequently confirmed the Health Trends and
selected-period history visuals after the Neo Dark picker contrast correction;
the user's later targeted dialog/measurement suite passed all 7 tests, including
the 4.5:1 foreground contrast assertions.
TonosField adoption in two flow forms, the database JSON-import dialog, and the
database manifest-URL dialog is verified. TonosSurfaceTheme's focused tests and
analysis passed; the latest 120-test regression batch, inventory check, and
two-file ratchet report/enforce also passed. Its three exact fingerprints are
reviewed and approved. The current Flow Methods and Workout Progress Flows
appearance was accepted on 2026-09-24 after the dropdown contrast correction.
The user also accepted the Exercise Progress chart and the Preset Generation QA /
Food Customization ExpansionTiles. The Neo-dark settings validation-error fix
passed formatting, analysis, and 32 focused tests on 2026-09-24; the user
accepted its device appearance. Nested flow persistence/editing review is
explicitly deferred.

Completed: shared surfaces, actions/depth, fields, sheets/dialogs, navigation,
and workout presentation with focused coverage. The repeated Train panel
foreground recipe now has one private owner rather than three copies. The
settings field primitive also centralizes disabled foreground ink for text and
dropdown icons across its existing consumers; the focused user run passed 34
settings, residue-contract, and route-ledger tests.
The subsequent TonosField adoption converted 12 flow-editor fields and one
database JSON-import field plus the manifest-URL field while preserving the
explicit import border and URL/multiline behavior; the user's focused format,
analysis, and 13-test run passed. The TonosSurfaceTheme extraction is covered
by a focused test batch and clean analysis. Its later ratchet-only failure is
now addressed by exact reviewed approvals; the subsequent two-file
report/enforce rerun passed.
`TonosExpansionTileScope` now centralizes the repeated divider-only, compact,
and dense ExpansionTile recipes across the preset QA and nutrition flows. The
first four-mode run reached the recipe assertions but failed the unrelated
TextTheme preservation assertion against the raw factory theme. The test now
captures MaterialApp's resolved parent; the user-run formatting, analysis, and
five-file focused suite passed (25 tests). A subsequent source review found
that compact/dense variants replaced inherited ListTileThemeData and
IconThemeData; the implementation now changes only density and icon size via
`copyWith`, and the four-mode inheritance regression passed in the follow-up
five-file suite (26 tests). SettingsExpansionSection now uses the standard
divider-only variant without removing its caller-content color/text scope;
its divider integration assertion passed in the latest user-run
`settings_tiles_test.dart` suite. The subsequent user-run inventory/Train/Settings
batch passed all 49 tests, including the four-mode inherited icon and ListTile
contract. The corrected inventory-rationale contract also passed in the earlier
37-test focused batch.
The 2026-09-25 MealPlanAddBar refactor is the latest shared-action adoption:
`TonosSegmentedActionBar` now owns its clipped structure, theme-family shape,
and interaction, while the caller supplies existing nutrition colors plus its
Classic body typography and divider. The shared-primitive and four-mode caller
tests passed in the user's 26-test batch; retain the four-mode action-bar visual
review as a Step 3/9/10/18 closeout item.
The Auto Preset add-method dialog adds six field and three dialog-dropdown
consumers of the shared primitives; source ownership and all four mode recipes
are covered by the 25-test focused run and 796-test full run. Classic keeps its
Material fallback. A device visual check of this specific add-method dialog is
still needed before its appearance is accepted.
The subsequent accessibility follow-up keeps that horizontal layout whenever
measured labels fit the compact segment width and height, and stacks full-width,
wrapping segments only when they do not. Tests cover the unchanged row, moderate
scaling where labels still fit, 2.0 text scale, narrow width, tall labels, and
stacked activation. The production MealPlanAddBar also has a 2.0x text-scale
regression in all four family/brightness modes. Codex ran formatting (zero
changes), targeted analysis (clean), 118 focused tests, and inventory refresh;
the responsive change is automated-verified. Neo Current Metrics and
MealPlanAddBar visual acceptance remain pending.
Current Metrics now uses `TonosSurfaceVariant.panelRaised` for its no-data
message, with a `SizedBox` preserving the previous full-width composition.
Its five-mode batch includes four-mode assertions for the resolved Material
surface, family shape, and available width; Neo visual acceptance is still
needed for this changed surface.
The 2026-09-26 Food Customization slice adds `TonosFormField` for six form
controls, centralizing common decoration while delegating to Flutter's native
`TextFormField`. Its focused tests cover validators, numeric formatters,
controllers, keys, actions, and tap-outside behavior. The subsequent Food
Logging slice moves search and barcode inputs to `TonosField`, and four
quantity/note/tag form inputs to `TonosFormField`, preserving their clear
actions, callbacks, multiline limits, compact padding, text alignment, and
explicit borders. The wrapper, Nutrition behavior/presentation, N5, and
inventory suites passed 40 tests; the full suite passed 797 tests and
repository-wide analysis was clean. Review both routes' affected fields in
Classic/Neo light and dark.
WeightCard's tokenized recipes remain widget-owned: this batch does not force
its completed-set and editable-field behavior through `TonosSurface`, whose
surface contract is not an equivalent replacement. No new shared primitive
adoption is claimed for WeightCard.

Remaining tasks:

1. Reuse existing primitives where they express the production variant correctly.
2. Preserve distinct flat-section, raised-panel, neutral-control, and modal roles.
3. Paint shadows around actual surfaces and reserve their visible footprint.
   Preserve hit targets, semantics, and Classic variants.
4. Share duplicated presentation between fixtures and production; keep data,
   persistence, navigation, and business behavior in the appropriate caller.
5. Add abstractions only for demonstrated repetition, not every individual widget.

Exit: intended consumers share recipes without erasing legitimate differences.

### Step 11. Complete Theme Lab Acceptance

Status: implementation, pilot review, and current N6 device/stress qualification
are accepted for the agreed development scope. Recheck affected pilots only
after a relevant change.

Completed: family/brightness controls, fixtures, media, reset, shared components,
effects/motion controls, and pilot tests. Theme Lab is no longer Classic-only.

Completed: the accepted review covers Theme Lab plus the Train, Workout, User
Information, and Weight Units pilots. It also covered the current route review
that uses those shared presentations.

Conditional maintenance:

1. Revalidate an affected pilot if a later shared presentation change alters it.
2. Qualify large-text, effects, accessibility, reset, and preview parity for a
   newly added fixture or interactive state; do not repeat the accepted matrix.

Exit: pilot acceptance has evidence. This is the same review as N3, not another
independent matrix to complete twice.

### Step 12. Close The Reachable-Surface Migration Ledger

Status: complete for the agreed current development route/state/device scope.
The 21-item visual review and 2026-09-17 qualification are accepted, with the
specified September 24 refinements separately rechecked. Later changes need
focused rechecks; final product-specific recipes and wider-release Step 15
qualification remain separate.

Completed batches cover shell/settings, B1-B6 Train/plans/workouts, catalog and
media, analytics/history/measurements, onboarding, and specialized flows. The
current screen batch adds the reviewed Neo Catalog, Logbook, Progress, Workout
Report, Health Trends, and exercise-detail presentation refinements. Read
historical pending labels in light of the later Q3 accepted scope.

The secondary-surface compatibility extension adds a safe interim theme
boundary for evolving non-default routes. It is intentionally narrower than a
full Neo implementation: it lets these consumers resolve semantic surfaces and
contrast-aware accents now, while leaving final route-specific geometry and
visual recipes for the later product-complete pass.

Earlier source/state ownership contracts and focused behavior coverage support
the route ledger; the later 2026-09-17 user qualification supplies rendered
route/state/device acceptance for the agreed scope. The compatibility wrapper remains an interim boundary for
exercise definitions/history, cardio/stretch, measurements/trends, and
nutrition until final Neo recipes receive product and human review.

Conditional maintenance and explicit deferrals:

1. Keep the route/caller ledger current as new routes or actions are added; the
   accepted unchanged route matrix does not need a blanket re-review.
2. Before removing or exposing the source-only `AppSettingsPage`, verify its
   callers and record evidence; current absence from the traced graph is not a
   deletion decision.
3. Keep final product-specific geometry decisions for the secondary-surface
   compatibility consumers separate from the accepted interim development
   boundary.
4. Flow Methods and Workout Progress Flows nested persistence/editing review is
   explicitly deferred by the user; reopen only when requested.
5. Recheck styling, behavior, accessibility, and device evidence only for an
   affected surface after a later change.

#### Current Neo Visual Review Status (updated 2026-09-17)

The user accepted the full current 21-item Neo visual review as good for now.
This is a route-and-normal-state acceptance record. The separate development
qualification confirmation below now covers the listed loading, error,
destructive, persistence, keyboard, TalkBack, rotation, media, and scanner
checks for the current code; release qualification remains separate.

| Items | Review scope | Status |
| --- | --- | --- |
| 1-5 | Theme Lab; Train; Workout; Optimized Workout Settings; Train2 and preset flows | Manually accepted for the current Neo review scope. |
| 6-8 | Exercise Catalog; Logbook and Session Detail; Progress including Workout Report | Manually accepted for the current Neo review scope. |
| 9-13 | User Information; Weight Units; UI and Appearance; Edit Gym Profile; Database Settings | Manually accepted for the current Neo review scope. |
| 14-16 | Guided Tutorials; Bodypart Rankings; Muscle Rankings | Manually accepted for the current Neo review scope. |
| 17-19 | Volume Boundaries; Anatomy Mapping; Exercise Set Allocation | Manually accepted for the current Neo review scope. |
| 20-21 | Exercise Editor; Flow Methods and Workout Progress Flows | Manually accepted for the current Neo review scope. |

The final observed selector issue was fixed by giving bright Neo dropdown
triggers their field-ink foreground independently from the charcoal popup
menu's foreground. The 63-test verification recorded above covers that change.
Classic remains on its inherited/default selector path.

#### Current Development Qualification Confirmation (2026-09-17)

The user confirmed that every item in the consolidated human/device/N6
qualification checklist passed for the current working tree. This closes the
current development qualification for N5 route states, E2.2 nutrition,
E2.3 settings residue, N6 device/accessibility behavior, Q2 switching and
effects, and the affected Step 17 Classic-parity checks. It also supplies the
human/device input required for E2.4 closeout accounting.

This confirmation is user-reported qualification evidence, not a new terminal
run or a signed release result. Preserve the existing device/build identity
records where applicable, and record any later defect as a focused recheck.
The user accepted the signed Step 15 Android internal candidate and all six
focused device checks on 2026-09-23. The candidate source commit and APK hash are
now linked in the closeout record. This acceptance does not enroll additional
style-ratchet files or resolve wider-release treatment of retained placeholders.

#### Current 12A/N5 Working Ledger (2026-09-16)

This is the first continuation of the reachable-route review. It records source
reachability and current visual ownership; a `pending` disposition still needs
the user-run route, state, or device evidence named in the final column.
The user’s 2026-09-17 qualification confirmation supersedes those pending
dispositions for the current working tree; the table remains as the route/state
ownership map and its final column identifies the checks that were performed.

| Entry point | Reachable destinations and states | Current visual owner | Disposition and evidence |
| --- | --- | --- | --- |
| `ProfilePage` | Account, Training, Data, and deferred Nutrition sections; localized copy; lazy scrolling; profile tutorial | `SettingsPageScaffold`, `SettingsSection`, `SettingsActionTile`, `SettingsStatusBadge` | Shared settings boundary is in place. Canadian French landing coverage is automated; the route remains pending Neo manual state review. |
| `UIAppearanceSettingsPage` | Theme mode, onboarding replay, weight-unit choice, language choice, bottom-tab editor, tutorial overlay | Settings primitives; `TonosChoiceDialog`; `TonosDialogFrame` | UI and Appearance and Weight Units are accepted in the current Neo visual review. Language and overlay state/device qualification remain separate. |
| `UserInformationSettingsPage` | Text fields, date picker, dropdowns, save/error states, keyboard and large-text layout | Settings field helpers and shared save bar | Accepted as a reviewed pilot. Preserve current behavior and Classic geometry; full error/keyboard/device evidence remains N6 work. |
| `TutorialsSettingsPage` | Reset-all action, per-topic reset, expandable tutorial groups, snackbar feedback | Settings sections, expansion sections, info card, tutorial state store | Guided Tutorials is accepted in the current Neo visual review. Expanded/collapsed, reset, localized, effects-off, and reduced-motion evidence remain N6 work. |
| `GymExerciseSettingsPage` | Analytics hub, exit-preference choice, flow tools, rule methods | Settings primitives; `TonosDialogFrame` for exit preference | Flow Methods and Workout Progress Flows are accepted in the current Neo visual review. Exit-dialog persistence and non-happy-path interaction evidence remain separate. |
| `AnalyticsSettingsScreen` | Body-part ranking, muscle ranking, volume boundaries, anatomy mapping, exercise analytics, exercise editor | Settings primitives plus specialized route owners | The ranked, boundary, mapping, allocation, and editor child routes are accepted for current Neo visuals. Individual loading/editing/error/device states remain to be qualified. |
| `MeasurementsTrendsSettingsPage` | Measurement library and `MeasuredItemsPage` | Settings primitives plus D3 health/measurement owners | Reachable; do not redo D3 migration. Empty, populated, edit, delete, and return-state evidence remains pending. |
| `DatabaseSettingsPage` | Import/export, content environment, cache/media maintenance, health refresh, destructive confirmations, result dialogs | Settings primitives plus database/data-service callers; `TonosDialogFrame` for dialogs | Accepted for current Neo visuals. All reachable dialogs inherit the Neo overlay recipe; loading, failure, busy, and destructive states are not yet manually qualified. |
| `DiagnosticsSettingsPage` | Loading, configured/unconfigured diagnostics, event history, test event, shared deletion, failure snackbar | Settings primitives plus `DiagnosticsService` | Reachable; async and failure states need focused route evidence. |
| `NavBarSettingsPage` | Reorder, enable/disable, locked Profile tab, save/cancel | Shared ranking/action/save recipes and `NavBarConfig` | Reachable secondary route; persistence and large-text evidence remain pending. |
| Specialized child routes | `BodyPartRankingScreen`, `MuscleRankingScreen`, `VolumeBoundariesScreen`, `BodyPartMuscleMappingScreen`, `ExerciseAnalyticsScreen`, `ExerciseEditorScreen`, `WorkoutProgressFlowsPage`, `FlowMethodsPage`, and their dialogs/catalog pickers | Local domain widgets with shared settings primitives where adopted; `TonosDialogFrame` at the Database, Flow Methods, and Exercise Editor dialog boundaries | Current Neo visual review accepted. Dialog presentation has a shared Neo boundary in the migrated owners; do not call the routes fully qualified until their empty/loading/editing/error and device states are recorded. |
| `AppSettingsPage` | Legacy database export/import page | Legacy local Material implementation | No current caller was found in the active Profile graph. Keep it in the ledger as an unconfirmed legacy route; do not delete or classify it unreachable without separate evidence. |

#### 12E Theme-Ready Compatibility Extension (2026-09-15)

This extension reduces unowned structural styling on evolving, non-default
routes without claiming that their product designs or final Neo recipes are
complete. It preserves the original Classic recipes through an explicit
`Card` fallback and gives Neo a semantic surface/contrast path.

| Consumer group | Theme-ready coverage | Deferred work |
| --- | --- | --- |
| Exercise definitions and history | `definitions_by_bodypart_page.dart`, `definitions_by_muscle_page.dart`, `exercise_definition_info_tile.dart`, and `full_history_screen.dart` use the compatibility surface; Neo metadata accents use semantic positive color where appropriate. | Current development route/state/device qualification is accepted. Final product-specific route composition and Neo recipes remain a separate design decision. |
| Cardio and stretch | `cardio_card.dart` uses semantic timer states in Neo; `stretch_card.dart` uses a semantic add-action color; both use the compatibility surface. | Current development qualification is accepted. Any broader product-flow expansion and final Neo recipes remain deferred. |
| Current measurements | `current_metrics_section.dart` resolves Neo metric colors through data-visualization roles while Classic keeps its original palette. | Current development route/state/device qualification is accepted; recheck only affected changes. |
| Nutrition surfaces | `nutrition_bar_details.dart`, `default_trend_page.dart`, `food_customization_page.dart`, and `food_logging_page.dart` now have theme-ready foreground, visualization, and surface ownership. | Current nutrition behavior and development qualification are accepted. Retained-placeholder release treatment and any final Neo recipe decisions remain separate. |
| Shared boundary | `theme/widgets/tonos_theme_ready.dart` owns the explicit Classic `Card`/Neo `TonosSurface` split. | Do not enroll every consumer in the style ratchet until its full route scope is reviewed. |

Focused source evidence for this slice remains
[`pre_q2_route_evidence_test.dart`](../test/theme/pre_q2_route_evidence_test.dart),
[`settings_tiles_test.dart`](../test/theme/widgets/settings_tiles_test.dart),
[`tonos_dialog_test.dart`](../test/theme/widgets/tonos_dialog_test.dart),
and [`localized_landing_pages_test.dart`](../test/localization/localized_landing_pages_test.dart).
The advanced-dialog and selector-contrast edits are now user-verified for their
current visual scope. This ledger does not claim a complete 12A or N5 exit: the
remaining gap is focused route-state, reachability, and device evidence, not an
unclassified dialog implementation.

Exit: no unexplained reachable omission in agreed scope. Use this ledger for N5
as well; do not duplicate its route inventory in a new document.

### Step 13. Finish Neo-Brutalism

Status: current N4/N5 route, state, and visual qualification and N6 development
device/accessibility checks are accepted for the agreed scope. Later changes
need focused rechecks; final product-specific recipes for deferred secondary
surfaces remain a separate design decision.

Preserve the approved flat panels, dark ink on bright fills, dark frames, hard
offsets, subtle light/dark palette differences, and restrained neutral borders.
Do not revive global white framing from early inspiration. Preserve the
continuous bottom bar and familiar application layout.

#### N1. Recipe And Gap Audit - Complete

Revision 5 and required role/font/geometry decisions were approved. Later
requested refinements are in the Neo specification. No new redesign is needed.

#### N2. Shared Extensions - Complete

Capabilities and Classic defaults are implemented and verified. Maintain them
through Steps 7/10 instead of restarting the initial extension project.

#### N3. Family And Preview - Implemented; Reviewed Pilots Accepted

Neo has registered light/dark definitions and development selection. Scoped
tests and Theme Lab smoke review passed. The current rendered pilots and
stress/effects states are included in the accepted Step 11/N6 scope. New pilots
still require their own rendered evidence. Exit: complete definitions, intact
gating, and approved rendered previews.

#### N4. Real Routes - Current Reviewed Pilot Refinements Accepted

Original phone acceptance covers state/persistence, both modes, and 1.15/2.0
scales. Later changes include shared dialogs/completion, foreground/contrast,
readable Progress/report content, Classic restoration, and Train header fixes.

Current device checks:

- Weekly Overview retains normal-scale side-by-side composition in both themes;
  high-scale reflow remains available when genuinely needed.
- Floating debug buttons do not reserve a black band or move app content.
- The compact Overview/Plans frame, bottom edge, and shadow remain fully visible.
- The selector uses the smaller card offset; raised panels retain their own
  depth. The latest 51-test pass covers the selector shadow refinement.
- Classic retains ordinary density and styling while long values, names,
  editing, and removal remain usable.

Exit: affected current surfaces pass the correction matrix. Preserve accepted
historical results for unaffected behavior.

#### N5. Current 21-Item Visual Review And Route-State Qualification Accepted

The current visual review is complete for all 21 agreed Neo entries, including
the specialized Profile/settings routes. Many routes beyond the original pilots
have received refinements. The user has now confirmed the route-state and
non-happy-path qualification for the current working tree; later changes need
only focused rechecks.

The theme-ready secondary-surface extension remains an interim adoption step
inside this sweep. It closes a compatibility gap but does not by itself close
the final Neo design decision for evolving product areas.

Exit: each in-scope surface has a disposition and evidence; no unexplained gaps.

The new N5 state-owner contract covers loading, empty, error, editing,
destructive, media, workout-completion, history, progress, nutrition, scanner,
and settings categories. It proves that each category has a concrete source
owner only; rendered state, interaction, accessibility, device, and
performance qualification are separately recorded and user-accepted for the
current development scope.

#### N6. Qualification/Handoff - Current Development Acceptance Recorded

Automated runs, original phone checks, the 21-item visual acceptance, and the
latest 63-test selector-contrast verification exist. The user has confirmed
the current light/dark, localization, large text, TalkBack, keyboard, rotation,
overlays, live switching, restart, effects-off, reduced-motion, scanner/media,
and performance checks. Link any later limitation to the affected route and
reopen only that scope without bypassing release gating.

Exit: development qualification is recorded, ready for Step 14. Step 14
implementation is recorded below; public release approval is still a separate
Step 15 decision.

### Step 14. Deliver The Public Family Selector

Status: implemented, automated-verified, and included in the current
human/device qualification; Neo remains non-release eligible.

Implementation requirements (complete; retained as the selector contract):

1. Add a localized real Appearance setting using existing provider/preferences
   and centrally filtered eligible families.
2. Keep family independent of light/dark/system brightness.
3. Expose accessible labels/selection and support keyboard operation.
4. Preserve app state and represent save failure/retry truthfully.
5. Test restart, unavailable values, downgrade, and bundled offline rendering.
6. Keep actual release enrollment subject to Step 15's decision; implementation
   of the setting does not require exposing an unfinished family publicly.

Implementation record (2026-09-16):

- `UIAppearanceSettingsPage` now exposes a real localized theme-family setting
  with a compact current-brightness preview when the centralized capability
  policy provides more than Classic.
- `TonosChoiceDialog` supplies the selected radio state, accessible labels,
  focusable activation and keyboard activation without changing the existing
  Weight Units dialog contract.
- `ThemeProvider.setFamily` remains the only mutation path, preserving the
  current brightness, route state and failed-write behavior. Failed writes
  keep the previous family and show a localized retry action.
- The selector test covers eligible selection, brightness independence,
  failed-save retry, Classic-only hiding, restart, downgrade fallback and all
  bundled locales. The user's current development qualification supplies the
  corresponding human/device evidence.
- Step 14 did not change release capabilities. The later Step 15 opt-in now
  permits Neo in explicitly enabled internal release candidates.

Implementation and current development qualification exit: met in source,
focused coverage, user-run automated verification, and the user's consolidated
human visual/accessibility/device confirmation. The Step 15 release decision
remains separate.
Debug buttons do not count as the public selector.

### Step 15. Qualify Themes For Release

Status: Android internal/closed candidate, six focused device checks, and
source/hash association complete. Source commit `eae77c321a7acd7ec66a77f634eec08d009d727c`
is linked to APK SHA-256 `549BE2C9EDD96E44840C7E42976BDF436C29B3F53DC9C946FA043EB3EC68615D`.
Open testing and Play Store release remain out of scope.

Candidate built 2026-09-22; accepted 2026-09-23; source commit associated:

- Source baseline: `55b0222` on `updates/backlog`, committed and pushed after
  verification of the development media and debug APK. The release opt-in
  changes are a subsequent working-tree patch; all checks below passed. The
  exact tested source is committed as `eae77c321a7acd7ec66a77f634eec08d009d727c`
  and associated with the accepted APK hash. `incoming/` and
  `tmp/` are excluded from the candidate.
- Platform decision (user, 2026-09-22): Android is the current target for
  internal and closed testing, not open testing or a Play Store release. iOS
  and web are future targets; Windows, Linux, and macOS remain out of scope.
- The app declares `bn`, `en`, `es`, `fr`, `fr_CA`, `hi`, and `zh`.
  The user intends to keep all seven locales and accepts the current
  translations for the planned Android release. Native-speaker review has not
  occurred; the user accepts that as a release limitation, with review
  potentially following later. Do not describe it as native-speaker signoff.
- Family decision (user, 2026-09-22): the Android release target is Classic
  plus Neo, with Classic remaining the default and Neo selectable in both
  light and dark modes. This scope is accepted for Android internal/closed
  testing only, not open testing or a Play Store release.
- The user authorized implementing Neo release eligibility for internal testing.
  `TONOS_ENABLE_NEO_RELEASE=true` now opts a release build into Classic and
  Neo. Classic remains the default. The experimental-theme flag only controls
  non-release builds. A missing/false release opt-in retains Classic fallback;
  malformed values are rejected. Internal CI and the candidate script explicitly
  enable Neo; the production release workflow retains its default Classic policy.
- User-reported toolchain: Flutter 3.29.3 and Dart 3.7.2. The repository
  debug baseline was verified as `1.0.1+5`; the new internal release candidate
  uses `1.0.1+6`. Confirm the signed APK and installed version before accepting
  the candidate. Play Console version-code
  checks and protected release signing are later Play Store gates; never place
  signing secrets in the repository or terminal transcript.
- Exercise media for internal testing can use the existing development manifest
  v15 with 253/300 thumbnails (84.3%). The user-supplied remote check passed for
  all 253 assets and confirmed a zero-difference canonical manifest. Keep the
  47 missing entries on the heatmap fallback. No production-bucket
  promotion is required for this internal/closed test. Production is still
  documented at v5/62 assets and uses a temporary `r2.dev` URL. Before any
  production-targeted Android release with the new thumbnails, promote and
  validate the complete canonical media/manifest and clean-install sync. See
  [production content setup](content-production-setup.md) and the
  [cloud-content roadmap](cloud-content-roadmap.md).

Internal candidate closeout:

1. Run `scripts/verify_neo_release.ps1`: focused policy/selector/persistence/
   renderer/workflow tests, real compile-time flag cases, signed release build,
   signature/manifest inspection, and an APK SHA-256 evidence record. The APK
   uses `com.tonos.internal` so it can coexist with a debug-signed install.
2. Install the APK and complete the focused release checklist in
   [Testing Tonos](testing.md#neo-internal-android-release-candidate). Reuse
   previously accepted N5/N6, locale, route, and visual evidence for unchanged
   surfaces; no repeat of the 21-item development checklist is required.
3. The user accepted this signed internal candidate on 2026-09-23; all six
   device checks passed, as recorded in [Testing Tonos](testing.md#neo-internal-android-release-candidate). The
   installed APK is `com.tonos.internal` `1.0.1+6`, SHA-256
   `549BE2C9EDD96E44840C7E42976BDF436C29B3F53DC9C946FA043EB3EC68615D`. The
   exact tested application/build/test source is committed as
   `eae77c321a7acd7ec66a77f634eec08d009d727c` and associated with this APK hash.
   The working tree was based on `55b0222071645392e1c66d5e01c5f8b3eaf10f11`;
   the acceptance documentation was added after the APK build and does not
   change app/build source.

The 47 heatmap fallbacks, owner-accepted translations, and retained placeholder
routes remain the existing internal-test limitations. Experimental navigation
tabs stay release-gated. Native-speaker review and production content promotion
remain outside this internal candidate's closeout.

Broader release qualification reference:

1. Identify candidate/source state, SDK/build configuration, supported platforms,
   locales, and proposed eligible families.
2. Obtain relevant automated verification through user-supplied terminal output;
   record scope and failures individually.
3. Review representative routes and loading/error/form/overlay/media/workout
   states for every released family and brightness variant.
4. Complete physical accessibility, narrow/large viewports, rotation, keyboard,
   TalkBack, long-label/RTL where supported, and high-text-scale checks.
5. Verify startup/restart, save failures, missing/corrupt settings, upgrades,
   downgrades, eligibility, and fallback.
6. Check scrolling/transitions, reduced motion, effects disabled, and actual
   performance concerns on supported hardware.
7. Record release blockers, accepted limitations, and the explicit user decision
   before approving wider distribution.

Internal exit: the identified signed candidate and both families have explicit
user acceptance for Android internal/closed testing. This does not approve open
testing or a Play Store launch.

### Step 16. Add Later Families

Status: not started; defer until current family qualification.

Select a family through a separate product/design decision. Reuse stable
preferences, capability policy, tokens, primitives, Theme Lab, and qualification.
Design both modes together and preserve Classic/Neo. Expressive in old phase
tables is future-family guidance, not the active first alternate family.

Exit: separately requested family work is implemented and qualified. There is
no present obligation to implement every speculative family in the old plan.

### Step 17. Close Current Review Findings

Status: current affected development state/parity scope accepted on 2026-09-24;
reopen only for a later reproduced defect or an affected code change.

Completed work includes persistence fixes, consumer tests, contrast/focus,
responsive content, localized removal, shared presentation, Classic restoration,
and focused Classic-parity contracts for the changed health-delta and
compatibility-boundary behavior. The user also accepted the Classic-light
completed-workout palette refinement: card and set-row fills are swapped, the
status ink remains contrast-qualified, and the focused format, analysis, and
15-test workout suite passed on 2026-09-24.

Conditional defect-handling protocol:

1. Reconcile old issues with current source and tests before carrying them forward;
   a historical line number is not current proof of a defect.
2. Complete affected visual/device checks through Steps 2/11 and N4.
3. Record unresolved defects with route, reproduction, expected/actual result,
   family/state, owner, and evidence.
4. Fix reproduced problems and rerun the affected scope.
5. Close findings with evidence or explicit accepted limitations, keeping pending
   manual checks visible.

Exit: the current reviewed scope has no outstanding correction-pass review.
If a new defect is reproduced, record and qualify that affected scope; source
tests alone do not close visual acceptance.

### Step 18. Finish Enforcement And Shared-System Qualification

Status: partial. Latest inventory scan on 2026-09-26 covers 278 Dart files /
2,286 candidates (92 allowlisted, 1,568 migrated, 626 pending), with 1,013
uniquely queued, 1,273 outside queues, zero overlaps, and zero pending findings
without a queue. Repository-wide Dart analysis and the full 797-test Flutter
suite passed after the WeightCard hint/suffix restoration. After the inventory-
only TrainTabs ownership update, focused tabs/inventory tests and inventory
`--check` passed. Those inventory/test updates do not affect the three approved
ratchet scopes; report/enforce passes for those exact scopes. An earlier
full-suite run found one stale N5 assertion;
the contract was corrected, then the subsequent full suite passed. A report-only TonosDialog probe
found 18 distinct fingerprints and was not enrolled without statement-by-
statement review. Separately, Current Metrics retains five category-color
allowlists plus one circular-marker allowlist and has no pending finding in
that widget. Its empty panel uses TonosSurface with four-mode
color/shape/width/foreground assertions. Train's
profile avatar contrast role is also four-mode tested; Train now has zero
pending findings after the seven action/avatar candidates were migrated.
WeightCard now has zero pending findings after 23
token-backed recipes and three popup/input text-style findings were qualified;
the hint/suffix styles are restored through semantic workout ink, with the hint
opacity provided by its dedicated token.
WorkoutDashboard's eight and DataRecordsSection's four existing D2-owned
findings now have exact inventory rules and count-pinned contracts.
`PresetsLoaded`'s six scoped findings now have a four-mode rendered contract and
an exact inventory rule. Neo Current Metrics, MealPlanAddBar, the Auto Preset
add-method dialog, and Nutrition form visual acceptance remain open. Nested
flow-state review is explicitly deferred;
broader per-file evidence and enrollment remain limited.

Verified follow-up after that source checkpoint: the shared segmented action
bar reflows only when measured labels exceed the compact segment width or
height. Regression tests cover the standard row, moderate scaling where labels
fit, 2.0x scaling, narrow width, tall labels, and activation after stacking.
The production MealPlanAddBar is covered at 2.0x in all four theme modes.
Codex ran format, analysis, the 118-test focused batch, and inventory refresh
successfully. Human visual acceptance for MealPlanAddBar and Neo Current Metrics
remains pending.

The user-run Classic-light workout completion palette check also passed
formatting, targeted analysis, and 15 workout tests after visual acceptance.
That verified its focused surface; Train and WeightCard were subsequently
accepted in all four modes. The 2026-09-25 inventory refresh is recorded above.

Historical broad verification (2026-09-22): formatting 135 files with 0
changes, clean analysis, 321 theme tests, 6 responsive tests, 46 route-boundary
tests, and the then-current one-file enforce-mode ratchet passed. Badge
enrollment later expanded the manifest to two production files, and its
post-enrollment report and enforcement passed on 2026-09-23 before the current
`TonosSurfaceTheme` edit. The later two-file TonosSurfaceTheme report/enforce
passed before ExpansionTile was enrolled as the third scope.
The exact badge inventory rule and five-scope ExpansionTile extraction were
included in an interim 2,288-candidate inventory check; the subsequent
2,294-candidate and then-current 2,293-candidate reports superseded it at later
checkpoints. Those reports were later superseded by the 2,297-candidate scan,
which was superseded at that checkpoint by the 2,307-candidate pre-refactor
baseline; the 2,299-candidate scan was a later checkpoint, superseded by the
previous 2,303-candidate scan, itself superseded by the 2,301-candidate
checkpoint; the current 2,295-candidate scan is recorded above.
The corrected
inventory-contract/widget batch for the prior tested source first passed 25
tests, then the inherited-style correction and its regression passed the
follow-up 26-test suite. The pre-follow-up inventory/ratchet/CLI/ExpansionTile
batch passed 22 tests. Formatting and analysis were clean for its listed
inputs. The canonical three-file manifest and CLI contract test were edited
afterward; rerun focused formatting, analysis, tests, and ratchet report/enforce.
The earlier two-file pass qualifies only its earlier source state.

The user then ran report mode for the ExpansionTile candidate; its three
count-1 fingerprints were mapped to the exact Theme lookup, Theme wrapper, and
transparent divider override and added to the canonical manifest. The focused
inventory/ratchet/CLI/ExpansionTile suite passed all 22 tests before the final
canonical-manifest and CLI-contract edits. Subsequent tests and the current three-scope report/enforce passed. The user then ran targeted analysis twice after the chart import removals; both runs reported no issues. The later health/history helper adoption passed four-file formatting/analysis, six focused suites (23 tests), and the refreshed inventory; it did not alter the three protected ratchet files. The dialog-surface fix passed formatting and analysis; its corrected captured-menu-theme assertion and date/time picker route checks passed in the user's 38-test focused run. The user accepted the Health Trends and selected-period history visuals. The 2026-09-26 inventory scan below includes the later MealPlanAddBar, WeightCard, and TrainTabs changes; the ratchet manifest and protected sources remain unchanged.

Remaining and conditional work:

1. The three-scope report/enforce passed on 2026-09-26; no protected file or
   ratchet manifest changed. Rerun it after future protected-file or manifest
   changes; do not broaden enrollment without per-file ownership and
   qualification evidence. The latest inventory refresh includes Current
   Metrics, Train, MealPlanAddBar, WeightCard, and exact TrainTabs ownership;
   refresh after later inventory-relevant source changes.
2. Audit actual typography, local themes, motion, and effects consumers found
   in the route sweep while preserving legitimate variants/framework defaults.
3. Verify production consumption of roles; avoid class-name-presence checks or
   property tests that never exercise rendered output.
4. Cover changed focus/activation, disabled precedence, independent selection
   and removal, localized values, and content reachability.
5. Recheck affected physical behavior after edits, retaining the historical Q3
   acceptance and its explicit limitations.

Exit: each protected source state passes report/enforce and relevant focused
qualification before it is called current and qualified. Historical passes
remain tied to their tested source state; three protected scopes are not global
coverage.

### Step 19. Preserve The Q3 Readiness Decision

Status: complete for agreed scope, 2026-09-11.

The 226-test result and manual acceptance authorized Neo development with
recorded limitations. Keep this historical decision intact. Do not describe the
initial gate as unstarted or repeat its initial approval process.

Remaining responsibility: qualify later changes through Steps 17/18 and N6;
wider/open release remains a separate Step 15 scope.

## Next Execution Order

Immediate follow-up: review the Nutrition Dashboard action bar in Classic and
Neo, light and dark. Formatting, analysis, 26 focused tests, and the refreshed
inventory have passed; complete the visual signoff before marking this slice
qualified.

1. The corrected TonosDialog route check, formatter, analyzer, and nine-file
   focused suite are now passing; inventory check/report and three-scope ratchet
   report/enforce also passed after the library change. Rerun those checks only
   if their source scope changes. Health Trends and selected-period history
   visuals are accepted, so do not repeat those checks unless affected.
2. For one selected slice, complete Step 9 local Material/theme ownership and
   Step 10 primitive adoption. In the shared settings slice, validation colors
   now resolve the Material error role against the bright field; the regression
   requires 4.5:1 against both field and containing section in both Neo modes.
   The exercise-history
   estimated-1RM series keeps `AppProgressColors.estimatedOneRm` as its Classic
   fallback, while both chart series now resolve against Neo's bright chart
   surface. The earlier 120-test batch, including the contrast tests, passed
   before the exact badge-rule and ExpansionTile-scope follow-up. The prior
   Pixel 7 screenshot covers an earlier chart recipe; the user accepted the
   current Exercise Progress chart on 2026-09-24. The user confirmed the
   Measurement Trends graph visuals in all four Classic/Neo modes on 2026-09-23.
   The user identified the workout-detail
   26-pixel overflows in
   rep-best/volume-best badges; `WorkoutRecordBadgeStack` now shrink-wraps them.
   The follow-up passed analysis and all 16 focused tests, refreshed the report,
   and the Pixel 7 screenshot confirms no overflow. This closes that focused
   Step 10 issue, not all primitive adoption. Continue only after reviewing
   each remaining finding. An earlier follow-up used the existing
   workoutIncrease/workoutDecrease roles directly and passed its focused tests.
   Review later found those luminous Neo dark-mode values had inadequate
   contrast on the bright Workout Report stat tiles. Trend text now resolves
   positive, negative, and neutral colors against its actual tile surface; the
   integration test covers all three directions on selected lavender and
   unselected yellow tiles in all four theme modes and passed in the supplied 27-test chart/theme batch. The analyzer then found two unused imports; they were removed, and the user subsequently ran targeted analysis twice with no issues.
   The shared-settings disabled foreground rule now has one implementation for
   text and dropdown icons; the user-run format and analysis passed and all 34
   settings, residue-contract, and route-ledger tests passed. The regenerated
   report removed two duplicate pending transforms without changing the 16
   pending local Theme count. The latest TonosSurfaceTheme extraction was
   formatted (two files changed), analyzed cleanly, and included in an initial
   46-test pass. A later focused suite passed 44 tests and failed the production
   ratchet contract on three new fingerprints. Those statements were exactly
   reviewed and approved before the then-current two-file report/enforce
   pass; the current three-scope rerun passed. The
   Flow Methods and Workout Progress Flows appearance was accepted on
   2026-09-24 after the dropdown contrast correction. The user also accepted
   the Exercise Progress chart and the Preset Generation QA / Food
   Customization ExpansionTiles. The Neo-dark settings validation-error
   correction passed formatting, analysis, and 32 focused tests; its device
   appearance was accepted by the user, and nested flow-state review is deferred.
   Add further Step 7 roles only for evidenced, repeated semantics.
   Preserve Classic variants, states, semantics, and behavior.
3. Mark inventory scope migrated only when every finding in that exact scope
   has a reviewed owner and destination or a justified exception. Keep
   unresolved findings pending.
4. Consider ratchet enrollment one exact production file at a time, only after
   current inventory output, lexer eligibility, Classic parity, rendered/state
   coverage, and ownership evidence are reviewed. The canonical manifest now
    lists TonosSurface, workout-record badges, and the ExpansionTile scope with
    exact reviewed fingerprints; never regenerate approvals automatically. The
    badge file's six inventory findings are all classified as migrated by the
    2026-09-25 scan. Its rendered Classic/Neo light/dark badge-token test passed
    user verification on 2026-09-23, and the user confirmed that workout-detail
    badges no longer overflow. The current
    three-scope report/enforce passed on 2026-09-24 with matching approvals.
    This does not classify findings as migrated or close broader styling debt.
5. Step 2's matched Classic comparisons are user-confirmed complete for the
   documented affected restorations on 2026-09-24. The accepted 21-item Neo
   review remains separate evidence; repeat Classic comparisons only when a
   later change affects those surfaces.
6. Keep placeholder disposition, optional final Neo recipes, wider-release
   scope, and production media promotion as separate decisions. Defer Step 16.

## Verification And Future Updates

- Follow AGENTS.md for command permissions. Codex may run relevant Dart/Flutter
  formatting, analysis, and tests; avoid dependency installation, device runs,
  and release builds unless the task requires them.
- If a verification command fails or stalls, report the exact command and
  output before asking the user to run it. Avoid undefined reviewSources or
  reviewTests variables when preparing a user verification session.
- Record actual scope, source identity, and result. Check native command exit
  codes independently so a later success cannot hide a failure.
- Broaden reruns when subsequent changes justify them; documentation-only edits
  do not require Flutter tests.
- After acceptance, update affected statuses here and link existing evidence.
  Create another document only for a distinct purpose the owners above cannot hold.
