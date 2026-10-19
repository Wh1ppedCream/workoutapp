# Post-remediation Pixel 7 evidence

Captured locally on 2026-10-10 from the current remediation candidate. The
source/build provenance is recorded in the parent
[`current-source-snapshot.md`](../../current-source-snapshot.md). The user
requested that screenshot media remain local. These captures are evidence for
human review only; they do not grant visual approval or technical qualification.

## Provenance

- Candidate branch/HEAD: `feature/expressive-visual-polish` at `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`, with the seven dirty source/test files listed in the source snapshot.
- Device: Pixel 7 `28021FDH200228`, 1080×2400 physical pixels, 420 dpi (about 411×914 dp).
- Package/database: `com.tonos.expressivepreview` / `tonos_expressive_preview.db`.
- Flutter/Dart: 3.47.5 / 3.13.4.
- APK SHA-256: `c7ae829826d8527660f5a4e8b4a1a2e575680f5aa20a72b5d64f49f374370da0`.
- Captures are unedited Android screenshots. Matching UI hierarchy XML dumps are included beside the PNGs.
- No workout/profile values were edited. The Mapping edit captures show entry into edit mode only; Cancel was used without changing selections. Preview DB/WAL/SHM and preference files were restored byte-for-byte and verified afterward.

## Screenshots

### Smoke capture

- [Initial Train Overview](initial-home.png) — confirms the installed candidate opened in Expressive light mode. This is not a remediation target.

### Muscle Rankings

- [Light](muscle-rankings-light.png) and [dark](muscle-rankings-dark.png).
- Shows the single in-page title, shared Rank cue, editable rank boxes, and repeated ranking rows.

### Body Part / Muscle Mapping

- [Light, read-only](mapping-light.png)
- [Dark, read-only](mapping-dark.png)
- [Light, edit mode](mapping-light-edit.png)
- [Dark, edit mode](mapping-dark-edit.png)
- The edit captures show the linked-muscle selection form and Cancel/Save actions; no selection was changed or saved.

### Exercise Editor and caller-scoped picker

- Exercise Editor landing: [light](exercise-editor-light.png), [dark](exercise-editor-dark.png).
- Exercise Catalog picker opened from Exercise Editor: [light](exercise-editor-picker-light.png), [dark](exercise-editor-picker-dark.png).
- The captured picker uses the Analytics destination treatment for this caller. These images do not imply that Catalog's other callers are approved or changed.

## Limits

- Physical Pixel 7 default viewport only. No 320 dp, tablet/wide, landscape, or systematic 1×/1.15×/1.5×/2× screenshots were taken.
- The picker captures show its initial loaded list, not filter dialogs, search, selection-return, or media-failure states.
- The ranking captures show resting rows; keyboard editing, drag feedback, and save confirmation were not captured.
- Mapping edit mode was captured, but no values were toggled or saved.
- These are the only post-remediation screens in this evidence set. Other routes remain governed by the existing review queue and approval inventory.

