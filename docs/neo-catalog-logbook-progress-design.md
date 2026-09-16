# Neo-Brutalism: Catalog, Logbook, And Progress

Detailed design specification and current-batch implementation record,
2026-09-15. The consolidated roadmap remains the acceptance source.

This specification expands the remaining-screen work under Step 12 and
Step 13/N5 of the [consolidated roadmap](theme-consolidated-roadmap.md).
That roadmap remains the source of completion status. The implementation
sequence here is guidance, not a separate backlog.

## Current Implementation Status

The first-pass Neo treatment described here is implemented for the Catalog,
Logbook, and Progress surfaces and their shared exercise-detail destination.
The user has reviewed the current batch and considers it finished for now.
This closes the visual implementation pass for these screens, not the full
reachable-route ledger, large-text/accessibility matrix, or release
qualification.

The completed refinements include:

- Catalog and Logbook structural panels, colored surface roles, summaries, and
  existing navigation/data behavior.
- Compact Progress Workout Report metric tiles, range selector, and two-column
  Additional Details treatment at normal phone widths, with content-driven
  reflow retained for narrow or large-text layouts.
- Readable Neo Health Trends cards instead of the previous dark placeholder
  rendering, while preserving measurement definitions, units, entry flows,
  and empty states.
- Classic Workout Report insight boxes restored to same-line value/unit
  presentation where appropriate, including the `lbs` Best Volume wording.
- One modal owner for the Neo exercise-detail sheet handle. The outer modal
  route no longer adds a second Neo drag handle or competing frame; the
  existing detail-sheet drag behavior remains the owner.

The Logbook calendar/date-range surface keeps its earlier neutral/off-white
appearance. A pale-yellow recolor was tried and then intentionally reverted
after visual review; do not treat that experiment as the final requirement.

The latest user-supplied exercise-detail verification reported clean analysis
and four passing contract tests. Individual earlier screen fixes have their
own scoped results in the consolidated roadmap; these results are not a new
whole-application qualification run.

## 1. Non-Negotiable Design Contract

Extend the accepted Train, Profile, exercise editing, workout session, and
completion-sheet design. Do not introduce a new interpretation of Neo for each
tab. Use flat colored panels, firm dark outlines, compact hard shadows, and
the existing typography. Light mode stays warm rather than sterile white;
dark mode retains charcoal framing and bright, readable colored surfaces.

Preserve Classic's accepted presentation. Preserve both themes' information
order, queries, sorting, units, filters, navigation, selection, editing,
refresh, validation, and persistence. Do not add decorative page heroes,
new tabs, redundant explanatory copy, or extra navigation during this pass.
Neo should remain parallel to Classic, not become a different application.

Do not change global CardTheme or the generic card token merely to recolor
these screens. Do not alter Classic's compact metric geometry or accepted
normal-scale layouts. A necessary shared accessibility fix must be identified
and justified separately; it is not permission to redesign Classic.

Neutral chart backgrounds are intentional. The goal is to color structural
panels, not every pixel. White plots in light mode and charcoal plots in dark
mode support readability. Likewise, preserve meaningful circles such as date
cells and familiar anatomy illustrations; Neo does not require every shape
to become a square. Avoid glows, glass effects, new gradients, blurred Neo
shadows, oversized typography, and arbitrary colors for individual exercises.

## 2. Palette And Foreground Boundaries

The following values already exist in `lib/theme/neo_brutalism_theme.dart`.
Use semantic tokens in widgets, not scattered hexadecimal literals.

| Role | Light | Dark | Use |
| --- | --- | --- | --- |
| Canvas | #FFF8E7 | #171717 | Space surrounding panels |
| Neutral surface | #FFFFFF | #272727 | Plot wells and quiet inner cards |
| Secondary neutral | #F1E9D7 | #333333 | Muted structural surfaces |
| Yellow | #FFE34D | #FFEA61 | Main actions, report shell, selected controls |
| Lavender | #C4A1FF | #D2A8FF | Catalog, Logbook, Exercise Progress shells |
| Cyan | #64DDE0 | #55F0EA | Catalog previews, health cards, period summary |
| Pink | #FF92BF | #FF6BAE | Selected exercise progress hero |
| Orange | #FFB36B | #FF8A3D | Reserved accent, not a generic warning |
| Pale yellow | #FFF0A6 | #FFE875 | Quiet statistics and selector rails |
| Exercise peach | #FFD2A3 | #FFC184 | Existing exercise surface, preserve |
| Completed exercise | #96B967 | #A6D466 | Existing completion state, preserve |
| Completed set | #B9D994 | #C5EC91 | Existing completion state, preserve |
| Colored-surface ink | #161616 | #161616 | Text, icons, and bright-surface outlines |
| Error | #B3261E | #FF8A80 | Actual errors/destructive status |

