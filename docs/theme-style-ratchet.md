# Theme Style Ratchet

Status: eighteen exact production scopes are listed for enforcement. The current
manifest contains 158 approval entries (154 unique fingerprint hashes) and 180
approved occurrences, all mapped in the manifest. The 2026-10-02 read-only
ratchet report and enforcement both passed for all 18 scopes. The latest full
verification on 2026-09-27 passed all 1,137 Flutter tests (exit 0), repository-wide
`dart analyze`, inventory `--check` (279 Dart files / 2,239 candidates;
130 allowlisted, 2,109 migrated/classified, zero pending), and detailed
report/enforcement for all 18 scopes. Final onboarding qualification used
existing owners and narrow inventory rules, not ratchet enrollment. No scope,
approval, or manifest bytes changed in that pass; zero pending is not an
enrollment gate. Human visual acceptance remains separate in the consolidated
roadmap. The Exercise Catalog ownership follow-up likewise did not add a
ratchet scope. The preceding 1,072-test/2,259-candidate and 940-test checkpoints
are historical. The 940-test checkpoint followed the Exercise
Detail/Preset Generation ownership update. Those inventory contracts did not
add ratchet scopes because broader file/device qualification remains open.
The prior 15-scope checkpoint
had 110 approval entries and 118 occurrences; CardioCard adds four entries/six
occurrences, and StretchCard adds three entries/four occurrences. The previous
full Flutter suite passed 907 tests. The latest review follow-up passed
formatting, targeted analysis, the focused widget/inventory/ratchet batch,
inventory `--check`, and 17-scope report/enforce. The user subsequently
accepted the updated Neo BodyPartFocusChips appearance; automated lexical
protection and widget contracts remain distinct from that visual acceptance.

Earlier ValueCard detailed-report follow-up added statement context to report
mode and mapped all five fingerprints to exact lexical scopes/statements. Its
four-mode contract covers the token border, caller override, scaled shape, and
inherited typography. That contract's visual acceptance is tracked separately
from its lexical protection.
The subsequent review fixed a delimiter-matching edge case when a nested
interpolated string contains a quoted closing brace. The scanner now recursively
skips nested interpolation expressions while finding quoted-string boundaries;
the regression verifies both candidate discovery and change-sensitive
fingerprints. Repository-wide analysis, inventory `--check`, the full
850-test suite, and eleven-scope report/enforce pass with the then-current
manifest approvals unchanged.
On 2026-09-24, the focused inventory/ratchet/CLI/settings/ExpansionTile suite
passed all 52 tests with clean analysis; formatting changed three targeted test
files. The then-current three-scope report/enforce output matched all approved
fingerprints. This is scoped protection, not full repository styling
qualification.
On 2026-09-25, after the final Current Metrics caller-side
`TonosSurfaceTheme`/`Builder` foreground-scope edit passed targeted
format/analyze/tests and inventory refresh, both report and enforce again
matched the existing three protected scopes. The manifest and enrolled files
did not change; no scope was expanded at that checkpoint. In the subsequent
TonosTrainTabs follow-up, it was reviewed and enrolled as the fourth exact
scope. The updated manifest report and enforcement each matched four protected
files; formatting reported no changes, targeted analysis was clean, and the
focused selector/inventory/ratchet/CLI suite passed all 38 tests.
On 2026-09-25, `TonosBottomNavigationBar` became the fifth exact production
scope. Its four-mode widget tests cover Classic's unchanged Material fallback and
Neo's token-owned rail, including the approved 4px underline geometry. The
eight fingerprints were mapped statement-by-statement and pinned in the
manifest/CLI contract. Formatting made no changes, repository-wide analysis
passed, all 803 Flutter tests passed, the inventory check remained at 2,286
candidates, and report/enforce passed for all five scopes.

2026-09-26 completion-surface qualification added a four-mode rendered contract
and an exact inventory rule for `session_complete_sheet.dart`, but did not
expand the ratchet. That source contains interpolated strings, which the current
fail-closed lexer explicitly rejects pending parser support. The five existing
scopes at that checkpoint continued to pass report/enforce; inventory classification and rendered
tests are not substitutes for lexical protection.

## Step 18 Interpolation-Aware Completion Scope (2026-09-26)

