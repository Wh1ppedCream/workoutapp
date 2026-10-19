# Progress refinement — Pixel 7 review evidence

Captured on 2026-10-06 from the current working source at `ab18ed8cab5582c8449e13724afae3c4b74ebeea` on `feature/classic-m3e`. The working tree was already extensively dirty before this pass; this evidence is uncommitted.

## Preview identity

- Device: Pixel 7, `28021FDH200228` (`panther`)
- Preview package: `com.tonos.expressivepreview`
- Isolated database: `tonos_expressive_preview.db`
- Build: `tools/run_expressive_preview.ps1 -BuildMode debug`
- SDK: Flutter 3.47.5 / bundled Dart 3.13.4
- APK manifest: version code 6, version name 1.0.1

A final incremental build and install was completed after the formatting-only edits. `final-light-current-build.png` is from that last APK; the other named state captures are from the preceding build, before those nonsemantic line-wrapping changes.

Only the isolated preview package was updated. The normal `com.tonos` package remained installed and was not modified or launched for this review.

## Review captures

### Workout Report

- `workout-report-light-collapsed-all-workouts.png` — All range, Workouts selected, details collapsed.
- `workout-report-light-all-time.png` — All range, Time selected, details collapsed.
- `workout-report-light-3m-time-collapsed.png` and `workout-report-light-3m-time-expanded.png` — 3M range, Time selected, collapsed and expanded details.
- `workout-report-dark-3m-time-collapsed.png` and `workout-report-dark-3m-time-expanded.png` — matching dark 3M/Time states.
- `workout-report-dark-1m-time-collapsed.png` — 1M range, Time selected.
- `progress-large-text-1-5x.png` — preview text scaling at 1.5×; KPI cards stack and remain readable. The preview setting was returned to app/device default afterward.
- `final-light-restored.png` — final normal-scale light state after restoring the preview setting.
- `final-light-current-build.png` — fresh light Workout Report capture from the final incremental APK, with All/Workouts selected and details collapsed.

Matching UI hierarchy dumps are included where available for range, KPI, and disclosure state inspection.

### Exercise Progress and Health Trends

- `exercise-progress-light.png` and `exercise-progress-dark.png` — selected exercise hero, chart, Actual/Estimated 1RM, and secondary exercise selector preview.
- `health-trends-light.png` and `health-trends-dark.png` — populated Weight trend, empty Height and Chest cards, and the next-card peek.

These scroll captures include adjacent Progress sections where they share the viewport.

## Supplemental files

`00-fresh-launch.png` is a transient startup frame and `preview-controls.png` shows the preview configuration panel; neither is a visual-review result. Their XML files are operational snapshots. Use the named review captures above.