Neutral dark surfaces use cream foreground #FFF8E7 and the existing outline
role #81776B. Colored surfaces use dark ink in BOTH modes. Secondary text on
bright backgrounds uses the established #38312B, not translucent white.
Do not repeat the earlier white Set-label regression when nesting surfaces.

At every background boundary, resolve text, icon, outline, and secondary text
against the actual painted background. Use `tonosForegroundForSurface`,
`tonosSecondaryForegroundForSurface`, and `tonosOutlineForSurface` as
appropriate. A cyan row inside lavender must resolve against cyan; a neutral
plot inside pink must resolve against the plot, not the pink parent.

Target at least 4.5:1 for normal text and 3:1 for meaningful chart marks and
graphical boundaries. Verify actual color pairs. Saturated colors can still
have poor contrast. Existing light chart candidates include purple #64408F
and cyan #006A72; dark charts use their bright counterparts. Use the existing
surface-aware data resolver rather than one fixed cyan on every background.

Reserve green for genuine completion or existing positive semantics. An
increase in a health measurement is not automatically good. Do not make
every report insight green merely because it contains a number.

## 3. Structure, Depth, Density, And Typography

Use 2-logical-pixel solid outside borders. Internal separators should normally
be 1 pixel or the existing subdued divider role, not competing heavy frames.
Focus uses the existing 3-pixel treatment with disabled-first resolution and
without changing layout dimensions. Bright-surface borders use dark ink;
neutral dark surfaces use their surface-aware outline rather than compulsory
pure-white frames.

| Element | Shadow offset | Blur/spread | Treatment |
| --- | --- | --- | --- |
| Major standalone panel | (4,4) | 0/0 | Existing raised-panel recipe |
| Ordinary item card | (3,3) | 0/0 | Modest depth, avoid unnecessary nesting |
| Completed set row | (2,2) | 0/0 | Existing pilot recipe, unchanged |
| Embedded stat or plot well | None | None | Fill and border provide hierarchy |
| Calendar day | None | None | No floating grid of date buttons |
| Segment inside selector rail | None | None | Selection uses fill/border |

Shadow color remains #161616 in light mode and black in dark mode. Do not
introduce neon offsets only on these screens. Reserve bottom/right paint
space so shadows remain visible; inspect scroll clips and last-card padding.
Never enlarge a shadow to compensate for clipping or add a second shadow
because the parent wrapper already supplies one.

Retain existing corner tokens: compact details approximately 4, cards 8,
sheets 12. Use `TonosSurface` and existing recipes, checking actual decoration
rather than assuming a variant name implies flat or raised treatment.
Major panels should use the existing raised-panel depth; embedded plots and
statistics should explicitly be flat.

Keep current gutters: generally 16, while Progress's existing card-owned
12-pixel margins remain authoritative. Do not double-pad the screen. Keep
panel padding approximately 14-18, inner cards 10-12, compact row vertical
padding 8-11, section gaps 16, internal groups 10-12, and row gaps around 8.
These are targets, not instructions to replace already-correct spacing.

Use the current TextTheme and font family. Section headings retain the
accepted 800/900 weight. Exercise names and primary values are strong;
metadata remains readable body text. Do not uppercase everything, introduce
a monospace body font, or add an icon to every metadata line.

At normal scale retain familiar compact arrangements. Reflow when actual
content needs it, especially at 200% text and long translations. Avoid fixed
heights that hide labels. Preserve Classic's accepted compact fitted metric
branch, rather than changing it while improving Neo.

## 4. Catalog

### Landing composition

