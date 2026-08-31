# Timestamp and Local-Calendar Semantics

Tonos stores two related but different kinds of time information. They must
not be substituted for one another.

## Data contract

| Record | Exact instant | Stable calendar day | Legacy export field |
| --- | --- | --- | --- |
| Workout session | `sessions.completed_at_ms` UTC epoch milliseconds | `sessions.training_day` as `YYYY-MM-DD` | `sessions.date` |
| Measurement | `measurements.measured_at_ms` UTC epoch milliseconds | `measurements.measured_on` as `YYYY-MM-DD` | `measurements.timestamp` |
| Nutrition diary entry | `diary_entries.logged_at` UTC epoch milliseconds | `diary_entries.date` as `YYYY-MM-DD` | None |

The exact instant answers questions such as "which workout finished most
recently?" The stable calendar day answers questions such as "which day should
contain this workout on the history calendar?"

## Writes and reads

New workout and measurement writes populate both canonical fields and retain
their legacy ISO text field for export compatibility with existing backups.
The day is derived from the completion or measurement time in the device's
local calendar at write time. Workout completion remains the source of the
workout day; the active-workout start time is never used for that purpose.

Use epoch milliseconds for ordering, pagination, precise reports, recent
activity, and generic time-window queries. `SessionDao.getSessionsForInstantRange`
keeps the existing inclusive `[start, end]` contract. Nutrition's precise
entry APIs intentionally use a half-open `[start, end)` range so adjacent
windows do not duplicate an entry.

Use `LocalCalendarDay` and the stable day fields for calendar grouping, daily
totals, weekday/streak calculations, monthly records, date-only labels, and
calendar-day queries. `SessionDao.getSessionsForCalendarRange` accepts an
inclusive start and end day. Do not use a timestamp at midnight as a substitute
for a saved calendar day.

## Migration and import behavior

Database version 61 adds the workout and measurement canonical fields,
backfills them from existing ISO text, and adds indexes for exact-time and
calendar-day reads. Existing legacy text is never rewritten during the
migration. For a legacy ISO value, the original `YYYY-MM-DD` text prefix is
kept as the historical visible day, while the parsed value supplies the exact
UTC instant.

An imported backup is canonicalized immediately after its atomic import
transaction succeeds and before normal readers or derived-record maintenance
run. Older backups that contain only legacy `date` or `timestamp` values remain
supported; current exports include both legacy and canonical fields.

## Implementation rules

- Do not add new SQL comparisons or ordering based on `sessions.date` or
  `measurements.timestamp`.
- Do not derive a calendar day by converting an old saved instant in the
  current device time zone when a stored day is available.
- Keep date-only UI labels based on `LocalCalendarDay`; use the exact instant
  only for a clock time, ordering, or an explicit time-range operation.
- When adding a new timestamped feature, document whether it needs an exact
  instant, a stable calendar day, or both before adding storage.

## Regression coverage

`test/models/temporal_semantics_test.dart` covers parsing and display
semantics. `test/db/temporal_semantics_migration_test.dart` covers the v61
migration, canonical writes, exact versus calendar session ranges, and
nutrition's exclusive upper bound. `test/database_import_contract_test.dart`
covers legacy-import acceptance and canonicalization ordering. `test/db/database_upgrade_test.dart`
covers the upgrade path from historical schema versions.
