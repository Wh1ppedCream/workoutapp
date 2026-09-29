# Tonos Expressive: Course-Correction Plan

**Status:** research and design recommendation; implementation is not approved by this document
**Prepared:** 2026-09-29
**Scope:** an isolated experimental theme direction, not a change to Classic or Neo

## 1. Executive summary

The three approved Classic interaction improvements are good groundwork: controlled WeightCard expansion, a 48 dp set-completion target without taller rows, and a standard anchored exercise menu. They show that Tonos can gain tactile clarity through small, testable changes. They do not answer how the whole app should look and feel as a coherent Material 3 Expressive experience.

The earlier visual work and interaction work answered different questions. The separate-family boards did not remain convincing as the current app wearing a theme: reconstructed screens drifted from production composition, and color/container treatment read as an imposed concept. The later interaction phase correctly prioritized safety but tested isolated controls inside an otherwise Classic visual system. Its “pause” conclusion applies to the original interaction-candidate list, not to the broader design direction.

**Recommendation:** pursue Expressive as a true, paired light/dark third theme family, provisionally labeled **Expressive**, implemented with material_ui, standard Flutter primitives, and Tonos-owned recipes. Keep it build-gated and unavailable in release builds until the three-screen slice passes visual, accessibility, regression, and Pixel 7 gates. Do not retain or reintroduce the material_3_expressive package.

The first proof should style the current production Train Overview, Active Workout, and Progress experiences as one system. It should change hierarchy, tonal containment, selected states, role-specific geometry, and a few deliberate interactions while retaining Tonos layout, data meanings, and fast workout workflow.

## 2. Why the earlier work stopped short

The first proposal rounds showed a concept more than a faithful theme application. Bespoke static reconstructions and broad palette/container changes made it difficult to judge how the real production widgets would look. In particular, visual treatment sometimes overwhelmed the question of whether current Tonos hierarchy and density had been preserved. That is a reconstruction and scope problem, not evidence that Expressive design is unsuitable.

The next pass tightened layout fidelity and restored the familiar Classic purple system. That improved recognizability, but it intentionally asked the narrower question “how can Classic be refined safely?” A selective Classic modernization cannot demonstrate a new visual language across the app.

The component interaction lab then compared individual package and standard controls in Classic screens. It found that isolated M3E swaps can feel inconsistent when their surrounding surfaces, hierarchy, and motion still follow another system. That result rules against a package-led component swap strategy; it does not rule out a coordinated theme recipe.

The future review should begin with current production widget trees and workflows, then apply one system consistently. Old proposal artwork may inform presentation, but it is not layout authority. The source-backed routes and components in this plan are the layout authority.

## 3. What the three approved changes taught us

These remain accepted Classic behavior and should remain intact:

1. **Controlled exercise expansion:** a short 180 ms standard Flutter reveal can make a real workout card feel more polished while leaving Tonos state ownership and final-set auto-collapse intact. It worked because movement stayed local to the changing content.
2. **Set completion target:** a 48 × 48 dp interactive region can improve touch confidence without enlarging the familiar checkbox or increasing measured row height, including compact and 2× text layouts. Keep green semantic.
3. **Anchored exercise menu:** standard MenuAnchor provides a useful explicit anchor while preserving Tonos action order, confirmation flow, focus, dismissal, and Back behavior. A third-party M3E menu was unnecessary.

Together, these support an Expressive rule: make touch and state response feel more intentional, but do not make repeated logging bigger, slower, or more theatrical. The three changes are safe interaction groundwork, not the visual definition of a new family.

## 4. Official Material 3 Expressive findings

Material 3 Expressive is a coordinated visual and interaction language. Google describes expression through the relationships among color, shape, size, motion, and containment, with hierarchy intended to help people notice the right control or information. Google reports research across 46 studies and more than 18,000 participants; its “up to 4× faster” observation applies to tested research screens and must not be treated as a predicted Tonos result. Google also reports that context and individual preference matter, so Tonos must be judged in its own dense workflows.

Material’s current guidance is evolving: it now describes motion-physics tokens and a wider shape system alongside component updates. These are design-system capabilities and design references, not a mandate to use every shape, morph, toolbar, or spring in Tonos. Android and Compose examples show the direction, but are not evidence that the same behavior is exposed by Flutter’s Material library.

Relevant official sources:

- [Google Design: Material 3 Expressive research](https://design.google/library/expressive-material-design-google-research) — research framing, creative drivers, and study results.
- [Google: Material 3 Expressive on Android and Wear OS](https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/) — product examples and motion/shape direction. Watch-specific layout advice should not be copied to a phone logger.
- [Material Design 3](https://m3.material.io/) — current system and component guidance, including its evolving motion and shape work.
- [Flutter: Material and Cupertino decoupling](https://flutter.dev/blog/decoupling-material-cupertino) — official material_ui availability and Flutter’s statement that broader Expressive implementations are underway.
- [material_ui on pub.dev](https://pub.dev/packages/material_ui) — official Flutter Material package version and changelog.
- [Flutter MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) — system animation preference available to custom widgets.

### Separate the design direction from package capability

The accepted, explicitly pinned workspace toolchain is Flutter 3.47.5 with bundled Dart 3.13.4; those binaries were verified directly. The machine-wide Flutter command may still resolve to Flutter 3.29.3/Dart 3.7.2, so future analysis and tests must continue to use the pinned SDK paths. The lockfile pins material_ui 1.5.0, which requires Flutter >=3.47.0 and Dart >=3.13.0. Local package-source inspection found partial Expressive support: DynamicSchemeVariant.expressive is a seed-color algorithm, and the expressive StyleVariant is an opt-in, under-development IconButton treatment. There is no global Flutter useMaterial3Expressive switch or general official Flutter expressive motion scheme in this version. Full support is still evolving.

Therefore:

- Keep material_ui as the standard Material foundation.
- Use standard Material components where their behavior and geometry fit Tonos.
- Use existing Tonos theme extensions and narrowly owned Flutter behavior for requirements that standard theming cannot express.
- Re-check official package support at implementation time; do not design around a component that is still absent.
- Keep the rejected material_3_expressive package decision separate from the open question of whether Expressive is a useful design direction.

## 5. Current Tonos architecture readiness

The family backbone is real and explicit:

- AppThemeFamily owns stable family codes and supported brightnesses.
- AppThemeSelection separates family from light/dark mode.
- AppThemeFactory returns cached, family-specific light and dark ThemeData.
- AppThemeCapabilities controls which families may be selected and already distinguishes development availability from release availability.
- AppThemeFamily stores the persisted family code, while AppThemeFamilyIdentity and the AppThemeIdentity ThemeExtension record the rendered family. These drive explicit usesClassicPresentation and usesNeoPresentation helpers; the enum and extension must both gain the new identity.
- Theme extensions already own semantic colors, surfaces, surface decoration/effects, shape, motion, progress and chart data colors, nutrition, and other product recipes.

This makes a third family technically feasible, but not a drop-in recipe. In the current dirty working tree, a search across lib Dart files found 174 usesNeoPresentation occurrences in 54 files and 29 usesClassicPresentation occurrences in 11 files. This includes debug/preview code; the figures are identifier occurrences, not widget counts or a rewrite estimate. Many “not Neo” branches currently select Classic-specific or generic Material rendering. An Expressive theme can therefore have a complete ThemeData and still fall through to an incoherent mix of Classic and defaults.

Before expanding production screens, classify affected identity branches by visual or behavioral intent. Generalize only owners that truly have three-family behavior; keep unrelated route-specific decisions local. In particular:

- Check custom surface foreground resolution. TonosSurfaceTheme currently applies a Neo-specific treatment, while foreground helpers fall back to the active ColorScheme outside Neo.
- Complete all 14 non-identity theme extensions intentionally: semantic colors, shapes, surfaces, surface decoration, effects, motion, data visualization, progress, nutrition, flows, generation, settings presentation, media, and tutorials. Do not depend on Classic fallbacks for the new family.
- Review app-theme selection, both identity registries, capability/release gates, UI Appearance labels and localized descriptions, Theme Lab previews, debug controls, and exhaustive family tests. The current release opt-in is Neo-specific; do not reuse TONOS_ENABLE_NEO_RELEASE to expose Expressive.
- Preserve current Classic and Neo builder outputs and their availability rules.
- Keep family identity explicit. Do not infer Expressive identity from border, elevation, or shape style.
- Account for app-wide scope: MyApp applies the selected family to MaterialApp.theme and darkTheme, and both UI Appearance and Theme Lab consume the available-family list. A development toggle therefore changes every route, not only the proving slice. Keep the first preview scoped to a Theme Lab/isolated preview composition or cover all out-of-slice routes before exposing a global family choice.

The older [Step 16 design brief](theme-step-16-design-brief.md) remains useful historical exploration, but its usesClassicPresentation description and earlier source counts are stale. The current implementation uses explicit AppThemeIdentity; verify current code rather than copying those passages.

### Architecture options

| Option | Isolation and iteration | Cost and risk | Assessment |
|---|---|---|---|
| **A. True third theme family** | Independent identity, light/dark recipes, Theme Lab preview, and eventual user choice. Classic and Neo remain selectable baselines. | Requires exhaustive family wiring and targeted review of two-family branches; family tests grow. | **Recommend.** This matches a coherent app-wide visual system and gives the experiment a clear safety boundary. Gate it from release until accepted. |
| **B. Expressive style variant layered over Material/Classic** | Quick to prototype a few component treatments. | Creates a second style axis alongside family identity; screens can accidentally combine Classic + Expressive or Neo + Expressive. A later promotion migrates variant state and branches. | Reject for production architecture. A disposable visual fixture is fine, but not a persisted mode. |
| **C. Screen-specific Expressive wrappers without a family identity** | Local experiments can be isolated temporarily. | Scatters conditions and makes a coordinated visual contract, paired light/dark behavior, and family selection difficult to test. High leakage risk. | Reject beyond short-lived experiments. |

**Recommended identity:** a true third AppThemeFamily with a stable code such as expressive; final stored code and localized product label must be fixed before implementation. Use the existing capability boundary or a narrowly generalized equivalent to keep it internal/build-gated. Do not make it generally selectable in a release until the gates in §21 pass.

## 6. Tonos Expressive design philosophy

1. **Training utility leads.** Every expressive decision should help prepare, log, or understand training.
2. **Density is a feature.** Keep the workout logger compact and values scannable; grow only when text, touch, or comprehension requires it.
3. **Hierarchy is coordinated.** Color, size, shape, surface, and motion should reinforce one another rather than compete as separate decorations.
4. **Motion has cadence.** Use a lively, lightly springy response for a few intentional low-frequency actions; keep repeated logging immediate and composed.
5. **Shape communicates role.** Differentiate the primary action, selection, content group, and modal—not every individual card.
6. **Color has ownership.** Theme accents organize the interface; success, error, plan identity, chart series, and measurements retain their domain meaning.
7. **Access is part of the expression.** Selection, focus, semantics, large text, compact widths, and reduced motion must be legible variants of the same system.

## 7. Proposed visual system

### Color strategy

Begin with a fixed Tonos purple seed, carried forward from Classic, and explore a more expressive tonal ColorScheme relationship around it. material_ui’s expressive dynamic-scheme variant may be compared against a curated purple-led scheme in the first visual slice; it is a palette generator, not proof of an Expressive component system. Do not use device wallpaper colors for the initial comparison: a fixed seed makes screen and light/dark evaluation repeatable.

Use primary for the main action and a small number of selected or focal surfaces. Use secondary/tertiary roles sparingly to separate meaningful groups or call attention to a different role, not as a new semantic system on every screen. Build light and dark schemes as intentional pairs with readable text, field, and focus contrast.

Keep existing ownership for completion/success green, warnings/errors, workout status, plan/profile/gym identity colors, nutrition semantics, chart series, progress colors, and heatmaps. Theme the chart frame, labels, tooltip, and selection affordance; do not retint its data to match the app accent. Avoid the earlier Jade/Iris/Apricot proposal palette.

### Surfaces and containment

Use a small, visible surface ladder:

1. **Canvas:** quiet page background.
2. **Group:** low-contrast tonal surface grouping a related section.
3. **Card:** distinct content surface with enough separation to read as an interactive or scannable unit.
4. **Selected/focal:** a stronger primary-tonal treatment for a true selected state or the screen’s key action.
5. **Raised/overlay:** dialog, sheet, menu, and transient feedback surfaces that clearly sit above the page.
6. **Navigation/action area:** a stable shell surface, distinct enough to separate persistent controls without competing with content.

Prefer tonal difference, a restrained outline, and shape to heavy elevation. Avoid enclosing every line item in its own tinted panel. Existing AppSurfaceTokens, AppSurfaceDecorationTokens, AppEffectTokens, and TonosSurface roles cover most of this ladder; configure family recipes first.

### Shapes

Keep the current hierarchy of semantic roles in AppShapeTokens, but tune the family recipe toward stronger contrast between a few roles:

- compact fields and small icon controls stay compact and rounded;
- secondary buttons and selection tracks have a clear, consistent shape;
- the primary workout action gets the most distinctive button silhouette, without becoming oversized;
- content cards use restrained medium rounding, with a selected card differing subtly in contour or fill;
- sheets and dialogs use a deliberate modal contour;
- FAB and transient actions may use a more expressive shape, but keep their current position and task.

Use shape change only when selection, activation, or expansion makes it meaningful. Do not make every surface pill-shaped or add arbitrary blobs. The present tokens store BorderRadius recipes; repeated non-rounded geometries or shape morphing would require evidence before adding a richer shape representation.

### Motion and the “bouncy” part

Tonos already has family-owned AppMotionTokens and appMotionDuration; Classic currently uses quick 180 ms, standard 200 ms, emphasized/page 300 ms, page transition 240 ms, and 160 ms exercise-detail selection. Both families resolve the reduced duration to zero. Keep using this policy.

The first Expressive slice should have a discernible rhythm, not animation everywhere:

- **Instant:** field typing, checkbox state availability, validation, busy/disabled state, destructive decision, and reduced-motion response.
- **Quick, roughly 120–180 ms:** pressed/released feedback and tiny selection acknowledgement.
- **Standard, roughly 180–240 ms:** a local selection/container change or an intentional reveal.
- **Emphasized, roughly 240–320 ms:** at most one major screen-local transition whose purpose is orientation.

Those are proposed Tonos ranges, not official Material mandates. Use a restrained spring with little or no overshoot on a primary button press/release, the Train tab’s selected-state movement, or a prominent metric selection if device review shows it helps. Give the user an immediate final state; spring motion must not delay a callback or next set entry.

Keep the adopted 180 ms WeightCard expansion recipe in Classic. In Expressive, the first slice may compare a lightly damped expansion only if it preserves the same state owner, final-set collapse, focus, and scroll behavior. Do not spring every set row, text field, scroll, chart series, menu, destructive dialog, or route. A real spring recipe is not represented by current duration/curve tokens; if more than one justified consumer emerges, define one semantic motion owner rather than scattering controller constants.

For MediaQuery.disableAnimations, all custom motion and shape transitions should settle immediately using existing appMotionDuration. Do not add opacity flourishes or secondary bounce as a supposed reduced-motion alternative.

### Typography

Keep the existing/system font stack. Use Material text roles and weight/spacing for clearer relative emphasis:

- one compact, strong page title;
- clearly differentiated section labels;
- medium/semibold exercise, plan, and settings row titles;
- quieter but readable supporting copy;
- bold, tabular-looking focal values only where current data supports them;
- supporting metrics remain smaller and visually secondary.

Emphasize the current exercise and selected Progress metric selectively. Do not enlarge every title or reduce dense set labels. Test platform fonts, locale expansion, 2× text, and existing numeric field geometry before adopting any typography detail.

### Actions and selected state

- **Primary:** Start Workout on Train; Finish Workout in an active session. Use Material primary tonal contrast and a stronger role-specific shape.
- **Secondary/tonal:** Optimize, plan support actions, and non-final page tasks. Preserve current locations and avoid duplicate primaries.
- **Text/supporting:** Add Set and compact inline actions remain quiet but discoverable.
- **Icon/utility:** gear, overflow, and edit controls keep their anchors, labels, focus, and touch area.
- **Floating:** Add Exercise remains a single-action FAB that opens the current Catalog route; do not turn it into a FAB menu.
- **Destructive:** keep red/error ownership, explicit labels, and current confirmation paths.
- **Completion:** green remains the success/completion signal, not an alternate general primary.

Make selected state unmistakable through at least two cues where practical (for example tonal fill plus shape/weight or icon plus label). Preserve current selection semantics and only style selected cards when a real state exists. Apply the same selection logic to Train tabs, configurable navigation, plan states, Progress metric/range controls, chart points, and exercise selectors.

## 8. Train: current composition and proposal

**Production source:** TrainPage in lib/screens/exercise/train_page.dart; SevenDayFocusCard; _ActivePresetsCard; _SplitWorkoutBar; TonosTrainTabs; MainScreen and TonosBottomNavigationBar.

**Current layout, in order:** the app bar contains the Overview/Plans selector and profile/gym action. Overview is an IndexedStack page with a vertical list: the seven-day focused-set body heatmap and leading muscle groups, followed by active plan cards. The focus entries drill into the existing analytics dashboard, and plan cards retain their management/detail routes. A persistent bottom safe-area bar contains Start Workout, Optimize, and the Optimize settings action. The default app navigation remains at the bottom.

**High-value Expressive treatment:** keep all positions and card order. Make the current tab selection more apparent in the compact app-bar selector. Give the weekly focus area and active plans distinct but coordinated tonal containment. Let the active plan state and its existing identity colors do the work; do not repaint plan identities. Give Start Workout the strongest action contrast in the pinned action group, with Optimize tonal and its gear remaining utility. Consider a quick, springy press response on Start, not a delayed launch.

**Plans tab, current and intended treatment:** the existing vertical list is Active Plans, Archived Plans, Premade Plans, Generate Custom Plans, then Manually Add Plan. Keep progressive plan reveal, edit actions, empty states, and their routes. Expressive can strengthen section containment and plan-title/metadata hierarchy while preserving plan identity colors; the final two creation bars remain supporting actions, not a new dashboard or primary-action row.

| Classification | Train decision |
|---|---|
| **High-value Expressive change** | Stronger Overview/Plans selected state; coordinated tonal focus and plan containers; unmistakable Start Workout hierarchy with a deliberate but quick press response. |
| **Supporting system change** | Match bottom navigation selection, icon-button focus/pressed states, typography, and light/dark surfaces to the same recipe. |
| **Keep current** | Focus-card/active-plan order, profile context, heatmap meaning, plan IDs/colors, drilldowns, pinned Start/Optimize/settings placement, and the five default navigation destinations. |
| **Defer** | New page header, dashboard, extra summary/quick-action sections, floating navigation, center FAB, and new plan-selection workflow. |

**Keep:** heatmap meaning, section sequence, selected profile behavior, edit and plan drilldowns, bottom action placement, and the bottom navigation. No new page title/header, dashboard, center FAB, or added summary section. The combined Train action bar and navigation already occupy persistent vertical space; the theme must not increase their height gratuitously. The action bar already reflows for compact widths and large text. Classic Train tabs currently use a fixed 44 dp height, while large-text tab coverage is stronger for Neo; include an explicit compact/2× Train check before changing its size or typography.

## 9. Active Workout: current composition and proposal

**Production source:** SessionScreen → ExerciseCard → WeightCard in lib/screens/exercise/session_screen.dart, lib/widgets/exercise_card.dart, and lib/widgets/weight_card.dart; WorkoutFinishAction and AddExerciseFab own the fixed actions.

**Current layout and behavior:** the workout is a scrollable list of exercise cards. Session timing is opened through the current drawer action. Each WeightCard header presents the exercise and completed/required count plus collapse, details, and anchored overflow actions. Expanded cards repeat the completion checkbox, weight and reps fields, and remove action per set, followed by Add Set. Add Exercise remains a FAB; Finish Workout stays pinned at the bottom. Completing all required sets triggers Tonos’s final-set collapse behavior. When a session is active elsewhere in the app, the existing OngoingSessionFab offers Resume or Exit; completing this screen opens the existing SessionCompleteSheet.

**High-value Expressive treatment:** give the currently expanded exercise header/card clear structural emphasis, while completed cards/set rows use semantic green. Keep dense field rows and field geometry. Do not introduce a selected “active set” state; the existing states are expanded/collapsed cards, checked/unchecked sets, keyboard focus, and menu state. Use quick check feedback without bounce; use the already approved 48 dp interactive completion region with the same visual checkbox. Keep Add Set supporting and Add Exercise utility. Finish remains the final primary action.

**Motion boundary:** retain the controlled expansion, 48 dp target, and anchored MenuAnchor as the established behavior. A third family may tune the surface and a few selected/press states, but must not add repeated row animation, delayed set availability, whole-session rebuilding, new focus rules, or scroll-to-card behavior. Any expressive expansion experiment is optional and must beat the accepted 180 ms recipe on Pixel 7 without compromising focus, viewport anchoring, or final-set auto-collapse.

**Keep:** set order, one-tap completion semantics, field entry flow, weight/reps labels, Add Set duplication behavior, contextual-menu action order, remove confirmation, final-set collapse, Finish position, and the scrollable dense logger. The active workout is the strictest performance and “less is more” screen.

## 10. Progress: current composition and proposal

**Production source:** MeasurementsTrendsPage in lib/screens/measurement_trends_page.dart with WorkoutMetricChartCard, ExerciseProgressSection, and HealthTrendsSection.

**Current layout, in order:** a pull-to-refresh vertical list begins with Workout Report: Workouts, Time, and Volume totals, a swipeable/selectable chart, six range options, and Additional Details. Exercise progress follows with actual and estimated one-rep-max trends, summary values, and a horizontal exercise selector. Health measurement trends follow in a horizontal card collection with add-entry/custom-metric actions. Do not substitute the separate, hidden Dashboard route.

**High-value Expressive treatment:** make the selected metric the focal item through stronger selected containment, text weight, and clear state geometry; keep the other two as supporting summaries. Give range selection a coordinated selected fill and local response. Give a selected chart point/tooltip enough contrast to read as interactive. Apply surface and type hierarchy consistently across the exercise and health sections.

**Keep:** all metric totals, order, range choices, actual/estimated distinction, drilldowns, chart ownership, and health-measurement identity. Preserve chart-series and heatmap colors. Do not count up metrics or tween a data line between different ranges; keep values immediately correct and use motion only to show which metric/range/point is selected. The existing WorkoutMetricChartCard range animation uses a fixed 160 ms AnimatedContainer; if touched, bring it under the existing reduced-motion helper.

**Known accessibility debt:** the custom exercise-progress chart responds to touch, but its plotted points do not have an obvious screen-reader/keyboard interaction or a textual point summary. Both Workout Report and Exercise Progress painters draw fixed 10/11sp labels without a TextScaler. Health Trends has a localized chart summary in the current working tree, but that source file is already modified locally; verify its committed/current status before treating it as a baseline contract. Include chart description, label scaling, and reduced-motion checks in the slice rather than assuming themed surfaces solve them.

## 11. App shell and navigation

The default bottom destinations are **Train, Catalog, Logbook, Progress, Profile**. The user can change which tabs are shown and their order; the number of destinations is not guaranteed to be five. MainScreen keeps destination state through an IndexedStack, so switching tabs is not route navigation.

Keep the bottom bar in its current location and preserve configurable destinations. Apply Expressive treatment through the existing TonosBottomNavigationBar: a visible selected indicator, a considered icon/label hierarchy, and a short local selection response. Do not replace it with floating navigation, a rail, a center FAB, a fixed five-item special case, or a morphing toolbar.

Keep the Train app bar’s tabs/profile control, Profile/settings back bars, and Session drawer actions where they are. A global route-transition rewrite is out of scope for the vertical slice. A later route study needs an actual orientation or continuity problem to solve and must respect disableAnimations.

## 12. Component opportunity matrix

| Component and current owner | Expressive opportunity and expected user value | Density risk; accessibility risk | Effort and scope | Recommendation |
|---|---|---|---|---|
| Bottom navigation — TonosBottomNavigationBar | Stronger selected destination cue and tonal shell; easier orientation. | Density: medium if height grows. Access: configurable count/order and selected semantics must survive. | Medium; shared/app shell. | **Slice.** Style existing bar in place; no floating redesign. |
| App bars and page headers — Material app bars, route-owned titles | More decisive title/action hierarchy and calmer surrounding surface. | Density: low. Access: title order, back/action labels, text scaling. | Low/medium; shared theme plus screen owners. | **Supporting.** Keep bar placement and controls. |
| Primary buttons — TonosAction and Material buttons | Primary shape/tonal emphasis and one-shot lively press response improve action recognition. | Density: medium if padding grows. Access: busy, disabled, focus and semantic labels. | Medium; shared action boundary and owners. | **Slice.** Focus Start and Finish. |
| Secondary/tonal buttons | Clear subordinate hierarchy for Optimize and support tasks. | Density: low. Access: maintain contrast and touch targets. | Low; mostly theme recipe. | **Slice.** Preserve action placement. |
| Icon buttons | Expressive pressed/focus state without enlarging the glyph. | Density: low. Access: label and 48 dp target. | Low; shared theme. | **Adopt where built-in material_ui support fits**, then verify by version. |
| FAB — AddExerciseFab | More tactile press/release and a family-owned shape. | Density: medium if FAB scale changes. Access: tooltip/name and route behavior. | Low; shared component. | **Supporting.** Keep it a single Catalog action. |
| Train segmented tabs — TonosTrainTabs | More legible selected container and short spring response. | Density: high if control gets taller. Access: keyboard, focus, selected state, large text. | Medium; shared plus Train. | **Slice.** Retain compact app-bar position and two labels. |
| Chips and filters | Clear state/role for actual filters and selected values. | Density: medium; chips can wrap. Access: selected state, labels, focus. | Medium; shared where patterns recur. | **Defer beyond slice.** Do not add decorative chips. |
| Cards and grouped panels — TonosSurface, TonosSection | Distinct canvas/group/card/focal ladder makes current content easier to scan. | Density: medium if padding or nested containers grow. Access: contrast and focus if tappable. | Medium; shared roles. | **Slice.** Tune existing surfaces, not a new card taxonomy. |
| Generic list rows and settings tiles | Stronger title/support/value hierarchy and controlled selected/focus states. | Density: medium at large text. Access: preserve full row actions and switch nodes. | Medium; shared settings owners. | **Later.** Keep current settings structure. |
| Workout exercise cards — WeightCard | Expanded/collapsed and completed-card hierarchy helps locate current work without implying an extra active selection. | Density: high; repeated cards and scroll anchoring. Access: focus, semantics, final-set state. | Medium/high; screen-specific plus tokens. | **Slice cautiously.** No new row height or repeated bounce. |
| Set rows and completion | Tactile but fast interaction with checked/unchecked states and the existing final-set transition. | Density: very high. Access: fields, checkbox semantics, target separation. | Medium; screen-specific. | **Slice.** Retain 48 dp target, visual glyph, and field layout. |
| Menus — WeightCard MenuAnchor | Family-owned selected/hover/focus container while preserving anchored actions. | Density: low. Access: focus traversal, Escape/Back/outside dismissal. | Low/medium; shared recipe only if reused. | **Keep adopted behavior; style only as needed.** |
| Dialogs — TonosDialogFrame / TonosChoiceDialog | Clear modal elevation, shape, selection, and readable title/actions. | Density: low. Access: focus containment, large text, keyboard and Back. | Low/medium; shared. | **Later.** Preserve current dialog content and return values. |
| Sheets — TonosSheet plus direct Material sheets | Coordinated modal surfaces/handles/action hierarchy. | Density: low. Access: safe area, drag/back, semantics. | Medium; shared boundary adoption is uneven. | **Later.** Do not migrate every sheet for visual uniformity alone. |
| Snackbars and feedback | Consistent success/error/info hierarchy without changing message timing. | Density: low. Access: announce meaningful messages; no color-only meaning. | Low; theme-level. | **Supporting.** Keep success/error semantics. |
| Progress indicators and loading states | Clear real progress and quiet loading containers. | Density: low. Access: progress labels and status semantics. | Low/medium; shared and operation-specific. | **Keep restrained.** No wavy/decorative loader by default. |
| Workout charts and exercise trend charts | Expressive framing, point focus, and selected state improve interpretation. | Density: medium. Access: custom-painted chart descriptions and keyboard point selection. | Medium/high; chart owners. | **Slice framing/selection only.** Preserve series; audit custom chart semantics separately. |
| Metric cards — workout report and health summaries | Selected metric becomes focal; support values stay compact. | Density: high in three-up summaries. Access: reading order, selected name/value/action. | Medium; metric card and chart owner. | **Slice.** No number-count animation. |
| Forms and fields — TonosField, TonosFormField, workout fields | Tonal focus/filled/error treatment communicates state with familiar entry. | Density: very high in repeated set rows. Access: labels, focus, keyboard, error text. | Medium; shared and route-specific. | **Theme carefully.** Keep logging field dimensions and focus order. |
| Empty states | A little more hierarchy and a clear next action. | Density: low. Access: text and action stay explicit. | Low; per screen. | **Later.** Do not invent empty-state dashboards. |
| Route transitions and container morphs | Could clarify orientation where navigation truly changes task context. | Density: n/a. Access: reduced motion and no lost state; frame-time risk. | High; router/app shell. | **Defer.** Keep platform routes for this slice. |

## 13. Three-screen vertical slice

Treat this as one connected proof, with fixed representative data and matched light/dark states. Geometry, section order, navigation, controls, and task flow remain the production versions.

### Train / Overview

- **Surface:** clearer canvas, focus-card, and active-plans separation; no extra nested cards.
- **Shape:** more character on tab selection and primary action; restrained plan/focus cards.
- **Type:** firm section titles, existing plan labels and counts remain compact.
- **Actions:** Start Workout is primary; Optimize is tonal; its gear remains utility.
- **Motion:** responsive primary press/release and tab selection; no delay before starting.
- **Selection:** current Overview tab and actual active plan state are explicit.
- **Owners:** existing Train layout, TonosTrainTabs, TonosSurface, split action bar, and app navigation.
- **Responsive/reduced motion:** preserve compact app-bar/action-bar reflow and reduce animated selection to immediate state.

### Active Workout

- **Surface:** the currently expanded exercise and completed exercise/set states have a clear tonal role without lifting all rows.
- **Shape:** distinguish header/action roles; set fields and repeated rows keep current geometry.
- **Type:** exercise name and completion count scan quickly; weight/reps stay readable; no giant workout headline.
- **Actions:** completion remains green; Add Set secondary; Add Exercise utility; Finish Workout final primary.
- **Motion:** preserve the 180 ms controlled expansion and MenuAnchor; use only a small press response outside repeated logging. Optional Expressive expansion test is a separate device-gated comparison, not a prerequisite.
- **Selection:** expanded/collapsed, checked/unchecked, keyboard focus, and menu state remain semantically explicit; no new active-set selection is introduced.
- **Owners:** SessionScreen, ExerciseCard, WeightCard, WorkoutFinishAction, AddExerciseFab, and current session state.
- **Responsive/reduced motion:** no control overlap at compact width or 2× text; zero-duration behavior retains final card/checkbox state, focus policy, and scroll position.

### Progress

- **Surface:** focus the report and selected metric, separate exercise progress and health trends with quiet group surfaces.
- **Shape:** selected metric/range state differs visibly; chart container remains a data frame, not decoration.
- **Type:** selected metric leads; Time/Volume support; labels and exact values remain stable.
- **Actions:** chart/range/metric controls preserve existing hit regions and labels.
- **Motion:** quick selection and point-tooltip feedback; no value counting or data-series interpolation across unrelated ranges.
- **Selection:** metric, date range, exercise, and chart point states are distinguishable.
- **Owners:** MeasurementsTrendsPage, WorkoutMetricChartCard, ExerciseProgressSection, HealthTrendsSection.
- **Responsive/reduced motion:** preserve all six range options; the current selector uses six columns through 1.15 text scale and three columns above that scale. Selection changes settle immediately when animations are disabled.

### Slice acceptance

The three screens should read as the same Tonos Expressive family in both modes while still being recognizable as today’s Tonos. The slice fails if it only looks like new purple paint, if one screen reads as Neo, if it changes workout density, or if its selected states/motion are inconsistent between shared components.

## 14. Areas deliberately kept current

- All workflows, routes, screen order, bottom navigation destinations/configuration, Train Overview/Plans tabs, card order, primary action placement, and workout set structure.
- Classic and Neo colors, geometry, capability behavior, settings state, and user data.
- Completion green, errors/warnings, plan/gym/profile identities, nutrition meaning, chart/heatmap series, and measurement colors.
- Weight/reps field layout, set order and labels, final-set auto-collapse, 48 dp completion region, MenuAnchor action order, and confirmation flow.
- Progress totals, actual-versus-estimated distinction, range choices, chart interaction, and drilldowns.
- Profile/settings taxonomy and dialog/sheet content.
- Font family, app route transitions, and global motion behavior until an actual screen-specific benefit is shown.

## 15. Tokens and shared-component implications

Do not create tokens in this planning task. The current token inventory is already broad: AppShapeTokens has dozens of named BorderRadius roles; AppSurfaceTokens describes product surfaces and opacities; AppSurfaceDecorationTokens selects flat, Material-elevated, or explicit-shadow treatment; AppEffectTokens owns depth/effect values; and AppMotionTokens owns durations and curves. Use these first.

Only add or generalize a semantic token after the slice identifies a repeated role that current ownership cannot express. Likely candidates to test, not pre-approve:

- **Expressive selection container** if multiple components need a coherent selected fill/shape/state-layer recipe beyond their existing role.
- **Action press motion** if more than one shared control needs a real damped spring not expressible by duration/curve alone.
- **Family surface foreground resolution** if custom-tonal surfaces repeatedly need contrast selection beyond generic ColorScheme foregrounds.
- **Shape representation** only if multiple production components require a recurring non-BorderRadius shape or coordinated morph.

Use semantic shared boundaries where they already exist: TonosAction, TonosSurface, TonosSection, TonosField/TonosFormField, dialog and sheet wrappers, TonosBottomNavigationBar, and TonosTrainTabs. Their production reach is uneven: TonosAction currently has one production caller; TonosSection and TonosSheet are currently used in Theme Lab; TonosDialogFrame and TonosField have broader production use; navigation and Train tabs are strong centralized styling points. TonosSurface is useful but caller overrides can bypass its shared recipe. Standard Material button themes currently have broader reach than TonosAction, and many sheets remain direct modal-sheet calls. Do not assume every Material button or modal passes through a Tonos wrapper. Extend a shared component only when multiple real callers need the same behavior; keep workout-specific semantics with WeightCard and chart-specific semantics with their chart owner. Avoid a generic “ExpressiveWidget” or family-name conditional sprinkled into leaf routes.

## 16. Accessibility, responsive layout, and reduced motion

- Preserve labels, selected/checked/expanded state, action semantics, focus traversal, keyboard behavior, and focus restoration. Visual state and semantic action must remain on the same logical control.
- Keep the 48 dp set target as the interactive region, not a reason to scale checkbox artwork or inflate every row. Retain the tested no-row-height-growth behavior.
- Test regular and compact widths (including the current 320 dp WeightCard case), default text, and 2× text. Current WeightCard already reflows below 330 px and stacks fields above 1.15 scale. At 2× the fixed-width Set N label can ellipsize while its semantic label remains complete; that is known existing debt and must not be worsened or hidden by this visual work.
- Preserve keyboard and field focus during interactions, especially while completing non-final/final sets. Do not animate a disappearing focused control without preserving the established collapse behavior.
- Use MediaQuery.disableAnimationsOf(context) through appMotionDuration for custom movement and selection. Reduced motion must keep all selected/expanded/completion states clear and immediate.
- Preserve scroll anchoring when cards expand/collapse; never auto-scroll merely to stage an expressive transition.
- Include contrast and non-color selection cues in both light and dark families. Check Android font scaling and localization expansion.
- The custom-painted exercise trend chart needs a separate screen-reader/keyboard description review; its totals and controls should not be mistaken for a description of plotted points.

## 17. Testing strategy for implementation

1. **Theme contract:** for Classic, Neo, and Expressive in light/dark, assert both persisted family and rendered-family identity, complete registration of all 14 non-identity extensions, capabilities, stable stored code, and expected foreground/surface contrast. The existing Classic completeness helper omits Progress, Tutorial, and Media extensions; assert these explicitly so Classic defaults cannot mask an incomplete Expressive recipe. Test unavailable Expressive selection resolves safely without changing Classic or Neo.
2. **Parity:** compare Classic and Neo theme recipes/representative widgets against current golden or value contracts. No Expressive registration should silently alter their current builders.
3. **Fallback audit:** categorize every affected usesNeoPresentation / usesClassicPresentation branch in the three routes and shared components. Add targeted tests so an Expressive theme cannot accidentally receive a Classic-only custom surface or fallback.
4. **Screen behavior:** widget tests use production Train Overview, Session/WeightCard, and Progress owners with deterministic state/data. Verify screen hierarchy, action order, current selected state, set behavior, and chart meaning.
5. **Accessibility/responsive:** semantics for controls and charts, focus and keyboard where supported, reduced-motion state, 320 dp and regular width, 1×/2× text, and adequate hit boxes/non-overlap.
6. **Goldens:** capture the real production widgets with fixed fake/session data in paired light/dark modes at one standard and one compact/text-scaled viewport. Keep snapshots limited to the proving slice and update them only with deliberate visual review. Goldens catch drift; they do not replace Pixel 7 review.
7. **Device review:** reuse the checkpoints in [device visual accessibility QA](device-visual-accessibility-qa.md); install an isolated development package/database on Pixel 7 (previously verified device ID 28021FDH200228), compare Classic with Expressive in the same workflow, and ask whether hierarchy/tactility improve without slowing logging or harming data reading. Do not use the user's normal app database.
8. **Repository gates:** run dart analyze with the accepted toolchain, focused route/theme tests, the uninterrupted full suite, git diff --check, Android debug build, and current theme inventory/ratchet checks if theme ownership/inventory scopes change.

## 18. Rollout sequence

### Phase 0 — Approve the product contract

Review this plan’s family recommendation, palette strategy, role-based shape/motion language, and keep-current boundaries. No production change is implied until this review is accepted.

### Phase 1 — Isolated family foundation and proving slice

Build the Expressive family behind a development/build gate. Add complete light/dark recipes and only the minimum shared-owner adjustments needed for the Train Overview, Active Workout, and Progress production widgets. Preview these production widgets under a scoped Theme Lab/isolated preview theme; do not put Expressive into the global available-family list yet. MyApp applies a selected family to every route, so either establish coherent out-of-slice fallbacks for all routes or keep the experiment locally scoped. Do not enable release selection. The existing TONOS_ENABLE_NEO_RELEASE flag must remain Neo-only.

### Phase 2 — Device and accessibility qualification

Use Pixel 7 review and responsive/semantics/reduced-motion checks. Tune or reject the system before expanding route coverage. Classic and Neo parity is a hard gate.

### Phase 3 — Expand by workflow

Only after the slice is accepted, apply the same recipe to Catalog and Logbook workflows, then Profile/settings. Preserve component semantics and keep shared-boundary reuse evidence-based.

### Phase 4 — Secondary flows and release readiness

Qualify dialogs, sheets, onboarding, and secondary settings routes; finish localization, contrast, inventory/ratchet scope, regression, and release policy. Keep advanced morphing, experimental shapes, or global route motion deferred unless product review explicitly chooses them.

## 19. Decision gates

- **Gate A — identity isolation:** Expressive has explicit persisted and rendered identity plus complete paired recipes. A preview is scoped to the lab/slice; do not expose it in the app-wide selector until the rest of the app has intentional behavior. Classic/Neo selection, persisted values, and rendered contracts remain unchanged.
- **Gate B — three-screen coherence:** Train, active logging, and Progress read as one family without new information architecture, misplaced controls, inconsistent selection, or density loss.
- **Gate C — real-device approval:** on Pixel 7, primary actions feel tactile and responsive; logging is no slower; no unexpected focus, scroll, keyboard, or chart behavior occurs.
- **Gate D — access parity:** 2× text, compact width, semantics, touch targets, keyboard/focus, reduced motion, light/dark contrast, and chart meaning remain usable.
- **Gate E — regression qualification:** analyzer, focused tests, full suite, build, inventory/ratchet where applicable, and Classic/Neo parity all pass.
- **Gate F — release decision:** only explicit product acceptance may change release availability or user-facing family selection.

Failure at B, C, or D means revise or narrow the slice; failure at A or E means do not expose or expand the family.

## 20. Risks and open questions

- **Expressive leakage into Classic/Neo:** two-family predicates can route the new theme into Classic or generic styling. Audit affected branches and test all three identities.
- **Density and performance:** tonal panels, larger controls, or row motion can accumulate cost across repeated sets. Measure whole cards and full workflows, not isolated controls.
- **Over-animation:** springiness can increase perceived latency and make a dense fitness logger noisy. Keep bounce to rare, reversible emphasis; never add it to routine set entry.
- **Color semantics:** a generated Expressive color scheme may introduce contrast or semantic collisions. Preserve domain colors and review full light/dark surfaces.
- **Accessibility:** icon-only selected states, semantics separated from hit actions, tiny scaled labels, and custom charts can undermine the visual gain. Test state names and geometry with real widgets.
- **System capability drift:** material_ui is evolving. Verify the actual pinned package API before relying on newer Expressive controls or official motion support.
- **Maintenance:** a third family adds one recipe across family builders, extensions, previews, localization, capability, and tests. Avoid unnecessary new tokens and avoid globally rewriting every identity branch.
- **Brand expression:** carrying the purple seed gives continuity but may make the result too Classic-like; aggressive accent rotation may make it feel unrelated. Resolve this in the matched three-screen palette comparison, not by deciding from a token table.
- **Scope:** Nutrition and unrelated dashboard/Theme Lab modifications remain outside this proving slice.

## 21. Recommended immediate next implementation task

**Implement one scoped Tonos Expressive vertical slice using the production Train Overview, Active Workout, and Progress widgets.** Include the minimum true-family identity and complete light/dark theme plumbing required to render that slice in a Theme Lab/isolated preview, without adding it to the app-wide family selector; preserve current layouts and all Classic/Neo behavior; and finish with the responsive, reduced-motion, regression, and Pixel 7 gates in this plan. Before exposing Expressive app-wide, either give every route intentional behavior or keep the preview isolated. Do not expand to Catalog, Logbook, or Profile until this single slice is reviewed and accepted.

This is a recommendation only. No part of that implementation is included in this documentation task.

## 22. Source-backed screen and architecture map

- Train Overview and Plans: [TrainPage](../lib/screens/exercise/train_page.dart), [SevenDayFocusCard](../lib/widgets/seven_day_focus_card.dart), [TonosTrainTabs](../lib/widgets/tonos_train_tabs.dart), and [TonosBottomNavigationBar](../lib/widgets/tonos_bottom_navigation_bar.dart).
- Active workout: [SessionScreen](../lib/screens/exercise/session_screen.dart), [ExerciseCard](../lib/widgets/exercise_card.dart), [WeightCard](../lib/widgets/weight_card.dart), and workout actions in [workout_actions.dart](../lib/theme/widgets/workout_actions.dart).
- Progress: [MeasurementsTrendsPage](../lib/screens/measurement_trends_page.dart), [WorkoutMetricChartCard](../lib/widgets/workout_metric_chart_card.dart), [ExerciseProgressSection](../lib/widgets/exercise_progress_section.dart), and [HealthTrendsSection](../lib/widgets/health_trends_section.dart).
- Family architecture: [AppThemeFamily](../lib/theme/app_theme_family.dart), [AppThemeSelection](../lib/theme/app_theme_selection.dart), [AppThemeFactory](../lib/theme/app_theme_factory.dart), [AppThemeCapabilities](../lib/theme/app_theme_capabilities.dart), and [theme_extensions.dart](../lib/theme/theme_extensions.dart).
- Theme recipes and shared boundaries: [AppMotionTokens](../lib/theme/tokens/app_motion_tokens.dart), [AppShapeTokens](../lib/theme/tokens/app_shape_tokens.dart), [AppSurfaceTokens](../lib/theme/tokens/app_surface_tokens.dart), [AppSurfaceDecorationTokens](../lib/theme/tokens/app_surface_decoration_tokens.dart), [TonosAction](../lib/theme/widgets/tonos_action.dart), [TonosSurface](../lib/theme/widgets/tonos_surface.dart), [TonosField](../lib/theme/widgets/tonos_field.dart), [TonosDialogFrame](../lib/theme/widgets/tonos_dialog.dart), and [TonosSheet](../lib/theme/widgets/tonos_sheet.dart).
- Earlier interaction evidence remains in [classic-m3e-component-interaction-plan.md](classic-m3e-component-interaction-plan.md) and [classic-m3e-interaction-prototype-results.md](classic-m3e-interaction-prototype-results.md). Its final “pause interaction modernization” recommendation closes those specific candidates; it does not supersede this broader design course correction.

## 23. Decision record

- **Design direction:** Material 3 Expressive as a coherent Tonos visual/interaction system remains worth evaluating.
- **Architecture recommendation:** a true third, development-gated family.
- **Package decision:** do not retain or add material_3_expressive; use current official material_ui, standard Flutter, and Tonos-owned behavior.
- **Classic/Neo:** preserve as accepted families and require parity.
- **Next work:** one source-faithful, build-gated Train/Active Workout/Progress vertical slice; not implemented here.
- **Screenshot need:** source code establishes the current hierarchy and widget composition for this planning pass. No screenshot is required to define the slice. Pixel 7 visual/human review remains required at the implementation gate.
