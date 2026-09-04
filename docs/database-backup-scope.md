# Database Backup Scope

Tonos database export is a portable JSON snapshot of the application's local
database. It is not a complete device backup and it is not encrypted.

## Included State

Current v3 exports include completed workout history, measurements, profiles,
plans, nutrition records, custom and referenced catalog rows, personal
exercise-allocation overrides, active plans, active workout drafts, and pending
automatic progression. These are the rows required to restore the same
repository-visible training state on a fresh current-version install.

## Rebuilt State

Recipe nutrient caches, daily nutrition totals, food search indexes, and
historical workout record events are not serialized. After a full restore,
Tonos recalculates them from the authoritative imported rows. Bundled catalog
aliases and creator allocation defaults are also refreshed from the current app
version after restoration.

## Excluded State

The export does not include SharedPreferences, downloaded media files, media
cache metadata, diagnostics, cloud-content metadata, app maintenance metadata,
or files saved outside the app. SharedPreferences migration is tracked
separately; cached media is intentionally re-downloaded as needed. A future
feature that attaches user photos or other external files must add them to an
archive format before claiming that they are backed up.

## Import Safety

Version 3 files declare a complete database snapshot and must include every
required snapshot table, including empty tables. A complete snapshot replaces
authoritative database rows in one transaction, validates foreign keys, then
rebuilds derived state. Missing or malformed v3 sections block the import
before replacement.

Older version 2 and legacy table-map files remain readable. When they do not
contain the current complete snapshot contract, Tonos merges the available
authoritative rows and never clears unrelated current data first. Older files
cannot recreate data that their original format never stored, such as personal
allocation overrides.

## Maintenance Rule

Every permanent application table must appear in
`database_backup_policy.dart` with a data class and restore action. The backup
contract test scans schema declarations and fails when a new table has no
policy decision.