Keep Exercise Catalog followed by Target Anatomy, with existing refresh,
loading, cached data, retry, list padding, and navigation. No new hero.
The first panel is lavender, the second yellow, both with 2-pixel outlines
and (4,4) hard shadows. This matches Train's panel language without copying
its colors indiscriminately.

### Exercise Catalog panel

Use lavender #C4A1FF / #D2A8FF for the shell. Keep the current left-aligned
icon/title header and Most used exercises subtitle. Give the icon a yellow
backing with dark ink, not a transparent muddy lavender backing. Keep padding
around 18, approximately 16 before the subtitle and 10 before its rows.

Most-used rows use cyan #64DDE0 / #55F0EA, 2-pixel ink outlines, compact
corners, and at most (3,3) item shadows. Keep around 8 between rows, allowing
shadow paint space. Retain names/metadata left and the approximately 52-pixel
thumbnail right. The image uses a neutral light media backing; do not tint or
invert exercise illustrations for dark mode.

Use localized exercise names, equipment, and usage wording. For Neo, prefer
allowing a second name line when necessary rather than shrinking the row's
text. Preserve useful metadata and prevent text painting under the thumbnail.
Where overview summarization remains intentional, retain full accessible
labels and access to the complete library. Do not impose a broad text-layout
change on Classic during this visual pass.

Important: `_ExerciseUsageBar` currently has no independent navigation
callback. Its rows belong to the parent catalog preview. Do not add fake
chevrons, nested button semantics, or new exercise-detail taps during styling.
Preserve the current whole-card navigation behavior.

### Target Anatomy panel

Use yellow #FFE34D / #FFEA61 with dark title, names, and set counts. Use a
small lavender backing for the header icon to relate the two panels. Do not
leave yellow counts on yellow. Default to plain bold ink counts rather than
creating a new badge for every number.

Keep Bodyparts and Muscles side by side at ordinary width, including their
existing rankings, units, and independent navigation. Preserve approximately
12 on either side of the center divider. Do not turn each ranked row into a
separately raised card. At large text/narrow pane widths, stack the same two
panes with a horizontal separator; evaluate actual allocated pane width.
Keep separate hit regions, localized names, and meaningful headings.

### Empty states and destinations

Empty previews retain their colored shell and honest localized empty copy.
Loading and retry use readable ink or existing state roles. Error content can
sit on a neutral inset surface; the entire screen need not turn red.

The full library preserves search, filters, sorting, selection mode, and
current result navigation. Continue cyan results and yellow primary actions,
with restrained lavender/pale-yellow control groups. Inputs remain neutral
and floating labels must have correctly interrupted outlines. Selected
filters need state indication beyond color. Bodypart and muscle destinations
retain their existing information and actions.

### Implementation owners

Start in `lib/screens/catalog_page.dart`: `_ExerciseCatalogCard`,
`_ExerciseUsageBar`, `_TargetAnatomyCard`, `_FocusSummaryPane`, and
`_FocusUsageRow`. Any helper resolving foreground against `surfaces.card`
must instead account for its actual new colored background.

`catalogUsage` is a focused candidate for cyan previews after checking all
consumers. Add dedicated shell roles only if existing roles cannot express
the design safely. Audit `lib/screens/exercise/exercise_catalog_page.dart`
separately for destination styling. Leave Classic's Card/InkWell branch and
all callbacks unchanged.

## 5. Logbook

### Landing composition

The active route is `lib/screens/exercise/history_screen.dart`, using
`WorkoutHistoryCalendar`. Do not mistake `combined_history_page.dart` and
its placeholder for the active screen. Keep the current mode selector,
period heading/navigation, calendar, anatomy/metrics, and selected-period
summary in their existing order.

Use a lavender raised outer panel, 2-pixel outline, and (4,4) shadow. Retain
its existing margin and approximately 14-pixel internal rhythm. The calendar
grid occupies a neutral inset surface. Color frames the information rather
than turning every date into a neon sticker.

The final reviewed calendar/date-range surface remains the prior neutral
off-white treatment. Keep the mode selector's existing state language, but do
not recolor the calendar body to pale yellow merely because pale yellow is used
elsewhere for compact controls.

### Mode selector and header

