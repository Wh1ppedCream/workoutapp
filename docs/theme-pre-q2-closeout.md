# Pre-Q2 Closeout Ledger

This is the current status summary for the seven pre-Q2 follow-ups. Older batch
records describe their original implementation checkpoints; they are not current
qualification claims. The latest user-run verification covers the current
automated implementation and test changes.

## Evidence Already Supplied

- C3-D3 review corrections: user-reported clean scoped analysis and 168 passing tests.
- E1: user-reported clean analysis and 184 passing scoped tests.
- E2 initial presentation slice: user-reported clean analysis and 181 passing tests.
- The latest user-run verification passed 200 theme/configuration tests after
  the food-provider disposal, media-viewer async, scanner, log-entry, pan and
  ratchet CLI corrections. Scoped analysis also reported no issues.
- These are scoped automated results, not matched screenshots, device
  accessibility review, full application correctness, or approval of every
  production style expression.

## Seven Follow-Ups

| Item | Current state | Completion condition |
| --- | --- | --- |
| 1. Evidence reconciliation | Complete for the automated closeout record | Keep manual qualification separate from historical and scoped automated evidence. |
| 2. Reachability and styling audit | Scoped implementation and caller-contract verification complete | Finish manual route review for the reachable Train2, generator, nutrition, and profile-settings paths. |
| 3. Food behavior coverage | Automated evidence complete | Retain manual acceptance review if grouped/date behavior needs broader product qualification. |
| 4. Scanner tests | Fake-session automated evidence complete | Perform real-device permission, camera, lifecycle, and dismissal qualification. |
| 5. Earlier consumer evidence | Automated viewer/effects evidence complete | Perform real-media, heatmap, device, and accessibility review. |
| 6. Q1 hardening | Complete for the current scoped implementation | Keep interpolated files ineligible until parser support exists. |
| 7. Enrollment and CI | One exact production scope enforced in CI | Enroll additional files only after per-file ownership and qualification evidence exist. |

The latest automated corrections are now user-verified by the 200-test run.
Q1 is complete for the enrolled TonosSurface scope and its CI enforcement;
additional production enrollment is intentionally pending per-file evidence.
Interpolation support is explicitly deferred under theme-style-ratchet.md.
Manual/device/Classic parity qualification remains separate.

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

## Manual And Product Review Still Required

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
   `AppGenerationTokens`. Verify selected/unselected states and copy/lerp;
   preserve generator inputs, onboarding result IDs, save/cancel and generation
   behavior.
3. Nutrition Log, Pantry Log and Plan Meal are retained placeholders with
   callers. Do not classify them as excluded or remove navigation without a
   product decision. Their presence is not fixed by token extraction.
4. A source search found only the declaration of `DefaultTrendPage`, not a
   construction call. Record this as a source-search finding, not proof that
   every possible release route or generated entry point was examined.
5. Food logging now has a controlled repository/provider fixture for search
   selection, favorites, portion selection, quantity arithmetic, and the final
   persistence payload. Verify the new behavior test and add representative
   grouped/date-rendering evidence if the acceptance review requires it.

## Enrollment Rule

`docs/theme-style-ratchet.json` enrolls only
`lib/theme/widgets/tonos_surface.dart`. Do not populate it with every current
finding to obtain a green run. Each exact file needs an owner, evidence and
narrowly justified approvals. Missing manual qualification must stay visible.
Q1 fixture correctness and broader production protection are separate
milestones.
