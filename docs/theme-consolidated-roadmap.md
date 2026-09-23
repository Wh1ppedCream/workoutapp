# Consolidated Theming Roadmap

Updated: 2026-09-23.

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
| 2 | Visual/behavioral baseline | Reviewed current Classic restorations accepted for affected surfaces; matched evidence remains |
| 3 | Inventory/classification | Inventory and scoped ratchet implemented; broader qualification partial |
| 4 | Classic extraction | Implemented and accepted for Q3; recheck affected parity after refinements |
| 5 | Selection/preferences | Implemented; original persistence/switching accepted; revalidate relevant changes |
| 6 | Availability policy | Internal Neo opt-in and accepted candidate source `eae77c321a7acd7ec66a77f634eec08d009d727c` linked to the APK hash |
| 7 | Focused tokens | Foundation complete; adoption follows route work |
| 8 | AppColors retirement | Complete |
| 9 | Material ownership | Foundation implemented; local override audit remains |
| 10 | Tonos primitives | Implemented; adoption and coverage remain |
| 11 | Theme Lab | Classic/Neo pilot implementation and automatable coverage complete; current visual review and current development device/stress qualification accepted |
| 12 | Surface migration | Current 21-item Neo visual route review and current route/state/device qualification accepted; route ledger remains the source of truth |
| 13 | Neo-Brutalism | N1/N2 complete, N3 implementation/automatable coverage complete, N4 and the current 21-item visual review accepted; current N5 route-state and N6 development qualification accepted |
| 14 | Public selector | Implemented and accepted; Neo is selectable in the accepted Android internal candidate, with Classic as default |
| 15 | Release qualification | Android internal/closed candidate accepted and source-linked; open/Play release is out of scope |
| 16 | Later families | Not started |
| 17 | Review closure/parity | Original Q3, the current 21-item Neo visual review, and the current affected state/parity checks accepted; later changes require focused rechecks |
| 18 | Enforcement/qualification | Current scoped work and development qualification accepted; broader per-file evidence and ratchet enrollment remain intentionally limited |
| 19 | Development readiness | Complete for agreed Q3 scope, 2026-09-11 |

Steps 17-19 were inserted as prerequisites, so numerical order is not execution
order. Step 19 already authorized Step 13. Older statements that the initial
readiness gate is unstarted or that preference write ordering needs initial
implementation are superseded.

## Verification Already Reported

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

Status: original manual baseline and affected current restorations accepted;
matched post-refinement comparisons remain.

Completed: the accepted 16-image set at 1.15, reference conditions, behavioral
results, and classification of the correction pass's Classic-visible changes.

Remaining tasks:

1. Record build/worktree identity, device/OS, logical viewport, density, locale,
   display/font scales, fixture data, and input setup in the evidence record.
2. Capture matched Classic light/dark states for Weekly Overview, Train sections
   and actions, settings, Progress selectors, Workout Report, completion, and
   record badges after the restoration changes.
3. Compare at the accepted 1.15 scale with equivalent data/state. Add 2.0 checks
   for accessibility reflow; different scales/data are not parity comparisons.
4. Record expected accessibility differences and investigate unexpected changes.
5. Link each result and resolve regressions before accepting the affected surface.

Exit: all affected comparisons have results and evidence. The accepted original
set need not be recreated wholesale. Automated goldens are a separate choice
for stable surfaces, not a requirement to invent new baseline approval.

### Step 3. Finish Style Classification And Qualified Coverage

Status: inventory and scoped enforcement implemented; broader work partial.

Completed: machine-readable inventory, scanner, validation tests, and enforcement
for an exact qualified scope. Assigned inventory entries are not all approved.

Remaining tasks:

1. Reconcile current reachable routes and changed files with inventory entries.
2. Classify styling as Material, semantic token, shared recipe, data/media, or a
   documented exception. Record why fixed identity/illustration colors stay fixed.
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

### Step 8. Keep AppColors Retired

Status: complete.

Completed: legacy extension/accessors and production consumers were removed.
Maintain the zero-consumer contract. Do not recreate a compatibility bridge.

Exit: no legacy production usage is reintroduced.

### Step 9. Complete Material Ownership Review

Status: shared boundary implemented; local override audit remains.

Completed: Material ownership and Neo component recipes are centralized.

Remaining tasks:

1. Inspect local Theme subtrees and per-control overrides found in Step 12/N5.
2. Preserve valid Classic defaults and distinct variants; remove redundant
   overrides only after confirming their resolved output.
3. Move duplicated structural styling into its owning recipe or theme.
4. Check rendered selected/pressed/focused/disabled/busy/error/destructive states.
   Disabled must take precedence over focused styling and activation.
5. Recheck semantics, targets, focus order, and activation on changed controls.

Exit: local exceptions are justified and ordinary controls inherit correctly.

### Step 10. Complete Shared Primitive Adoption

Status: primitives implemented; production adoption remains route-dependent.

Completed: shared surfaces, actions/depth, fields, sheets/dialogs, navigation,
and workout presentation with focused coverage.

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

Status: Classic/Neo implementation and automatable pilot coverage are present;
the current Theme Lab review is accepted. Device and stress qualification remain
with N6.

Completed: family/brightness controls, fixtures, media, reset, shared components,
effects/motion controls, and pilot tests. Theme Lab is no longer Classic-only.

