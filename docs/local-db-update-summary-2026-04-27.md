Local DB update summary
Date: 2026-04-27
Branch: local-db

Changes since commit `3a206ea`:

- Added a database maintenance layer to support health snapshots, integrity checks, optimize, WAL checkpoint, and vacuum actions.
- Upgraded the Database Settings screen so it now shows schema version, database size, journal mode, table/index/trigger counts, and food/FTS counts.
- Improved database import safety by adding import preview/validation, schema-version checks, malformed-data blocking, and an automatic backup-to-clipboard step before destructive imports.
- Updated full database export so it now includes export format metadata, format version, schema version, and export timestamp.
- Added focused database contract tests for import/export behavior and schema-version wiring.
- Removed the default counter widget test because it no longer matched the app.

Files added:

- `lib/db/database_maintenance.dart`
- `test/database_import_contract_test.dart`
- `test/database_schema_contract_test.dart`

Files updated:

- `lib/db/database_helper.dart`
- `lib/repositories/app_repository.dart`
- `lib/screens/profile/settings/database_settings_page.dart`

Files removed:

- `test/widget_test.dart`

Verification:

- `flutter test test/database_import_contract_test.dart test/database_schema_contract_test.dart`
- Result: all tests passed
