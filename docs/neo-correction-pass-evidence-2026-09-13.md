# Neo Correction Pass Evidence

Status: **Pending fresh-device review**

Status reconciled 2026-09-14: original Q3 and N4 device acceptance remains valid
for its historical scope. This matrix covers subsequent refinements and Classic
restoration; it does not erase that acceptance. Automated results include the
reported 274-test plus six-responsive-test run and later focused passes, most
recently 51 Train-tab/settings/Neo-regression tests after the selector shadow
change. These are separate source states and do not close this device matrix.
See the [consolidated roadmap](theme-consolidated-roadmap.md) for the current
step list and verification summary. Fill actual results here rather than
starting another overlapping qualification document.

This record is intentionally a qualification template. No device, screenshot,
keyboard, screen-reader, or matched Classic result is marked as passed until a
reviewer completes the checks on the target device.

## Visual Review Supplement (2026-09-16)

The user accepted all 21 entries in the current Neo visual review as good for
now. The final bright-field dropdown contrast correction was also verified by
user-run formatting, clean analysis, and 63 focused Flutter tests. This is
evidence for the reviewed normal route appearances only. Do not translate it
into PASS values for the device matrix below without the exact conditions,
results, and evidence that each row requires.

## Setup Metadata

- Reviewer: Pending
- Review date: Pending
- Build or commit identifier: Pending
- Device manufacturer and model: Pending
- Android version and API level: Pending
- Physical resolution and Flutter logical viewport: Pending
- Display density and display-size setting: Pending
- System font size and app text scale: Pending
- Locale and region: Pending
- Fixture account and data state: Pending
- Keyboard, D-pad, emulator keyboard, and TalkBack setup: Pending

## Matched Visual Checks

| Check ID | Route or component | Family / brightness | Width / scale / locale | Expected result | Actual result | Status | Evidence | Issue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V01 | Train Overview, Weekly Overview, Active Plans | Neo light and dark | Normal scale, matched locale | Same state and complete content in both modes | Pending | PENDING | Pending | |
| V02 | Exercise Progress hero and selectors | Neo light and dark | Normal scale, matched locale | Localized names and values remain complete | Pending | PENDING | Pending | |
| V03 | Workout Report with Additional Details expanded | Neo light and dark | Normal scale, matched locale | Insight tiles grow and remain readable | Pending | PENDING | Pending | |
| V04 | Profile and Settings hero surfaces | Neo light and dark | Normal scale, matched locale | Shared reflow without clipping or Neo leakage into Classic | Pending | PENDING | Pending | |
| V05 | Bright-surface charts and heatmaps | Neo light and dark | Normal scale, matched locale | Lines, points, legends, and heatmap endpoints are distinct | Pending | PENDING | Pending | |
| V06 | Exercise Progress, narrow viewport | Neo light and dark | 200% scale, longest relevant locale | Hero and selector content are reachable without clipping | Pending | PENDING | Pending | |
| V07 | Workout Report insights | Neo light and dark | 200% scale, longest relevant locale | One-column, stacked insight content is complete | Pending | PENDING | Pending | |
| V08 | Weekly Overview | Neo light and dark | 200% scale, longest relevant locale | Heatmap, labels, counts, and More action remain reachable | Pending | PENDING | Pending | |
| V09 | Settings hero | Neo light and dark | 200% scale, longest relevant locale | Title, subtitle, and icon do not overlap | Pending | PENDING | Pending | |
| V10 | Shared changed components | Classic light and dark | Matched state and conditions | Classic colors, radii, borders, shadows, and density remain approved | Pending | PENDING | Pending | |

## Interaction Checks

| Check ID | Check | Expected result | Actual result | Status | Evidence | Issue |
| --- | --- | --- | --- | --- | --- | --- |
| I01 | Keyboard focus and Enter/Space activation | Enabled TextButton shows focus and activates once per key; disabled button does neither | Pending | PENDING | Pending | |
| I02 | Exercise Progress selector body | Selecting changes the exercise only | Pending | PENDING | Pending | |
| I03 | Exercise Progress remove action | Removal changes the exercise list only | Pending | PENDING | Pending | |
| I04 | Exercise Progress semantics | Selector and remove action are announced as separate localized controls | Pending | PENDING | Pending | |
| I05 | Horizontal selector scrolling | Horizontal scrolling works without trapping page vertical scrolling | Pending | PENDING | Pending | |
| I06 | Report scrolling | Expanded details reach the final insight without an inner vertical scroll trap | Pending | PENDING | Pending | |
| I07 | Theme switching | Selection, expansion, data, and intended scroll state survive Neo light/dark switching | Pending | PENDING | Pending | |

## Closure

Do not mark this record complete until every check has an explicit PASS, FAIL,
or BLOCKED result, every failure has a follow-up issue, and matched Classic
evidence is recorded in `docs/classic-theme-baseline.md`.
