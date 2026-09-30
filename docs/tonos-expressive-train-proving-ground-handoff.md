# Tonos Expressive Train Proving Ground — Handoff

**Status: safe resumable qualification checkpoint; final device/user review remains pending (2026-09-30).** The user stopped the broader campaign to preserve usage. Section 21 is the latest continuation record. Sections 1–20 retain the implementation checkpoint and its historical evidence/procedure; their pending-device/full-suite statements describe that checkpoint. The recovered bounded combined run passed 163/163 tests, zero failures/skips, exit 0, before this qualification session. Resume the existing implementation rather than repeating the architecture audit.

## 1. Checkpoint summary

The repository contains a non-persisted Expressive preview of the production Train page and app shell. It uses the real Train Overview and Plans children, existing route callbacks, the production navigation, and a separate preview package/database. The preview can switch between Classic and Expressive, generated and curated palette treatments, light and dark, text scale, locale, reduced motion, and effects-off settings.

Train Overview contains exactly the existing seven-day focus card followed by the active presets card. Train Plans contains the active and archived plan sections and the existing premade, generated, and manual plan actions. No recommendations or placeholder workflow pages were added.

This is an implementation checkpoint, not final qualification. Profile performance, human motion review, final matched-focus recapture, the full Flutter suite, and child-route visual qualification remain pending.

## 2. Exact Git state

- Branch: `feature/classic-m3e`.
- Starting checkpoint: `0b7c4fd510a3ffa4f7dff270685445c066feec4b` (Review and expand Tonos Expressive plan).
- Implementation checkpoint: `9cd78807922e57602f4d9bbf32d417afc40386f9` — `Add isolated Tonos Expressive proving ground` (31 task-owned files).
- Documentation/evidence checkpoint: `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9` — `Record Expressive proving-ground checkpoint`.
- Qualification started with that documentation/evidence checkpoint synchronized with the live remote. Later qualification evidence may advance the branch; resolve current HEAD and remote with the commands below.
- Before publishing these commits the live remote was `0b7c4fd510a3ffa4f7dff270685445c066feec4b`; do not confuse that historical tip with the final pushed checkpoint.
- Upstream: `origin/feature/classic-m3e`.
- The latest qualification commit cannot embed its own SHA. Resolve the current values with:

~~~powershell
git status --short --branch
git log -5 --oneline --decorate
git log -1 --format='%H %s' -- docs/tonos-expressive-train-proving-ground-handoff.md
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
git ls-remote origin refs/heads/feature/classic-m3e
~~~

Do not repair or rewrite the malformed Codex checkpoint ref if Git reports it. Verify the push independently with the final `git ls-remote` result.

The implementation commit succeeded with exit 0 despite automatic Git maintenance reporting the known malformed checkpoint ref and a failed repack. The ref was left untouched.

## 3. Architecture implemented

- `AppThemeFamilyIdentity.expressivePreview` is a rendered identity, not a persisted family choice. The persisted Classic/Neo family enum and preferences remain unchanged.
- `TonosPreviewPresentation` is an in-memory root controller. It owns the preview look, palette treatment, brightness, locale and text-scale overrides, reduced-motion/effects settings, preview controls, and route-aware visibility. It does not read or write the persisted `ThemeProvider`.
- `buildTonosApp` has an optional preview seam. Its omitted and explicit-null paths were rendered against the same production tree and exercised in the root parity test.
- `lib/expressive_preview_main.dart` is the preview entry point. Preview controls are review-only and may be hidden at build time for captures.
- Android preview identity: `com.tonos.expressivepreview`. Preview database: `tonos_expressive_preview.db`. The Gradle guard requires matching preview/internal/database defines before assigning the preview application ID.
- Package-specific app storage isolates preview SharedPreferences and SQLite data. Preview presentation controls are in memory.
- The preview theme supplies 14 shared application token extensions: semantic colors, shape, surface, surface decoration, effects, motion, data visualization, progress, settings presentation, tutorial, media, flow, generation, and nutrition. `AppThemeIdentity` is the separate family marker.
- `ExpressivePreviewSafety.verifyBeforeDataAccess()` validates preview defines, non-internal flag, isolated database name, and runtime package ID before preferences or the app repository are loaded.
- `ExpressivePreviewFixtures` seeds and resets only its recorded preview fixture rows. Startup requires the identity guard, suppresses pre-verification diagnostic persistence, fails closed if verification fails or startup failure has already been shown, and renders failure UI in the initialized binding zone. The current architecture tests cover the guard policy.

## 4. Expressive visual system currently implemented

