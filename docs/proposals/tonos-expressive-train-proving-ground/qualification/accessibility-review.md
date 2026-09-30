# Train + shell Expressive accessibility review

**Review date:** 2026-09-30
**Checkpoint:** `feature/classic-m3e`, `a4f877a59b0872315b6e53db1049bb7bd5d1d5c9`
**Scope:** widget-level accessibility, density, overlay, focus, and performance-harness audit for the existing Train + shell preview. No production accessibility or theme source was changed.

## Qualification summary

The scoped widget checks passed. The production preview has coverage for the ordinary 320 dp / 2× cases, the corrected five-destination height, an 11-destination light/dark layout matrix, selected-state semantics, overlays, reduced motion, and Back focus restoration. A new stress test adds long localized navigation labels, RTL layout direction, and a custom nonlinear `TextScaler` to one compact case.

These are Flutter widget results. They do not establish TalkBack or VoiceOver behavior, the Android operating system's exact nonlinear scaling curve, or physical-device accessibility behavior. The Pixel device lane owns hands-on device validation.

## Coverage checked

| Area | Evidence | Result and limit |
|---|---|---|
| Compact Train | `test/expressive_train_presentation_test.dart` and `test/expressive_overlay_qualification_test.dart` | French Train tabs and action bar at 320 dp / 2×; first build and live resize at 320 dp / 2× passed without layout exceptions. |
| Five-destination navigation | `test/expressive_navigation_presentation_test.dart` | 1× ordinary height and 2× bounds tested at 320 dp and Pixel logical width. The recorded corrected 2× height is 72 dp. Tests also inspect each visible hit area and tap semantics. |
| Configured 11-destination navigation | `test/expressive_navigation_presentation_test.dart` | 320 dp, light/dark, 1×/2× matrix passed; selected-last and reordered topology remain visible, actionable, and semantic. Its height check has a lower bound derived from label height, not an upper limit or exact post-fix measurement. The old 136 dp figure predates the correction and is not current evidence. |
| Long localized labels, RTL, nonlinear scaling | `test/expressive_qualification_accessibility_test.dart` | New 320 dp stress case uses all 11 French localized destination labels, RTL `Directionality`, selected-state/tap semantics, and visible hit-area checks. Its monotone piecewise `TextScaler` deliberately scales smaller sizes at 2× and larger sizes at a lower factor. This is a synthetic nonlinear layout stress curve, not Android's implementation or a claimed OS test. French labels are rendered in RTL direction; this does not test Arabic/Hebrew glyph shaping because the app has no RTL localization in its supported-locale list. |
| Train tabs | `test/expressive_accessibility_test.dart`, `test/expressive_train_presentation_test.dart`, and the new stress test | Selected state and 48 dp target checks are covered, including a compact 2× RTL selector smoke and French compact layout. The new case exercises the production Train selector and callback in the same RTL nonlinear stress host as navigation. |
| Reduced motion and overlays | `test/expressive_overlay_qualification_test.dart` | Preview reduced-motion controls, dialog/route presentation, French 2× reduced-motion dialog semantics, SnackBar, and drawer semantics passed. |
| Back and keyboard focus | `test/expressive_overlay_qualification_test.dart` | Enter opens the root preview controls; system Back dismisses them and focus returns to the root control. This is widget keyboard/focus coverage, not a device keyboard test. |
| Semantics | The focused test files above | Train tabs and navigation destinations expose tap actions and selected state; overlay actions and drawer profile rows expose their expected semantics. Decorative selection layers are tested through their child controls. |

The navigation tests use the production `TonosBottomNavigationBar`; the new case uses production `TonosTrainTabs` too. The new 11-label stress case asserts that each destination remains at least 48 dp tall, retains at least 48 dp of visible hit width after scrolling, and has its label inside the viewport. It does not assert an exact or maximum bar height, so it does not reopen the corrected five-destination 72 dp result or claim that the extreme configured-navigation density tradeoff is resolved.

## Focused test results

Using the pinned Flutter 3.47.5 / bundled Dart 3.13.4 SDK with `--no-pub`:

```text
Existing focused set:
  expressive_accessibility_test.dart
  expressive_navigation_presentation_test.dart
  expressive_overlay_qualification_test.dart
  expressive_train_presentation_test.dart
  28 passed, 0 failed, exit 0

New nonlinear / localized-label / RTL stress test:
  expressive_qualification_accessibility_test.dart
  1 passed, 0 failed, exit 0
```

The new test's green result establishes its host-side geometry and semantics assertions only. It does not replace the Android OS text-scale controls, native assistive technology, or the physical Pixel review.

## Performance harness audit

