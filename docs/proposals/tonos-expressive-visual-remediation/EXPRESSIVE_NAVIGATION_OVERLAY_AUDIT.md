# Tonos Expressive Navigation and Overlay Audit

**Audit date:** 2026-10-11

**Branch / source baseline:** `feature/expressive-visual-polish` at `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`
**Classification:** focused source, widget-test, and Pixel 7 interaction audit; not full route qualification.

## Scope and evidence standard

This pass inspected **17 representative navigation path archetypes**, **14 dropdown/popup-menu families** (11 selector groups and 3 popup-menu sites), and **10 dialog/bottom-sheet families** across Catalog, Train/workout selection, Logbook, Progress, Profile analytics/settings, and the shared overlay layer. It followed alternate constructors as well as primary Catalog routes. This is an audit inventory of the implemented high-value paths, not a claim that every button and every overlay instance was physically exercised.

Evidence labels used below:

- **Fixed + widget verified:** the destination or interaction was driven in a focused Flutter widget test after the route change.
- **Fixed + contract checked:** the route builder and its explicit theme ownership were asserted by a focused source-contract test.
- **Source verified:** inspected in current source; no end-to-end runtime claim.
- **Device verified:** exercised on the Pixel 7 in the current no-fixture build.
- **Suspected / unverified:** a source pattern merits later interaction review, but no visible defect has been confirmed.

The earlier `LEGACY_SCREEN_REVIEW_20261011.md` and the existing approval ledger were consulted. Older screenshot sets were treated as historical because their build provenance predates this dirty-tree build. No approval classification was changed.

## Findings summary

- **Direct Classic-only destination widgets confirmed:** 0. A route-name or class-name difference alone was not treated as a defect.
- **Destination-scope omissions fixed:** 13 route-builder sites across 8 pre-existing dirty production files. These paths could lose the intended Catalog or Logbook destination tokens when pushed from a nested/alternate source.
- **Confirmed legacy-styled overlay defects:** 1. The Expressive Catalog filter dropdown used a large square Material menu with no height cap. It was fixed and verified on-device.
- **Additional confirmed defects fixed:** 0. Remaining popup-menu differences are source-only suspicions, not confirmed visual faults.
- **Focused tests:** 127 unique tests passed across route, history, analytics-picking, dropdown, dialog, and Catalog presentation batches. The Catalog presentation file (17 tests) was rerun after the final dropdown correction and passed.
- **Scoped analysis:** 0 errors, 0 warnings, and 1 existing informational deprecation (`dashboard_page.dart:174`, `onReorder` → `onReorderItem`). The separately analyzed Profile and Catalog scopes reported no issues.
- **Classic and Neo:** guarded through explicit Expressive identity; relevant focused checks retained their no-Expressive-scope behavior. No intentional Classic/Neo presentation change was made.

## Navigation matrix

