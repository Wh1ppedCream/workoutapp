# Missing, Blocked, and Unverified Evidence

Approval status is defined by the official route ledger, not inferred from evidence coverage. `MISSING` means there is no verified capture. `BLOCKED` means obtaining the state would risk changing retained preview data or requires an unavailable flow. `NOT APPLICABLE` means source inspection found that the requested control/state is not implemented in that route. The source manifest and generated coverage matrix describe state-level evidence.

## Missing

Approved Train2 is outside this pending-evidence queue. Its Train landing presentation was explicitly approved on 2026-10-19 after the refreshed light-mode view. There are no Train2 source captures or coverage entries in this campaign; no separate final dark-mode, History-content, or Add-popup visual evidence is claimed. This evidence boundary does not reopen the user's approval or change other page/interaction classifications.


## Blocked

- **Onboarding welcome and equipment-selection steps — light and dark.** The installed isolated preview entrypoint bypasses first-run onboarding. Replay can modify onboarding/profile preferences, so it was not triggered.
- **Generated plan output and adjustment actions — light and dark.** The Generate Plans setup page is now visually approved and removed from the active review gallery. Its generated-output state remains uncaptured because generation persists presets; this is a separate interaction/qualification evidence limit, not a pending page approval.
- **Editing an existing plan-specific flow rule — light and dark.** The Plan-Specific Flow Methods Editor is visually approved. No existing plan rule is present in retained data, and creating/saving one solely to unlock this state would mutate protected preview data. This remains an evidence gap for that interaction, not pending visual approval of the page.

## Not applicable after source inspection

- **Plan Management plan overflow/delete/restore menus:** current rows expose inline Archive/Activate; no delete or restore menu is implemented.
- **Dashboard restore-defaults confirmation:** the action calls `DashboardConfig.restoreDefaults()` immediately; there is no confirmation dialog. It was not activated because it persists configuration.
- **Caller-specific Measurement Library presentation:** source call sites instantiate the same `MeasuredItemsPage`; no caller-specific visual branch was found. The Profile route already has separate approval status.
- **Additional workout/session overlay combinations:** the applicable current combinations are already covered by earlier approvals; this campaign did not duplicate approved states.

## Retained stale or duplicate screenshots excluded from the active gallery

These image files and manifest records remain in the local archive to preserve capture history, but are excluded from the generated review gallery so they cannot be mistaken for current or distinct evidence. They are **not evidence for the state claimed**. Use the listed verified capture instead.

| Screenshot ID | Why unverified | Use instead |
|---|---|---|
| `01-browser-muscle-menu-dark-final` | Shows Focus Area options, not Specific Muscle options. | `01-browser-specific-muscle-menu-dark-campaign` |

All Premade Plans captures are excluded from the active gallery because the page is approved; seven stale or duplicate records remain individually flagged in the source manifest. The separate Browser muscle-menu image remains in the gallery with its unverified status visible. No archived PNG/XML file or source manifest entry was deleted.

## Other evidence limits

- The approved shared exercise sheet and its image viewer are excluded from the pending gallery. Older Anatomy/Plan-caller screenshots show superseded sheet layouts and are retained only in the archive. Current production Expressive entry points all resolve through `ExerciseDetailSheet.show` to the same approved presentation; caller-specific routing/data qualification remains separate. The archived viewer screenshots do not independently demonstrate the full zoom/pan gesture range or missing-media/error/retry fallback states.
- Muscle detail is represented with Biceps Brachii and the low-count Adductor Brevis example; not every muscle, viewport, or secondary interaction was captured.
- Gym Profile / Equipment is visually approved for the reviewed light/dark presentation; its create/empty-profile states remain uncaptured. This is an evidence limitation, not a pending page approval.
- Dashboard has populated top/lower and edit-mode captures, but no persisted reorder was performed. Responsive and empty-widget states are not comprehensively captured.
- Search captures include the keyboard-focused Browser query, but this campaign did not run a systematic responsive or text-scaling matrix.
- Screenshot provenance identifies the base commit, installed APK artifact hash, and hashes of relevant dirty source files, but the complete dirty source snapshot used with the temporary capture entrypoint cannot be reconstructed. See `build-provenance.json`.
- After the 2026-10-13 22:44–23:13 screenshot refresh, the preview DB/WAL/SHM and two preference files were restored byte-for-byte from the immediately pre-install snapshot and verified; the package remains force-stopped and was not relaunched after restore. The earlier campaign's SHM mismatch against its older manifest remains documented as a historical restore record. See `preview-restore-verification.json`.

