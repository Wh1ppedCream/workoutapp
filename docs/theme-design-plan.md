# Scalable Theme Design Plan

## Current Status (2026-09-23)

Use the [Consolidated Theming Roadmap](theme-consolidated-roadmap.md) as the
current Step 1-19 checklist. This document retains architecture and original
requirements; historical batch descriptions below are evidence for their dates.

Q3 readiness and original N4 real-route checks were accepted. Neo light/dark,
development selection, shared previews, subsequent refinements, and the
repository-side pilot/compatibility qualification are implemented. The user
accepted the current 21-item Neo visual review and, on 2026-09-17, confirmed
the consolidated human/device/N6 checklist for the current working tree. This
records development qualification for the current routes, states,
accessibility, and affected Classic-parity scope; it is not release approval.
Step 14 is implemented, automated-verified, and included in that acceptance.
The Step 15 signed Android internal candidate and all six focused device
checks were accepted on 2026-09-23. Its tested-source commit/hash association
remains the final internal closeout task. Wider-release treatment for retained
placeholders, final product-specific Neo recipes where still needed, broader
per-file ratchet evidence, and native-speaker review remain separate. For the
planned Android release, the user accepts the current translations for all
supported locales without native-speaker review; that remains an accepted
limitation, not a completed linguistic signoff.

The 2026-09-15 theme-ready compatibility extension now gives evolving
non-default exercise-definition, history, cardio, stretch, measurement, trend,
and nutrition consumers an explicit Classic/Neo presentation boundary. This
reduces unowned structural styling without claiming final Neo route design:
the shared wrapper keeps the original Classic `Card` recipe and resolves a
semantic `TonosSurface` for Neo. Final product-specific geometry, state
coverage, and product-specific design decisions remain deferred for selected
evolving surfaces; this does not reopen accepted development qualification.

## Historical Pre-Q2 Status

Read [Pre-Q2 Closeout Ledger](theme-pre-q2-closeout.md) for the current seven-item
follow-up status and verification evidence. It supersedes historical pending-test
labels below. The latest earlier expanded run passed 302 scoped
theme/configuration tests,
plus 6 responsive tests;
manual, device,
accessibility, visual-parity, and release qualification remain separate gates.

The active [Q3 readiness gate](theme-q3-readiness-gate.md) reconciles those
historical results with the current dirty Q2 implementation. Its decision is
complete for the agreed Q3 scope as of 2026-09-11: clean analysis, 226 passing
tests, and explicit manual-plan confirmation. The gate records the accepted
1.15 baseline and limitations. Historical pending labels below describe earlier
work; the Q3 gate controls current readiness for Step 13 development.

## Upcoming Execution Detail

Use [E2 And Qualification Execution Guide](theme-e2-qualification-guide.md)
alongside the [batch playbook](theme-batch-playbook.md). It defines E2.1-E2.4,
Q1 scanner/enforcement changes, Q2 runtime/manual evidence, and Q3 readiness
criteria. These are detailed work instructions, not claims of completion.
E1 has user-reported clean analysis and 184 passing scoped tests; manual
qualification remains pending. This supersedes older E1 pending-test notes.

## C3-D3 Review Correction (2026-09-09)

Follow-up verification: the user reported clean scoped analysis and 168 passing
tests for C3-D3. E1 subsequently passed 184 scoped tests: onboarding
and tutorial geometry/effects/motion are theme-owned, readiness and persistence
are unchanged. See the E1 playbook record for scope and pending manual evidence.

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

Latest verification: the B1-C2 review fixes, C2-D3 work, and pre-Q2 follow-up
changes are covered by clean analysis, 302 passing theme/configuration tests,
6 passing responsive tests, a passing route-boundary batch, and a passing
enforce-mode ratchet reported by the user. This supersedes pending-
verification labels in the historical records below. Device and full-release
qualification remain pending and are tracked in the closeout ledger.
Device visual/interaction checks and full-release qualification remain pending;
the source-contract tests alone do not establish rendered state preservation.

Status (updated 2026-09-08): the shared foundation is implemented, but
preparation for alternate themes is incomplete. Classic is the only registered
family. Its extraction, focused tokens, retired AppColors bridge, primitives,
and development Theme Lab exist. Release-surface migration remains in progress.
The B6 route/evidence closure is scoped-verified. The latest supplied
verification reports clean analysis and 141 passing tests across test/theme and
app_configuration_test; that is scoped automated evidence, not full visual or
release qualification. C1 catalog/media implementation is now scoped-verified
with clean analysis and 148 focused tests; device and full-release
qualification remain pending. C2 detail-tabs/form-guide/metrics/records work
is automated-verified in the expanded 2026-09-17 user run; C3 remains
responsible for zoom and media overlays. D1 dashboard/logbook structure is
also automated-verified in that run; D2 progress/records/metric structure is
scoped-verified with clean analysis and 158 focused tests; rendered state,
device and full-release verification remain pending.

The earlier review identified Classic color differences, overlapping theme
writes, and incomplete rendered parity coverage. Source fixes and regression
tests now exist for the badge outline, drawer heading, queued writes, and
consumer recipes. Preserve those fixes; the historical defect descriptions are
not instructions to implement them again. Remaining matched visual/device
evidence still prevents full qualification.

For upcoming work, use [Theming Batch Playbook](theme-batch-playbook.md).
It defines batch IDs, concrete file targets, acceptance requirements, and the
current execution order. It takes precedence over historical batch narratives
for what to do next. This plan remains authoritative for phase numbering and
architecture; classic-theme-baseline.md owns visual evidence, and the inventory
manifest owns classification. Do not infer whole-phase completion from a test
count or a completed batch.
No alternate-family implementation should begin until Step 19 passes.

Current progress: the first application-shell slice is in progress. `main.dart`
already delegates global Material and bottom-navigation treatment to the
shared theme factory; shared quick actions now use
`TonosSegmentedActionBar`, drawer geometry and motion use focused tokens, the
persistent workout action plus durability banner use semantic and shape roles,
and shared settings building blocks resolve section/card surfaces, geometry,
and dividers through focused tokens. UI Appearance values now use a shared
accent-aware value recipe, and User Information fields plus its animated save
bar use shared input, surface, divider, and motion recipes. The bottom-tab
editor now shares the save-bar recipe and tokenized tab icon geometry. The
Profile's deferred-feature badge now uses a shared status recipe. The primary
Train page's Overview/Plans control now uses shared pill geometry, surface, and
inherited typography roles. The split workout bar now uses shared sheet
geometry, elevation, action typography, and a semantic start-action role.
Plan-generation accents, completion headlines, session metric accents, saved-
session edit state, workout record badges, and repeated metric-tile geometry now
resolve through focused semantic/data/shape roles while preserving their Classic
colors. The active-workout
slice keeps the session timer and completion values on inherited theme
typography, uses shared pill/control geometry in the completion sheet, and
routes saved-session summary/set surfaces through focused tokens. The
remaining completion-section audit, profile identity
palette, category accent ownership, local control overrides, and remaining
dialog/elevation details are still explicitly pending in the style inventory.
Route behavior, provider ownership, and feature logic must remain outside
presentation migrations; theme preference error and ordering fixes are tracked
separately as correctness work.

## Objective

C3 is automated-verified in the expanded 2026-09-17 user run alongside the
B1-C2 review fixes.
Detail media geometry and shadows use AppMediaTokens; fixed viewing contrast
has a narrow MediaViewingColors owner. Full-size images now have an error
fallback. See the playbook C3 record for preserved interactions and outstanding
device, real-image and effects-disabled rendering evidence.

Review follow-up for B1-C2: corrected the exercise-detail handle to its original
0.55 opacity (the workout handle remains 0.50), removed an unused test import,
avoided eager fallback token construction, and added in-place flow presentation
refresh on theme changes. Regression coverage checks flow graph geometry and
connection retention. The expanded user-run analysis/tests passed. C2's source
contracts must not be treated as rendered tab/scroll/state or visual evidence.

Create a theme system that keeps the current Tonos appearance as the default
Classic theme while making future theme families safe and inexpensive to add.
The first alternate theme would follow the Material 3 Expressive design
direction. The same foundation should also support later themes such as Liquid
Glass, Neo-Brutalism, and tactile or soft UI without adding theme-specific
branches throughout feature code.

## Current App State

- `ThemeProvider` exposes the existing mode API plus an immutable family/mode
  selection. Production startup loads it before `runApp`, while injected test
  trees can continue using the asynchronous constructor.
- `lib/theme/classic_theme.dart` defines the bundled light and dark Classic
  `ThemeData` values using the same `ColorScheme.fromSeed` calls as the
  previous inline definitions; `lib/theme/app_theme_factory.dart` caches and
  selects those definitions.
- Widgets can read standard Material roles through `context.cs` and focused
  non-null Tonos roles through the accessors in `theme_extensions.dart`.
- The first compatibility migrations now read focused visualization, semantic,
  surface, and effect tokens directly. Shared heatmaps, summary/preset/
  calendar views, repeated info cards, health/progress tile outlines, progress
  indicators, nutrition series, trend add icons, generic bars, past-session
  controls, the workout-start action, the records-today marker, and the
  automatic-plan badge no longer depend on their equivalent legacy roles.
- `lib/theme/tokens/` contains complete Classic light/dark contracts for
  semantic colors, geometry, surface recipes, motion, effects, data
  visualization, flow diagrams, and nutrition-specific surfaces.
- The current theme is only partially tokenized. Many screens and shared
  widgets still define colors, radii, shadows, and text styles directly.
- The preference model now has explicit `theme_mode` and `theme_family` keys;
  the appearance settings UI still exposes only the existing brightness
  control, so no family picker is visible yet.
- `AppThemeCapabilities` is now the single build-policy boundary for family
  availability. Classic is unconditional, while non-Classic families are
  fail-closed in release builds and are not exposed until their definitions
  are complete.

### Repository audit findings

The current foundation is useful, but it is not yet a scalable design system:

- The original roughly 300 lines of light and dark theme construction have
  been extracted from `main.dart` into an independently tested and cached
  Classic theme factory. `MyApp` now selects from that boundary.
- `ThemeProvider` now stores an `AppThemeSelection`; it still defaults to dark
  Classic and preserves the existing mode API. `ThemeProvider.load()` is
  awaited by the production entry point so a saved light mode does not flash
  dark before the first themed frame.
- `AppThemePreferences` owns the `theme_mode` and `theme_family` keys, parses
  explicit `system`, `light`, and `dark` codes, materializes the missing
  Classic family key, and preserves unknown future family codes while the
  current build renders Classic.
- The former `AppColors` extension and `context.colors` accessor have been
  deleted. Feature-specific roles now live in focused non-null contracts such
  as `AppFlowTokens` and `AppNutritionTokens`, while structural rendering is
  owned by surface, semantic, shape, effect, motion, and visualization tokens.
- The compatibility contract scans every production Dart file and rejects any
  reintroduction of `AppColors` or `context.colors`.
- `lib/` currently contains about 305 direct color expressions, 279
  `BorderRadius` uses, 214 `BoxDecoration` constructions, and 96 direct
  `TextStyle` constructions. Not all are wrong: illustration colors, chart
  series, anatomy heatmaps, and media treatments can be intentionally fixed.
  Structural UI values must be classified before they are replaced.
- The largest style concentrations are `main.dart`,
  `exercise_detail_sheet.dart`, `onboarding_flow.dart`,
  `dashboard_sections.dart`, `exercise_editor_screen.dart`,
  `preset_generation_qa.dart`, and shared settings widgets. These are the
  highest-risk places to migrate and the most valuable places to centralize.
- Several subtrees create local `Theme` overrides, including settings,
  tutorials, preset QA, and food customization. Each override must either be
  converted into a documented semantic variant or deliberately retained.
- The appearance settings screen currently exposes a two-state dark-mode
  switch. There is no theme-family picker, system-following choice, preview,
  or experimental-theme release policy.
- Theme persistence and token completeness have focused tests, and
  responsive/accessibility widget contracts cover several settings layouts.
  Stable theme goldens, contrast tests, and multi-theme widget matrices remain
  future QA work.
- The project is currently pinned to Flutter 3.29.3 in CI. Material 3 is the
  Flutter default, but newer Material 3 Expressive APIs cannot be assumed until
  the controlled Flutter-upgrade backlog item is complete.
- No custom fonts are bundled. A future expressive type family must prove
  glyph coverage and fallback behavior for Bangla, Simplified Chinese, Hindi,
  French, Canadian French, and Spanish before it replaces the current type.

The practical conclusion is that alternate themes must not be introduced by
adding another large `ThemeData` block or by branching inside feature widgets.
The first release should establish the boundary and reproduce Classic exactly;
the second should use that boundary to build Expressive behind a development
gate.

This means the reactive Flutter mechanism is already suitable. The main work
is to establish a complete token boundary and migrate custom UI to it.

## Design Principles

