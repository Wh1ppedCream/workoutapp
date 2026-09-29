# Tonos Expressive — Sol independent review

**Status:** documentation-only recommendation; no redesign implemented or implementation authorized by this document.

**Reviewed:** 2026-09-29, `feature/classic-m3e`, starting HEAD/remote `9512d2609e59511fc6c4e8f0b92c051afc731209`.

**Foundation verified:** Flutter 3.47.5 / bundled Dart 3.13.4 / locked `material_ui` 1.5.0.

**Authority:** this review replaces the architecture, first-slice, and sequencing recommendations in the [Luna course-correction plan](tonos-expressive-course-correction-plan.md), while retaining that document as historical evidence.

## 1. Executive verdict

**The Luna plan is sound but needs expansion and two material architecture corrections.** It correctly distinguishes a coherent Expressive experience from three useful Classic interaction fixes. Its source fidelity, semantic color boundaries, package rejection, and Classic/Neo isolation are strong. Its immediate stored-family commitment and nested preview navigation are premature; its motion and shape proposals are too optional to reliably produce the noticeably newer experience requested.

Recommend **Option B: an explicit, preview-only rendered Expressive identity, promoted to a true stored third family only after evidence**. Prove it in a **separate sandbox app build that reuses production providers, shell, routes, and widgets**, starting with **Train Overview + Plans and the shell**, in light and dark together. Theme Lab is the discovery/control surface in that sandbox, not a data-isolation boundary inside the user's app.

The first proof must visibly coordinate containment, selected geometry, numeric hierarchy, primary actions, and navigation; it must also contain real, restrained spring responses. A recolored Classic with a few eased transitions fails the product goal. Workout remains utilitarian during repetition, and the accepted 180 ms expansion, 48 dp target, and MenuAnchor remain contracts. Progress follows a chart-accessibility prerequisite. Train/Workout/Progress is the best eventual qualification program, not the first implementation batch.

## 2. What the Luna plan got right

- **WELL SUPPORTED:** inspect current production composition; preserve destination order/configuration, control placement, workflows, plan identities, heatmaps, and chart meaning.
- **WELL SUPPORTED:** retain Classic and Neo as accepted alternatives. A coherent experiment must not silently modernize Classic.
- **WELL SUPPORTED:** reject `material_3_expressive` as a dependency. The three production follow-ups show standard Material/Tonos ownership can preserve semantics, focus, density, and business state.
- **WELL SUPPORTED:** explicit rendered identity, paired brightness recipes, complete extension registration, shared component ownership, human/device review, and reduced motion.
- **WELL SUPPORTED:** avoid universal capsules, new dashboards, floating navigation, celebratory set logging, and package-led component replacement.
- **PLAUSIBLE:** an eventual third family gives users a clear choice. That does not establish that its persisted enum should change before a preview earns adoption.

The historical [interaction plan](classic-m3e-component-interaction-plan.md) describes an older SDK and earlier candidates. The [results](classic-m3e-interaction-prototype-results.md) supersede those particulars. Rejected isolated press/tab/range swaps are evidence about those experiments, not a veto on coherent Expressive design.

## 3. What should change or expand

| Previous recommendation | Review | Replacement |
|---|---|---|
| True third family during foundation | Too aggressive before visual acceptance | Rendered preview identity now; stored family promotion after gates |
| Theme Lab plus nested Navigator isolates proof | Architecturally risky for writable workflows | Separate package/storage sandbox; production root navigator |
| Train, Workout, Progress in first batch | Too broad for first tuning | Train + shell first; Workout and Progress as subsequent gates |
| Springs optional, little/no overshoot everywhere | Too conservative for requested feel | Designated spatial spring roles with small visible recovery; repeated logging immediate |
| Broad shape ranges | Under-specified | Role table, state transitions, and fixed hit/layout bounds |
| Seven recipe groups all imply new values | Missing ownership detail | Fourteen explicit slots; sparse presentation values; shared domain values |
| Chart/accessibility debt separate indefinitely | Under-scoped for Progress claims | Fix relevant debt before Progress qualification; no invented point interaction |

Correct the actual expansion primitive: the accepted production implementation is `TweenAnimationBuilder<double>` with `ClipRect` and `Align.heightFactor`, not a copied `AnimatedSize` fixture. `SessionScreen` enables it for Classic, and `WeightCard` resolves `motionTokens.quick`; Expressive must explicitly opt into the **same 180 ms recipe** when Workout enters scope. Changing the shared quick token could accidentally retime it.

## 4. Current official Material 3 Expressive evidence