## Approved archive — Weekly Sets Overview

**Analytics Dashboard / Weekly Sets Overview — A — Visually Approved / Frozen**, explicitly authorized by the user on 2026-10-15 for the reviewed light/dark main screen, Bodyparts and Muscles tabs, heatmap/summary hero, rows, selection styling, proportions, and existing reviewed interactions. It is no longer a pending visual-review gap. Its four PNG/XML pairs and unchanged manifest records remain archived at [`pages/11-analytics-dashboard/`](./pages/11-analytics-dashboard/); capture-time B labels are historical. These 2026-10-14 images predate the latest refinements and do not prove every current state, viewport, or text scale. No new capture, responsive/accessibility check, test, or technical/release qualification is claimed. Dashboard main and Bodypart/Muscle detail approvals remain independent.

## Approved archive — Gym Profile / Equipment

**Train → Gym Profile / Equipment — A — Visually Approved / Frozen**, explicitly authorized on 2026-10-16 for the reviewed light/dark profile/equipment presentation, including the profile card, equipment search/categories/rows, same-line Equipment actions, and conditional floating Save Profile control. Its 10 PNG/XML capture pairs and unchanged manifest records remain archived under [`pages/08-gym-profile/`](./pages/08-gym-profile/); they predate the latest refinements and are not current-source proof. Create/empty-profile states remain uncaptured. Responsive, accessibility, technical, automated-test, and release qualification are separate.

## Approved archive — Health Trend Detail and entry actions

**Progress → Health Trends → metric card → Measurement Trend Detail — A — Visually Approved / Frozen**, baseline refreshed by explicit user authorization on 2026-10-16. Scope includes the current summary, chart, entry rows, Log entry action and reviewed route-owned entry actions. Its six historical light/dark menu/edit/delete PNG/XML pairs remain at [`overlays/health-entry-actions/`](./overlays/health-entry-actions/) with unchanged manifest records, but are excluded from the active pending gallery and contact sheets. They predate the final polish. The latest implementation pass confirmed light mode; fresh final-polish dark-mode and independent visual confirmation of every dialog state are not claimed. Those are evidence/qualification limitations, not a pending approval for this page. Unreviewed forms in other caller contexts remain independently pending. The existing A page is not counted again: at that update master totals were **A36 / B11**; current totals are **A37 / B10**, and the 24-route dossier remains **21 approved / 3 pending**.

## Approved archive — Optimized Workout Settings

**Train → Overview → Optimize → settings gear → Optimized Workout Settings — A — Visually Approved / Frozen**, explicitly authorized by the user on 2026-10-16. Its four historical light/dark PNG/UI-hierarchy pairs and four manifest records remain archived under [`pages/07-optimized-settings/`](./pages/07-optimized-settings/), but are excluded from the active pending gallery and contact sheets. They predate the final Avoided-indicator correction; the latest Pixel 7 refresh confirmed the corrected prohibition symbol in light mode. No fresh latest-source dark capture or exhaustive keyboard, validation, selector, large-text, responsive, accessibility, or technical qualification is claimed. These evidence limits do not reverse the user-authorized visual approval. At that approval update master page totals were **A36 / B11**; current totals are **A37 / B10**. The separate 24-route dossier remains **21 approved / 3 pending**.

## Approved archive — Plan Management

**Train → Plans → Manage Plans — A — Visually Approved / Frozen**, explicitly authorized by the user on 2026-10-16 for the current Expressive page, its active/archived plan groupings, plan rows, and inline actions. Four 2026-10-14 PNG/XML captures and twelve source coverage records remain in the archive and manifest but are excluded from the active pending gallery, generated coverage matrix, and contact sheets. These captures predate the latest refinement and are not current-source proof. The empty-plan state was not captured because reaching it would require deleting or replacing protected preview data; this does not block the user's explicit page approval. No fresh screenshot or technical, responsive, accessibility, test, or release qualification is claimed here. Current explicit master page-archetype totals are **A37 / B10**; the separate 24-route dossier remains **21 approved / 3 pending**. Dashboard retains its independent status.

