# Pre-Q2 Closeout Ledger

This is the current status summary for the seven pre-Q2 follow-ups. Older batch
records describe their original implementation checkpoints; they are not current
qualification claims. The latest supplied user-run verification (2026-09-22)
covers the post-review automated implementation and test changes: 135 files
were formatted with 0 changes, analysis was clean, the full theme suite passed
321 tests, the responsive suite passed 6 tests, the route-boundary batch
passed 46 tests, and the enforce-mode ratchet passed with one protected
production file. The user has now confirmed the
human/device/N6 checklist for the current development scope, and E2.4 closeout
is recorded as complete. Step 15 release qualification remains separate.

This ledger does not qualify later Q2 code. The current cross-prerequisite
decision, including the passing 213-test Q2 rerun and dirty-tree identity, is recorded
in [Q3 Theming Readiness Gate](theme-q3-readiness-gate.md).

## Evidence Already Supplied

- C3-D3 review corrections: user-reported clean scoped analysis and 168 passing tests.
- E1: user-reported clean analysis and 184 passing scoped tests.
- E2 initial presentation slice: user-reported clean analysis and 181 passing tests.
- The latest supplied post-review verification (2026-09-22) passed 321
  theme/configuration tests, 6 responsive tests, and 46 route-boundary tests
  with clean analysis, formatting of 135 files with 0 changes, and a passing
  enforce-mode ratchet with one protected production file.
  The standalone
  2-test nutrition behavior run also passed.
- The current 21-item Neo visual review is accepted. The final bright-field
  selector correction passed user-run formatting, clean analysis, and 63
  focused tests. The later user qualification confirmation closes the current
  development nutrition, scanner, route-state, accessibility, and device
  review. It does not qualify Neo for release.
- These are scoped automated results, not matched screenshots, device
  accessibility review, full application correctness, or approval of every
  production style expression.

Post-review implementation pass (2026-09-17; automated-verified in the latest
supplied user run): added focused
nutrition rollback/failure and grouped/date-ordering coverage, food-editor
validation and narrow-layout coverage, N5 state-owner and settings-residue
contracts, health-delta Classic parity, large-text settings wrapping, and
explicit shape/elevation forwarding through the Neo compatibility boundary.
The post-review pass also restores outlines and shadow geometry for explicit
custom rounded Neo shapes and tightens route-edge contract matching. No new
style-ratchet scope was enrolled. Follow-up verification exposed a large-text
settings-row layout failure and two test-only determinism/fixture issues;
those are now corrected and covered by the latest supplied run. The selector
row subsequently required a bounded stacked large-text action composition
rather than relying on ListTile's shared horizontal slot. Its regression
fixture now uses the failing 320x640 viewport, and the selector harness uses a
zero-duration theme transition for deterministic family changes.

## Seven Follow-Ups

| Item | Current state | Completion condition |
| --- | --- | --- |
| 1. Evidence reconciliation | Complete for the automated closeout record | Keep manual qualification separate from historical and scoped automated evidence. |
| 2. Reachability and styling audit | Scoped implementation/caller-contract verification and current Train2/generator/Profile visual review complete; current development route/device qualification user-accepted | Preserve the ledger and reopen only affected routes after later changes. |
| 3. Food behavior coverage | Automated and current user route acceptance complete | Preserve the focused behavior evidence and reopen only if product behavior changes. |
| 4. Scanner tests | Fake-session automation and current user real-device qualification complete | Recheck camera/lifecycle behavior after scanner changes. |
| 5. Earlier consumer evidence | Automated viewer/effects evidence and current user device/accessibility qualification complete | Finish final Neo recipes only where the product surface still requires them. |
| 6. Q1 hardening | Complete for the current scoped implementation | Keep interpolated files ineligible until parser support exists. |
| 7. Enrollment and CI | One exact production scope enforced in CI | Enroll additional files only after per-file ownership and qualification evidence exist. |

The latest supplied post-review automated verification (2026-09-22) reported
135 files formatted with 0 changes, clean analysis, 321 theme/configuration
tests, 6 responsive tests, 46 route-boundary tests, and a passing enforce-mode
ratchet with one protected production file.
The standalone 2-test nutrition behavior run also passed. These results do not
replace human/device/Classic parity or full-release qualification; the user’s
current development qualification is recorded above, while Step 15 remains
open.
Q1 is complete for the enrolled TonosSurface scope and its CI enforcement;
additional production enrollment is intentionally pending per-file evidence.
Interpolation support is explicitly deferred under theme-style-ratchet.md.
Manual/device/Classic parity qualification is accepted for the current scope;
later changes require focused rechecks.

## Current Code Changes And Evidence

- `lib/services/barcode_scanner_session.dart`: injectable, page-owned session;
  default adapter uses mobile_scanner with explicit start (autoStart disabled).
- `lib/screens/nutrition/barcode_scanner_page.dart`: preserves first nonempty
   trimmed code and single navigation result; cancels subscriptions on inactive
   state/disposal, resumes only when permitted, guards post-await UI updates.
