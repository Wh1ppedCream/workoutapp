Theme style inventory (report-only)
Scanned root: lib
Dart files: 316
Style candidates: 4382

Candidates by kind:
- color: 249
- color_literal: 675
- color_literal_candidate: 663
- color_transform: 705
- component_style: 64
- decoration: 429
- geometry: 1325
- gradient: 6
- local_theme: 51
- shadow: 27
- text_style: 188
Candidates by classification:
- application_shell: 1
- data_visualization: 31
- illustration_media: 25
- intentional_one_off: 51
- material_component: 10
- release_surface: 269
- stable_category_data: 41
- structural_theme: 1848
- theme_system: 2101
- tonos_semantic: 5
Candidates by status:
- allowlisted: 144
- migrated: 3595
- pending: 643

Pending candidates without a review queue: 0
Review queue coverage:
- 2250 candidates in exactly one queue
- 2132 candidates outside configured queues
- 0 candidates in multiple queues
- application-shell: 81 candidates (allowlisted=8, migrated=66, pending=7)
- shared-settings: 688 candidates (allowlisted=16, migrated=302, pending=370)
- active-workout: 86 candidates (allowlisted=2, migrated=69, pending=15)
- catalog-detail: 216 candidates (allowlisted=13, migrated=201, pending=2)
- dashboard-progress-health: 306 candidates (allowlisted=16, migrated=275, pending=15)
- onboarding-and-development: 166 candidates (allowlisted=10, migrated=131, pending=25)
- exercise-planning-analytics: 440 candidates (allowlisted=9, migrated=297, pending=134)
- nutrition-workflows: 128 candidates (allowlisted=14, migrated=61, pending=53)
- history-measurement-support: 71 candidates (allowlisted=6, migrated=43, pending=22)
- shared-flow-controls: 14 candidates (migrated=14)
- catalog-conditioning-browse: 22 candidates (migrated=22)
- navigation-anatomy-support: 32 candidates (allowlisted=5, migrated=27)

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
- lib/main.dart:343 color [application_shell/migrated] statusBarColor: Colors.transparent,
- lib/screens/catalog_page.dart:338 color_transform [structural_theme/migrated] .withValues(alpha: 0.82)
- lib/screens/catalog_page.dart:413 geometry [structural_theme/migrated] ? const BorderRadius.only(
- lib/screens/catalog_page.dart:591 geometry [structural_theme/migrated] ? const BorderRadius.only(
- lib/screens/catalog_page.dart:638 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/catalog_page.dart:640 geometry [structural_theme/migrated] borderRadius: BorderRadius.circular(14),
- lib/screens/catalog_page.dart:763 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/catalog_page.dart:766 geometry [structural_theme/migrated] ? const BorderRadius.only(
- lib/screens/catalog_page.dart:774 geometry [structural_theme/migrated] ? Border.all(
- lib/screens/catalog_page.dart:779 color_transform [structural_theme/migrated] .withValues(alpha: 0.35) ??
- lib/screens/catalog_page.dart:780 color_transform [structural_theme/migrated] theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
- lib/screens/catalog_page.dart:783 geometry [structural_theme/migrated] : Border.all(
- lib/screens/catalog_page.dart:791 shadow [structural_theme/migrated] BoxShadow(
- lib/screens/catalog_page.dart:844 geometry [structural_theme/migrated] ? const BorderRadius.only(
- lib/screens/catalog_page.dart:855 color_transform [structural_theme/migrated] ? surfaces.mediaOutline.withValues(alpha: 0.55)
- lib/screens/catalog_page.dart:929 geometry [structural_theme/migrated] ? const BorderRadius.only(
- lib/screens/catalog_page.dart:935 geometry [structural_theme/migrated] : const BorderRadius.only(
- lib/screens/catalog_page.dart:1022 decoration [structural_theme/migrated] decoration: BoxDecoration(
- lib/screens/dashboard_page.dart:210 color [release_surface/pending] color: Colors.transparent,
- lib/screens/dashboard_page.dart:216 color_transform [stable_category_data/allowlisted] .withValues(alpha: 0.35),
- ... 4362 more; use --format json for all.
