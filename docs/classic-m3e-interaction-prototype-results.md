# Classic interaction prototype results

**Evaluation date:** 2026-09-28
**Branch:** `feature/classic-m3e`
**Decision:** **NO — standard Material/Tonos is sufficient.**

Classic remains the visual and interaction baseline. The original prototype phase tested whether a package-backed Material 3 Expressive component improves real Tonos tasks enough to justify another permanent dependency. That comparison concluded that the package was not needed. The production follow-ups below subsequently adopted three standard Flutter/Tonos interaction improvements, which the user reviewed and approved on 2026-09-29.

## Package and toolchain audit

The current `material_3_expressive` release checked was **1.1.3**. Its declared requirements are Flutter `>=3.47.0`, Dart `^3.13.0`, and `material_ui ^1.4.0`. The workspace ran Flutter **3.47.5**, bundled Dart **3.13.4**, and `material_ui` **1.5.0**, so the package resolved against the accepted stack. The [package page](https://pub.dev/packages/material_3_expressive) and [1.1.3 changelog](https://pub.dev/packages/material_3_expressive/changelog) were checked on the evaluation date.

Version 1.1.3 includes breaking button size/color/shape API changes, removes `M3EToggleButton`, changes ButtonGroup density and keyboard focus behavior, makes the default FAB `medium` size 80 dp, and changes extended FAB, icon button, badge, loading, menu, and selection APIs. This is a fast-moving surface to wrap and maintain. The package also brings `dynamic_color`, `motor`, and `material_new_shapes`; its `material_ui` dependency is compatible with Tonos but does not replace Tonos's semantic component boundary.

The package was temporarily pinned to 1.1.3 for the prototypes, then removed. Pinned Flutter `pub get --offline` succeeded after removal and dropped `material_3_expressive`, `dynamic_color`, `material_new_shapes`, and `motor`. `material_ui 1.5.0` remains. No package-backed widget, M3E theme, production theme-family API, or production component implementation remains in `lib/` or `test/`.

## Lab architecture

The package-backed comparisons were run in the debug Theme Lab under the actual Tonos Classic theme. Prototype state was local to the lab: no workout, profile, or settings records were read or written. The package was never given app-shell, route, theme-family, or persistence ownership.

The package-free follow-up lab is `lib/theme/classic_interaction_lab/`, with focused tests in `test/theme/classic_interaction_lab/`. It compares current Tonos components with standard Material alternatives and remains absent from normal navigation. It is shown only in debug builds, only while Classic is selected, and only with `TONOS_THEME_LAB=true` and `TONOS_INTERACTION_PROTOTYPES=true`.

The package comparison captures remain under [`docs/proposals/classic-m3e-interaction-lab/`](proposals/classic-m3e-interaction-lab/). They are evidence from the temporary evaluation build; they do not imply that M3E widgets remain in the source tree.

## Seven prototype results

| Candidate | A/B comparison and Pixel 7 result | Accessibility, motion, and density | Decision |
|---|---|---|---|
| Primary action | `TonosAction` vs. `M3EButton`, same Finish Workout label and Classic color. Both kept a 48 dp tap target; the M3E small visual was 40 dp. Its spring press shape was visible during interaction, but did not make repeated activation feel faster or more reliable. | Disabled state and keyboard activation worked. The package press motion does not follow `MediaQuery.disableAnimations`, so reduced motion had to swap back to `TonosAction`. | **KEEP CURRENT.** The shared Tonos action already provides the needed role and feedback. |
| Train tabs | `TonosTrainTabs` vs. `M3ESegmentedButton`, with Overview and Plans in the existing location. Selection was clear in both. The current Classic frame is 44 dp; M3E uses a 48 dp target with a 40 dp visual band. | The package adds 4 dp to the frame and 12 dp to the target band. A semantics adapter was needed to keep each label attached to its selected action. Reduced motion used the current Tonos selector. | **KEEP CURRENT.** The compact current selector fits the app bar better. |
| Exercise expand/collapse | Current immediate Tonos disclosure vs. `M3EExpandableList` using the same fixture card and set rows. The spring reveal felt responsive on Pixel 7 and did not show an obvious scroll jump in the captured interaction. In the 800 dp fixture viewport the package list was about 18 dp shorter than the current card. | The package reports expanded state and supports keyboard activation, but exposes no controlled collapse handle. Preserving Tonos's auto-collapse after the last completed set required recreating its internal state, which snapped shut. Its spring also required a Tonos fallback for reduced motion. | **ADOPT PATTERN ONLY.** Keep a controlled standard `AnimatedSize` candidate (180 ms, no spring; zero duration when reduced motion is enabled). The source-derived card fixture is not the production `WeightCard`, so verify the exact focus and scroll behavior before production rollout. |
| Set completion | Compact current Material checkbox vs. package checkbox, with the same Tonos success green and set-row content. The M3E control provided a 48 dp target versus the compact current target; the row grew by at most 8 dp in the prototype test. | The success color had to be mapped locally because the package checkbox uses its own primary role. The larger target improves touch room but costs height on a repeated, dense logger row. | **ADOPT — standard Material/Tonos.** Preserve success ownership and use the standard checkbox when a 48 dp target fits the real row. No package is needed. |
| Anchored exercise menu | Current `PopupMenuButton`, standard `MenuAnchor`, and package `M3EMenu` used the real WeightCard action labels and order: Swap Exercise, Remove Exercise, Make ChangeSet. Each choice changed only local lab state. The package menu anchored correctly, but occupied a substantial overlay area without making the action choice faster. | The standard Material menu is sufficient for a controlled anchor and keeps the same action flow. Package motion needs a reduced-motion alternative. The fixture does not execute the real remove-confirm or swap callback, so those route-specific results remain owned by production Tonos. | **ADOPT — standard Material/Tonos.** Use `MenuAnchor` only where the current popup needs its explicit anchor control; keep the current action order and confirmation behavior. |
| Progress selection | Current six-range Tonos control vs. standard `SegmentedButton` and package `M3EButtonGroup`. The Tonos selector remains one compact row. On the Pixel capture, the standard Material control wrapped into two rows (about 88 dp); the M3E group stayed on one 48 dp row. | The package group separated a range's accessible name from its tappable button node at the same bounds. Large-text/narrow cases needed a Tonos fallback. Chart data colors stayed Tonos-owned and the fixture changed only local sample data. | **KEEP CURRENT.** The denser selector has working selection semantics and avoids the package's detached accessible name. |
| Route transition | Platform `MaterialPageRoute` vs. a scoped 240 ms fade with a small slide, with identical local Session and completion-sheet content. The transition did not improve orientation enough to justify replacing the platform route. | The custom route uses zero duration under reduced motion. A first device capture revealed a duplicate safe-top inset in the prototype; it was corrected, and the corrected platform/custom screens align below the system status bar. This route is standard Flutter code, not an M3E component. | **KEEP CURRENT.** Retain platform route motion until a real Tonos flow shows a specific orientation problem. |

### Set insertion scope

The plan groups Add Set with set completion. This pass isolated completion feedback and did not animate insertion: adding a row introduces a separate scroll-position and text-field focus question. Keep insertion immediate until it receives its own controlled test; no Add Set behavior was changed in production.

## Cross-cutting findings

- The Pixel 7 was verified at runtime as `28021FDH200228` (`Pixel_7`, `panther`). Prototypes used the isolated `com.tonos.internal.m3elab` application ID and a dedicated `tonos_m3e_interaction_lab.db` name. The installed `com.tonos.internal` and `com.tonos` applications were left in place. After the package-free rebuild, that isolated APK installed and launched; the phone was asleep and then remained at its lock screen, so I did not unlock it or repeat the touch pass. The earlier A/B captures below remain the device-interaction evidence.
- The lab used fixed demo data. The Progress screen was a deterministic chart fixture using Tonos data-visualization colors; it did not read the production workout chart or workout records. The exercise-expansion card was derived from the `WeightCard` structure, not the production widget/model.
- Repeated interaction checks found no visible delay that justified replacing current controls. This was hands-on device review, not a profile-mode frame-time benchmark.
- The most defensible improvements are available without the package: a controlled, reduced-motion-aware standard size transition; a 48 dp standard checkbox target where the production row can absorb the small height increase; and `MenuAnchor` for cases that need explicit anchor control.
- The package's strongest visual differences were not sufficient on their own. Its larger targets cost density, reduced-motion fallbacks needed extra code, and the Progress semantics defect made its most compact range control unsuitable.

## Evidence captures

- [Progress ranges and chart, all three variants](proposals/classic-m3e-interaction-lab/pixel-7-progress-full.png)
- [M3E exercise menu open](proposals/classic-m3e-interaction-lab/pixel-7-menu-open.png)
- [Exercise expansion](proposals/classic-m3e-interaction-lab/pixel-7-exercise-expansion.png) and [after all sets complete](proposals/classic-m3e-interaction-lab/pixel-7-expansion-complete.png)
- [Route comparison after safe-inset correction](proposals/classic-m3e-interaction-lab/pixel-7-route-selective.png)
- [Reduced-motion fallback](proposals/classic-m3e-interaction-lab/pixel-7-reduced-motion-top.png)

## Validation record

- Pinned executables: `E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat` and `E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin\dart.exe`; Flutter 3.47.5 / Dart 3.13.4.
- Prototype-focused suite: **32 passed**.
- Classic/Neo and Theme Lab regression subset: **130 passed**.
- Full suite: **1,182 passed; 1 failed** when `TEMP` pointed to `E:\projects\build\codex_temp`. The failing `theme_style_inventory_source_rules_test.dart` fixture depends on the system temp path being on a different drive from the repository; with a same-drive temp directory, the scanner correctly made it repository-relative and the test's absolute-path rule did not match. The isolated source-rules file passed **4/4** using the normal `C:\Users\talh7\AppData\Local\Temp`. A full rerun with that C: temp path stalled in the Flutter test compiler after 153 tests without producing new output; it was stopped. Thus the full suite was not observed green in one uninterrupted run.
- `flutter analyze --no-pub`: **0 errors, 0 warnings, 115 infos** (deprecated API notices); the analyzer exits nonzero when infos are present. No informational lint was reported in the new interaction-lab files.
- Android debug APK: **built successfully** in 79.6 seconds with the two lab compile-time flags and dedicated database name. APK package ID was verified as `com.tonos.internal.m3elab` and installed only over that isolated package.
- Pixel 7: the earlier package-backed A/B interactions and reduced-motion comparison were captured on device. The final package-free APK launch was confirmed, but the screen could not be rechecked because the device remained locked; no unlock credentials were entered.
- `git diff --check`: passed. Source search found no `material_3_expressive` dependency or M3E prototype references in `lib/`, `test/`, `pubspec.yaml`, or `pubspec.lock`.

## Prototype-phase decision boundary (2026-09-28)

At this prototype checkpoint, production adoption had not yet been approved. That temporary boundary was superseded by the production follow-ups below: controlled WeightCard expansion, the 48 dp set-completion target, and the WeightCard MenuAnchor are now production-adopted and user-approved. The package decision remains **NO — standard Material/Tonos is sufficient**; the three changes do not create a separate M3E theme or require `material_3_expressive`.

## Production follow-up: controlled WeightCard expansion

- **Evaluation date:** 2026-09-29
- **Branch:** `feature/classic-m3e`
- **Starting commit:** `47e9ba0846c0a0b91171243abc21c1e317a85322`
- **Decision:** **ADOPT.**

The production `WeightCard` now uses a controlled, standard Flutter height reveal when the active workout runs under Classic. Its existing `_isCollapsed` state and final-set auto-collapse remain authoritative. `TweenAnimationBuilder<double>` with `ClipRect` and `Align.heightFactor` reveals the existing set content over the Classic quick duration (180 ms), using the theme's standard curve. It uses no spring, fade, new controller, or animation dependency. The `appMotionDuration` reduced-motion policy selects the theme's immediate reduced duration. Other `WeightCard` call sites remain immediate by default, and the session enables the behavior only for Classic.

On Pixel 7 (`28021FDH200228`, `Pixel_7` / `panther`), the production session was launched with `flutter run` using the isolated package `com.tonos.internal.weightcardvalidation` and database `tonos_weightcard_validation.db`. Existing Tonos package installs and their data were left untouched. The hands-on session covered manual open/close and rapid retargeting, weight editing with the keyboard, a nonfinal set, final-set completion, reopening completed sets, and expansion of a lower card in a scrolled two-exercise session. The interaction felt slightly smoother and remained quick; there was no bounce or visual flourish. Editing retained the entered value, collapse removed focus and hid the keyboard, the nonfinal set kept the card open, the final required set auto-collapsed it, and reopening retained both completion checks. The lower card's header stayed anchored while it expanded and collapsed. At the scroll limit, the preceding card shifted by 42 screen pixels (about 15 dp) as the scroll extent clamped after collapse; this was small and did not obscure the active card.

Reduced motion was verified by the focused widget test with `MediaQuery.disableAnimations` enabled: collapse and reopen were immediate. The Pixel 7 remained at its normal motion setting during device interaction. Focused regression coverage passed for manual/rapid toggles, semantics, focus, reduced motion, compact width/large text, nonfinal and final completion, and reopened completed sets. The focused interaction and workout/session regression batch passed **37 tests**. Final repository validation and build results are recorded with the implementation commit.

### Final validation

- Flutter **3.47.5** / Dart **3.13.4**; the full suite used `--no-pub` and the machine's normal temp directory.
- Full Flutter suite: **1,188 passed, 0 failed, 0 skipped**, exit code 0, uninterrupted (**6m35s**).
- `flutter analyze --no-pub`: **0 errors, 0 warnings, 115 informational deprecation notices** in existing files; analyzer exit code 1 reflects the repository's informational-only findings. None are in the changed Dart files.
- Android debug APK: built successfully in **42.4 seconds**. Flutter reported upcoming support cutoffs for the existing Gradle 8.14.5, Android Gradle Plugin 8.11.1, and Kotlin 2.2.21 versions; this build succeeded without changing those versions.
- `git diff --check`: passed. Theme inventory and style ratchet were not applicable because no theme recipes or static styles changed.

## Production follow-up: set-completion touch target

- **Evaluation date:** 2026-09-29
- **Branch:** `feature/classic-m3e`
- **Starting commit:** `fe0dc174adb98c3ceeddad5dfebe07cf3f6c50f7`
- **Decision:** **ADOPT.**

The real control is the standard Flutter `Checkbox` rendered in each set row by `WeightCard` (`lib/widgets/weight_card.dart`), reached in the active logger through `SessionScreen` and `ExerciseCard`. `WeightCard` owns its `_completedSets` view state, mirrors completion into `exercise.completedParents`, and calls the session refresh callback. Its existing final-set rule still sets `_isCollapsed` when every required parent set is complete. Completion green continues to come from Tonos's semantic completion color.

The production checkbox keeps Flutter's 18 dp visual square and familiar checked/unchecked appearance. Before this change, its measured interactive box was **40×40 dp** at a regular 393 dp row width and **34×40 dp** in the compact 320 dp layout. It now measures **48×48 dp** at both widths, using the padded standard tap target and standard visual density. The checkbox's visible artwork and the row's completion color were not enlarged or recolored.

| Layout | Before row height | After row height | Delta |
|---|---:|---:|---:|
| 393 dp wide, 1× text | 80 dp | 80 dp | 0 dp |
| 320 dp wide, 1× text | 80 dp | 80 dp | 0 dp |
| 393 dp wide, 2× text | 222 dp | 222 dp | 0 dp |
| 320 dp wide, 2× text | 218 dp | 218 dp | 0 dp |

At 2× text, the weight and reps fields stack vertically as they already do under the current scale threshold. The fixed set-label slot ellipsizes at that scale; this target change leaves that slot's width and text style unchanged. Widget geometry tests confirm that the checkbox region does not overlap either input at compact or regular width, and each six-row fixture retains the measured per-row height. The checkbox semantics continue to expose one `Set N` control with its checked state and tap action together.

On Pixel 7 (`28021FDH200228`, 1080×2400 at 420 dpi), the isolated `com.tonos.internal.setcompletionvalidation` build used the separate `tonos_set_completion_validation_20260929.db`. In a real five-set Barbell Squat session, an edge-area tap on the checkbox toggled only its intended set; rapid distinct taps produced one state change per tap. A nonfinal completion kept the card expanded. Completing set 5 changed the header to 5/5, auto-collapsed the card, and dismissed the numeric keyboard; reopening showed all five checks retained. The weight field accepted a typed value while the numeric keyboard was open. Marking a nonfinal set complete retained field focus and the keyboard; marking the final set complete collapsed the card and dismissed the keyboard. The target felt more forgiving, while the checkbox drawing and repeated-row density looked unchanged.

The device font scale was temporarily raised from its original **1.15** to **2.0** for inspection, then restored to **1.15**. The enlarged-text device view showed the expected stacked fields and taller rows; the focused geometry test measured no target-caused row-height increase at either width. Completion semantics and touch behavior remained clear. No completion animation or reduced-motion behavior was changed.

### Set-completion validation

- Flutter **3.47.5** / bundled Dart **3.13.4**.
- Focused `weight_card_expansion_test.dart`: **6 passed**. Coverage includes 48 dp target bounds, six rows at compact and regular widths, 1×/2× text geometry, field non-overlap/input/focus, edge and repeated taps, semantics, and the existing nonfinal/final collapse contract.
- Full Flutter suite: **1,190 passed, 0 failed, 0 skipped**, exit code 0, uninterrupted (**8m09s**).
- `flutter analyze --no-pub`: **0 errors, 0 warnings, 83 informational notices**; exit code 1 because the repository reports informational deprecation notices as a nonzero analyzer result. No new analyzer error or warning was present in the changed Dart files.
- Android debug APK built and launched with `flutter run` against the isolated package/database; the normal Tonos installs and data were left untouched.
- `git diff --check`: passed. Theme inventory and style ratchet were not applicable; no theme ownership or token changed.

## Production follow-up: anchored exercise menu

- **Evaluation date:** 2026-09-29
- **Branch:** `feature/classic-m3e`
- **Starting commit:** `42ff353f25db7b543fbf6cbe26fc7537f8352d94`
- **Decision:** **ADOPT.**

The production contextual menu is the trailing exercise-card action in `WeightCard` (`lib/widgets/weight_card.dart`), used by the active logger through `SessionScreen` and `ExerciseCard` and by plan-editing callers. It is now a standard Flutter `MenuAnchor`. The action order and owners remain the same: Swap Exercise appears only when its callback exists, Remove Exercise still requires the existing Tonos confirmation dialog, and Make ChangeSet still toggles the existing local editing mode. Read-only cards disable the anchor.

The anchor keeps the prior Tonos popup surface, shape, elevation, shadow, tint, and family-specific foreground treatment. It is aligned to the card's trailing edge, constrained to the viewport, and consumes outside taps. The same owned focus node connects the icon button and menu; the first available action uses standard `MenuItemButton.autofocus`, so Enter opens the menu and a second Enter activates that action. Selecting an action returns focus to the trigger, Escape dismisses the menu, and Android Back closes it before leaving the route. When Swap is unavailable, Remove receives initial focus but still opens the existing confirmation dialog. No workout state or action callback moved into the menu.

On Pixel 7 (`28021FDH200228`, `Pixel_7` / `panther`, 1080×2400 at 420 dpi), `flutter run` launched the real active workout screen with isolated package `com.tonos.internal.menuvalidation` and database `tonos_menu_anchor_validation_20260929.db`. The app used the normal 1.15 device text scale and dark Classic appearance. The menu stayed within the right screen edge. Android Back and outside taps dismissed it without leaving the session or activating the underlying row. Make ChangeSet showed the existing Add CSet control; Remove Exercise displayed the existing confirmation dialog, which was cancelled. Opening the menu from a focused weight field hid the numeric keyboard while preserving the entered row values. Rapid open/dismiss interactions left the card and session intact. The normal Tonos installs and databases were not used.

### Anchored-menu validation

- Flutter **3.47.5** / bundled Dart **3.13.4**.
- Focused menu and WeightCard theme-scope batch: **17 passed**. Coverage includes action order, keyboard activation and Escape focus return, callback behavior, remove confirmation, read-only state, outside-tap handling, Android Back, semantics labels/actions, compact-width 2× text, and Classic/Neo light/dark menu contrast.
- Full Flutter suite on the production implementation commit `8618328`: **1,198 passed, 0 failed, 0 skipped**, exit code 0, uninterrupted (**9m36.2s**).
- `dart analyze`: exit code **0**, **0 errors, 0 warnings, 0 hints, 84 informational diagnostics**; no diagnostics were reported in the changed Dart files.
- Android debug APK built successfully with `flutter build apk --debug --no-pub` in **81.0 seconds** (Gradle task: **69.9 seconds**). Flutter reported upcoming support cutoffs for the existing Gradle **8.14.5**, Android Gradle Plugin **8.11.1**, and Kotlin **2.2.21** versions; this task made no build-tool changes.
- `git diff --check`: passed. Theme inventory and style ratchet were not applicable because no theme recipes or static styles changed.

The follow-up commit `af28641` only strengthened the Android Back widget test to use a real two-route test stack. After that test-only change, `weight_card_menu_anchor_test.dart` passed **8/8**; the route assertion verifies that the first Back dismisses the menu without popping Workout Session and that the second Back pops the test route. A direct isolated Pixel 7 check likewise showed the first Back keeping Workout Session open and the second returning to Train. No full-suite rerun was needed because production code was unchanged.

## Final consolidation: production-approved Classic interaction set

The user reviewed the three production changes together and approved them on **2026-09-29**, including the real-device WeightCard menu check. They are accepted Classic behavior, not open prototypes.

| Original plan candidate | Current status | Production behavior |
|---|---|---|
| Primary-action feedback | **KEEP CURRENT** | Existing Start/Finish action treatment remains. The expressive press treatment did not improve repeated use enough to justify changing it. |
| Train Overview/Plans tabs | **KEEP CURRENT** | Keep the compact two-tab control and its current location. |
| Exercise expansion | **PRODUCTION ADOPTED + USER APPROVED** | Classic workout sessions use WeightCard's controlled, quick-motion height reveal (about 180 ms), with no spring or bounce. Reduced motion is immediate; existing state ownership and final-set auto-collapse remain. |
| Set completion | **PRODUCTION ADOPTED + USER APPROVED** | The standard Material checkbox keeps its visual size and semantic completion green while providing a 48×48 dp hit target. Tested normal, compact, and 2× text layouts showed no target-caused row-height increase. |
| Anchored exercise menu | **PRODUCTION ADOPTED + USER APPROVED** | WeightCard uses standard `MenuAnchor`; action order and remove confirmation remain. Outside tap, Escape, and Android Back dismiss the menu; Back on the Pixel 7 was verified to leave the workout only on the next press. |
| Progress selection | **KEEP CURRENT** | Preserve the current six-range selector, chart interaction, and data-color ownership. No package alternative improved the full interaction enough to adopt. |
| Route transition | **KEEP CURRENT** | Retain platform Material route transitions; the scoped fade/slide did not improve orientation enough to replace them. |

Together these changes establish the Classic interaction rule: keep the static Tonos appearance and dense workout layout familiar; use short, local motion only when it clarifies a state change; respect reduced motion; enlarge the interactive area instead of the repeated control artwork; and use standard Material anchoring for actions already attached to a control. Completion green remains semantic. This is selective Classic modernization, not a separate M3E identity.

The package conclusion is final: **do not retain `material_3_expressive`**. `material_ui` remains the Material foundation, with Tonos-owned state, semantics, colors, and behavior.

Two separate, non-blocking observations remain documented: at approximately 2× text the visible fixed-width `Set N` label can ellipsize while its semantic label remains complete; and collapsing at an extreme scroll limit can shift the preceding content by about 15 dp as the viewport clamps. Neither was introduced by the approved target change or judged a reason to reopen the adopted interactions. The set-label issue remains a separate accessibility/responsive follow-up.

**Recommendation: PAUSE INTERACTION MODERNIZATION.** The three highest-value interaction candidates are complete and approved; the other four original candidates remain `KEEP CURRENT`, with no unresolved evidence justifying more interaction polish. Revisit the area only if a concrete usability problem appears.

### Broader Expressive design direction

This pause closes the original interaction-candidate list only. The broader question of a coherent Tonos Expressive visual system has been reopened as a separate research and planning effort. See [Tonos Expressive: Course-Correction Plan](tonos-expressive-course-correction-plan.md) for the current source-backed architecture recommendation and three-screen roadmap; this does not change the accepted Classic behavior recorded above.
