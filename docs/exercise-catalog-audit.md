# Exercise Catalog Audit

This document separates objective catalog safety checks from the human review
needed before a Tonos release. It applies to the shipped
`assets/exercises.json` catalog only; user-created exercises remain user-owned
content.

## Automated Gate

`test/exercise_catalog_audit_contract_test.dart` must pass whenever the
catalog changes. It rejects:

- invalid or unexpected catalog fields;
- missing, duplicate, or unknown equipment, body-part, and muscle references;
- invalid ratings, IDs, aliases, sequential muscle ranks, optional flags, creator
  allocations, and starter-load profiles;
- unsafe text encoding, control characters, replacement characters, common
  mojibake markers, surrounding whitespace, or malformed instruction lines;
- guidance that does not use exactly three short setup steps, three short
  execution steps, and three short tips;
- media-source entries that no longer resolve to the current exercise identity
  or a declared historical alias.

This gate intentionally does not decide whether a movement is appropriate for
every user, whether a particular muscle order is correct, or whether two
similar exercises should be combined. Those are product decisions and require
review.

## Localization Boundary

Localized names and guidance are presentation data keyed by stable
`catalogId`; they do not replace the canonical English catalog values used for
matching, history, plans, imports, exports, or media. The localization bundles,
ARB resources, and native-speaker review are tracked separately in
`exercise-catalog-localization.md`, `localization-remaining-inventory.md`, and
`localization-review.md`.

## Edit Workflow

1. Make catalog edits while preserving `catalogId` and `legacyMediaId`.
2. Add a previous public name to `aliases` when renaming an exercise.
3. Increase the top-level `revision` for every shipped catalog change.
4. Run the automated catalog and media checks before committing.
5. Review only the changed exercises using the checklist below.
6. Record the revision, reviewer, date, and unresolved decisions in the
   release record.

Run these checks in one PowerShell block:

```powershell
Set-Location E:\projects\env_test
$ErrorActionPreference = 'Stop'

dart format `
  test\catalog_contract_test.dart `
  test\exercise_catalog_audit_contract_test.dart `
  test\premade_plan_catalog_contract_test.dart `
  test\db\exercise_catalog_seed_test.dart

dart analyze `
  test\catalog_contract_test.dart `
  test\exercise_catalog_audit_contract_test.dart `
  test\premade_plan_catalog_contract_test.dart `
  test\db\exercise_catalog_seed_test.dart

flutter test `
  test\catalog_contract_test.dart `
  test\exercise_catalog_audit_contract_test.dart `
  test\premade_plan_catalog_contract_test.dart `
  test\db\exercise_catalog_seed_test.dart

dart run tools\content_pipeline.dart validate-exercise-media `
  --source tools\content_pipeline\exercise_media_source.example.json `
  --check-remote `
  --strict `
  --quality-preset exercise-thumbnail

git diff --check
```

## Human Review Checklist

For each changed or added exercise, confirm:

- The name is clear, specific, and not an alias of an existing exercise.
- Equipment lists every required item and excludes optional alternatives.
- Body parts and ranked muscles describe the intended movement.
- Ratings and any starter-load profile are appropriate and conservative.
- Setup steps establish a safe starting position and required safety equipment.
- Execution steps explain the movement plainly without medical or guaranteed
  outcome claims.
- Tips contain the most useful safety or technique reminders and do not repeat
  setup or execution text.
- Any thumbnail depicts the exact movement and matches the stable catalog ID.
- Renames preserve history through aliases; removals are deliberate retirements.

## Current Baseline: Revision 7

Date: 2026-08-31

- 300 active catalog exercises.
- 154 current development thumbnail mappings, all resolving to a current name
  or declared alias.
- All catalog equipment, body parts, and muscles resolve to their canonical
  reference assets.
- Three duplicate `Hips` relationships were removed from the Side Lunge
  variants.
- All instructions use the compact three-step and three-tip format.
- Seventeen exercise variants have movement- and equipment-specific guidance guarded
  by semantic regression checks.
- The unsupported `Donkey Kick - Leg Extension Machine` entry was retired. It
  had no media or plan references and duplicated the existing leg-extension
  instructions despite declaring glute-focused metadata.

### Review Record

- The project owner reviewed and approved the revision 5, 301-entry baseline on
  2026-08-29.
- Revision 6 corrects confirmed copied-template guidance and retires one invalid
  duplicate. Final release review should include these changed entries.
- Revision 7 corrects five additional equipment-specific guidance mismatches
  discovered during localization review.
- This records product-owner approval only; it does not claim independent
  trainer or medical certification.

## Release Sign-off

Add a new entry for each release candidate:

| Catalog revision | Reviewer | Date | Changed exercise IDs | Open decisions | Approved |
| --- | --- | --- | --- | --- | --- |
| 4 | Superseded | 2026-08-29 | `tonos.exercise.0262`, `tonos.exercise.0308`-`0311` | Included in revision 5 review | N/A |
| 5 | Project owner | 2026-08-29 | All 301 active entries; `tonos.exercise.0243`, `tonos.exercise.0287`-`0290` | None recorded | Yes |
| 6 | Pending final review | 2026-08-31 | `tonos.exercise.0006`, `0021`, `0029`, `0034`, `0054`-`0055`, `0064`-`0065`, `0069`-`0070`, `0088`-`0089`, `0099` | Review corrected guidance in the app | Pending |
| 7 | Pending final review | 2026-08-31 | `tonos.exercise.0109`, `0126`-`0127`, `0139`, `0151` | Review corrected guidance in the app | Pending |
