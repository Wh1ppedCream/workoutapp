# Tonos Expressive Responsive Validation Evidence

## Current-state follow-up — 2026-10-12

No device, emulator, screenshot, or responsive-matrix run followed the latest
Onboarding source refinement. The latest focused result of 67 passing tests
across seven files is not a new responsive qualification result. The sections
below are dated evidence records, not fresh captures. The last physical
evidence remains the Pixel 7 captures listed below and in
[`current-source-snapshot.md`](current-source-snapshot.md); the current dirty
source tree has no matching build/capture. No new claims are made for 320 dp,
tablet, landscape, or 1×/1.15×/1.5×/2× text-scale behavior.

This note distinguishes the initial screenshot-refresh evidence from the later remediation candidate's captures and focused tests. It records only viewports/text scales actually represented; it does not approve routes or claim that an unrun matrix passed.

## Initial screenshot-refresh candidate and provenance

- Repository checkpoint: `9ac12f9` (`checkpoint: preserve Tonos Expressive visual review and audit baseline`).
- Evidence build fingerprint: `e87b4eee03832c8036a89ad6ce1337d3ec8c68c8adb2348ac8d42e7aeb950073`.
- Isolated preview package: `com.tonos.expressivepreview`.
- Device: Pixel 7, `28021FDH200228`, 1080×2400 physical pixels, approximately 411×914 logical dp at 420 dpi.
- Evidence directory: `docs/proposals/tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/`.
- The evidence index reports 92 verified screenshots: 47 light and 45 dark. These are route/state captures, not a route-wide responsive qualification matrix.
- New captures have a thin lime-green perimeter whose source is unconfirmed. Images were left unaltered; do not interpret that perimeter as application styling.

## Responsive captures currently available

### Dashboard

- Normal-scale light/dark Dashboard references are in `dashboard/dashboard-home-light.png` and `dashboard/dashboard-home-dark.png`.
- One large-text stress capture is available at `dashboard/dashboard-2x-dark-boundary.png`. Its manifest records a 2× preview text-scale override, with system font scale 1.15, at the Data & records / Weekly Overview boundary.
- The corresponding hierarchy dump is `dashboard/dashboard-2x-dark-boundary-ui.xml`. It records a vertically scrollable Android `ScrollView` from `[0,273]` to `[1080,2148]`; the bottom navigation begins at y=2148. The capture places Data & records partly above the scroll viewport and Weekly Overview partly below it. This is a boundary/scroll-position image, not proof of internal child clipping. Capture each section fully visible in separate 2× states before judging its large-text layout.
- No Dashboard 320 dp, landscape, tablet, or 1×/1.15×/1.5×/2× route matrix is available as screenshot evidence.

### Other captured routes

The evidence package includes Pixel 7 normal-width light/dark references for Train Overview and Plans, plus planning routes: Plan Management, Premade Plans, Preset Detail, Optimized Workout Settings, and Gym Profile. These captures use the device's approximately 411×914 dp viewport; they do not establish narrower, tablet, landscape, or large-text behavior.

The Premade Plans pair is not state-matched:

- `planning/premade-plans-light.png` shows the settled equipment-filter state (“Plans already fit the current profile”).
- `planning/premade-plans-dark.png` shows “Checking plan exercises against your profile…” and a progress indicator.
- `planning/premade-plans-dark-ui.xml` corroborates the loading presentation. In `lib/screens/exercise/premade_plans_page.dart`, the equipment-filter loading state is derived from the adaptation `FutureBuilder` while its snapshot is not done, then passed to `_PremadeProfileEquipmentFilterCard`.
- Recapture the dark state after loading settles and update its state description in `manifest.csv`. This is a capture-state mismatch; it does not by itself establish a light/dark implementation difference.

The initial `e87b4eee` screenshot-refresh package does not contain current-build Active Workout screenshots, Onboarding screenshots, or Preset Generation QA screenshots. Older approved Active Workout images may serve as historical references only, not as evidence for that initial candidate build. Onboarding is captured separately for the later candidate below; the other evidence gaps remain.

## Responsive test coverage present in source

The following tests contain viewport or text-scale scenarios. They were identified in source; their execution and results are not established by this evidence note.

