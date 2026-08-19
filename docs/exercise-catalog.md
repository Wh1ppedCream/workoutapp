# Exercise Catalog Maintenance

`assets/exercises.json` is the shipped exercise catalog. It is an object with
a positive `revision` and an alphabetically ordered `exercises` list. The app
reconciles a newer revision transactionally without changing local database
row IDs, so existing workouts, plans, records, and cached media keep their
references.

## Stable identity

Every shipped exercise has two immutable identifiers:

- `catalogId`, for example `tonos.exercise.0314`, is the durable catalog and
  media identity. Never change or reuse it.
- `legacyMediaId` is the original numeric media identity. Keep it unchanged
  so older published manifests still resolve safely during the migration.

The SQLite `exercise_definitions.id` is deliberately *not* a catalog ID. It
is a local implementation detail and may differ between fresh installs and
upgraded databases.

## Safe edits

For every edit that changes shipped exercise content, increase the top-level
`revision` by one before release.

- **Add:** allocate the next unused `catalogId` and `legacyMediaId`, add the
  full exercise record in case-insensitive alphabetical order by `name`, and
  raise `revision`.
- **Rename:** keep both IDs unchanged, replace `name`, add the old public name
  to `aliases`, move the record to its new alphabetical position, and raise
  `revision`.
- **Update details:** retain both IDs, change equipment, scores, notes,
  muscles, or body parts as needed, and raise `revision`.
- **Remove:** delete the record from the next revision rather than reusing its
  IDs. Upgraded installs mark the old shipped definition `retired`; it no
  longer appears in new catalog selection but remains available to historic
  workouts and plans.

Do not change an ID to make the JSON look tidy, do not reuse a retired ID, and
do not lower or reuse a released revision. User-created definitions have no
`catalogId` and are never affected by catalog retirement.

## Media publishing

The content pipeline resolves `exerciseCatalogId` first, but accepts
`exerciseId` as the legacy numeric fallback for manifests already published.
New generated manifests emit both fields. A manifest with an unknown stable
catalog ID fails closed; it cannot fall back to a numeric ID and attach media
to the wrong exercise.

When changing exercises and media together, update the catalog first, build a
new manifest, validate it, and then publish the manifest/assets as one release
unit. Do not hand-edit generated manifests.

## Checks before commit

Run the catalog contract and the database/media migration tests after editing.
The full command block is provided with the change that introduced this
document. The contract checks identifier uniqueness and alphabetical order;
the migration tests check rename, retirement, database preservation, and
stable media attachment.