- The selected review treatment is **Curated**. It keeps the Deep Purple seed and Material 3 light/dark `ColorScheme.fromSeed` behavior while mapping panels and cards to calmer surface-container roles. Generated remains selectable for comparison.
- Curated panel/card roles use `surfaceContainerLow`, `surfaceContainer`, and `surfaceContainerHigh` for panels, cards, plan groups, sheets, and dialogs. Classic progress colors and shared effects/decorations remain in use.
- Shapes: card and plan-card radius 18 dp; Train tab frame radius 16 dp; Train tab button radius 12 dp. Start uses 22 dp resting outer corners and 14 dp pressed corners.
- Typography uses the existing Material 3 scale. Start uses `titleMedium` at weight 600; Optimize uses `bodyMedium` at weight 600; Train tabs use `labelLarge`; bottom-navigation labels use `labelSmall` with the inherited default style as fallback. Labels and numbers do not spring.
- Start remains the real `InkWell` and invokes the production callback immediately. Its helper changes only the clipped outer shape; it does not scale the label or change layout, hit bounds, keyboard activation, or semantics ownership. Optimize keeps its independent right-side corner recipe and real settings control.
- The horizontal Start/Optimize bar is 64 dp high at ordinary text scale. Expressive reflows vertically when text scale exceeds 1.15 or the viewport is narrower than 380 dp. Vertical segments use measured scaled labels, a 59.5 dp minimum per segment, and a 1 dp divider.
- Train tabs use the secondary-container selected fill on the panel surface. The bottom bar uses secondary-container selected fill, `onSecondaryContainer` selected icon, `onSurface` selected label, `onSurfaceVariant` unselected content, and `surfaceContainerLow` behind the bar.
- Current helper values: selection `mass=1, stiffness=650, damping ratio=0.8`, with travel bounded to 0.06 slot beyond endpoints; primary press recovery `mass=1, stiffness=800, damping ratio=0.72`, with shape overshoot bounded by 0.08 progress. These are implementation values, not a completed motion-tuning result. No human-speed bounce review has qualified them.
- Both helpers snap when `MediaQuery.disableAnimations` is true or their `TickerMode` is disabled. Preview reduced motion, effects-off, and OS reduced animation feed the root media setting. Callback and final selection state remain immediate.

## 5. Train Overview status

`_OverviewTab` in `lib/screens/exercise/train_page.dart` contains only `SevenDayFocusCard` and `_ActivePresetsCard`, in that order. Production focus-card navigation and preset-selection/start actions remain.

The focused Train presentation test covers loaded content, loading, repository failure, missing profile, empty history/empty plans, stale selected preset, archived plans, busy Optimize, and the horizontal action bar's RTL corners. The root overlay test covers real Start/Optimize behavior and dialog/snackbar semantics. Pixel captures show real seeded Overview content, but do not qualify every state on device.

## 6. Train Plans status

Plans uses the real active and archived plan sections. Existing actions remain: open a plan, browse premade plans, generate custom plans, and create a manual plan. No fake route screen or recommended-plan section was introduced.

Focused Train tests cover active/archive lists, empty active/archive sections, missing profile, stale selected-plan IDs, loading, repository failure, and Optimize busy state. B's last live fixture report had 300 eligible exercise definitions, 8 plans, and 3 sessions.

Light and dark top/lower Plans captures are present. Orange plan-name contrast in light mode is a known pre-existing issue and was not changed.

## 7. Shell and navigation status

- Production default: five visible destinations in order, Train, Catalog, Logbook, Progress, Profile. Train is initially selected. Measurements and Trends is the internal owner name for the Progress destination, not its visible label.
- In the ordinary-text harness the default Classic and Expressive bars both measured 58 dp, excluding system bottom inset. Expressive Train tabs use a 56 dp frame in a 64 dp AppBar, versus Classic's 44 dp frame in a 56 dp AppBar: the header delta is 8 dp, not two additive increases. The compact French 2x case measured a 96 dp AppBar.
- The main shell retains page widgets in its indexed stack. Root parity coverage exercises Train → Catalog → Train and confirms Train Plans selection remains intact.
- Configured navigation can contain 11 destinations. When the row exceeds the viewport, it scrolls horizontally with a visible scrollbar; selecting a destination scrolls it into view. The selection indicator follows RTL direction and snaps if item count/order changes.
- Each destination remains its own hit-target and semantics owner. The decorative selection fill is pointer-ignored and excluded from semantics.
- The bounded nav-height issue is fixed: the five-destination bar measures 72 dp at 2x in the 320 dp viewport and Pixel logical-width scenarios. Tallest rendered labels are 32 dp; the height assertion is 32 dp icon area + 32 dp label + 8 dp vertical space.
- The earlier 104 dp value came from a measurement-style/constraint mismatch. The fix measures labels using the same available width as the actual renderer.
- The earlier 11-destination 136 dp figure was measured before the correction. The post-fix 11-destination light/dark 1x/2x matrix passes, but exact post-fix height was not remeasured. Keep **OPEN TUNING ITEM — NAVIGATION LARGE-TEXT DENSITY** and do not start another long investigation.

## 8. Sandbox and exact runner commands

Pinned toolchain:

- Flutter: `E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat` (Flutter 3.47.5).
- Dart: `E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin\dart.exe` (Dart 3.13.4).
- Preview app entry: `lib/expressive_preview_main.dart`.
- Required defines: `TONOS_EXPRESSIVE_PREVIEW=true`, `TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true`, `TONOS_ANDROID_INTERNAL_BUILD=false`, `TONOS_DATABASE_NAME=tonos_expressive_preview.db`, and `TONOS_PREVIEW_SHOW_CONTROLS=true`.

