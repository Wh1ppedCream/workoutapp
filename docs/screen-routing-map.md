# Screen Routing Map

This is the maintained map of Tonos entry points and active navigation. Use it
before changing a screen with a duplicate-looking counterpart under
`lib/screens/`.

For product and engineering priorities, use
[maintenance-backlog.md](maintenance-backlog.md). The cloud media publishing
workflow remains in [cloud-content-roadmap.md](cloud-content-roadmap.md).

## Application Startup

- `lib/main.dart` builds `MaterialApp`, registers providers, applies theme and
  locale preferences, and chooses between onboarding and `MainScreen`.
- `lib/screens/onboarding_flow.dart` is shown on first install until the
  onboarding provider marks it complete.
- `/main` opens `MainScreen` after onboarding or when a flow explicitly
  returns to the main application shell.

## Configurable Bottom Navigation

`lib/providers/nav_bar_config.dart` owns the saved order and enabled state of
bottom-nav tabs. Fresh installs enable these five tabs:

| User-facing tab | Active screen |
| --- | --- |
| Train | `lib/screens/exercise/train_page.dart` |
| Catalog | `lib/screens/catalog_page.dart` |
| Logbook | `lib/screens/exercise/history_screen.dart` |
| Progress | `lib/screens/measurement_trends_page.dart` |
| Profile | `lib/screens/profile/settings/profile_page.dart` |

The configuration screen can also enable Dashboard, Nutrition, Nutrition Log,
Combined History, Form and Posing, and the alternative Train hub.

### Alternative Train Hub

- `lib/screens/exercise/train2_page.dart` remains selectable as `Train2`.
- It is not enabled by default, but it is a live route in `MainScreen` and
  must not be deleted until its remaining behavior is migrated or retired.
- Shared history content used by the primary History screen and Train2 lives in
  `lib/widgets/history_content.dart`.

## Primary Feature Ownership

- `lib/screens/exercise/`: training, plans, sessions, exercise detail, history,
  and catalog drill-down screens.
- `lib/screens/nutrition/`: nutrition-specific pages and logging flows.
- `lib/screens/profile/settings/`: profile, gym, appearance, tutorial, and
  advanced settings screens.
- `lib/widgets/`: reusable visual components, sheets, cards, charts, and
  navigation helpers.
- `lib/repositories/`: app-facing data facades.
- `lib/db/`: database lifecycle, schema, migrations, seed data, and focused
  DAO queries.

## Compatibility Screen Files

Some root-level files under `lib/screens/` are forwarding or legacy
counterparts of nested feature screens. Do not assume they are active based on
their name alone; trace the import from `main.dart` or the calling widget.

Common examples:

- `lib/screens/muscle_filter_page.dart` and
  `lib/screens/exercise/muscle_filter_page.dart`
- `lib/screens/definitions_by_bodypart_page.dart` and
  `lib/screens/exercise/definitions_by_bodypart_page.dart`
- `lib/screens/exercise_analytics_screen.dart` and
  `lib/screens/profile/settings/exercise_analytics_screen.dart`
- `lib/screens/session_detail_screen.dart` and
  `lib/screens/exercise/session_detail_screen.dart`
- `lib/screens/new_measurement_item_page.dart` and
  `lib/screens/nutrition/new_measurement_item_page.dart`

## Maintenance Rules

- Add a new tab to `TabItem`, `MainScreen._pageForTab`, and the navigation
  configuration together.
- New route-level screens should live in their owning feature folder whenever
  possible.
- Prefer changing a focused DAO and exposing it through `AppRepository` over
  adding new table-specific SQL to a screen or provider.
- When a feature changes routing or persistence, update this map or the
  maintenance backlog in the same change.