**Official evidence, checked in this review:** [Google Design's research account](https://design.google/library/expressive-material-design-google-research) describes coordinated color, shape, size, motion, and containment. Its research spans 46 studies and over 18,000 participants. The reported attention advantage belongs to specific tested screens; some examples changed size and placement. It is not a predicted benefit of theming Tonos. Preferences and task context varied, and some louder experiments damaged usability.

[AndroidX MotionScheme source](https://raw.githubusercontent.com/androidx/androidx/androidx-main/compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/MotionScheme.kt) separates spatial changes from effects such as color/alpha, and distinguishes utilitarian recurring interactions from prominent interactions. This supports differentiated motion, not bouncing every control.

| Official component evidence | Tonos interpretation, not a Google requirement |
|---|---|
| [Common buttons](https://github.com/material-components/material-components-android/blob/master/docs/components/CommonButton.md): size/shape choices and state-dependent shapes | Vary primary versus supporting actions; preserve compact repeated controls |
| [Button groups](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/ButtonGroup.md): coordinated shape/width behavior | Train can express selection without transferring pressed width into neighboring hit areas; do not recreate the full group engine |
| [Navigation](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/BottomNavigation.md): compact selected indicator and more flexible configurations | Keep Tonos's fixed bottom location and configurable destinations; measure usable height |
| [App bars](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/TopAppBar.md): flexible title/content arrangements | Retain Train tabs/avatar and existing title/back controls; no new large header |
| [Cards](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/Card.md), [menus](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/Menu.md), [chips](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/Chip.md) | Use role-specific containment and normal component semantics; these references do not prove a new Expressive API exists for each Flutter widget |
| [Dialogs](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/Dialog.md), [sheets](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/BottomSheet.md) | Preserve modal task, safe areas, focus, dismissal, and existing content |
| [FABs](https://raw.githubusercontent.com/material-components/material-components-android/master/docs/components/FloatingActionButton.md): expanded size/color choices | Keep Add Exercise's current location and utility hierarchy; no FAB menu or oversized replacement |

Android/Compose implementation is design evidence, not Flutter capability evidence. Some Material web pages require JavaScript and provided no readable detailed specification in the research tool; the accessible official implementation docs above were used rather than filling gaps from third-party demos. Spring parameters and role sizes below are Tonos trials, not copied official requirements.

## 5. Flutter / material_ui capability reality

[Flutter's decoupling announcement](https://flutter.dev/blog/decoupling-material-cupertino) explains the standalone libraries and continuing official Expressive work. The **pinned local package** determines this task's available API, not current Android examples or future package releases.

| Capability | Verified reality at the accepted pin | Ownership |
|---|---|---|
| Ordinary M3 buttons, cards, fields, navigation, menus, dialogs/sheets | Available through `material_ui` | Prefer component themes/standard state and semantics |
| Expressive icon buttons | `IconButtonThemeData.variant = StyleVariant.material3Expressive`; `ButtonStyle` size, width, shape variants; component state shapes | Opt into relevant scoped icon controls; keep small familiar glyphs and adequate hit targets |
| Universal Expressive switch | `StyleVariant` enum exists, but no whole-ThemeData switch enabling every component | Do not claim one flag modernizes the app |
| Full official Expressive motion scheme | No equivalent app-wide MotionScheme found at 1.5.0 | Small Tonos semantic spring recipe where needed |
| Springs and ordinary transitions | Standard Flutter `SpringSimulation`, `SpringDescription`, `AnimationController.animateWith`, tweens, transforms | Tonos owns interruptibility, amplitude, lifecycle, and reduced motion |
| Color generation | `ColorScheme.fromSeed`, dynamic scheme variants, contrast level, surface roles | Generated foundation plus deliberate Tonos/domain ownership |
| Button-group neighbor morphing, flexible expressive app bars/nav, exotic shapes/loaders | Not established as complete pinned APIs | Defer; do not custom-build an entire component library |

The icon-button defaults still use ordinary `ButtonStyleButton` animation machinery; state shapes do not establish spring physics. The enum documentation warns that Expressive support is evolving. Keep the pin during the first proof, identify use of experimental variants, and qualify later upgrades separately. No package was added or fetched for this review.

The pinned `page_transitions_theme.dart` also explicitly notes that native Android Expressive springs are not currently supported. Custom local physics remains possible; this is another reason to keep route motion standard initially.

## 6. Architecture review

Current ownership is useful: `AppThemeFamily` and `AppThemeSelection` represent stored choice; `AppThemeFamilyIdentity`/`AppThemeIdentity` represent rendered identity; `AppThemeFactory` caches Classic/Neo recipes; capabilities own availability. `ThemeProvider` writes preferences. Preserve these distinctions.

| Model | Isolation / Classic-Neo risk | Maintenance, tests, abandonment | User clarity / eventual settings |
|---|---|---|---|
| **A — stored third family immediately** | Explicit, but expands factory/capability/preferences before proof | Early serialization/default/exhaustive-switch burden; abandonment leaves contract cleanup | Clear eventual choice; premature current promise |
| **B — explicit preview rendered identity** | Distinct from Classic and generic Material; production selection unchanged | New recipe and in-scope widget tests; cheap removal; promotion mapping later | Clear experimental label; one settings family when accepted |
| **C — Classic variant/mode** | Risks altering Classic defaults and predicate meaning | Extra combinations and conditional tokens; settings needs family plus style | Ambiguous Classic contract; bad fit for a visibly separate experience |
| **D — family-independent presentation policy** | Could reduce name branches but permits incoherent combinations | Capability matrix, flags, and tests grow; tempting global abstraction | Useful for shared roles, excessive as a user model now |

**Choose B.** These option letters follow this review request; the older plan used different labels for some alternatives. Reuse presentation roles from D where genuinely shared; do not create a policy matrix. B delays persistence, not coherent design. A becomes sensible after Train tuning and dense-workflow/data qualification. C remains a valid restrained Classic polish technique, but cannot serve this new product question without compromising the approved Classic contract. A gated enum member would not itself corrupt preferences; its main cost is committing the stored contract before the design earns adoption.

Identity rules:

- `usesClassicPresentation`, `usesNeoPresentation`, and a future `usesExpressivePresentation` are exact identity checks.
- Identity-less Material is a separate fallback, not Expressive.
- `!usesNeoPresentation` may mean shared Material behavior only when explicitly reviewed; it is never proof of Classic or Expressive identity.
- Never infer Expressive through `!Classic`, `!Neo`, brightness, color seed, enum position, or token absence.
- Prefer component themes/semantic tokens to repeating three-way family branches. Use a family branch only at a real presentation boundary.
- Audit reached branches in each slice, including descendants/overlays; do not perform a repository-wide predicate rewrite before evidence.

## 7. Third-family decision

Add **only the nonpersisted rendered identity** for the preview when implementation is approved. Build its paired cached ThemeData through an experimental definition; leave persisted family codes, default resolution, public availability, preferences, and release controls unchanged. Populate explicit extension slots so rendering does not depend on missing-token fallback.

Promote to stored `Expressive` only after the user accepts the direction and Train, Workout, Progress plus shell pass their gates. Promotion is a separate narrow task: stable storage code, capability gate, factory mapping, preference round-trip/default tests, translated family label, and Settings integration. Keep a release gate until wider workflows qualify. `TONOS_ENABLE_NEO_RELEASE` remains Neo-only.

If rejected, remove the experimental identity/recipe/runner without preference migration. No installed user's selected family should ever have been rewritten. Both eventual user choice and development cost argue for B at this stage.

## 8. Preview architecture decision

**Choose a root sandbox preview app, reusing `buildTonosApp` and `MyApp`, with a narrow optional root presentation override.** Do not fork the router or duplicate its provider list. A preview-only controller supplies cached light/dark themes and local mode/locale/text-scale/reduced-motion review settings; the default path still uses `AppThemeFactory` and `ThemeProvider` exactly as before. The root override must cover the navigator and builder-owned durability banner/system bars, not merely a page body.

The existing injection seam accepts `AppRepository` and `ThemeProvider`, but not arbitrary rendered theme pairs. Extending that seam is real work; pretending a page-level Theme wrapper is equivalent would hide the problem. Use no alternate persisted family to transport preview state. Ordinary Theme Lab discovery may document how to launch the sandbox; any actual Expressive entry/controller belongs inside the isolated runner. The runner must also work in profile mode for performance checks even though ordinary Theme Lab is debug-only.

| Boundary | Required sandbox behavior |
|---|---|
| Database | Distinct build-time `TONOS_DATABASE_NAME`; disposable deterministic fixtures. `DatabaseHelper` is a singleton, so injection of an ordinary `AppRepository` inside the running app does not select a second file |
| Android app data/preferences | Add a narrowly scoped preview build identity/flag with a unique applicationId; bind its runner to the distinct `TONOS_DATABASE_NAME`. Fail fast if preview launch/build lacks either setting, and inspect the built manifest before installation. Current internal flag selects only `com.tonos.internal`; that alone may reuse an existing internal install. Never overwrite normal/internal data |
| Providers/services | Reuse production provider tree in the separate process; seed onboarding/tutorials locally; verify direct repository/singleton users remain in its sandbox. No provider-tree copy or runtime DB hot-swap |
| Navigator/overlays | Reuse production root routes and callbacks. Root Theme/MediaQuery/locale are coherent for ordinary dialogs, sheets, menus, drawers, SnackBars, and Back |
| Locale/media | Root localization delegates/locale; preserve OS insets, viewPadding, keyboard, brightness and non-linear scaling. Review overrides apply above navigator child; restored on exit/reset |
| Root services | Inventory startup diagnostics, preference writes, durability/recovery, debug controls, system bars, tutorials. Keep their production behavior except preview-specific reset/data; global debug controls cannot change normal preferences |
| Deep links/restoration | Keep normal app contract untouched. Preview launch/reset opens a deterministic Train state; do not register user-facing Expressive deep links or restore a preview selection into production |

**Why not the nested-host proposal?** Train calls `ActiveSession.start()` before pushing Session, writes Optimize preferences, and creates plans before opening detail. A nested navigator intercepts routes, not those writes. `showDialog` defaults to root navigation; pinned `dialog.dart` captures inherited themes for the ordinary modal route, while its separate full-window builder also wraps caller MediaQuery. That is not a general guarantee that a nested preview's locale/providers/media propagate everywhere. Root builder-owned UI also escapes page-only theming. Nested navigation remains acceptable for an isolated component gallery with owned fixtures; it is weaker for these real workflows.

Keep real child routes and real callbacks in the sandbox. Children not yet qualified render with unchanged production widgets under the sandbox root theme and are explicitly **visually unqualified**, not replaced by fake detail screens. There is no separate route-specific Classic adapter or baseline-theme guarantee. Smoke-test navigation/return and sandbox writes; do not claim their final Expressive design is complete. This is safer and more faithful than adding route interception to each screen. It trades a small root seam and package-isolation setup for fewer preview-only workflow branches.

## 9. Revised Tonos Expressive principles

1. **Expression follows importance.** Give Start, selected destination/tab, and later selected metric coordinated emphasis. Repeated set entry is not a hero interaction.
2. **Density is a measurable contract.** Compare full repeated cards and available content above the fold, not isolated screenshots. No gratuitous row growth or new nested panels.
3. **Respond immediately; recover playfully.** State/callbacks update at once. A small spring may settle the visual selection or release; it never delays work.
4. **Make the system visible while still.** Surfaces, shape roles, type and selection should identify the new experience even with motion disabled.
5. **Use shape to name a role.** Distinguish prominent action, selection, ordinary card, and modal. Stable workout containers do not morph when completed.
6. **Keep semantic and data ownership.** Primary is an action role; green is completion/success; plan, heatmap, nutrition, and chart colors remain domain-owned.
7. **Adapt to content and access.** Large text can require reflow; never solve it by shrinking labels, disabling scaling, or weakening semantics.
8. **Keep business state outside animation.** Session rules, range/metric selection, and persistence remain with their existing owners. Retarget visuals to the latest state.
9. **Earn abstraction and rollout.** Use standard component themes first; add only consumed roles/shared boundaries. Tune the first screen before spreading its recipe.

Decision examples: a primary release can spring; a completion checkbox cannot celebrate; a selected tab can change shape/tone; an ordinary noninteractive card stays stable; a row remains compact unless content needs growth. Preserve a screen whose tasks already scan well until it enters a qualified scope.

## 10. Revised motion system

**Official distinction:** spatial motion and color/alpha effects deserve different behavior; prominent interactions can be more expressive than recurring utilitarian ones. **Tonos trial:** use two small spring recipes plus existing duration roles, not a universal animation engine.

| Role | Initial recipe to tune on device | Intended use |
|---|---|---|
| Instant | Zero visual delay | State, input, completion, busy flag, data selection |
| Quick effects | 120–160 ms non-overshooting color/state layer | Supporting press, selected fill, tooltip chrome; existing role consumers audited |
| Standard | 180–220 ms restrained ease-out | Small content/selection changes where no spring needed |
| Emphasized container | 220–280 ms non-bouncy | Only a future meaningful modal/container transition; not first proof |
| Spring-selected | Normalized mass 1, stiffness roughly 500–800, damping ratio 0.72–0.85 | Train/nav selection indicator; visible small recovery, fixed label/hit boxes |
| Spring-action | Mass 1, stiffness roughly 500–900, ratio 0.70–0.85 | Primary action's release/shape recovery, not callback timing |
| Route/surface | Existing platform transition first | No custom route spring in the initial proof |

These are **Tonos hypotheses**, not Material token values. In Flutter damping is derived from mass/stiffness/ratio; do not paste Compose stiffness numbers without the same units/normalization. Springs settle rather than finish at a prescribed duration. Tune displacement and tolerances as well as physics: one small noticeable recovery, no sustained oscillation. Aim to feel responsive within the ordinary short-transition envelope; record measured settling/perceived delay. Color, opacity, and hit/layout bounds must never overshoot.

| Interaction | Expressive / restrained contract |
|---|---|
| Start Workout | Expressive press shape/very small visual compression and spring release; invoke existing callback normally; no delayed launch |
| Optimize | Supporting tonal state layer; busy immediate; no repeating spring/spinner flourish |
| Overview/Plans | Spring-selected indicator/shape recovery, content switches immediately; no whole-page slide |
| Plan/card selection | Tone/state immediate, short effects; no bounce of every plan row |
| Exercise expansion | Preserve approved controlled 180 ms; no spring/shape morph |
| Set completion | Existing semantic green/check; state and auto-collapse exact; no new motion or haptic |
| Add Exercise FAB | Standard state layer initially; one subtle recovery only after later device evidence; no idle bobbing |
| Chips | Short fill/state response; no per-chip spring by default |
| Menu | Existing MenuAnchor focus/dismissal; normal Material motion |
| Sheets/dialogs | Standard modal behavior first; later restrained container role only if justified |
| Route entry | Standard platform transition; no hero flights or global replacement |
| Chart range | Immediate new selection/data; non-overshooting control fill; keep plot stable |
| Chart selected point | Immediate crosshair/description, no bouncing data point |
| Main navigation | Selected indicator can recover with spring; IndexedStack changes immediately; no animated page carousel |

Use actual physics for the approved spring roles, not `elasticOut` renamed as a spring. Repeated taps retarget from current visual value/velocity to the latest target; do not queue animations or replay every intermediate state. Bounds remain fixed, so any paint transform cannot move a control into another control's target. Clamp shape interpolation to valid shape ranges; spring a small spatial property separately if necessary.

Implementation detail to preserve the intended feel: Flutter's `SpringDescription.withDampingRatio` parameter is named `ratio`; a normally bounded controller clamps values and can hide overshoot. Use an unbounded/expanded-range **decorative** controller where travel needs recovery, with bounded displacement and clipping inside its allocated frame. Start indicator trials around mass 1 / stiffness 650 / ratio 0.8, then tune by measured travel; multi-destination jumps need tighter damping/amplitude limits. Snap rather than spring when destination count/order changes programmatically. A tiny button scale recovery may be barely perceptible, so do not claim that alone supplies the requested bounce; indicator travel and meaningful press-shape response carry it.

`appMotionDuration` handles duration-based custom movement; it does not suppress a `SpringSimulation`. Extend the existing policy minimally so spring users check the same `MediaQuery.disableAnimations` condition, stop active simulations if it changes, and snap to the latest state. Effects-off likewise disables optional recovery. Do not add a second user preference. Keep `quick = 180 ms` where the current workout recipe consumes it; use a dedicated effects role if 120–160 ms is needed elsewhere. There is no automatic performance benefit from merely renaming tokens.

## 11. Revised shape system

**Tonos starting values, subject to production geometry review:**

| Role | Starting silhouette | State behavior |
|---|---|---|
| Compact chip/control | Rounded rectangle, about 8–12 dp corners; no extra outer height | Fill/outline selection; stable label/hit area |
| Icon utility | Existing glyph; 48 dp target, restrained round/square variant | Official pinned expressive icon press shape only where useful |
| Supporting button | About 12–16 dp corners | Ordinary press/state layer |
| Prominent Start/Finish | Strong rounded rectangle, about 20–24 dp; keep current allocated height | Press toward roughly 12–16 dp, bounded recovery; not every action a capsule |
| Content card/group | About 16–20 dp; stable resting box | No random asymmetric corners or completion morph |
| Focal/selected card | Same box, distinct tone and optional about 20–24 dp rounding | Selection changes meaning without relayout |
| Train selected segment | Rounded block within its existing selector allocation | Indicator travels/recovers; text remains stable |
| Navigation indicator | Compact oval/rounded indicator behind existing destination glyph | State motion only, not floating entire bar |
| Dialog/sheet | About 24–28 dp modal rounding; sheet top corners as appropriate | Standard entry/exit; contents remain scrollable |
| FAB | Familiar rounded-square utility surface | Keep present size/location; no morph into menu |

Meaningful shape change belongs to press/selection, not every expanded, active, or completed state. Workout expansion is already communicated by disclosure and content size; completion by green/check/count. Do not add a competing shape channel there. Connected Start/Optimize outer/inner corners can clarify the existing relationship, but preserve split ownership, gear target, and responsive layout. Defer arbitrary polygons, 35-shape catalogs, custom path interpolation, and neighbor-width morphing.

## 12. Revised surface / containment system

Use a readable ladder, not nested rectangles of the same lavender. Suggested mapping:

| Role | Light starting role | Dark starting role | Use |
|---|---|---|---|
| Canvas | `surface` / lowest container | `surface` / lowest container | Quiet background |
| Group | `surfaceContainerLow` | `surfaceContainerLow` | Existing section grouping |
| Ordinary card | `surfaceContainer` or locally distinct low level | `surfaceContainer` | Existing plan/report surfaces |
| Selected/focal | `primaryContainer` or deliberate secondary container | Paired container with correct on-color | Selected tab/metric; sparse focal hierarchy |
| Raised/overlay | `surfaceContainerHigh` | `surfaceContainerHigh` | Dialog/menu/sheet contrast |
| Navigation | Neutral container | Neutral container with clear selected indicator | Fixed shell, not floating furniture |

This is a role allocation to evaluate, not an assurance every generated tone differs enough. Some existing `AppSurfaceTokens` defaults use fixed white/near-black card/sheet values; override these deliberately for Expressive rather than relying on factory names. Resolve `onPrimaryContainer`, `onSecondaryContainer`, and `onSurface` to their matching surface; a generic non-Neo `onSurface` helper is insufficient for every new container.

Train already has a focus group and an active-plans group: retain those boxes and reduce duplicate internal framing/shadow where it serves no meaning. Plans keeps its section cards; distinguish plan identity within them without tinting every section by the app accent. Workout keeps one exercise container and existing set-state fill, not one new raised card per field/set. Progress uses one report containment hierarchy; selected metric leads inside it, chart remains a neutral data region. No new sections or geometry rearrangement is justified by containment.

## 13. Revised action hierarchy

| Semantic role | Proposed Expressive treatment | Real owner |
|---|---|---|
| Primary workflow | Filled Material primary with high foreground contrast; strongest action emphasis | Train custom split bar; later `WorkoutFinishAction` |
| Secondary/tonal | Secondary/container tone, smaller emphasis in same allocation | Optimize, Browse Premade Plans |
| Supporting | Text/tonal action; short state layer | Add Set, minor edit actions |
| Utility/icon | Compact familiar icon, adequate target | Optimize gear, plan edit, profile action |
| Contextual | Standard anchored menu | Existing WeightCard MenuAnchor and plan menus |
| Destructive | Existing error/negative ownership and confirmation | Remove/discard/delete |
| Floating | Existing Add Exercise utility position; tonal containment | Session FAB |
| Selection | Selected container and clear semantic selected state | Train tabs, navigation, Progress metric/range |

For **Expressive only**, explicitly map Start and later Finish to Material primary; retain green for success/completion. Classic's green Start remains untouched. `AppSemanticColors.startWorkoutAction` is currently green and the split bar paints it directly; changing the seed alone does nothing. `WorkoutFinishAction` is a Material ElevatedButton with its own depth helper, so it must be qualified through its actual owner, not assumed to share Start's recipe.

Finish is the page-level action; current exercise structure is the strongest content emphasis. Add Set and FAB should not compete with Finish. Disabled and busy treatment preserves semantics and callback availability, without shrinking hit boxes. Never make a whole editable set row complete on tap.

## 14. Color strategy

Keep a Tonos connection through the existing purple identity, but express hierarchy through role contrast and neutral surfaces. Avoid flooding panels with lavender or introducing Jade/Iris/Apricot as a new domain system.

| Approach | Advantage | Risk | Decision |
|---|---|---|---|
| Generated from Tonos seed, including `DynamicSchemeVariant.expressive` | Complete paired roles, systematic contrasts | The pinned expressive variant rotates primary hue; its name is not a guarantee of Tonos branding or M3E behavior | Compare as a reference, not an automatic winner |
| Hand-curated complete scheme | Exact identity and role control | Many manual pairs and contrast maintenance | Avoid a full hand-authored palette without evidence |
| **Generated purple-led foundation with narrow curation** | Complete roles plus deliberate identity/surface/action tuning | Every override needs both brightness/on-color checks | **Recommended** |

Compare at most generated versus narrowly curated on the **same** Train states/layout, light/dark. Choose one before Workout rollout. Exact hex approval belongs to rendered review, not this source audit. Dynamic device wallpaper color is not part of the first proof.

Domain rules: keep completion green, warning/error meanings, plan/profile/gym identity palettes, muscle heatmap scale, nutrition meanings, and actual chart series. `AppProgressColors.accent` is currently both scheme-derived and used for chart/selection work: do not let a new generator silently recolor the workout series. Preserve the accepted brightness-specific data recipe, derive labels/grid/surface chrome separately, and introduce a narrow selection-role split only if mixed ownership prevents safe theming. Contrast fixes to a data palette are a separately justified data-accessibility decision, not accent matching.

## 15. Typography / data hierarchy

Retain the **inherited Material font family**; Classic does not declare a separate project font family. No new font dependency. Tune role size/weight/spacing selectively, with these initial logical-pixel ranges as Tonos hypotheses:

| Role | Initial hierarchy | Data/access rule |
|---|---|---|
| Page title | 24–28, medium/semibold | Preserve existing app-bar/header location; no hero headline |
| Section title | 20–22, semibold | Existing section order and spacing |
| Plan/exercise/setting row title | 16–18, medium/semibold | Clear scan line, not same weight as description |
| Supporting copy/metadata | 13–14 normal | Readable contrast; never tiny to compensate for layout |
| Dense input numbers | Keep existing 16–18-equivalent role/field geometry | Units separate, no animated digit transitions |
| Focal metric | About 30–34 semibold, chosen value only | Units 12–14; actual selected metric leads |
| Supporting metrics | About 24–28 medium | Stable baseline; no large shape/number competition |

Use tabular figures for aligned weights/reps/time/totals if the inherited font supports them; verify availability, decimal separator, and unit localization. Do not silently swap font for it. Numeric emphasis comes from value/unit relationship and alignment as much as size. Large values may wrap/reflow sensibly; do not truncate meaningful totals or abbreviate differently to stage a screenshot. No counter animations, rotating digits, or bouncing charts. Test non-linear OS text scaling, not just a linear multiplier.

## 16. Train review

Production `TrainPage` owns centered Overview/Plans, profile-avatar end-drawer action, and an IndexedStack. **Overview is exactly SevenDayFocusCard then Active Plans**. Do not add a recommendation/dashboard section. The pinned Start/Optimize split action bar appears only on Overview, above the main navigation. **Plans is Active, Archived, Premade, Generate Custom, Manually Add**, including existing progressive reveal.

Immediately noticeable newer-generation cues should be the **coordinated** selected Train segment, differentiated focus/plans grouping, a clearly primary Start beside tonal Optimize, and the shell's selected indicator. Section/title/value hierarchy supports these without increasing card count. Keep heatmap anatomy/data and plan identity fills/borders. Profile avatar remains identity-colored. Motion provides tactile recovery on deliberate navigation/action use, not scroll-time decoration.

Overview preserves the 7-day heatmap/focused-set arrangement, its more/analytics affordance, and active-plan rows/menu/edit location. Plans keeps archived/premade/creation content and reveal batches; no enlarged cover cards or new dashboard. The Start area keeps its current split/bar allocation and responsive reflow; no separate full-width replacement. At compact/large text, let header/bar content use needed height while preserving all controls and scrollable content; do not impose a fixed large-text cap.

Qualify focus data/loading/failure; selected profile/no profile; populated/no selected/missing active plans; disabled edit/loading; active/archived empty or populated; progressive reveal; Optimize busy/disabled and missing-profile feedback. Existing plans creation remains usable while active-state lookup is unresolved. Seed fixtures for rest-warning dialog, drawer, gear, and plan context menu. Tutorials should be fixture-completed, not removed from production.

Start actually starts a disposable session; Optimize actually computes/starts one. Child pages remain production smoke-test destinations until their phases. No fake behavior makes a press comparison trustworthy.

## 17. Active Workout review

The real hierarchy is `SessionScreen → ExerciseCard → WeightCard`, plus existing finish action, Add Exercise FAB, timers/drawer, and finish sheet. Its 180 ms controlled reveal, set target and anchored menu are accepted production behavior. Keep final-set auto-collapse, state persistence, menu order, Back/outside-dismissal, and hidden-control focus/semantics exclusion.

**Expressive later:** firmer session/exercise heading hierarchy; tonal current/ordinary exercise separation within existing rectangles; semantic green completed exercise/set; clear Finish primary; compatible modal containment. Use existing progress/count/timer information where present; do not invent a progress header or rest control. Expanded state is content/disclosure, not a new border animation.

**Strictly utilitarian:** weight/reps values, set labeling, checkbox glyph/48 dp target, add/remove set logic, fields, focused editing, scrolling, and all high-frequency repeat work. No field translation, row celebration, completion spring, counter animation, or per-set animation controller. The expressive theme must preserve tested target geometry and no checkbox-driven row-height increase.

Before real Start can reach Session in the first sandbox, explicitly preserve the accepted controlled region for Expressive: both `SessionScreen.animateExpansion` and `WeightCard`'s duration gate currently require Classic. A minimal explicit compatibility opt-in at these owners must retain 180 ms under `appMotionDuration`; it is not permission for new Workout styling or animation. Prove it with the adopted focused regressions. At zero motion, layout/state updates immediately. When Workout later enters visual qualification, existing focus contract remains: non-final completion keeps surviving field/IME behavior; final collapse removes hidden focus. Benchmark 4–6 rows, several cards, keyboard open, quick completion/reopen, and scroll-limit clamp. Reject a treatment that scans slower even if its screenshot is attractive.

## 18. Progress review

The destination is `MeasurementsTrendsPage` in **`lib/screens/measurement_trends_page.dart`**: workout report, exercise progress, health trends in one refreshable list. Preserve these, the three selectable metrics, chart PageView, six ranges, Additional Details, exercise/health selectors, comparison meaning and current tooltips.

Selected metric leads by stronger container/contrast and a modest value hierarchy. Workouts leads when selected; if Time or Volume is selected, it receives the same role. Do not permanently favor Workouts while another metric drives the chart. Supporting metrics remain compact. The plot remains a quiet data region with original series colors and stable axes.

Range/metric changes update selection and data immediately. Use restrained selection effects; no spring deformation of plots, interpolation between unrelated series, staged redraw, or delay behind an animated selector. Point selection should show the real bucket/value/comparison with an immediate accessible description, not a bounce. Retain current pointer interaction until its keyboard/screen-reader counterpart is designed and tested; do not add a new point/details mechanism in Train work.

Before Progress qualification, address point descriptions/access and fixed painter text scaling for the touched custom charts. Provide equivalent accessible values/summary navigation if individual points cannot sensibly become nodes, without test-only adapters. Replace range's fixed 160 ms custom animation with the existing reduced-motion policy. Cover no workouts/no points, missing estimates, loading/error, changing range, selected metric/point and Additional Details expanded. Static framing alone does not justify an accessibility claim.

## 19. Navigation / app-shell review

Shell belongs in the **first** proof. `MainScreen` in `main.dart` caches destinations in IndexedStack; NavBarConfig supplies live count/order and defaults Train/Catalog/Logbook/Progress/Profile. Preserve state, destinations, selected semantics, labels and position. Do not hard-code a five-item review shell as the implementation.

Use the existing `TonosBottomNavigationBar` boundary for an explicit Expressive Material presentation. Prefer `NavigationBar` and component theming if its measured geometry/semantics are acceptable. Its pinned implementation has fixed sizing and clamped label scaling: do not assume switching widgets solves large text. Trial the compact height/indicator separately, compare total shell height against current Classic, and resolve scaling/localization intentionally without blanket `withNoTextScaling`. Preserve existing configuration including supported nondefault counts; any adapter must handle the source contract instead of imposing the Material guideline's typical range.

Train's header remains tabs plus avatar; Session keeps title/timer action; other pages keep real back/navigation controls. No floating toolbar, center FAB, bottom placement change, large flexible header adoption, page carousel or route-motion replacement. Selected indicator motion is a shell concern; business destination changes stay instant. Root system bars and durability banner must use the same preview brightness/presentation.

## 20. ThemeExtension strategy

Register **all 14 non-identity extensions** deliberately in both preview brightnesses, plus identity. This prevents accidental null fallback, not a mandate for 14 bespoke Expressive matrices. The prior “seven groups” were conceptual; eventual trio consumes **eight concrete slots**, because ProgressColors and DataVisualization are separate owners.

| Extension | First Train + shell treatment | Later qualification / boundary |
|---|---|---|
| `AppSemanticColors` | Deliberate sparse action/foreground recipe over existing factory | Preserve completion/error/domain values; new primary action mapping explicit |
| `AppShapeTokens` | Sparse Train/action/card/nav role overrides | Workout field/set geometry shared; Progress selection later |
| `AppSurfaceTokens` | Scheme-derived complete matrix, override visible ladder roles | Audit fixed defaults/caller overrides; no copied hundred-field recipe |
| `AppSurfaceDecorationTokens` | Sparse visible group/card/modal decoration | No borders/shadows everywhere |
| `AppEffectTokens` | Deliberate brightness-specific restrained depth | Preserve readable separation without heavy shadows |
| `AppMotionTokens` | Existing duration contract plus minimal consumed spring role(s) | Keep workout quick180; one canonical reduced-motion policy |
| `AppDataVisualizationTokens` | Explicit shared heatmap/identity/data recipe; derive safe chrome if needed | Never generate series from new primary; verify every mixed role |
| `AppProgressColors` | Explicit compatibility registration preserving existing series meanings | Later chrome derivation and selection/series separation; not blind `fromTheme` recoloring |
| `AppSettingsPresentationTokens` | Explicit existing recipe | Settings-category meaning shared; presentation review later |
| `AppTutorialTokens` | Explicit existing recipe | Tutorial/onboarding review later; fixture-completed for captures |
| `AppMediaTokens` | Explicit existing recipe | Anatomy/media meaning shared; media routes later |
| `AppFlowTokens` | Existing brightness-specific recipe | Flow/diagram presentation later |
| `AppGenerationTokens` | Existing scheme-based complete factory | Train CTA in scope; generator pages unqualified |
| `AppNutritionTokens` | Explicit existing brightness recipe | Nutrition semantics shared; no Nutrition work in this proof |

“Shared” may intentionally reuse a Classic immutable recipe because its values express accepted domain behavior; it is not fallback by omission. Compose a new Material base using the expressive scheme, then attach explicit values. Avoid wholesale `ClassicTheme.copyWith` that silently carries family identity or unrelated style defaults. Sparse copies of individual role recipes are appropriate.

Current completeness helper omits Progress/Tutorial/Media; future tests should enumerate all slots, identity, pairings, and Classic/Neo unchanged values. Add a new token only for repeated semantic need. Two real selection consumers can justify a small spring role; one screen's arbitrary radius cannot justify a global token family. Document later-route compatibility as unqualified, not fully Expressive.

## 21. Shared-component strategy

| Boundary | Actual leverage | Recommendation |
|---|---|---|
| Material component themes | Broad standard-widget reach | First choice for buttons, fields, menus, cards/modal basics |
| `TonosTrainTabs`, `TonosBottomNavigationBar` | Real centralized Train/shell presentation | Explicit Expressive branch/recipe; same state callbacks and semantic nodes |
| `TonosSurface` | Multiple real Train/Progress consumers; color/radius/etc overrides exist | Reuse but inspect overrides; it cannot style every card automatically |
| `TonosDialogFrame`, `TonosField`/FormField | Broader production use | Theme their semantic boundaries; WeightCard inputs are separate |
| `TonosAction` | One production supporting Train caller | Do not migrate all actions merely to claim reuse; Start is custom |
| `TonosSection`, `TonosSheet` | Current use is Theme Lab | Do not claim broad production coverage or migrate every sheet |
| SplitWorkoutBar / workout action helpers | Real action semantics | Keep placement/state; targeted presentation recipe |
| `WeightCard` | Owns direct tokens, fields, completion and reveal | Later targeted theme consumption; business logic remains |
| Chart wrappers/painters | Domain state/series/access responsibility | Later local selection/chrome/a11y work; no generic Expressive chart |

No “ExpressiveWidget” mega-wrapper, duplicated screen trees, family-conditioned data providers, or one-consumer token explosion. Build a tiny reusable spring response only when two real controls need the same lifecycle/semantic policy. Preserve one logical control and standard Material gesture/focus semantics; a decorative layer must be IgnorePointer/ExcludeSemantics, not a second callback owner.

## 22. Accessibility / responsive strategy

[Flutter accessibility guidance](https://docs.flutter.dev/ui/accessibility) treats access as ordinary product quality. **Tonos gates** apply to every in-scope state: at least 48 dp interactive targets where appropriate; legible paired contrast; selected/checked/expanded/name/action on the same control; no duplicate semantic controls; focus restoration and Back; text reflow at 320 dp and normal Pixel width, 1× and approximately 2× plus OS non-linear scaling. Include long localized labels/RTL and landscape/insets smoke checks. Do not shrink typography or globally disable scaling.

| Existing issue | Timing / decision |
|---|---|
| Train Classic44 dp tab visual/interactive allocation | Expressive Train gate: derive actual hit region, provide48 dp without overlap, fit app-bar content at large text; leave Classic unchanged in this task |
| Navigation labels/scaling and configurable counts | During first shell slice; standard NavigationBar is not automatically sufficient |
| Visible Set N ellipsis at 2× | Separate focused accessibility fix **before or alongside Workout qualification**; full semantic name alone does not justify unreadable visible label. Preserve target/field usability; text-driven height growth acceptable |
| Custom chart point descriptions/fixed label scaling | Prerequisite **before Progress qualification**, not an indefinite afterthought. Preserve data meaning and provide accessible equivalent |
| Progress fixed 160 ms range animation | During Progress prerequisite/slice, use canonical reduced-motion policy |
| About15 dp clamp near extreme collapse scroll limit | Existing accepted observation; monitor against baseline in Workout, fix only if content/focus loss worsens. No automatic-scroll choreography |

Known chart debt does not block Train design; large-text Set label debt does not justify new workout styling before its turn. Existing debts elsewhere are tracked separately, not used to excuse new regressions. Reduced motion removes custom recovery entirely while preserving static hierarchy/selection. New paint transforms cannot alter or overlap hit boxes. No “test-only semantics adapter” to make a visual component appear accessible.

## 23. Dark-mode strategy

Dark is part of the first deliverable, not a later inversion. Use independently generated/curated paired roles and modest container separation, with accurate on-colors. No absolute white glyphs assumed on lighter dark containers; no blanket low-opacity disabled text on every surface. Test selected and unselected, busy, error, dialog scrim, profile identity, plan fills and heatmap colors.

Preserve brightness-specific semantic/data palettes. Light/dark comparison fixtures use identical content, geometry, scroll, selection and operation state. A dark recipe can use tone rather than shadow to separate group/card/overlay. Avoid neon primary everywhere and washed-out completed green. Review charts/series against dark background before Progress acceptance without opportunistic recoloring. Root system-bar contrast follows preview brightness.

## 24. Performance guardrails

- Cache theme pairs; no scheme/theme construction on animation frames. Keep providers/business state out of animated builders.
- At first, animate only the primary action and visible selected Train/nav indicators. Idle pages/lists do not run repeating springs.
- Reuse MainScreen TickerMode/state retention; stop invisible/disposed controllers, and stop/snap when reduced motion/effects-off changes.
- Prefer local paint/transform/decoration changes with fixed layout bounds. No intrinsic-layout probing, per-set controllers, full-list relayout or chart regeneration for a press.
- Avoid stacked fades/shape clips/shadows/saveLayer for ordinary cards. Clip only where the actual surface needs it. Do not preemptively add RepaintBoundary everywhere.
- Rapid retargeting must cancel stale completion callbacks; navigation, busy flags, and model writes occur independently of visual settling.
- Profile on Pixel 7 in **profile mode** against matched Classic fixtures, recording build/raster frame times and missed-frame clusters at actual display refresh rate. Debug frame timings are not an adoption claim.
- Measure scrolling + keyboard + repeated logging in later Workout. Reject perceptible delay/jank; do not hide it with longer animations. Chart selection must not repaint/rebuild unrelated dashboard sections.

No frame profile or device performance measurement was performed in this documentation task. A physics recipe that looks plausible is a hypothesis until the implementation is profiled.

## 25. Exact first vertical-slice scope

**First slice: root sandbox foundation + production Train Overview/Plans + production shell.** It is one visible proof, with actual callbacks and compatible child pages; full visual qualification is deliberately limited.

| Area | Exact scope/states |
|---|---|
| Root | `buildTonosApp` / `MyApp` optional preview presentation seam, explicit rendered identity, cached paired recipes, local review controller, minimal Android preview applicationId/flag plus runner binding to a distinct DB name and fail-fast install checks, no persisted Expressive choice |
| Shell | `MainScreen`, `TonosBottomNavigationBar`, real default five destinations and supported configured count/order, state retention/system bars/durability UI; selected/unselected states |
| Train header | `TonosTrainTabs`, selected Overview/Plans, avatar/end drawer; compact/large/localized labels |
| Overview | `SevenDayFocusCard` then `_ActivePresetsCard`; deterministic populated week/plans; loading/failure/empty focus; no-profile/no-selected/missing/populated active plans; edit disabled/loading |
| Plans | Active/Archived/Premade/Generate/Manual in production order; empty/populated active/archived; reveal3 then batches5; creation available during lookup |
| Actions | Existing `_SplitWorkoutBar`: primary Start, tonal Optimize, utility gear, Optimize busy/disabled; Browse Premade and creation CTA states |
| Direct overlays | Profile drawer, existing plan context menu, existing rest-warning AlertDialog/TonosDialogFrame, missing-profile SnackBar; focus, dismissal, correct root theme/media/locale |
| Real child routes | Session, analytics focus drilldown, plan management/detail, Premade, Optimize settings, generation/manual flow and profile children: unchanged workflow, sandbox writes, navigate/back smoke; minimal explicit identity compatibility fixes where required (including both accepted expansion gates) with focused regression coverage; explicitly unqualified visuals |
| Responsive/theme | Paired light/dark same states; 320 dp and normal Pixel width; 1×/~2×/OS scaling; long locale/RTL; reduced motion toggled before and during spring; keyboard/dialog/safe-area/landscape smoke |

Do not implement expressive Workout/Progress visuals, chart point interaction, router replacement, package upgrades, persisted-family selection, or broad wrapper migration here. A root scheme necessarily reaches ordinary child widgets; that compatibility reach is not permission to manually redesign them. Where a current identity gate would drop an approved behavior, narrowly preserve it and test it; if that becomes a broad child-route refactor, stop and report the dependency rather than widening the slice. Capture before/after production renders and short interaction recordings, with exact fixture/scroll metadata. Screenshots alone cannot judge bounciness.

## 26. Human-review success criteria

Use an isolated Pixel 7 build; verify device ID at runtime (previously `28021FDH200228`). Compare Classic and Expressive with the same fixture state. Record retain/tune/reject by role, rather than treating a whole app demo as automatically adopted.

1. At rest and with reduced motion, is this clearly a newer Material experience through coordinated type/surface/shape/action/navigation? If the only noticeable change is hue, fail.
2. Do Start, tabs, and nav feel tactile with a small enjoyable recovery? If no playful response can be perceived, the design is too conservative; if it distracts after 20 toggles, reduce it.
3. Does tapping update state immediately with no wait for animation? Rapid retargets must not jump, queue or double-fire.
4. Does it still read as Tonos: same Overview/Plans hierarchy, same actions, heatmap/plan identities, same destination behavior?
5. Are primary/supporting/utility actions distinguishable? Green completion/status must not be mistaken for selection/action emphasis.
6. Are selection and containment clearer without extra cards, universal pills or lavender saturation?
7. At normal scale, record total shell/bar heights and visible useful content against Classic; no avoidable density loss. At 2×, necessary text reflow must remain usable.
8. Do light/dark match in content/state, with readable overlays and identity/data colors?
9. Can keyboard/TalkBack reach each action once, identify current tab/destination, dismiss overlays and return focus?
10. Does Classic/Neo remain unchanged outside the sandbox and retain prior accepted behavior?

Train acceptance is provisional system acceptance, not final family adoption. Workout adds repeated edit/complete/auto-collapse/scroll-density gates; Progress adds readable/accessibly navigable data/range/comparison gates. If the user cannot explain what feels newer without sacrificing utility, tune before spreading the recipe.

## 27. Revised rollout phases

| Phase | Deliverable / gate |
|---|---|
| 0 — accept this implementation brief | Explicit product approval; safeguard dirty work and define safe sandbox identifiers/fixtures |
| 1 — Train + shell proof | Preview rendered identity, paired role recipe, root sandbox, real Train/shell states and designated springs; focused isolation/contract/responsive tests plus device review |
| 2 — user tuning | Freeze one palette/shape/motion direction; remove weak ideas before new routes; no automatic promotion |
| 3 — Workout | Set-label accessibility fix, accepted 180 ms compatibility opt-in already preserved, 48 dp/menu invariants; dense workflow/theme/focus/keyboard/performance qualification |
| 4 — Progress prerequisite and proof | Chart accessible equivalents/scaling and reduced-motion fix first; then selected metric/chrome/containment without data recoloring |
| 5 — promote identity | If full trio/shell accepted, add true stored third family with preference/capability/settings tests; release availability still gated |
| 6 — complete workflows | Qualify plan children, Catalog/search/filter/swap/Add Exercise, Logbook, Profile/settings, dialogs/sheets and other supported routes in coherent batches |
| 7 — release readiness | Localization/access/performance/parity, full validation, theme inventory/ratchet and wider route coverage; separate release decision |

Every implementation stage runs the accepted toolchain's analysis/focused tests; retained production changes require the repository's full validation gates. This document-only review needs no suite/build and claims no fresh analyzer/test totals. A failed direction can be abandoned before phase 5 without persisted-family migration.

## 28. Risks / open questions

- **Brand versus generated hue:** the expressive generator rotates primary. Choose the rendered purple-led result, not its enum name.
- **Preview setup cost:** root override/applicationId isolation is more setup than a gallery. It buys faithful root overlays/providers and avoids mutation interception. Keep the seam narrow and test null/default parity.
- **Theme leakage:** non-Neo branches, generic foreground helpers and direct color/radius overrides can defeat the recipe. Audit reachable consumers and classify unqualified children honestly.
- **Mixed chart roles:** scheme-derived `accent` mixes selection/data ownership. Freeze series and split only the smallest necessary UI role before Progress.
- **Motion under-delivery or excess:** selective springs are required for the experiment; logging springs are prohibited. Device tuning resolves amplitude/timing, not an all-motion on/off aesthetic.
- **Navigation scale/config:** standard M3 bar sizing/clamping may violate Tonos access/density. Resolve in the centralized owner, not with blanket scaling suppression.
- **Maintenance:** fourteenth extension presence is cheap; three bespoke copies of every field/route are not. Shared domain recipes and staged tests limit the burden.
- **Dirty work overlaps:** Theme Lab and HealthTrends are pre-existing modified files. Future work must incorporate those changes explicitly or use an agreed isolation strategy; no overwrite disguised as planning cleanup.
- **No render evidence yet:** source establishes layout/ownership for planning; actual palette, spring settling, perceived bounciness and performance remain unverified until the scoped runner is built.

## 29. Exact recommended next implementation task

> **Build an isolated Tonos Expressive Train proving ground using the current production app.**
>
> Continue on `feature/classic-m3e` from the verified current checkpoint; read AGENTS/status and preserve unrelated edits/untracked files. Use Flutter 3.47.5, bundled Dart 3.13.4 and pinned material_ui 1.5.0. Add no package and do not upgrade the SDK. Implement Option B: explicit nonpersisted rendered Expressive identity, paired cached Material themes and all 14 deliberate extension slots; leave stored AppThemeFamily, the family-preference contract, public availability and Classic/Neo recipes unchanged. Real sandbox workflows may write only their own disposable data/preferences.
>
> Reuse buildTonosApp/MyApp via one narrow optional root presentation seam, with a preview-only controller and a separately identified package/database/preferences sandbox. Add a minimal Android preview build identity/flag with a unique applicationId and one canonical runner invocation that binds it to a distinct TONOS_DATABASE_NAME. Fail fast if preview mode lacks either safe setting; verify the actual APK manifest/applicationId before installation. Leave normal/internal build identities unchanged. The existing internal flag alone is insufficient if that install exists. Put review controls above the sandbox navigator; do not duplicate providers/routes or intercept real callbacks into placeholders. Theme Lab may expose controls/discovery inside the sandbox. Provide profile-mode execution independent of debug-only Theme Lab.
>
> Apply one coordinated recipe only to real Train Overview/Plans and the shell as specified in section 25: existing focus/active-plan hierarchy, all Plans sections, selected tabs/destination, primary Start/tonal Optimize/utility gear, direct drawer/menu/rest-dialog/SnackBar states, loading/empty/busy cases. Preserve semantic and data colors; map Expressive primary workflow actions explicitly without changing Classic green. Add actual bounded spring-selected recovery for Train/nav indicators and spring-action recovery for Start, using canonical reduced-motion cancellation and fixed hit/layout boxes. State/callbacks stay immediate.
>
> Keep production children functional on disposable fixtures and label them unqualified in review evidence; no expressive Workout/Progress/route redesign. Preserve approved WeightCard 180 ms/48 dp/MenuAnchor/business behavior everywhere, including the minimum explicit Expressive opt-in at both expansion identity gates. Add focused compatibility tests; if preservation requires a broad route refactor, stop and report rather than expanding scope. Do not modify unrelated dirty files as cleanup; integrate any necessary touched-line work deliberately.
>
> Add focused identity/default-parity/isolation/theme-slot/semantics/retarget/reduced-motion/320 dp/2× tests. Render paired fixed-state production screenshots and capture short spring interaction video; inspect output. Run appropriate analysis, focused tests, full regression/build/inventory gates for retained changes. Evaluate the real Train workflow on isolated Pixel 7, including rapid toggles, long text, overlays, Back, light/dark and profile frame behavior. Report measured shell/content geometry and user retain/tune/reject checkpoints; wait for user tuning before expanding scope. Do not promote the stored family or implement another screen in this task.

This is the **one** recommended next task. It is sufficiently visible to test the system and sufficiently narrow to remove or tune. It is not implemented by this review.

## 30. Source / reference notes

**Repository evidence:** the three planning/results documents were read in full. Primary source paths inspected include:

- [TrainPage](../lib/screens/exercise/train_page.dart), [SevenDayFocusCard](../lib/widgets/seven_day_focus_card.dart), [Train tabs](../lib/widgets/tonos_train_tabs.dart), [bottom navigation](../lib/widgets/tonos_bottom_navigation_bar.dart), [main/app shell](../lib/main.dart), [NavBarConfig](../lib/providers/nav_bar_config.dart).
- [SessionScreen](../lib/screens/exercise/session_screen.dart), [ExerciseCard](../lib/widgets/exercise_card.dart), [WeightCard](../lib/widgets/weight_card.dart), [workout actions](../lib/theme/widgets/workout_actions.dart), [ActiveSession](../lib/providers/active_session.dart).
- [Progress destination](../lib/screens/measurement_trends_page.dart), [workout metric/chart](../lib/widgets/workout_metric_chart_card.dart), [exercise progress](../lib/widgets/exercise_progress_section.dart), [health trends](../lib/widgets/health_trends_section.dart).
- [Stored family](../lib/theme/app_theme_family.dart), [selection](../lib/theme/app_theme_selection.dart), [factory](../lib/theme/app_theme_factory.dart), [capabilities](../lib/theme/app_theme_capabilities.dart), [rendered identity/helpers](../lib/theme/theme_extensions.dart), [Classic recipe](../lib/theme/classic_theme.dart), [Material foundation](../lib/theme/app_material_theme.dart), [token definitions](../lib/theme/tokens), [ThemeProvider](../lib/providers/theme_provider.dart), [Theme Lab](../lib/theme/theme_lab_page.dart).
- [DatabaseHelper](../lib/db/database_helper.dart), [AppRepository](../lib/repositories/app_repository.dart), [Android build identity](../android/app/build.gradle.kts), [pubspec lock](../pubspec.lock), [device QA guidance](device-visual-accessibility-qa.md).

Pinned local evidence: `C:\Users\talh7\AppData\Local\Pub\Cache\hosted\pub.dev\material_ui-1.5.0\` (`pubspec.yaml`, `CHANGELOG.md`, and `lib/src/theme_data.dart`, `color_scheme.dart`, `icon_button.dart`, `icon_button_theme.dart`, `button_style.dart`, `dialog.dart`, `navigation_bar.dart`, `page_transitions_theme.dart`). Package path is machine-local evidence, not a portable build dependency. Official web sources are linked beside their claims in sections 4/5/10/22. Standard physics references: [SpringDescription.withDampingRatio](https://api.flutter.dev/flutter/physics/SpringDescription/SpringDescription.withDampingRatio.html), [AnimationController.animateWith](https://api.flutter.dev/flutter/animation/AnimationController/animateWith.html), [disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html). Navigator reference: [showDialog](https://api.flutter.dev/flutter/material/showDialog.html); pinned source and Flutter's `lib/src/widgets/dialog.dart`, not latest documentation alone, determined the ordinary modal versus full-window propagation caveat.

**Investigation and reconciliation:** three Luna Max investigators covered architecture/red-team/preview isolation; Train/Workout/Progress/accessibility/scope; and 14-slot tokens/color/components. Follow-up scopes covered pinned capability, motion/performance, and adversarial review. Sol owns the synthesis. Accepted their source maps and sparse token strategy; rejected child-route placeholders in favor of real sandbox callbacks; rejected blind Progress accent regeneration; required perceptible, bounded springs rather than treating all bounce as optional. Final adversarial review found no architecture blocker and prompted explicit preview build-identity/DB binding, accurate unqualified-child wording, and both expansion-gate compatibility requirements. The full trio remains the program, while Train+shell becomes the first proof.

**Worktree safety:** started with 15 unrelated tracked Dart edits and 5 untracked entries; no production/test/dependency/SDK files changed by this review. Theme Lab and health-trends evidence includes current local modifications and is not represented as a clean-HEAD implementation baseline. No analysis/test/device/build execution was required or performed. Historical green-suite results remain historical. The malformed Codex ref is outside this task and untouched.
