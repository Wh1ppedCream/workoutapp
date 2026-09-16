# Neo-Brutalism: First Alternate Theme

Current status (2026-09-15): N1/N2 complete; N3 family and pilot preview
implementation plus automatable coverage are complete; original N4 real-route
development acceptance is complete.
The reviewed current screen batch is accepted for now. Later refinements require
affected-surface rechecks. Final rendered preview/device evidence, exhaustive
N5 route disposition, and N6 qualification remain. N5/N6 have
implementation/evidence underway and are not wholly unstarted.

Use the [Consolidated Theming Roadmap](theme-consolidated-roadmap.md) for current
tasks and completion criteria. This document owns visual specifications and
historical implementation detail. Historical 230/233-test results remain scoped
evidence; the latest user-supplied Train-tab/settings/Neo-regression run passed
51 tests with clean targeted analysis after reducing the selector shadow.
Public selection and release approval remain separate Steps 14-15.

The latest Train refinement also aligns the Neo depth hierarchy: the compact
Overview/Plans frame uses the standard structural outline, raised plan sections
use the 4x4 raised-panel shadow, plan rows and the archived empty state use the
3x3 compact-card shadow, and the Premade browse action uses the 4x4 primary
action shadow. Classic branches retain their established recipes.

Neo workout-card fields were also corrected in the shared WeightCard: Weight
labels use a compact always-floated style and reduced inner padding so the full
unit label remains visible without the outline crossing its text. This applies
to preset details and active sessions while the Classic input recipe remains
unchanged. Set labels, change-set labels, and Add Set also use the dark
workout-container ink explicitly so they do not inherit the dark-canvas light
foreground.

Neo completion-state refinement now separates the completed exercise surface
from completed set rows. Completed exercises use the darker green `#96B967`
light / `#A6D466` dark; completed set rows use the lighter green `#B9D994`
light / `#C5EC91` dark and a dedicated compact `(2,2)` hard shadow. The
Classic completion color, row geometry, and effect path remain unchanged.

The 2026-09-15 Catalog/Logbook/Progress batch is also implemented and user
reviewed for now. It includes the compact Neo Workout Report layouts, readable
Health Trends cards, the restored Classic report insight layout, the reverted
Logbook calendar-surface experiment, and a single-owner Neo exercise-detail
sheet handle. This is a current-batch visual acceptance note, not N5/N6
qualification.

The same date's secondary-surface compatibility extension is now recorded
separately from full Neo implementation. It covers evolving exercise-definition,
history, cardio, stretch, measurement, trend, and nutrition consumers through
`TonosThemeReadyCard` and existing semantic/data roles. Classic retains the
original `Card`/palette paths. This keeps unfinished product areas theme-ready
without locking their final Neo geometry or claiming N5/N6 completion.

## Approved Design Record

The user accepted the current board with: "alright, i think this should be good.
lets lock this in". This closes N1's visual review requirement for all eight
pilot views. The approved reference is [revision 5](theme-n1-proposals.html).
Earlier pending-review notes and superseded recipe descriptions below are
historical; this record takes precedence.

Carry these decisions into implementation:

- Bright yellow primary actions and hero/overview surfaces; pink, cyan,
  orange and purple supporting surfaces with dark text and black borders.
- Overview/Plans has individually outlined segments within a single rail.
- Bottom navigation is one continuous yellow bar, purple active segment,
  dark underline and one black outer border/shadow; no separated tab buttons.
- Workout cards use quieter peach/lavender fills, flat outer frames and
  aligned set rows. Completed exercises use a darker green surface; completed
  set rows use a lighter green, an outline, left marker and compact `(2,2)`
  shadow. Incomplete rows remain flat.
- Use the existing font family initially. Retain real app icons, media,
  interaction behavior and accessibility when translating the mockups.

N2 implements shared capabilities; N3 verifies the actual Flutter rendering.
The HTML is a design reference, not runtime or release qualification. Record
any material visual deviation from this approved reference before accepting it.
Reviewed 2026-09-11.
The user selected Neo-Brutalism as the first alternate family. N2 has added the
shared runtime capability boundary without registering Neo-Brutalism or changing
the production family list.
The agreed Q3 readiness gate permits development; it is not release approval.
Material 3 Expressive remains a later candidate, not a prerequisite.

Implementation detail: sections 7-13 are the file-level execution specification.
Existing identifiers there were checked against the repository. Proposed new
identifiers are explicitly marked; they are not claims about existing APIs.

## 1. Outcome And Non-Goals

Build a coherent light and dark theme with solid colors, strong outlines,
hard offset shadows, bold headings, and restrained accent colors. Aim for a
sturdy training notebook rather than deliberate disorder. Dense workout data
must remain easy to scan and edit.

- Preserve Classic's current appearance and all existing application behavior.
- Preserve navigation, workout values, units, plan identity, media and storage.
- Use the existing theme factory, extensions, shared widgets and availability
  policy. Do not fork screens or add family checks throughout feature code.
- Do not introduce blur, shaders, wallpaper extraction or continuous animation.
- Do not expose a public selector or enable release availability in this work.
  Steps 14 and 15 remain separate selector and release-qualification work.
- Verify the actual SDK and lockfile before implementation. The last supplied
  environment was Flutter 3.29.3; do not assume newer APIs or upgrade casually.

## 2. Proposed Visual Recipe

These numbers are starting proposals, not approved final designs. Finalize
them through the pilot previews and contrast measurements.

| Role | Light | Dark |
| --- | --- | --- |
| Canvas | Warm paper `#FFF8E7` | Ink `#171717` |
| Main surface | White `#FFFFFF` | Charcoal `#272727` |
| Secondary surface | `#F1E9D7` | `#333333` |
| Main text | `#161616` | Warm paper `#FFF8E7` |
| Structural edge ink | `#161616` | Near-black `#161616` |
| Primary action fill | Yellow `#FFE34D` | Luminous yellow `#FFEA61` |
| On-primary text | `#161616` | `#161616` |
| Optional supporting fills | Cyan `#64DDE0`, pink `#FF92BF` | Luminous cyan `#55F0EA`, pink `#FF6BAE` |
| Hard shadow | Dark ink | Black |

Use accents as intentional fills, not arbitrary alternating card colors.
Do not use pale accent colors as small text on white. Measure actual foreground
and background pairs, including disabled, selected, error and focus states.
Target at least 4.5:1 for normal text and 3:1 for large text and meaningful
control boundaries. Keep error/success roles separate from decorative accents.
Charts retain distinct semantic series; user-assigned plan colors and exercise
media must not be recolored merely to fit the palette.

Dark Neo-Brutalism deliberately separates canvas text from structural ink.
Warm paper remains the primary text color on the dark canvas so headings,
labels and status content stay readable. Card outlines, selector rails,
colored action frames and structural dividers use near-black `#161616`.
Dark-mode hard shadows remain black `#000000`, with zero blur. These edges
anchor the yellow, pink, cyan, orange and purple surfaces to the approved
proposal. Colored surfaces continue to use dark `#161616` text in both modes.
Inputs and outlined actions on neutral dark surfaces retain contrasting
control borders. Unchecked controls, sheet handles, chart tracks and flow
connections also retain visible contrast; they must not disappear into the
charcoal background when the decorative frames become dark.

### Shape, Density And Depth

- Start with 2 logical-pixel outlines; use 3 only for emphasized elements.
- Start with radii of 4 for compact controls, 8 for cards, 12 for sheets.
  Avatars and other meaningfully circular elements can remain circular.
- Start with shadows offset `(3, 3)`, zero blur and zero spread; use `(4, 4)`
  sparingly on primary actions. Dense nested rows should usually have no shadow.
- Reserve space for shadow painting. Check clipping at list edges, sheets,
  bottom navigation and keyboard insets. Do not increase every row's padding.
- Effects-off removes decoration, not outlines or selected-state indicators.
- Keep directional alignment correct in RTL; document whether decorative
  shadow direction stays fixed or mirrors, and test that choice consistently.

### Typography

Use a heavy readable sans-serif for headings and a restrained monospace for
selected numeric metadata, not all body copy. Space Grotesk and IBM Plex Mono
are candidates only: verify licenses, weights, glyph coverage and asset cost
before choosing. Bundle approved font files and license notices locally;
do not depend on runtime font fetching.

Keep existing semantic text sizes initially. Apply typography through the
family TextTheme rather than screen-specific font literals. Check long names,
French, fallback scripts, decimals, units and font scale 2.0. Never fix overflow
by globally suppressing scaling or shrinking important labels. Avoid forcing
all caps on localized body text or replacing meaningful icons unnecessarily.

### Interaction States

Primary buttons use yellow fill, dark text, outline and hard shadow. Secondary
actions use quieter surfaces. Define normal, pressed, focused, hovered,
selected, disabled and error recipes before using them in production.

Optional pressed feedback may translate paint by 1-2 pixels while reducing
the shadow, with an initial 80-120ms duration. It must not move the hit target,
change layout, or remain stuck after cancellation. Reduced motion removes
displacement. Focus must remain visible without relying only on shadow or
color; disabled controls should not appear raised and inviting.

## 3. Code Ownership And Architecture

| Location | Intended work |
| --- | --- |
| `lib/theme/app_theme_family.dart` | Add a stable `neo_brutalism` identity once both brightness definitions are ready; preserve Classic fallback and stored codes. |
| `lib/theme/app_theme_factory.dart` | Construct/cache complete light and dark definitions and handle the new enum exhaustively. |
| `lib/theme/app_theme_capabilities.dart` | Keep the existing experimental and release restrictions; test fallback when unavailable. |
| Proposed `lib/theme/neo_brutalism_theme.dart` | Own the family's color scheme, TextTheme, Material component recipes and full extension set. |
| `lib/theme/tokens/` | Add only missing semantic outline, shadow and interaction capabilities, including copyWith/lerp and unchanged Classic defaults. |
| `lib/theme/widgets/` | Render the new capabilities through shared surfaces, actions, fields, sections and sheets. |
| `lib/theme/theme_lab_page.dart` | Preview both modes and state variants without accidentally persisting preview selection. |
| `pubspec.yaml` and font assets | Register only approved bundled fonts and licenses, if chosen. |
| `test/theme/` | Add family, primitive, capability, interaction and representative route evidence. |

The current TonosSurface implementation hard-codes some outline/shadow choices.
A palette-only theme cannot produce the intended result consistently. Audit
each variant and extend its semantic recipe where needed. Do not simply force
all variants to be outlined: Classic must keep its existing defaults.

Material widgets also need ownership: buttons, FABs, inputs, dialogs, menus,
navigation, switches and checkboxes cannot be left with unrelated defaults.
Keep Classic's Material construction unchanged. Avoid app-wide overrides that
silently restyle Classic or local overlays.

For every added token, identify actual consumers, its Classic value, new-family
value, no-effects behavior and interpolation policy. Preserve constructor
compatibility where required. Choose discrete interpolation deliberately for
non-interpolable values; never omit an extension from one brightness mode.

## 4. Component Acceptance Matrix

| Component | Required result |
| --- | --- |
| Train header/segments | Clear selection, strong structure, no excessive height or truncated tab labels. |
| Plan cards | Consistent outline; user identity colors retained; menus and activation behavior unchanged. |
| Workout rows | Checked and unchecked sets distinguishable; editable weights/reps and units remain legible. |
| Primary actions/FAB | Clear hierarchy, correct pressed/disabled behavior, no shadow clipping. |
| Forms | Labels, hints, validation and dropdowns fit at 2.0 scale; keyboard and focus work. |
| Sheets/dialogs | Coherent framing, readable scrim/content, correct safe areas and dismissal. |
| Catalog/media | Untinted imagery, readable placeholders, preserved pan/zoom and close controls. |
| Charts/progress | Semantic series retained, readable legends/axes and clear empty states. |
| Navigation | Selected state not color-only; labels and touch targets preserved. |
| Tutorials | Anchors, reading order and controls survive effects-off and reduced motion. |

## 5. Implementation Batches

### N1. Recipe And Gap Audit (complete; revision 5 approved)

Current deliverable: [eight-view proposal board](theme-n1-proposals.html).

Revision 2, user-requested direction: increase bright yellow coverage and use
green, orange, pink and purple supporting surfaces in both modes. This
supersedes the earlier mostly neutral card recipe. Dark mode keeps a dark
canvas but colored panels use dark ink and black outlines, not warm-paper text.
Use these semantic assignments consistently, never random colors by list index:

