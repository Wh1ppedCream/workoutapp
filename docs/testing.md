# Testing Tonos

The automated suite is organized by the behavior it protects, rather than by
screen name:

- `test/models` verifies immutable models and manifest parsing.
- `test/utils` verifies unit conversion, generated-weight helpers, flow
  traversal, and concurrency behavior.
- `test/providers` verifies SharedPreferences-backed app configuration.
- `test/services` verifies content configuration and platform-download policy.
- `test/db` runs selected DAO contracts against in-memory SQLite.
- `test/widgets` smoke-tests reusable user-interface components and their
  accessibility actions.

Run the complete suite from the repository root:

```powershell
flutter test
```

Run a focused test file while developing a feature:

```powershell
flutter test test\services\flow_executor_test.dart
```

For every new user-visible feature, add at least one test at the lowest useful
level: pure model/utility first, then DAO/service, then widget or integration
coverage when interaction or persistence is involved. Avoid network calls,
real device storage, and production content URLs in tests; use bundled assets,
SharedPreferences mocks, in-memory SQLite, or a mocked platform channel.