Canonical build-only runner (validates tool versions, locked dependencies, build flags, and APK application ID; it does not install or launch):

~~~powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_expressive_preview.ps1 -BuildMode debug
~~~

After a fresh runner build and its manifest/hash checks, the next qualification session can install and launch only the preview package with:

~~~powershell
& 'E:\Android\Sdk\platform-tools\adb.exe' devices
& 'E:\Android\Sdk\platform-tools\adb.exe' -s 28021FDH200228 install -r .\build\app\outputs\flutter-apk\app-debug.apk
& 'E:\Android\Sdk\platform-tools\adb.exe' -s 28021FDH200228 shell monkey -p com.tonos.expressivepreview -c android.intent.category.LAUNCHER 1
~~~

These are continuation commands, not actions performed during checkpoint recovery. Use `app-profile.apk` after a canonical profile build; do not install either stale recorded artifact.

Use `-BuildMode profile` in the next qualification session. The startup guard and bounded gates are now complete. Verify `com.tonos.expressivepreview` in the APK manifest and record SHA-256 before install. The previous verified preview installation used a debug APK, not the new profile integration-test APK.

In the preview review sheet, `Reset review controls` restores only in-memory settings. `Reset sandbox fixtures` invokes the preview-only callback for the recorded fixture set; overlapping resets are refused and the action is disabled while running. Finishing sessions or pending progression updates block reset. Do not reset fixtures while exercising a live workout session.

## 9. Pixel 7 status

- Device: Pixel 7, serial `28021FDH200228`, Android 16 / API 36, 1080×2400 physical pixels, 420 dpi (2.625 device-pixel ratio).
- At the last read-only display check, active rendering was 60 Hz; 90 Hz is supported but was not active. Use the runtime `PlatformDispatcher` refresh rate in the profile harness; do not assume 90 Hz. Thermal/power state was not captured.
- The last verified preview update used debug APK SHA-256 `6942579267B697B2EE89F49F4E921A77322A168C7EC359A051B6B3A904E64CC3`. Package metadata still identifies the preview install; on-device APK bytes were not independently pulled and rehashed. Earlier `0EA13DFF…` debug artifact was superseded. The installed artifact predates the navigation measurement correction and final startup diagnostics guard.
- A later profile integration-test APK was built and manifest-verified, but **never installed**: SHA-256 `D404DFBB2022FE056611F756BDB37B08C831862EDD91824CEAC2021FFEE5CE08`, 131,700,861 bytes, package `com.tonos.expressivepreview`. It predates the navigation measurement correction and final startup diagnostics guard, so it is stale for final qualification.
- B verified live seeded data and captured static screenshots. Last reported UI state: Generated/Light, lower Plans area. No interaction video was captured. The existing comparison board shows a Profile-side focus/hover highlight in Classic and Generated that is absent in Curated; clear focus and pointer state before any replacement comparison. Treat that mismatch as capture state, not a palette result.
- Normal and internal Tonos packages were present on the device, but this task only updated/inspected the separate preview package. Their application data was not touched.

## 10. Test results

### Passed at the recovered implementation checkpoint (historical), 2026-09-30

| Test group | Result |
|---|---|
| Overlay/root | 13/13. Null/default root parity, shell state, controls, dialogs/snackbars, Back/focus, resize/reduced motion. |
| Train presentation / navigation | 8/8 + 6/6. Five-item compact and Pixel logical-width cases at 2x text plus 11-item light/dark matrix. Pixel DPR is 2.625; text scale here is 2x. |
| Architecture / Workout compatibility / chart resize | 11/11 + 3/3 + 1/1. |
| Motion / accessibility | 12/12 + 1/1. |
| Inventory contract / ratchet CLI / ratchet / source rules | 50/50 + 3/3 + 14/14 + 4/4. |
| Shared Train tabs / navigation / focus presentation | 8/8 + 11/11 + 1/1. |
| Family / selector / debug-family control | 4/4 + 11/11 + 2/2. |
| Aggregate | **163 passed, 0 failed, 0 skipped; exit 0; 140.6614 seconds wall time.** Reporter terminal success at 131.297 seconds; hidden suite-load events are excluded from the test total. |
| Targeted analyzer | 0 errors, 0 warnings, 4 pre-existing infos, exit 0; section 11. |
| Inventory / ratchet | 294 files, 2,294 candidates, 130 allowlisted, 2,164 migrated, 0 pending/unassigned. Enforcement exit 0: 18 protected files, 139 approvals, 137 unique hashes, 156 occurrences. |

The exact bounded invocation used Flutter 3.47.5, bundled Dart 3.13.4 on PATH, default concurrency, and normal `C:\Users\talh7\AppData\Local\Temp` TEMP/TMP. JSON log: `C:\Users\talh7\AppData\Local\Temp\tonos-expressive-recovery-current.jsonl` (local diagnostic evidence, not a repository artifact).