| Role | Revised proposal |
| --- | --- |
| Overview/hero and primary action | Yellow `#FFE34D` |
| Active plans panel | Pink `#FF92BF` |
| Workout panel | Orange `#FFB36B` |
| Supporting panel/control | Purple `#C4A1FF` |
| Completed set | Green `#A8E66E`, plus the existing completion indicator |
| Plan item supporting fill | Cyan `#64DDE0`; preserve its identity marker |
| Field/incomplete set fill | Pale yellow `#FFF0A6` |
| Foreground on all these fills | Ink `#161616`, secondary `#38312B` |
| Colored-item outline | Black `#000000`, 2px; emphasized rail/actions 3px |

Overview and Plans each receive a full black outline, with a black outlined
outer rail, small gap and selected underline. Yellow marks the selected tab;
purple is the unselected tab fill. Both remain readable in light and dark.
Preserve selected semantics in the future Flutter component.

Revision 3 refines the direction following user feedback:

- Bottom navigation is one continuous region. No separate rounded boxes,
  colored button backgrounds or individual outlines for Train/Catalog/etc.
  Use the page/secondary surface, readable labels and a short active indicator.
  Actual Flutter navigation retains icons, selected semantics and touch targets.
- Workout cards retain color with quieter peach `#FFD2A3` and lavender
  `#DAC8F1` fills, 2px outer borders, 4px radius and no card shadow. Lavender
  represents a supporting surface in the proposal; do not alternate production
  exercise colors randomly by index.
- Set rows use thin separators rather than nested outlined boxes. Align weight,
  reps and trailing actions consistently; use tabular numerals where supported.
  Preserve editable fields, their focus/error indicators and touch targets.
- Completed rows use muted green `#C8DFAB`, a left marker and the existing
  checkbox/count. Keep other rows transparent over the card. No changes to
  completion behavior or stored values.
- Primary Finish action remains yellow. The hierarchy should emphasize the
  exercise title and training data before decorative frames.

Revision 5: bottom navigation uses a continuous yellow `#FFE34D` surface in
both modes, dark labels/icons, a single 2px black outer border, 6px outer radius
and a `(3,3)` zero-blur black shadow. The active segment uses purple `#C4A1FF`
and a dark bottom indicator. There are no gaps, individually rounded buttons
or individual tab borders. This supersedes revision 3's neutral navigation
surface; preserve the continuous layout requested by the user. Effects-off
removes the outer shadow, retaining color and the active indicator. Flutter
implementation retains navigation icons, labels and selected semantics.

Revision 4: completed workout rows now use deeper green `#A9CD80`, dark ink,
a 1px outline with a 3px left marker, and a `(3,3)` ink shadow with zero blur
and spread. Reserve trailing/bottom space so the shadow does not overlap the
next row or clip. Apply this only to completed rows; incomplete rows stay flat.
Effects-off removes the shadow while retaining green, outline and checkbox.
This supersedes revision 3's completed green `#C8DFAB` and flat completion row.

These adjustments supersede revision 2's individual navigation boxes and heavy
set-row outlines. They remain proposals for visual review.

The increased color coverage requires per-surface on-colors. Do not inherit
dark-mode white text into bright panels. Keep page text readable on the dark
canvas. The revised proposal is awaiting review; it is not final approval.
Open this HTML file in a browser at 100% zoom. It contains N1-TL/TD, WL/WD,
UL/UD and DL/DD. These are static HTML design compositions with a maximum
410 CSS-pixel frame width, browser sans-serif and illustrative data. They are
not Android captures, font-scale tests or functioning forms. Media is omitted.
Earlier references below to missing artifacts are superseded by this link.

Review procedure:

1. Compare Train light and dark: approve or revise the outlined cards, yellow
   Start action, secondary Optimize area and overall density.
2. Compare workout light and dark: approve or revise checked/unchecked set
   contrast, editable-number treatment, borders and Finish action.
3. Compare User Information light and dark: approve or revise solid header,
   category markers, field outlines and Save action.
4. Compare Weight Units light and dark: approve or revise modal framing and
   selected/unselected choices. Supporting explanatory copy in this mockup is
   annotation only; do not add new product copy or selection-row fills without
   recording the corresponding component recipe during implementation.
5. Reply with the IDs needing revision and the desired change, or say that
   all eight proposals are approved. No Flutter commands or phone screenshots
   are required for this design decision.

Revision 5 has been approved by the user and N2 has passed its automated gate.
Flutter rendering, actual fonts, responsive behavior, media,
loading/disabled controls and real route state remain N3-N6 checks. The HTML
board simplifies those details and must not be copied as a replacement app UI.

1. Inventory the shared primitives and Material components used by the four
   pilot screens: Train, active workout, User Information and Weight Units dialog.
2. List exact missing capabilities by file and variant, with existing Classic
   values. Distinguish existing reusable tokens from genuinely missing ones.
3. Resolve palette pairings and font licensing/coverage. Record decisions here.
4. Prepare light/dark visual proposals for the four pilots, eight views total.
   These may be design proposals before runtime infrastructure exists.
5. Review density, accent use and typography before locking the recipe. N3
   provides the subsequent rendered Flutter checkpoint.

Exit: an agreed design direction and bounded extension list, not a claim of
completed production styling. No application behavior changes.

#### N1 Audit Record

The audit below records the original implementation findings. Revision 5 of
the linked proposal board supersedes the initial composition briefs and has
user approval. N1 is complete; N2 was the first runtime/code batch.

##### Audit Boundary And Method

The audit followed the four pilot surfaces named above and traced their shared
owners rather than treating each screen as an isolated styling target. The
table maps inspected route code to downstream owners. A listed dependency is
an audit target, not evidence that every line or state in it has been reviewed:

| Pilot | Route entry | Current direct owner | Shared owners that must be changed before broad adoption |
| --- | --- | --- | --- |
| Train | `lib/screens/exercise/train_page.dart` | `_TrainTabs`, `_ActivePresetsCard`, `_PresetSectionCard`, `_PremadePlansCard`, `_SplitWorkoutBar` | `lib/widgets/presets_loaded.dart`, `lib/widgets/seven_day_focus_card.dart`, `lib/widgets/drawers.dart`, plan-management screens, `TonosSurface`/`TonosAction` where adopted |
| Active workout | `lib/screens/exercise/session_screen.dart` | Session shell and `ExerciseCard` entry point | `lib/widgets/exercise_card.dart`, `lib/widgets/weight_card.dart`, `lib/widgets/session_complete_sheet.dart`, `lib/widgets/ongoing_session_fab.dart`, `lib/theme/widgets/workout_actions.dart` |
| User Information | `lib/screens/profile/settings/user_information_settings_page.dart` | Form field and dropdown composition | `lib/widgets/settings_tiles.dart` (`SettingsPageScaffold`, `SettingsHeroCard`, `SettingsSection`, `settingsInputDecoration`, tile primitives) |
| Weight Units | `lib/screens/profile/settings/ui_appearance_settings_page.dart` | `_showWeightUnitDialog` and `AlertDialog`/`RadioListTile` composition | `lib/widgets/settings_tiles.dart`, the new family's `DialogThemeData`, `RadioThemeData`, and shared surface/action recipes |

The audit also checked the existing theme boundary: `AppThemeFamily` contains
only Classic, `AppThemeFactory` has only Classic branches, and Classic registers
the current semantic, surface, shape, motion, effect, data, flow, generation,
nutrition, media, progress and tutorial extensions. N1 therefore found no
partially registered Neo family to repair. Registration is intentionally
deferred to N3, after N2's shared capability work is complete.

##### Pilot Findings And Required N2 Disposition

| Pilot | Confirmed current styling | N2 disposition |
| --- | --- | --- |
| Train tabs | `_TrainTabs` composes a local `Container` and `_TabButton` uses `Material`, `InkWell`, `primaryContainer`, transparent unselected state and the existing `pill` shape. | Add a semantic segmented-control recipe. Neo uses a solid outlined rail, an outlined/filled selected segment and a non-color selected cue. Keep the current callback and tutorial key behavior. Do not edit the screen for family-specific branches. |
| Train cards | `_ActivePresetsCard`, `_PresetSectionCard` and `_PremadePlansCard` use direct `Card`/`FilledButton.tonalIcon` and local padding. | Let the Neo `CardThemeData` and action theme supply surfaces, outlines, radius and depth. If a card needs a hard shadow, render it once at the shared card boundary. Preserve plan identity colors, refresh callbacks and empty/loading states. |
| Train action bar | `_SplitWorkoutBar` composes local `Material`/`InkWell` layers, uses `effects.sheetElevation`, semantic start-workout colors, `primaryContainer`, and a divider. | Add a shared split-action recipe or adapt `TonosSegmentedActionBar`. Neo uses yellow for the primary start action, a solid secondary surface for Optimize, a 2px outer outline and one hard shadow. Preserve the existing vertical fallback for localized text and large scale. |
| Active workout cards | `WeightCard` uses direct `Card`, a completion fill, local header controls and direct `TextFormField` decorations for weight/reps. | Add a workout-card surface recipe and route all field borders through the active input theme or a shared field boundary. Completed state retains a semantic success cue plus text/icon, not color alone. Preserve controllers, focus nodes, set removal, collapse state and unit labels. |
| Active workout overlays | `SessionScreen` opens exercise detail and completion sheets; `OngoingSessionFab` opens exit/confirmation dialogs. | Apply `DialogThemeData`, `BottomSheetThemeData`, `TonosSheet` and `TonosAction` consistently. Preserve Navigator results, dismissal, safe areas, exit decisions and the already-qualified close behavior. |
| User Information form | The page uses `SettingsPageScaffold`, `SettingsSection`, `settingsInputDecoration`, `TextFormField` and expanded `DropdownButtonFormField` controls. | Change the shared settings hero/section/field/tile recipes. Keep `isExpanded: true`, `itemHeight: null`, localized labels and the existing 2.0-scale layout protections. Do not solve Neo overflow by reducing text scale. |
| Settings visual language | `SettingsHeroCard` currently uses an accent gradient; settings sections and tiles use category accent colors, translucent icon containers and rounded shapes. | Neo removes decorative gradients and uses solid surfaces plus outlines. Category accents retain their product meaning but receive contrast-safe Neo foreground/fill pairings. Tile hit targets, title/subtitle wrapping and switch semantics remain unchanged. |
| Weight Units dialog | `_showWeightUnitDialog` uses a framework `AlertDialog` with `RadioListTile`, selected value and short unit label. | Style through the new family's dialog/radio themes and, if required, a shared dialog-choice token. Keep the framework interaction, selected radio semantics, pop result and provider write unchanged. |

##### Existing Capability Inventory

The current system already provides reusable roles that N2 should reuse:

| Existing capability | Current source | N1 decision |
| --- | --- | --- |
| Surface colors | `AppSurfaceTokens` | Reuse semantic roles; add only decoration policy or missing selected/pressed roles. Do not add another parallel color bag. |
| Geometry | `AppShapeTokens` | Reuse named roles. Neo pilot starting values are `4` for compact controls, `8` for cards/action bars/sections, and `12` for sheets/dialogs. Keep circular roles and meaningful pills. |
| Shadows/effects | `AppEffectTokens` | Reuse the extension and add explicit hard-shadow roles only if existing fields cannot express zero-blur color/offset/opacity. Neo must not combine Material elevation with a second hard shadow. |
| Semantic states | `AppSemanticColors` | Preserve success, error, warning, focus, disabled and domain-action meaning. Choose contrast-safe Neo pairings rather than reusing decorative cyan/pink for status. |
| Motion | `AppMotionTokens` and `appMotionDuration` | Keep feedback short and make reduced motion remove displacement. No continuous Neo animation is required. |
| Shared primitives | `TonosSurface`, `TonosAction`, `TonosField`, `TonosSheet`, `TonosSection` | Extend these boundaries. Do not add screen-level `if (family == ...)` styling. |
| Theme Lab | `lib/theme/theme_lab_page.dart` | Reuse its family/effects/reduced-motion preview state. It must remain non-persistent and development-only. |

The confirmed missing capability is not a color: `TonosSurface` currently
defaults every variant except `input` to no outline, and only `compactCard`
gets an explicit BoxShadow. Material elevation is not equivalent to the
Neo hard-shadow recipe. N2 therefore owns a typed surface-decoration policy
that maps each semantic variant to outline/depth behavior while preserving all
Classic defaults and explicit `outlined` overrides.