The M / 3M / Y / 4Y rail uses pale yellow #FFF0A6 / #FFE875. Its active
segment uses full yellow, dark text, and a firm selected boundary. Inactive
labels remain dark, not white on pale yellow. Use compact corners and a
2-pixel rail outline; no individual segment shadows.

Preserve mode semantics: month selects a day, three-month view a week, year
view a month, and four-year view a year. Retain current date/range selection,
period navigation, session refresh, and localized formatting. A styling pass
must not make every mode behave as a day picker.

Keep the period title centered between arrows with its current strong weight.
Arrows use dark ink on lavender and retain practical touch targets. Long
localized period names may wrap or trigger a measured header arrangement;
they must not overlap arrows or disappear under them. Changing mode should
not reset selection beyond existing behavior.

### Calendar day and period states

Keep the seven-column month grid and recognizable circles. Ordinary empty
dates use secondary neutral fill with its appropriate foreground. Outside-
month dates use deliberate subdued text rather than near-invisible opacity;
preserve their existing availability and navigation behavior.

Workout activity uses cyan-family flat fills. If the current continuous
opacity treatment is replaced for Neo, use a small deterministic opaque ramp
while preserving its underlying count/intensity meaning. Proposed LOW
activity candidates are #C8EFED in light and #A8E5DC in dark. These two values
are NEW proposals, not existing approved tokens; verify contrast and token
ownership before adopting them. HIGH activity uses existing cyan #64DDE0 /
#55F0EA. Do not invent workout thresholds or discard current count badges.

Selected dates are yellow with dark ink and a firm dark boundary; selected
state takes precedence over activity fill. Today retains a separate visible
indicator, so today and another selected date remain distinguishable. Keep
multi-workout badges readable and inside available paint space. Full localized
date semantics must retain selected status and available workout information.

No date-cell shadows: dozens of offsets create visual noise and distort the
grid's hierarchy. Other period views use the same selected/activity language,
not a new palette for each mode. Maintain adequate gaps without changing the
number of date columns.

Seven 48-pixel targets do not fit into a 280-pixel inner calendar. Do not
overlap hit regions or claim target-size compliance by measuring an invisible
larger widget. Preserve usable nonoverlapping cells, test actual geometry,
keyboard and screen-reader access, and explicitly document any necessary
calendar target-size exception. Do not silently replace the month with a list.

### Anatomy and metrics

At ordinary widths, keep the anatomy diagram on the left and Workouts / Total
time / Total volume on the right. Do not unconditionally stack them or
enlarge the diagram. Reflow only when allocated widths and text require it.
Preserve existing heatmap colors/data semantics and selection linkage.

The three summary boxes use pale yellow, dark values and labels, compact
corners, and 2-pixel outlines without individual shadows. Values are visually
stronger than their labels. Maintain compact gaps. Zero remains readable
data, not a disabled state; do not dim it or turn it into a success badge.

### Selected-period summary

Use cyan for the selected-period summary block, dark bold date/title, and
dark secondary supporting text. Preserve the View All/expand action, current
position, and callback. Give it visible keyboard focus without a large
decorative container.

Session entries remain compact rows separated by restrained lines, not
individually raised cards inside another raised card. Retain duration,
exercise count, sets, volume, and existing navigation. At normal scale,
metadata should not unnecessarily occupy four lines; when space genuinely
requires wrapping, preserve all units and keep the trailing action reachable.

Empty periods retain the selected date and localized empty message inside
the same cyan block. Do not introduce a Start Workout action or fake history.
The panel should feel complete without inventing content.

### Implementation owners

Work in `lib/widgets/workout_history_calendar.dart`, including
`_CalendarModeTabs`, `_CalendarDayButton`, `_PeriodCircleButton`,
`_WorkoutCountBadge`, `_CalendarMetricCard`, and `_SelectedPeriodSummary`.
Existing mode-selector, empty-date, selected-period, and divider roles are
starting points, but audit their consumers before changing values.

Keep the proposed solid activity ramp Neo-only. Preserve Classic's accepted
circle opacity/intensity styling. Audit `history_summary_widget.dart` only
where reachable; its existence is not reason to add it to Logbook. No query,
aggregation, or period-selection changes are needed for this visual design.

## 6. Progress