~~~powershell
$env:PATH = 'E:\tools\flutter_sdks\3.47.5\flutter\bin;E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin;' + $env:PATH
$checkpointTests = @(
  'test/expressive_accessibility_test.dart',
  'test/expressive_motion_test.dart',
  'test/expressive_navigation_presentation_test.dart',
  'test/expressive_overlay_qualification_test.dart',
  'test/expressive_preview_architecture_test.dart',
  'test/expressive_preview_workout_compatibility_test.dart',
  'test/expressive_train_presentation_test.dart',
  'test/workout_metric_chart_preview_resize_test.dart',
  'test/theme/theme_style_inventory_contract_test.dart',
  'test/theme/theme_style_ratchet_cli_test.dart',
  'test/theme/theme_style_ratchet_test.dart',
  'test/theme/theme_style_inventory_source_rules_test.dart',
  'test/theme/widgets/tonos_train_tabs_test.dart',
  'test/theme/widgets/tonos_bottom_navigation_bar_test.dart',
  'test/theme/widgets/seven_day_focus_presentation_test.dart',
  'test/theme/app_theme_family_test.dart',
  'test/theme/theme_family_selector_test.dart',
  'test/theme/debug_theme_family_control_test.dart'
)
& 'E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat' test --no-pub --reporter json @checkpointTests > "$env:TEMP\tonos-expressive-recovery-current.jsonl"
$LASTEXITCODE
~~~

### Failed, then corrected

One combined run of the eight focused test files exited 1 because the first analyzer modernization compared Flutter's `Tristate` selected flag with `bool`. The fix preserves the old `hasFlag` contract (only `Tristate.isTrue` is selected) and keeps `isButton` as a bool. The overlay file then passed separately at 13/13. Do **not** report the mixed invocation as a clean combined aggregate.

The interrupted session's earlier bounded run reported 159 passed, 4 failed, 0 skipped. All four failures were stale inventory/ratchet fixture assertions: Start/Optimize action findings 7→18, bottom-navigation findings 4→6, Train-tab findings 4→6, and exact navigation fingerprint occurrence counts (including fingerprints occurring three times rather than universally once). Only the fixture expectations were corrected in recovery; ratchet logic and the allowlist were not weakened. Corrected contracts passed 53/53, a recovered clean aggregate passed 163/163, and the fresh current aggregate above independently passed 163/163 with exit 0.

Earlier milestones (historical, superseded by the current aggregate): architecture 8/8 before later startup-policy tests, compatibility/architecture/chart 14/14, and Classic/Neo presentation 34/34. Do not add these overlapping milestones to the current total.

### Pending at the implementation checkpoint (historical)

- Full Flutter regression suite: not run.
- Profile integration driver/device test: not run.
- Final video/human-speed spring review: not run.

## 11. Analyzer

- Current pinned `dart analyze` on all 26 task-owned Dart source/test files (including the integration harness and both contract tests): **exit 0, 0 errors, 0 warnings, 4 informational notices**. Three are existing `TickerMode.of` deprecations in Train; one is the existing braces lint in WeightCard. Their source constructs were verified present in starting HEAD. No unrelated cleanup was performed.
- Historical: the motion/accessibility/overlay/harness subset had no issues; earlier repository-wide analysis had 93 informational notices and no errors/warnings; earlier analysis including reference Classic/Neo regression files had 11 informational deprecations. These are not current repository-wide claims. Full qualification may repeat repository-wide analysis.
- Use the pinned Dart executable above. Do not infer a clean full analysis from an earlier result.

## 12. Inventory and ratchet

Current direct gates: 294 inventory files, 2,294 candidates, 0 pending/unassigned findings. Ratchet enforcement passed with 18 files, 139 approvals, 137 unique hashes, and 156 occurrences. Both tools exited 0. The exact contract corrections are described in section 10; all 53 inventory-contract/CLI tests now pass. Affected records: `docs/theme-style-inventory.md`, `docs/theme-style-inventory.json`, `docs/theme-style-ratchet.json`, `test/theme/theme_style_inventory_contract_test.dart`, and `test/theme/theme_style_ratchet_cli_test.dart`.

`git diff --check` exited 0 during recovery and is checked again before committing the documentation. Preserve baseline files; do not run cleanup commands.

## 13. Classic and Neo parity

The preview uses a separate rendered identity rather than a stored third family. No stored family choice, preference key, or Classic/Neo color scheme was added. Root default/null tests rendered the production shell under normal persisted Classic state and found parity between omitted and explicit-null preview presentation.

The two Workout reveal gates are the intended family-compatibility changes: `session_screen.dart` and `weight_card.dart` explicitly opt in with `usesExpressivePresentation`, retain Classic's existing 180 ms behavior, and leave Neo out of that gate. Focused Workout compatibility tests cover those cases. A previously reported targeted Classic/Neo presentation set passed 34/34; retain its original log rather than merging that historical count into a new aggregate.

## 14. Workout compatibility

No Workout visual redesign was made. The scope preserves the existing session and weight-card presentation, adding only explicit Expressive identity opt-in for the existing controlled reveal. The focused regression group proves:

- controlled `WeightCard` reveal remains 180 ms when motion is enabled;
- collapse and menu actions meet 48×48 dp targets, and checkboxes measure 48×48 dp;
- the real `MenuAnchor` opens “Make change set” and closes on Back;
- non-final set completion keeps the card expanded, final-set completion auto-collapses it, and reopening retains completed checks.

The device integration harness contains a real Start → Session path and this production Workout compatibility flow, but the harness has not run on Pixel.

## 15. Known issues and open questions

- **BLOCKER — NONE FOR CHECKPOINT:** all minimum bounded gates are green. Full qualification remains deferred; this is not family adoption.
- **OPEN TUNING ITEM — NAVIGATION LARGE-TEXT DENSITY:** five destinations at 2x are corrected to 72 dp. Exact post-fix height for 11 destinations was not remeasured; focused matrix cases passed.
- **PRE-EXISTING:** orange plan-name contrast in light mode remains unchanged.
- **PRE-EXISTING SDK CASE:** Flutter 3.47.5 can throw `RenderAnimatedSize` during the Classic initial Train build when the hidden Progress disclosure uses `AnimatedCrossFade` with zero duration under inactive `TickerMode` and reduced animations. Recorded owner: `_AdditionalDetailsDropdown` → `AnimatedCrossFade` → `AnimatedSize` in `lib/widgets/workout_metric_chart_card.dart`. This was reproduced in Classic before the shim. Do not claim Classic is error-free for this exact SDK state.
- **DEFERRED QUALIFICATION:** no human-speed review of current spring values; no profile frame-budget data; no final focus-matched screenshot boards; no full Flutter suite; no thermal/power capture.
- **DEFERRED VISUAL SCOPE:** child routes are real production pages that inherit the Expressive root theme and ordinary Tonos/Material widgets; their layouts were not redesigned, and their visual quality has not been qualified. Premade, generated-plan QA, manual-plan detail, analytics, settings, and Session remain outside the visual qualification.
- The existing board's Profile-side focus/hover mismatch remains unqualified until recapture with focus and pointer state cleared.
- **DEFERRED DEVICE MATRIX:** landscape and explicit system-inset/keyboard-inset qualification were not completed. Do not infer device coverage from widget resize cases.

## 16. Narrow compatibility fix

The `workout_metric_chart_card.dart` branch is limited to Expressive preview identity **and** inactive `TickerMode` **and** `MediaQuery.disableAnimations == true`. It renders the existing expanded/collapsed disclosure state statically so Flutter 3.47.5 does not start `AnimatedSize` with zero duration while its render object is inactive. It preserves disclosure state and active 180 ms crossfade. Classic, Neo, generic Material, and active animated paths are unchanged. This is a narrow framework-compatibility fallback, not a Progress redesign.

Coverage is in `test/workout_metric_chart_preview_resize_test.dart` and the explicit Classic baseline classifier in `test/expressive_overlay_qualification_test.dart`. The latter records the Classic SDK case and keeps the Expressive no-layout-error assertion hard.

## 17. Task-owned file map

### Preview architecture and safety

- `android/app/build.gradle.kts` — validates preview build flags and assigns the isolated preview application ID.
- `lib/main.dart` — optional preview root seam, production tree, preview controls, and verified startup diagnostics/fail-closed guard.
- `lib/expressive_preview_main.dart` — preview-only entry point.
- `lib/dev/expressive_preview_fixtures.dart` — deterministic isolated exercise/profile/plan/session fixtures.
- `lib/dev/expressive_preview_safety.dart` — compile-time and runtime package/database guard.
- `lib/theme/theme_extensions.dart` — explicit preview identity and `usesExpressivePresentation` helpers.
- `lib/theme/expressive_theme.dart` — generated and curated light/dark recipes.
- `lib/theme/tonos_preview_presentation.dart` — in-memory review controls, root route observation, and reset behavior.
- `tools/run_expressive_preview.ps1` — pinned no-pub build-only runner with APK manifest verification.

### Train, navigation, motion, and compatibility

- `lib/screens/exercise/train_page.dart` — Expressive Overview/Plans presentation and Start/Optimize bar using production callbacks.
- `lib/widgets/seven_day_focus_card.dart` — preview-only surface/type emphasis, with existing heatmap and data ownership retained.
- `lib/widgets/tonos_train_tabs.dart` — family-aware Overview/Plans selector and springing selected fill.
- `lib/widgets/tonos_bottom_navigation_bar.dart` — Expressive five/custom destination shell, selected fill, semantic actions, and large-text measurement.
- `lib/theme/widgets/tonos_expressive_motion.dart` — selection spring and pointer-only Start shape response.
- `lib/screens/exercise/session_screen.dart` — explicit Expressive identity opt-in for existing reveal behavior.
- `lib/widgets/weight_card.dart` — explicit Expressive identity opt-in for the existing 180 ms reveal.
- `lib/widgets/workout_metric_chart_card.dart` — inactive/reduced-motion Expressive static disclosure fallback.

### Tests and device harness