1. Classic remains the default and must preserve its current appearance.
2. Theme family and brightness are separate settings.
3. Themes affect presentation only, never workout logic, navigation behavior,
   database state, catalog identity, localization keys, or user data.
4. Standard Material controls use `ThemeData`, `ColorScheme`, and component
   theme objects.
5. Bespoke Tonos surfaces use shared primitives and semantic application
   tokens.
6. Theme definitions are statically bundled and validated before release.
7. New themes should be added by supplying tokens and recipes, not by adding
   conditionals to every screen.
8. Every theme must have light, dark, large-text, long-locale, and reduced-
   motion behavior where those modes are supported by the app.
9. Layout geometry should remain mostly shared across themes. Theme families
   may vary shape and controlled density, but they must not silently change
   information architecture, ordering, navigation, or content semantics.
10. Theme selection must fail closed: unavailable, corrupt, or future values
    render Classic rather than a partially themed interface.
11. Data visualization colors are a separate contract from structural UI
    colors and must retain meaning, contrast, and non-color indicators.

## Architecture Decision

Use Flutter's native inherited theme mechanism. Standard Material widgets
receive values through `ThemeData`, `ColorScheme`, `TextTheme`, and component
theme objects. Tonos-specific visual language is represented by several small,
complete, non-null `ThemeExtension` objects and rendered by shared primitives.

Do not build a parallel CSS-like cascade, a remote JSON theme engine, or a
user-authored theme schema. The planned families are bundled product designs;
static Dart definitions provide type safety, deterministic startup, offline
availability, and compile-time review. Remote themes can be reconsidered only
if user-authored themes become a real requirement.

Keep the existing `ThemeProvider` as the public facade during migration. This
avoids unnecessary provider-tree and test churn. Its internal state can evolve
from one `ThemeMode` value to an immutable `AppThemeSelection` while preserving
the existing `mode` getter and `setMode` API until callers have migrated.

## Theme Model

Keep these concepts independent:

- `AppThemeFamily`: `classic`, `expressive`, and future family IDs.
- `ThemeMode`: light, dark, or optional system brightness.
- Accessibility preferences: text scale, high contrast where supported, and
  reduced motion.
- Runtime capability flags: for example, whether blur effects are available
  and affordable on the current device.

Persist the family using a stable value such as `classic`, never an enum's
`toString()` output. The existing brightness preference remains compatible.
Invalid or future family values must fall back to Classic without affecting
the rest of the settings. Preference versioning should be coordinated with
the preference-schema backlog item.

### Stable identities and persisted selection

Define product identities explicitly rather than using display labels or enum
serialization. `AppThemeFamily` should expose stable codes such as `classic`,
`expressive`, `liquid_glass`, `neo_brutalist`, and `soft_tactile`.
`AppThemeSelection` should be an immutable value containing a family and a
standard Flutter `ThemeMode`.

The preference layer should own keys, defaults, parsing, and migration:

- continue reading the legacy `theme_mode` key;
- write explicit brightness codes (`system`, `light`, or `dark`);
- add an explicit `theme_family` code;
- default missing or invalid family values to `classic`;
- preserve a valid existing brightness during migration;
- decide explicitly whether appearance is device-local or included in future
  settings export, and document that decision in the preference schema;
- load the selection before the first themed app frame so saved light mode does
  not flash dark.

Keep `ThemeProvider` as the public facade during migration to avoid unnecessary
provider-tree churn. It should expose one coherent selection and notify once
per committed change. It should not build visual objects. A separate
`AppThemeFactory` should return prebuilt immutable `ThemeData` for each family
and brightness combination.

### Availability and release gating

A known family and an available family are different concepts. Persistence can
recognize future codes while `AppThemeCapabilities` decides what the current
build may expose:

- Classic is always available and remains the release default.
- Incomplete families are visible only in debug/development through Theme Lab.
- Release builds deny experimental families even if a Dart define is supplied
  incorrectly, following the fail-closed experimental-navigation pattern.
- If a selected family is unavailable after a downgrade or policy change,
  render Classic without deleting the stored code so it can recover later.
- Do not show disabled theme tiles in normal settings merely to advertise
  unfinished work.

An optional `TONOS_ENABLE_EXPERIMENTAL_THEMES` flag is appropriate only behind
this centralized policy and a release contract test. The flag must not be
checked throughout feature widgets.

## Token Architecture

Use a layered token model rather than exposing raw values to feature widgets.

### Base palette tokens

These are raw colors and measurements owned by a theme definition. Examples
include a brand hue, neutral tones, accent colors, shadow colors, and blur
defaults. They should normally remain private to the theme implementation.

### Semantic tokens

These describe meaning rather than a visual implementation:

- primary and secondary surfaces
- elevated and inverse surfaces
- primary, secondary, and muted content
- outline, divider, focus, disabled, success, warning, and error
- interactive, selected, pressed, and loading states
- chart, measurement, nutrition, anatomy, and workout-status roles

Standard roles should map into Flutter's `ColorScheme`. Tonos-specific roles
should live in focused, complete, non-null `ThemeExtension` objects. Do not
recreate the retired large nullable `AppColors` as another catch-all extension.
Divide ownership by reason to change:

- `AppSemanticColors`: application states not represented by `ColorScheme`,
  including workout, measurement, nutrition, anatomy, and recovery roles.
- `AppShapeTokens`: bounded radii, border widths, and reusable shapes.
- `AppSurfaceTokens`: elevation, shadow, outline, tint, and surface recipes.
- `AppMotionTokens`: durations, curves, and reduced-motion substitutions.
- `AppEffectTokens`: opacity, blur, clipping, highlight, and safe fallbacks.
- `AppDataVisualizationTokens`: categorical series, heatmaps, thresholds, and
  record/progress colors whose meaning must remain stable.
- `AppFlowTokens`: flow-diagram canvas, nodes, branch outcomes, loopbacks, and
  diagram actions.
- `AppNutritionTokens`: nutrition-specific meal surfaces and text-detail
  borders that are not generic surfaces or semantic states.

Every field must be non-null, every extension must implement `copyWith` and
`lerp`, and every registered family/brightness combination must supply every
required extension. Accessors should assert usefully in debug and provide a
deliberate Classic fallback in release rather than using pervasive `!`.

### Component tokens

These define reusable component treatments:

- cards and section containers
- buttons and icon buttons
- navigation and tab indicators
- dialogs and bottom sheets
- input fields, filters, chips, and switches
- media surfaces and image placeholders
- chart and progress treatments

Component tokens may refer to semantic tokens, but screens should not need to
know the raw palette values.

Prefer Flutter component themes whenever Material already owns the component.
Configure app bars, navigation, buttons, fields, chips, switches, list tiles,
cards, dialogs, sheets, dividers, snack bars, tooltips, progress indicators,
text selection, and focus treatment in `ThemeData`. Reserve Tonos component
recipes for genuinely custom structures.

### Geometry, depth, and effect tokens

The system must support more than color. Define tokens for:

- corner shapes and radii
- border width, style, and color
- spacing and content density
- elevation and shadow recipes
- surface tint and opacity
- blur amount, clipping, and fallback behavior
- motion duration, curve, and state transitions

Do not store widgets in tokens. Store immutable data and let reusable widgets
render the data.

Spacing should remain largely family-independent. Letting every family alter
all padding and dimensions would create a second responsive layout system and
multiply localization failures. Themes may choose from a small tested density
range and vary shapes, borders, and depth while preserving tap targets, content
order, and behavior.

### Typography tokens

Define an app text scale on top of Flutter's `TextTheme`, including display,
heading, body, label, numeric, and helper roles. Keep the scale compatible
with Bangla, Chinese, Hindi, French, Canadian French, and Spanish wrapping.
Avoid fixed heights that assume English text lengths.

Do not choose an expressive Latin font in isolation. Any bundled family needs
documented licensing, predictable asset size, and script coverage or explicit
fallbacks for every supported locale. Numeric workout data also needs tabular
number and alignment checks. Until approved, Classic typography and platform
fallbacks should remain unchanged.

## Flutter Architecture

The intended structure is:

```text
lib/theme/
  app_theme_family.dart
  app_theme_selection.dart
  app_theme_preferences.dart
  app_theme_factory.dart
  app_theme_capabilities.dart
  classic_theme_baseline.dart
  tokens/
    app_semantic_colors.dart
    app_shape_tokens.dart
    app_surface_tokens.dart
    app_motion_tokens.dart
    app_effect_tokens.dart
    app_data_visualization_tokens.dart
  themes/
    classic_theme.dart
    expressive_theme.dart
    liquid_glass_theme.dart
    neo_brutalist_theme.dart
    soft_tactile_theme.dart
  widgets/
    tonos_surface.dart
    tonos_card.dart
    tonos_section.dart
    tonos_action.dart
    tonos_field.dart
    tonos_sheet.dart
  theme_lab/
    theme_lab_page.dart
    theme_component_gallery.dart
```

The exact filenames may change, but responsibilities should remain separated:

- the existing provider coordinates selection and notifications;
- the preferences class owns storage and legacy migration;
- the factory selects a theme family and brightness;
- theme definitions supply tokens and standard component themes;
- reusable primitives render custom surfaces;
- feature screens provide content and actions only.

The large theme construction has been extracted from `main.dart` without
changing its values. Future alternate themes must be introduced through the
same boundary rather than by restoring inline construction.

### Factory and construction rules

`AppThemeFactory` should be the only place that assembles a complete
`ThemeData`. Theme files provide family-specific palettes and recipes, while
`AppMaterialTheme` provides the shared Material baseline and each definition
registers its required focused extensions.
The factory should cache the small finite set of family/brightness results so
ordinary provider rebuilds do not reconstruct both light and dark themes.

Set product-level framework choices explicitly, such as `useMaterial3`, page
transitions, and supported-platform adaptations. Do not globally restate every
ordinary Material component recipe when `ThemeData.from` already provides the
Classic behavior; those overrides become app-owned values and can silently
change parity. Changes to either framework defaults or app-owned recipes need
separate visual approval.

`MaterialApp` should receive the selected light/dark definitions and use its
normal animated theme path. Theme transitions must be short and centrally
configured; screens must not animate theme changes themselves.

### Compatibility bridge

The former `AppColors` bridge was intentionally temporary. Its values were
first preserved in the Classic definition, then migrated by feature slice to
focused non-null tokens, and finally removed after a repository-wide contract
proved that no production caller remained. New theme work must add a focused
semantic contract or a shared recipe rather than recreate a catch-all color
extension.

### Theme Lab

Build a development-only component gallery before designing Expressive. It
should render every meaningful state without navigating through real user data:

- color and typography roles;
- buttons, fields, chips, switches, list rows, cards, and navigation;
- dialogs, sheets, snack bars, loading, empty, warning, and error states;
- workout cards, set rows, timers, charts, measurement tiles, anatomy overlays,
  and media placeholders;
- enabled, pressed, focused, selected, disabled, and destructive variants;
- all supported locales, text scales, brightness modes, and reduced motion;
- effect-capable and effect-disabled renderings.

Theme Lab is the design and regression workspace. It must remain inaccessible
from normal release navigation.

## Classic Theme

Classic is a compatibility contract, not merely the fallback branch in a
conditional. Capture light and dark reference screenshots for stable screens,
then preserve:

- current colors and reviewed focused token values;
- current typography and density unless a deliberate correction is approved;
- current card, sheet, dialog, navigation, and button behavior;
- current layout and navigation behavior.

Existing users should select Classic automatically after the migration. No
database, catalog, workout, or export migration is required for a theme choice.

## Expressive Theme

Expressive should be built as the first test of the scalable system. It should
use deliberate choices around:

- more energetic but accessible color relationships;
- flexible typography and stronger hierarchy;
- contrasting, intentional shapes;
- expressive but restrained state transitions and motion;
- adaptive components that remain usable on small screens and with long text.

The first version should use stable Flutter theme APIs and the shared token
system. It should not depend on an uncontrolled SDK upgrade or require a
rewrite of every screen before it can be previewed.

Material 3 Expressive is more than a brighter palette. Its design direction
combines color, typography, contrasting shapes, adaptive containment, and
intentional motion. Tonos should first reproduce those principles with APIs
available in the pinned SDK. After the controlled Flutter upgrade, compare the
implementation with any newer Flutter-native Expressive components and adopt
them only where they improve behavior without fragmenting the token boundary.

## Future Theme Capabilities

### Liquid Glass

Support optional translucent surfaces, background blur, tint, highlights,
clipping, and an opaque fallback. Blur should be limited to high-value surfaces
because it can cost more on low-end devices. The fallback must remain readable
and visually intentional when blur is disabled, unsupported, or too expensive.

Never place `BackdropFilter` in every scrolling card or list row. Clip each blur
to the smallest required area, keep moving content outside repeated blur layers,
and test release-frame timing on physical low- and mid-range Android devices.
Glass must still expose clear boundaries, focus states, and readable content
over unpredictable exercise and food imagery.