### Landing composition

`lib/screens/measurement_trends_page.dart` owns the current ordering:
Workout Report, Exercise Progress, then Health Trends. Keep that order,
refresh behavior, and card-owned margins. These widgets have other consumers,
so audit them before altering shared surface roles. Add neither a Progress
hero nor another tab selector.

Use a yellow Workout Report shell, a lavender Exercise Progress shell, and
cyan individual Health Trends cards. These colors identify sections, not
individual records. Keep all substantial plot wells neutral so comparable
data retains consistent chart colors and good contrast.

### Workout Report shell and metric boxes

Use yellow #FFE34D / #FFEA61, 2-pixel ink border, (4,4) shadow, current card
corners, and approximately the existing 16-pixel padding. Retain the centered
title and current metric selector relationship to the chart.

Workouts, Time, and Volume remain three aligned side-by-side boxes at ordinary
phone widths and text scale. Use pale yellow for unselected boxes, lavender
for the selected box, dark ink throughout, 2-pixel boundaries, and no separate
shadows. The values are strongest, units stay attached, and comparison text
remains secondary. Selection should look deliberate, not like a taller card.

Do not let Time alone become taller at normal scale. Use measured compact
layout/fitting consistent with the accepted presentation, without hiding
units. At large accessibility text, permit fewer columns when necessary
rather than shrinking away the user's requested scale. Reflow should depend
on actual localized content, not only a single width threshold.

Classic's recently restored metric geometry and `_classicContent` branch
must remain unchanged. Decoration work must not alter formatting, comparison
calculations, current selection, or the chart page controller.

Implementation note: the Neo metric row, range selector, and expanded insight
grid now follow this compact normal-phone geometry. Classic keeps its restored
same-line value/unit layout and the existing report calculations.

### Workout Report chart

Retain the existing footprint, approximately the current 220-pixel slot at
normal scale. Use a neutral white / #272727 plot well, restrained boundary,
and no raised shadow. Resolve chart title, axis labels, grid, data line,
points, and tooltip against this actual surface.

Keep current range aggregation, y-axis behavior, units, dates, and precision.
Grid lines remain subordinate and can retain their current dashed treatment;
do not make every grid line a heavy black structural border. Use the current
surface-aware primary purple. Any real secondary series needs a distinct
supported color/style and meaningful legend, not a nearly identical hue.

Tooltips use neutral contrasting surfaces, firm outlines, and readable values.
If a small hard popup shadow is used, test its clipping at chart edges.
No neon line glow or new multi-stop area gradients. Existing restrained fills
may remain where appropriate, but must not dominate the chart. Empty and
single-point states remain meaningful and accessible.

### Time ranges and Additional Details

Retain 1W / 1M / 3M / 6M / 1Y / All and their current callbacks. Use a
pale-yellow rail, lavender selected segment, dark labels, compact corners,
and visible focus. Do not give each segment an offset shadow. All ranges
remain reachable at narrow widths and large text without cropped labels.

Additional Details uses lavender, dark text, a 2-pixel outline, and the
existing expand/collapse icon aligned to the trailing edge. Its closed state
must not look disabled. Keep the current disclosure behavior and information.

Expanded insights use neutral inset surfaces with compact padding, appropriate
2-pixel outlines, and no shadows. Do not use green for every insight. Preserve
full labels, values, details, and units through content-sized wrapping. A
content-sized Wrap does not solve readability if its children still ellipsize
all values to one line. Align each run cleanly and allow it to grow.

### Exercise Progress shell and hero

Use lavender shell, 2-pixel border, and (4,4) shadow. Retain centered section
title, selected-exercise hero, alternative selector strip, and edit/add
actions. Do not repeat the title in another decorative banner.

The selected hero uses pink #FF92BF / #FF6BAE with dark title/chevron and a
flat inner boundary, not another 4-pixel shadow. The plot itself is neutral
so its data colors do not depend on marginal contrast over pink. Statistic
boxes use pale yellow, dark ink, and no shadows. Full labels such as 1 Rep Max
must remain readable.

