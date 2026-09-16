# Theme Style Inventory

Opt-in enforcement infrastructure is documented in [Theme Style Ratchet](theme-style-ratchet.md).
The separate ratchet manifest now protects one exact production scope in CI.
The existing inventory scanner remains report-only and its meaning is unchanged.

## Next Migration And Enforcement Work

See [E2 And Qualification Execution Guide](theme-e2-qualification-guide.md)
for route disposition, narrow exceptions, stable finding identity, duplicate
handling, scanner fixtures and CI acceptance criteria. The inventory artifact
remains report-only; the separate ratchet manifest is the only enforcement
baseline and does not reclassify the broader debt.
The latest user-run theme/configuration suite passed 200 tests and analysis
reported no issues; manual qualification remains separate from inventory
classification.

The 2026-09-15 theme-ready compatibility extension is recorded separately from
full route migration. TonosThemeReadyCard is a migrated theme-system primitive,
while its exercise-definition, history, cardio, stretch, measurement, trend,
and nutrition consumers remain reportable until their complete route scopes and
final Neo recipes are reviewed. This batch does not change the report-only
manifest or enroll those consumers in the ratchet.

The [Q3 readiness gate](theme-q3-readiness-gate.md) is the current
cross-prerequisite record. The Q2 tutorial correction passed 213 scoped tests
and clean analysis. Readiness remains blocked while reachable-route/manual
qualification remains open. Inventory classification and ratchet enrollment do
not convert those items into qualified evidence.

## C3-D3 Review Correction (2026-09-09)

C3-D3 follow-up: user-run analysis was clean and all 168 scoped tests passed.
E1 now assigns onboarding and tutorial geometry, scrims, optional shadows, and
visual durations to AppTutorialTokens. Material colors/text, content identity,
readiness delays and completion state remain with their existing owners. The
inventory remains report-only; automated E1 verification is superseded by the
latest suite, while manual qualification remains pending.

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
C2 is implemented-awaiting-verification for the exercise-detail form guide,
metrics, records, chart, selector, and sheet-shell recipes. Its zoom, image,
scrim, heatmap, and media-overlay decisions remain assigned to C3.
Swap actions, filter, match badge and marker now have shared recipes. B1 is now
scoped-verified for the preset thumbnail frame and swap secondary copy opacity,
with clean analysis and 134 scoped tests. This does not change
the report-only manifest or qualify all expressions in the swap sheet. Older
batch-count paragraphs below are historical evidence.

B2 is scoped-verified for train header and plan-list consumers. Its named
opacity roles and fixed identity-palette ownership do not change the
report-only manifest; identity palettes remain documented review exceptions.

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
unchanged. Focused source/token tests were added; user-run verification and
rendered empty/populated/edit-state evidence remain pending.

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
- `allowlisted` is reserved for fixed data visualization or asset/media
  treatment. It does not exempt the surrounding application chrome.
- `review` is reserved for a named one-off, such as the tutorial scrim, that
  still needs an explicit accessibility or effect-fallback decision.
- `excluded` is limited to generated source.

An allowlist entry must include a non-empty rationale and a destination. Fixed
anatomy, chart, and illustration values remain visible in the report so their
contrast and non-color meaning can be reviewed independently. The manifest is
not a subjective approval record: human parity, accessibility, and product
decisions remain in the relevant QA and theme-plan documents.

## Current Boundary

The report makes the following distinctions immediately:

- `lib/theme/**` is the migrated theme-system owner.
- The application shell has started its first vertical slice: global Material
 and bottom-navigation ownership already live in the theme boundary, and
 shared quick actions use a Tonos action-bar recipe.
- Shared drawer navigation, the persistent ongoing-session action, and the
  app-level durability banner now use focused surface, shape, semantic-action,
  and effect-token roles. The fixed profile and plan identity palettes remain
  explicit review exceptions.
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
  value/form/save-bar/status-badge recipes are now token-backed, but the profile
  identity palettes, category accents, and local control overrides remain
  deliberate review items rather than application-state colors.
- Premade plan expansion and automatic-flow controls now use named motion,
  surface, flow, shape, and data-visualization roles for their B3-owned
  presentation recipes. Classic light/dark grid parity is covered; full route
  reachability and device parity remain pending.
- Anatomy and chart color owners have explicit data-visualization rules where
  the fixed palette is part of the data meaning.
- Exercise thumbnails and shared entity thumbnails have explicit media rules.
- C1 adds focused catalog surface roles for selected rows, usage rows, and
  catalog outlines, while the two media widgets keep separate frame,
  placeholder, and media-outline ownership. Existing media fallback, retry,
  cache, sizing, and caller-supplied geometry behavior remains unchanged.
  Its scoped automated contract is verified; device and full-route visual
  evidence remain pending.
- The tutorial overlay remains a review exception rather than silently being
  treated as application chrome.
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
  token contracts are added; formatting, analysis, tests, device review, and
  full-release qualification remain pending.
- The secondary-surface compatibility extension now gives evolving
  non-default exercise-definition, history, cardio, stretch, measurement,
  trend, food-customization, and food-logging consumers an explicit
  Classic-Card/Neo-TonosSurface boundary. Semantic and data-visualization
  roles own the Neo-specific accents. These consumers remain pending for full
  route migration, final Neo recipes, and device qualification; wrapper
  adoption alone is not a migrated inventory claim.
- All other screen/widget candidates remain reportable through pending
  release-surface or catch-all rules.

When a vertical slice is migrated, replace its pending rule with the narrowest
appropriate rule or update its ownership classification. Keep the broad
catch-all rules in place so newly added styling cannot disappear from the
inventory.