### Neo-Brutalism

Support high-contrast fills, thick outlines, low or zero corner radii, hard
offset shadows, and clear pressed states. These should be surface and button
recipes, not custom decoration code copied into individual screens.

Hard shadows must not alter hit testing or produce accidental clipping. Pressed
offsets should be implemented in shared actions and respect reduced motion.

### Tactile or Soft UI

Support rounded geometry, layered directional shadows, subtle surface contrast,
and pressed or raised states. Contrast and focus indicators must remain strong
enough for accessibility rather than relying only on subtle depth cues.

Pure low-contrast neumorphism is not an acceptable accessibility fallback.
Inputs, selected states, disabled states, and buttons still need explicit
outlines or color relationships and cannot communicate affordance using shadow
direction alone.

## Reusable UI Migration

Migrate high-reuse surfaces before individual feature screens:

1. App scaffold, app bars, navigation, dialogs, sheets, and buttons.
2. Cards, sections, list rows, fields, chips, and switches.
3. Exercise catalog, exercise detail, dashboard, settings, and workout cards.
4. Charts, anatomy/media surfaces, measurement cards, and nutrition surfaces.
5. One-off feature screens and low-frequency experimental surfaces.

Use the current style concentrations to organize the work:

- **Foundation:** extract `main.dart`, harden `ThemeProvider`, replace unsafe
  extension access, and theme root navigation.
- **Shared controls:** migrate `settings_tiles.dart`, common dialogs, feedback
  surfaces, fields, buttons, sheets, and reusable cards.
- **Core training:** migrate Train, active-workout rows, exercise catalog,
  `exercise_detail_sheet.dart`, workout metrics, timers, and records.
- **Progress and dashboard:** migrate dashboard sections, measurements, health
  trends, charts, heatmaps, history, and analytics.
- **Creation and setup:** migrate onboarding, exercise editor, plan generation,
  profile settings, and maintenance tools.
- **Evolving products:** give nutrition, cardio, stretch, and experimental
  surfaces a narrow theme-ready compatibility boundary when needed, then apply
  their full Neo recipes after the product designs stabilize. Release themes
  must never navigate into an unthemed active surface.

During migration, replace direct application colors, fixed visual styles, and
duplicated shapes with semantic tokens or shared primitives. Keep legitimate
fixed colors for illustrations, branded media, and data visualization only
when they are documented and accessible.

Do not attempt a mechanical replacement of every `Colors.*` reference. Each
value should be classified as a semantic application color, a component token,
an intentional data color, or an allowed fixed asset color.

Maintain a machine-readable migration inventory with file, expression category,
owner token or component, status, and justification for any allowlisted fixed
value. A source contract should reject newly introduced structural colors,
radii, shadows, gradients, and text styles in migrated paths. Start in report
mode, establish a reviewed baseline, then tighten the contract per directory so
existing debt does not block unrelated work.

Local `Theme` widgets are allowed only for documented component variants. They
must derive from the parent theme with `copyWith`, preserve every required
extension, and be covered by a test. A locally generated unrelated color scheme
is a theme leak.

## Switching and Performance

Theme changes should rebuild through Flutter's normal inherited `Theme` path.
No custom rendering engine or CSS-like cascade is needed. Prebuild immutable
theme objects where practical, keep theme changes infrequent, and use a short
theme transition only where it improves continuity.

All expressive motion must respect `MediaQuery.disableAnimations` and any
future explicit in-app preference. `AppMotionTokens` should provide reduced
alternatives, normally zero or near-zero duration and non-spring transitions,
so individual screens do not contain accessibility branches. Avoid adding
blur, large shadows, or expensive effects to every list row. Profile Liquid
Glass and animation-heavy surfaces on low- and mid-range Android devices before
making them available.

Measure theme switching separately from normal screen rendering. Acceptance
should include no unthemed frame at startup, no layout shift when cached images
arrive, no lost focus or route state during a switch, and no repeated expensive
asset decoding caused by a theme rebuild.

## Localization and Accessibility

Theme names, descriptions, settings labels, and preview text must use ARB
localizations. Visual styles must not depend on English-only widths.

For every theme family and brightness combination, verify:

- text and icon contrast;
- focus, selected, disabled, error, and loading states;
- semantics and tap targets;
- large text and screen-reader behavior;
- Bangla, Chinese, Hindi, French, Canadian French, and Spanish layouts;
- reduced motion and low-capability effect fallbacks.

Color must never be the only signal for workout status, errors, progress, or
selection.

## Guardrails and Tests

Add automated coverage for:

- stable theme-family preference values and invalid-value fallback;
- preservation of the Classic theme contract;
- completeness of required tokens for every theme and brightness;
- contrast of semantic text, icon, focus, and state roles;
- widget primitives rendering under every theme combination;
- dialogs, sheets, navigation, forms, charts, and media placeholders;
- theme switching and persistence across restart;
- large text, long locales, reduced motion, and accessibility semantics;
- performance budgets for blur, shadows, image decoding, and transitions.

### Automated test layers

1. **Preference tests:** legacy `theme_mode` migration, stable family codes,
   invalid and future values, unavailable-family fallback, persistence failure,
   and no first-frame brightness mismatch.
2. **Factory tests:** every allowed family/brightness pair produces a complete
   `ThemeData`, every extension is present and non-null, and family codes are
   unique and immutable.
3. **Token tests:** semantic foreground/background pairs meet approved contrast
   thresholds; `copyWith` and `lerp` preserve every field; reduced-motion and
   no-effects variants are complete.
4. **Primitive widget tests:** every shared component renders and exposes the
   same semantics and actions across themes, brightness, disabled states, and
   large text.
5. **Release-surface tests:** representative settings, catalog/detail, Train,
   active workout, dashboard, measurements, dialogs, and failure states render
   under every release theme.
6. **Localization matrix:** target long French/Canadian French strings plus
   Bangla, Chinese, Hindi, and Spanish at text scales 1.0, 1.3, 1.6, and 2.0 on
   small and normal phone constraints.
7. **Golden tests:** capture only stable representative screens and Theme Lab
   components. Do not generate every screen-by-locale permutation or update
   baselines automatically in CI.
8. **Integration tests:** switch, restart, downgrade/unavailable fallback,
   system brightness change, route preservation, and release denial of
   experimental families.
9. **Physical-device checks:** TalkBack, focus visibility, motion reduction,
   blur/shadow performance, battery, memory, and low-end GPU behavior.

Contrast checks should use the project-approved accessibility policy, with
WCAG-style targets of at least 4.5:1 for ordinary text, 3:1 for large text, and
3:1 for meaningful non-text controls and focus indicators unless a stricter
platform requirement applies. Color must never be the only state signal.

Add a source contract or lint rule that flags new direct UI styling outside an
allowlist. The goal is to prevent new theme leaks without banning intentional
fixed colors in data visualizations or media.

Use goldens only for stable screens. Keep the visual matrix focused enough to
remain maintainable: Classic and Expressive, light and dark, plus a targeted
long-locale and large-text set.

### Classic parity gate

The architecture foundation is allowed to merge before an alternate theme only
if all of these hold:

- Classic is the only normal-user family and remains selected by default.
- Existing dark/light preferences survive and no startup flash is introduced.
- Extracted Classic `ThemeData` preserves reviewed colors, typography,
  component behavior, density, and navigation.
- Stable-screen before/after goldens or equivalent reviewed screenshots match,
  except for separately approved bug fixes.
- Analyzer, unit/widget tests, localization generation, release build, and
  physical-device smoke tests pass using the repository verification process.

## Delivery Path

The phases group the detailed steps; they are not a second independent backlog.
Existing phase numbers are retained where possible. Phases 9-11 are new required
gates inserted before alternate-family implementation.

| Phase | Scope | Status | Detailed steps |
| --- | --- | --- | --- |
| 0 | Classic evidence and style inventory | Baseline accepted; current comparisons and broader classification remain | 1-3 |
| 1 | Classic factory extraction | Implemented; recheck affected parity after refinements | 4 |
| 2 | Selection, startup, and availability | Implemented; original Q3 behavior accepted | 5-6, 17 |
| 3 | Focused token model and bridge retirement | Foundation complete; slice-driven extensions remain | 7-8 |
| 4 | Material boundary, Tonos primitives, Theme Lab | Implemented; compatibility and usage audit remains | 9-11, 17-18 |
| 5 | Release-reachable surface migrations | Q3 scope accepted; exhaustive current ledger remains | 12 |
| 9 | Close review findings and protect rendered Classic behavior | Original Q3 accepted; refinement closure remains | 17 |
| 10 | Enforce migrated boundaries and qualify shared behavior | Scoped verification accepted; broader enrollment remains | 18 |
| 11 | Approve alternate-theme readiness | Complete for agreed Q3 scope | 19 |
| 6 | Implement Neo-Brutalism in development | Implemented pilots; final review and route sweep remain | 13 |
| 7 | Selector and release qualification | Not started | 14-15 |
| 8 | Later theme families | Not started | 16 |

Initial execution order was 0-5 as needed, then 9, 10, 11, 6, 7, 8. Phase 11
has passed for agreed scope. Continue current refinement qualification and
route coverage using the consolidated roadmap before Phases 7 and 8.
The unusual numbering preserves references from earlier work; always use the
step ID when filing an individual task.

Phase 0 exits when reference conditions, approved deviations, and per-surface
ownership are recorded. Phase 1 exits when extraction and observed Classic
output agree. Phase 2 exits when invalid preferences, failed writes, and
overlapping requests all have deterministic behavior. Phase 3 exits when
registered contracts are complete; it does not imply every consumer is migrated.

Phase 4 exits when shared recipes preserve the different original component
variants and Theme Lab exercises them. Phase 5 exits only when every route
reachable in release, including dialogs and indirect navigation, has an owner
and evidence. A route may retain documented fixed media or data colors.

Phase 9 exits when the review closure matrix has no unresolved defect.
Phase 10 exits when migrated scope has enforceable checks and real consumers
pass behavioral, accessibility, and state-preservation checks. Phase 11 records
the evidence and approval needed to start Expressive. This is separate from
the later approval needed to expose Expressive to release users.

## Dependencies and Coordination

- Coordinate stable preference codes with the preference-schema backlog item.
- Coordinate fonts and visual assets with licensing/provenance review.
- Coordinate blur, animation, and image effects with performance baselines.
- Coordinate newer Material APIs with the controlled Flutter upgrade.
- Revisit deferred nutrition, cardio, and stretch styling after those product
  streams stabilize, but keep any release-reachable shell fully themed.
- Do not combine theme extraction with navigation, database, workout logic, or
  catalog behavior changes; smaller independent changes are easier to verify.

## Risks and Mitigations

- **Classic drift:** extraction subtly changes defaults. Mitigate with explicit
  values, resolved-theme tests, and approved visual references before cleanup.
- **Incomplete theme crashes:** nullable tokens or unsafe extension lookups fail
  at runtime. Mitigate with non-null contracts, factory completeness tests, and
  the temporary compatibility adapter.
- **Token explosion:** every widget gets a bespoke token. Mitigate by preferring
  `ThemeData`, semantic roles, and a small set of reusable surface recipes.
- **Layout regressions:** themes change spacing and type too freely. Mitigate by
  keeping spacing mostly global and testing long locales and large text.
- **Visual sameness:** overusing generic primitives makes every family a color
  swap. Mitigate by allowing bounded family recipes for shape, depth, effects,
  typography, and motion while keeping behavior stable.
- **Performance regressions:** glass, shadows, or motion overload scrolling.
  Mitigate with capability fallbacks, reduced-motion tokens, profiling, and
  effects limited to high-value surfaces.
- **Accessibility regressions:** soft or colorful themes lose contrast and
  affordance. Mitigate with semantic pair tests, explicit focus/border states,
  non-color cues, screen-reader checks, and manual review.
- **Framework churn:** building around APIs unavailable in Flutter 3.29.3
  blocks delivery. Mitigate by using stable `ThemeData` and `ThemeExtension`
  now, then adopting newer components behind the same boundary after upgrade.
- **Endless migration:** new hardcoded styles are added faster than old ones are
  removed. Mitigate with a baseline inventory and directory-by-directory CI
  enforcement.

## Historical First Implementation Slice

The following records the original extraction sequence, which has already been
implemented. It is retained to explain earlier decisions; do not recreate the
retired AppColors bridge or repeat extraction. The next work is Step 17, followed
by the remaining Step 12 batches and Steps 18-19.

1. Add Classic light/dark reference coverage for a small stable screen set in
   `classic-theme-baseline.md`.
2. Extract the exact current theme definitions from `main.dart`.
3. Add a cached `AppThemeFactory` that can currently return only Classic.
4. Keep `ThemeProvider`, settings UI, preference keys, and `AppColors` behavior
   unchanged in this slice.
5. Verify analyzer, full tests, localization generation cleanliness, release
   APK construction, and physical-device Classic parity.