Other confirmed gaps are the absence of a Neo family definition, stable family
registration, Neo Material component recipes, a shared settings hero/section
recipe without gradients, and a single split-action/workout-card ownership
boundary. These are N2/N3 work, not omissions to hide by changing the audit.

##### Initial N1 Recipe

The following is the starting recipe for N2. It is specific enough to implement
and measure, while N3 remains the rendered visual-approval checkpoint.

| Role | Light value | Dark value | Usage rule |
| --- | --- | --- | --- |
| Canvas | `#FFF8E7` | `#171717` | Page background only. |
| Primary surface | `#FFFFFF` | `#272727` | Cards, main panels and field interiors. |
| Secondary surface | `#F1E9D7` | `#333333` | Secondary panels, rails and inactive controls. |
| Main ink | `#161616` | `#FFF8E7` | Body/headline text and regular outlines. |
| Primary action | `#FFE34D` | `#FFE34D` | Start/save/confirm emphasis; use `#161616` on top. |
| Cyan accent | `#64DDE0` | `#64DDE0` | Supporting fill, focus/selection support or category accent after contrast check. |
| Pink accent | `#FF92BF` | `#FF92BF` | Supporting fill or category accent after contrast check. |
| Success | Existing semantic success role, contrast-adjusted if needed | Same semantic role, contrast-adjusted if needed | Never rely on green alone; retain icon/text. |
| Error | Existing semantic negative role, contrast-adjusted if needed | Same semantic role, contrast-adjusted if needed | Pair with error text/icon and a visible border. |
| Hard shadow | `#161616` at recipe opacity | `#000000` at recipe opacity | Offset `(3, 3)`, blur `0`, spread `0`; `(4, 4)` only for primary actions. |

Pairing rules are: dark ink on yellow; main ink on light surfaces; warm
paper on dark surfaces; accent fills are not small body text on paper; status
colors keep their semantic on-colors. N2 must measure every actual pair in
normal, selected, focused, disabled and error states before accepting values.

Typography is also resolved for the first implementation: do not add a font
package or downloaded font in N1/N2. Use the app's current Material/platform
sans family, create Neo character through weight and hierarchy, and keep body
copy readable. Use approximately 800-900 for display/section headings, 700-800
for action and card labels, and existing semantic sizes for body/helper text.
Numeric workout metadata may use tabular figures if the installed text API
supports it without a new asset; otherwise keep the current family. Space
Grotesk and IBM Plex Mono remain optional later research candidates, not N2
dependencies or unresolved blockers.

##### Eight Pilot View Proposals

These are the exact compositions N3 must render and review, not claims that
screenshots already exist:

| View | Light proposal | Dark proposal | Required state evidence |
| --- | --- | --- | --- |
| Train | Paper canvas; yellow raised overview; pink active-plan panel; cyan plan rows; yellow Start Workout; purple Optimize rail; ink outlines and hard action shadows. | Ink canvas with the same saturated colored roles and black ink on colored panels; neutral page text remains warm-paper. | Overview tab selected, active plan present, one loading/empty disposition documented. |
| Active workout | Peach main workout cards with 2px ink outline; completed set uses deeper green fill plus check and crisp offset shadow; outlined numeric fields; yellow add/finish emphasis. | Dark canvas with the same peach/lavender/green card roles and black ink on those fills. | One checked and one unchecked set, editable weight/reps, collapsed/expanded behavior, add/remove action. |
| User Information | Solid yellow hero, purple identity section, orange body-metrics section, outlined pale-yellow fields and category accents; no gradient. | Dark canvas with the same saturated section and field roles, black ink on colored surfaces, and warm-paper text only on neutral canvas areas. | Normal form, focused field, open gender/body-fat dropdown, localized/long label check. |
| Weight Units dialog | Solid purple dialog with ink outline/hard shadow; yellow selected Pounds choice and pink unselected Kilograms choice; readable black ink labels. | Same purple/yellow/pink role pairing on the dark canvas; selected/unselected radio states remain distinct. | Dialog open with both options, selected option, dismissal and provider result. |

N3 should supplement these with disabled, error, effects-off and reduced-motion
states. The eight views do not qualify every component by themselves.

##### N1 Exit And N2 Input List

The pilot boundary, current owners, capability gaps and composition briefs are
recorded. Visual proposals and acceptance remain outstanding. No runtime code,
asset, preference, route or Classic behavior was changed by this audit.

N2 may begin with these bounded changes only:

1. Add the typed surface-decoration capability and preserve Classic defaults.
2. Add any missing hard-shadow/effects fields with explicit no-effects values.
3. Move shared action, field, settings and sheet decoration decisions to theme
   ownership while preserving constructors and behavior.
4. Add rendered primitive tests for borders, shadows, focus, disabled states,
   clipping and effects-off behavior in Classic before introducing Neo values.
5. Record the exact Classic values that each new token returns before a Neo
   family is registered in N3.

Keep enum/factory registration in N3, together with both complete definitions.
Do not
start the route sweep, public selector or release qualification in N2.

#### N1 Review Addendum: Implementation Decisions And Evidence

This addendum takes precedence over ambiguous shorthand in the initial tables.
Values are an implementation starting point. Visual acceptance is still open.

##### Separate Accent Fills From Text Colors

Do not assign yellow to light-mode `ColorScheme.primary` simply because primary
buttons are yellow. Existing consumers such as SevenDayFocusCard's More link,
SettingsValueText, icons and text buttons use primary as foreground text.
Use ink `#161616` for light primary foreground and warm paper `#FFF8E7` for dark
primary foreground. Give filled actions explicit yellow background and ink
foreground through button/semantic recipes. Use yellow for primaryContainer
with ink onPrimaryContainer where selected filled controls need it. Review
every actual primary/onPrimary pairing after construction.

Calculated opaque sRGB contrast ratios (rounded to two decimals):

| Foreground / background | Ratio | Decision |
| --- | --- | --- |
| Ink / yellow | 14.09 | Primary action text pairing. |
| Ink / warm paper | 17.09 | Light body text. |
| Warm paper / charcoal `#272727` | 14.11 | Dark body text. |
| Yellow / white | 1.28 | Do not use for light text or sole meaningful boundary. |
| Cyan / white | 1.62 | Accent fill requires ink outline/text. |
| Pink / white | 2.08 | Accent fill requires ink outline/text. |
| Ink / cyan | 11.17 | Supporting filled label pairing. |
| Ink / pink | 8.72 | Supporting filled label pairing. |
| Muted ink `#4D4D4D` / paper | 7.98 | Initial light secondary text. |
| Muted paper `#C8C1B4` / `#333333` | 7.07 | Initial dark secondary text. |

These numbers use the standard sRGB linearization and relative-luminance ratio
`(lighter + 0.05) / (darker + 0.05)`. They measure solid swatches only. Alpha
compositing, disabled overlays, selected row fills and font rendering still
need consumer checks. Do not cite these as whole-app accessibility approval.

Use full-opacity hard shadows initially: ink in light, black in dark, `(3,3)`
offset, zero blur/spread. Dark-mode structure must remain clear from its light
outline even where black shadow contrast is low. The `(4,4)` emphasized variant
is optional; implement one depth first unless a reviewed pilot needs both.
Secondary text must use the explicit muted values above, not arbitrary alpha.

##### Concrete Shared Gaps And Classic Preservation

| Gap | Current Classic behavior to preserve | Required capability and owning batch |
| --- | --- | --- |
| Surface outline policy | TonosSurface: only input defaults outlined; all other variants do not. | N2: typed decoration policy, Classic fallback matching each variant, explicit outlined override retains precedence. |
| Surface shadow policy | CompactCard uses cardShadow/blur/offset; card reads cardElevation; other variants have no explicit shadow. | N2: choose depth through policy; retain effect-token resolution. N3 supplies Neo values. |
| Effect defaults | Classic cardElevation 0, sheetElevation 8, dialogElevation 24; card blur 4, offset `(0,2)`, alpha `0x22` light / `0x66` dark. | N2: retain these exact token defaults. A direct Material Card may still use framework elevation; do not equate it with TonosSurface.card. |
| Shape defaults | Classic outlineWidth 1, focusRingWidth 2. | N2 preserves defaults. N3 supplies outlineWidth 2; field focus must remain discernible without shifting content. |
| Settings hero | Fixed gradient from accent alpha 0.26 to settingsHero; accent border alpha 0.42; icon tint alpha 0.18. | N2: shared settings recipe controls gradient/solid choice, border width/color and icon foreground/fill. Classic recipe reproduces existing values. |
| Settings section | Border accent alpha 0.46, or outlineVariant alpha 0.55; child Theme changes only primary to category accent. | N2: recipe controls whether category accent replaces primary. Preserve current Classic behavior; Neo keeps accessible foreground pairings. |
| Settings fields | Local settingsInputDecoration supplies an OutlineInputBorder and settingsField radius. | N2: test local decoration plus global theme precedence for enabled, focused, error and disabled borders. Do not assume global input theme overrides every local field. |
| Direct Material cards | Train/weekly overview and WeightCard render Card directly. | N3 handles ordinary Material appearance; N4 adopts shared hard-shadow rendering where required. CardTheme cannot express arbitrary offset BoxShadow. |

Proposed `AppSurfaceDecorationTokens` owns only surface policy. Keep settings
gradient/category resolution in a focused settings recipe, proposed
`AppSettingsPresentationTokens`, if existing extensions cannot represent it.
Do not make a general surface token depend on SettingsAccent or widget types.
Document each new field's consumer and default; avoid fields with no consumer.

For settings category inputs, keep current Color-based call sites compatible.
Introduce a centralized semantic category mapping with a literal-color fallback
for unknown callers. A typed category migration can happen incrementally.
Do not scatter comparisons to SettingsAccent constants across feature pages.
Keep category identity visible through markers; Neo section titles use readable
ink and field focus uses the family recipe. Replacing only local primary can
break onPrimary pairing, so test the complete child theme and controls.

##### Train Segmentation Is Not A Drop-In Replacement

The current TonosSegmentedActionBar requires non-null callbacks, uses equal
Expanded widths in a Row, accepts text labels only, and fixes segment height.
The Train split bar needs a 3:2 split, a busy indicator, disabled Optimize,
a separate settings icon action, tutorial keys and a vertical fallback.
Do not replace the Train implementation with the current API as-is.

N2 should first supply reusable decoration without changing these behaviors.
N4 can extract a dedicated shared split-workout component or extend the API
with tests for all those requirements. A loading spinner must not become a
second active button. Disabled segments must expose disabled semantics and
have no pointer or semantic callback. One activation invokes one callback.
Treat Train's selected-tab rail separately from command segments: selection
needs selected semantics, while Start/Optimize are commands.

##### Pilot Details Previously Missing

- SevenDayFocusCard is a direct Card; its More link uses primary. It also has
  a transparent Material control with a local radius 16. Record this control
  separately from the outer card in N4; transparency alone is intentional.
- PresetsLoaded contains its own shape and primary-color treatment. Inspect
  those states in N4 before claiming that CardTheme styled the plan list.
- The profile avatar's fixed palette and white text are product identity.
  Record that exception; do not classify every Colors.white as a theme defect.
- WeightCard's completed color overrides CardTheme.color and applies alpha.
  Test the resulting composite in both modes and specify on-completed text if
  the normal foreground is unsuitable. Do not make a saturated green opaque
  merely by setting the completion alpha to 1.
- The Weight Units modal is opened using the page context; the category Theme
  inside a settings section is not proof of the modal's inherited colors.
  Test the actual open dialog under the app theme and local preview theme.
- English Train tabs and action rows have fixed heights. Existing French/
  large-text fallbacks do not prove English 2.0 fits with heavier typography.
  Exercise both before declaring layout parity; record any necessary responsive
  fix as a behavior-preserving shared layout change.

##### N2 Execution Order And Stopping Point

1. Capture current primitive assertions and exact defaults before modifying
   constructors. Use the existing theme tests as the starting evidence.
2. Add the surface policy, Classic registration and fallback accessors. Test
   with an injected synthetic outlined/hard-shadow recipe without registering
   a production family.
3. Wire TonosSurface and sheet decoration. Test override precedence, clipped
   content, an outer shadow, ink feedback and effects-off output.
4. Add settings recipe controls for gradient and category treatment with
   Classic defaults. Verify hero/section/field rendering in existing tests.
5. Add action decoration only where a real consumer needs it. Defer optional
   animated displacement; static borders and hard shadows are the first slice.
