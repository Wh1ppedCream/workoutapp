# E2 Route Disposition And Current Slice

Status: the route and caller inventory is complete as of 2026-09-16. The
initial migration slice passed 181 user-run scoped tests; the theme-ready
compatibility extension and its source-boundary contract are recorded. The
current 21-item Neo visual review is accepted. Step 14's localized family
selector is implemented and automated-verified. The focused E2.2/E2.3 and N5
source/behavior contracts were included in the 2026-09-22 user-supplied
verifier run: formatting reported 135 files with 0 changes; analysis was clean;
the theme suite passed 321 tests, the responsive suite passed 6 tests, the
route-boundary batch passed 46 tests, and the enforce-mode ratchet passed with
one protected production file. The corrected verifier scope includes
`lib/utils/app_test_keys.dart` and
`test/theme/health_measurements_tokens_test.dart`; this successful rerun
closes that scope-only check. BodyHeatmap diagnostics showed active SVG paths
for the tested palettes. The user subsequently confirmed all items
in the human/device/N6 qualification checklist for the current working tree;
the development qualification and E2.4 closeout are recorded below. Step 15
release qualification remains separate.
The 2026-09-23 TonosSurfaceTheme refactor in Flow Methods and Workout Progress
Flows replaces two flow-card Theme boundaries. Its focused test batch passed
46 tests and analysis was clean; a later suite passed 44 tests and failed only
the production ratchet contract on three then-unapproved fingerprints. Those
exact statements were reviewed and approved before the 120-test run and
two-file report/enforce passed. The latest September 24 inventory covers 278
Dart files / 2,293 candidates (70 allowlisted, 1,224 migrated, 999 pending,
zero review and zero unassigned); all 11 identity-color findings are now
allowlisted. The user visually
accepted the current Flow Methods and Workout Progress Flows appearance,
including the Neo-dark Add App Default Rule dropdown contrast correction. The
user also accepted the Exercise Progress chart and the Preset Generation QA /
Food Customization ExpansionTiles. The prior five-file suite passed all 26
tests, including the ExpansionTile inheritance regression. A later focused
corrected contract/drawers/settings run passed all 37 tests; formatting reported
no changes and analysis found no issues.
Nested persistence/editing review is explicitly deferred.
The darker Neo-dark
settings validation-error change passed formatting, analysis, and 32 focused
tests; the user accepted its device appearance on 2026-09-24.
After the prior widget suite, SettingsExpansionSection began using the shared
divider scope. The latest inventory includes that edit and no longer reports
the former divider candidate; its integration assertion passed in the latest
settings test run.
See [current pre-Q2 follow-ups](theme-pre-q2-closeout.md) for current
automated results and remaining release/design decisions. Older row-level
`pending` labels and the pre-closeout checklist below describe their original
checkpoint; the 2026-09-17 development qualification confirmation supersedes
them for the current working tree. The verifier-scope rerun completed on
2026-09-22 and is recorded above.
This is not a complete release-qualification proof. Do not advance to Step 15
release approval on this record alone. The route inventory closure and current
development qualification are recorded below.

## Route Ledger Closure (2026-09-16)

The inventory below was traced from `lib/main.dart`, `NavBarConfig`,
`NavigationBuildPolicy`, `CatalogPage`, `ProfilePage`, the Nutrition drawer,
dashboard callers, and nested `Navigator`/dialog/sheet calls. A source file
without a caller is recorded as unreferenced rather than treated as reachable.

Disposition meanings:

- `reachable`: a current caller or configurable tab can open the route.
- `experimental`: available only under the existing development navigation
  policy and denied by release builds where that policy applies.
- `placeholder`: intentionally incomplete product surface retained in the tree
  and requiring a separate product decision.
- `source-ready`: ownership and automated source contracts exist, but device,
  accessibility, or complete non-happy-path evidence is pending.
- `unreferenced`: no production caller was found; this is not approval to
  delete or expose the route.

### Canonical E2.1 Route Matrix

The matrix below is the authoritative E2.1 ledger. It includes the nested
destinations found by following supported Navigator pushes from the main tabs,
settings, onboarding, drawers, cards, and shared action bars. Every row records
the E2.1 fields: entry point, destination, shared consumers, visibility,
state coverage, visual owner, batch ID, verification evidence, and remaining
manual check or approved exclusion.

The shorter tables below are readable summaries only. They are not separate
inventories and do not override this matrix.
For the current working tree, the user qualification confirmation recorded
below supersedes pending wording in the state-check column; retained placeholder
and unreferenced-route decisions remain unchanged.

The machine-checkable guard for this matrix is
test/theme/e2_route_ledger_contract_test.dart. It verifies exact row ordering,
the 12-column schema, route names, concrete source-file paths,
constructor-level nested caller edges, and concrete evidence paths. It does
not replace manual visual, accessibility, or physical-device qualification.