Only after that slice is accepted should preference migration and the new token
extensions begin. This sequencing gives the architecture a clean rollback point
and avoids mixing visual design with foundation work.

## Detailed Step-By-Step Implementation Checklist

The steps below are the recommended working order. Complete and verify each
stage before starting the next. Classic is a permanent supported family through
the entire process: it is not removed when Expressive or later themes ship.

### Step 1: Declare the permanent Classic contract (complete)

1. Write down that the app's current production appearance is named `Classic`.
2. Treat both its current light and dark appearances as supported variants.
3. Record that Classic remains the default for new and existing users unless a
   later product decision deliberately changes that default.
4. Record that adding another family must never delete, restyle, or silently
   reinterpret Classic.
5. Separate approved Classic bug fixes from theme-system migration. If a visual
   correction is wanted, review and commit it independently so parity evidence
   remains meaningful.
6. Add this compatibility rule to theme tests and contributor documentation.

Completion evidence:

- the family is identified by the stable code `classic`;
- the document and tests describe Classic as permanent;
- no alternate theme work is needed to render Classic.

### Step 2: Capture the current visual and behavioral baseline (original accepted; current comparisons remain)

1. Select stable, release-accessible reference surfaces: root navigation,
   appearance settings, Train, active workout, exercise catalog, exercise
   details, dashboard/progress, measurements, a form, a dialog, a bottom sheet,
   an empty state, a warning, and a media fallback.
2. Capture reviewed light and dark screenshots at the same device dimensions,
   text scale, locale, seed data, and route state.
3. Record resolved theme values that are easy to change accidentally during
   extraction: `ColorScheme`, `TextTheme`, scaffold, app bar, navigation, card,
   dialog, sheet, input, button, chip, switch, divider, focus, and snack-bar
   themes.
4. Record all current reviewed light and dark color values that the focused
   contracts must preserve.
5. Add focused widget or golden coverage only for screens whose layout is
   stable. Keep screenshots for changing screens as manual references instead
   of brittle automated goldens.
6. Verify current dark/light persistence and startup behavior so any existing
   first-frame issue is known before architecture changes begin.

Completion evidence:

- Classic light and dark have reproducible reference conditions;
- intentional current behavior is distinguished from known defects;
- later parity checks do not depend on memory or subjective comparison.

### Step 3: Inventory and classify existing styling (in progress)

1. Generate a list of direct colors, color literals, radii, decorations,
   gradients, shadows, local `Theme` widgets, and direct text styles.
2. Classify each relevant expression as one of:
   structural theme styling, Material component styling, Tonos semantic
   styling, data visualization, illustration/media styling, or an intentional
   one-off exception.
3. Assign structural values to a future `ColorScheme` role, component theme,
   focused Tonos token, or shared primitive.
4. Document why fixed data, anatomy, chart, or illustration colors remain fixed
   and how their contrast and non-color meaning are protected.
5. Store the inventory in a mechanically checkable form so directories can be
   marked migrated without repeatedly auditing the whole repository.
6. Begin with reporting only. Do not fail CI for all existing style debt.

Current implementation status: the report-only inventory boundary is now in
place. `docs/theme-style-inventory.json` records ordered path rules,
classification/status metadata, explicit fixed data/media exceptions, and a
review queue. `tools/theme_style_inventory.dart` scans production Dart source
for style-bearing expressions and preserves file/line evidence; its contract
test ensures that every current candidate has a destination without claiming
that pending classifications are human-approved. The CI check fails only for
malformed inventory configuration or an unassigned candidate. Full screen
migration and subjective parity/accessibility decisions remain future work.

Completion evidence:

- every high-use styling hotspot has a migration destination;
- the project can distinguish theme leakage from legitimate fixed color;
- new migration work can be measured rather than guessed.

The first two outcomes are represented by explicit hotspot rules and
allowlisted data/media rules; the inventory is intentionally still report-only
until the Step 12 release-surface migrations are complete.

### Step 4: Extract Classic from `main.dart` (implemented; affected parity rechecks remain)

1. Create the initial theme folder and `themes/classic_theme.dart`.
2. Move the exact existing light and dark `ThemeData` construction out of
   `main.dart` without simplifying values, changing defaults, or redesigning
   components.
3. Add `AppThemeFactory` and have it return cached Classic light and dark
   instances.
4. Keep the existing `ThemeProvider`, `ThemeMode`, preference key, and settings
   switch unchanged in this step.
5. Keep `AppColors` registered with exactly the same resolved values.
6. Update `MyApp` to request Classic themes from the factory instead of building
   large theme objects inline.
7. Explicitly pin framework choices that affect appearance only when the pinned
   value matches the baseline.
8. Compare every stable reference and investigate any difference before moving
   forward.

Completion evidence:

- the app looks and behaves the same as before;
- `main.dart` no longer owns the visual definitions;
- Classic can be constructed and tested independently;
- no theme-family control is visible to users yet.

This step is implemented in `lib/theme/classic_theme.dart` and
`lib/theme/app_material_theme.dart`. The factory contract test covers cached
light/dark instances, brightness, and the complete focused extension set.
Physical screenshot parity remains part of the review evidence, not a reason
to duplicate the theme definitions.

### Step 5: Add stable selection and preference migration (implemented; original Q3 accepted)

1. Add `AppThemeFamily` with explicit stable codes, beginning with `classic`.
2. Add immutable `AppThemeSelection` containing family and `ThemeMode`.
3. Add `AppThemePreferences` as the only owner of appearance storage keys,
   parsing, defaults, and migrations.
4. Continue reading the existing `theme_mode` value so current users preserve
   their light/dark choice.
5. Stop deriving persisted values from enum `toString()` output. Parse and
   write explicit codes.
6. Add `theme_family`, default it to Classic, and safely handle missing,
   corrupt, removed, unavailable, and future values.
7. Keep unavailable stored family codes intact while rendering Classic, so a
   downgrade does not unnecessarily destroy the user's later preference.
8. Load the saved selection before the first themed frame or show a neutral
   bootstrap surface until it is ready. Do not flash dark before a saved light
   preference loads.
9. Decide whether the appearance selection is device-local or included in a
   settings export; document and test the decision.
10. Preserve the existing dark-mode API temporarily so callers can migrate
    without a disruptive provider rewrite.

Completion evidence:

- existing brightness preferences survive the migration;
- all invalid states render complete Classic safely;
- startup does not display the wrong theme first;
- no new family is exposed merely because its enum value exists.

This step is implemented by `AppThemeSelection`, `AppThemePreferences`, and
the evolved `ThemeProvider`. Appearance preferences remain device-local in
`SharedPreferences`; settings export/import can adopt the same explicit codes
later as a separate preference-schema decision. The family selector is exposed
only where the centralized availability policy reports an eligible complete
family.

### Step 6: Add centralized theme availability policy (complete)

1. Create `AppThemeCapabilities` to decide which families may be selected in
   the current build.
2. Make Classic unconditionally available.
3. Add a single development opt-in for unfinished themes if needed.
4. Ensure release mode rejects experimental families regardless of a mistaken
   build define.
5. Add a release contract test similar to experimental navigation protection.
6. Make settings obtain available families from this policy rather than from
   all enum values.
7. Fall back to Classic if a stored family is known but unavailable.

Completion evidence:

- unfinished themes cannot leak into release UI;
- feature screens contain no build-flag or family-availability branches;
- disabling an experimental family leaves the app usable.

This step is implemented by `lib/theme/app_theme_capabilities.dart` and the
provider integration. Classic and Neo-Brutalism are registered. Neo development
selection uses the experimental policy; internal release candidates require
the separate `TONOS_ENABLE_NEO_RELEASE=true` opt-in. Default release builds
retain Classic fallback. Future families require explicit policy implementation
before appearing in Theme Lab or a selector.

### Step 7: Introduce focused design tokens (foundation complete)

1. Add non-null extensions for semantic colors, shape, surfaces, motion,
   effects, and data visualization.
2. Decide which roles already belong in `ColorScheme` or `TextTheme`; do not
   duplicate them in Tonos extensions.
3. Name Tonos roles by meaning, not current color or visual treatment.
4. Populate every role for Classic light and dark using the captured values.
5. Implement and test `copyWith` and `lerp` for every field.
6. Add safe context accessors that produce a useful debug assertion and a
   complete Classic release fallback rather than an unexplained force-unwrap.
7. Define reduced-motion values and effect-disabled fallbacks as part of the
   token contract, not as optional cleanup later.
8. Keep dimensions that influence layout mostly shared across families.

Completion evidence:

- every registered family/brightness pair has a complete token set;
- missing extensions use safe fallbacks for isolated host themes and are covered
  by complete-family contract tests;
- Classic still matches its baseline after token registration.

This step is implemented by the focused extensions under
`lib/theme/tokens/`. Classic registers complete light and dark instances for
semantic colors, shape, surface recipes, motion, effects, data visualization,
flow diagrams, and nutrition-specific surfaces. `ThemeData` and `BuildContext`
accessors return complete brightness-aware fallbacks when an ad hoc host theme
omits an extension, while the factory and token tests enforce complete built-in
families. Reduced-motion and no-effects values are part of the token contracts.
The focused roles are now consumed directly; no compatibility extension is
needed to preserve the reviewed Classic appearance.

### Step 8: Bridge and retire the existing `AppColors` (complete)

1. Keep `AppColors` temporarily so the 8 remaining compatibility files do not
   need to change at once.
2. Populate the compatibility extension from the new Classic token definitions.
3. Add a contract that prevents new `AppColors` consumers after replacement
   accessors are available.
4. Migrate one feature slice at a time to `ColorScheme`, focused tokens, or
   shared components.
5. Make formerly nullable roles non-null during migration.
6. Remove individual old fields once repository search proves they have no
   remaining consumers.
7. Delete `AppColors` and the force-unwrapped `context.colors` accessor only
   after all consumers and exceptions have been accounted for.

Completion evidence:

- there is one authoritative token system;
- no production path can crash because a theme omitted an optional color;
- the temporary bridge is fully removed rather than maintained indefinitely.

Current progress: the reviewed legacy roles were migrated to focused,
non-null contracts. Flow-chart canvas, node, arrow, and action roles are owned
by `AppFlowTokens`; nutrition meal surfaces and text-detail borders are owned
by `AppNutritionTokens`; all former consumers use `ColorScheme`, focused
tokens, or shared primitives. The compatibility contract now scans all of
`lib/` and requires zero legacy matches. `app_colors.dart`,
`classic_app_colors.dart`, and the force-unwrapped `context.colors` accessor
are deleted, so no future family can fail because an optional legacy color was
omitted.

### Step 9: Establish Material component ownership (foundation implemented)

1. Keep ordinary Classic Material recipes inherited from `ThemeData.from`.
   Centralize only app-owned overrides proven equivalent to the original output.
   Future families may supply component themes through the factory, but do not
   restate all defaults or globally apply Tonos custom-surface values.
2. Remove redundant per-widget overrides after verifying they resolve to the
   same Classic output.
3. Review each local `Theme` subtree. Convert a legitimate variation into a
   named parent-derived variant and remove unrelated local color schemes.
4. Preserve semantics, enabled/disabled behavior, hit targets, focus order, and
   navigation while changing style ownership.
5. Add component tests for normal, pressed, focused, selected, disabled,
   loading, warning, error, and destructive states.

Completion evidence:

- ordinary Material widgets respond to a family through global themes;
- local styling is exceptional and documented;
- Classic parity remains intact.

Current progress: `AppMaterialTheme` is the shared factory boundary for every
family. It pins the Material 3 baseline and keeps the app-owned bottom
navigation recipe centralized. Ordinary app bars, sheets, dialogs, dividers,
FABs, buttons, fields, chips, switches, list tiles, progress indicators,
selection, and focus behavior inherit from `ThemeData.from(colorScheme: ...)`
instead of being globally copied into a second component-recipe layer. The
Classic tests explicitly guard this ownership boundary; local feature overrides
remain deliberate Step 12 migration targets rather than being changed silently.

### Step 10: Build a small set of Tonos primitives (implemented; adoption ongoing)

1. Use Theme Lab and the inventory to identify repeated custom structures.
2. Implement only high-value primitives such as `TonosSurface`, `TonosCard`,
   `TonosSection`, `TonosAction`, `TonosField`, and `TonosSheet` where Material
   components cannot express the required behavior.
3. Accept semantic variants such as standard, emphasized, warning, destructive,
   selected, or media rather than raw colors and arbitrary decorations.
4. Keep content, callbacks, semantics, focus behavior, and layout constraints
   in the component API; keep family-specific rendering in tokens and recipes.
5. Avoid making one wrapper for every existing widget or one giant component
   with dozens of unrelated flags.
6. Test primitives across Classic light/dark, long locales, large text, reduced
   motion, and effect-disabled conditions.

Completion evidence:

- a future family can change Tonos-specific surfaces centrally;
- feature widgets describe intent rather than constructing decoration;
- shared primitives do not erase necessary differences between screens.

Current progress: `TonosSurface` maps semantic panel, raised-panel, card,
compact-card, input, media, and media-placeholder variants to the active
surface, shape, and effect tokens. `TonosAction` provides primary, tonal,
outlined, destructive, and text recipes while delegating ordinary appearance
to standard Material button themes and resolving destructive colors through
semantic roles. `TonosSection`, `TonosField`, and `TonosSheet` now cover the
repeated titled-section, input-boundary, and sheet-boundary structures that
Material does not express by itself. All primitives retain feature-owned
callbacks, semantics, and layout constraints without accepting raw visual
values. Widget contracts cover Classic token resolution, light/dark behavior,
callbacks, semantics, and the shared effect/surface recipes.

### Step 11: Build the development-only Theme Lab (implemented; current review accepted)

1. Add a gallery that renders all standard Material components, Tonos
   primitives, data colors, typography roles, and interaction states.
2. Add controls for family, brightness, locale, text scale, reduced motion, and
   effects capability.
3. Include representative fitness components without requiring real user data.
4. Include visual stress cases: long translations, missing media, loading,
   offline, errors, disabled actions, dense lists, and large numeric values.
5. Ensure Theme Lab is available only through development tooling and cannot be
   reached in a normal release build.
6. Use it as the primary design-review surface for every new family.

Completion evidence:

- designers and developers can inspect a family consistently in one place;
- visual states are not discovered only through manual app navigation;
- release navigation has no Theme Lab entry.

Current progress: `ThemeLabPage` now provides a debug-only gallery for the
currently available family, light/dark preview, every supported locale, text
scales from 1.0 to 2.0, reduced motion, effects disabling, standard Material
states, Tonos surfaces/actions/sections/fields/sheets, typography roles, data
visualization roles, representative workout states, and visual stress states
for missing media, offline/loading, errors, disabled actions, dense rows, and
large values. Locale changes are scoped to the gallery through
`Localizations.override` and do not alter the persisted app preference. It can
be opened with the debug-only `TONOS_THEME_LAB=true` compile-time flag or the
`/__theme_lab` route; neither entry exists in release mode, and the page itself
renders an empty fallback if referenced from a release build. The gallery
exercises Classic and development-enabled Neo, including the Neo pilot gallery.
Shared production presentation, fixtures, representative media, and reset have
been added. The current Theme Lab and shared-pilot visual review is accepted.
Device-specific stress, accessibility, and release approval remain separate.
Widget coverage checks mounted lazy sections and pilot behavior.

### Step 12: Migrate release surfaces in vertical slices (in progress)

1. Start with root navigation and shared settings because they affect many
   routes.
2. Continue with Train and active-workout components.
3. Migrate exercise catalog, detail sheet, media states, records, and metrics.
4. Migrate dashboard, progress, measurements, charts, and health surfaces.
5. Migrate onboarding, exercise editing, plan generation, maintenance, and
   remaining profile settings.
6. Handle nutrition, cardio, stretch, and experimental areas with a theme-ready
   compatibility boundary when they are reachable, then complete their
   route-specific Neo designs after the product layouts stabilize.
7. For every slice, replace only presentation ownership. Do not mix in workout,
   persistence, navigation, or catalog behavior changes.
8. Verify Classic parity, semantics, locales, and large text before marking a
   directory migrated and enabling its CI style guard.

Completion evidence:

- every release-reachable route is token-driven;
- repository checks prevent new structural hardcoding in migrated areas;
- unfinished features cannot expose a partially themed screen in release.

### Step 13: Finish Neo-Brutalism (N1/N2 complete; current visual review accepted)

The user selected Neo-Brutalism first on 2026-09-11 and approved N1 revision 5.
N2 capabilities and the N3 registered family/Theme Lab implementation are
automated-verified. Original N4 real-route acceptance and the current 21-item
Neo visual review are recorded. Subsequent refinements need affected-surface
checks; N5 route-state/reachability and N6 qualification remain. Follow the
[consolidated checklist](theme-consolidated-roadmap.md) for current tasks and
the [Neo specification](theme-neo-brutalism-plan.md) for visual recipes.
The agreed Q3 gate has passed. The
Expressive-specific checklist below is historical guidance for a later family,
not the current implementation order.

1. Define the intended Tonos personality and where expression helps core tasks.
2. Design Expressive light and dark together rather than deriving one at the
   end.
3. Create accessible primary, secondary, tertiary, surface, state, and data
   relationships.
4. Define a deliberate shape system with contrasting containment rather than
   applying one large radius everywhere.
5. Define typography hierarchy with proven glyph fallbacks for every locale.
6. Define centralized motion recipes and a reduced-motion alternative.
7. Choose a limited set of meaningful hero moments, such as starting or
   completing a workout; keep logging interactions fast and calm.
8. Implement Expressive only through `ThemeData`, tokens, component recipes,
   and shared primitives. Do not branch inside feature screens.
9. Confirm the repository's actual Flutter/Dart versions and dependency lockfile
   before selecting APIs. CI currently pins Flutter 3.29.3; confirm the local SDK
   as well. Handle any SDK upgrade as a separate reviewed change and refresh
   Classic parity evidence against that SDK.
10. Keep Expressive development-only until every active release surface passes
    the qualification matrix.

Completion evidence:

- Expressive is a coherent visual family rather than a color swap;
- Classic remains unchanged and selectable;
- feature behavior and data are identical between families.

### Step 14: Add the user-facing theme selector (implemented; current development qualification accepted)

1. Add localized names, concise descriptions, and previews for approved
   families to UI and Appearance settings.
2. Keep brightness selection independent, preferably supporting System, Light,
   and Dark once behavior is approved.
3. Show only families approved by `AppThemeCapabilities`.
4. Apply selection predictably and preserve current route, scroll position,
   focus where reasonable, and unsaved form state.
5. Provide an immediate route back to Classic if a user dislikes or cannot use
   another family.
6. Persist only after successful selection handling and surface a recoverable
   warning if preference storage fails.
7. Do not require network access to select or render bundled themes.

Completion evidence:

- users can switch approved families without restarting or losing work;
- family and brightness remain separate settings;
- Classic is clearly available as the familiar permanent option.

Current implementation record (2026-09-16): `UIAppearanceSettingsPage` uses the
capability-filtered `ThemeProvider.availableFamilies` list, a compact preview
of each family at the active brightness, and the localized `TonosChoiceDialog`
radio control. Selection persists through
`ThemeProvider.setFamily`, preserves the independent brightness mode, keeps the
previous value after a failed write, and offers localized retry guidance.
`test/theme/theme_family_selector_test.dart` covers selection, restart,
downgrade, unavailable values, failed writes and bundled locale copy. User-run
automated verification and the user's current human visual, accessibility,
and N6 device acceptance are recorded above. The Step 15 Android internal
candidate is accepted; only its tested-source commit/hash association remains.

The first expanded verifier rerun also exposed a 129 px right RenderFlex
overflow in the Neo food editor at 320x640/2x text in both brightness modes.
The bottom extended-action row now wraps on narrow layouts; the subsequent
focused and expanded reruns passed.

### Step 15: Qualify themes for release (Android internal candidate accepted; commit association pending)