6. Update Theme Lab's effects transformation for any new shadow-bearing values.
   Ensure effects-off removes explicit depth and preserves borders/selection.
7. Give the user exact changed-file commands and record their results. N2 ends
   with reusable capabilities verified; family registration belongs to N3 and
   broad route adoption belongs to N4/N5.

This ordering corrects the earlier matrix heading: some listed changes are
N3 family recipes or N4 route adoption, not all N2 implementation requirements.

##### Remaining Visual Evidence And Acceptance

The eight written briefs above are inputs for eight actual visual proposals.
Assign stable IDs N1-TL/TD (Train), N1-WL/WD (workout), N1-UL/UD (User Information)
and N1-DL/DD (dialog). Render or sketch each with matching content and viewport;
record tool, font, dimensions and scale. A mockup must be labeled as a proposal,
not a Flutter screenshot. Link the artifacts here when created.

Review card density, border weight, shadows, category accents and text hierarchy
across all eight. Record accepted or revise for each, with a short reason.
Do not infer user acceptance from the instruction to audit or from the absence
of feedback. Actual Flutter previews in N3 remain a second checkpoint.

The revision 5 approval completes the N1 visual deliverable. It does not
qualify Flutter rendering, which remains an N3 checkpoint. No font was added, so
there is no new font-license requirement; actual device fallback coverage for
the app's supported scripts remains part of N3/N6 verification. Sections naming
Space Grotesk/IBM Plex Mono are optional future candidates only.

### N2. Shared Recipe Extensions

1. Implement the missing outline/shadow/state capabilities found in N1.
2. Give Classic exactly its existing values and preserve all previous behavior.
3. Update shared renderers rather than adding screen-level family conditions.
4. Test actual rendered borders, shadows, focus, effects-off and clipping.
5. Check existing Classic tests and scoped style-ratchet approvals. Do not
   increase a baseline or add blanket exemptions to hide violations.

Exit: reusable support with Classic regression evidence; family still not
available to ordinary users.

#### N2 Implementation Record (2026-09-11, verified)

N2's bounded shared-capability slice is implemented. The change deliberately
does not add the Neo-Brutalism family, alter stored theme preferences, expose a
new selector, or migrate pilot routes. Those decisions remain N3/N4 work.

Implemented shared boundaries:

- `AppSurfaceDecorationTokens` defines typed semantic outline/depth policies
  for Tonos panels, raised panels, cards, compact cards, inputs, sheets and
  media surfaces. `AppSurfaceDecorationRole` stays in the token layer and
  `TonosSurface`/`TonosSheet` map their existing variants explicitly.
- Classic registers the new surface policy with the exact previous behavior:
  input-only outlines, compact-card explicit effect-token shadow, card and
  sheet effect-token depth, and no added depth for the remaining roles. The
  ThemeData and BuildContext fallback accessors use the same Classic recipe
  when an injected theme is incomplete.
- `TonosSurface` and `TonosSheet` preserve their Material and InkWell paths,
  clipping, padding, margins, close/tap callbacks and semantic labels. An
  explicit outline override still wins over the policy. Explicit shadows are
  painted outside clipped content and are omitted when the active effect recipe
  resolves to a no-effects shadow.
- `AppSettingsPresentationTokens` owns settings hero gradient/solid selection,
  hero hard-depth policy, category-control primary inheritance, repeated border
  alpha values, icon fills and save-bar border alpha. Classic values reproduce
  the prior recipe; settings borders now use the existing
  `AppShapeTokens.outlineWidth` role.
- Token copy/lerp/fallback behavior, injected surface and sheet rendering,
  outline precedence, effects-off shadow removal, settings category-control
  inheritance and Classic extension registration have focused coverage.

The user-run formatter, corrected analyzer, targeted/full theme tests and
`git diff --check` are complete. The final run reported 218 passing tests and
matching ratchet report and enforcement output. This establishes automated
verification for N2; it does not establish Neo visual approval or device
qualification. N3 remains responsible for complete light/dark family
definitions, Theme Lab preview, palette/component recipes and visual review.

### N3. Complete Family And Theme Lab Preview

Pre-N3 review: corrected obsolete N1 approval statements and strengthened
sheet coverage to use a zero-blur shadow, scope the wrapper lookup, and check
effects-off outline/clipping preservation. Added rendered gradient/solid hero
coverage. The user verified these review changes: both test files formatted,
scoped analysis reported no issues, all 220 theme/configuration tests passed,
and diff-check reported only existing line-ending warnings. The prior 218-test
run and ratchet enforcement remain historical evidence. The review gate is
complete and N3 can begin.

1. Add complete light/dark definitions and all extensions. Use the existing
   font family initially; new font assets are optional future work.
2. Register stable identity, factory construction and capability handling.
3. Audit enum switches and tests that assume Classic is the only family.
4. Add a development-only Theme Lab family preview; keep gallery state separate
   from stored application preferences. Localize any exposed family label.
5. Render the eight pilot views plus component states. Measure contrast using
   actual rendered colors, not only palette swatches.
6. Obtain visual approval or revise before proceeding to broad adoption.

Exit: both modes render coherently; unavailable/release requests still resolve
according to policy; preview does not change user preferences unexpectedly.

#### N3 Implementation Record (2026-09-11, scoped-verified; visual review pending)

The first N3 implementation slice is present and remains development-only
until rendered preview review and later route qualification are supplied. It
includes:

- AppThemeFamily.neoBrutalism with the stable neo_brutalism code and both
  brightness values.
- Cached light and dark factory branches in AppThemeFactory.
- A complete NeoBrutalismThemeDefinition with explicit per-brightness
  ColorScheme values, all current app-owned ThemeExtension types, compact
  Neo geometry, solid settings presentation, and zero-blur (3,3) depth.
- Material recipes for cards, buttons, FABs, fields, app bars, both bottom
  navigation APIs, tabs, dialogs, sheets, menus, snackbars, selection
  controls, dividers, tooltips and progress indicators.
- Theme Lab family labeling and effects-off removal for the Neo tooltip shadow.
- Focused family, capability, preference, factory, palette, extension,
  material-recipe and Theme Lab picker/effects tests.

The user-run N3 automated verification completed with these results:

- `dart format test\theme\theme_lab_page_test.dart`: one file checked, no
  formatting changes.
- `dart analyze lib\main.dart lib\theme test\theme`: no issues found.
- `flutter test test\theme test\providers\app_configuration_test.dart`:
  228 tests passed.
- `git diff --check`: no whitespace errors; only the repository's existing
  LF/CRLF conversion warnings were reported.

The initial verification attempt found an unsupported `Finder.isEmpty` test
guard and two Theme Lab assertions that did not settle the picker or select
the Neo-specific tooltip recipe. Those test-only issues were corrected before
the passing rerun above. This is scoped automated evidence, not visual
acceptance. The user then manually smoke-tested Theme Lab on-device: Neo was
selectable, light and dark previews rendered, effects could be enabled and
disabled, and the Tonos surface gallery remained readable in all four shown
brightness/effects combinations. The supplied captures do not cover the eight
documented pilot routes or the reduced-motion-on state. The remaining N3 gate
is manual visual review of those pilot states in both brightnesses, with
effects and reduced motion checked. No public selector, route migration or
release enrollment is included in N3.

#### N3 Review Corrections And Remaining Evidence

The earlier 228-test result applies to the pre-review implementation. The
review corrected dark semantic-container foregrounds, selected navigation/tab
foregrounds, snackbar action contrast, light field focus contrast, and disabled
button colors. Picker tests now fail instead of silently returning when a
required family is absent. New tests check resolved foreground/background
contrast and disabled action differentiation. The user rerun passed all 230
theme/provider tests; formatting checked three files and changed two. The
paste reports no analyzer issues but omits the analyzer command itself.
Diff-check reported only LF/CRLF warnings. This verifies the review fixes,
not the remaining preview implementation described below.

At the time of this correction record, the generic Theme Lab gallery did not
contain the eight full pilot compositions. That implementation gap has since
been closed by the development-only neo_brutalism_pilot_gallery.dart preview.
The remaining gap is rendered acceptance of those compositions and their
contrast on the target device, not the existence of a route the user can open.
The approved colored pilot panels, continuous navigation indicator/frame, and
completed-set marker/shadow are now covered by the pilot implementation and
focused tests; do not infer their visual approval from generic surface samples.

Correction to the earlier manual checklist: gallery sheet close actions and
many sample buttons/selection controls are intentionally no-ops. They do not
open or dismiss real modal sheets. Reduced motion changes app motion tokens;
it does not promise that every framework dropdown animation or loading spinner
stops. Theme Lab overrides text scaling with its slider, so changing the phone
font setting is unnecessary for gallery testing. No further screenshots are
needed to prove implementation once the pilot preview is present. The pilot is
now present; N3 remains open only for rendered approval of the documented
states and target-device contrast.

#### N3 Implementation Specification And Evidence

This section records the execution contract and remaining evidence for N3. It
takes precedence over earlier shorthand describing the remaining work as only
manual review. Revision 5 of `theme-n1-proposals.html` remains the approved
visual reference. The values identified as implementation guidance below are proposed
Flutter translations, not additional user-approved mockups. Preserve the
approved hierarchy if responsive layout requires different spacing.

##### N3-R1. Preview Architecture And Ownership

Add a clearly labeled pilot-preview entry in `lib/theme/theme_lab_page.dart`.
It must expose Train, Workout, User Information and Weight Units under the
selected family, brightness, effects setting and text scale. Each pilot must
be individually reachable without scrolling through the entire generic gallery.
Use the existing Theme Lab preview theme so all registered extensions and the
effects transformation remain active. Do not create a second theme builder.

Proposed implementation files under `lib/theme/` may contain fixture hosts and
fixture data. Label them as development previews. Reuse production presentation
components where possible. If a component couples rendering to database access,
extract a shared presentation component with explicit inputs and callbacks;
preserve the existing production constructor through an adapter if needed.
Do not copy an entire production screen and maintain two styling implementations.

The fixture host owns temporary state only: selected tab, expanded exercise,
edited weight/reps, completed sets, form values and selected units. No database,
network, camera, profile write or real active-session provider is needed.
Changing brightness/effects must preserve this state. Provide an explicit reset
action to restore deterministic fixture values. Preview Save/Finish actions
may display local confirmation, clearly labeled as a preview; do not save data.

N3 establishes these reusable visual owners and their previews. N4 wires any
remaining real-route adapters and tests real provider/storage behavior. This
boundary must not leave N3 waiting for an app-wide family selector to capture
its own previews. Keep the existing release guard and compile-time capability
policy. English developer-only gallery headings are consistent with the current
gallery; production strings in reused controls retain localization ownership.

##### N3-R2. Color And Foreground Contract

Use the exact role colors below in each brightness mode. The dark column
intentionally lifts the colored roles slightly toward luminous neon while
keeping the same semantic ownership. Colored panels do not become charcoal in
dark mode.

| Role | Light | Dark | Foreground / border |
| --- | --- | --- | --- |
| Page canvas | `#FFF8E7` | `#171717` | Page text light `#161616`, dark `#FFF8E7` |
| Neutral fallback surface | `#FFFFFF` | `#272727` | Brightness-appropriate page text |
| Overview / hero / primary action | `#FFE34D` | `#FFEA61` | `#161616`; black border |
| Active Plans panel | `#FF92BF` | `#FF6BAE` | `#161616`; black border |
| Plan item | `#64DDE0` | `#55F0EA` | `#161616`; retain separate identity marker |
| Supporting control / Identity section / dialog | `#C4A1FF` | `#D2A8FF` | `#161616`; black border |
| Body metrics section | `#FFB36B` | `#FF8A3D` | `#161616`; black border |
| Main exercise card | `#FFD2A3` | `#FFC184` | `#161616`; black border |
| Supporting exercise surface | `#DAC8F1` | `#E0C9FF` | `#161616`; black border |
| Completed exercise | `#96B967` | `#A6D466` | `#161616`; black border |
| Completed set row | `#B9D994` | `#C5EC91` | `#161616`; ink outline and marker |
| Settings field interior | `#FFF0A6` | `#FFE875` | `#161616`, secondary `#38312B` |
| Unselected dialog choice / category label | `#FF92BF` | `#FF6BAE` | `#161616`; black border |

