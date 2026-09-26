# Exercise Catalog Localization

The English text in `assets/exercises.json` is the canonical catalog content.
Built-in exercise guidance can be translated without changing database rows,
workout history, media identities, or user-created exercises.

## Translation Bundle

`assets/exercise_content_localizations.json` maps a supported locale to a
stable `catalogId`. Each translated entry must include all three fields:

- `setupNotes`: numbered steps beginning with `1. `.
- `executionNotes`: numbered steps beginning with `1. `.
- `tipsNotes`: short bullet points beginning with `- `.

The same bundle's `names` object maps stable `catalogId` values to localized
display names. These names are presentation-only: canonical English names stay
in the database and continue to own history, media, plan references, imports,
and search aliases. Keep `nameCoverage` synchronized with every locale map.
Name coverage may be rolled out one complete locale at a time; a locale listed
under `names` must always contain every built-in catalog ID. Spanish, French,
Bangla, Simplified Chinese, and Hindi now have complete name coverage. Canadian
French inherits the French names unless a reviewed regional override is added.
Unsupported locales and user-created exercises retain their stored names.

Stable-code localization for other shipped catalog entities is maintained
separately in `assets/catalog_entity_localizations.json` and
`assets/premade_plan_localizations.json`. The current implementation covers 40
equipment labels, 56 muscle labels, 21 direct built-in plan IDs, and four
derived one-hour plan rows in the same five base locales. Stretch and nutrition
catalog localization remain deferred until those product surfaces are ready.

Use `fr_CA` only for Canadian French differences; the resolver falls back from
a regional locale to its base language, then to the original English catalog
guidance. Do not add translations for user-created exercises, and do not use
visible exercise names as identifiers. Keep the top-level `coverage` count in
sync with each locale's entries; its contract catches drift.

## Review And Release

As of 2026-09-03, the deterministic catalog-localization contracts pass for
all 300 exercise IDs and all five non-English base locales, including runtime
placeholder and fallback checks. Guidance may be drafted during development,
but a fluent speaker and an exercise-content reviewer must approve every
locale batch before release. A missing entry deliberately shows the stored
English text; it must not show a partial translation. Record completed reviews
in `localization-review.md`, and run the catalog localization contract whenever
entries are added, renamed, or retired.