`integration_test/expressive_preview_device_test.dart` requires profile mode, checks the isolated preview identity before data access, warms both looks in both brightness modes outside the timing callback, and alternates Classic / Expressive / Expressive / Classic. For each look and brightness it samples a three-second quiet-idle action, six settled mixed-interaction cycles, and six rapid tab/navigation retargeting cycles. Idle phases record their UTC start, action duration, frame count, and build/raster summaries. `_captureTimings` keeps the callback attached during a further two-second flush after the idle action, so the idle frame count covers about five seconds while `idleDurationMicros` covers only the three-second action. Do not divide that frame count by three to claim an idle frame rate. The rapid path uses an 80 ms `WidgetTester.pump` cadence, records that configured cadence, and settles only after the sequence. Interaction reports include runtime refresh rate, build/raster p50/p90/p95/p99/max, frame-budget buckets, over-budget counts, and slow-frame clusters.

The corrected retry log at `docs/proposals/tonos-expressive-train-proving-ground/qualification/logs/profile-driver-rerun-2026-09-30.txt` contains all four idle rows and all 16 interaction rows, plus runtime device metadata: 60 Hz active refresh, 16,667 µs frame budget, 411.43 × 914.29 dp logical display, and DPR 2.625. The post-fix full suite ended at 10:28:09 local; the first idle window began at 10:29:14 local, so this profile run did not overlap the host suite.

The table pools counts across each look's four batches (light/dark × two repeats). Frame counts and over-budget counts are summed; p95 values are the minimum and maximum of the four batch-level p95s; cluster values show the batch range and sum.

| Look | Phase | Frames | Build p95 range | Build over budget | Raster p95 range | Raster over budget | Slow-frame clusters |
|---|---|---:|---:|---:|---:|---:|---:|
| Classic | Settled mixed | 915 | 41.89–50.38 ms | 98/915 (10.71%) | 19.38–20.25 ms | 326/915 (35.63%) | 41–45 per batch; 171 total |
| Expressive | Settled mixed | 911 | 46.16–49.72 ms | 103/911 (11.31%) | 19.42–20.48 ms | 330/911 (36.22%) | 42–45 per batch; 174 total |
| Classic | Rapid retargeting | 212 | 16.67–23.25 ms | 34/212 (16.04%) | 14.53–15.56 ms | 2/212 (0.94%) | 4–16 per batch; 34 total |
| Expressive | Rapid retargeting | 212 | 21.47–25.75 ms | 50/212 (23.58%) | 13.25–15.25 ms | 1/212 (0.47%) | 10–15 per batch; 51 total |

Each settled batch had six interaction cycles and 227–229 frames; each rapid batch had 53 frames at the configured 80 ms synthetic cadence. All four three-second idle actions observed zero frame timings; the callback stayed attached for the two-second flush, so each count covers roughly five seconds and does not define an idle frame rate. The rapid batches show higher build over-budget counts for Expressive (50/212) than Classic (34/212) in this single run; settled results are close. Treat this as an observed harness difference, not a causal or population-level performance conclusion. Three garbage-collection events occurred during measured batches, so do not attribute every upper-tail sample to theme rendering.

The retry driver exited 1 after the timing phases, at the production compatibility smoke's 48 dp collapse-control assertion. That assertion measures `find.byTooltip(...).getRect()`, which returns the 40 dp inner Tooltip/Material bounds. The app uses Material 3; the pinned Flutter implementation wraps that inner button with `_InputPadding` for the 48 dp padded target. Thus the 40 dp measurement is not evidence that the tap target is 40 dp, and this run does not complete the end-to-end driver. The previous attempt stopped at the ongoing-session menu `MergeSemantics` hit-test warning; the corrected retry passed that menu interaction and its cleanup before reaching the collapse assertion. Both runs are completed profile-phase observations, not a successful full driver run.

A smoke-only selector then skipped warm-up/timing loops and unrelated routes. Its scoped analysis and profile build passed, but the bounded Pixel attempt stalled for over five minutes after fixture setup and was interrupted (exit 1) before geometry/runtime output. No Flutter exception was observed in the inspected logcat; the cause remains unknown. The outer target size and edge-hit proof are pending. No physical edge taps were completed, and the stalled attempt is not evidence of a production 40 dp target defect.

The profile harness uses synthetic `WidgetTester` pointer events and build/raster frame times; it has no event-to-visible-frame timestamp and does not measure physical touch-to-response latency. Start is only pressed and cancelled inside the measured loop; its real callback/route is exercised separately and not timed. The 80 ms value is the injected test cadence, not measured device input latency. Native scaling, assistive technology, physical hit edges, matched visual captures, and motion review remain outside this evidence.

## Open accessibility limits

- The 11-destination 320 dp / 2× matrix has no exact post-correction height measurement or maximum-height acceptance bound. Treat extreme density as an explicit user-review tradeoff, as the handoff does.
- The custom nonlinear scaler is a deterministic stress case. Validate the actual Android 16 text-scale curve on the Pixel before claiming OS nonlinear-scale coverage.
- No RTL locale is currently supported. RTL layout direction was stress-tested with French strings; native RTL localization and bidirectional script shaping remain outside this test.
- No TalkBack/VoiceOver session, hardware keyboard session, landscape case, or system-inset/keyboard-inset device case was performed by this lane.
- Widget semantics checks do not establish screen-reader focus order or announcements on a device.