Preserve the current responsive chart/statistics relationship. Decide whether
side-by-side fits from the width actually allocated to statistics and their
content. Do not restore fixed `heroHeight` or scale-multiplied selector height.
When stacked, preserve order and let content determine height. Keep large
localized values within their cards. Missing records remain honest missing
states, not synthetic zeroes.

### Exercise selectors and editing

Alternative exercise cards use cyan, 2-pixel ink borders, and at most (3,3)
shadows. Keep horizontal scrolling and the current exclusion of the selected
exercise from the alternative strip. Allow complete names and relevant
localized values to remain readable by growing content height as needed.

Reserve bottom/right shadow paint space inside the horizontal viewport.
Do not add excessive vertical padding to hide clipping, and do not reinstate
a fixed-height strip that only fits English at normal scale.

Edit and Add use yellow with the existing shared action treatment. Preserve
edit-mode behavior. Remove remains an independent 48-by-48 action with a
localized label identifying the exercise and removal from Progress. Its tap
and Enter/Space action must not select the parent card. Red can identify the
destructive action, but must not recolor the entire exercise card.

### Exercise detail destinations

Keep timeframe controls, records, metric lists, charts, and tooltips. Use
lavender control groups, pale-yellow summaries, and neutral plot wells.
Maintain distinctions between actual values, estimates, missing data, and
user input. Do not relabel an estimated maximum as a measured maximum.
Use consistent chart/tooltip recipes rather than destination-specific styles.

The shared Neo detail destination now presents one visible top section and one
interactive drag handle. The global modal handle is disabled for this route so
it cannot stack above the detail sheet's own handle. Classic continues to use
its normal modal defaults.

### Health Trends

Health Trends is part of the current route and must not be omitted. Preserve
definition ordering, latest values, units, entry flows, sparklines, detail
pages, validation, and editing/removal behavior.

Use cyan individual cards with 2-pixel ink outlines and (3,3) shadows. Do not
invent an enclosing colored panel if the current section does not have one.
Keep measurement name, latest value, unit, date, and graph in the existing
hierarchy. Use dark text on cyan and neutral graph wells where necessary.

Add is yellow. Detail summaries may use pale yellow; larger plots are neutral;
entry lists remain compact. Definition and measurement dialogs use existing
Neo dialog/input recipes with readable floating labels. No new health
interpretation, unit conversion, decimal behavior, or validation is implied.
Never automatically equate rising measurements with success.

Implementation note: the Neo cards now render their intended names, empty
states, entry affordance, and trend placeholder/content treatment instead of
the previous dark blocks. This was a visual repair only; measurement data and
interaction ownership remain unchanged.

### Implementation owners

In `lib/widgets/workout_metric_chart_card.dart`, review `workoutMetricStat`,
`workoutMetricChart`, `workoutMetricRange`, `workoutMetricDetails`, and
`workoutMetricInsight` consumers. Selected metric styling may need an explicit
state treatment, not a global stat-color replacement.

In `lib/widgets/exercise_progress_section.dart`, start with the focused
`exerciseProgressHero`, `exerciseProgressStat`, and
`exerciseProgressSelector` roles. Do not accidentally recolor tooltips or
Classic through a broad shared token change.

In `lib/widgets/health_trends_section.dart`, audit each text/sparkline's actual
background. Keep decoration separate from data access. New shell roles should
be narrowly scoped and receive safe Classic defaults if the extension needs
them. Do not reuse a completion-state role simply to obtain green.

## 7. Interaction And Responsive Requirements

Decorative layers must not cover hit targets. Existing raised actions use the
Neo mechanical pressed treatment: reduce offset while retaining readable
text, rather than scaling the whole control. Passive plots and date cells do
not need that movement. Preserve reduced-motion handling; do not add a new
page-transition system during this pass.

Keyboard focus must be visible on actual controls. Resolve disabled before
focused so a disabled control cannot acquire an active-looking frame. Keep
focus decoration within reserved space, without shifting nearby content.
Selection should be conveyed by border/state/semantics as well as color.

Check logical widths around 320, 360, 393, and 420, plus a wider layout, at
text scales 1.0, 1.15, and 2.0. Include English and long French translations,
long exercise names, large localized numbers, zero values, and missing data.
The goal is usable content, not merely absence of RenderFlex errors.