The lexical scanner now recursively tokenizes `${...}` expressions as code,
while keeping interpolated literal segments opaque and exact. `$identifier`
expressions are retained as identifier tokens; escaped dollars and raw strings
remain literal. Delimiter matching accounts for nested comments, braces, and
quoted strings and continues to fail closed for malformed strings/comments.

`lib/widgets/session_complete_sheet.dart` is now the eighth exact protected
scope. Its 26 distinct fingerprints (28 occurrences) were mapped to the helper,
card, set-row, summary-header, and metric statements. The CLI contract pins the
complete hash/count set and nonempty per-fingerprint rationale. The existing
four-mode rendered contract remains the qualification evidence; enrollment
does not imply data-loading, device, or release qualification. Formatting
reported zero changes, repository-wide analysis was clean, inventory
`--check` retained 278 files / 2,286 candidates, eight-scope report/enforce
passed, and the full Flutter suite passed all 826 tests.

## Step 18 Flow Controls And Recommended Sets Scope (2026-09-26)

`lib/widgets/flow_screen_widgets.dart` owns six explicit dropdown hint/option
TextStyles, all sourced from `ColorScheme.onSurface`. Its four-mode contract
checks popup surface, menu ink, callbacks, and no layout exceptions. Selected
value styling intentionally remains Material-inherited. The report-only run
returned six count-1 fingerprints, each reviewed against the exact source
scope and recorded in the manifest.

`lib/widgets/recommended_sets_editor_dialog.dart` uses the existing
`TonosDialogFrame(styleFormControls: true)` boundary for both field decorations
and `ColorScheme.error` for validation ink. The four-mode contract verifies
field labels/suffixes, invalid input, successful save values, and unchanged
Classic Material decoration defaults. The report-only run returned three
fingerprints with counts 2, 2, and 1, covering the repeated field decorations,
inherited dialog Theme lookups, and explicit validation TextStyle.

The new focused contracts, exact inventory-owner contracts, and ratchet CLI
contract passed in a 34-test run; targeted and repository-wide analysis were
clean. All 822 Flutter tests passed. Inventory `--check` remained at 278 Dart
files / 2,286 candidates (92 allowlisted, 1,593 migrated, 601 pending), and
seven-scope report/enforce matched the exact approvals. This protects these
lexical scopes only; it does not replace route-wide human review.

## Step 18 Exercise Definition Info Scope (2026-09-26)

`lib/widgets/exercise_definition_info_tile.dart` is the ninth exact protected
scope. Its only style candidate is the title's `fontWeight: FontWeight.w700`;
the `ListTile` continues to supply Material size and foreground in Classic/Neo
light/dark. The four-mode rendered contract verifies the effective style and
the existing Classic `Card` / Neo `TonosSurface` ownership boundary. No app
rendering or token role changed.

The report-only run returned one fingerprint,
`50ab6b853cf46e7e5a0455cb489b8cad5a697e15cf360f716b8a60f851b8e227`, with an
expected count of one. The inventory rule and its contract pin one migrated
`text_style` finding; the CLI contract pins the exact fingerprint and a
non-empty rationale. Formatting and repository-wide analysis passed, the
focused widget/inventory/ratchet tests passed all 43 tests, inventory `--check`
reported 278 Dart files / 2,286 candidates (92 allowlisted, 1,594 migrated,
600 pending), and nine-scope report/enforce passed. The full Flutter suite
passed all 831 tests at this ninth-scope checkpoint. This remains lexical
protection, not full route, device, or release qualification.

## Step 18 SetStatChip Scope (2026-09-26)

`lib/widgets/set_stat_chip.dart` is the tenth exact protected scope. Its two
fingerprints map to the active `Theme.of(context)` lookup and the chip's
`BoxDecoration`. The four-mode widget contract asserts the resulting
`AppSurfaceTokens.metricChip` fill and `AppShapeTokens.metric` radius, resolved
foreground ink, and absence of border/shadow. The existing focused-sets test
continues to cover the optional edit action. No production appearance or token
changed.

