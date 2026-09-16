# Classic Theme Baseline

Current decision (2026-09-11): the user accepted the 16 supplied Q3 screenshots
as the Classic manual baseline at font scale 1.15. This supersedes the 1.0
capture requirement below for this accepted set. Use 1.15 for comparisons.
Status-bar readability was corrected and phone-verified afterward. Other
reported screenshot differences were accepted for now. These are manual
references, not approved goldens; historical strict-parity tasks below remain
reference guidance, not a request to retake this accepted set. See the
[current Q3 record](theme-q3-readiness-gate.md).

Current status (2026-09-14): baseline inventory and executable Classic contracts
are recorded; the Q3 manual baseline was accepted with explicit limitations.
The later restoration/correction pass still needs the matched comparisons below.
Golden approval is separate; the accepted images are manual references.
The prior description of Q3 as awaiting initial Step 2 verification is superseded
by its accepted decision. Use the [consolidated roadmap](theme-consolidated-roadmap.md)
for current tasks; this document owns Classic reference/evidence details.

## Purpose

The current Tonos appearance is the permanent `Classic` theme. Its light and
dark variants must remain available after Expressive and any later theme
families are introduced. Theme extraction, token migration, and visual fixes
must be measured against this baseline rather than against an earlier memory of
the UI.

Classic parity means preserving the current resolved colors, typography,
density, component behavior, layout, navigation, semantics, and persistence
behavior. It does not prevent separately approved product or accessibility
fixes; those must be recorded as intentional deviations instead of being
silently mixed into theme architecture work.

## Authoritative Sources

- `lib/theme/app_theme_family.dart` declares the stable `classic` family code
  and its light/dark support.
- `lib/theme/classic_theme_baseline.dart` contains the machine-readable stable
  surface inventory, framework-recipe ownership contract, and compatibility
  recipe values.
- `lib/providers/theme_provider.dart` currently defaults to dark Classic,
  reads the explicit `theme_mode` and `theme_family` preferences, and exposes
  the existing brightness API during migration.
- `lib/theme/app_theme_capabilities.dart` keeps Classic available in every
  build and prevents unfinished future families from being selected.
- `lib/theme/classic_theme.dart` owns the extracted light and dark `ThemeData`
  definitions, while `lib/theme/app_theme_factory.dart` owns the cached
  `AppThemeFactory` lookup. `lib/main.dart` only requests the selected family
  from that boundary.
- `lib/theme/classic_theme_tokens.dart` contains named Classic-only values that
  need to remain stable when the broader palette is extracted.
- `lib/theme/tokens/` contains the focused, complete semantic, surface, shape,
  motion, effect, visualization, flow, and nutrition contracts used by both
  Classic variants. The former `AppColors` bridge was retired after all
  production consumers were migrated.

Do not copy the complete color table into this document. During extraction,
the code snapshot and reviewed screenshots must agree; duplicating dozens of
hex values here would create a second source of truth and could become stale.

## Reference Conditions

Capture the same conditions for every reference surface:

- physical Android device in portrait orientation;
- release-mode or otherwise production-equivalent rendering; a debug banner
  may remain in manual evidence when it is the only build difference, but it
  must be excluded from any approved golden;
- one agreed device model, screen size, density, and OS version recorded with
  the evidence;
- system font scale 1.0 and default display size;
- English locale for the primary Classic reference;
- deterministic seed data and a known route/scroll position;
- the same status-bar, navigation-bar, and edge-to-edge configuration;
- no transient loading spinner, keyboard, permission prompt, or system dialog;
- screenshots taken only after the surface has settled;
- both light and dark variants, with the same content and state where possible.

Use separate evidence for conditions that are intentionally different:

- online media and an offline/media-placeholder state;
- empty, populated, loading, warning, and error states;
- normal text and the large-text/accessibility matrix;
- translated locales and long strings.

The primary baseline is not a claim that every state has identical pixels. It
is a controlled reference for identifying unintended changes during extraction.

## Stable Reference Surfaces

The following identifiers are also stored in
`ClassicThemeBaseline.surfaceIds`:

| ID | Surface and state |
| --- | --- |
| `main_navigation` | Main scaffold with bottom navigation and selected default tab |
| `appearance_settings` | Profile UI and Appearance settings with the dark/light control |
| `train_home` | Train landing surface with normal content |
| `active_workout` | Active workout with set rows, actions, and progress state |
| `exercise_catalog` | Catalog list with search/filter controls and thumbnails |
| `exercise_detail` | Exercise detail sheet with media, tabs, and form guidance |
| `dashboard` | Dashboard with stable default sections and cards |
| `progress_measurements` | Measurements hub with health-trend cards |
| `form_screen` | Representative editable form with validation affordances |
| `dialog` | Representative confirmation or information dialog |
| `bottom_sheet` | Representative action/detail sheet |
| `empty_state` | Stable empty content state with its primary action |
| `warning_or_error` | Recoverable warning or error surface |
| `media_placeholder` | Missing/offline media fallback and retry state |

## Exact Capture Script

This is the minimum screenshot set for the first Classic review. Do not capture
every route, dialog, or language. For each required surface, capture one dark
variant and one light variant under the same data and scroll state. Wait for
the route to settle before each capture.

The supplied captures include the Flutter `DEBUG` ribbon. That is acceptable
for manual review because it does not represent app content, but the ribbon is
not part of the Classic visual baseline and must not be baked into goldens.

### Required primary captures

| Surface ID | Exact navigation and action | Capture state |
| --- | --- | --- |
| `main_navigation` and `train_home` | Fresh-launch the app and remain on the default `Train` tab, using the `Overview` section if the Train page offers its internal tabs. | One settled viewport showing the app bar, Train content, and bottom navigation. This single capture covers both IDs. |
| `appearance_settings` | `Profile` tab -> `UI & Appearance`. | The settings page with the light/dark control visible. Capture once in each final brightness; wait after toggling before the second capture. |
| `active_workout` | From the same deterministic plan/session fixture, open `Train` -> the plan -> `Start Workout` (or the visible `Start Workout` action). | The initial active-workout viewport with at least one exercise/set row and its primary controls. Do not capture a moving timer or snackbar. |
| `exercise_catalog` | `Catalog` tab -> focus `Search Exercises` -> enter `overhead`. | The settled filtered list with the search field, `Filters` action, and visible thumbnails. Use a known locally available media fixture. |
| `exercise_detail` and `bottom_sheet` | Tap `Overhead Press - Barbell` in the filtered catalog. | The exercise detail bottom sheet on the `Details` tab with its media and `Form guide` visible. This single capture covers the content and presentation IDs. |
| `progress_measurements` | Tap the `Progress` bottom tab. | The settled Progress viewport containing the `Health Trends` section. If one viewport cannot include it, perform one recorded scroll and capture the viewport where the cards are fully visible. |
| `form_screen` | `Profile` tab -> `User Information`. | A clean, settled form with no keyboard, focused field, validation message, or date picker. Use the same blank or seeded values in both variants. |
| `dialog` | `Profile` tab -> `UI & Appearance` -> open `Weight Units`. | The open weight-unit alert dialog, with the underlying page dimmed. Dismiss it after each capture. |

`dashboard` is a primary capture only when the current build intentionally
exposes the Dashboard tab. If it is hidden, do not change the release
navigation just to create a screenshot; keep it as a later development-only
reference until that surface is approved for release.

The two filtered catalog rows `Overhead Tricep Extension - Barbell` and
`Overhead Tricep Extension - Cable Machine` are excluded from the current
Classic media fixture because their source thumbnails are not registered in
the media manifest. Their fallback anatomy is a separate media-content issue,
not a theme decision and not a reason to block theme extraction.

### Supplemental state captures

These states are useful for manual theme review but should not become goldens
until their content and failure behavior are stable:

- `empty_state`: use a clean test fixture, or create a new measurement metric
  and leave it without entries; open `Progress` -> `Health Trends` and capture
  the no-entry state with its primary action.
- `warning_or_error` and `media_placeholder`: with a known uncached media item,
  disable network access, open the catalog/detail route, and capture the
  recoverable fallback/retry state. Restore network access and verify the retry
  result separately; do not use a real user database to manufacture an error.
- `active_workout` interaction state: optionally capture after completing one
  set if the selected/completed state is important to the review.
- `form_screen` interaction state: optionally capture a focused field or a
  validation message as manual evidence, not as the clean baseline.

Do not include `Train2`, unfinished nutrition routes, or other experimental
navigation in the required Classic release baseline. They can receive their
own references after their product designs are approved.

### Capture order and evidence

For every required capture:

1. Set English, portrait orientation, font scale 1.0, default display size,
   and the agreed physical Android device.
2. Install or run a release-equivalent build with no debug banner, and use the
   recorded deterministic data fixture.
3. Capture the dark state, then toggle only the brightness setting and capture
   the light state after the UI settles. Keep route, scroll, and data state the
   same.
4. Name the evidence `classic-v1/<surface-id>-dark.png` and
   `classic-v1/<surface-id>-light.png`, or record the equivalent local paths.
5. Record device model, Android version, build identifier, locale, font scale,
   fixture name, route/scroll state, and capture date next to the images.

Send back the image files or paths together with that metadata. The images are
not approved merely because they were captured: compare them against the
review checklist below and record any intentional deviation before adding a
golden.

If a surface is not stable enough for a golden, retain its ID and use a manual
reference plus a widget contract instead. Do not delete it merely because its
product design is still being refined.

## Evidence Naming

When the reference captures are approved, store or link them using a predictable
name such as:

```text
classic-v1/<surface-id>-light.png
classic-v1/<surface-id>-dark.png
```

The evidence record should include the device, build identifier, locale,
font-scale, seed-data fixture, route state, and capture date. Existing root
screenshots such as `flutter_01.png` are not automatically considered Classic
references; they must be deliberately matched to a surface ID and reviewed.

## Behavioral Baseline

Before theme extraction, verify and record:

- a fresh install starts in dark mode;
- a saved light preference renders the light theme after restart;
- changing the existing appearance control does not change family identity;
- the current family is always `classic`;
- no database, workout, catalog, media, localization, or navigation state
  changes when brightness changes;
- the current route, form state, and active-workout state remain safe when the
  theme provider notifies listeners;
- the complete focused token set is present on both light and dark `ThemeData`
  objects, with no legacy `AppColors` bridge;
- standard Material recipe fields remain framework-owned, except for the
  explicitly app-owned bottom navigation recipe;
- Classic compatibility-specific shapes, motion, and ongoing-session action
  roles match the values recorded by `ClassicThemeBaseline`;
- representative custom-color consumers render without changing their current
  resolved values.

The current provider technically parses all Flutter `ThemeMode` enum values,
but the user-facing appearance control is a light/dark control. System-following
brightness is deferred to the later selection migration and is not part of this
Classic baseline contract.

## Review Checklist

For each surface and each brightness:

- compare background, surface, border, icon, text, selected, disabled, error,
  and focus colors;
- compare typography size, weight, line height, wrapping, and truncation;
- compare padding, gaps, radii, borders, elevation, and shadows;
- compare component states, tap targets, semantics, and focus order;
- compare scroll position, route state, form state, and media state;
- record every intentional difference with a reason and owner;
- reject unexplained changes until the Classic contract is updated separately.

## Neo Correction Pass: Classic-Visible Change Classification

2026-09-14 user review: current Classic looks roughly the same as the older
screenshots except Workout Report's top metric boxes. The duration wrapped and
made its box taller; the old presentation scaled text within stable boxes.
The correction restores single-line fitting and equal line slots at ordinary
Classic text scales (through 1.15), retaining adaptive layout above that scale.
Implementation and a regression test are added; user-run verification and a
fresh screenshot of this fix are pending. This general comparison is useful
user feedback, not a completed per-state accessibility or device matrix.

This record classifies the shared changes made during the Neo correction pass.
The responsive and accessibility behavior may be shared with Classic, while
Neo-specific fills, borders, radii, shadows, and focus colors must remain behind
the Neo presentation-token boundary.

