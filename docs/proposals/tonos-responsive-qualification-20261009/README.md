# Tonos Responsive Qualification — 2026-10-09

## Status and source identity

This is a responsive and regression qualification record for the current candidate tree. It is **not a release qualification** and does not update any visual-approval status.

- Repository: `E:\projects\env_test`
- Branch: `feature/classic-m3e`
- HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Upstream: `origin/feature/classic-m3e`
- Source state: dirty working tree; the device build came from this working tree, not from a clean checkout of HEAD.
- Toolchain: Flutter 3.47.5, Dart 3.13.4.
- Worktree count before adding this report: 139 tracked modifications, 273 untracked paths, 0 staged paths. Adding this report adds one untracked path. These counts include inherited user work and are not a count of this pass's edits.

**Qualification result: NOT QUALIFIED.** The final complete suite ran to completion but returned exit code 1. The analyzer also returned exit code 1. Exact theme inventory/ratchet contracts, both Flow Editor goldens, and formatting checks remain unresolved. No approval or baseline files were rewritten to make these checks green.

## Full Flutter suite

| Run | Result | Exit | Elapsed |
| --- | --- | ---: | ---: |
| Initial full run before the final fixes | 2,074 passed, 17 failed, 5 errors, 0 skipped (2,096 total) | 1 | 13m 34.8s |
| Intermediate complete run | 2,085 passed, 16 failed, 3 errors, 0 skipped (2,104 total) | 1 | 11m 22.7s |
| Final uninterrupted run | 2,085 passed, 16 failed, 3 errors, 0 skipped (2,104 total) | 1 | 10m 44.164s |

Final command: `flutter test --no-pub --concurrency=4 --reporter=json`. JSON log: `C:\Users\talh7\AppData\Local\Temp\tonos-responsive-qualification-final-c5-20261009.jsonl`.

A separate default-concurrency attempt crashed in the Windows `flutter_tester.exe` / `dartaotruntime.exe` child process around 6.5 minutes and was stopped after identifying the orphan. The final concurrency-4 run above was uninterrupted and completed the entire suite. No test skips or timeout results were reported in the final run.

### Remaining failures

The 16 assertion failures are exact source-candidate/style-inventory scope or count contracts. The current dirty source tree reports more/different findings than the committed expectations. These are not safely classified as harmless stale tests without an ownership decision, so no inventory or ratchet baseline was regenerated:

1. Catalog overview recipes have exact four-mode ownership
2. Exercise Detail and Preset Generation styles have exact owners
3. qualified onboarding and editor recipes stay source-limited
4. Expressive AddExerciseFab outline has exact opt-in geometry ownership
5. workout history calendar recipes have exact ownership
6. TonosBottomNavigationBar owns its exact migrated theme candidates
7. reviewed flow and Exercise Progress recipes have scoped rules
8. Food Customization recipes have exact, kind-limited ownership
9. UI Appearance family previews have exact recipe ownership
10. Gym Profile recipes have exact four-mode ownership
11. Food Logging recipes have exact four-mode ownership
12. Log Entry recipes have exact four-mode ownership
13. barcode scanner camera contrast stays a narrow one-off allowlist
14. premade plan route findings have an exact four-mode owner
15. every production style candidate has a measurable destination
16. navigation and gym settings have exact scoped inventory ownership

The 3 test errors are:

- `production manifest retains exact qualified scopes`: the ratchet reports 22 fingerprint-count mismatches across `lib/widgets/tonos_bottom_navigation_bar.dart` and `lib/widgets/exercise_definition_info_tile.dart`. The baseline was left unchanged.
- `Expressive flow control panels in dark mode`: golden mismatch.
- `Expressive flow control panels in light mode`: golden mismatch.

The two Flow Editor golden differences are similar in both themes; inspection found a current panel-height difference of approximately 18 logical pixels (baseline 588, candidate 570), not a dark-only behavior. The existing untracked golden/failure artifacts were preserved and not replaced. These mismatches still need an explicit design/baseline decision.

## Analyzer, formatting, localization, and diff checks