The report-only output mapped `912ba3dfc1570e9ba8f95b5e7350970dc666592e5bd2f4365d3797bc434a5866`
to the Theme lookup and `cc6fd99f4549991e1418de00a3124f125fac10ae7e05bc80f54afcaaadb8eaa5`
to the decoration, each with count one and a distinct rationale. The inventory
rule and contract own exactly one migrated `decoration` finding. Formatting,
repository-wide analysis, the focused 52-test batch, inventory `--check`,
ten-scope report/enforce, and full 836-test Flutter suite passed for this
tenth-scope checkpoint. This is exact lexical protection, not broad route or
release qualification.

## Step 18 Past Sessions Scope (2026-09-26)

`lib/widgets/past_sessions_list.dart` has one explicit filter-label
`TextStyle`, whose foreground resolves from `ColorScheme.onSurface`; all other
typography remains inherited from the active `DefaultTextStyle`. The four-mode
rendered contract verifies this resolved foreground and inherited style. Its
single fingerprint was mapped to that exact label statement and added as the
eleventh protected scope. This is a narrow ownership assertion, not a broader
history-route or device qualification. The focused Past Sessions/inventory/CLI
batch passed 34 tests; repository-wide analysis, inventory `--check`, and
11-scope report/enforce passed. The full Flutter suite passed all 841 tests.

The following 2026-09-26 Weekly Overview and SingleBodyPartHeatmap contracts
qualify five additional inventory findings in four modes. No ratchet scopes
were added: the report-only output includes complete file-level fingerprint
sets, and these passes did not map and qualify every style statement in either
file. The inventory contract, component tests, repository-wide analysis,
11-scope report/enforce, and full 844-test Flutter suite passed. Keep these as
inventory classification evidence until their complete lexical scopes are
reviewed for enrollment.

Reviewed TonosSurfaceTheme fingerprints (2026-09-23):

- `b4a7314cb5fe5c1f029c64a1fd626aceeb584dc8b0f9c7416e95eaa2545c3b18`:
  the helper's explicit `Color surface` role.
- `c0c1508f90b9eab20bdd29eeb7eb400591ebb3e8d758f34761a47eb152ee4396`:
  the active `Theme.of(context)` lookup.
- `cf3529f26722b1a59f40a8edb32069d8762cf0c8e0ba9c0df2eba901338652c5`:
  the scoped `Theme` that updates surface and inherited foreground roles.

Each had actual count 1 and expected count 0 in the failing report. Source and
lexer identities were reviewed directly, and the machine-readable manifest now
expects count 1 for each, and the subsequent enforce-mode run passed. The
commands below can be rerun after future changes; do not regenerate approvals
automatically.

Step 14's new Appearance selector is intentionally not enrolled here even
though its route/device qualification is user-accepted. At that checkpoint,
the protected scope remained unchanged and the manifest only added approvals
for current TonosSurface fingerprints. The later badge-file enrollment below
is based on its own per-file evidence, not selector implementation or route
qualification.

The 2026-09-17 implementation pass adds optional shape/elevation forwarding
through the already protected TonosSurface boundary and preserves the
ratchet-recognized style statements. The post-review shape regression fix and
contract-test changes were covered by the corrected-scope verifier run on
2026-09-22 and passed. No new production file was enrolled. Do not
automatically regenerate approvals or treat the new compatibility test as a
substitute for per-file review.

## Eligibility Decision

The scanner tokenizes braced and simple identifier interpolation expressions
as code and keeps surrounding literal segments opaque. Style candidates inside
those expressions remain visible; escaped dollars and raw strings remain
literal. Delimiter matching covers nested braces/comments and quoted strings
inside nested expressions. Because this remains a purpose-built lexer, not a
complete Dart parser, a protected file is eligible only when its syntax is
covered by the lexer tests and its exact fingerprints are reviewed. Do not
remove strings or broaden approvals to bypass unsupported syntax.

Other production files remain pending per-file Classic qualification. Before
enrollment, record exact path, owner, lexer compatibility, parity evidence and
narrow fingerprint approvals. Classify each proposed file as interpolation-
compatible, evidence-pending, or qualified. The original five listed scopes are
`lib/theme/widgets/tonos_surface.dart`,
`lib/theme/widgets/tonos_expansion_tile_scope.dart`,
`lib/widgets/workout_record_badges.dart`, `lib/widgets/tonos_train_tabs.dart`,
and `lib/widgets/tonos_bottom_navigation_bar.dart`; the CLI fixture is
test-only, not production evidence.