Do not globally replace `ColorScheme.onSurface` with dark ink in dark mode:
page text and neutral surfaces still need light foregrounds. A colored surface
needs an explicit matching foreground role, inherited by its text and icons.
Audit nested labels, units, placeholder text, dropdown arrows and disabled
states; setting only the parent's fill is insufficient. Use a local theme or
explicit semantic foreground properties at the shared presentation boundary.

Keep the review's corrected contrast pairs. In particular, pale purple is a
fill, not suitable small text on yellow or white. Use dark ink for navigation
labels in both modes. Light-mode field focus may use `#64408F` with a 3px
border; on dark neutral fields the brighter purple remains appropriate. Focus
on pale colored fields also needs a contrast-safe outline. Measure the actual
composited pair, including alpha, instead of relying on a color's name.

Do not recolor exercise images, plan identity markers, or semantic errors to
match decorative panels. Peach/lavender exercise variation needs a named role
and purpose; never assign colors by even/odd exercise index.

##### N3-R3. Geometry And Depth Contract

All dimensions are Flutter logical pixels. Use theme-owned values; proposed
new roles must include Classic defaults, copyWith and lerp coverage.

| Element | Border / radius | Effects-on depth |
| --- | --- | --- |
| Overview raised panel | 2px black; 8px radius | `(4,4)`, blur 0, spread 0, black |
| Ordinary colored section | 2px black; 8px radius | None unless explicitly raised |
| Exercise card | 2px black; 4px radius | None |
| Completed row | 1px `#161616`; 3px left marker; square corners | `(3,3)`, blur 0, spread 0, `#161616` |
| Bottom navigation frame | 2px black; 6px radius | `(3,3)`, blur 0, spread 0, black |
| Settings field | 2px black; 4px radius | None |
| Weight Units dialog | 2px black; 12px radius | `(4,4)`, blur 0, spread 0, black |
| Primary standalone action | 3px black; 4px radius | `(4,4)`, blur 0, spread 0, black |
| Workout Finish action | 2px black; 4px radius | `(3,3)`, blur 0, spread 0, black |

The 4px raised roles come from the approved board's final CSS cascade; do not
silently normalize all depth to the existing generic `(3,3)` token. Add a
bounded semantic override when necessary. Do not change Classic depth values.
Do not paint both Material elevation and a custom shadow. Reserve at least the
shadow offset outside the decorated child so parent clipping cannot cut it off.
Clip ink/content inside the rounded shape, with the shadow painted outside it.

Effects-off removes optional shadows only. Keep fills, outlines, selected
indicators, completed-row marker, layout spacing and hit targets. Do not remove
the dialog's modal scrim: it communicates modality, not decorative depth.

##### N3-R4. Train Preview

Render a full composition with Overview/Plans selector, profile avatar, Weekly
Overview, Active Plans, Start Workout/Optimize action rail and bottom tabs.
Use deterministic Full Body plan data; show Quads 6, Chest 6 and Upper Back 3,
with representative media/body-map content from existing assets when available.
Do not invent a separate media renderer merely to match the HTML omission.

Weekly Overview uses yellow and raised depth. Active Plans uses pink. Its Full
Body item uses cyan with a preserved blue fixture identity stripe (`#1976D2`),
which remains data-owned. Progress bars use pale yellow tracks and dark fills.
The overview selector uses a 3px black outer rail, purple unselected segment,
yellow selected segment and a dark bottom selection marker. Its segmented
treatment must not be applied to the bottom navigation.

Bottom navigation is one continuous yellow region containing the real icons
and labels Train, Catalog, Logbook, Progress and Profile. Train is initially
selected. The selected segment is purple with a 4px ink underline. Segments
have no gaps, individual outlines or individually rounded backgrounds. Only
the outside corners are rounded. A shared presentation owner must retain
selected semantics, focus and tap targets. BottomNavigationBarTheme alone
cannot paint this complete segmented background/frame recipe.

Start Workout is yellow; Optimize is purple. Preserve readable text at large
scale using wrapping or the existing stacked fallback. Use a continuous shared
rail with a divider; do not add a second shadow to each segment. Preview tab
taps update local selection; action taps provide local feedback. Also provide
an explicit empty-plan fixture state and ensure the call to action remains
reachable. The baseline capture uses the populated state.

##### N3-R5. Workout Preview

Show Barbell Squat expanded with three sets at 40 lbs and 8 reps; Set 1 is
completed and Sets 2/3 are incomplete. Include a second exercise header, Bench
Press - Barbell, with 0/3 done. Use peach for the main exercise surface; reserve
lavender for an explicitly identified supporting role, not automatic alternation.
Include real editable numeric fields, completion checkbox, add/remove controls,
collapse control, count, and a visible yellow Finish Workout action.

Exercise cards remain flat. Completed rows alone get green, the 1px frame,
3px left marker and hard shadow. Leave approximately 4px trailing clearance
and 12px bottom separation as starting layout guidance. Incomplete rows stay
transparent over the exercise card with a thin ink separator; do not surround
every row with a thick box. Align weight/reps columns, unit labels and trailing
controls. Use existing typography, with tabular numerals only if supported.

Toggle completion and update the local count; enter different values; collapse
and reopen; add/remove a fixture set. Values must survive theme/effects changes.
At 2.0 scale, use responsive reflow instead of fixed widths that clip labels or
shrink text. Completion remains evident with effects off through the checkbox,
count, green fill and left marker. A generic checkbox row is not sufficient
evidence for the approved completed-row presentation.

##### N3-R6. User Information Preview

Use a yellow hero, pink category labels, purple Identity section and orange
Body metrics section. All colored panels use dark text and black outlines in
both modes. Include Name (fixture Alex), Gender, Date of birth, Height and
Current weight with a unit label, and a yellow Save changes action. Prefer
the existing settings presentation boundary and actual field widgets.

Fields use pale yellow interiors. Show normal, focused, error and disabled
states without changing field height when focus changes. Dropdowns must open
and dismiss in the fixture host; preserve expanded/wrapping behavior. Keep
keyboard-visible content scrollable and Save reachable. Changing preview
brightness must not reset typed text, focus or selection. Save displays preview
feedback without altering the user's profile. Include one deterministic error
fixture rather than relying on real validation writes.

##### N3-R7. Weight Units Dialog Preview

Provide an explicit Open Weight Units button that opens an actual modal using
the preview's inherited theme. Show a purple dialog over the current preview
with a dark scrim. Title: Weight Units. Pounds/lbs starts selected on yellow;
Kilograms/kg is unselected on pink. Selected choice has a 3px black outline,
unselected 2px, both 4px radius. Text and radio glyphs use readable dark ink.
Use the dialog frame/depth recipe above without duplicate Material elevation.

Selecting an option closes the modal and updates only the host's local unit
label. Reopening reflects that selection. Back/dismiss returns no selection
and preserves the prior value. Exercise these paths; a permanently painted
TonosSheet with a no-op close callback does not verify modal behavior. At large
text, keep both choices reachable and allow vertical growth/scrolling within
safe areas. Effects-off preserves the scrim, frame and selected state.

##### N3-R8. Files, Tests And Acceptance

Implementation record, automatable qualification complete with rendered
acceptance pending: the
development-only
`neo_brutalism_pilot_gallery.dart` is hosted directly by Theme Lab when the Neo
family is selected. It owns disposable fixture state only: pilot choice,
Train's selected tabs and empty-plan state, workout expansion/sets/completion,
form values/validation fixture, and Weight Units selection. It does not access
providers, repositories, storage, routes, camera APIs or network services.

The four compositions now include the required profile avatar, populated and
empty Train states, continuous bottom navigation, completed-row left marker and
hard shadow, the collapsed Bench Press - Barbell fixture, editable/addable/
removable workout sets, local finish/discard feedback, normal/focused/disabled/
error-capable User Information controls, and a real cancellable Weight Units
modal. Colored panels, dialog choices and their
frames use dark `#161616` foregrounds/borders in both brightness modes; neutral
surfaces continue to use the brightness-specific surface foreground. The pilot
uses `AppEffectTokens` for optional hard shadows and `AppMotionTokens` for its
two size/state animations, so the existing Theme Lab controls affect it without
adding another effects or motion switch.

`AppEffectTokens` now owns `raisedPanelShadowOffset`,
`primaryActionShadowOffset` and `dialogShadowOffset`, with Classic `(0,2)`
defaults and Neo `(4,4)` values; general card/completed-row/navigation depth
continues to use `cardShadowOffset` at Neo `(3,3)`. Its copy/lerp coverage was
extended accordingly. `theme_lab_page_test.dart` now covers effects-off border
preservation, pilot selection, the populated/empty Train state, the data-owned
blue identity marker, the collapsed second exercise, set completion and
addition, the validation fixture, selected navigation, real dialog
selection/cancellation, the live reduced-motion duration, narrow 320px/2.0x
pilot mounting, and local state survival across a Theme Lab brightness change.
tonos_theme_ready_test.dart separately verifies that Classic still owns a
Material Card while Neo owns the semantic TonosSurface boundary. The expanded
scripts/verify_neo_refinement.ps1 now includes the pilot, route ledger,
theme-ready consumers, and git diff --check. This is scoped automated
evidence; rendered pilot acceptance, real-route qualification and
physical-device checks remain separate.

Start with `neo_brutalism_theme.dart`, `theme_lab_page.dart`, the existing
surface/effect/shape/settings tokens and shared widgets. Inspect `train_page.dart`,
`weight_card.dart`, `settings_tiles.dart` and the Weight Units dialog owner for
reuse before introducing proposed preview components. New color/depth roles
must be semantic and paired with foregrounds. Do not add family-name branches
through feature code or put production recipe constants in fixture hosts.

Add meaningful rendered tests for colored foreground inheritance, the single
navigation frame/selection marker, completed-row shadow versus flat incomplete
row, and effects-off preservation. Test local state across light/dark changes,
real modal selection/cancellation, and narrow layouts at 1.0 and 2.0. Use both
families when shared behavior changes. Remove silent early returns from required
coverage; explicitly test unavailable-family behavior separately. The current
focused suite now covers these automatable cases; the remaining rendered
comparison still requires device captures.

Capture N3-TL/TD, WL/WD, UL/UD and DL/DD: four compositions times two modes,
with the same fixture state per pair. Supplement with focused/error/disabled,
effects-off and 2.0 states; do not require duplicate control screenshots already
accepted. Record device, logical viewport, family, brightness, Theme Lab text
scale, effects setting and revision/dirty-tree identity. Measure resolved text
contrast (4.5:1 for normal text, 3:1 for large text) and essential control/focus
boundaries (3:1 against adjacent colors); disabled controls remain visually
distinct even where contrast exceptions apply. Automated color assertions do
not establish absence of clipping or correct compositing on a device.

Reduced-motion checks must identify a real app-token-driven transition; static
samples cannot prove it. Assert zero app motion durations separately and report
framework-controlled animations honestly. Do not promise that all spinners or
dropdown transitions stop. Keep the normal gallery usable while testing.

Exit only when the preview compositions exist, relevant user-run verification
passes, and the rendered recipe is accepted. Record any deviation from the
approved board explicitly, with its reason and review outcome. Generic gallery
acceptance and the 233-test run do not close this remaining implementation list.

## N4 Implementation Record (2026-09-11)

Status: N4 functional and real-route acceptance is complete for the current
development scope. The user exercised Train, active workout, User Information
and Weight Units in both brightness modes at the documented text scales, and
confirmed switching, restart persistence and disabled-family behavior. The
Neo-Brutalism rendering differs from the original proposal in some visual
details, so this record does not claim pixel parity with the N1 reference.

lib/theme/debug_theme_family_control.dart adds the development-only family
switcher beside the existing debug light/dark control. It consumes
ThemeProvider.availableFamilies, cycles through the available families, and
calls ThemeProvider.setFamily rather than writing SharedPreferences directly.
It is a direct IconButton because this control is mounted above the app
Navigator; a PopupMenuButton or Tooltip there would require an Overlay that is
not available at that boundary. Its semantic label identifies the current and
next family.
lib/main.dart mounts it only when both kDebugMode and TONOS_THEME_SWITCH are
active. The switcher is therefore unavailable to release builds and disappears
when experimental families are disabled.

The existing MyApp provider boundary already rebuilds both cached
brightness-specific ThemeData values from the selected family. MainScreen
continues to retain its tab/page cache, so the family switch does not create a
second route, repository, or session state owner. No business logic,
navigation, database, active-session, profile, or unit-preference behavior was
changed for N4.