- `test/expressive_motion_test.dart` — retargeting, RTL, reduced motion, pointer cancellation, disabled action, and disposal.
- `test/expressive_accessibility_test.dart` — selected-state semantics and 48 dp Train-tab targets at 2x.
- `test/expressive_overlay_qualification_test.dart` — root parity, overlays, focus/semantics, resize, and reduced-motion cases.
- `test/expressive_navigation_presentation_test.dart` — five-destination and configurable 11-destination layout matrix.
- `test/expressive_train_presentation_test.dart` — content/actions, loading/error/empty/profile/RTL/busy states.
- `test/expressive_preview_architecture_test.dart` — preview identity, fixtures, root, and reset architecture.
- `test/expressive_preview_workout_compatibility_test.dart` — Classic/Expressive/Neo reveal compatibility and 180 ms behavior.
- `test/workout_metric_chart_preview_resize_test.dart` — retained disclosure state and active-vs-inactive transitions.
- `integration_test/expressive_preview_device_test.dart` — profile matched frame timing and real route/Workout harness; not yet run on device.
- `test/theme/theme_style_inventory_contract_test.dart` and `test/theme/theme_style_ratchet_cli_test.dart` — inventory/ratchet enforcement.

### Inventory and visual evidence

- `docs/theme-style-inventory.md`, `docs/theme-style-inventory.json`, and `docs/theme-style-ratchet.json` — inventory and ratchet records.
- `docs/proposals/tonos-expressive-train-proving-ground/static/` — retained raw captures and boards:
  `classic-overview-light.png`, `classic-overview-dark.png`, `classic-plans-light-top.png`, `classic-plans-dark-top.png`;
  `expressive-generated-overview-light.png`, `expressive-generated-overview-dark.png`, `expressive-generated-plans-light-top.png`, `expressive-generated-plans-light-lower.png`, `expressive-generated-plans-dark-top.png`;
  `expressive-curated-overview-light.png`, `expressive-curated-overview-dark.png`, `expressive-curated-plans-light-top.png`, `expressive-curated-plans-light-lower.png`, `expressive-curated-plans-dark-top.png`;
  `board-overview-light.png`, `board-overview-dark.png`, `board-plans-light-top.png`, `board-plans-light-lower.png`, `board-plans-dark-top.png`.
- `docs/tonos-expressive-train-proving-ground-results.md` — concise evidence/status summary.
- `docs/tonos-expressive-train-proving-ground-handoff.md` — this continuation procedure.

## 18. Pre-existing user work and protected hashes

The lead verified the original 15 tracked files remained byte-identical to saved baseline hashes at two checks this resumed turn. The current SHA-256 table below was read from the workspace for this handoff and matches those protected originals. These files do not overlap authorized task-owned source changes.

| Protected tracked file | Current SHA-256 (matches saved original) |
|---|---|
| `lib/screens/exercise/auto_preset_flow_screen.dart` | `C37DEBC9F57E24F1342DDD28353521D16328E3429665AF8BCFF6DBDA2583E053` |
| `lib/screens/exercise/exercise_catalog_page.dart` | `A575D8C7996140D9DEFA7C89E1230492CBDB8C886C2D39B48F74C835A1B6295E` |
| `lib/screens/nutrition/food_customization_page.dart` | `7B9D05B1FA771EA99B3DF15C43D1F3B5CC01047D8070448CF1578D31D20AAC28` |
| `lib/screens/onboarding_flow.dart` | `5EEB88D897ABBD1CF54C7BAA57754A311C4CE1A30EBB1C7237841B6D04945CF7` |
| `lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart` | `2A1AB878CAE167A6C0CAC24D0A7A6474B399DF317E7AAE4B4FE4DF934336B852` |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | `36EAF079013894870323CB8163E09916DDA61E46F0CFC2C7A312EDD822382941` |
| `lib/screens/profile/settings/user_information_settings_page.dart` | `11A7739C30C130FBFDA84B42375DCE0E70D50C3AEFCF16975733851D49C660DE` |
| `lib/screens/profile/settings/volume_boundaries_screen.dart` | `E4863A139A2A82D688AF5CECBFA3C0CB77B6A3B7FEFBB02C144EFF22DB0FD124` |
| `lib/services/active_plan_store.dart` | `5C764666BD64FCEFFA1994EE3BC24F0406FC1815EBFF79C987ECDD1BCA2D0D15` |
| `lib/services/diagnostics_service.dart` | `F75DABC17F0B610E021A4B3EC3062E044E593475F13DCB44B2482A5D32728B8B` |
| `lib/theme/neo_brutalism_pilot_gallery.dart` | `6107CBA564B8E0851CBA40877402861734B959732182E5D8DD74EB16442AF617` |
| `lib/theme/theme_lab_page.dart` | `D181EE2AAB794BB1599A78068C13D55841209A9790BC79D23E810DB8D3103E82` |
| `lib/widgets/health_trends_section.dart` | `41605E8E3B80E6BD6E717A6EFFA6E5ACEC23C068184F026DE98020591DDA3B43` |
| `lib/widgets/stretch_search_dialog.dart` | `991D7243015A7E72C865EEFD4D41CAF46B1FD21538B127FB762C8AF4B12A0910` |
| `lib/widgets/workout_dashboard.dart` | `CD686E5BF3309CBC6C92F1E0DF9992B3C47598434656099A31394A2784CC8D31` |

