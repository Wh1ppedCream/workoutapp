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

## Current Baseline: Revision 5

Date: 2026-08-29

- 301 active catalog exercises.
- 154 current development thumbnail mappings, all resolving to a current name
  or declared alias.
- All catalog equipment, body parts, and muscles resolve to their canonical
  reference assets.
- Three duplicate `Hips` relationships were removed from the Side Lunge
  variants.
- All instructions use the compact three-step and three-tip format.

### Review Record

- The project owner reviewed and approved the current 301-entry baseline on
  2026-08-29.
- This records product-owner approval only; it does not claim independent
  trainer or medical certification.

## Release Sign-off

Add a new entry for each release candidate:

| Catalog revision | Reviewer | Date | Changed exercise IDs | Open decisions | Approved |
| --- | --- | --- | --- | --- | --- |
| 4 | Superseded | 2026-08-29 | `tonos.exercise.0262`, `tonos.exercise.0308`-`0311` | Included in revision 5 review | N/A |
| 5 | Project owner | 2026-08-29 | All 301 active entries; `tonos.exercise.0243`, `tonos.exercise.0287`-`0290` | None recorded | Yes |