test/theme/debug_theme_family_control_test.dart verifies that the control
cycles through capability-approved families, persists a Neo selection through
the provider boundary, returns to Classic, works at the root-builder placement
without an Overlay exception, and hides itself when experimental families are
unavailable.
The existing provider tests continue to cover stored-family fallback and queued
preference writes. The user-run route/device evidence covered local form
values, focus, selections, completed sets, mode switching, restart
persistence, the 1.15 baseline scale, the 2.0 stress scale and Classic
regression.

The first device launch exposed an Overlay assertion because the initial popup
and tooltip implementation was mounted above the Navigator. N4 now uses a
direct palette button that cycles through the capability-approved families.
The user reran the debug build and confirmed that this control works as
intended. That smoke result closed the control implementation issue; the
subsequent route review closed the real-route acceptance matrix below.

### N4. Pilot In Real Routes

1. Add or extend a debug-only family control using the existing selection
   provider and availability policy, not a second preference mechanism.
2. Exercise Train, active workout, User Information and Weight Units on-device.
3. Fix shared recipe defects at the owning layer. Preserve local state while
   switching: entered form values, focus, selections and completed sets.
4. Test restart persistence for an available family and fallback when disabled.
5. Review both modes, 1.15 baseline scale and 2.0 stress scale before expansion.

Exit: real-route pilot accepted without Classic or behavioral regressions.
Visual differences from the original proposal are recorded as follow-up
design work rather than treated as behavioral failures.

### N4.5 Proposal Realignment Checkpoint (2026-09-11)

Review fixes 6-8 (2026-09-12): implemented, awaiting user-run verification.
Classic Weekly Overview again uses its original Card and 16px content padding;
Classic settings inherit their original field styles, hero foregrounds, and
section text theme. Neo retains the colored overview surface.

Border ownership is now explicit: ColorScheme outline/outlineVariant describe
neutral controls, with warm-paper boundaries in dark mode. The existing
subtleOutline surface role retains near-black framing for colored panels.
Health Trends uses the neutral role, as do unselected generator choices and
TonosSurface defaults. Explicitly colored TonosSurface panels and the Train
selector divider retain the colored-panel edge. Classic border behavior is
preserved. New callers must choose the role for their actual background.

Neo colored settings inputs and the pilot gallery share the semantic focusRing
color #64408F at the 3px focus width. Neutral dark inputs retain their lighter
purple Material focus border; bright settings inputs need the darker purple.
Regression checks cover inherited Classic input defaults and focus contrast.
Phone review should compare Classic Overview/settings to the accepted baseline,
check dark Neo empty Health Trends cards, and focus settings fields in both
brightness modes and Theme Lab. Earlier test results do not verify this patch.

Readability review items 1-5 (2026-09-12): source fixes implemented,
verification pending. This is not a sign-off for the remaining review items.

- Workout numeric inputs use transparent fill over peach/green, with ink text,
  labels, and underlines. Completed-card counts and check icons also use ink,
  not the green used for their background.
- All four User Information dropdowns explicitly pair their popup fill with
  ink labels and icons. Neutral Classic dropdowns retain their defaults.
- Weekly Overview's more affordance uses ink on yellow. Selected generator
  choices use ink for title, subtitle, and radio on their yellow surface.
- Weight Units options use ink text and radios on yellow/pink. The selected
  option uses the focus-ring border width rather than the ordinary outline.
- Actual WeightCard regression tests cover light/dark, incomplete/completed
  count contrast, check-icon contrast, and numeric-field styling. These tests
  have not yet been run. Other changed routes still require phone checks.

Verification: run formatting, analyzer, and the theme test suite. On the phone,
repeat in Neo light and dark: edit workout weight/reps and complete every set;
open each User Information dropdown; check the overview more affordance with
more than three focused body parts; change generator choices; open Weight Units
and select each option. Confirm text remains visible, the selection is clear,
and values persist. Spot-check Classic to confirm unchanged styling.

Dark-mode follow-up (2026-09-12): the theme now supplies separate text and
structural edge colors. The Train selector, yellow overview, pink plan groups,
cyan plan rows and split action frame resolve to near-black outlines while
dark-canvas text stays warm paper. Material colored surfaces and the
generation action frame use the same edge treatment. Readability cues for
neutral controls and sheet handles are preserved. Regression expectations
cover the outline/text split and use floating-alpha colors consistently.
Code and documentation are updated; analyzer, tests and phone review for
this follow-up await the user's run. Earlier passing results do not verify
this new patch.

Preview architecture and depth review items 9-10 (2026-09-12): source fixes
are implemented, verification pending. Theme Lab still owns fixture data and
preview-only callbacks, but it no longer owns parallel visual recipes for the
main pilot surfaces. The Neo gallery now composes the production
`TonosTrainTabs`, `FocusedSetsList`, `TonosSurface`, `GenericBar`,
`ExerciseMediaFrame`/`BodyHeatmap`, `WeightCard`, `settingsInputDecoration`,
and `TonosBottomNavigationBar` widgets. This keeps
the gallery useful as a controlled fixture without allowing a preview-only
panel, field, plan row, workout row, media frame, or navigation rail to drift
away from the real route.

The gallery's workout fixture remains local and disposable: it creates a
`WeightExercise` with three sets and the first set completed, while
`WeightCard` owns the real set-row rendering, completion cue, add-set action,
numeric fields, and collapse behavior. The Train fixture now includes a real
heatmap-backed media frame inside the production `GenericBar`, so the preview
exercises the same media boundary used by plan/catalog content. Theme Lab also
exposes a development-only `Reset preview` action. Reset returns family,
brightness, locale, text scale, effects, reduced motion, pilot selection and
fixture state to their initial values; it does not write user preferences or
application data.

Dialog depth is now bounded by the shared `TonosDialogFrame`. Both the real
Weight Units dialog and the gallery dialog keep an ordinary `AlertDialog` for
semantics and dismissal, but add the theme-owned hard shadow around the
dialog-sized surface rather than decorating the route-sized dialog builder.
`TonosSurface` uses the raised-panel shadow offset for `panelRaised` and the
card offset for other explicit-shadow roles. `TonosTrainTabs` uses the slightly
smaller card offset to keep its compact selector from carrying a heavy lower
edge, and removes an invisible effects-off shadow entirely. This preserves the
intended Neo `(4,4)` raised-panel depth while leaving the selector and
compact-card roles separate, and effects-off still removes the optional shadow
through the existing effect-token transformation.

Verification: run formatting, analyzer, and the focused Theme Lab/theme widget
tests. In Theme Lab, select Neo, switch among Train, Workout, User Information
and Weight Units, use the reset action, toggle effects and brightness, and
confirm that the real shared cards, fields, media frame, bottom navigation and
bounded dialog remain readable and interactive. Compare the gallery with the
corresponding production routes after the test run; preview fixture values may
be disposable, but presentation, color roles, outlines, focus treatment,
radius and shadow behavior should match.

Navigation follow-up (N11, 2026-09-12): the shared navigation owners now carry
the remaining proposal details. Neo's bottom navigation is one continuous
yellow rail with one near-black outer outline, the theme card shadow offset
`(3,3)` with zero blur, a purple selected segment, and a 4px near-black bottom
indicator. The selected background is an inert visual layer behind the normal
Material `BottomNavigationBar`, so item semantics, focus, ripples and touch
targets remain framework-owned. Effects-off removes only the optional outer
shadow; the yellow rail, purple selection, dark icon/label foregrounds and
underline remain.

The shared Overview/Plans selector now gives each Neo segment its own near-
black outline, keeps a small rail-colored gap between segments, preserves the
yellow-selected/purple-unselected fills, and paints a 4px dark selected marker.
Each segment exposes its label, button role and selected state through
semantics. Classic continues to use its existing pill selector and ordinary
bottom-navigation recipe. The dialog frame also shrink-wraps its `AlertDialog`,
so the `(4,4)` hard shadow is bounded to the modal surface rather than the
dialog route or backdrop.

Follow-up audit of all thirteen findings: see [theme-review-1-13.md](theme-review-1-13.md).
That record supersedes earlier dialog-shadow and preview-parity verification
claims and documents the additional code/test corrections and pending checks.

Review items 12-13 (2026-09-12): source implementation is complete; user-run
verification remains pending. Neo User Information now uses the yellow hero and
save-action roles, pale-yellow `#FFF0A6` field interiors, black structural
outlines, pink category labels, and theme-owned hard depth. The hero depth and
save-action depth are separate explicit presentation roles, and the Neo save
bar uses the same near-black structural boundary rather than the dark-canvas
light outline. Classic retains the gradient hero, vertical accent markers,
accent borders and ordinary save-bar recipe. Neo section controls no longer
inherit category accents as their primary role; field focus and control
foregrounds continue to come from the shared contrast-safe recipes. Entered
values and insertion cursors in outlined settings fields also use the field's
near-black ink, including the Theme Lab fixture; Classic keeps its inherited
input text and cursor behavior.

Neo workout cards now use the existing theme card outline with a 4px radius.
Completed exercises use the darker green surface; completed set rows use the
lighter green, square corners, a 3px near-black left marker, 1px remaining
outline sides, and a dedicated compact `(2,2)` zero-blur shadow. Set groups
add 1px divider lines between rows while incomplete rows remain transparent and
flat. Completion state, editing, collapse behavior, change sets and stored
values are unchanged. Focused regression coverage now checks the settings
roles, completion colors and workout geometry; the Classic settings and
workout paths remain covered separately.

This checkpoint implements the first visual realignment pass against the
approved N1 proposal board. It is intentionally a role-and-owner pass, not a
pixel-copy exercise. Production content that was absent from the proposal,
including the weekly body heatmap, plan focus thumbnails, exercise thumbnails,
menus, and persisted controls, remains in place.

The Neo palette now keeps its colored roles saturated in both brightness modes,
with a restrained dark-mode lift rather than a separate visual language:

- The warm paper light canvas and charcoal dark canvas remain the page-level
  backgrounds.
- Yellow remains the overview/hero/primary-action role.
- Pink is used for active-plan group surfaces.
- Cyan remains available for plan/action rows and catalog accents.
- Purple is used for supporting controls, settings sections, dialogs, and
  secondary actions.
- Orange remains the warning/body-metric role.
- Workout cards use proposal peach, completed exercises use the deeper green,
  completed set rows use the lighter green, and the supporting session role is
  proposal lavender.
- Dark Neo raises the active role colors slightly: yellow `#FFEA61`, pink
  `#FF6BAE`, purple `#D2A8FF`, cyan `#55F0EA`, orange `#FF8A3D`, pale yellow
  `#FFE875`, completed exercise green `#A6D466`, completed set green
  `#C5EC91`, peach `#FFC184`, and lavender `#E0C9FF`. Light mode uses
  completed exercise `#96B967` and completed set `#B9D994`.
- This is a palette-only dark-mode refinement. Structural edges remain the
  approved near-black `#161616`, and hard-shadow offsets remain unchanged;
  the white/neon-border and neon-shadow alternatives from the inspiration
  notes are not adopted in this pass.
- Colored surfaces use ink foregrounds in dark mode instead of inheriting the
  warm-paper foreground intended for the dark canvas.

The visible route owners were updated as follows:

- Train's Overview/Plans selector has a Neo-only ink outline, black segment
  divider, yellow selected segment, purple alternate segment, and crisp offset
  shadow. Classic keeps its existing selector treatment.
- Weekly Overview uses the dashboard hero role with the raised-panel outline
  and hard shadow while retaining the body heatmap and focused-set interaction.
- Active-plan groups and the Plans tab sections use the pink plan-group role;
  plan rows use cyan fills with ink borders, a preserved accent identity rail,
  and hard offset depth.
  Their rename, delete, activate/archive, thumbnails, heatmaps, and menus are
  unchanged.
- Active workout WeightCards use proposal peach; completed exercises use the
  darker green surface, while completed set rows use the lighter green with
  the ink edge and compact completion shadow. Completion collapse, editing,
  change sets, and persistence are unchanged.
- The split Start Workout/Optimize action bar uses yellow Start Workout and
  purple Optimize surfaces inside one Neo ink frame and hard shadow without
  changing its text-scale fallback or callbacks. The selected bottom tab uses
  a purple color cue while the navigation remains one continuous rail.
- Settings heroes/sections/fields/save surfaces and the Weight Units choices
  use the yellow, purple, pink, and ink roles, with black text on the bright
  surfaces in dark mode.