Completed: the accepted review covers Theme Lab plus the Train, Workout, User
Information, and Weight Units pilots. It also covered the current route review
that uses those shared presentations.

Remaining tasks:

1. Revalidate an affected pilot if a later shared presentation change alters it.
2. Record device-specific large-text, effects-off, reduced-motion, and
   accessibility results through N6 rather than repeating ordinary visual review.
3. Confirm reset, preference isolation, and production/preview parity for any
   newly added fixture or interactive state.

Exit: pilot acceptance has evidence. This is the same review as N3, not another
independent matrix to complete twice.

### Step 12. Close The Reachable-Surface Migration Ledger

Status: the current 21-item visual review and the 2026-09-17 development
route/state/device qualification are accepted. Later changes need focused
rechecks; separate product/design decisions and wider-release Step 15 qualification remain.

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

The current pass adds source/state ownership contracts and focused behavior
coverage for the remaining non-human gaps, but does not claim rendered route
qualification. The compatibility wrapper remains an interim boundary for
exercise definitions/history, cardio/stretch, measurements/trends, and
nutrition until final Neo recipes receive product and human review.

Remaining tasks:

1. Enumerate actual reachable navigation, secondary actions, legacy callers,
   dialogs, and sheets. A route name alone does not prove coverage.
2. 12A: review app chrome, Profile/settings sections, fields, menus, and overlays.
3. 12B: review plan creation/editing/generation, sets/rest/swapping, completion,
   saved history, and loading/failure states.
4. 12C: review search/filter/results, detail tabs/records, media fallback and zoom.
5. 12D: review calendar/ranges, charts/legends, selectors, insight tiles,
   measurements, and empty states.
6. 12E: review onboarding/tutorials, nutrition, scanner/permissions, database
   settings, and other reachable specialized flows. Treat the new theme-ready
   wrappers as an interim boundary, not final Neo approval.
7. For each surface record migrated, intentionally retained with reason,
   unreachable with evidence, or deferred with owner/impact. Link verification.
8. Correct unexplained styling leakage while preserving accepted layout and data.

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

Status: advanced development implementation; N4 and the current 21-item Neo
visual review are accepted, while the route-state sweep and qualification remain
below.

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
tests and Theme Lab smoke review passed. Finish Step 11's final rendered pilots,
stress/effects states, and discrepancy fixes. Exit: complete definitions,
intact gating, and approved rendered previews.

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

Status: current affected development state/parity scope accepted on 2026-09-17;
reopen only for a later reproduced defect or an affected code change.

Completed work includes persistence fixes, consumer tests, contrast/focus,
responsive content, localized removal, shared presentation, Classic restoration,
and focused Classic-parity contracts for the changed health-delta and
compatibility-boundary behavior.

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

Status: scoped ratchet and Q2 work are verified/accepted; current development
qualification is accepted. The corrected verifier scope passed on 2026-09-22;
broader per-file evidence and enrollment remain intentionally limited.

Latest verification (2026-09-22): formatting 135 files with 0 changes, clean
analysis, 321 theme tests, 6 responsive tests, 46 route-boundary tests, and
enforce-mode ratchet passed. The ratchet still protects one production file.

Remaining and conditional work:

1. Expand enforcement only from Step 3's reviewed inventory and qualified files.
2. Audit actual typography, local themes, motion, and effects consumers found
   in the route sweep while preserving legitimate variants/framework defaults.
3. Verify production consumption of roles; avoid class-name-presence checks or
   property tests that never exercise rendered output.
4. Cover changed focus/activation, disabled precedence, independent selection
   and removal, localized values, and content reachability.
5. Recheck affected physical behavior after edits, retaining the historical Q3
   acceptance and its explicit limitations.

Exit: the current scope remains qualified and protected; any future enrollment
has per-file evidence and appropriate automated/manual qualification. One
protected scope is not global coverage.

### Step 19. Preserve The Q3 Readiness Decision

Status: complete for agreed scope, 2026-09-11.

The 226-test result and manual acceptance authorized Neo development with
recorded limitations. Keep this historical decision intact. Do not describe the
initial gate as unstarted or repeat its initial approval process.

Remaining responsibility: qualify later changes through Steps 17/18 and N6;
public selection/release stay in Steps 14/15.

## Next Execution Order

1. Prepare Step 15's release-candidate scope and explicit decision record.
2. Expand qualified style-ratchet enforcement only for surfaces with complete
   per-file evidence; do not use the ratchet as a substitute for route/state
   review.
3. Fix only later reproduced issues, rerun the affected automated scope, and
   perform a focused device recheck. Defer Step 16.

## Verification And Future Updates

- Follow AGENTS.md: Codex does not run Dart/Flutter format, analyze, tests,
  dependency installation, run, or build commands.
- Give exact user commands for the changed sources/tests. Avoid undefined
  reviewSources/reviewTests variables when starting a new verification session.
- Record actual scope, source identity, and result. Check native command exit
  codes independently so a later success cannot hide a failure.
- Broaden reruns when subsequent changes justify them; documentation-only edits
  do not require Flutter tests.
- After acceptance, update affected statuses here and link existing evidence.
  Create another document only for a distinct purpose the owners above cannot hold.