## Approved archive — Premade Plans

**Train → Plans → Browse Premade Plans — A — Visually Approved / Frozen**, explicitly authorized by the user on 2026-10-17. The approved Expressive page scope includes the duration selector, profile-equipment filter, plan groups and cards, exercise preview rows, concise duration-and-plan descriptions, and Add actions. Its 15 screenshot records and 14 coverage rows remain preserved in source folders and the manifest; the eight previously visible current captures, seven stale/duplicate captures, all page coverage rows, and its generated contact sheet are excluded from active unapproved outputs. No new screenshots were captured; existing captures predate the concise-description update and are historical rather than current-source proof. Empty/no-match and load-failure evidence remains incomplete, and this update does not claim theme-specific, responsive, accessibility, automated-test, technical, or release qualification. These evidence limits do not block the user's explicit approval. The explicit master page-archetype totals move from **A37 / B10** to **A38 / B9**; the separate 24-route dossier remains **21 approved / 3 pending**. Dashboard, onboarding, Preset Detail, and alternate callers retain independent classifications.

## Approved archive — Plan-Specific Flow Methods Editor

**Profile → Training → Gym & Workout Settings → Workout Progress Rules → expand Plans → plan ⋮ → Add Rule or Edit — A — Visually Approved / Frozen**, explicitly approved by the user on 2026-10-18. The approved scope includes the current Expressive Copy from choices (Last set, First set, Specific set), one-based Set number input and guidance, anchored menu, and existing Cancel/Save behavior. Six 2026-10-13 screenshot records and eight source coverage records remain preserved in the archive and manifest, but are filtered from active unapproved outputs. They predate the Copy from refinement and do not show its current appearance. Editing an existing saved rule remains uncaptured because retained preview data has no saved rule. These limitations do not block the explicit approval. Current explicit master totals are **A39 / B8**; the separate 24-route dossier is **22 approved / 2 pending**. The Flow Methods selection page and shared AutoPresetFlowScreen retain their independent approval scopes. Responsive, accessibility, keyboard, test, technical, and release qualification remain separate.

## Approved interaction archive — Train Plans Archived Plan Actions

**Train → Plans → archived plan card → Show menu → Delete confirmation — A — Visually Approved / Frozen as an interaction state**, explicitly authorized on 2026-10-18. The scope is the visual presentation of the archived-plan action menu and its cancel-only Delete confirmation in the reviewed light and dark captures. Four 2026-10-13 PNG/XML pairs and four source coverage rows remain preserved in their original locations and manifest but are excluded from active unapproved outputs. The menu options were not activated, and the Delete confirmation was canceled, so option outcomes and deletion behavior are not visually or functionally qualified. These older captures are not current-source proof. This interaction approval does not add a page archetype or change the master **A39 / B8** or 24-route **22 approved / 2 pending** totals; the separate Manage Plans page retains its existing approval. Responsive, accessibility, functional, technical, and release qualification remain separate.

## Scope boundaries

Today’s Records, Diet & Nutrition Settings, and Manual Nutrition Goals are a separate unmapped Nutrition review group, not extra campaign B page archetypes. Pantry Log and Plan Meal appear as separate placeholder destinations. C/D/legacy/protected/deferred routes remain in the current master route ledger and are not reclassified by this campaign. The original campaign made no automatic approvals. On 2026-10-15 the user explicitly approved the Exercise Browser, its Filters interaction, the Catalog-caller Exercise Details Sheet, the Catalog-caller Exercise Image Media Viewer, and Weekly Sets Overview. On 2026-10-16, Generate Plans, Gym Profile / Equipment, Health Trend Detail, Optimized Workout Settings, and Plan Management were also explicitly approved. On 2026-10-17, Premade Plans was explicitly approved. On 2026-10-18, the Plan-Specific Flow Methods Editor and Train Plans Archived Plan Actions interaction state were explicitly approved. These approved items are excluded from the current unapproved gallery; source captures remain archived. The current explicit master page-archetype totals are **A39 / B8**, while the separate 24-route dossier remains **22 approved / 2 pending**. Visual approval remains separate from technical, responsive, accessibility, automated-test, and release qualification.