| ID | Entry point | Destination file/widget | Shared widgets/services | Visibility | State coverage | Visual owner | Batch ID | Verification evidence | Outstanding checks / decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R00 | App startup | lib/main.dart: _StartupGate, OnboardingFlow, MainScreen | AppConfiguration, theme bootstrap, navigation policy | Release | startup loading; first-run; normal app | app shell / BASE | BASE | lib/main.dart; test/providers/app_configuration_test.dart | N6 startup, restart, persistence, and accessibility evidence |
| R01 | Main shell default tab | lib/screens/exercise/train_page.dart: TrainPage | plan bars, profile header, tutorials, active-session actions | Release | loading/error/empty/populated plans; drawers; workout entry | Train surface / B1 | B1 | current 21-item Neo review; train-focused source contracts | N5 non-happy-path and N6 device review |
| R02 | Train, Train2, dashboard, FAB, quick actions, session detail | lib/screens/exercise/session_screen.dart: SessionScreen | workout cards, controls, ongoing-session state, workout exit actions | Release when caller reachable | loading; empty; editing; completed; finish busy/error/discard | Workout/session surfaces / B2 | B2 | test/theme/widgets/neo_workout_readability_test.dart; workout control tests | finish/error/discard lifecycle and real-device keyboard/rotation |
| R03 | Train, Train2, dashboard preset bars, onboarding | lib/screens/exercise/preset_detail_screen.dart: PresetDetailScreen | preset bars, exercise detail, session entry, exit dialogs | Release when caller reachable | loading/error/empty/populated; editing; discard/save | Preset surfaces / B3 | B3 | source trace; accepted Train/Train2 visual review | nested editor and destructive-state device review |
| R04 | Train, Train2, dashboard, onboarding | lib/screens/exercise/preset_generation_qa.dart: PresetGenerationQaScreen | preset generation cards, dialogs, save/cancel actions | Release when caller reachable | loading/error; choices; generated/empty; editing; save/cancel | Preset-generation surface / B3 | B3 | source trace; pre-Q2 route evidence | generation failure, persistence, and N6 review |
| R05 | Train optimized action; Train2 settings dialog | lib/screens/exercise/optimized_workout_settings_page.dart: OptimizedWorkoutSettingsPage | settings fields, recommendation controls, save/cancel | Release when caller reachable | populated; editing; validation; cancel/save | Workout settings / B4 | B4 | current 21-item Neo visual review; settings tests | validation, keyboard, persistence, and N6 review |
| R06 | Train, Train2, drawer, onboarding | lib/screens/exercise/gym_profile_screen.dart: GymProfileScreen | profile fields, media, unsaved-exit dialog | Release when caller reachable | loading; populated; editing; validation; unsaved exit | Gym profile / B5 | B5 | current 21-item Neo visual review; source trace | save/error/unsaved dialog, keyboard, and N6 review |
| R07 | Train, dashboard | lib/screens/exercise/plan_management_page.dart: PlanManagementPage | plan lists, plan editor actions, session/preset links | Release when caller reachable | loading/error/empty/populated; editing; delete/restore | Plan-management surface / B6 | B6 | source trace; pre-Q2 route evidence | nested edit/delete/reorder states and device review |
| R08 | Train, dashboard, onboarding | lib/screens/exercise/premade_plans_page.dart: PremadePlansPage | plan cards, preset detail, generation entry | Release when caller reachable | loading/error/empty/populated; selection; back/cancel | Premade-plan surface / B6 | B6 | source trace; accepted Train2 visual review | failed load, selection persistence, and N6 review |
| R09 | Train, dashboard | lib/screens/exercise/analytics_dashboard_screen.dart: AnalyticsDashboardScreen | definition cards, body heatmap links, progress summaries | Release when caller reachable | loading/error/empty/populated; selection | Analytics dashboard / D1 | D1 | source trace; theme-ready consumer tests | body-part/muscle route evidence and large-text review |
| R10 | Main shell Catalog tab | lib/screens/catalog_page.dart: CatalogPage | heatmap, catalog cards, tutorials, active-session refresh | Release | loading/error/empty/populated; tutorial overlay; refresh | Catalog overview / C2 | C2 | catalog and Neo refinement tests | C2/C3 state and N6 device review |
| R11 | Catalog overview, Train2, exercise editor | lib/screens/exercise/exercise_catalog_page.dart: ExerciseCatalogPage | search field, filters, media thumbnails, detail sheet | Release when caller reachable | loading/error/empty/populated; search; filters; selection | Exercise catalog / C2 | C2 | current Neo visual review; refinement regression tests | no-results/error, keyboard, localization, and N6 review |
| R12 | Catalog filter action, Train2, dashboard, editor picker | lib/screens/exercise/muscle_filter_page.dart: MuscleFilterPage | filter tabs, localized catalog names, definition links | Release when caller reachable | empty/populated; selected; back/save | Catalog filtering / C2 | C2 | current Neo visual review; source trace | selection persistence, long labels, and device review |
| R13 | Catalog anatomy, analytics dashboard, muscle filter | lib/screens/exercise/definitions_by_bodypart_page.dart: DefinitionsByBodyPartPage | definition cards, media, cross-link to muscle definitions | Release when caller reachable | loading/error/empty/populated; selection | Definition surfaces / C3 | C3 | source trace; theme-ready consumer parity | route recipe, media, and N6 review |
| R14 | Catalog anatomy, analytics dashboard, body-part definitions | lib/screens/exercise/definitions_by_muscle_page.dart: DefinitionsByMusclePage | definition cards, media, cross-link to body-part definitions | Release when caller reachable | loading/error/empty/populated; selection | Definition surfaces / C3 | C3 | source trace; theme-ready consumer parity | route recipe, media, and N6 review |
| R15 | Catalog row and definition actions | lib/widgets/exercise_detail_sheet.dart: ExerciseDetailSheet | Tonos sheet, tabs, media, history/report actions | Release when caller reachable | details/metrics/records; empty/loading/error; scroll/resize | Exercise detail sheet / C3 | C3 | test/theme/exercise_detail_contract_test.dart; test/theme/widgets/tonos_sheet_test.dart | real media, nested session return, and N6 review |
| R16 | Detail media and definition cards | lib/widgets/exercise_media_thumbnail.dart, lib/widgets/shared_entity_media_thumbnail.dart, lib/theme/widgets/media_viewer_image.dart | media tokens, viewer route, fallback/error UI | Release when media exists | missing/loading/error; zoom/pan; dismiss/back | Media viewer / C3 | C3 | test/theme/media_viewer_test.dart | real-device media lifecycle, image failures, and performance |
| R17 | Detail, dashboard, logbook, progress, session history | lib/screens/exercise/full_history_screen.dart: FullHistoryScreen | history content, session cards, refresh, session detail | Release when caller reachable | loading/error/empty/populated; selection; return refresh | History surfaces / D1 | D1 | source trace; dashboard/history compatibility coverage | device/state evidence and large-text review |
| R18 | History, full history, dashboard, detail sheet, progress | lib/screens/exercise/session_detail_screen.dart: SessionDetailScreen | history content, session actions, session entry, dialogs | Release when caller reachable | loading/error/empty/populated; edit; discard/rename/restart | Session history / D1 | D1 | source trace; exercise-detail contract coverage | destructive/restart states and N6 review |
| R19 | Main shell Logbook tab | lib/screens/exercise/history_screen.dart, lib/widgets/history_content.dart | calendar, past sessions, tutorial, full history | Release | loading/error/empty/populated; date selection; refresh | Logbook / D1 | D1 | test/theme/dashboard_history_contract_test.dart; history source trace | device/state evidence and accessibility review |
| R20 | Dashboard tab | lib/screens/dashboard_page.dart, lib/widgets/dashboard_sections.dart: DashboardPage | DashboardConfig, section cards, edit/reorder controls | Release when enabled | loading/error/empty; edit/reorder; hidden/visible; restore | Dashboard / D1 | D1 | test/theme/dashboard_history_contract_test.dart; test/theme/dashboard_history_tokens_test.dart | configurable-tab reachability and manual/device state review |
| R21 | Main shell Progress tab; dashboard health/progress modules | lib/screens/measurement_trends_page.dart: MeasurementsTrendsPage | exercise progress, metric chart, health trends, tutorials | Release | loading/error/empty; one-entry; populated; range/details | Progress and trends / D2-D3 | D2-D3 | test/theme/widgets/workout_metric_chart_card_responsive_test.dart; health/measurement tests | large text, long values, accessibility, and N6 review |
| R22 | Progress health section | lib/widgets/health_trends_section.dart: MeasurementTrendDetailPage | health chart/grid, measurement repositories, date/time pickers | Release when Progress/Nutrition caller is reachable | empty/one-entry/populated; editing; delete/refresh | Health trends / D3 | D3 | test/theme/health_measurements_contract_test.dart; test/theme/health_measurements_tokens_test.dart | route-level behavior, date/time keyboard, and device review |
| R23 | Progress exercise section | lib/widgets/exercise_progress_section.dart: _ExerciseProgressDetailPage | progress chart, metric cards, session-detail return | Release when Progress caller is reachable | empty/one-entry/populated; range/details; loading/error | Exercise progress / D2 | D2 | test/theme/widgets/exercise_progress_responsive_test.dart | private nested page needs route-level state and device evidence |
| R24 | Nutrition configurable tab | lib/screens/nutrition/nutrition_page.dart: NutritionPage | providers, drawer, SpeedDial, measured items | Release when enabled | loading/error/retry; empty/populated; drawer/actions | Nutrition home / E2.2 | E2.2 | test/theme/nutrition_presentation_test.dart | route behavior, persistence, localization, and N6 review |
| R25 | Nutrition drawer and quick actions | lib/screens/nutrition/food_logging_page.dart: FoodLoggingPage | search, favorites, portions, keyboard, scanner entry | Release when Nutrition enabled | loading/error/empty/populated; editing; save/cancel | Food logging / E2.2 | E2.2 | test/theme/food_logging_behavior_test.dart | repository persistence, keyboard, and device review |
| R26 | Food result/edit action | lib/screens/nutrition/food_customization_page.dart: FoodCustomizationPage | photo picker, nutrition fields, density help, save/cancel | Release when Nutrition enabled | loading/empty/populated; editing; validation; save/cancel | Food customization / E2.2 | E2.2 | test/theme/nutrition_presentation_test.dart; food behavior tests | photo-picker/device path, validation, and persistence |
| R27 | Food logging scanner action | lib/screens/nutrition/barcode_scanner_page.dart: BarcodeScannerPage | camera plugin, scanner session, app-owned overlay | Release when Nutrition enabled | permission pending/denied/granted; preview; detection; error; dismiss | Scanner boundary / N6 | N6 | test/theme/barcode_scanner_route_test.dart | real-device permission, background/resume, repeated detection, performance |
| R28 | Nutrition drawer and settings | lib/screens/nutrition/measured_items_page.dart: MeasuredItemsPage | health cards, measurement repository, date/unit fields | Release when caller reachable | empty/populated; add/edit/delete; validation; save/cancel | Measurements / D3 | D3 | test/screens/measured_items_page_test.dart | persistence, device keyboard, and accessibility review |
| R29 | Nutrition drawer today action | lib/screens/nutrition/log_entry_page.dart: LogEntryPage | meal grid, date controls, bottom sheets, repository payload | Release when Nutrition enabled | empty/populated; editing; save/cancel; returned result | Nutrition log entry / E2.2 | E2.2 | test/theme/food_logging_behavior_test.dart; nutrition presentation tests | fake-repository route evidence and device review |
| R30 | Nutrition drawer goals action | lib/screens/profile/settings/diet_nutrition_settings_page.dart: DietNutritionSettingsPage | settings sections, goal entry link | Release when Nutrition enabled | populated; editing; validation; save/cancel | Nutrition settings / E2.3 | E2.3 | source trace; settings tile contracts | nested goal route, persistence, and N6 review |
| R31 | Goal settings nested action | lib/screens/profile/settings/goal_manual_entry_page.dart: GoalManualEntryPage | goal fields, date picker, save/cancel | Release when Nutrition enabled | empty/populated; editing; validation; date picker; save failure | Goal settings / E2.3 | E2.3 | test/theme/nutrition_goals_behavior_test.dart; source trace | route-level persistence, keyboard, and accessibility |
| R32 | Meal-plan add bar | lib/screens/nutrition/pantry_log_page.dart: PantryLogPage | meal-plan add bar, placeholder scaffold | Release when caller reachable | placeholder; back | Nutrition placeholder / E2.2 | E2.2 | source trace | product decision required; not release-qualified |
| R33 | Meal-plan add bar | lib/screens/nutrition/plan_meal_page.dart: PlanMealPage | meal-plan add bar, placeholder scaffold | Release when caller reachable | placeholder; back | Nutrition placeholder / E2.2 | E2.2 | source trace | product decision required; not release-qualified |
| R34 | Main shell Profile tab | lib/screens/profile/settings/profile_page.dart: ProfilePage | settings tiles, sections, disabled tile, navigation | Release | populated; disabled; navigation | Profile settings / E2.3 | E2.3 | current 21-item Neo visual review; settings tests | save/error/dialog/accessibility/device states |
| R35 | Profile account | lib/screens/profile/settings/user_information_settings_page.dart: UserInformationSettingsPage | fields, date picker, units, validation, save bar | Release | populated/editing; validation; focus; keyboard; save feedback | User information / E2.3 | E2.3 | current 21-item Neo visual review; settings contracts | N6 form, keyboard, localization, persistence |
| R36 | Profile account | lib/screens/profile/settings/ui_appearance_settings_page.dart: UIAppearanceSettingsPage | theme family/mode controls, unit/language dialogs, nav editor | Release | populated; dialogs; persistence; restart | Appearance settings / E2.3 | E2.3 | current 21-item Neo visual review; theme preference tests; test/theme/theme_family_selector_test.dart | user-run selector verification, localization, restart, accessibility, and N6 device evidence |
| R37 | UI Appearance | lib/screens/profile/settings/nav_bar_settings_page.dart: NavBarSettingsPage | NavBarConfig, reorder/toggle controls, policy | Release | populated; editing; reorder; save/reset | Navigation settings / BASE | BASE | lib/providers/nav_bar_config.dart; app configuration tests | configurable-tab persistence and release-policy device check |
| R38 | Profile account | lib/screens/profile/settings/tutorials_settings_page.dart: TutorialsSettingsPage | tutorial store, expansion, reset/overlay actions | Release | populated; expanded/collapsed; reset; confirmation/snackbar | Guided tutorials / E2.3 | E2.3 | test/theme/tutorial_presentation_test.dart | accessibility focus, persistence, and N6 review |
| R39 | Profile training | lib/screens/profile/settings/gym_exercise_settings_page.dart: GymExerciseSettingsPage | settings actions, workout-exit preference dialog | Release | populated; dialog; persistence | Training settings / E2.3 | E2.3 | current 21-item Neo visual review; source trace | dialog/error/persistence and N6 review |
| R40 | Training settings | lib/screens/profile/settings/analytics_setting_screen.dart: AnalyticsSettingsScreen | settings actions and linked analytics pages | Release | populated; navigation | Analytics settings / E2.3 | E2.3 | source trace; settings contracts | linked-route state and accessibility evidence |
| R41 | Analytics settings | lib/screens/profile/settings/bodypart_ranking_screen.dart: BodyPartRankingScreen | ranking tiles, reorder controls, rank fields | Release | populated; editing/reorder; validation | Ranking settings / E2.3 | E2.3 | current 21-item Neo visual review; test/theme/widgets/settings_tiles_test.dart | persistence, large text, and device review |
| R42 | Analytics settings | lib/screens/profile/settings/muscle_ranking_screen.dart: MuscleRankingScreen | ranking tiles, reorder controls, rank fields | Release | populated; editing/reorder; validation | Ranking settings / E2.3 | E2.3 | current 21-item Neo visual review; test/theme/widgets/settings_tiles_test.dart | persistence, large text, and device review |
| R43 | Analytics settings | lib/screens/profile/settings/volume_boundaries_screen.dart: VolumeBoundariesScreen | tabs, selected entity dropdown, numeric fields, save bar | Release | selected body part/muscle; editing; validation; save | Volume settings / E2.3 | E2.3 | current 21-item Neo visual review; focused settings tests | dropdown/error/persistence and N6 review |
| R44 | Analytics settings | lib/screens/profile/settings/bodypart_muscle_mapping_screen.dart: BodyPartMuscleMappingScreen | selected entity dropdown, linked-muscle list, edit/save | Release | selected; empty/populated links; editing; save | Anatomy mapping / E2.3 | E2.3 | current 21-item Neo visual review; focused settings tests | selection/edit persistence and N6 review |
| R45 | Analytics settings | lib/screens/profile/settings/exercise_analytics_screen.dart: ExerciseAnalyticsScreen | allocation tabs, credit fields, save actions | Release | selected exercise; muscle/body-part tabs; editing; validation | Exercise allocation / E2.3 | E2.3 | current 21-item Neo visual review; settings contracts | persistence, validation, and accessibility review |
| R46 | Analytics settings | lib/screens/profile/settings/exercise_editor_screen.dart: ExerciseEditorScreen | catalog picker, definition tabs, media, allocation dialogs | Release | no selection/selected; loading/error; editing; save/delete | Exercise editor / E2.3 | E2.3 | current 21-item Neo visual review; source trace | destructive/media/dialog/device states |
| R47 | Training settings | lib/screens/profile/settings/flow_methods_page.dart: FlowMethodsPage | flow cards, editor dialogs, reorder/delete | Release | empty/populated; editing; save/delete; confirmation | Flow settings / E2.3 | E2.3 | source trace; settings contracts; focused TonosSurfaceTheme tests and analysis; current appearance accepted 2026-09-24 | nested editor/persistence |
| R48 | Training settings | lib/screens/profile/settings/workout_progress_flows_page.dart: WorkoutProgressFlowsPage | flow cards, AutoPresetFlowScreen, reorder | Release | empty/populated; editing; save/delete; confirmation | Progress-flow settings / E2.3 | E2.3 | source trace; focused TonosSurfaceTheme tests and analysis; current appearance accepted 2026-09-24 | nested editor/reorder persistence |
| R49 | Workout progress flows | lib/screens/exercise/auto_preset_flow_screen.dart: AutoPresetFlowScreen | flow editor, preset/profile defaults, dialogs | Release when caller reachable | defaults; populated; editing; validation; save/cancel | Auto-preset flow / E2.3 | E2.3 | source trace; pre-Q2 route evidence | nested editor persistence and device review |
| R50 | Profile data | lib/screens/profile/settings/database_settings_page.dart: DatabaseSettingsPage | import/export, maintenance actions, confirmations | Release | idle/busy; success/error; confirmation; file action | Database settings / E2.3 | E2.3 | current 21-item Neo visual review; source trace | import/export, permission, busy/error, and N6 review |
| R51 | Profile data | lib/screens/profile/settings/diagnostics_settings_page.dart: DiagnosticsSettingsPage | diagnostics actions, status/error surfaces | Release | idle/busy; success/error; confirmation | Diagnostics settings / E2.3 | E2.3 | source trace; settings contracts | device/error evidence and accessibility review |
| R52 | Configurable experimental tab | lib/screens/nutrition_log_page.dart: NutritionLogPage | placeholder scaffold, navigation policy | Debug/non-release experimental | placeholder; back | Experimental placeholder / Q2 | Q2 | NavBarConfig and NavigationBuildPolicy source trace | product decision; release exposure denied |
| R53 | Configurable experimental tab | lib/screens/combined_history_page.dart: CombinedHistoryPage | placeholder scaffold, navigation policy | Debug/non-release experimental | placeholder; back | Experimental placeholder / Q2 | Q2 | NavBarConfig and NavigationBuildPolicy source trace | product decision; release exposure denied |
| R54 | Configurable experimental tab | lib/screens/form_posing_page.dart: FormPosingPage | placeholder/current form surface, navigation policy | Debug/non-release experimental | current surface; back | Experimental route / Q2 | Q2 | NavBarConfig and NavigationBuildPolicy source trace | product qualification required; release policy decision |
| R55 | Debug route and toolbar | lib/theme/theme_lab_page.dart: ThemeLabPage | theme family, brightness, effects, motion controls | Debug only | gallery; pilot states; narrow/large text | Theme Lab / Q2 | Q2 | test/theme/theme_lab_page_test.dart; debug theme tests | no release qualification; continue pilot regression only |
| R56 | Onboarding nested plan actions | lib/screens/onboarding_flow.dart: PremadePlansPage, PresetGenerationQaScreen, PresetDetailScreen, GymProfileScreen callers | onboarding state store, plan/preset/profile forms | Release first-run | loading; editing; discard/save; return | Onboarding / BASE-B6 | BASE-B6 | test/screens/onboarding_and_plan_flow_test.dart | full onboarding route/device accessibility review |
| R57 | Profile/settings source residue | lib/screens/profile/settings/app_settings_page.dart: AppSettingsPage | settings scaffold, dialogs | No current caller | source-only; dialog code present | Unreferenced residue / UNREF | UNREF | source trace found no production caller | retain; no release qualification or navigation change |
| R58 | Nutrition source residue | lib/screens/nutrition/default_trend_page.dart: DefaultTrendPage | trend placeholder/data visualization | No current caller | source-only placeholder | Unreferenced residue / UNREF | UNREF | source trace found no production caller | retain; no release qualification until a caller exists |
| R59 | Shared detail boundary | lib/widgets/health_trends_section.dart: _MeasurementDefinitionDialog and entry/delete dialogs | health trends, date/time pickers, validation | Release when health caller reachable | add/edit/delete; validation; confirmation | Health trends / D3 | D3 | Health-measurement contract/token tests; TonosDialog tests | Neo Dark entry/dropdown/date-time appearance accepted 2026-09-24; formatter unchanged, analyzer clean, and the corrected captured-menu-theme check passed within the 38-test focused run; keyboard/semantics and non-happy-path states remain |
| R60 | Shared workout boundary | lib/widgets/ongoing_session_fab.dart, lib/screens/exercise/session_screen.dart: exit/finish dialogs and sheets | workout exit preferences, session controls | Release when workout caller reachable | finish busy/error; discard/confirm; sheet open/dismiss | Workout/session / B2 | B2 | workout controls/exit tests; source trace | real-device back/keyboard/rotation and destructive-state review |
| R61 | Shared dashboard boundary | lib/screens/dashboard_page.dart: edit/restore dialog; lib/widgets/dashboard_sections.dart action routes | DashboardConfig, dialogs, section cards | Release when Dashboard enabled | edit/reorder; hide/show; restore; cancel/save | Dashboard / D1 | D1 | dashboard contract/token tests; source trace | configurable-tab and large-text device review |
| R62 | Shared data/settings boundary | lib/screens/profile/settings/database_settings_page.dart, lib/screens/profile/settings/exercise_editor_screen.dart, lib/screens/profile/settings/flow_methods_page.dart: confirmation/editor dialogs | dialogs, sheets, save bars, field tokens | Release | busy/error; validation; confirm/cancel; editing | Settings consumers / E2.3 | E2.3 | settings tile/consumer parity tests; source trace | complete destructive/media/dialog state evidence |
| R63 | Main shell configurable tab | lib/screens/exercise/train2_page.dart: Train2Page | preset bars, optimized settings, session, catalog, and gym-profile actions | Release when enabled | intro/choices; loading/error; generated/premade; editing; cancel/back | Train2 flow / B3-B6 | B3-B6 | source trace; current 21-item Neo visual review | configurable-tab reachability, non-happy-path, and N6 review |
| R64 | Profile progress settings | lib/screens/profile/settings/measurements_trends_settings_page.dart: MeasurementsTrendsSettingsPage | measurement library, D3 health/measurement consumers | Release when caller reachable | populated; navigation; return refresh | Measurements settings / D3 | D3 | source trace; test/theme/health_measurements_contract_test.dart; test/screens/measured_items_page_test.dart | empty, edit, delete, return-state, large-text, and N6 review |