- Full `flutter analyze --no-pub`: 0 errors, 0 warnings, 78 informational diagnostics, exit code 1. The informational notices are deprecation notices; no analyzer errors or warnings remain.
- Analyzer output: `C:\Users\talh7\AppData\Local\Temp\tonos-responsive-qualification-analyze-final-20261009.txt`.
- Formatter check: `dart format --output=none --set-exit-if-changed` on 14 directly relevant Dart files returned 1 because it would reformat `lib/screens/catalog_page.dart` and the untracked `test/theme/widgets/profile_settings_expressive_test.dart`. No formatting was applied to avoid reformatting broad dirty-file content as part of this qualification pass.
- `git diff --check`: exit 0. Git printed line-ending conversion warnings for existing working-copy files; there were no whitespace errors.
- `flutter gen-l10n`: completed successfully for the Navigation Editor required-state label, with generated localization files checked for the expected output.
- Theme inventory and ratchet checks were not regenerated or relaxed; their failures are listed above.

## Responsive viewport coverage

The suite contains route-specific widget matrices, but it does **not** execute every route at every viewport/text-scale combination. Rows below describe only exact viewport coverage found in the executed tests. A check at one route does not imply app-wide coverage at that size.

| Requested viewport | Executed coverage | Result / limitation |
| --- | --- | --- |
| 320 × 568 | No exact route-level case found | Unverified at this exact short height. |
| 360 × 640 | A tutorial-action check only | Not a full-page or cross-route pass. |
| 390 × 844 | Present in Train, Catalog, navigation, Logbook, and other route-specific tests | Covered selectively, not as a complete app-wide cross-product. |
| 412 × 915 | No exact case found | Unverified at this exact size. |
| 430 × 932 | Present in Train, Catalog/anatomy and selected enlarged-text cases | Selective route coverage. |
| 600 × 960 | Present in Catalog/anatomy and related adaptive layouts | Selective route coverage. |
| 800 × 1280 | Present in Catalog/anatomy and navigation cases | Selective route coverage. |
| 1024 × 768 | Present in Catalog/anatomy and Progress detail cases | Selective route coverage. |
| 640 × 360 | Present in Catalog, Train, and overlay cases | Selective landscape coverage. |
| 800 × 360 | Present in Catalog/anatomy and overlay cases | Selective compact-height landscape coverage. |
| 844 × 390 | No exact case found | Unverified at this exact landscape size. |

Additional executed sizes include 320 × 720, 320 × 780, 320 × 900, 320 × 960, 320 × 1500, 320 × 1800, 360 × 800, 390 × 900/1000/1200, 420 × 1500, 430 × 900/932, 512/532 × 900, 600 × 1000, 800 × 390/600/1100, 1024 × 900/1000/1280/1366, and related route-specific cases.

Text scales of 1.0×, 1.15×, 1.3×, 1.5×, and 2.0× occur in selected tests. Both brightnesses are covered for several Expressive widget matrices. These are not a complete viewport × text scale × theme cross-product.

### Route matrix represented by tests

- Catalog and anatomy routes: 320 × 780, 360 × 800, 390 × 844, 430 × 932, 600 × 960, 800 × 1280, 1024 × 768, 640 × 360, and 800 × 360; text-scale variants include 1.0×, 1.3×, 1.5×, and 2.0× in light and dark. Catalog detail tests include 320 × 780 at 1.0×, 1.15×, 1.5×, and 2.0×.
- Train: 320 × 720, 360 × 800, 390 × 844, 430 × 932, 600 × 960, 800 × 1100, 1024 × 1366, 640 × 360, and 1024 × 768, with selected 2.0×/1.3×/1.5× cases.
- Active Session: Train-like widths plus 320 × 960 at 1.15×/1.5×/2.0× and 320 × 640 at 1.5× with keyboard inset.
- Navigation Editor: 320 × 800, 390 × 844, and 800 × 1280 at 1.0× and 2.0×, with destination-count variants.
- Nutrition customization: 320/360/390 × 900 and 512/532/600 × 900 at 1.0×/1.3×/1.5×/2.0×.
- Logbook: Session Detail at 320 × 1800 and 2.0×; calendar, Full History, and details at 390 × 1000.
- Progress: detail and report routes include 320 × 1800, 320/420 × 1500, 600 × 1000, 800 × 390, and 1024 × 768, with selected 1.0×–2.0× cases.
- Profile dialogs and flows: 320 × 720 at 1.0×/1.5×/2.0×, 390 × 844 at 1.0×/1.5×, 1024 × 900 at 2.0×; flow routes include 320/390/430 × 900 at 1.0×/1.5×/2.0×.
- Planning and overlays: representative 320 × 760/900, 390 × 844, 600 × 1000, 640 × 360, 800 × 360/390, and 1024 × 768 cases.
- Analytics settings children: paired light/dark route tests exist for ranking, mapping/editor, allocation and volume-boundary surfaces; complete interaction/device coverage is still open.