| # | Source → action | Destination / expected owner | Result and verification |
|---:|---|---|---|
| 1 | Dashboard workout report → open session | Session Detail, Logbook destination | **Fixed + contract checked.** Added explicit Logbook destination scope. |
| 2 | Dashboard workout report → all history | Full History, Logbook destination | **Fixed + contract checked.** Added explicit Logbook destination scope. |
| 3 | Dashboard recent workouts → all history | Full History, Logbook destination | **Fixed + contract checked.** Added explicit Logbook destination scope. |
| 4 | Dashboard recent workout → open session | Session Detail, Logbook destination | **Fixed + contract checked.** Added explicit Logbook destination scope. |
| 5 | Dashboard most-used exercises → browse | Exercise Catalog | **Fixed + contract checked.** Explicit Catalog destination tokens and Expressive presentation flag. |
| 6 | Dashboard body-part history → browse | Muscle Filter / body-part focus | **Fixed + contract checked.** Explicit Catalog scope, focus tab, and Expressive flag. |
| 7 | Train drawer → Exercise Catalog | Exercise Catalog | **Fixed + contract checked.** Added Catalog scope and explicit Expressive flag. |
| 8 | Train drawer → muscle/body-part browsing | Muscle Filter | **Fixed + contract checked.** Added Catalog scope and explicit Expressive flag. |
| 9 | Active Workout → Add exercise | Catalog picker | **Fixed + source/contract checked.** Shared add-exercise route now passes the caller’s Expressive state and Catalog scope. |
| 10 | Preset Detail → Add exercise | Catalog picker | **Fixed + source/contract checked.** Same shared component correction as path 9. |
| 11 | Workout exercise → Swap | Catalog picker in swap flow | **Fixed + contract checked.** Preserved the picker callback and added explicit Catalog scope/flag. |
| 12 | Progress → Track exercise | Catalog picker | **Fixed + widget verified.** Expressive opens with Catalog tokens; Classic remains unscoped. |
| 13 | Exercise Analytics → choose from Catalog | Catalog picker | **Fixed + widget verified.** Previously inherited Analytics tokens despite opting into the Catalog recipe; now explicitly scoped. |
| 14 | Exercise Editor → choose from Catalog | Catalog picker | **Fixed + widget verified.** Previously inherited Analytics tokens; now explicitly scoped. |
| 15 | Catalog root → exercise browser | Catalog browser | **Source and focused UI tests verified.** Existing route remains in the Catalog family. |
| 16 | Catalog root → body-part/muscle browsing | Catalog Focus | **Source and focused UI tests verified.** Existing route retains the Catalog family and selected focus. |
| 17 | Exercise browser → exercise information | Exercise Detail sheet | **Source and focused Catalog/detail tests verified.** Catalog caller supplies its Expressive context; other workout-selection sheets intentionally keep their own selection presentation. |

The 13 changed builder sites implement paths 1–8 and 11–14, plus the shared builder used by paths 9–10 (one source site serves two user paths). The existing Catalog root and detail paths were audited but did not need route changes.

## Dropdown and popup-menu matrix

| Family / controls | Finding | Result |
|---|---|---|
| Catalog filter dialog: workspace profile, equipment, focus area, specific muscle | Expressive fields already used Catalog tones, but their standard anchored menus could occupy nearly the whole display, had square corners, and covered the modal’s lower actions. | **Fixed + device verified.** All four Expressive fields now cap menu height at half of the available MediaQuery height and use a 20dp menu radius. Existing surface/text tokens, selection values, and anchored dropdown behavior remain. Non-Expressive values stay `null` and unchanged. Long menus scroll. |
| Profile analytics selection controls | Reviewed caller theme and interaction tests. | **Source/widget verified.** Existing options remain dropdowns; no confirmed legacy presentation defect. |
| Exercise Editor selection fields | Reviewed explicit theme path and editor tests. | **Source verified.** No confirmed defect; Classic/Neo remain outside the Catalog wrapper. |
| Anatomy Mapping body-part selector | Uses the approved anchored `MenuAnchor` pattern with root overlay, viewport-bounded height, selected surface, and outside-tap behavior. | **Source/widget verified.** No change. |
| Volume Boundaries selector | Uses the established anchored `MenuAnchor` pattern with viewport bound and Expressive tokens. | **Source verified.** No change. |
| Flow Methods Add Rule: type and operation | Uses the dialog dropdown component; row action also has a `PopupMenuButton`. | **Focused widget tests passed.** No confirmed visual defect. Row action menu appearance remains source-only. |
| AutoPresetFlow type and operation selectors | Reviewed Expressive form branches and screen tests. | **Focused widget tests passed.** No confirmed route/style defect. Runtime keyboard and long-content states remain unverified. |
| Health Trends metric selector | Source-reviewed as an Expressive Progress interaction. | **Source verified.** No confirmed defect. |
| Preset Detail overflow menu | Raw `PopupMenuButton` on an Expressive-capable page. | **Suspected / unverified.** Flutter theme may provide the intended surface; no runtime mismatch was confirmed. |
| Health Trends row actions | Raw `PopupMenuButton`. | **Suspected / unverified.** Do not infer a defect from the widget class alone. |