### Root And Main-Tab Reachability (Summary)

| Entry | Destination | Visibility and states | Owner / evidence | Disposition |
| --- | --- | --- | --- | --- |
| App startup | `_StartupGate`, `OnboardingFlow`, or `MainScreen` | Startup loading; first-run onboarding; normal app | `lib/main.dart`; onboarding and app-configuration tests | reachable; N6 startup/restart evidence pending |
| Default tab | `TrainPage` | Overview, plans, empty/loading/error plan states, drawers and workout entry | `lib/screens/exercise/train_page.dart`; existing Neo review and train tests | reachable; visual review accepted; affected-state recheck only |
| Configurable tab | `CatalogPage` | Catalog, exercise catalog, filters, target anatomy and detail sheet | `lib/screens/catalog_page.dart` and catalog screens | reachable; C2/C3 and N6 states pending |
| Default tab | `HistoryScreen` | Calendar/list history, empty days, session detail and tutorial | `lib/screens/exercise/history_screen.dart`, `lib/widgets/history_content.dart` | reachable; D1 source-ready; device/state evidence pending |
| Default tab | `MeasurementsTrendsPage` | Progress charts, workout report, health trends, empty/one-entry states | `lib/screens/measurement_trends_page.dart` and D2/D3 consumers | reachable; D2 scoped-verified, D3 source-ready |
| Default tab | `ProfilePage` | Account, training, data, disabled nutrition tile and tutorials | `lib/screens/profile/settings/profile_page.dart` | reachable; 21-item visual review accepted; state/N6 pending |
| Configurable tab | `DashboardPage` | Populated/empty dashboard, edit/reorder, hide/show, restore defaults | `lib/screens/dashboard_page.dart`, `dashboard_sections.dart`, `DashboardConfig` | reachable when enabled; D1 source-ready |
| Configurable tab | `NutritionPage` | Loading, load failure/retry, populated dashboard, drawer and SpeedDial | `lib/screens/nutrition/nutrition_page.dart` and nutrition providers | reachable when enabled; focused E2.2 coverage added; route/device qualification pending |
| Configurable tab | `Train2Page` | Intro, choices, generated/premade flows, optimized settings, cancel/back | `lib/screens/exercise/train2_page.dart` and preset screens | reachable when enabled; visual review accepted; non-happy-path pending |
| Configurable tab | `NutritionLogPage` | Static placeholder with AppBar and back | `lib/screens/nutrition_log_page.dart` | experimental placeholder; retained, not release-qualified |
| Configurable tab | `CombinedHistoryPage` | Static placeholder with AppBar and back | `lib/screens/combined_history_page.dart` | experimental placeholder; retained, not release-qualified |
| Configurable tab | `FormPosingPage` | Current form/posing surface and back | `lib/screens/form_posing_page.dart` | experimental; disposition recorded, product qualification pending |
| Debug route | `ThemeLabPage` and debug toolbar | Development-only family/mode/effects/reduced-motion controls | `lib/theme/theme_lab_page.dart`, `lib/main.dart` | debug-only; never a release route |
| Named route | `/main` | Main tab shell | `lib/main.dart` | reachable; covered by normal entry |
| Named route | `/__theme_lab` | Theme Lab only in debug builds | `lib/main.dart` | debug-only |