### Responsive gaps

- The exact requested 320 × 568, 412 × 915, and 844 × 390 cases are not present at route level.
- 360 × 640 is only a narrow tutorial-action check, not a full screen pass.
- Flow Editor has golden coverage at 430 × 1400 and physical Pixel portrait coverage, but no broad viewport/keyboard/graph-interaction matrix. The lower control deck is scrollable with both panels expanded; full graph-node selection did not validate on device.
- Several settings child routes and their dialogs (Database/Diagnostics, Progress Settings/Measured Items, Ongoing Workout Exit, Analytics Settings children) lack complete light/dark, keyboard, large-text, persistence, and device state coverage.
- French and Spanish long-label behavior was not exercised as a full route-by-route device audit. Generated localization completed, but the localization matrix is incomplete.
- TalkBack was not manually exercised. Automated semantics and accessible-action tests provide partial coverage only.
- No full tablet, physical landscape rotation, or system-wide 2× text-scale sweep was performed on the Pixel.

## Defects investigated and corrections

| Surface | Finding | Correction | Verification |
| --- | --- | --- | --- |
| Profile → User Information | Focusing/selecting a TextEditingController could trigger its listener and mark the form dirty, revealing Save Changes without editing. | Removed controller-listener dirty tracking; Name, Height, and Weight now mark dirty from text changes. | Light/dark focused widget tests passed 2/2; Pixel keyboard-open checks in both modes showed focus/IME working and no Save action before editing. |
| Profile → Workout Progress Rules / Flow Methods | The non-Expressive paired rule controls could overflow at narrow width. | Replaced the constrained Classic/Neo Row with OverflowBar. The Expressive Wrap remains unchanged. | New Flow Methods focused regression file passed 8/8, including 320/390/430 dp at 2× text with keyboard inset. |
| Analytics Settings navigation test | A large-text/keyboard test queried a dropdown before it was visible. | The test now scrolls the dropdown into view before checking it. | Included in focused and full-suite reruns. |
| AutoPresetFlowScreen theme test | A stale Save control/subtitle expectation did not match the current UI. | Updated the focused test to assert the current control/copy; no workout behavior was changed. | Focused AutoPresetFlowScreen tests passed 17/17. |
| Catalog/Profile family fallbacks | Expressive-specific ownership had obscured two existing non-Expressive values. | Restored the Classic/Neo Catalog usage-row padding and kept Profile's Classic diagnostics accent explicitly on its existing role. | Theme-family tests and final full suite exercised these paths; exact inventory failures remain separately open. |
| Navigation Editor required marker | The Required state label was not localized across supported ARB sources. | Added the required-state message to seven ARB files and regenerated the localized accessors. | gen-l10n and generated-output checks completed. |

No workout calculations, data semantics, navigation, approval statuses, or route behavior were intentionally changed. The User Information correction changes only dirty-state ownership; the Flow Methods correction changes narrow-width layout only.

## Focused test runs

Counts are per run and overlap; do not add them together:

- Combined responsive/route regression selection: 59 passed.
- Step 17 parity selection: 8 passed.
- Flow Methods regression file: 8 passed.
- AutoPresetFlowScreen focused tests: 17 passed.
- User Information focus/dirty-state light/dark cases: 2 passed.
- Workout chart accessibility: 5 passed.
- Exercise Progress Expressive color-role: 1 passed.
- Health Trends focused tests: 7 passed.
- A separate Progress-integrated run reached 19 passing tests before a storage-related interruption; it is not a complete run.

## Fresh route coverage and visual inventory

The current master ledger contains 55 archetypes, approximately 52 production-reachable. Its current status remains **A16 / B22 / C11 / D1 / E0 / F5 / G0**. The separate 24-route visual-review dossier contains **14 approved / 10 pending**. No visual approval statuses were changed for this qualification.