Preserve these five original untracked groups and do not add or clean them:

1. `android/build/`
2. `docs/proposals/classic-m3e-interaction-lab/pixel-7-standard-lab.png`
3. `flutter_06.png`
4. `incoming/`
5. `tmp/`

`android/.kotlin/` was previously observed as a generated build cache and is absent from the recovered status. If it reappears, exclude it from commits and do not clean it. Expressive preview sources/tests and `docs/proposals/tonos-expressive-train-proving-ground/` are task-owned. Stage explicit paths; never `git add .` or `git add -A`.

## 19. Qualification procedure from the implementation checkpoint

The checkpoint recovery completes the exact fixture corrections, clean bounded rerun, and task-owned commit/push. The next GPT-6.1 Sol High session should resume qualification of the existing Train + shell proving ground; do not redesign it first or repeat the architecture audit.

1. Read this handoff and `docs/tonos-expressive-train-proving-ground-results.md`. Verify branch, final HEAD, upstream remote tip, `git status --short --branch`, and the protected 15 hashes. The checkpoint should already be committed and pushed; do not recommit it.
2. Complete pending profile qualification from current source: rebuild the profile integration APK, verify its fresh hash and `com.tonos.expressivepreview` manifest before install, then run the exact Pixel driver command below. Do not install either stale recorded APK.
3. Run the full Flutter regression suite when resuming qualification, then review the result without widening into Workout/Progress redesign.
4. Capture matched Classic/Curated screens with focus and pointer state cleared, record actual display refresh/thermal/power state, and review normal-speed Start→Session behavior for visible spring response. Update the handoff with exact outputs.
5. Revisit the 11-destination 2x large-text density tradeoff using the post-fix rendered measurement and decide whether it needs user tuning. Child-route visual qualification remains a separate later phase.

The existing profile harness uses the hydrated preview fixture (300 eligible exercise definitions, 8 plans, 3 sessions), alternates Classic/Expressive four times, excludes warm-up, measures six interaction cycles per phase, and reports build/raster p50/p90/p95/p99/max, frame-budget buckets, and slow-frame clusters. It includes actual production route/Workout smoke paths outside timing.

**Rebuild the integration-test profile APK in the next qualification session.** The bounded source gates have passed. These are the exact current build/drive arguments; rebuild first because the existing profile APK predates the final startup guard:

~~~powershell
$env:Path = 'E:\tools\flutter_sdks\3.47.5\flutter\bin;E:\tools\flutter_sdks\3.47.5\flutter\bin\cache\dart-sdk\bin;' + $env:Path
$env:TONOS_ANDROID_INTERNAL_BUILD = 'false'
$env:TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD = 'true'
& 'E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat' build apk --profile --no-pub --target integration_test\expressive_preview_device_test.dart --dart-define=TONOS_EXPRESSIVE_PREVIEW=true --dart-define=TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true --dart-define=TONOS_ANDROID_INTERNAL_BUILD=false --dart-define=TONOS_DATABASE_NAME=tonos_expressive_preview.db --dart-define=TONOS_PREVIEW_SHOW_CONTROLS=true
~~~

Before any install, inspect `build\app\outputs\flutter-apk\app-profile.apk` with `E:\Android\Sdk\build-tools\36.0.0\aapt.exe dump badging` and require `package: name='com.tonos.expressivepreview'`; record its fresh SHA-256. Then drive that exact verified binary:

~~~powershell
& 'E:\tools\flutter_sdks\3.47.5\flutter\bin\flutter.bat' drive --no-pub --profile --device-id 28021FDH200228 --target integration_test\expressive_preview_device_test.dart --driver test_driver\integration_test.dart --use-application-binary build\app\outputs\flutter-apk\app-profile.apk --keep-app-running
~~~

The integration build and canonical interactive app build both write `app-profile.apk`; finish the driver run before overwriting it. For the final interactive preview, rebuild with `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_expressive_preview.ps1 -BuildMode profile`, verify manifest/hash again, then install only the verified preview package and launch `com.tonos.expressivepreview`. The runner itself never installs.

## 20. Do not do

- Do not add or persist a third theme family.
- Do not redesign Workout or Progress.
- Do not fix orange plan-name contrast as part of this checkpoint.
- Do not merge to `master`.
- Do not clean, overwrite, or stage unrelated user work; do not touch the protected 15 files.
- Do not clean `android/build/`, `android/.kotlin/`, or the unrelated untracked groups.
- Do not touch or repair the malformed Codex checkpoint ref.
- Do not treat the uninstalled profile APK or debug timing as profile qualification.
- Do not report a pending gate as passed.

## 21. Qualification continuation record — current authority

This session began with `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9` equal to the live remote. The production proving ground, palettes, springs, persistence, dependencies, and SDK remain unchanged. Only qualification tests/harnesses, evidence, and documentation are being updated.

