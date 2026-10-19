# Route and Component Audit Ledger

This ledger records a rendering-correctness review, not a design approval or release qualification. Auditors inspected source hierarchies and relevant tests. Physical-device visual verification was concentrated on the primary Flow Editor defect; routes marked “source review” were not individually screenshot-qualified.

## Confirmed defects and fixes

| Route/component | Defect | Correction / verification |
| --- | --- | --- |
| Profile → Gym & Workout Settings → Workout Progress Flows → App Default Progression → Add a branch | ExpansionTile's opaque Material painted over the Expressive outline behind it, exposing interrupted/straight border segments around the rounded surface. | Expressive-only foreground outline using the tile's same ShapeBorder above the anti-aliased clipped card. Light/dark collapsed and expanded Pixel captures; focused widget/golden tests. |
| Profile Expressive `SettingsSection` | Descendant Material ink could extend beyond the rounded section surface. | Explicit Profile Expressive Material radius and `Clip.antiAlias`. Focused light/dark widget test; Classic/Neo behavior assertion. |
| Profile Expressive choice fields | Choice InkWell had no radius matching its existing outlined field. | InkWell uses the current `OutlineInputBorder.borderRadius`. Focused Profile Expressive test coverage. |

## Source-reviewed routes and surfaces

| Family | Routes/components inspected | Result |
| --- | --- | --- |
| Profile, approved | Profile root; User Information; UI & Appearance; Navigation Editor; Guided Tutorials; Gym & Workout Settings; Workout Progress Flows main page; Ongoing Workout Exit popup child state. | No static geometry/paint defect found. Ongoing Workout Exit is now **A — visually approved / frozen** for light/dark and its single-popup, three-option presentation; this does not add a page archetype or establish technical qualification. Shared section/choice interaction clipping above does not change the approved resting design. |
| Profile, unapproved | Workout Settings; Workout Progress Flow Editor; Workout Progress Rules / Flow Methods; Analytics Settings; Volume Boundaries; Body Part and Muscle Ranking; Progress Settings; Measured Items Library; Exercise Editor; Database Settings; Diagnostics & Privacy; other reachable descendants, selectors, and dialogs. | Flow Editor defect fixed. No other confirmed shape/border/clipping/shadow defect reported. |
| Train and workout | Train; Active Workout/session screen; WeightCard and set rows; Session Detail/Past Workout. | No additional confirmed shape, clipping, or shadow defect reported. Existing expansion and normal-width design remain unchanged. |
| Catalog | Catalog root/browser; Exercise Focus Library; body-part and muscle detail; Exercise Details sheet; shared definition tiles/media fallbacks. | No additional confirmed defect reported. |
| Progress | Progress root; Workout Report; Exercise Progress/1RM detail; Health Trends; Measurement Trend detail; chart/summary surfaces. | No additional confirmed defect reported. |
| Logbook | Calendar root and period summaries; Full History / All Sessions; Session Detail and history exercise cards. | No additional confirmed defect reported. A suspected calendar corner anomaly was judged to be screenshot scaling, not a source paint defect. |
| Dashboard and shared surfaces | Dashboard widgets; heroes, nested sections, accordions, navigation rows, selection surfaces, dialogs/sheets, buttons, icon tiles, empty states, sticky actions, graph editor surfaces. | Source review found no further confirmed defect. The shared Profile ink containment fixes were narrowly token-gated. |

## Coverage limits and remaining verification

- The Pixel 7 check covered App Default Progression at 1080×2400 physical pixels / 420 dpi, light and dark, collapsed and expanded states for both panels. A dark transition recording exists but was not frame-sampled.
- A representative dark Profile UI & Appearance screen was captured; transient Profile ripple clipping was validated in widget tests rather than manually photographed mid-ripple.
- The 430×1400 golden viewport verifies the four Flow panel variants. No complete 320, 360, 390, 430, 600, 800, and 1024 dp matrix, landscape matrix, enlarged-text matrix, or multi-DPR matrix was run.
- Not every route listed above received a physical-device capture. Source review and targeted tests support the “no confirmed defect” finding, but do not prove pixel-level correctness for every state.
- The full suite completed with 21 failures against the heavily dirty current checkout; analyzer reported 3 warnings and 78 infos. Details are in the audit README. No inventory/ratchet baselines or approval entries were changed.

## Preservation

- No intended Expressive colors, corner assignments, card dimensions, padding, typography, shadows, progression logic, route behavior, or stored data semantics were changed.
- The legacy Flow card border remains for Classic/Neo; Expressive-only condition gates the foreground outline.
- Profile section/choice clipping activates only when the corresponding Profile Expressive destination tokens are present.
- No visual approval statuses were altered. Visual approval and technical qualification remain separate.