Current-source route families reviewed include Train and Active Workout; planning and preset detail; the Catalog root/browser/focus/detail routes; Logbook calendar, Full History, and Session Detail; Progress root/report/Exercise Progress/Health Trends; Profile root and settings children; and the seven Analytics Settings destinations (Analytics Settings, Body Part Ranking, Muscle Ranking, Volume Boundaries, Anatomy Mapping, Exercise Set Allocation, Exercise Editor).

The approved Train and Active Workout designs remain the visual references. Several Profile, Logbook and Progress routes are individually approved in the existing ledger, while child settings and analytics destinations remain pending their own review. The following remain specifically incomplete or open in the current ledger:

- Workout Settings → Analytics Settings and its children.
- Ongoing Workout Exit chooser responsive/device/accessibility qualification; its light/dark popup appearance is separately visually approved.
- Workout Progress Rules / Flow Methods persistence, reorder/delete, nested-dialog, large-text, and dark-device states.
- Progress Settings and Measured Items editing, delete, dialog, and Nutrition-caller states.
- Database Settings and Diagnostics & Privacy import/export, permission, busy/error, consent/delete, keyboard, dark, and accessibility states.
- Analytics ranking persistence and complete light/dark, large-text, and device review.
- Volume Boundaries, Anatomy Mapping, and Exercise Set Allocation input/selection/validation/persistence states.
- Exercise Editor save/delete/allocation dialogs, validation, media fallback, keyboard, and dark-device states.
- Onboarding, deferred Nutrition, and other less-used child routes have incomplete full-flow device coverage.

No additional production destination family was confirmed beyond the existing route ledger. Inventory status B means implemented but not visually approved; it is not a claim that every such route was screenshot-reviewed or found sufficiently expressive. The old status ledger remains the authority for visual approval.

### Subsequent visual approval note — Ongoing Workout Exit — 2026-10-09

After this responsive qualification snapshot, the user approved the current Profile → Training → Gym & Workout Settings → Ongoing Workout Exit popup as **A — visually approved / frozen** in both light and dark Expressive modes, specifically the single-popup, three-option choice layout. Keep the popup interaction style frozen. This child-state approval does not change the 55-archetype or 24-route totals and does not close the responsive/device/accessibility or behavior qualification gaps listed above. The qualification counts below remain a historical snapshot for this report; the current visual inventory is recorded in the route-component ledger and combined review dossier.

## Pixel 7 verification

- Runtime device: `28021FDH200228`, Pixel 7 (`panther`).
- Package: `com.tonos.expressivepreview`.
- Database: `tonos_expressive_preview.db`.
- Build: debug APK from `lib/expressive_preview_main.dart`, with preview database and controls dart-defines, then installed with `adb install -r`.
- Package path confirmed under the preview application ID; the normal Tonos package was not launched.
- Database remained 1,572,864 bytes with its recorded 12:20 timestamp; it was not reset.
- App remains installed and foregrounded in the dark Flow Editor with both control panels expanded and scrolled.

Fresh/current-candidate device evidence is in `pixel7/`. Representative inspected captures:

- Train: `16-final-train-overview.png` (light), `03-train-overview-dark.png` (dark; before the final User Information-only dirty-state fix).
- Profile root: `20-profile-root-final-light.png`, `26-profile-root-dark-final.png`.
- User Information keyboard/focus: `17-user-info-keyboard-final.png`, `22-user-info-keyboard-dark-final.png`; Gender selector: `18-user-info-gender-dialog.png`.
- Gym & Workout Settings: `06-gym-workout-settings-light.png`, `27-gym-workout-settings-dark-final.png`.
- Workout Progress Flows: `07-workout-progress-flows-light.png`, `28-workout-progress-flows-dark-final.png`, `29-workout-progress-flows-dark-scrolled.png`.
- Flow Editor: `08-flow-editor-light.png`, `09-flow-editor-both-panels-expanded.png`, `11-flow-editor-scrolled-expanded-controls.png`, `30-flow-editor-dark-final.png`, `31-flow-editor-dark-both-expanded-final.png`, `32-flow-editor-dark-scrolled-expanded-final.png`.
- Other representatives: `23-progress-root-dark.png`, `24-logbook-root-dark.png`, `25-catalog-root-dark.png`.