The default enabled tabs are Train, Catalog, Logbook, Progress, and Profile.
Dashboard, Nutrition, and Train2 are configurable but not enabled by default.
`NavBarSettingsPage` owns persisted order/enabled state. `NavigationBuildPolicy`
filters experimental tabs and denies them in release builds.

### Catalog, Detail, And Media Paths (Summary)

| Entry and destination | Required state coverage | Current owner / evidence | Disposition |
| --- | --- | --- | --- |
| Catalog -> `ExerciseCatalogPage` | Search, settled results, filters open/save/cancel, no results, loading/error, exercise selection | Catalog screens; catalog and refinement regression tests | reachable; visual review accepted; C2/N6 states pending |
| Catalog -> `MuscleFilterPage` | Body-part/muscle tabs, empty/populated lists, selection and back | `lib/screens/exercise/muscle_filter_page.dart` | reachable; visual review accepted; state/device evidence pending |
| Catalog row -> `ExerciseDetailSheet` | Details, metrics, records, form guide, tabs, empty/loading/error, saved records, actions, sheet resize/scroll | `lib/widgets/exercise_detail_sheet.dart`; `exercise_detail_contract_test.dart` | reachable; C2 source-ready; user-run/device evidence pending |
| Detail preview -> media viewer | Missing media, retry/fallback, zoom, pan, dismiss, system Back, scrim and effects-off | `exercise_media_thumbnail.dart`, `shared_entity_media_thumbnail.dart`, `media_viewer_image.dart`, `body_heatmap.dart`; `media_viewer_test.dart` | reachable where media exists; C3 source-ready; real-media/device pending |
| Detail anatomy -> full-screen heatmap | Front/back, selected region, target anatomy tags, empty/unknown data | `body_heatmap.dart` and anatomy consumers | reachable; data/illustration colors remain domain-owned; N6 pending |
| Detail -> session/report | Open historical session, return to sheet, preserve selected tab/scroll | Dashboard/history callers and `SessionDetailScreen` | reachable; callback behavior preserved; D1/C2 state evidence pending |