The shared `TonosSurface` primitive now accepts a theme-owned color override
so route owners can select a semantic role without duplicating border/depth
recipes. Classic defaults remain unchanged. This checkpoint still requires
the normal user visual review in light and dark mode at the 1.15 baseline
scale. The plan-row identity rail is rendered inside the uniform rounded ink
outline so Flutter does not receive an invalid rounded multi-color border.
The debug family/brightness controls are compact and confined to the status-bar
area in the development build; they are not part of the release UI. This
checkpoint does not close the broader N5 route sweep.

### N4.6 Light-Mode Refinement Pass (2026-09-12)

The next refinement targets are implemented as role-owned presentation rather
than route-specific theme forks. Neo's debug family and brightness controls
now use the same compact hard-frame treatment as other Neo controls, while
Classic keeps its Material elevation. Workout setup weight and rep fields use
outlined compact controls, and the setup Save/Start action uses the shared
hard action depth.

The Catalog cards now use the production `TonosSurface` recipe in Neo,
including compact exercise-media frames, stronger anatomy dividers and
contrast-safe small stat accents. Archived-plan empty content uses a compact
neutral outlined state instead of reading as another active pink plan group;
Classic's empty state is unchanged.

Workout completion now has one bounded Neo sheet frame with explicit outline
and `(4,4)` depth. Its green completion header remains semantic, while summary
metrics use neutral framed tiles and readable theme foregrounds. The modal
route is transparent only for Neo so its route-sized surface cannot add a
second competing frame. These changes preserve the shared production widgets,
callbacks, stored values and accessibility behavior, and still require the
user-run analyzer, test and phone visual checks listed below.

### N4.7 Dark-Mode Refinement Pass (2026-09-13)

The dark-mode follow-up keeps the established saturated Neo palette and yellow
navigation bar while tightening the surfaces that previously became muddy or
disconnected. Completion and finish actions now share one reusable hard-depth
wrapper, with a shared black hard offset in both modes and no-op behavior
for Classic. The completion sheet remains one bounded raised surface, with a
semantic green header and neutral framed metrics rather than a collection of
competing colored cards.

Profile action and expansion rows now resolve foreground, icon and chevron
colors from the settings surface, so bright lavender sections use dark ink
instead of low-contrast white content. Plan-detail summaries use the production
TonosSurface raised-panel recipe in Neo while retaining the Classic Card.
Dark anatomy inactive regions and secondary content use explicit warm-muted
roles instead of near-black or opacity-only values. These changes are limited
to presentation tokens and shared widgets; route behavior, stored data and
Classic defaults remain unchanged.

The completion sheet's Neo density is now aligned with the compact Classic
composition without copying Classic decoration: normal phone widths keep all
four summary metrics on one row, and normal-scale exercise result cards use
tighter outer padding, set spacing, separators and badge spacing. Narrow or
large-text cases retain their responsive reflow. This is a Neo-only layout
refinement; Classic completion density and decoration remain unchanged apart
from the shared ERM trailing-alignment correction requested for both themes.

Completion rows also keep the ERM value beside its matching set result at
normal phone widths. The value occupies a right-aligned trailing column in
both themes and scales down rather than clipping; narrow or large-text cases
retain a right-aligned stacked fallback. This preserves the Classic alignment
while giving Neo the same compact vertical rhythm.

### N4.8 Current Screen Batch (2026-09-15)

The first-pass styling for the remaining Catalog, Logbook, and Progress screens
was implemented without changing route behavior, queries, units, selection,
or persistence. The current fixes include:

- Catalog and Logbook surface treatments, summaries, calendar states, and
  existing navigation/data ownership.
- Compact Neo Workout Report metric/range/Additional Details layouts while
  retaining responsive reflow for narrow and large-text cases.
- Health Trends cards that render their intended content and empty states
  instead of the previous dark placeholder blocks.
- Classic report insight boxes that keep values and units on the intended line,
  including the `lbs` Best Volume wording.
- A centralized exercise-detail modal presentation that disables Neo's outer
  theme drag handle and leaves the detail sheet's own interactive handle as
  the sole visible handle.

The user considers this batch good for now. The latest exercise-detail
verification supplied clean analysis and four passing contract tests. Broader
device, accessibility, route-ledger, and release checks remain N5/N6 work.

### N4.9 Theme-Ready Secondary Surfaces (2026-09-15)

This bounded compatibility pass prepares evolving, non-default routes for both
families without redesigning their products. `TonosThemeReadyCard` returns
the original Material `Card` recipe for Classic and a semantic
`TonosSurface` for Neo. Existing semantic and data-visualization roles supply
Neo-only metric, timer, add-action, and nutrition foreground colors where
needed.

Covered consumers:

- exercise definition body-part/muscle pages, definition info tiles, and full
  exercise history;
- cardio and stretch cards;
- current measurements and the generic trend page;
- nutrition bar details, food customization, and food logging.

No route, query, persistence, unit, repository, or product-flow behavior was
changed. The user supplied clean post-fix analysis for
`current_metrics_section.dart` and 32 focused tests passed. Full route,
visual, accessibility, and device qualification remains N5/N6 work, and final
Neo recipes remain deferred until the affected product areas stabilize.

### N5 Review Closure Update (2026-09-16)

The user accepted all 21 entries in the current Neo visual review as good for
now. The review includes Theme Lab, Train, Workout, Optimized Workout Settings,
Train2 and preset flows, Catalog, Logbook and Session Detail, Progress/Workout
Report, User Information, Weight Units, UI and Appearance, Edit Gym Profile,
Database Settings, Guided Tutorials, Bodypart Rankings, Muscle Rankings,
Volume Boundaries, Anatomy Mapping, Exercise Set Allocation, Exercise Editor,
and Flow Methods / Workout Progress Flows.

The final selector contrast correction is also user-verified: the selected
value on a bright Neo field uses dark field ink while the charcoal popup keeps
light option text. The user ran formatting successfully for the three affected
files, received clean analysis, and passed 63 focused Flutter tests. This is
current visual-review and targeted automated evidence, not a claim of exhaustive
route-state, accessibility, or release qualification.

### N5. Current Visual Review Accepted; Remaining Route-State Sweep

Automatable boundary work is in place for the current secondary-surface
extension, and the agreed 21-item visual review is accepted. The
`pre_q2_route_evidence_test.dart` records the explicit Classic/Neo card-wrapper
consumers and the semantic-token consumers for measurements and nutrition bars.
The expanded verification script includes those sources and tests. Neither the
review nor the source boundary proves every route/state is reachable or fully
qualified.

1. Follow the existing route ledger through catalog/details/media, plan
   generation, session history, progress, nutrition, settings, and tutorials
   for non-happy-path state evidence.
2. Include reachable legacy callers; do not infer coverage from a route name.
3. For each styling exception record migrated, intentionally retained with
   reason, unreachable with evidence, or deferred with an owner and impact.
4. Preserve identity colors, diagram semantics, and media assets. Correct only
   presentation omissions, not unrelated business logic.
5. Add focused rendered/interaction tests for newly discovered gaps and repeat
   representative Classic checks after shared changes.
6. Revisit the N4.9 compatibility consumers after their product designs
   stabilize; wrapper adoption alone is not final Neo route approval.

Exit: no unexplained reachable styling omissions within the agreed scope.

### N6. Qualification And Handoff

The repository-side qualification harness includes the complete pilot gallery,
the secondary theme-ready consumers, the route-boundary contract, and
`git diff --check`. The latest targeted selector verification was user-run:
formatting completed, analysis reported no issues, and 63 focused Flutter tests
passed. No Dart or Flutter command is run by Codex in this repository; the user
must run commands and supply their output.

1. Run the batch-specific analyzer, tests and style ratchet through user-supplied
   terminal output; record the actual commands and results.
2. Check light/dark, large text, localization, TalkBack, keyboard focus, rotation,
   overlays, live switching, restart, reduced motion and disabled effects.
3. Review approved screenshots against the new recipe and Classic's accepted
   baseline. Existing Classic images were captured at 1.15, not 1.0.
4. Investigate performance if needed using an explicitly supported non-release
   configuration; do not bypass release gating to obtain measurements.
5. Record acceptance, limitations and outstanding release work. Hand off to
   Step 14 for the public selector, then Step 15 for release qualification.

Exit: development qualification, not automatic public release approval.

## 6. Verification And Change Discipline

For every batch record changed files, decisions, automated results, manual
evidence and remaining issues. Use these statuses distinctly: planned,
implemented awaiting verification, automated verified, manually accepted.
Do not reuse historical test totals as evidence for new changes.

Codex must not run Dart/Flutter commands in this repository. Supply exact
batch-specific commands to the user and inspect their returned output. Git
whitespace checks are separate from runtime verification. Prefer tests that
assert rendered properties and behavior over source-string-only contracts.
Never blindly regenerate snapshots or approvals after a regression.

N1 and N2 are complete. N3/N4 and the current 21-item visual-review scope are
accepted. Continue N5/N6 only for unreviewed route states, accessibility,
device behavior, and release gating. The visual recipe remains adjustable at
future checkpoints; Classic preservation, state safety, and release gating do
not.

## 7. Exact Foundation Changes

### 7.1 Family Identity And Factory (N3)

In `lib/theme/app_theme_family.dart`, add enum member `neoBrutalism` with code
`neo_brutalism` and both Brightness values. Keep `classic` first and retain its
code. Do not persist enum indexes or display labels. `fromCode` should continue
returning null for unknown codes. Update exhaustive switches, including
`_familyLabel` in `lib/theme/theme_lab_page.dart`.

Create `lib/theme/neo_brutalism_theme.dart` with proposed public class
`NeoBrutalismThemeDefinition` and static `light()`/`dark()` methods. Share a
private builder to avoid duplicating wiring, but supply explicit per-brightness
colors. In `app_theme_factory.dart`, add cached definitions and branches for
both lookup methods. Do not rebuild ThemeData in feature-widget build methods.
Update its stale comment that only Classic is registered.

Do not register the enum in a partial batch that cannot construct both modes.
Registration, complete definition and exhaustive-switch fixes form one change.

### 7.2 Availability And Preferences (N3-N4)

`app_theme_capabilities.dart` already allows non-Classic families only when
experimental themes are enabled and the build is not release. Preserve this
policy; adding another condition to make the new family visible in release is
not part of N1-N6. Reuse `availableFamilies` for the development picker.

`lib/providers/theme_provider.dart` already exposes `setFamily` and serializes
selection changes. The debug control must call that API and await its result.
Do not write SharedPreferences directly, mutate provider fields, or instantiate
a replacement provider to switch appearance. Preserve the selected ThemeMode
when changing only family and preserve family when changing only brightness.

Keep `app_theme_preferences.dart`'s `theme_family` key and existing mode key.
No database schema migration is needed for a new string family code. Verify
existing fallback behavior for unavailable/unknown stored values rather than
inventing new persistence behavior. Rapid toggling and restart tests must cover
the actual queued writes, not only in-memory selection.

### 7.3 Complete Extension Registration (N3)

The new definition must explicitly register each of these current types:

| Type | New-family decision required |
| --- | --- |
| AppSemanticColors | Actions, errors, success and foreground pairings. |
| AppProgressColors | Readable heatmap/progress roles, preserving meaning. |
| AppTutorialTokens | Overlay structure, anchors, text and controls. |
| AppMediaTokens | Viewer controls, frames and no-effects presentation. |
| AppShapeTokens | All relevant semantic radii, not merely `card` and `control`. |
| AppSurfaceTokens | Backgrounds, outlines, selected states and feature surfaces. |
| AppMotionTokens | Short feedback and reduced-motion recipe. |
| AppEffectTokens | Zero-blur depth, elevations and no-effects fallbacks. |
| AppDataVisualizationTokens | Series, grids, labels and tooltips. |
| AppFlowTokens | Flow-diagram semantic visuals. |
| AppGenerationTokens | Generation choices, summaries and status surfaces. |
| AppNutritionTokens | Food-flow presentation and metadata. |

`theme_extensions.dart` silently supplies fallbacks when extensions are absent.
Those fallbacks protect legacy contexts; they do NOT establish complete new
theme coverage. Test `theme.extension<T>() != null` directly for each required
type in both modes. If an existing recipe is intentionally reused, instantiate
it explicitly and document why; do not rely on an accidental fallback.