The **Catalog Equipment menu** was opened on-device. Before the fix, it rendered as a square, near-full-height blue menu and reached the Android navigation area. After the fix it remained anchored, showed the selected item distinctly, was rounded, stayed above the bottom navigation region, and exposed a scrollable subset of the long option list. Back closed only the dropdown; the parent filter dialog remained. An outside tap then closed that dialog. No filter value was selected.

## Dialog and bottom-sheet matrix

| Family | Review result |
|---|---|
| Catalog “Selected Filters” modal and nested filter dropdown | **Device verified in light mode.** The filter surface remains an intentional modal; its Equipment selector remains an anchored dropdown, now bounded and rounded as described above. |
| Shared `TonosDialogFrame` | **Source and focused tests reviewed.** It has a Neo-specific wrapper and passes Expressive children through; Expressive callers must provide the intended theme/content themselves. No broad wrapper change was justified. |
| Flow Methods “Add Rule” dialog | **Focused widget tests passed.** Fields and anchored selection behavior retained. |
| AutoPresetFlow editor dialogs | **Focused widget tests passed.** No confirmed Classic-route or dismissal defect. |
| Profile User Information selection dialogs | **Source reviewed as modal selections.** Preserved as intentional modal choices; no change to shared selection behavior. |
| Dashboard hidden-section dialog | **Source reviewed.** No runtime check; the dashboard is a configurable/secondary route. |
| Exercise Detail bottom sheet | **Source and focused Catalog detail tests reviewed.** No confirmed route or theme leak from Catalog. |
| Swap Exercise sheet | **Source reviewed and caller route corrected.** Interaction remains a selection sheet, with Catalog destination ownership applied to the picker it opens. |
| Preset Detail workout-settings sheet and Session Complete sheet | **Source reviewed.** No runtime confirmation in this pass; no visual defect confirmed. |

No destructive confirmation, save/discard, or persistence behavior was changed. Further keyboard-open and unusually long-content overlay checks remain part of technical qualification, not visual approval.

## Production files changed by this pass

The working tree already contained unrelated edits in several of these files. The changes attributable to this audit are limited to the route-scope and Catalog menu hunks below; all other pre-existing modifications were preserved.

| File | Affected interaction | Change |
|---|---|---|
| `lib/screens/dashboard_page.dart` | Report → Session Detail / Full History | Scoped pushed destinations to Logbook tokens. |
| `lib/widgets/dashboard_sections.dart` | Recent history, Most Used, anatomy shortcuts | Scoped history destinations to Logbook and Catalog destinations to Catalog. |
| `lib/screens/exercise/train2_page.dart` | Train drawer Catalog / Muscle Filter | Passed explicit Catalog scope and Expressive flag. |
| `lib/widgets/add_exercise_fab.dart` | Add exercise from Active Workout / Preset Detail | Propagated the caller’s Expressive picker flag and Catalog token scope. |
| `lib/widgets/swap_exercise_sheet.dart` | Swap exercise picker | Added Catalog token scope and explicit family flag. |
| `lib/widgets/exercise_progress_section.dart` | Progress exercise picker | Added Catalog scope only for Expressive; Classic path is unchanged. |
| `lib/screens/profile/settings/exercise_analytics_screen.dart` | Exercise Analytics Catalog picker | Corrected inherited destination tokens to Catalog. |
| `lib/screens/profile/settings/exercise_editor_screen.dart` | Exercise Editor Catalog picker | Corrected inherited destination tokens to Catalog. |
| `lib/screens/exercise/exercise_catalog_page.dart` | Expressive filter dropdown menus | Added a half-viewport menu cap and 20dp corners for the four Expressive filter dropdowns only. |