Ensure the final row and all hard shadows scroll fully above bottom
navigation. Verify horizontal selector strips independently. Do not place
fixed-height wrappers around content-sized cards or compensate for clipping
with excessive blank padding. Debug palette controls must not force production
app bars down or create reserved black space.

Test actual interactions: parent selector versus remove; report metric and
range changes; calendar mode/date selection; selected-session navigation;
search/filter dialogs; measurement editing; and refresh after a new workout.
Keep current semantics, tooltips, enabled states, and callback boundaries.

## 8. Implementation Sequence

1. Capture matched Classic and current Neo states before editing. Record
   brightness, logical width, text scale, locale, data, selected ranges, and
   expanded sections. Use accepted pilots as the depth/density reference.
2. Audit existing surface-role consumers before changing values. Add narrowly
   scoped roles only where required. Preserve generic card, global CardTheme,
   and completed exercise/set styling. Document any intentional shared change.
3. Implement Catalog's two landing panels and actual foreground boundaries.
   Verify parent navigation, independent anatomy panes, and empty states.
4. Implement Logbook's shell, mode/date states, metrics, and selected-period
   summary. Check all four calendar modes before styling reachable details.
5. Implement Workout Report decoration without changing Classic metric
   geometry. Verify complete insight content and plot/tooltip contrast.
6. Implement Exercise Progress shell, hero, and selectors while preserving
   responsive geometry. Verify independent removal and selection actions.
7. Implement Health Trends and reachable destinations. Preserve definitions,
   entry ordering, unit semantics, validation, and current data behavior.
8. Extend real widget tests for rendered fills, borders, shadow offsets,
   selected/disabled/focused states, complete content, and successful actions.
   Token-only assertions and source-name searches are insufficient evidence.
9. Have the user run focused formatting, analysis, and test commands under
   repository policy. Reuse existing responsive and regression test suites.
   Distinguish unrelated known failures from regressions in this work.
10. Review matched device states in both brightness modes and both families.
    The current first-pass batch is user-accepted for now, but the remaining
    device/accessibility evidence still belongs in the qualification record.
    These three landing pages do not constitute whole-application Neo
    acceptance.

## 9. Detailed Acceptance Checklist

### Catalog

- Lavender shell and cyan previews are consistent in both modes, with dark
  foregrounds on the colored surfaces.
- Yellow anatomy pane shows readable names/counts and retains separate
  Bodyparts/Muscles navigation.
- Thumbnails stay legible, row content does not overlap them, and overview
  rows do not acquire unrequested independent actions.
- Outer and row shadows are visible without colliding with neighboring cards.
- Search, filters, refresh, loading, error, and empty states still work.

### Logbook

- Lavender outer shell surrounds a quiet neutral calendar, with yellow
  selection and distinct cyan activity states.
- Today, selection, outside-month dates, multiple-workout badges, and all four
  modes remain distinguishable without changing data meaning.
- Anatomy and metrics retain the compact ordinary-width arrangement; large
  text reflows without hiding values or navigation.
- Cyan selected-period summary contains complete useful session information
  and the existing detail action.
- Calendar hit regions do not overlap and no claimed target size is based
  on an invisible box that does not actually receive input.

### Progress

- Yellow report, lavender exercise section, pink hero, and cyan health cards
  look related to accepted pilots, not like unrelated color experiments.
- Normal-size report metric boxes align; Classic's restored layout is intact.
- Neutral charts have readable axes, meaningful empty states, unclipped
  tooltips, and verified graphical contrast.
- Insight labels/values and selector names remain complete at larger scales.
- Exercise remove controls stay separate from selection for pointer,
  semantics, and keyboard input.
- Health entry/detail flows retain units, validation, ordering, and semantics.

### Cross-theme preservation

- Classic matched screenshots show no unapproved visual change.
- Major panels share (4,4) depth, ordinary item cards at most (3,3), and
  embedded statistics/date cells do not acquire unnecessary shadows.
- Dark Neo uses dark ink over colored fills and cream over neutral dark fills.
- Screen order, navigation, datasets, formatting, and editing remain unchanged.
- The user has recorded visual acceptance of the current first-pass batch for
  now. This document must not be treated as proof that the full migration,
  route ledger, or release qualification is complete.
