# Expressive micro-interaction review

This targeted follow-up checks small interaction defects around pressed feedback, scrolling, motion overrides and the Nutrition floating menu. It preserves the approved layouts, palettes, geometry and animation timings. It is not a new full-app visual approval or release qualification.

## Confirmed defects fixed

| Area | Previous behavior | Result | Review route |
| --- | --- | --- | --- |
| Pressed cards during scrolling | A raw pointer-down compressed the card until the finger lifted, even after the gesture became a scroll. | Crossing the normal touch slop releases only the visual press. The child and scrollable retain gesture ownership; small tap movement still works. | Train > Plans; start scrolling from a plan row. |
| Secondary mouse clicks | Right-clicking could compress an action that only activates on a primary click. | Secondary clicks do not trigger primary-action feedback. | A desktop/mouse-enabled Expressive action. |
| Motion overrides | Custom press feedback ignored a zero-duration motion configuration. | Zero-duration motion overrides now suppress and cancel press feedback while preserving activation. Existing system reduced-motion and inactive-ticker behavior remains. | Focused light/dark override tests; normal app motion is unchanged. |
| Nutrition floating toggle | Some callers supplied no accessible tooltip; the open state had no expanded/collapsed announcement. | The default purpose is localized, the open control announces Close, and expanded state is exposed on the merged native button semantics. Supplied closed-state labels are respected. | Nutrition > bottom-right plus; inspect with accessibility services or long-press for its tooltip. |
| Back with Nutrition actions open | Back left the page while its action menu was open. | Back closes the menu first; another Back follows normal navigation. An inactive cached menu cannot block Back on another page. | Nutrition > plus > Android Back. |
| Nutrition view selector | Ring/Bar/Summary view exposed duplicate accessibility entries, with selection and activation on separate nodes. | Each view is one merged native button carrying its tooltip, selected state and activation action. Appearance and page-switch timing are unchanged. | Nutrition > Daily nutrition > Ring/Bar/Summary controls. |

## Validation

- **56 focused widget tests passed** across four files: the new micro-interaction regressions, existing Expressive motion tests, pending-motion regressions and Nutrition summary tests.
- New tests first reproduced the scroll, secondary-click, motion-override, missing-tooltip and Back defects.
- Existing checks cover keyboard activation, pointer cancellation, repeated presses, disabled controls, retained hit targets, reduced motion and ticker suspension.
- Nutrition checks cover merged view-selection semantics, ring replay, missing/exceeded goals, centered summaries, narrow widths, large/localized text and Classic/Neo preservation.
- Scoped analysis completed without issues. Changed Dart files were formatted and diff whitespace checks passed.
- The offline debug build passed. On the physical Pixel 7, each Nutrition view selector now exposes one entry, and Back closes the floating menu while keeping Nutrition open. The bounded runtime log check found no Flutter error matches.
- The refreshed app is left on **Nutrition Dashboard with its action menu open**. Device checks only opened/closed the menu and navigated; no entries were logged or settings changed.
- No databases, fixture records, settings or user-authored changes were reset. No staging, commits or pushes were performed.
- This review does not grant additional motion approvals or change existing page classifications.

## Files

- `lib/theme/widgets/tonos_expressive_motion.dart`
- `lib/widgets/speed_dial_fab.dart`
- `lib/widgets/expressive_nutrition_summary.dart`
- `test/theme/widgets/expressive_micro_interactions_test.dart`
- `test/theme/widgets/nutrition_dash_expressive_test.dart`

Source inspection also sampled settings selectors, profile drawers, navigation controls, media frames and exercise-sheet controls. The fixes above are the confirmed issues addressed by this pass; this is not an exhaustive device, assistive-technology or responsive certification.