Focused regression files are `test/theme/expressive_interaction_route_contract_test.dart`, `test/theme/widgets/exercise_progress_catalog_route_test.dart`, `test/theme/widgets/exercise_analytics_screen_theme_test.dart`, `test/theme/widgets/exercise_editor_expressive_presentation_test.dart`, and `test/expressive_catalog_browser_presentation_test.dart`. The first two are new route checks; the Analytics and Editor test files were already dirty and received task-related assertions, while the Catalog presentation test received only the new menu assertions.

## Focused tests and checks

| Validation | Result |
|---|---|
| Route/history focused batch (Dashboard contracts, Progress picker, anatomy routes, history and Session Detail ownership) | **45 passed** |
| Overlay/Catalog/Profile focused batch (Flow Methods, AutoPresetFlow, analytics dropdowns, TonosDialog, Catalog browser/detail) | **80 passed** |
| Profile Analytics and Exercise Editor destination-token tests | **2 passed** |
| Final Catalog presentation suite after menu correction | **17 passed** |
| Unique focused test count | **127 passed, 0 failed.** The 17-test Catalog file is included in the 80-test batch and was rerun after the final fix, not double-counted. |
| Scoped Dart analysis | **0 errors, 0 warnings, 1 existing info** (`dashboard_page.dart:174` deprecated `onReorder`). Profile and Catalog scoped analyses reported no issues. |
| Formatter | The final formatter check for `exercise_catalog_page.dart` and its focused test passed. The earlier check on six already-dirty, long legacy files proposed additional whole-file layout changes, which were not applied to avoid unrelated churn. |
| `git diff --check` | Passed for the focused source/test changes; final workspace check is recorded in the closeout response. |
| Full repository suite / full analysis | Not run. |

## Pixel 7 verification and local evidence

