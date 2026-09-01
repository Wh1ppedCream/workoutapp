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

Use `fr_CA` only for Canadian French differences; the resolver falls back from
a regional locale to its base language, then to the original English catalog
guidance. Do not add translations for user-created exercises, and do not use
visible exercise names as identifiers. Keep the top-level `coverage` count in
sync with each locale's entries; its contract catches drift.

## Review And Release

Guidance may be drafted during development, but a fluent speaker and an
exercise-content reviewer must approve every locale batch before release. A
missing entry deliberately shows the stored English text; it must not show a
partial translation. Record completed reviews in `localization-review.md`, and
run the catalog localization contract whenever entries are added, renamed, or
retired.
