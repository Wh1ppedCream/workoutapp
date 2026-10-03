# Tonos Expressive Progress review

**Current amplified candidate:** [Expressive Progress — amplified review (2026-10-03)](amplified-review/20261003/README.md). Focused and integrated QA have passed, and fresh light/dark Pixel captures are ready for user review. The foundation captures and notes below remain the original baseline evidence and are preserved as before; Progress qualification and full-suite qualification remain deferred until user approval.

Pixel 7 review captures for the isolated Expressive preview.

- Device: Pixel 7 (`28021FDH200228`), Android 16, 1080 × 2400.
- App: `com.tonos.expressivepreview`.
- Database: `tonos_expressive_preview.db`.
- Build: Flutter 3.47.5 / Dart 3.13.4, profile APK.
- The preview uses its own fixture profile and workout data. Health Trends has no measurements seeded, so those cards show their empty state.

## Captures

| State | Light | Dark |
| --- | --- | --- |
| Progress overview: Workout Report, selected Workouts metric, All range, Exercise Progress start | [PNG](review/progress-expressive-light-overview.png) | [PNG](review/progress-expressive-dark-overview.png) |
| Scrolled Progress: Exercise Progress and Health Trends | [PNG](review/progress-expressive-light-health.png) | [PNG](review/progress-expressive-dark-health.png) |
| Ab Wheel 1RM detail chart and recordings | [PNG](review/progress-expressive-light-exercise-detail.png) | [PNG](review/progress-expressive-dark-exercise-detail.png) |

Additional captures show the light 1M range, expanded Workout Report details, and a selected historical Ab Wheel chart point.

## Pixel checks

- Selecting `1M` changed the Workout Report range and chart content; the accessibility node reported two workouts for that range. Returning to `All` restored the overview state.
- Expanding `Additional Details` displayed the four summary metrics without clipping.
- Opening Ab Wheel showed its 1RM chart and recordings. Tapping a historical point changed the chart's semantic value/date from the latest point to the selected Oct 1 recording.
- Scrolling exposed Exercise Progress and Health Trends without a viewport overflow. Health Trends' metric cards remain horizontally scrollable; the next card is partially visible at the right edge by design.
- The profile capture still displays Flutter's diagonal `DEBUG` ribbon. It is a build-mode indicator, not part of the Expressive theme.

The full repository test suite remains deferred until visual review. The focused tests and repo-wide analyzer results are recorded in the handoff message for this review.