- `lib/theme/tokens/app_generation_tokens.dart`: owns the custom preset-generation
  flow's gradients, surfaces, borders, text roles, choices, action bar, badge,
  and geometry while retaining the former Classic recipe.
- `lib/screens/exercise/preset_generation_qa.dart`: consumes generation tokens
  for the reachable intro, summary pills, settings sections, numeric fields,
  choice tiles, onboarding action bar, and completion badge. Transparent tile
  dividers remain intentional framework configuration.
- `lib/screens/exercise/train2_page.dart`: consumes explicit Train2 shape,
  semantic-color, and data-visualization roles without changing the legacy
  route's callbacks or Classic color values.
- `test/theme/barcode_scanner_route_test.dart`: empty/repeated codes, inactive
  subscription, resume, back cancellation, late torch completion and permission
  pending behavior. No physical camera is opened by these tests.
- `test/theme/pre_q2_route_evidence_test.dart`: keeps the reachable nutrition
  food-flow and profile-settings caller graph explicit without claiming that
  placeholders, device permissions or visual parity are release-qualified.
- `test/theme/nutrition_presentation_test.dart`: real editor route saves edited
  name, identity and supplied nutrient values; cancel returns no payload. These
  tests do not claim that the logging page persists these values correctly.
- `test/theme/food_logging_behavior_test.dart`: controlled provider/repository
  coverage for search selection, favorites, portion selection, quantity
  arithmetic, and the final `addDiaryFood` payload.
- `lib/theme/widgets/media_viewer_image.dart`: extracted existing dialog into
  `showMediaImageViewer`, used by the exercise detail sheet. Preserves original
  frame, labels, scrolling, min/max zoom, guide footer and close control.
- `test/theme/media_viewer_test.dart`: opens that production route and checks
  missing-file fallback, pinch transform and close. The Theme Lab regression
  also disables optional media shadows and the specialized exercise-detail
  sheet elevation without changing fixed image-viewing contrast. Real media
  capture and heatmap viewer behavior still require their own evidence.
- `tools/theme_style_ratchet.dart`: rejects normalized-path aliases, case-only
  duplicate entries and resolved files escaping the repository. Existing
  conservative interpolation rejection remains; this is not an AST analyzer.
- `test/theme/theme_style_ratchet_cli_test.dart`: launches `dart run` as a child
  process, checks JSON reporting and invalid-argument/JSON/missing-file exits.
  Requires `dart` on PATH and must be run from repository root.
- `.github/workflows/ci.yml`: includes ratchet in tool analysis; existing full
  `flutter test` step includes the new tests. No empty production gate is added.

## Historical Manual And Product Review Notes

The requirements below describe the review scope that was pending when this
ledger was written. The user's later development-qualification confirmation
supersedes those pending statuses for the current working tree; retain the
notes as the evidence checklist for future changes.

The current implementation pass adds provider rollback/diary-write failure,
stable grouped/date rendering, food-editor validation/layout, N5 state-owner,
settings-residue, health-delta parity, and compatibility-boundary contracts.
These focused checks are covered by the latest supplied automated run and do
not replace route visual or device qualification.
1. `lib/main.dart` constructs `Train2Page`. It is not dead code. Its toggle
   radii, avatar colors, purple plan actions and green optimization actions are
   now represented by route-specific shape, semantic-color, and data roles in
   `lib/screens/exercise/train2_page.dart`. Verify exact Classic values, text
   inheritance, loading/disabled behavior and repository callbacks. Do not
   substitute the newer Train page's colors merely because the actions have
   similar names.
2. `lib/screens/exercise/preset_generation_qa.dart` is reachable from Train2.
   Its intro gradients, border alpha, summary pills, expansion section frames,
   number-field/choice states and completion chips now have recipe ownership in
   `AppGenerationTokens`. The current Neo visual review is accepted; preserve
   generator inputs, onboarding result IDs, save/cancel, and generation behavior
   through any later state/device qualification.
3. Nutrition Log, Pantry Log and Plan Meal are retained placeholders with
   callers. Do not classify them as excluded or remove navigation without a
   product decision. Their presence is not fixed by token extraction.
4. A source search found only the declaration of `DefaultTrendPage`, not a
   construction call. Record this as a source-search finding, not proof that
   every possible release route or generated entry point was examined.
5. Food logging now has a controlled repository/provider fixture for search
   selection, favorites, portion selection, quantity arithmetic, and the final
   persistence payload. Verify the new behavior test and add representative
  persistence payload and stable grouped/date rendering. The new behavior
  tests are included in the latest supplied run; broader product acceptance
  remains separate.

## Enrollment Rule

`docs/theme-style-ratchet.json` enrolls only
`lib/theme/widgets/tonos_surface.dart`. Do not populate it with every current
finding to obtain a green run. Each exact file needs an owner, evidence and
narrowly justified approvals. Missing manual qualification must stay visible.
Q1 fixture correctness and broader production protection are separate
milestones.