Audit every color/gradient field in these extensions. A copied Classic recipe
may retain purple, gradients or blur. Mark retained domain colors intentionally;
replace decorative Classic values with the chosen recipe. Do not globally
replace every color literal or flatten chart distinctions.

## 8. Shared Surface Specification (N2)

### 8.1 What Exists And What Must Change

`TonosSurface.build` currently sets `defaultOutlined = false` for all variants
except input, and gives only compactCard an explicit BoxShadow. Card uses
Material elevation. This means changing outlineWidth alone cannot add outlines.

Introduce a small semantic per-variant decoration policy. Proposed location:
`lib/theme/tokens/app_surface_decoration_tokens.dart`, with proposed extension
`AppSurfaceDecorationTokens`. Keep color ownership in AppSurfaceTokens and
geometry in AppShapeTokens; this policy only decides whether/how depth and
outlines are used. Before creating it, confirm no existing equivalent has been
added since this plan. Reuse an equivalent rather than duplicate it.

The policy must express outline visibility and depth choice (none, Material
elevation, or explicit shadow) per semantic surface. Keep its key enum in the
token layer, not imported from the widget layer. Explicitly map each widget
variant to its policy entry. Do not key the map with free-form strings.

| Variant | Exact Classic preservation | Proposed Neo policy |
| --- | --- | --- |
| panel | No outline, no depth | Outline, no depth |
| panelRaised | No outline, no depth | Outline, hard shadow |
| card | No outline, existing cardElevation | Outline, hard shadow, zero elevation |
| compactCard | No outline, existing explicit card shadow | Outline, hard shadow |
| input | Outline, no depth | Outline, no depth |
| media | No outline, antialias clip, no depth | Outline, antialias clip, no depth |
| mediaPlaceholder | No outline, antialias clip, no depth | Outline, antialias clip, no depth |

The Classic policy must preserve existing effect-token overrides, not freeze
today's numeric values into a duplicate token. Resolve shadow/elevation from
AppEffectTokens after selecting the policy. Preserve `outlined` override
precedence: explicit false still disables the variant default. Audit callers
using false to establish whether that exception is intentional.

### 8.2 Rendering Rules

Keep a Material ancestor and the existing InkWell path. Paint the hard shadow
outside the clipped content, as compactCard already does. Never replace the
button surface with only GestureDetector and Container. Preserve semanticLabel,
padding, margin, onTap and clipBehavior API behavior.

Never paint both Material elevation and explicit hard shadow for Neo. Effects
off must suppress the explicit shadow, not its border. Shadow transparency or
policy suppression must work through Theme Lab's effects transformation too.
Do not add automatic external padding to every instance: find actual clipped
parents and reserve space there without changing Classic's layout.

Add extension accessors to ThemeData and BuildContext with a Classic-compatible
fallback. Register the extension in both families. Implement copyWith and lerp;
test t=0, 0.5, 1 and null/other handling consistent with existing extensions.
For enum/bool policies, document the discrete midpoint switch. Do not mutate
maps or lists shared by cached themes.

## 9. Actions, Fields And Material Ownership

### Actions

Inspect `tonos_action.dart`, `workout_actions.dart` and
`tonos_segmented_action_bar.dart` independently. The generic action already
wraps Material buttons and owns destructive styling. Preserve callbacks,
long-press, focus, hover, tooltip, semantics, expansion and disabled behavior.

Set ordinary button foreground/background/border/shape through the new family's
Material component themes. An elevation value does not create a crisp offset
shadow. If a hard shadow requires a shared decoration wrapper, add it only at
the reusable action boundary and make its Classic default a no-op. Do not wrap
both the base and feature button and accidentally draw two shadows.

Pressed displacement is optional and comes after a correct static recipe. If
implemented, track press through supported button state APIs for the installed
SDK. Dispose owned controllers and handle pointer cancellation, keyboard
activation, focus loss and disabled transitions. Do not implement a second
tap handler that can invoke the callback twice.

### Fields And Dropdowns

`tonos_field.dart` builds InputDecoration and accepts caller-owned controllers
and focus nodes. Retain them across family changes. Set enabled/focused/error/
disabled borders explicitly in the family input theme, with consistent radius.
Do not introduce fixed field heights. A focus border must not change content
position or clip helper/error text. Keep multiline input and large-text paths.

Audit direct dropdowns separately; InputDecorationTheme alone does not guarantee
popup item readability or expansion. Preserve the large-text fixes already in
User Information. Verify selected values, menu contents and hint text in both
modes. Do not replace form widgets merely for a different visual style.

### Material Components

In the new definition, explicitly decide recipes for cards, filled/elevated/
outlined/text buttons, FAB, inputs, app bars, bottom navigation, tabs, dialogs,
bottom sheets, popup menus, snackbars, checkboxes, radios, switches, dividers,
tooltips and progress indicators actually used by the app. An unused component
does not require new abstraction work; document it as unused.

Use APIs available in the installed SDK. Keep the existing Classic builder in
`app_material_theme.dart` intact. For Neo, disable unwanted tonal/elevation tint
where it would alter solid surfaces. Use zero conventional elevation where a
custom hard shadow is used. Keep on-colors appropriate for accent-filled areas.

`tonos_sheet.dart` owns its Material shape/elevation: inspect it alongside
BottomSheetTheme, not instead of it. Use one border, preserve close semantics,
handle, insets and Navigator behavior. Do not reopen the already-fixed root
Theme Lab Close behavior by introducing a new nested navigator.

## 10. Theme Lab And Pilot Instructions

Theme Lab already has `_family`, a family dropdown, factory lookup and an
effects transformation. Extend those paths; do not create a parallel gallery.
Update `_familyLabel` and add any new extension to the effects-off processing
only if it contains decoration that needs suppression. Preserve outlines.

For each pilot collect the same state in light and dark:

1. Train: one active plan, weekly overview and bottom actions visible.
2. Workout: one checked and one unchecked set, weights/reps and add/finish
   actions visible; use disposable data and retain it during switching.
3. User Information: normal fields, then a focused field and an open dropdown.
4. Weight Units: open dialog with selected and unselected options visible.

The primary eight views are one representative state per pilot per brightness.
Supplement them with focused/error/disabled states rather than pretending eight
screenshots prove every interaction. Record app revision, device, logical size,
font scale, brightness, family and effects setting for each capture.

For stress testing use 2.0 text scale, long labels, keyboard shown, and narrow
width. Check layout through interaction, not screenshots alone. Re-run the
same pilot in Classic after shared changes. Acceptance means no new clipping,
overflow, unreadable labels, lost values or unreachable controls.

## 11. Test Map And Required Assertions

| Existing test or proposed new test | Assertions to add or preserve |
| --- | --- |
| app_theme_family_test.dart | Stable code round-trip, both modes, unknown remains unknown. |
| app_theme_capabilities_test.dart | Neo allowed only in eligible non-release configuration; release blocks it even with flag true. |
| app_theme_preferences_test.dart | Existing stored Classic/mode intact, Neo round-trip, unavailable fallback. |
| Proposed neo_brutalism_theme_test.dart | Complete extensions, correct brightness, cached factory results, explicit intended palette. |
| app_theme_tokens_test.dart | New token copyWith/lerp endpoints, fallbacks and immutable defaults. |
| widgets/tonos_surface_test.dart | Every variant's Classic defaults unchanged; Neo border/depth, overrides, clipping and tap semantics. |
| widgets/tonos_action_test.dart | Once-only callback, disabled no callback, keyboard/focus and optional cancel recovery. |
| widgets/tonos_field_test.dart | Text/focus preserved across theme rebuild, validation and 2.0 layout. |
| widgets/tonos_sheet_test.dart | Insets, close/dismiss behavior, one border and effects-off. |
| theme_lab_page_test.dart | Picker finds Neo when allowed; preview does not persist; root Close still works. |
| q2_runtime_accessibility_test.dart | Both families where relevant, local overlay inheritance and switching state. |

Keep existing Classic baseline and parity assertions. Add separate Neo
expectations instead of changing expected Classic colors to the new palette.
Use deterministic fake data, no camera/network requirement, and tear down
controllers and preferences. A source-string contract can guard enrollment;
it cannot prove a rendered border, overflow absence or usable focus state.

Test no-effects with nonzero hard shadows first, then disable effects and
assert their removal while borders and selections remain. For motion, exercise
disableAnimations separately from effects; the two are not interchangeable.

## 12. Batch Handoff And Verification Commands

Before each implementation batch inspect the working diff. Record existing
user changes and avoid formatting unrelated files. Do not commit automatically.
At handoff supply an exact changed-file format/analyze command and targeted
tests, followed by broader theme tests when shared behavior changed.

The following broad commands refer to existing paths and are for the USER to
run after implementation, not required for this documentation-only update:

```powershell
Set-Location E:\projects\env_test
dart analyze lib\main.dart lib\theme lib\providers\theme_provider.dart test\theme
flutter test test\theme test\providers\app_configuration_test.dart
git diff --check
```

Expand the analyzer list for changed feature files. Only include newly proposed
test filenames once created. Inspect `tools/theme_style_ratchet.dart` usage and
the existing CI invocation before supplying its command; do not guess flags or
rewrite its baseline. Record actual verification, never projected test counts.

If a failure occurs, isolate the failing case and fix the implementation or a
demonstrably obsolete test. Do not weaken assertions just to get a green run.
Document manual checks separately from automated checks and release approval.

## 13. Completion Checklist And Boundaries

- N1: exact missing-role inventory and visual/font decisions recorded.
- N2: new capabilities render correctly; Classic defaults and tests preserved.
- N3: both definitions complete, picker works, release policy intact, current
  previews accepted.
- N4: current real-route visual refinements accepted; revalidate only affected
  shared presentations after later edits.
- N5: the current 21-item visual review is accepted; every in-scope reachable
  route still needs a recorded state/reachability disposition and evidence.
- N6: targeted verification and visual acceptance are recorded; outstanding
  device, accessibility, lifecycle, performance, and release work is explicit.

Stop expansion and fix the shared layer if Classic changes unexpectedly,
family switching loses state, release gating fails, or important text becomes
unreadable. A disagreement about accent hue can wait for the preview checkpoint;
a data-loss or accessibility regression cannot.

Do not change repositories, plan activation, database schema, workout calculations
or route semantics as part of visual implementation. If a real unrelated defect
is discovered, record it separately and explain its scope before combining it.
Do not add Glass/Expressive-specific machinery speculatively: only generalize a
capability needed by the current recipe, with a clear Classic default.

## N4 Coordinated Refinement Record

The current Neo implementation now follows an explicit surface-policy pass:

- Colored surfaces resolve dark ink from their semantic role, while neutral
  charcoal surfaces retain warm-paper text. Arbitrary or translucent surfaces
  use contrast against their composited parent rather than a luminance cutoff.
- Neutral surfaces use a restrained warm-gray outline role; bright yellow,
  pink, cyan, lavender and orange panels retain the structural dark outline.
  The same policy is used by TonosSurface, TonosSheet, completion surfaces,
  plan metrics and debug controls.
- Primary button depth is painted by the shared Material outline, not the
  padded touch target. Save, Finish and Done share that implementation. The
  continuous split Start/Optimize bar retains its single container-sized
  shadow, using the same black `(4,4)` effects role. Disabled and busy buttons
  have no raised depth; the split bar stays raised while Start remains enabled.
- Completion loading, error, success and Theme Lab fixture states share the
  bounded completion shell. The result-card widget is shared between the real
  completion route and the deterministic Theme Lab fixture, including long
  values, set separators and record badges.
- The completion summary header, responsive metric grid, legend, result-card
  list and Done action are also owned by `WorkoutCompletionPresentation`. The
  production sheet supplies hydrated data and its draggable controller, while
  Theme Lab supplies fixture data; neither caller rebuilds the success layout.
- Completion metrics and set rows choose columns and stacking from available
  width and effective text scale, not language. The footer reserves its actual
  layout height outside the scroll viewport rather than estimating bottom
  padding. Panels use the standard outer stroke with thin internal separators.
- The debug theme controls float below the system status area without changing
  the app's layout. Their 48px keyboard-focusable targets and hard shadows are
  development-only and remain outside release builds.
- Anatomy heatmaps receive an explicit inactive color for bright Neo panels,
  while neutral canvases retain their darker-context palette. SVG fills are
  forced opaque before RGB conversion because alpha is not part of the renderer
  contract.

The debug controls float below the status area when `TONOS_THEME_SWITCH` is
enabled. This development-only overlay must not reserve vertical space or move
the real app content.