The user accepted the signed Android internal/closed candidate on 2026-09-23;
all six focused device checks passed. The candidate uses application ID
`com.tonos.internal`, version `1.0.1+6`, and SHA-256
`549BE2C9EDD96E44840C7E42976BDF436C29B3F53DC9C946FA043EB3EC68615D`. Neo is
enabled through `TONOS_ENABLE_NEO_RELEASE=true`; Classic remains the default.
The APK source tree was based on `55b0222071645392e1c66d5e01c5f8b3eaf10f11`
with working-tree changes. Commit the exact tested source and associate that
commit with the APK hash before closing the internal Step 15 gate. This is not
approval for open testing or a Play Store release. See the [current candidate
record](theme-consolidated-roadmap.md#step-15-qualify-themes-for-release) and
[execution checklist](testing.md#neo-internal-android-release-candidate).
Accepted development evidence is reused for unchanged surfaces.

#### Broader release qualification (later open/Play release; not an internal-candidate blocker)

1. Run preference, factory, token, contrast, primitive, release-surface,
   localization, golden, integration, and release-policy tests.
2. Verify small and normal phones, all supported locales, and text scales 1.0,
   1.3, 1.6, and 2.0.
3. Perform manual TalkBack checks for labels, focus order, selected state,
   disabled state, dialogs, sheets, and switch controls.
4. Verify reduced motion and confirm color is not the only state signal.
5. Profile startup, switching, scrolling, image decoding, memory, frame timing,
   battery, shadows, and blur on low- and mid-range physical Android devices.
6. Test process restart, corrupt preferences, downgrade to a build without the
   selected family, and release denial of experimental families.
7. Build and install a signed release candidate and repeat the navigation smoke
   test using Classic and every proposed release family.
8. Record visual, accessibility, performance, localization, and product signoff
   before enabling a family in release settings.

Completion evidence:

- every enabled family has complete release evidence;
- release configuration cannot expose an incomplete theme;
- Classic still passes the same release matrix.

### Step 16: Add later theme families through the same boundary (not started)

1. Start each family in Theme Lab and identify whether it needs a genuinely new
   reusable capability.
2. Extend the token contract only for a capability that cannot be represented
   semantically by existing roles.
3. Add complete light/dark, reduced-motion, and effects-disabled definitions.
4. For Liquid Glass, limit clipped blur to high-value surfaces and provide an
   opaque fallback.
5. For Neo-Brutalism, centralize thick outlines, hard shadows, and pressed
   offsets while protecting clipping and tap targets.
6. For Soft Tactile, retain explicit borders, focus, selection, and contrast;
   never rely only on low-contrast shadow direction.
7. Run the full qualification process independently for the new family.
8. Keep Classic and all previously approved families available unless a
   separately reviewed retirement policy is ever created.

Completion evidence:

- adding a family primarily means supplying theme definitions and recipes;
- no feature-specific family conditionals are required;
- new effects degrade safely on lower-capability devices.

## Required Pre-Alternate-Theme Work Packages

These instructions describe work to perform, not changes already implemented.
The baseline for visual comparisons is the pre-extraction recipe plus explicitly
approved deviations, including the readable light anatomy correction. Never
update an expected value merely to make a changed implementation pass.

### Step 17: Close the review findings and add consumer parity evidence (current affected development scope accepted)

The following matrix records the original review assessment. The user accepted
the current 21-item Neo visual review and the human/device/N6 qualification,
including affected Classic parity, on 2026-09-17. Actions in the matrix are
historical remedies or regression requirements, not open findings. Reopen only
if a later change affects the scope or a defect is reproduced.

The original eight findings had the following closure status:

| Finding | Current assessment | Remaining action |
| --- | --- | --- |
| 1. Timer typography | Source fix present | Keep ThemeData-derived text at the original 20/48 sizes; cover a rendered timer in light/dark |
| 2. Startup preference failure | Source fix and focused tests present | Retain invalid-type and unavailable-store fallback; add production load failure coverage if absent |
| 3. Global Material defaults | Source fix present | Preserve framework defaults and test resolved representative components |
| 4. Settings recipes | Mostly restored | Correct status-badge outline; retain distinct settings surface and save-bar recipes |
| 5. Drawer/session recipes | Mostly restored | Restore Classic main-drawer heading color; retain restored profile geometry and session colors |
| 6. Quick bar | Radius/divider restored | Retain scaled 24px radius and onSurface alpha 0.12 divider; verify consumer geometry/interaction |
| 7. Write failures | Individual failures handled | Serialize overlapping selection requests and test error/retry ordering |
| 8. Baseline coverage | Improved, incomplete | Add rendered consumer comparisons and enforce evidence before declaring scope migrated |

#### 17.1 Restore the remaining Classic colors

Historical repair specification: implemented in the current source. Keep the
outlined relationships below as regression requirements; re-open only if new
evidence shows a failure.

In `lib/widgets/settings_tiles.dart`, `SettingsStatusBadge` currently uses
`surfaceTokens.subtleOutline`. Classic assigns that shared role fixed gray
values in `lib/theme/classic_theme.dart`; the original Profile badge used
`colorScheme.outlineVariant`. Change this badge to the original scheme role.
Do not change the global subtleOutline token, because other migrated consumers
may intentionally depend on its fixed Classic gray.

Update `test/theme/widgets/settings_tiles_test.dart`: assert the original
outlineVariant relationship under actual Classic light and dark themes.
A custom-token forwarding test can remain, but it must not be used as evidence
that the substituted gray matches Classic.

In `lib/widgets/drawers.dart`, the main drawer heading changed from white to
`scheme.onPrimary`. Restore white for Classic through an appropriately named
drawer-header foreground recipe in the shared boundary. Use a focused semantic
role only if needed to let future families vary that color. Populate both
Classic variants with the original white value and update completeness,
copyWith, and lerp coverage if a field is introduced. Do not globally alter
ColorScheme.onPrimary to repair one heading.

Render MainDrawer with an explicit header string and verify its foreground and
18px size under both Classic variants. Record a contrast improvement separately
if the original white-on-primary treatment is later redesigned; this migration
does not authorize that design change.

Implementation batch status (2026-09-07): Step 17.1, the provider/persistence
portion of Step 17.2, and the automated Step 17.3 consumer parity work have
source changes and focused regression tests. The consumer parity suite covers
settings surfaces and save bars, profile tiles, timer typography, QuickBar
geometry, and ongoing-session actions and dialogs under both Classic brightness
variants. The startup-load failure seam and regression test are also complete.
The previous focused verification completed with 103 tests passing, no analyzer issues,
and only the repository's existing LF/CRLF warnings from git diff --check.
Remaining Step 17 work is any explicitly listed manual visual/device evidence;
Step 17 is not complete until that evidence is resolved or recorded.

#### 17.2 Make selection writes deterministic

Historical repair specification: the current provider already shares a
mutation queue, evaluates equality inside queued work, and handles disposal.
The preference tests cover ordering, failed writes, duplicate requests, and
disposal. Preserve these contracts; do not add another queue during migration.

Primary files: `lib/providers/theme_provider.dart`,
`lib/theme/app_theme_preferences.dart`, and
`lib/screens/profile/settings/ui_appearance_settings_page.dart`.

The current early equality check uses committed state while another write may
still be pending. Example: committed dark -> request light -> request dark
before light persists. The dark request currently returns early, allowing the
older light request to win.

Implement a provider-owned queue shared by mode and family mutations. Evaluate
equality and capabilities inside the queued operation, after earlier operations
settle. Preserve the other dimension from the latest committed selection when
applying each operation. Keep the queue usable after rejection; each caller
must still receive its own error. Avoid independent queues or stale copies of
the full selection that can overwrite a more recent mode/family value.

Commit and notify only after a successful write. A failed write must leave the
previous committed selection visible and allow a later request to succeed.
Do not rely on disabling one settings switch to make the provider correct for
other callers. A pending indicator/disabled control is optional UX and must
preserve feedback and accessibility if added.

Use controllable futures in meaningful tests for:

- dark -> light -> dark while the first write is unresolved;
- multiple different requests completing in the intended order;
- failed first request followed by a successful queued request;
- duplicate requests without redundant notifications;
- mode/family composition when a second real family is eventually introduced;
- no listener notification after disposal during asynchronous completion.

Review disposal in the async constructor and production injected provider
ownership. Add disposal handling only where the real lifetime requires it;
avoid introducing a second owner for a provider passed through Provider.value.

Keep storage reads tolerant of wrong types and unavailable stores. Review
`_restoreValue` before describing rollback as guaranteed: it currently restores
strings or removes the key, and restoration errors are swallowed. Preserve any
supported pre-existing value type if rollback is attempted; do not delete a
wrong-type value simply because a replacement write failed. Keep restoration
within the serialized operation so it cannot overwrite a newer successful
write. Report the original persistence failure and document restoration as
best effort. Startup family-key materialization must remain nonfatal.

#### 17.3 Protect rendered behavior, not only token definitions

Retain `classic_theme_baseline_test.dart` and `app_material_theme_test.dart`
as low-level contracts. Add focused consumer tests that would fail for the
specific original regressions: badge outline, drawer text, settings hero/section
surfaces, decorated versus plain save bars, profile-tile shape/motion, timer
typography, quick-bar scale/dividers, and ongoing-session action/dialog recipes.

Use actual Classic themes for parity tests. Compare against independent original
values or a small pre-extraction fixture, not against the same token the widget
reads. Test injected non-Classic-looking token values separately to prove
adoption. Keep those two purposes distinct.

For standard Material components, null theme overrides prove ownership but not
rendered dimensions or colors. Pump representative app bars, dividers, dialogs,
sheets, and FABs under Classic and an equivalent original ThemeData fixture on
the same SDK. Compare relevant resolved behavior. Use goldens only for stable,
deterministic compositions with controlled fonts/media and approved references.

Exit: all review defects have a regression test or documented verification
method, the focused suite passes, and any remaining manual evidence is explicitly
listed. The review is not closed solely because the scoped test suite passes.

### Step 12 Expanded: Complete the extraction and migration backlog

The inventory is the starting map, not proof that a whole file is done.
For each batch, enumerate release entry points, dependencies, dialogs, sheets,
empty/error states, and shared widgets before changing presentation ownership.

#### 12A. Application shell and settings

Review follow-up: settings tab indicators and scope icons now have independent
shape roles instead of sharing compact input geometry. Classic retains 14px
for both. The shared save bar resolves the reduced-motion duration from
MediaQuery. Shape tests now use distinct overrides and exact interpolation
expectations for every radius role. The latest save-bar and outlined-field
extractions are now formatted, analyzer-clean, and covered by the previous
103-test theme/provider verification. The current parity batch awaits the same
user-run verification gate.

Implementation batch status (2026-09-07): The tutorial-settings expandable
section is now owned by the shared settings primitive and has focused geometry
and expansion tests. The body-part and muscle ranking screens now share
SettingsRankingTile, including drag affordance, anatomy icon badge, panel
surface, outline, spacing, and compact rank-input geometry. The distinct
settingsPanel and settingsInput shape roles are covered by the Classic
baseline and token contracts, and the shared ranking behavior has a focused
widget test. Standard 16px settings fields now use the separate settingsField
shape role across the shared input decoration, body-part/muscle mapping,
nutrition manual entry, and volume boundaries forms. This keeps standard form
geometry independent from compact ranking inputs. Exercise analytics allocation
tabs, credit cards, source pills, and icon badges now resolve repeated geometry
through existing semantic roles. The active progression-flow and flow-method
cards now use the same semantic shape roles for their repeated surfaces and
icons.
The active exercise-editor path now does the same for its tabs, selected
definition header, allocation shortcut, body-part icon, and landing title
card. The unique picker and legacy-editor recipes remain explicit until they
receive deliberate roles. The repeated 20px exercise picker and 13px settings-icon
recipes now have named roles shared by analytics, the exercise editor, and
flow methods. The reachable exercise-editor landing title card now has its
own 24px shape role while retaining the Classic hero surface recipe. Database
health rows now use dedicated semantic health-status roles that preserve the
original Classic green/orange values and allow future families to adjust them.
The shared save bar now owns both the existing single-action recipe and the
repeated undecorated cancel/save recipe. Body-part ranking, muscle ranking,
body-part/muscle mapping, exercise editing, and manual nutrition goals use that
boundary without changing their callbacks, disabled states, progress indicators,
or 8px top padding. The compact outlined field recipe is also shared by mapping,
manual nutrition goals, and volume boundaries while retaining the existing
unfilled appearance and settingsField geometry.
SettingsAccent is now classified as a stable category-identity palette rather
than arbitrary decoration: its training, progress, data, safety, advanced,
account, appearance, and muted meanings must remain distinct. Future families
may provide contrast-safe variants, but should not collapse these roles into
one primary or success color. The profile drawer's fixed gym-profile colors are
also now named as ProfileIdentityPalette and documented as identity data rather
than theme-state colors; their visual treatment remains a manual review item.
The broader profile-settings subtree and remaining local control overrides
still require slice-level review.
The latest bounded settings batch extracts the identical flow-methods and
workout-progress legend chips into SettingsLegendChip, and the repeated
flow-methods count treatment into SettingsCountBadge. Tutorial reset labels
and analytics allocation-source labels now use SettingsAccentPill; the
tutorial reset variant retains its stronger border, padding, and weight while
the analytics source variant retains its borderless compact treatment and
external spacing. Focused widget tests and source contracts cover the shared
variants and consumer adoption; user-run formatting, analysis, and tests remain
the verification gate for this batch.
The follow-up exercise-editor slice extracts the repeated padded outlined add
action into SettingsInlineActionButton. Muscle, body-part, equipment, and
reference-media sections now share that wrapper while preserving their
nullable callbacks, labels, add icons, intrinsic button sizing, and 12px
section padding. The catalog/create actions and flow-method colored actions
remain local because their placement or button styling is intentionally
different.
The current batch adds Classic light/dark parity tests covering the shared
accent, legend, count, and inline-action primitives, both settings field
helpers, and the dual save bar's cancel/save order, disabled state, and
progress icon. These tests prove the shared boundary resolves Classic roles
without asserting that every future family must use the same fixed color
values.
This settings slice moves the active exercise-editor name, rating, and
guidance fields, plus the repeated analytics allocation-card inputs, onto the
shared settingsFieldDecoration boundary. The route contract now protects the
shared shell adoption across UI Appearance, User Information, navigation
editing, Profile, database, diagnostics, tutorials, analytics, and the
exercise editor. Custom/media dialogs, flow/database dialogs, the legacy
editor form, and transparent reorder/tab surfaces remain intentionally local
until their visual roles are separately reviewed; they are not accidental
migration omissions.
The duplicated profile-scope, plan-scope, and add-set action colors in the
progression-flow settings now resolve through AppFlowTokens. Classic keeps
their reviewed light/dark values, while other families can provide
contrast-safe variants without changing the flow behavior or category
meaning.

Work through `lib/main.dart`, `lib/widgets/drawers.dart`,
`lib/widgets/settings_tiles.dart`, and `lib/screens/profile/settings/`.

- Close Step 17 first. Preserve the navigation editor's undecorated save bar
  with 10px top padding and User Information's tinted, animated save bar with
  12px top padding.
- Classify SettingsAccent category colors and the gym/profile identity palette.
  Decide whether each is a theme-adjustable category role or intentionally
  stable identity data. Record the decision; do not replace all categories with
  primary or success colors.
- Inspect local Theme and control overrides across settings. Extract a named,
  parent-derived variant only where repeated or meaningfully family-dependent.
  Preserve existing spacing, typography, field borders, validation, disabled
  state, and switch behavior.
- Verify the new shared save-bar and outlined-field boundaries under both
  Classic brightness variants, including cancel/save ordering, disabled states,
  progress indicators, and form validation.
- Cover UI Appearance, User Information, navigation editing, Profile, database,
  diagnostics, tutorials, and specialized editing/settings routes reachable
  from these pages. Do not mark the entire settings directory migrated after
  only the shared tile file is changed.
- Audit main navigation and shared feedback for color, elevation, and typography
  ownership while preserving selected-tab state and active-workout continuity.
- Review the remaining deliberate local recipes: database and flow-method
  dialogs, exercise-editor legacy/developer-only cards, analytics allocation
  controls beyond the source label, transparent reorder/tab dividers, and
  specialized in-section save buttons. Extract them only when a repeated
  family-dependent role is clear; do not flatten category accents or
  framework-default dialog styling.

#### 12B. Train, plans, and active workouts

B1 implementation record (2026-09-08, scoped-verified): `PresetBar` now
uses `WorkoutThumbnailFrame`, whose `presetFocus` surface preserves the original
scheme-surface alpha 0.35 while keeping its 60 * scale size, 3 * scale padding,
and 10 * scale radius. The swap sheet's inherited `bodySmall` equipment copy
keeps its original color and now obtains alpha 184/255 from
`swapSecondaryTextOpacity`. The scaled geometry, automatic-badge typography,
and preset-name input's explicit 20px bold style were reviewed and intentionally
kept local because they are scale-sensitive or one-off. Token copy/lerp,
light/dark rendering, injected surface values, source adoption, and child/layout
preservation are covered by the new focused tests. User-run verification passed
with clean analysis and 134 scoped tests; B2 is next.

B2 implementation record (2026-09-08, scoped-verified): `TrainPage` now
routes the profile avatar identity color through the fixed profile palette and
routes the train-tab and split-workout divider opacities through named surface
roles. `PresetsLoaded` now uses a dedicated fixed plan identity palette and a
named plan-reveal border opacity. `PresetInfoCard` was audited and kept its
existing data-visualization, surface, semantic-content, inherited-card, and
standard Material ownership. The original 0.75, 0.18, and 0.45 opacity values,
plan ordering/filtering/reveal behavior, selected profile, popup actions, and
split workout callbacks are unchanged. Focused Classic, override, interpolation,
palette, and source-adoption tests cover the batch; user-run analysis passed
cleanly and the focused suite passed with 136 tests. This is scoped verification
only; no device review or full-repository qualification is implied.

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

B6 route/evidence implementation record (2026-09-08, scoped-verified): the
production shell, current Train route, legacy `Train2Page`,
and `PresetGenerationQaScreen` callers were traced without changing navigation
behavior. `MainScreen` maps both Train pages explicitly; `/main` remains the
normal release route. Theme Lab remains protected by the compile-time flag,
`kDebugMode` home selection, debug-only route registration, and its own
debug-mode widget guard. The unfinished nutrition/history/form tabs remain
denied in release builds through `NavigationBuildPolicy`.

The trace confirms that `Train2Page` is legacy but currently release-reachable
when a user enables `TabItem.train2`; it is not classified as experimental by
the navigation policy and must not be documented as developer-only without a
separate product decision. `PresetGenerationQaScreen` is release-reachable
from the current Train page, legacy Train2, dashboard plan generation, and the
onboarding plan-generation path. Session completion and saved-session detail
callers are also recorded. A dedicated source contract in
`test/theme/b6_route_evidence_test.dart` protects these entry points and the
release/debug gate distinction. Catalog/detail-sheet work remains assigned to
C1-C3, tutorial overlay work remains assigned to E1, and residual 12A settings
classification remains outside B6. No inventory-manifest classification was
changed because this batch adds route evidence rather than declaring additional
styling migrated. User-run formatting and analysis reported no issues, the
focused suite passed with 141 tests, and diff-check reported only existing
line-ending warnings. No device or full-repository qualification is implied.

C1 catalog/media implementation record (2026-09-08, scoped-verified):
`AppSurfaceTokens` now owns separate
`catalogSelection`, `catalogUsage`, and `catalogOutline` roles for catalog
structure, plus `mediaFrame`, `mediaPlaceholder`, and `mediaOutline` roles for
the two thumbnail owners. `ExerciseCatalogPage` keeps its selected-row alpha
0.45, border widths, selection callback, filtering, and exercise-detail action
while resolving selected and unselected catalog treatments through focused
roles. `CatalogPage` keeps the usage-row alpha 0.65 and border through catalog
roles. `ExerciseMediaThumbnail` and `SharedEntityMediaThumbnail` keep their
sizes, caller-supplied radii, padding, fit/scale, cache refresh, missing-file
recovery, fallback, Wi-Fi-only, retry, and localized semantics behavior while
moving frame and transient media-overlay colors to media roles.

`MuscleFilterPage` continues to own bodypart/muscle-specific fallback content
and sizes. The C1 source contract covers role adoption, Classic-derived
defaults, copy/interpolation, and preserved fallback/retry paths. The
inventory manifest remains report-only and unchanged; this batch does not
alter catalog localization, database identities, artwork, or route behavior.
User-run formatting and analysis reported no issues, the focused suite passed
with 148 tests, and diff-check reported only existing line-ending warnings. C1
is scoped-verified at the scoped automated level; device review of real and
missing media and full-repository qualification remain pending.

C2 detail-tabs/form-guide/metrics/records implementation record (2026-09-08,
implemented-awaiting-verification): `exercise_detail_sheet.dart` now routes
its custom form-guide cards, tags, metrics selector, metric summaries,
rep-best list, loading/error/empty state card, saved-record cards, record
actions, chart surfaces, chart grid/tooltip treatments, and sheet
elevation/geometry through focused surface, shape, motion, and effect roles.
Classic values are unchanged, including the existing detail surface and
opacity recipes, 9/10/11/13/15/16/18px radii, 160ms selector/chart motion, and
elevation 12. Material `TabBar`/`TabBarView` ownership remains intact. Data
series colors, anatomy heatmap, image preview, zoom viewer, scrims, and media
fallback chrome remain outside this batch for C3 or data-visualization
ownership. `test/theme/exercise_detail_contract_test.dart` protects role
adoption, Classic-derived defaults, copy/interpolation, tab/state evidence,
and empty/loading/error paths. User-run verification, device review, and
full-repository qualification remain pending.

Small swap-action batch (user verified: clean analyzer, 130 scoped tests passed): the swap sheet now delegates only
Cancel/Confirm button presentation to WorkoutSwapAction. Dedicated semantic roles
retain redAccent cancel, green confirm, and white confirm text in Classic. The
original 14px vertical padding, Material defaults, nullable confirm callback,
selection logic, Navigator result, outer spacing, and SafeArea are unchanged.
Light/dark recipe tests cover these styles, custom token values, interpolation,
callbacks, and disabled confirmation. Swap match badges, bodypart dots, and card
styling were outside that batch.

Swap visual follow-up (user verified: clean analyzer, 132 scoped tests passed): equipment filtering now uses
WorkoutEquipmentFilter, preserving the existing switch behavior, label styling,
padding, and disabled state. Its fill reuses planFilter and its corners reuse
card geometry. A dedicated swapFilterBorder opacity preserves outlineVariant
at 0.55; do not substitute the shared divider color, which Classic overrides.
WorkoutMatchBadge and WorkoutMatchMarker use a dedicated swapMatch accent
(Classic green); badge fill and border retain alpha 30/255 and 110/255 through
surface roles, with the shared pill radius. Score clamping, rounding and
localization stay in the consumer. Comparison cards continue to inherit the
Material Card theme; no explicit geometry override was necessary there.

Rendered light/dark tests cover original colors, padding, dimensions, typography,
injected roles, filter callbacks and disabled state, plus token interpolation.
The user-run analysis and scoped tests passed. Step 12B remains in progress;
comparison text opacity and remaining workout consumers still need auditing.

The preceding change-set/exit-action batch is now user-verified: analyzer clean,
128 scoped tests passed, and diff check reported only line-ending warnings.

Previous verified batch: WeightCard's compact add-change-set
action and the completed-work exit dialog's save/discard buttons now use shared
workout action recipes. Classic retains the blueAccent change-set border, 4px
corners, existing padding and text-only tap target; the consumer retains its
outer spacing and model-update callback. The exit dialog retains Material error
color (not the exit FAB's red), 70% outline opacity, 48px minimum button height,
18px icons, and unchanged save/discard/remember decisions.

New roles cover the change-set border color/corners and discard outline opacity,
including copyWith and interpolation. Dedicated light/dark tests cover Classic
values, injected overrides, callbacks, and disabled exit actions. This batch
was user-verified with 128 passing scoped tests and a clean analyzer.
Step 12B remains in progress: these extractions do not
constitute full active-workout migration or visual parity sign-off.

Audit `train_page.dart`, `session_screen.dart`, `session_detail_screen.dart`,
`session_complete_sheet.dart`, `ongoing_session_fab.dart`,
`active_session_durability_banner.dart`, and their plan/set widgets.

- Retain Overview/Plans text sizing and weight; a shared pill radius must not
  force a new text role. Preserve the split Start Workout/Optimize recipe.
- The split start action now owns its Classic green through a semantic role, and
  plan-generation bars use a data accent role without changing their callbacks.
  Keep this separation when adding other families. The current bounded batch also adds `workoutSection` and `planCard` shape/surface roles, moves the optimized Start Now action and preset-detail edit state onto semantic roles, tokenizes the plan-management tile and count pill, scales the plan reveal control from the shared card shape, and routes completion set-group geometry through the workout-section role. User-run formatting, analysis, and tests remain the verification gate for this batch.
- Completion headlines, session metric accents, record badges, and saved-session
  edit state now resolve through focused semantic/data roles, and repeated
  workout metric tiles use the shared metric shape. Extend those roles only
  when a repeated meaning is clear; do not collapse record tiers or metric
  categories into one generic accent.
- Record badge geometry now uses dedicated full and compact shape roles, and
  premade-plan count/swap badges share the pill role. Automatic-flow control
  cards now use dedicated flow surface and geometry roles while the premade
  duration control reuses plan geometry. Premade filter, duration, and group
  surfaces now have separate surface roles that preserve their Classic alpha
  recipes. The premade onboarding action bar, optimized-workout floating action,
  and reusable metric-chip surface also resolve through focused surface roles.
  Keep badge colors owned by data-visualization tokens and keep plan-flow
  surfaces separate from record meaning when migrating the remaining plan screens.
- Review corrections: editing icons use independent `editingActive` and
  `editingInactive` semantic roles (Classic green/grey); saved-session inactive
  icons retain inherited coloring. The onboarding plan-bar border retains
  `ColorScheme.outlineVariant` at 0.6 opacity because Classic `subtleOutline`
  represents a different gray. Both automatic-flow loopback creation paths
  now use `flowTokens.loopback`.
- Regression coverage now includes rendered plan-bar borders, surface overrides,
  enabled/busy actions, metric-chip surface/shape overrides, and exact surface
  interpolation values. User verification passed with clean analysis and 114
  tests after the review fixes.
- The next completion slice moves metric fill/border, set-marker fill, and
  exercise-group fill/border opacity into independent surface recipes. Classic
  retains 0.15/0.30, 0.20, and 0.10/0.52 respectively. Saved-session summary
  tiles use `sessionSummary` rather than forcing opacity onto `panelRaised`.
  User verification passed with clean analysis and 115 tests.
- Finish and Done now use dedicated workout action components, retaining their
  elevated/filled Material recipes, original button keys, and callbacks. Finish
  keeps its disabled 20-pixel spinner; Done keeps its 48-pixel minimum height.
  The 36-by-4 completion handle uses its own surface role. First-record and
  record-tier badge fill/border opacity now has independent surface roles,
  preserving Classic 0.12/0.72 and 0.14/0.62 respectively. Rendered tests cover
  actions, busy state, compact badges, and surface overrides in both modes.
  User verification passed with clean analysis and 122 theme/provider tests.
- The active WeightCard now resolves completed-workout color, completion-card
  and completed-set opacity, change-set outlines, set-row geometry, and
  thumbnail/fallback geometry through focused semantic, surface, and shape
  roles. Its Classic defaults preserve the existing green, grey, alpha, and
  10/12px radius values; callbacks, numeric editing, checkbox behavior,
  collapse behavior, and persistence remain local to the widget. Rendered and
  token-contract coverage has been added and the subsequent scoped suite passed.
- Continue auditing completion sections, dialogs, shadows,
  and set-row surfaces into existing appropriate roles or narrowly named
  variants. Keep completed, selected, warning, and destructive meanings distinct.
- Audit numeric fields, units, checkboxes, removal/add controls, overflow menus,
  collapsed cards, empty sessions, and saved-session details.
- Keep callbacks, focus, keyboard input, elapsed timer state, unsaved sets,
  scroll positions, workout-exit preferences, and persistence unchanged.
- Include premade/custom plans and generation flows if release navigation reaches
  them. Treat Train2 as deferred only after release reachability is verified.

#### 12C. Catalog and exercise details

Use the catalog/detail inventory paths and confirm their real callers before
editing. Include search/filter controls, exercise cards, detail tabs, form
guides, metrics, records, zoom, fallback thumbnails, and overlays.

Separate media art from its surrounding frame, scrim, anatomy overlay, and
placeholder treatment. Preserve the approved readable light anatomy tone.
Missing exercise thumbnails remain a content task; theme completion requires
a usable fallback, not production of every missing illustration.

Extract structural colors, shapes, tab treatment, dialog/sheet variants, and
text roles while preserving search state, selected exercise identity, sheet
expansion, scroll position, and record data. Test ordinary media and fallback
states in both brightness variants.

#### 12D. Dashboard, logbook, progress, and measurements

Audit `dashboard_sections.dart`, `data_records_section.dart`,
`history_summary_widget.dart`, `exercise_progress_section.dart`,
`health_trends_section.dart`, `workout_metric_chart_card.dart`,
`workout_history_calendar.dart`, and their route-level hosts.

- Separate structural cards, selected periods, borders, labels, and empty
  states from chart series, thresholds, anatomy intensity, and measurement
  category meaning.
- Use AppDataVisualizationTokens for chart-specific roles; do not assign every
  series a structural primary color.
- Preserve date ranges, units, selected metrics, chart interactions, empty
  record semantics, and horizontal/vertical scroll behavior.
- Confirm labels and state indicators remain understandable without relying
  solely on color. Test long numbers, large text, zero records, and missing data.

#### 12E. Onboarding, specialized flows, and remaining reachable routes

Trace `onboarding_flow.dart`, `guided_tutorial_overlay.dart`, exercise editing,
automatic/premade plan flows, maintenance pages, nutrition, and any cardio,
stretch, form, or experimental entry points that actually exist.

The current compatibility extension covers the non-default exercise-definition,
full-history, cardio, stretch, current-measurement, generic-trend,
food-customization, and food-logging consumers with a shared Classic/Neo
surface boundary. This is an interim theme-ready step: do not treat wrapper
adoption as final Neo implementation, product completion, or route
qualification. Revisit these consumers for route-specific Neo geometry,
loading/empty/error states, accessibility and device evidence after their
feature designs stabilize.

Extract repeated sections/fields/actions and local themes. Treat tutorial
spotlight/scrim effects as an explicit recipe with a readable fallback and
preserved focus/dismissal behavior. Confirm development-only QA pages cannot
be reached by release navigation or named routes.

A hidden bottom tab does not prove a route is unreachable. Follow buttons,
drawers, links, deep links, and programmatic navigation. For deferred features,
record the gate and verify release denial; for reachable features, complete
their presentation migration before Step 19.

#### Per-slice acceptance procedure

1. Record exact paths, route entry points, original recipes, and known deviations.
2. Assign each expression to Material, an existing Tonos role, a justified new
   role, a shared recipe, or a documented fixed data/media exception.
3. Change presentation ownership in a bounded batch. Do not rename data models
   or combine unrelated navigation, database, or localization refactors.
4. Preserve component-specific variants. Equal numeric values today do not
   imply equal semantic roles; different existing values must not be flattened.
5. Add only tests that protect behavior, adoption, or independent parity.
6. Obtain the user-run formatter/analyzer/tests required by AGENTS.md, inspect
   output, and fix failures before expanding the batch.
7. Record remaining visual/accessibility evidence, then update the narrow
   inventory rule. Mark migrated only after every expression in its scope is
   accounted for; otherwise keep the rule pending or split it.
8. Update Theme Lab with representative real component recipes where useful,
   without requiring private user data or duplicating feature business logic.

### Step 18: Enforce migration boundaries and qualify the shared system (scoped enforcement complete; broader work remains)

The Q1 ratchet protects one exact production scope, and current development
human/device qualification is accepted. The corrected verifier scope passed
on 2026-09-22; its results are recorded in the consolidated roadmap. Further
production enrollment requires per-file evidence; it is intentionally not a
blanket completion requirement.
The design criteria below preserve the original architecture and guide any
future expansion without reopening the accepted current development checks.

#### 18.1 Turn inventory labels into enforceable scoped checks

Files: `tools/theme_style_inventory.dart`,
`docs/theme-style-inventory.json`, `docs/theme-style-inventory.md`, and
`test/theme/theme_style_inventory_contract_test.dart`.

The report-only inventory's destination and status prove assignment, not
migration correctness. The separate Q1 ratchet protects one exact production
scope; it does not turn every migrated path into an enforced scope. Broad
fallback rules can still classify new raw styling as pending.

Keep the full report for unconverted areas. For qualified migrated scopes,
extend the ratchet only when it can detect newly introduced structural
literals/overrides or unresolved findings. Require a narrow exception with
rationale and owner/recipe when a fixed expression is intentional. Avoid a
line-number-only baseline: normal formatting should not invalidate exceptions,
while new expressions must not disappear under a broad wildcard.

Test the scanner with fixtures containing a new structural literal in migrated
scope, an allowed data/media value, a pending-scope value, and a rule-ordering
conflict. Specify exactly which cases fail. Add evidence references to migration
records without pretending that a text path or boolean establishes parity.

The TonosSurface CI scope is already enabled. Add other paths only after focused
scopes and fixture behavior are proven. Do not block the repository on all
existing pending debt or exempt an entire feature because one illustration
uses fixed colors.

#### 18.2 Finish typography, local-theme, motion, and effect adoption

Search for direct TextStyle, DefaultTextStyle, local Theme, decorations,
durations, shadows, and blur in qualified scopes. Inspect context placement:
a text style read above Scaffold/Material can differ from the inherited style
inside the rendered component. Select TextTheme roles by the original resolved
font, size, weight, spacing, and height, not by a role name that sounds similar.

Use TextTheme for ordinary typography. Add focused numeric/action typography
recipes only when repeated consumers require a stable distinction. Do not
invent a global font change or fixed text scale to conceal overflow.

Confirm reduced-motion and effect-disabled tokens are actually consumed by
production recipes, not merely present in extensions or altered in Theme Lab.
Trace MediaQuery/accessibility inputs and app capability resolution into the
relevant primitive. Preserve Classic's ordinary motion, while applying reduced
durations and opaque/no-shadow fallbacks when requested. Add tests for the
production path and ensure semantic callbacks and visibility remain intact.

When updating Theme Lab preview extensions, preserve untouched registered
extensions. A gallery-only override must not reset unrelated roles or persist
its preview mode, locale, or family.

#### 18.3 Verify switching, accessibility, and state preservation

The current development switching, accessibility, and state-preservation
checks were user-accepted on 2026-09-17. For future consumers, use a
deliberately different test theme or injected token fixture to detect ignored
shared roles. Keep such fixtures in tests/development; they are not a
user-selectable family.

Exercise brightness/theme replacement while a route has scroll position,
selected tabs, text-field focus, unsaved input, an open sheet, and an active
session. Check that provider/business objects are not recreated by theme
selection and that route keys remain stable. Test rapid changes and failed
writes with Step 17's queue.

For future changed scopes, cover supported locales and text scales 1.0, 1.3,
1.6, and 2.0 on representative small-phone layouts. Do not solve overflow by
shrinking all text or removing accessibility scaling. Use existing localized
resources for error feedback. Include selected/disabled semantics, keyboard
focus, and meaningful labels; add focused physical TalkBack checks for affected
interactions. Step 15 release qualification remains separate.

Measure startup, scrolling, and switching on agreed physical hardware before
declaring performance unchanged. Reuse cached factory themes, inspect repeated
fallback token construction if profiling identifies it as material, and avoid
speculative caching or state changes merely to simplify tests.

Exit: scope-specific migration checks work, representative real consumers
respond to injected recipes, and any new device/manual checks are recorded
with an owner and explicit disposition. The current development scope is
accepted; the separate release gate is Step 15.

### Step 19: Approve readiness to start alternate-theme implementation (complete for agreed Q3 scope)

Create a dated readiness record in the theming documentation with links to
evidence. Every item must be satisfied or carry a specific approved exception;
an unreviewed pending item does not pass by default.

- Step 17 defects are closed, including Classic badge/header colors and request
  ordering. The eight-finding closure matrix names evidence for each result.
- Step 2 references identify device/build, SDK, fonts, locale, scale, seed data,
  route/scroll state, and intentional deviations. Stable compositions have
  independent automated checks; remaining manual comparisons are reviewed.
- Step 3 and Step 12 account for all release-reachable routes and states.
  Deferred features have verified gates and explicit inventory exceptions.
- Material versus Tonos ownership is explicit. Required distinctions in
  settings, dialogs, cards, and actions survive shared extraction.
- Complete token contracts, fallback behavior, local variants, reduced motion,
  and effects-disabled behavior are exercised by real consumers.
- Theme Lab represents required recipes and states and remains development-only.
- Preference startup, failures, retry, queued selection, disposal, and route/
  session preservation have appropriate verification.
- Migrated-scope checks reject new unapproved structural styling. Broad pending
  rules remain visible debt rather than being counted as completed work.
- The agreed automated suite passes on the current tree. Manual visual,
  accessibility, and physical performance evidence has an explicit disposition.

This gate permits Step 13 development work only. It does not enable a release
selector, approve Expressive's design, or qualify a future theme for release.
Those remain Steps 14-15. Exploratory sketches may happen earlier, but must not
drive unapproved changes to Classic.

## Implementation Completion Order

| Step | Status | Next required outcome |
| --- | --- | --- |
| 1 | Complete | Maintain permanent Classic contract |
| 2 | Original baseline accepted | Finish post-refinement matched comparisons |
| 3 | In progress | Complete classification and evidence for migrated scope |
| 4 | Implemented | Recheck affected Classic parity through Steps 2/17 |
| 5 | Implemented; original Q3 accepted | Preserve ordered writes, retry and lifetime handling; revalidate relevant changes |
| 6 | Internal Neo opt-in and candidate checks accepted | Preserve explicit opt-in/default Classic; wider release remains separate |
| 7 | Foundation complete | Add only migration-justified roles and adoption checks |
| 8 | Complete | Keep zero production AppColors consumers |
| 9 | Foundation implemented | Preserve framework defaults; audit local overrides |
| 10 | Implemented; adoption ongoing | Preserve variants and complete release consumers |
| 11 | Implemented; current visual and development device qualification accepted | Revalidate only affected pilots after changes |
| 12 | Current visual, route/state, and development device qualification accepted | Resolve only separately deferred product/design decisions |
| 17 | Current affected state/parity checks accepted | Reopen only for a reproduced defect or later affected change |
| 18 | Current scoped work accepted; broader enrollment remains deliberately limited | Enroll only individually evidenced and qualified files |
| 19 | Complete for agreed scope | Manual results accepted; 226 tests passed |
| 13 | N1-N6 development scope accepted; route ledger closed | Requalify only affected scope after changes |
| 14 | Implemented and accepted; available in the Android internal candidate | Public/open release approval remains separate |
| 15 | Android internal/closed candidate accepted | Commit tested source and associate it with the APK SHA-256 before closeout |
| 16 | Not started | Later families through the same architecture |

Next action: commit the exact tested candidate source and associate that commit
with the APK hash to close internal Step 15. Development/device qualification,
automated checks, and signed-APK acceptance are recorded. Wider release approval,
production content promotion, and other previously documented product decisions
remain separate. Keep broader ratchet enrollment evidence-driven rather than
treating it as a blanket completion requirement.

Historical migration execution order: use batches B1-B6 in
[Theming Batch Playbook](theme-batch-playbook.md), then C1-C3, D1-D3, E1-E2,
and Q1-Q3. These are subdivisions of existing phases, not new theme families or
permission to mark a whole file migrated. B1, B2, B3, B4, B5, and B6 are
scoped-verified; C1 is scoped-verified with clean analysis and 148 focused
tests; C2 and D1 are implemented-awaiting-verification; D2 is scoped-verified
with clean analysis and 158 focused tests.

D1 implementation record (2026-09-08, implemented-awaiting-verification):
Dashboard and logbook structural surfaces now resolve through focused surface
and shape roles. The extraction covers dashboard hero/section/editor/usage
surfaces, history period selection, calendar mode/day-empty treatment,
selected-period summary, dividers, and their distinct geometry. Classic keeps
the original resolved alpha recipes and radii. Calendar intensity remains
data-driven, ordinary history `Card` recipes remain Material-owned, and the
non-default `CombinedHistoryPage` placeholder remains unchanged rather than
creating a second history flow.

The dashboard/history source contract protects the dashboard page-storage key,
calendar date/period state, refresh and tutorial state, keep-alive/filter
state, and session navigation callbacks. The token contract covers Classic
light/dark values plus surface override/interpolation. No route, callback,
date-range, scroll/list position, or record-navigation behavior was changed.
The report-only inventory manifest remains unchanged. User-run formatting,
analysis, tests, device review, and full-release qualification remain pending.

D2 implementation record (2026-09-08, scoped-verified):
Progress charts, data records, workout metric charts, and the workout dashboard
now separate structural surface/shape roles from data-visualization series,
grid, labels, selection, trend meaning, and record-today meaning. Classic keeps
the existing surface alpha recipes and 10/12/14/16/18px geometry. Units,
selected exercise/range, chart selection, tooltips, empty chart behavior,
scale-aware dashboard layout, and session callbacks remain unchanged. Source
contracts cover ownership, state-path evidence, Classic defaults, copy, and
interpolation; rendered long-value, zero/missing-record, device, and
full-release checks remain pending. User-run formatting, analysis, and tests
passed; device review and full-release qualification remain pending.

D3 implementation record (2026-09-08, implemented-awaiting-verification):
Health trend cards, measurement summary/chart/entry/empty states, and compact
versus full-page callers now use dedicated legacy-matching progress colors,
focused health trend geometry, and the existing tertiary series role.
Metric identity, values, unit conversion,
chart range, refresh/session invalidation, edit/delete return behavior, and
settings navigation were left unchanged. Focused source contracts and Classic
shape interpolation coverage were added; user-run formatting, analysis, tests,
device review, and full-release qualification remain pending.

Repository verification policy: Codex must not run dart format, dart analyze,
flutter test, flutter pub get, flutter run, or Flutter builds. For each code
batch, provide exact PowerShell commands appropriate to the touched paths and
wait for the user's output. A review can use source inspection and git diff
checks, but must label those separately from executed Flutter verification.

## Reference Basis

- Flutter recommends app-wide `ThemeData`, component themes, and `Theme.of`
  for shared visual configuration:
  https://docs.flutter.dev/cookbook/design/themes
- Flutter's `ThemeExtension` is the supported mechanism for custom additions to
  `ThemeData`, including interpolation during theme changes:
  https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Material 3 is Flutter's default design language, but migration can require
  deliberate component changes:
  https://docs.flutter.dev/ui/design/material
- Material 3 Expressive combines color, adaptive components, typography,
  contrasting shapes, and motion rather than acting as a palette swap:
  https://m3.material.io/

## Definition Of Done

This plan is fulfilled when:

- Classic remains the default and its reference screens do not regress;
- theme family and brightness preferences are independently stored and
  recover safely from invalid values;
- Expressive light and dark themes cover all active release surfaces;
- shared custom widgets consume semantic tokens rather than raw styling;
- future themes can be added without feature-screen conditionals;
- all supported locales, text sizes, accessibility states, and supported
  devices have targeted verification;
- advanced effects have performance-safe fallbacks;
- the theme design, preference behavior, and QA evidence are documented.

Until these conditions are met, the theme work remains a planning or
development-only feature and does not replace the current release appearance.