Six additional exact production scopes were subsequently enrolled:

- `lib/widgets/session_complete_sheet.dart`
- `lib/widgets/flow_screen_widgets.dart`
- `lib/widgets/recommended_sets_editor_dialog.dart`
- `lib/widgets/exercise_definition_info_tile.dart`
- `lib/widgets/set_stat_chip.dart`
- `lib/widgets/past_sessions_list.dart`

## Existing Report Versus New Enforcement

`tools/theme_style_inventory.dart` and `docs/theme-style-inventory.json` remain
separate from ratchet enforcement. Inventory classification can change without
changing the protected scope, and its `--check` still means all candidates are
assigned, not that styling is qualified. `tools/theme_style_ratchet.dart` uses
the separate version-1 `docs/theme-style-ratchet.json` file containing exact
protected file entries.

The manifest contains seventeen deliberately narrow production scopes. An empty run
reports protectedFileCount: 0 and proves no production protection; CI's
existing ratchet job enforces the listed scopes. Do not broaden enrollment to
make a migration gate green.

## Enrollment

Each file entry requires path (exact lib-relative .dart path), owner, evidence,
and approvals. Each approval requires fingerprint (64-character SHA-256),
positive count, and a nonempty reason. Use explicit reviewed evidence, not
a generic directory classification. Duplicate paths or approvals are errors.
Missing protected files fail, including deliberate renames until reviewed.

Run report mode on a proposed manifest with exact paths and empty approvals
to inspect fingerprints. Add `--details` to include the normalized lexical
scope, candidate token, and statement tokens for each fingerprint; ordinary
report output stays compact. Review the source alongside this evidence, then
manually add only justified approvals. The tool never writes or updates a
baseline.
File deletion, changed values and stale approvals require review as well as
new findings. There is no wildcard approval.

Existing user-run commands:
```powershell
dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json --report
dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json --report --details
dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json
```

Report mode bypasses count comparison only; malformed manifests, missing files,
and malformed lexical structures still fail. Enforcement failures use exit 64;
filesystem errors use exit 66. Compact output includes mode, protected count
and sorted file/hash counts. Detailed report mode adds statement context for
manual review; enforcement output and fingerprint identity are unchanged. A
failure identifies the path, fingerprint and expected/actual count.

## Identity And Deliberate Limits

The lexer ignores whitespace, nested comments and trailing commas. Literal
string segments are kept as opaque tokens, while non-raw interpolation
expressions are tokenized as code so style candidates inside them remain
visible. Raw and triple-quoted strings are recognized. This remains a
purpose-built lexical scanner rather than a complete Dart parser; add tests for
new syntax before relying on it for protected files.

Fingerprints include lexical scope prefix, candidate name and surrounding
statement tokens. Counts preserve duplicate occurrences. This is conservative:
refactoring, declaration renaming, or nearby non-style changes can require
reapproval. It is not a full Dart parser, type resolver, or semantic-equivalence
checker. Aliases, indirect helpers and all possible styling APIs are not
exhaustively detected. The normal analyzer remains necessary.

Only the documented lexical candidate names are protected. Do not claim that
a passed run proves absence of all style debt. Expanding candidate recognition
requires fixtures and explicit baseline review. Report-only inventory remains
the broader discovery mechanism.

## Required Before CI

Run test/theme/theme_style_ratchet_test.dart plus the existing inventory
contract. Demonstrate an approved fixture passing and a changed value failing.
Tests also cover duplicates, comments/formatting, nested and escaped
interpolation, raw strings, pending files, malformed approvals and missing
protected files.

Enroll only reviewed scopes with qualified evidence. Review aliases and unsupported
syntax before claiming coverage. Extend diagnostics/parser support as needed;
do not work around limitations with broad approvals. Inspect existing CI and
workflow contract tests before adding the job. Never regenerate approvals in CI.

Q1's scoped automated completion is recorded as a historical checkpoint. At a
later milestone, per-file enrollments brought the manifest to thirteen exact
production scopes; the scanner remains intentionally narrower than a Dart
parser. At the 2026-09-26 BodyPartFocusChips/PresetInfoCard checkpoint, the
manifest had fifteen scopes. The current count is recorded at the top of this
document; neither historical nor current scope counts imply repository-wide
style coverage. Current development
human/device qualification is accepted in the Q3 gate; this ratchet neither
replaces that qualification nor approves a public release.

