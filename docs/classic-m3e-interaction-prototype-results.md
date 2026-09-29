# Classic interaction prototype results

**Evaluation date:** 2026-09-28
**Branch:** `feature/classic-m3e`
**Decision:** **NO — standard Material/Tonos is sufficient.**

Classic remains the visual and interaction baseline. The prototypes tested whether a package-backed Material 3 Expressive component improves real Tonos tasks enough to justify another permanent dependency. The package was useful for comparison, but none of the tested results requires it. A small number of behaviors are worth keeping as standard Material/Tonos implementation candidates.

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

## Decision boundary

This artifact recommends only the small standard Material/Tonos candidates above. It does **not** approve production adoption or change the Classic/Neo theme architecture. The next work, if approved separately, is to productionize one candidate at a time behind its existing Tonos component boundary, beginning with controlled exercise expansion and its auto-collapse/reduced-motion behavior.