### Dashboard, Logbook, And Health Paths (Summary)

| Entry | Destination / state matrix | Current owner / evidence | Disposition |
| --- | --- | --- | --- |
| Dashboard tab | Visible/hidden modules, edit mode, reorder, restore defaults, empty visible set, scroll | `DashboardConfig`, `dashboard_page.dart`, `dashboard_sections.dart`; dashboard contract/token tests | reachable when enabled; D1 source-ready |
| Dashboard history module | Summary, calendar/list period selection, selected day, no records, refresh after completed session | `history_summary_widget.dart`, `workout_history_calendar.dart`, `history_content.dart` | reachable through dashboard; selected-period card visually accepted by user 2026-09-24; broader state/device checks remain |
| Dashboard history action | `FullHistoryScreen`: waiting, load error, empty, populated, session detail, return refresh | `full_history_screen.dart`; source parity coverage | reachable; theme-ready compatibility present; manual/device pending |
| Logbook tab | `HistoryScreen` and `PastSessionsList`: empty/populated, calendar selection, session detail, reload | `history_screen.dart`, `past_sessions_list.dart`, `history_content.dart` | reachable; selected-period card visually accepted by user 2026-09-24; broader state/device checks remain |
| Progress tab | Exercise progress, metric report, data records, range/details, zero/no-data, long values and tooltips | D2 consumers and tests | reachable; D2 scoped-verified; large-text/device pending |
| Progress health section | Empty, one entry, populated, compact scroll, chart/grid and refresh | `health_trends_section.dart`; health measurement tests | reachable from Progress/Nutrition; Neo Dark entry/date-time picker appearance accepted 2026-09-24; keyboard, validation, and CRUD state evidence remains |
| Measurements settings | Settings -> `MeasuredItemsPage` | settings page and measured-items widget tests | reachable; D3 compatibility present; add/edit/delete/device pending |
| Generic trend source | `lib/screens/nutrition/default_trend_page.dart` | No production caller found by source trace | unreferenced; retained as source residue, not release-qualified |