## Step 18 Badge Scope (2026-09-23)

`lib/widgets/workout_record_badges.dart` was added after manual review of the
13 exact count-1 fingerprints supplied by the report-only run. The candidates
are confined to the shared badge renderer and legend: color/style declarations,
token-alpha fill and border, box decorations, text styles, and the theme-based
legend text role. Colors, surface opacities, and shapes resolve through theme
tokens; the source is compatible with the current lexer. The rendered test
checks the token colors, opacity, shape, spacing/density, and legend dots in
Classic/Neo light/dark, and the user-run formatter, analyzer and focused test
passed. The user also visually confirmed that the workout-detail badges no
longer overflow.

The manifest now lists this exact file with those 13 approvals. The user-run
post-change report and enforce commands both passed with two protected files;
the ratchet unit, CLI, and badge tests passed all 15 tests. The separate
user-run analyzer reported no issues for the formatted CLI test. Its six
broader inventory findings remain pending; this narrow lexical baseline does
not mark the file migrated or establish
repository-wide styling qualification.

## Step 18 ExpansionTile Scope (2026-09-24)

`TonosExpansionTileScope` has one clear production owner and report-inventory
findings already classified under the migrated `theme-system` rule. Its tests
cover standard, compact, and dense behavior, inherited ListTile/Icon fields,
and unrelated theme-role preservation across Classic/Neo light/dark. The user
accepted the Preset Generation QA and Food Customization ExpansionTiles. The
September 24 focused suite passed all 22 tests across inventory, ratchet,
ratchet CLI, and ExpansionTile contracts. The report-only fingerprints were
mapped as follows:

- `d2d922eabbf86a9668f71c0e18fe5e42425ff589417c18bc990d583b78db8068`:
  `Theme.of(context)` copies the active inherited theme.
- `01941e88c6ebd2ec01e2857976243cbc5d8f948f7f08bd954ae56c6c457e92c2`:
  the returned `Theme` scopes the shared ExpansionTile defaults.
- `bee7073bcd06b3c316dcda9c6eaa21e3a69b1b97f55708540a5c0547f3d77c54`:
  `Colors.transparent` intentionally hides the ExpansionTile divider.

These exact count-1 approvals are in the canonical manifest. The three-scope
report and enforce run at that checkpoint passed on 2026-09-24; the earlier two-scope
result is historical. Rerun these commands after future manifest changes.

## Step 18 TonosTrainTabs Scope

`lib/widgets/tonos_train_tabs.dart` is the shared Train Overview/Plans selector
owner. Its inventory rules assign four geometry findings and four
surface/effect/color findings to the migrated theme-system recipe. The
four-mode rendered contract checks frame fill, radius, border, token shadow,
button fills/shapes/borders, semantics, activation, and absence of layout
exceptions; the user accepted the Train appearance in Classic and Neo, light
and dark. A focused Neo 2x text-scale regression checks that the selector uses
its bounded frame without overflow, while the four-mode contract pins the
ordinary 44px Classic and 48px Neo heights.

The report-only run returned ten fingerprints covering eleven occurrences.
Manual source review mapped them to the BoxShadow type reference used by the
visible-shadow guard, frame and button decorations, token-backed border and
shadow, Classic surface alpha and
transparent fill, the conditional button BorderSide (two occurrences), active
text-theme lookup, and responsive-height theme lookup. The exact counts and
per-fingerprint reasons are recorded in the canonical manifest and pinned by
`test/theme/theme_style_ratchet_cli_test.dart`. At that checkpoint, the
four-file manifest passed both report and enforce, and the focused
selector/inventory/ratchet/CLI
suite passed all 38 tests with clean targeted analysis and no formatter
changes. The inventory `--check` also passed with its existing 278-file /
2,286-candidate totals. This is narrow lexical protection, not a claim that
every style in the file or repository is qualified.

## Step 18 Bottom Navigation Scope (2026-09-25)

