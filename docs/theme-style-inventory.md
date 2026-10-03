Theme style inventory (report-only)
Scanned root: lib
Dart files: 297
Style candidates: 2473

Candidates by kind:
- color: 168
- color_literal: 308
- color_literal_candidate: 296
- color_transform: 401
- component_style: 30
- decoration: 296
- geometry: 794
- gradient: 6
- local_theme: 15
- shadow: 27
- text_style: 132
Candidates by classification:
- application_shell: 1
- data_visualization: 28
- illustration_media: 25
- intentional_one_off: 43
- material_component: 9
- release_surface: 5
- stable_category_data: 40
- structural_theme: 876
- theme_system: 1441
- tonos_semantic: 5
Candidates by status:
- allowlisted: 132
- migrated: 2341

Pending candidates without a review queue: 0
Review queue coverage:
- 1002 candidates in exactly one queue
- 1471 candidates outside configured queues
- 0 candidates in multiple queues
- application-shell: 62 candidates (allowlisted=7, migrated=55)
- shared-settings: 222 candidates (allowlisted=16, migrated=206)
- active-workout: 60 candidates (allowlisted=2, migrated=58)
- catalog-detail: 90 candidates (allowlisted=13, migrated=77)
- dashboard-progress-health: 157 candidates (allowlisted=16, migrated=141)
- onboarding-and-development: 112 candidates (allowlisted=10, migrated=102)
- exercise-planning-analytics: 156 candidates (allowlisted=3, migrated=153)
- nutrition-workflows: 50 candidates (allowlisted=12, migrated=38)
- history-measurement-support: 41 candidates (allowlisted=6, migrated=35)
- shared-flow-controls: 14 candidates (migrated=14)
- catalog-conditioning-browse: 8 candidates (migrated=8)
- navigation-anatomy-support: 30 candidates (allowlisted=5, migrated=25)

Unassigned candidates: 0

Pending review queue (12):
- Application shell and navigation [application-shell] -> AppMaterialTheme, navigation component themes, and Tonos shared primitives
- Shared settings and form controls [shared-settings] -> Tonos field/section/action primitives plus semantic category roles
- Active workout and completion [active-workout] -> Tonos surfaces/actions, workout semantic roles, and stable input component themes
- Catalog and exercise detail [catalog-detail] -> Tonos surfaces/fields/sheets plus media and data-visualization contracts
- Dashboard, progress, and health trends [dashboard-progress-health] -> Tonos surfaces plus AppDataVisualizationTokens and semantic measurement roles
- Onboarding and development-only routes [onboarding-and-development] -> Named Tonos variants, effect fallbacks, and release-gated surface ownership
- Exercise planning, analytics, and supporting widgets [exercise-planning-analytics] -> Tonos surface/action recipes plus exercise-specific semantic and data-visualization roles
- Nutrition and meal-entry workflows [nutrition-workflows] -> Tonos form/surface primitives and nutrition semantic roles
- History, measurement, and summary support [history-measurement-support] -> Tonos surfaces plus semantic measurement and progress roles
- Shared flow and configuration controls [shared-flow-controls] -> Tonos field, dialog, and action primitives with preserved flow behavior
- Catalog browse and conditioning widgets [catalog-conditioning-browse] -> Tonos cards/dialogs plus exercise-media and conditioning-specific roles
- Navigation and anatomy support widgets [navigation-anatomy-support] -> Shared navigation tokens and anatomy/data-visualization ownership

Sample findings (first 20):
- lib/main.dart:339 color [application_shell/migrated] statusBarColor: Colors.transparent,
- lib/screens/catalog_page.dart:540 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/catalog_page.dart:543 geometry [structural_theme/migrated] border: Border.all(
- lib/screens/catalog_page.dart:553 shadow [structural_theme/migrated] BoxShadow(
- lib/screens/dashboard_page.dart:164 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/dashboard_page.dart:167 color_transform [stable_category_data/allowlisted] border: Border.all(color: details.color.withValues(alpha: 0.48)),
- lib/screens/dashboard_page.dart:167 geometry [structural_theme/migrated] border: Border.all(color: details.color.withValues(alpha: 0.48)),
- lib/screens/dashboard_page.dart:184 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/dashboard_page.dart:185 color_transform [stable_category_data/allowlisted] color: details.color.withValues(alpha: 0.16),
- lib/screens/dashboard_page.dart:186 geometry [structural_theme/migrated] borderRadius: BorderRadius.circular(12),
- lib/screens/dashboard_page.dart:239 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/dashboard_page.dart:242 geometry [structural_theme/migrated] border: Border.all(color: scheme.outlineVariant),
- lib/screens/dashboard_page.dart:279 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/dashboard_page.dart:282 geometry [structural_theme/migrated] border: Border.all(color: scheme.outlineVariant),
- lib/screens/exercise/analytics_dashboard_screen.dart:383 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/exercise/analytics_dashboard_screen.dart:384 color_transform [structural_theme/migrated] color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
- lib/screens/exercise/analytics_dashboard_screen.dart:514 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/exercise/analytics_dashboard_screen.dart:517 geometry [structural_theme/migrated] border: Border.all(
- lib/screens/exercise/analytics_dashboard_screen.dart:582 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/exercise/analytics_dashboard_screen.dart:583 color_transform [structural_theme/migrated] color: scheme.primaryContainer.withValues(alpha: 0.55),
- ... 2453 more; use --format json for all.