### Nutrition And Scanner Paths (Summary)

| Entry | Destination / state matrix | Current owner / evidence | Disposition |
| --- | --- | --- | --- |
| Nutrition drawer -> food | Search/debounce, results, favorite, portion, quantity, save/cancel, empty/error, keyboard | `food_logging_page.dart`, `meal_plan_add_bar.dart`; nutrition presentation/behavior tests | reachable when Nutrition enabled; focused E2.2 coverage added; route/device qualification pending |
| Food result/editor | Unsaved name, photo/placeholder, density help, save/cancel, validation and keyboard | `food_customization_page.dart`, `app_nutrition_tokens.dart` | reachable; source-ready; photo-picker/device pending |
| Food logging -> scanner | Permission denied/granted, camera preview, repeated detections, result, dismiss, background/resume | `barcode_scanner_page.dart`, `barcode_scanner_session.dart`; scanner route test | reachable; fixed camera chrome intentional; real-device lifecycle pending |
| Nutrition drawer -> measurements | Empty/populated, add/edit/delete, validation, date/unit fields, save/cancel | `measured_items_page.dart`, measurement repository/validation | reachable; D3 ownership present; behavior/device pending |
| Nutrition drawer -> today | Date rendering, logged entries, empty, edit/delete, bottom actions and return value | `log_entry_page.dart` | reachable; source-ready; fake-repository/device pending |
| Nutrition drawer -> goals | Goal fields, save/cancel and validation | `diet_nutrition_settings_page.dart` | reachable from Nutrition drawer; focused settings behavior added; route/device qualification pending |
| Meal add bar -> pantry | Current placeholder and AppBar/back behavior | `pantry_log_page.dart`, `meal_plan_add_bar.dart` | reachable placeholder; retained, not release-qualified |
| Meal add bar -> plan meal | Current placeholder and AppBar/back behavior | `plan_meal_page.dart`, `meal_plan_add_bar.dart` | reachable placeholder; retained, not release-qualified |

### Profile And Settings Paths (Summary)