`lib/widgets/tonos_bottom_navigation_bar.dart` is the shared application-shell
owner used by production and Theme Lab. Its four-mode contract verifies that
Classic continues to return the unwrapped Material `BottomNavigationBar`,
while Neo uses ColorScheme and existing surface/shape/effect roles for its
continuous frame, selected segment, foregrounds, outline, and shadow. The test
also verifies activation and the selected underline's specified 4px height.
The user accepted the current 21-item Neo visual review, which includes the
shared app shell; no production visual default changed in this follow-up.

The inventory's kind-limited rule owns exactly four migrated candidates
(`color`, `decoration`, `geometry`, and `shadow`); this does not classify other
navigation styles or change the global inventory totals. Report-only output
returned eight count-1 fingerprints, manually mapped as follows:

- `14547d142c719736f56b7d3720acbc57a76d2cab26fcfbc84647e018dfef3f13`:
  inherited `Theme.of(context)` lookup for the navigation background.
- `657d2f1738bc0e8c38f4f6a8ef73b0677c2b46aeabdf4aa4f1364b02e9b59e18`:
  transparent Material fill that reveals the separate selected segment.
- `c52be0033ea57248051d9176a33f1e9852c22272b83dcfe6cc34a15a9134a59f`:
  token-backed `BoxDecoration` for the Neo frame.
- `1a02edd38f5a7cbdca6c845fea770194fe16d96816ed81a824420eca77283791`:
  `Border.all` structural frame outline.
- `0d3601f1da4df264c2aef6eea19f0d4ec9b58ab3e317636c4899a9fa1e6368ed`:
  BoxShadow construction from effect tokens.
- `0a7365d68272b8817d4c84a36b6d23f75edab387f67398f6019ce46f74e7817a`:
  BoxShadow type in the visible-shadow guard.
- `9b587dc1a09a54ff64331ff81ad911c56b10d82f645ff4c8565372024455eab3`:
  selected-segment Color role.
- `6e935861fcb507bebb821426e90e2ad6f971d6eda62dd2c5b1cb5df21856e7b4`:
  selection-underline Color role.

The canonical manifest and CLI contract pin these exact approvals. Focused
widget/Theme Lab/inventory/ratchet tests passed 49 tests, the separate CLI
contract passed all 3 tests, repository-wide `dart analyze` and all 803 Flutter
tests passed, inventory `--check` retained 278 files / 2,286 candidates, and
the five-scope report/enforce passed. This remains narrow lexical protection,
not repository-wide visual or styling qualification.

## Step 18 Weekly Overview Scope (2026-09-26)

`lib/widgets/seven_day_focus_card.dart` is now the thirteenth exact protected
scope. Its six fingerprints were inspected with `--report --details` and mapped
to their enclosing widget/method and statement: the `SevenDayFocusPresentation`
and `_MoreFocusedSetsHint` Theme lookups, scoped Theme construction, 0.22
progress-track alpha, transparent details Material, and 16px InkWell radius.
The contract checks the scoped surface/text/progress roles, focused-sets hint
ink/weight, transparent layer, exact radius, responsive layout, and reachable
action in Classic/Neo light/dark. Classic keeps its distinct `onSurfaceVariant`;
the first test run exposed and corrected an overly broad expectation before the
contract passed. Formatting, focused analysis, 33 focused tests, repository-wide
analysis, inventory `--check` (278 files / 2,286 candidates; 590 pending),
13-scope enforcement, and all 851 Flutter tests passed. No production appearance
or inventory count changed. The manifest and CLI contract pin all six count-1
fingerprints. This lexical guard does not qualify the entire Weekly Overview
route or close human visual review.

## Step 18 BodyPartFocusChips And PresetInfoCard Scopes (2026-09-26)

Two complete-file scopes were added after reviewing each report fingerprint
against its production statement and four-mode widget contract. The manifest
and CLI contract pin seven BodyPartFocusChips fingerprints (eight occurrences)
and four PresetInfoCard fingerprints (four occurrences), bringing enforcement
to fifteen files, 110 distinct fingerprints, and 118 approved occurrences.
BodyPartFocusChips keeps Classic's original status colors and neutral RawChip
behavior; Neo preferred/avoided states use the existing positive/negative
semantic roles. PresetInfoCard's tests preserve its existing Classic Card / Neo
TonosSurface boundary and token-backed metric appearance at compact width.
Neither scope adds a token or shared primitive. Formatting, targeted and
repository-wide analysis, 85 focused tests, inventory `--check`, 15-scope
report/enforce, and all 888 Flutter tests passed. Human visual review of the
updated Neo BodyPartFocusChips colors remains required; these tests do not
substitute for visual acceptance.