| Surface or component | Previous Classic behavior | Current or new Classic behavior | Classification | Reason | Automated evidence | Manual evidence status |
| --- | --- | --- | --- | --- | --- | --- |
| Weekly Overview / SevenDayFocusPresentation | Classic Card shell and 198px side-by-side heatmap/details layout | The Classic Card shell and normal-size side-by-side geometry are restored through ordinary text scales; stacking is limited to genuinely large text when the allocated width cannot support the row | Intentional large-text exception only | Preserve the established dashboard composition while preventing clipped heatmap details at high accessibility scales | Direct SevenDayFocusPresentation responsive test | Pending fresh matched capture |
| Train plan sections and action bar | Classic Cards with their established elevation, margins, and padding, plus the compact Start/Optimize bar | Active, archived, and premade plan sections use Classic Cards again; the normal-size Classic action bar remains horizontal, while Neo continues to use raised Tonos surfaces and its adaptive layout | Neo-only presentation is gated; large-text reflow remains intentional | Prevent Neo panel geometry, depth, and tall action-bar layout from leaking into Classic | Train-page theme regression coverage | Pending fresh matched capture |
| SettingsHeroCard and action tiles | Compact horizontal Classic hero and established tile density | The normal-size Classic hero and tile density are restored; long/localized or large-text content may still reflow to remain usable | Intentional large-text exception only | Restore the familiar Profile presentation without reintroducing truncation or overflow at 200 percent text | responsive_accessibility_test.dart | Pending fresh matched capture |
| Exercise Progress hero and selectors | Classic hero, selector height, and control layout | Normal-size Classic restores its established side-by-side hero and selector geometry; names and values may reflow only when width or accessibility scale requires it | Intentional large-text exception only | Keep localized exercise names and values readable while restoring the original default hierarchy | exercise_progress_responsive_test.dart and Exercise Progress interaction coverage | Pending fresh matched capture |
| Workout Report | Classic metrics row, range strip, and two-column insight arrangement | Normal-size Classic restores its established compact report density; translated or large-text content can continue to grow and stack safely | Intentional large-text exception only | Preserve the original report hierarchy without clipping long values or translated copy | WorkoutMetricChartCard direct responsive test | Pending fresh matched capture |
| Workout completion and record badges | Fixed Classic Done action, compact four-metric summary, original badge scale and legend row | Normal-size Classic restores its fixed bottom action, compact metrics, badge typography, and legend alignment; high text scale may use adaptive flow | Intentional large-text exception only | Retain familiar completion-sheet hierarchy while keeping accessible content readable | workout readability regression coverage | Pending fresh matched capture |
| Neo borders, hard shadows, bright-surface data colors, and focus frames | Not part of Classic | Must remain gated by surface decoration and presentation tokens | Neo-only | These are Neo visual identity decisions, not shared layout behavior | Neo theme and token tests | Pending fresh matched capture |

For every row above, the automated evidence is only a code-level gate. The
manual evidence remains pending until the final correction pass has been
captured on a fresh device with matching route, state, locale, text scale, and
build metadata. Any Classic screenshot difference outside the intentional
reflow rows must be recorded as a regression or an explicit pending decision;
the baseline must not be silently rewritten to match it.

Manual evidence record for this correction pass:

- Reviewer: Pending fresh-device review.
- Date: Pending fresh-device review.
- Build or commit identifier: Pending fresh-device review.
- Device and Android version: Pending fresh-device review.
- Physical and logical viewport, density, and display-size setting: Pending
  fresh-device review.
- Locale and region: Pending fresh-device review.
- System font scale and app text scale: Pending fresh-device review.
- Fixture account and data state: Pending fresh-device review.
- Keyboard, D-pad, and screen-reader setup: Pending fresh-device review.
- Evidence filenames and check results: Pending fresh-device review.

## Current Completion State

Completed in code:

- stable Classic identity and light/dark support;
- machine-readable stable-surface inventory;
- contract coverage for surface uniqueness and Classic brightness support;
- existing provider persistence tests remain the behavioral reference;
- the Classic light heatmap low tone was darkened after visual review so
  unselected anatomy remains readable on light surfaces.
- the exact Classic light and dark `ThemeData` definitions are extracted into
  `lib/theme/classic_theme.dart`; `AppThemeFactory` returns cached variants.
- the framework Material ownership boundary and the compatibility-specific
  Classic recipes are executable contracts in
  `test/theme/classic_theme_baseline_test.dart`.

Manual evidence supplied and reviewed:

- all required routes have dark and light coverage;
- the Progress `Health Trends` viewport is captured in both variants;
- the Train data state is matched between the dark and light captures.

Still required before marking the baseline fully reviewed:

- recapture or otherwise match the active-workout state so dark and light use
  the same completed-set state;
- keep the two excluded fallback rows out of the Classic media fixture until
  their source thumbnails receive a separate media-content fix;
- record device/build metadata and any intentional deviations;
- add goldens only for surfaces whose layouts are confirmed stable.

The Step 4 extraction is complete. The remaining baseline work is evidence
metadata, matched-state review, and goldens for surfaces that are stable
enough to approve.