| Entry | Destination / state matrix | Current owner / evidence | Disposition |
| --- | --- | --- | --- |
| Profile -> account | User Information, UI Appearance, Guided Tutorials | `profile_page.dart` and child pages; settings/refinement tests | reachable; visual review accepted; save/dialog/large-text/N6 pending |
| UI Appearance | Dark/light mode, theme-family selector, weight-unit dialog, language dialog, onboarding replay, bottom-tab editor | `ui_appearance_settings_page.dart`, `nav_bar_settings_page.dart`, providers and dialogs; `test/theme/theme_family_selector_test.dart` | reachable; visual review accepted; Step 14 selector automated-verified; human persistence/failure/keyboard/localization/restart and N6 evidence pending |
| Guided Tutorials | Reset all, per-topic reset, expansion, replay, snackbar/confirmation | `tutorials_settings_page.dart`, tutorial store and overlay | reachable; visual review accepted; state/accessibility/device pending |
| User Information | Identity/body fields, date picker, units, validation, focus, keyboard, save feedback | `user_information_settings_page.dart` | reachable; visual review accepted; N6 form pending |
| Profile -> training | Gym/Exercise Settings and exit-behavior dialog | `gym_exercise_settings_page.dart`, `WorkoutExitPreferences` | reachable; visual review accepted; persistence/dialog pending |
| Training -> analytics | Bodypart rankings, muscle rankings, volume boundaries, anatomy mapping, set allocation, exercise editor | `analytics_setting_screen.dart` and linked screens | reachable; visual review accepted; save/loading/error/selection pending |
| Training -> flow tools | Flow Methods and Workout Progress Flows, nested plan/profile/edit states | `flow_methods_page.dart`, `workout_progress_flows_page.dart` | reachable; current appearance visually accepted 2026-09-24 after dropdown contrast fix; focused surface-theme tests and analysis passed; nested persistence/editing review explicitly deferred by user |
| Training -> exercise editor | Catalog picker, custom exercise, muscles/bodyparts/equipment/media tabs, allocation dialogs, save/delete confirmations | `exercise_editor_screen.dart`, `exercise_analytics_screen.dart` | reachable; visual review accepted; destructive/media/dialog pending |
| Profile -> progress settings | Measurements/Trends settings -> Measured Items | `measurements_trends_settings_page.dart` | reachable; included in D3 ledger |
| Profile -> data | Database Settings and Diagnostics Settings | `database_settings_page.dart`, `diagnostics_settings_page.dart` | reachable; visual review accepted; import/export/maintenance/busy/error/confirmation pending |
| Profile -> nutrition tile | Disabled Diet/Nutrition tile on Profile | `profile_page.dart` | visible but intentionally disabled; Nutrition drawer is the reachable owner |
| Source-only settings page | `AppSettingsPage` | No caller found in current source trace | unreferenced; retained, not release-qualified; no navigation change |

### Ledger Exit And Remaining Qualification

The route inventory is complete: every current main-tab destination, nested
destination, settings child, placeholder, experimental route, debug route, and
unreferenced source page found in the source trace has an owner and
disposition. Dialogs and sheets are recorded under their owning route rows and
in the shared-boundary rows where they cross route ownership. No route was
removed, newly exposed, or silently marked release-ready.

The following are intentionally separate from ledger completion:

1. E2.2 nutrition implementation and route-level behavioral evidence.
2. E2.3 settings-residue implementation and state tests.
3. C2/C3/D1/D3 user-run scoped verification and affected device review.
4. N6 accessibility, keyboard, rotation, scanner/media lifecycle, and performance evidence.
5. Product decisions for reachable placeholders before any release gating change.

The canonical ledger contract is now machine-guarded. Future route additions
must update both the matrix and test/theme/e2_route_ledger_contract_test.dart;
the guard does not promote a route to release-qualified status.

The expanded non-human verification batch now analyzes the remaining route
owners and runs existing provider, screen, widget, localization, media,
scanner, health, and safety evidence outside `test/theme`; a narrow Neo
nutrition smoke test was added. An earlier expanded batch passed successfully:
analysis was clean, the full theme suite passed 302 tests, the responsive run
passed 6 tests, the route-boundary batch passed, and the enforce-mode ratchet
passed. The earlier 2026-09-17 post-review run formatted 132 files, with 1
file changed, and passed clean analysis, 315 theme/configuration tests, 6
responsive tests, 46 route-boundary tests, and the enforce-mode ratchet. The
later corrected-scope run is recorded at the top of this ledger. The ledger
must not be promoted to full E2 or
release qualification merely because the automated boundary is complete.

The first rerun reached the new smoke test and reported a 129 px right
RenderFlex overflow for the Neo food editor in both brightness modes at
320x640/2x text. `FoodCustomizationPage` now wraps the bottom extended
actions; the focused and expanded reruns passed after that fix.

## Current Neo Visual Review Update (2026-09-16)

The user accepted all 21 entries in the current Neo visual review. The
Profile/settings portion includes UI and Appearance, Weight Units, User
Information, Edit Gym Profile, Database Settings, Guided Tutorials, body-part
and muscle rankings, Volume Boundaries, Anatomy Mapping, Exercise Set
Allocation, Exercise Editor, Flow Methods, and Workout Progress Flows. The
final bright-field selector correction passed user-run formatting, clean
analysis, and 63 focused tests. An earlier selector run passed 7 tests, and an
earlier full-theme run passed 300 tests. The then-latest 2026-09-17
post-review run passed clean analysis, 315 theme/configuration tests, 6
responsive tests, 46 route-boundary tests, and the style ratchet in enforce
mode, with formatting unchanged. The newer 2026-09-22 corrected-scope result
is recorded above.

At that checkpoint this was normal-route visual acceptance only. The later
development qualification confirmation below closes the listed current-scope
state/device checks; Step 15 release behavior remains separate.

### Current Visual Review Confirmation (2026-09-17)

The user confirmed item 20, Guided Tutorials, after the Neo-light tutorial-card
icon and progress count were corrected with the theme-owned
AppTutorialTokens.accentForeground role. All 21 visual review items are now
accepted. Classic and Neo dark behavior remain preserved, and this confirmation
does not close the separate N6 state/accessibility requirements.

| Entry or group | Destination / shared consumer | Current disposition |
| --- | --- | --- |
| Configurable main tabs | nutrition/nutrition_page.dart | Retains existing Material and shared nutrition recipes. |
| Configurable Nutrition Log tab | nutrition_log_page.dart | Existing placeholder; retained, not declared release-qualified. |
| Nutrition drawer | food_logging_page.dart | Migrated residual food-action colors and control frames; theme-ready card ownership is now explicit. Search/debounce and writes unchanged. |
| Food results / food editor action | food_customization_page.dart | Migrated photo backgrounds/icons, density help, borders and frames; theme-ready card ownership is now explicit. Existing photo-picker TODOs retained. |
| Nutrition log entry action | log_entry_page.dart | Migrated grid/border/card geometry; meal ColorScheme mapping and date arithmetic unchanged. |
| MealPlanAddBar | pantry_log_page.dart; plan_meal_page.dart | Both are reachable placeholders. No new feature or gating implemented. |
| Food logging scanner | barcode_scanner_page.dart | Black/white camera contrast, viewfinder and hint retained as fixed viewing chrome; device/lifecycle verification pending. |
| Nutrition measurements action | measured_items_page.dart | Reuses D3 health presentation; not remigrated. |
| Profile / training settings | analytics_setting_screen.dart and linked editors | Existing SettingsSection/SettingsActionTile ownership retained; the current Neo visual review is accepted for the listed Profile/settings routes. |
| Exercise editor media grid | exercise_editor_screen.dart | Two legacy grey surfaces and 12px geometry moved to AppMediaTokens. |
| Exercise analytics save action | exercise_analytics_screen.dart | Existing advanced-category accent and white foreground retained; the current allocation visual review is accepted, while broader contrast/accessibility qualification belongs to Q2/N6. |
| Generic trend page | default_trend_page.dart | No production caller found in the current source trace; retained source residue and not release-qualified. State qualification is not applicable until a caller exists. |
| Exercise definitions and history | definitions_by_bodypart_page.dart, definitions_by_muscle_page.dart, exercise_definition_info_tile.dart, full_history_screen.dart | Theme-ready surface compatibility and semantic positive metadata are in place; final Neo route recipes and state/device evidence remain pending. |
| Cardio and stretch cards | cardio_card.dart, stretch_card.dart | Theme-ready surface boundary plus semantic timer/add-action colors; full product flows and final Neo design remain deferred. |
| Current measurements | current_metrics_section.dart | Neo metric accents resolve through data-visualization roles; Classic keeps its original palette; current development route/state qualification is user-accepted. |