- **Device:** Pixel 7 `28021FDH200228`.
- **Package:** `com.tonos.expressivepreview` (`versionName 1.0.1`).
- **Build:** debug APK built from the working tree using the temporary no-fixture entrypoint, `--no-pub`, `TONOS_EXPRESSIVE_PREVIEW=true`, and database name `tonos_expressive_preview.db`. The standard fixture-preparation entrypoint was not used.
- **APK SHA-256:** `D6C65EFC7D9CE8A419129AC65F5509F84C270779C38AA194A81A696D0F070C71`.
- **Device path exercised:** Train shell → Catalog tab → exercise browser → Filters modal → Equipment anchored dropdown → Back closes dropdown → outside tap closes modal → Back returns to Catalog root.
- **Observed:** Correct Expressive Catalog surfaces and text; dropdown is bounded and rounded after the fix; parent/child dismissal order is correct. Dark mode and other route families were not physically exercised in this pass.
- **Database safety:** Before interaction, backed up `tonos_expressive_preview.db`, its `-wal` and `-shm` files, and `FlutterSharedPreferences.xml`; force-stopped the app and restored those exact files after the checks. The app is left stopped with the isolated current-source package installed. Production Tonos was not launched or touched.
- **Local-only screenshots:** outside the repository under `C:\Users\talh7\AppData\Local\Temp\tonos-expressive-interaction-audit-20261011\`. `catalog-filters-expressive-light.png` and `catalog-equipment-anchored-menu-expressive-light.png` show the pre-fix states; `catalog-equipment-anchored-menu-after-fix-expressive-light.png` shows the corrected state. No screenshot media was added to the repository.
- The temporary no-fixture Dart entrypoint used to build was removed after installation. No temporary capture hook remains in source.

## Design-system, protected-screen, and data safety

- Catalog routes now install Catalog destination tokens explicitly instead of inheriting Analytics, Train, or generic shell tokens.
- Logbook details opened from Dashboard explicitly install Logbook tokens.
- Theme checks use explicit `usesExpressivePresentation` and destination-family wrappers; no `!Classic` inference was introduced.
- The Catalog dropdown keeps its existing palette and interaction model; this is a geometry/viewport correction, not a Catalog redesign.
- Classic and Neo code paths were left unmodified by these corrections and were covered by focused fallback assertions where relevant.
- No visual approval ledger, ranking/data behavior, database schema, calculations, or approval classification was changed.
- No files were staged; no commit or push was made.

## Remaining issues and manual review queue

### P1 — verify before broad technical qualification

1. Exercise the three raw popup-menu sites on-device in light/dark: Preset Detail overflow, Flow Methods rule actions, and Health Trends entry actions. They are **suspected only**; current source does not prove they render incorrectly.
2. Exercise AutoPresetFlow dialogs with keyboard open, long content, Back, and outside dismissal; focused widget tests passed but device states were not captured.
3. Exercise add/swap picker return flows from Active Workout and Preset Detail against the current APK. Their theme-scope changes are contract/source verified; they were not navigated physically to avoid altering active workout or plan data.

### P2 — additional runtime coverage

4. Exercise Catalog profile/equipment/focus/muscle selectors in dark mode and with large text; widget tests cover light/dark and 320dp/2x, but only Equipment was physically opened in light mode.
5. Verify Logbook Full History → Session Detail and Dashboard → history return navigation physically. Focused tests cover ownership and route contracts.
6. Verify Profile Analytics and Exercise Editor picker flows on-device, including return and saved form state.
7. Review Health Trends and Workout Session sheets with keyboard/insets and navigation-bar clearance.

### P3 — broader qualification

8. Run the repository’s planned responsive/accessibility and full-suite qualification separately. This audit did not establish release readiness.

## Final status

Confirmed destination-scope gaps and the one on-device Catalog menu defect were corrected. Focused tests and a representative physical interaction passed. The audit is **not** a claim of exhaustive device coverage, complete accessibility qualification, full test-suite success, or release readiness. Remaining source-only and runtime-unverified states are listed above.

## Follow-Up Interaction Verification — 2026-10-11

This follow-up reviews each of the five manual interaction-review items from the preceding audit and records what was verified, fixed, or left unverified. It does not change visual-approval classifications, and visual verification here is not technical or release qualification. The three earlier P1 popup bullets are superseded by the results below; the broader Catalog, history, settings-picker, and full qualification items in the earlier P2/P3 list remain open.

### Build and evidence provenance

- **Repository:** `E:\projects\env_test`; branch `feature/expressive-visual-polish`; source HEAD `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`. The working tree was already extensively dirty; this candidate was built from that working tree without staging or committing.
- **Device:** Pixel 7 `28021FDH200228`, physical capture size 1080 × 2400.
- **Installed package:** `com.tonos.expressivepreview`, versionCode 6, versionName 1.0.1. Production Tonos was not launched.
- **Candidate APK:** `build/app/outputs/flutter-apk/app-debug.apk`; SHA-256 `91AFB3AE4E7171D2F2A7E1E144756A6C75C88B89B9161D66EF7E41C39345DCB3`.
- **Preview safety:** The non-reseeding preview build path was used. After interaction checks, the app was force-stopped and the original `tonos_expressive_preview.db`, `-wal`, `-shm`, and `FlutterSharedPreferences.xml` were restored. Device readback hashes match the pre-check snapshot for all four files. The app is left stopped with the isolated preview installed.
- **Local evidence folder:** `C:\Users\talh7\AppData\Local\Temp\tonos-expressive-final-interaction-review-20261011-180559\captures\followup-current-build\`. Screenshot media remains local and is not in the repository. The newer `*-recheck-final-current-apk-*` captures have explicit light/dark names; some older files in the folder have misleading `light` suffixes and are not cited below.

#### Key screenshot index

These filenames are relative to the local evidence folder above; PNGs are opened UI states and XML files alongside them are UI hierarchy captures. Current-candidate captures correspond to the APK SHA-256 above unless specifically labeled as an earlier candidate.

| Review | Current-candidate evidence | Coverage note |
|---|---|---|
| Preset Detail | Light: `preset-overflow-recheck-final-light.png`, `preset-delete-confirm-recheck-final-light.png`, `preset-exercise-menu-recheck-final-light.png`, `preset-swap-sheet-recheck-final-light.png`, `preset-swap-picker-selected-recheck-final-light.png`, `preset-swap-return-recheck-final-light.png`, `preset-swap-cancel-recheck-final-light.png`. Dark: `preset-overflow-recheck-final-dark.png`. | Dark delete-confirm/swap captures are `preset-delete-confirm-dark.png`, `preset-swap-sheet-dark.png`, `preset-swap-picker-dark.png`, and `preset-swap-after-picker-dark.png` from the earlier final candidate; the follow-up change after those captures was limited to AutoPresetFlow controller ownership. The state-changing Make Automatic and Plan Progression options were not activated. |
| Flow Methods | `flow-methods-menu-recheck-final-light.png`, `flow-methods-menu-recheck-final-dark.png`, `flow-method-edit-recheck-final-light.png`. | Popup captured in both themes; nested edit dialog captured in light mode. Delete on the disposable app-default rule was immediate and the original snapshot was restored. |
| Health Trends | Light and dark `health-trend-detail-recheck-final-current-apk-*`, `health-entry-menu-recheck-final-current-apk-*`, `health-entry-edit-recheck-final-current-apk-*`, and `health-entry-delete-confirm-recheck-final-current-apk-*` PNGs. | Detail, action menu, edit dialog, and delete confirmation captured in both themes; confirmations canceled. |
| AutoPresetFlow | Both light and dark: `autopreset-new-dialog-final-*`, `autopreset-type-menu-final-*`, `autopreset-add-set-final-*`, `autopreset-keyboard-final-*`, `autopreset-keyboard-dismissed-final-*`, `autopreset-validation-final-*`, and `autopreset-cancel-final-*` PNGs. | Pixel 7 keyboard/normal-content states are captured. Compact 320dp and maximum-length stress states were not captured. |
| Add / swap pickers | Active Workout dark: `active-workout-add-picker-final-dark.png`, `active-workout-add-selected-final-dark.png`, `active-workout-add-return-final-dark.png`. Preset Detail light: `preset-swap-sheet-recheck-final-light.png`, `preset-swap-picker-recheck-final-light.png`, `preset-swap-picker-selected-recheck-final-light.png`, `preset-swap-return-recheck-final-light.png`, `preset-swap-cancel-recheck-final-light.png`. | Earlier final-candidate dark swap states are listed in the Preset Detail row. The Active Workout add check was captured in dark mode only. No workout was finished; the preview snapshot was restored afterward. |

### Five interaction reviews

| Review item | Light mode | Dark mode | Behavior and result |
|---|---|---|---|
| Preset Detail overflow | Current-candidate menu and Delete confirmation opened; Cancel returned to the preset. | Current-candidate overflow menu opened and stayed within the screen edge. Earlier candidate evidence also covers the dark Delete confirmation. | Outside/back menu dismissal and nested exercise-menu → Swap Exercise flow returned to the correct parent. The delete confirmation was canceled. Make Automatic and Plan Progression were not activated because they mutate plan state; their outcomes remain source-reviewed rather than device-verified. **Verified with that action boundary.** |
| Flow Methods rule-action popup | Current-candidate anchored Edit/Delete menu and Edit App Default Rule dialog captured. | Current-candidate anchored Edit/Delete menu captured. | Edit stayed in Flow Methods and its dialog remained open over the parent. Delete directly removed the disposable `AuditFollowUp` preview rule without a confirmation dialog; no intended confirmation contract was found, so behavior was not changed. The original database snapshot restores the rule. **Popup verified; immediate-delete behavior documented.** |
| Health Trends row-action popup | Current-candidate Weight entry menu, Edit Weight dialog, and Delete entry confirmation captured. | Current-candidate detail, entry menu, edit dialog, and delete confirmation captured. | Edit and Delete targeted the selected entry; Delete confirmation was canceled. Back returned to the trend detail. **Verified.** |
| AutoPresetFlow dialogs | New Action, anchored type menu, Add Set options, keyboard-open form, inline empty-name validation, keyboard dismissal, and Cancel captured. | The same principal dialog, menu, validation, keyboard, and return states captured. | Gboard appeared and dismissed without covering the actions; Cancel returned to the editor without a Flutter error after the controller-lifecycle fix. Long-label/max-content stress and a separate compact 320dp physical capture were not performed. **Keyboard and normal dialog flow verified; extreme content remains unverified.** |
| Active Workout / Preset Detail add-swap pickers | Current-candidate Preset Detail edit menu → swap sheet → Catalog picker → selected exercise returned to the sheet as a pending replacement; Cancel returned to edit mode without confirming. | Current-candidate picker selection and return states captured. | Active Workout Add opened the Expressive Catalog picker; selecting Arnold Press and pressing Add returned to the session and added the exercise. Scrolling and resuming showed the additions in the active draft. The repeated device check intentionally added the same test selection twice; no workout was finished, and the exact original database/preferences snapshot was restored. Preset swap was canceled before Confirm Swap. **Destination, return value, target, and cancel behavior verified.** |

### Confirmed findings and corrections

- **One confirmed functional defect fixed:** AutoPresetFlow could dispose text controllers while the closing dialog route was still mounted after keyboard dismissal, producing a Flutter framework assertion. Controller ownership now follows the dialog subtree's actual unmount. The keyboard-dismiss → Cancel widget regression test passes, and the same physical sequence was rechecked on the Pixel 7.
- **Expressive overlay consistency corrections:** the Preset Detail overflow menu, WeightCard exercise-action menu, Flow Methods rule-action menu, and Health Trends entry-action menu now use the intended Tonos Expressive tonal surfaces and corner treatment. The shared TonosDialog Expressive dropdown uses the scoped tonal foreground/surface and rounded anchored menu treatment. AutoPresetFlow's Add Set choices use a vertical Expressive choice layout, and its empty action-name validation remains inline.
- No incorrect Classic destination was found among these five workflows. No route/business-data calculation, approval record, or SQLite schema change was made. Classic and Neo styling branches remain opt-in and unchanged.
- Flow Methods Delete is currently immediate and has no confirmation step. The task's tested behavior was preserved; this is recorded as an interaction note, not treated as a confirmed defect without an established product contract.

### Source and test files

Production files changed by the follow-up:

- `lib/screens/exercise/preset_detail_screen.dart`
- `lib/screens/exercise/auto_preset_flow_screen.dart`
- `lib/screens/profile/settings/flow_methods_page.dart`
- `lib/theme/widgets/tonos_dialog.dart`
- `lib/widgets/health_trends_section.dart`
- `lib/widgets/weight_card.dart`

Focused regression files:

- `test/expressive_catalog_browser_presentation_test.dart`
- `test/expressive_active_workout_presentation_test.dart`
- `test/theme/expressive_interaction_route_contract_test.dart`
- `test/theme/widgets/auto_preset_flow_screen_theme_test.dart`
- `test/theme/widgets/exercise_progress_catalog_route_test.dart`
- `test/theme/widgets/flow_methods_page_refinement_test.dart`
- `test/theme/widgets/health_trends_chart_accessibility_test.dart`
- `test/theme/widgets/preset_detail_screen_theme_test.dart`
- `test/theme/widgets/tonos_dialog_test.dart`
- `test/theme/widgets/weight_card_theme_scope_test.dart`

Validation on the current source candidate:

| Check | Result |
|---|---|
| Focused Flutter batch (the ten files above) | **123 passed, 0 failed.** |
| Scoped `dart analyze` (six production and ten test files) | **0 errors, 0 warnings, 13 infos.** Infos are existing deprecation notices (`Radio.groupValue` / `onChanged`, plus `onReorder`). |
| Dart format check | **15 checked, 0 changed.** |
| `git diff --check` | Recorded in the closeout after this report update. |
| Full repository tests/analyzer | Not run. |

The temporary no-fixture entrypoint `lib/expressive_capture_main.dart` was removed from the source tree after installation. No temporary capture hook remains in `lib/`.

### Remaining qualification and review limits

1. Visually inspect the fresh light/dark captures in the local evidence folder; agent verification does not constitute user visual approval.
2. Preset Detail's state-changing Make Automatic / Plan Progression paths were not activated. Flow Methods immediate deletion has no confirmation by current implementation and should only be changed if the product contract is reopened.
3. AutoPresetFlow maximum-length content, extreme text scaling, and compact 320dp physical layout remain unverified here.
4. Full responsive/accessibility qualification and the repository-wide test suite remain separate work. This follow-up makes no release-readiness claim.

No screen approval status was changed. No files were staged; no commit or push was made.

## C/D implementation follow-up — 2026-10-12

This is a focused source/test follow-up to the 2026-10-11 route-and-overlay audit, not a repeat of its device pass. The previously reported 17 representative path archetypes, 14 dropdown/popup-menu families, and 10 dialog/sheet families remain the counts for that 2026-10-11 inventory; this follow-up does not add an uncounted set to those totals or claim app-wide runtime coverage.

| Scope | Source-level result | Runtime/evidence boundary |
|---|---|---|
| Onboarding Included Equipment summary and selected chips | Replaced the remaining generic neutral treatment with planning tones in Expressive. Selection and completion behavior is unchanged. | Focused widget/flow tests pass; no current-source device capture was made. Historical bootstrap images predate this refinement. |
| Onboarding → Skip setup | Replaced the stock-looking confirmation with a route-local Expressive plum dialog, readable foreground and mint confirmation. Draft data, skip/completion behavior, and next-route handoffs remain unchanged. | Focused widget/flow tests pass; modal appearance remains for the user to review on a current build. |
| Dashboard root; Weekly Sets Overview; Preset Generation QA | Current Expressive source and focused tests were checked. No confirmed incorrect Classic destination or additional redesign defect was found; routes are now B implementation candidates. | No current-source device navigation or screenshots in this follow-up. Prior captures are historical and must not be presented as current-source proof. |
| Plan-specific Flow Methods editor and Add Rule entry | Confirmed separate from the A-approved FlowMethodsPage and AutoPresetFlowScreen. The dialog uses Tonos fields, an anchored Expressive choice menu, scrollable content, and existing save/cancel behavior; no new source fix was justified. | Existing 2026-10-11 evidence covers light editor presentation and action menus in both modes. Dark editor, keyboard and unusual viewport remain unverified; focused tests passed. |
| Health metric create/log/edit/delete and entry action menu | Tracked by caller: Progress metric creation and trend-card entry; Profile → Progress Settings → Measured Items create/log; Measurement Trend detail → Entries → row menu for edit/delete. These are interaction states, not page archetypes. | Existing 2026-10-11 device evidence covers the Measurement Trend detail action/edit/delete path in light/dark; focused Health tests passed. The A-approved Progress-origin Log Measurement dialog does not extend approval to Profile callers. Other caller, keyboard and large-text states remain unverified. |
| Workout/session dialogs and sheets | Existing screen-owned Expressive scope remains protected. Only caller/state combinations outside current A approvals remain pending; no shared behavior was changed in this follow-up. | Rely on the scoped 2026-10-11 evidence and tests listed above; no new Pixel interaction occurred. |

Five page candidates are in the current visual queue in this order: Onboarding; Preset Generation QA; Analytics Dashboard / Weekly Sets Overview; Dashboard root; plan-specific Flow Methods editor. This is pending user review, not approval. The 55-archetype C/D aggregate remains unresolved because the historical C/D tables do not map uniquely to the stated denominator. No current device build or screenshot was produced, no preview database/preferences were touched, and no approval status changed. Focused validation for this follow-up totaled 67 passing tests across seven files; onboarding analysis was clean, while Flow Methods reported two informational deprecated Radio notices and no errors or warnings. The full repository suite was not run.