- Latest pinned repository analysis: **0 errors, 0 warnings, 84 infos, exit 0**, **49.135 seconds**, after the outer-target harness correction. The subsequent test-only bounded smoke selector receives scoped analysis/build verification. No normal-suite or production inputs changed after the clean full run.
- Initial uninterrupted full suite: **1,254 passed, 1 failed, 0 skipped, exit 1**, 834.154 seconds. The sole failure was a stale source-text contract in `test/theme/app_theme_tokens_test.dart`. Its corrected matcher proves the three Expressive `card` / retained `panelRaised` choices; other ownership checks remain. Focused rerun: **18/18**, exit 0.
- Final uninterrupted full suite: **1,255 passed, 0 failed, 0 skipped, exit 0**, **1,274.075 seconds**. Default concurrency, `--no-pub`, normal C: TEMP/TMP, source frozen; 239 hidden suite-load events excluded. Logs/metadata use the distinct `full-flutter-test-postfix-*` filenames. This is the current full-suite result.
- Direct inventory/ratchet: **0 pending/unassigned**, exit 0; exact counts remain 294 files / 2,294 candidates and 18 files / 139 approvals / 137 hashes / 156 occurrences.
- Accessibility: **28 existing focused tests + 1 new stress test**, passing in separate runs, exit 0. The new test uses 320 dp, 11 long French labels, RTL layout direction, semantics/hit checks, and a deterministic nonlinear scaler. Actual Android OS scaling is a separate pending device gate.
- Initial profile driver collected all idle/timing batches, then exited 1 at a non-hit-testable ongoing-session menu tap in a separate functional smoke. The second driver passed that route after a narrow settle/hit-test correction, collected all timing phases again, then exited 1 at a geometry assertion measuring the inner 40 dp Tooltip/Material. That finder does not measure the padded outer `IconButton` target. The harness-only correction now selects the outer `IconButton`, retains ≥48 dp checks, and probes outer edges; it also settles both returned-home cleanup paths. Neither complete timing driver is an end-to-end pass.
- To respect the course change, `TONOS_PREVIEW_DEVICE_SMOKE_ONLY=true` skips all warm-up/timing loops and unrelated functional routes, running only the existing production Workout compatibility helper. It is a test-only compile selector, default false, with separate `expressivePreviewDeviceSmoke` reporting and `timingsMeasured:false`. Scoped analyzer/build verification passed. The bounded Pixel attempt stalled after fixture setup for over five minutes without reaching geometry output or reporting a Flutter exception in inspected logcat; it was interrupted. The exact cause and outer-target/edge-hit proof remain **PENDING**. Do not invent a device pass or treat this as a production 40 dp target defect.
- Preserved second-run profile context: Pixel `28021FDH200228`, 60 Hz / 16,667 µs; no video or host-suite overlap. Four quiet idle observations had zero frame timings; each observation includes a three-second action and two-second flush. Settled raster exceedances: Classic 326/915 (35.63%), Expressive 330/911 (36.22%). Rapid build exceedances at the synthetic 80 ms cadence: Classic 34/212 (16.04%), Expressive 50/212 (23.58%). The complete matched p95/count/cluster table and raw logs are in Results. These are frame-cost observations from a failed later functional attempt, not zero-jank, physical-latency, or faster-Expressive evidence.
- Final matched-focus comparisons, all five requested motion clips, native Android OS large text/keyboard/Back/TalkBack checks, and the canonical interactive review build remain **PENDING**. Historical static captures contain a Profile-focus mismatch and DEBUG ribbon. The currently installed sandbox artifact is an integration-test profile APK, not a manual-review-ready canonical app. See the device note for exact APK identity/hash and interrupted-run state.
- C: storage fell to 0.35 GiB during overlapping validation/build work. No files were cleaned and TEMP/TMP were not redirected. The user freed space; the full suite finished uninterrupted with exit 0. C: measured 2.52 GiB after completion. All second-run timing windows began after the host suite finished; recheck headroom before additional profile/canonical builds.
- The 15 protected user-file hashes still match the saved baseline. Unrelated untracked groups remain excluded from task staging/cleanup.

Current details: [results](tonos-expressive-train-proving-ground-results.md), [host validation](proposals/tonos-expressive-train-proving-ground/qualification/validation/validation-summary.md), [device qualification](proposals/tonos-expressive-train-proving-ground/qualification/device-qualification.md), [accessibility scope](proposals/tonos-expressive-train-proving-ground/qualification/accessibility-review.md), and [short user-review checklist](proposals/tonos-expressive-train-proving-ground/qualification/manual-review.md).

The user changed the stop condition to a resumable checkpoint. The bounded source correction and its scoped analyzer/build verification are complete; the stalled device proof is saved as pending. Preserve already-collected timings, commit/push qualification-owned changes, then stop. No further full suite, complete timing matrix, canonical interactive build, capture campaign, or lengthy native-accessibility campaign is started in this checkpoint pass.

Resume from this qualification checkpoint. Complete only any remaining Pixel evidence/native accessibility checks, then present the existing Train + shell Expressive proving ground to the user for keep/tune/reject feedback. Do not expand Expressive to another screen before user review.