## Current Development Qualification Confirmation (2026-09-17)

The user confirmed that every item in the preceding human/device/N6 checklist
passed for the current working tree. This closes the current development
qualification for the ledger's N5 route states, E2.2 nutrition, E2.3 settings
residue, N6 device/accessibility behavior, Q2 switching/effects, and affected
Step 17 Classic-parity checks. It also closes the human/device portion of E2.4
for the current scope.

This is user-reported qualification evidence. It does not represent a new
terminal run, signed release artifact, or permission to change release gating.
Retained placeholders and unreferenced source residue keep their recorded
dispositions, and the style ratchet remains limited to separately qualified
per-file scopes. Any later code change reopens only its affected checks.

## Theme-Ready Compatibility Extension (2026-09-15)

The newly covered consumers are prepared for both families without being
declared fully Neo-complete. `TonosThemeReadyCard` keeps the original Classic
`Card` behavior and resolves a semantic Neo `TonosSurface`; targeted
measurement, timer, add-action, and nutrition foreground colors use existing
semantic or visualization roles. No route, persistence, query, unit,
repository, or product-flow behavior changed.

Final route-specific geometry, loading/empty/error states, accessibility,
device evidence, and complete product flows remain deferred until the affected
features stabilize. The compatibility boundary is not an inventory-ratchet
enrollment decision. test/theme/pre_q2_route_evidence_test.dart now verifies
that each listed wrapper consumer retains TonosThemeReadyCard and that the
measurement/nutrition semantic consumers retain their token accessors.

## This Slice's Boundaries

AppNutritionTokens now owns foodBorder, photoPlaceholder, mutedAction,
favoriteAction, addFoodAction, densityHelp, selectedLabel, logGrid and
compact/section/portion/quantity shapes. Constructor defaults, copyWith and lerp
include every added field. Both Classic modes retain the previous literals;
existing factory behavior is unchanged.

The quantity helper receives BuildContext only to resolve presentation.
No portion arithmetic, meal mapping, favorite persistence, query behavior,
navigation, save/cancel result, repository contract or localization text changed.
Transparent expansion dividers suppress double borders and remain intentional.
The commented-out quick-log button is not an active migration target.

AppMediaTokens owns editorAddSurface, editorItemSurface and editorShape.
The media editor still retains its original taps, edit controls and content.

Post-review non-human implementation pass (2026-09-17; automated-verified in
the latest supplied user run): nutrition provider failure/rollback, stable
log-entry grouping/date ordering, food-editor validation and narrow action
layout, large-text settings value wrapping, surface-aware health delta contrast
with Classic parity, and explicit shape/elevation forwarding through
TonosThemeReadyCard are covered by focused code/tests. The N5 state-owner and
settings-residue source contracts add explicit ownership checks for route
states and nested settings routes. The post-review surface-geometry regression
test and stricter route-edge contracts were included in that run and passed.
Follow-up verification exposed a large-text settings-row layout failure plus
two test-only determinism/fixture issues; those corrections are now in place.
The selector row subsequently required a bounded stacked large-text action
composition rather than relying on ListTile's shared horizontal slot. Its
focused fixture uses the failing 320x640 viewport, and the selector harness
disables theme transition timing. These contracts do not replace
rendered route, accessibility, device, or product-flow qualification.

Tests in test/theme/nutrition_presentation_test.dart cover defaults,
copy/interpolation, a real food customization theme rebuild retaining unsaved
text, and save/cancel payload behavior. The newer food logging behavioral test
also exercises search, favorite state, portion selection, quantity and the
actual diary payload. These tests were included in the latest supplied run and
do not replace real-device or full nutrition persistence evidence.

## Historical E2 Closeout Checklist (Superseded For Current Development Scope)

The checklist below was written before the current development qualification
confirmation. It is retained as provenance, not as an open E2 qualification
gate. Step 15 release qualification, the retained-placeholder product
decision, and any separately chosen final Neo recipes remain outside this
development closeout.

- Retain the latest supplied post-review verification (2026-09-22): 135 files
  formatted with 0 changes, clean analysis, 321 theme tests, 6 responsive
  tests, 46 route-boundary tests, and passing enforce-mode ratchet with one
  protected production file. This closes the verifier scope-only rerun. The
  user-confirmed development and N6 qualification is recorded above; Step 15
  release qualification remains separate.
- Preserve the accepted 21-item visual review; request only focused rechecks if
  a later change affects one of those presentations.
- Food selection, quantity/portion editing, log/save/cancel, favorite state,
  persistence/failure handling, and grouped/date rendering were included in
  the user's accepted current development qualification; reopen only after an
  affected code change or reproduced defect.
- The existing provider, screen, widget, localization, media, scanner, health,
  and safe-error tests plus the new N5/settings source contracts are included
  in the expanded verifier; this is automated boundary evidence, not a
  substitute for route visual or device qualification.
- The release caller ledger is complete. Use the closed rows above as the source
  of truth for E2.2 nutrition, E2.3 settings, N6, and placeholder decisions.
  Continue reviewing inherited styling and transforms as implementation changes.
- Record a product decision for the reachable placeholders. Do not delete/gate
  them without approval, and do not label them excluded merely because incomplete.
- Scanner permissions, repeated detections, navigation dismissal, and
  background/resume were included in the user's confirmed real-device
  checklist. The injectable session boundary and hardware-independent route
  tests remain supporting evidence.
- Current Classic/Neo visual and affected parity checks were user-accepted for
  the current scope. Keep the broad inventory report-only; Q1 only protects
  its individually enrolled TonosSurface scope and does not qualify all
  nutrition or settings expressions.