## Step 18 Cardio And Stretch Scopes (2026-09-26)

`lib/widgets/cardio_card.dart` and `lib/widgets/stretch_card.dart` are now
complete-file protected scopes after each report fingerprint was checked
against its production statement and four-mode widget contract. CardioCard adds
four approvals covering six occurrences; StretchCard adds three approvals
covering four occurrences. The manifest and CLI contract pin each hash/count
pair and require a nonempty per-fingerprint rationale. Across all scopes the
manifest now has 117 approval entries, 115 unique fingerprint hashes, and 128
approved occurrences.

The Cardio/Stretch contract verifies inherited title/body/countdown typography,
editable and read-only notes, semantic action colors, and the existing
Classic-Card/Neo-TonosSurface boundary. This batch changes no production
appearance and adds no shared card primitive. Formatting and focused analysis
passed; the 63-test focused batch, fresh inventory check, 17-scope report and
enforce, repository-wide analysis, and full 892-test Flutter suite passed. The
inventory remains at 278 Dart files / 2,283 candidates (92 allowlisted, 1,620
migrated, 571 pending; 1,010 uniquely queued, 1,273 outside queues, zero
overlaps, and zero unqueued pending findings). The separate Neo
BodyPartFocusChips visual review and other roadmap-listed human reviews remain
open.

Subsequent 2026-09-26 inventory-only update: WorkoutHistoryCalendar now has an
exact 19-finding migrated inventory rule and a four-mode rendered contract.
The inventory is 278 Dart files / 2,283 candidates (92 allowlisted, 1,639
migrated, 552 pending; 1,010 uniquely queued, 1,273 outside queues, no
overlaps or unqueued pending findings). The manifest intentionally remains at
17 protected scopes, 117 approval entries, 115 unique fingerprints, and 128
occurrences: human visual approval currently covers the selected-period card,
not the entire calendar. The 60-test history/inventory/ratchet batch, full
repository analysis, inventory check, and existing report/enforce passed.

Dashboard editor inventory/qualification follow-up (2026-09-26): the
four-mode rendered contract now covers the configurable Dashboard's empty and
editor states, exact token/ColorScheme ownership, and add/hide/reset/reorder
behavior. The inventory assigns eight surface/geometry findings to their
existing recipes and two bounded alpha transforms to stable section-category
data. The combined 68-test Dashboard/history/inventory/route/ratchet batch,
targeted Dart analysis, inventory `--check`, and report/enforce all passed.
The 17 protected scopes and 117 approvals are unchanged; Dashboard was not
enrolled because its manual/device state review remains pending. At that
checkpoint, the inventory reported 2,283 candidates: 94 allowlisted, 1,647
migrated, and 542 pending, with no unqueued pending findings or overlapping
review queues.

BodyPartFocusChips contrast follow-up (2026-09-26): the review found that Neo
selected chips used translucent status colors over the dark canvas while
resolving label ink for the unrelated dialog-choice yellow. Neo selected fills
are now opaque semantic positive/negative colors; labels and icons use the
corresponding `onPositive`/`onNegative` roles, and the outline uses that
contrast-qualified foreground. Classic's former alpha-61 fills and status inks
are unchanged. The four-mode contract asserts at least 4.5:1 contrast for
status foregrounds and 3:1 for outlines. An initial assertion caught the
light-Neo negative outline at 2.77:1; the `onNegative` outline resolves it.
The focused 12-test widget suite passes.

The six current BodyPartFocusChips fingerprints cover the selected-state
TextStyle (count two), status BorderSide, preferred/avoided color selection,
neutral outline resolver, and empty-state TextStyle. The obsolete translucent
fill fingerprint was removed; the exact manifest and CLI contract now require
six approvals/seven occurrences for this file. Overall enforcement remains at
17 scopes, 116 approvals, 114 unique fingerprints, and 127 occurrences. Human
visual review of the updated Neo fills remains open.