| Area | Test file | Scenarios identified in source |
|---|---|---|
| Train | `test/expressive_train_presentation_test.dart` | 320 dp and 2× French/text-scale cases |
| Active Workout / WeightCard | `test/expressive_active_workout_compact_scale_test.dart` | 320 dp at scales 1.0, 1.15, 1.5, and 2.0 |
| Active Workout / session | `test/expressive_session_compact_scale_test.dart` | 320 dp, varied scales, keyboard insets/widths |
| Preset Detail | `test/theme/widgets/preset_detail_screen_theme_test.dart` | 320×900 at 2×; 390×844; 600×1000 at 1.5×; 800×390 at 1.5×; 1024×768 at 2× |
| Premade Plans | `test/theme/widgets/premade_plans_page_theme_test.dart` | 320×900 at 1×/2×; 390×844 at 1.5×; 600×1000 at 1.5×; 800×390 at 1.5×; 1024×768 at 2× |
| Plan Management | `test/theme/widgets/plan_management_responsive_test.dart` | 320×900 at 1×/1.5×/2×; 390 dp; 600 dp; 800×390 landscape; 1024 dp at 2× |
| Optimized Workout Settings | `test/theme/widgets/optimized_workout_settings_fields_theme_test.dart` | 320×900 at 2× with a 300 dp keyboard inset; 390/600/800×390/1024 viewport cases |
| Gym Profile | `test/theme/widgets/gym_profile_screen_theme_test.dart` | 320 dp and 2× |
| Onboarding | `test/theme/widgets/onboarding_flow_theme_test.dart` | 320/390/600/800 and landscape, at 1×/1.5×/2× |
| Preset Generation QA | `test/theme/widgets/preset_generation_qa_responsive_test.dart` | 320 dp at 2× with keyboard inset; 390/600/800×390/1024 viewport cases |

The table describes source coverage, not a responsive qualification result. The later focused-run outcome is recorded below; only the specific cases that were run and passed may be cited as validated.

## Remaining responsive evidence gaps

1. No current-candidate physical or simulated screenshot set covers 320 dp, tablet width, or landscape for these routes.
2. No full route-wide 1×, 1.15×, 1.5×, and 2× text-scale capture matrix exists.
3. Dashboard has only one 2× dark boundary/scroll capture; it needs separately framed, fully visible Data & records and Weekly Overview states to distinguish intrinsic wrapping from viewport clipping.
4. Premade Plans dark needs a settled-state recapture to match the light capture.
5. Current-build Active Workout and Preset Generation QA visual evidence is absent from these packages. Onboarding has separate bootstrap-build captures but not standard-entrypoint or text-scale/viewport evidence.
6. Planning default screenshots do not cover validation, keyboard, persistence, edit/save/cancel, dialogs, empty/error, or return states. Record each state as unverified unless captured or tested directly.

## Interpretation boundary

The current evidence supports review at the Pixel 7's normal logical width and the specifically recorded Dashboard 2× boundary state. It does not establish responsive qualification across devices, widths, orientations, accessibility text scales, or interactive states. Keep route visual approval, test results, and release qualification as separate statuses.

## Post-remediation evidence — 2026-10-10 candidate (historical)

The standard candidate APK (`79e1ad795542bc93dd163046040a051ecc90a3ffeeb03c3bea5d1cf6b1aa5ce2`)
was captured on Pixel 7 `28021FDH200228` at approximately 411×914 dp. It adds
light/dark captures for Muscle Rankings, Body Part / Muscle Mapping (read-only
and edit), Exercise Editor and its caller-scoped picker, Weekly Sets Overview
(Bodyparts and Muscles tabs), and Dashboard root. Onboarding captures are in a
separate subfolder from a route-only bootstrap APK and are not represented as
standard-entrypoint captures. See
[`post-remediation-evidence/20261010-build-79e1ad79/`](post-remediation-evidence/20261010-build-79e1ad79/README.md).

The six focused candidate test files completed with **24 passed, 0 failed**.
The responsive ranking test covers both ranking pages at 393 dp and 320 dp
with 1×/1.5× text, and checks the long muscle label at 393 dp. The Weekly Sets
Overview tests include a 320×900 dp / 2× case and additional responsive sizes.
These are widget-test results, not device captures or a full route matrix.

The candidate still has no current-source physical/simulated screenshot set at
320 dp, tablet width, or landscape, and no systematic 1×, 1.15×, 1.5×, and 2×
text-scale capture matrix. The normal Pixel captures do not cover transient
keyboard, drag, validation, error, or full persistence flows. Onboarding
light/dark captures are not state matched. No broad responsive qualification
was completed.

## Latest remediation evidence recorded — 2026-10-10 (historical)

The latest dedicated-preview APK has SHA-256
`2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7` and was
captured on Pixel 7 `28021FDH200228` at approximately 411×914 dp. Local image
files and their route/state labels are indexed in
[`post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).
The current set covers Muscle Rankings; Body Part / Muscle Mapping;
Exercise Editor landing and its caller-scoped picker; Weekly Sets Overview
Bodyparts/Muscles and linked anatomy detail states; Database Settings and its
scrolled health/path state; and the default Optimized Workout Settings page.
It does not include an onboarding state from this exact APK; onboarding images
remain separately identified as bootstrap-build evidence.

The final focused combined run passed 63 tests across five focused files. The
ranking responsive tests exercised 393 dp and 320 dp at 1×/1.5× and a long
muscle label; Weekly Sets tests include 320×900 dp / 2× plus other widget test
sizes. These results cover only those test cases. There is still no device
capture matrix at 320 dp, wide/tablet, landscape, or across 1×/1.15×/1.5×/2×
text scales, and no broad route-responsive qualification.