The Flow Editor's expanded controls scrolled while the graph remained visible; a graph-node tap did not produce a selected-node state, so graph-node selection is **not** claimed as verified. User Information was focused with the soft keyboard in light and dark; the corrected form did not show Save until text changed. The selector was opened without changing profile data. Device verification is representative, not an all-routes interaction qualification. A few numbered captures are intentionally not cited as current evidence: 15 predates the dirty-state correction; 19 is not a Profile root; 21 did not actually show the keyboard; 33 did not confirm node selection. `current-ui.xml` is retained scratch state.

## Parallel work and integration

Parallel investigation covered Flow Editor golden triage, responsive-matrix inventory, route-coverage gaps, accessibility/contrast, action clipping, and an adversarial Active Workout review. Findings were integrated by the lead. The available subagent model was GPT-6 Sol High where GPT-6 Luna High was unavailable. Shared production changes were kept in the lead's integration scope; no competing Pixel/build process was used during device validation.

## Files touched by this qualification

The repository already had a large user-owned dirty tree. The following are the direct implementation/test/localization areas attributable to this qualification; this list is not a claim that the other dirty paths were edited in this pass.

Production source:

- `lib/screens/catalog_page.dart`
- `lib/screens/profile/settings/flow_methods_page.dart`
- `lib/screens/profile/settings/nav_bar_settings_page.dart`
- `lib/screens/profile/settings/profile_page.dart`
- `lib/screens/profile/settings/user_information_settings_page.dart`

Localization inputs:

- `lib/l10n/app_bn.arb`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_fr_CA.arb`
- `lib/l10n/app_hi.arb`
- `lib/l10n/app_zh.arb`

Generated localization outputs:

- `lib/l10n/generated/app_localizations.dart`
- `lib/l10n/generated/app_localizations_bn.dart`
- `lib/l10n/generated/app_localizations_en.dart`
- `lib/l10n/generated/app_localizations_es.dart`
- `lib/l10n/generated/app_localizations_fr.dart`
- `lib/l10n/generated/app_localizations_hi.dart`
- `lib/l10n/generated/app_localizations_zh.dart`

Focused test files:

- `test/theme/app_theme_tokens_test.dart`
- `test/theme/n5_route_state_contract_test.dart`
- `test/theme/settings_residue_contract_test.dart`
- `test/theme/widgets/analytics_destination_routes_test.dart`
- `test/theme/widgets/auto_preset_flow_screen_theme_test.dart`
- `test/theme/widgets/catalog_page_theme_ownership_test.dart`
- `test/theme/widgets/flow_methods_page_refinement_test.dart`
- `test/theme/widgets/profile_expressive_presentation_test.dart`
- `test/theme/widgets/profile_settings_expressive_test.dart`

Qualification artifacts are limited to this dated folder. The working-tree change in `docs/theme-style-inventory.json` and other unrelated dirty/untracked material were preserved and not staged.

## Freeze and Git safety

- Normal-width Train and Active Workout presentations were not redesigned. The Flow Methods fix is constrained to narrow non-Expressive layout; Expressive's existing Wrap remains.
- Classic and Neo styles were explicitly preserved in the Catalog/Profile fallback paths; the suite includes theme-family checks. The narrow Flow Methods overflow correction is a responsive layout fix.
- Existing visual approvals remain unchanged. Responsive qualification is independent of those approvals.
- Nothing was staged, committed, pushed, reset, cleaned, or stashed. The malformed local Codex ref was not accessed.

## Follow-up required before qualification can be called green

1. Resolve the 16 exact theme-inventory assertions against the intended candidate source/ownership without weakening scope rules.
2. Decide whether the Flow Editor panel-height change is intentional; if so, update the two focused goldens through the normal review workflow, otherwise correct the layout.
3. Reconcile the 22 theme-style ratchet fingerprint changes through the approved baseline process; do not silently regenerate.
4. Resolve formatter findings without reformatting unrelated dirty file content.
5. Add the missing exact short-height/412 dp/844 × 390 cases and broaden route × scale × theme combinations.
6. Complete open Profile child-route, dialog, locale, accessibility/TalkBack, persistence, and physical-device states documented above.
7. Rerun the complete suite and analyzer after the above decisions and any resulting code changes.

Until those gates are resolved, the candidate can be reviewed visually, but it is not technically or release qualified.
