# Tonos Expressive Logbook final review — 2026-10-03 to 2026-10-04

Pixel 7 evidence captured from the isolated preview app (`com.tonos.expressivepreview`) using its `tonos_expressive_preview.db` database. No normal Tonos package or database was used. Device: `28021FDH200228`.

## Full History

- `15-full-history-light-current.png` — current Expressive light list, normal device width.
- `18-full-history-dark-current.png` — matching dark list.
- `39-full-history-320dp-2x.png` — 320dp width at 2× text; dates and durations remain readable and rows scroll normally.

Same-day sessions keep their individual date and duration. The three Oct 2 rows read as a grouped run with restrained shape variation, while the Oct 1 boundary restores the larger gap. Row tap/navigation remains immediate with Reduced Motion enabled.

## Session Detail

- `27-session-detail-light-top.png` and `19-session-detail-dark-top-summary-current.png` — top/summary continuity.
- `29-session-detail-light-lower-end.png` and `21-session-detail-dark-lower-end-current.png` — historical exercise cards, media, set rows, records, estimated 1RM, and fixed actions.
- `20-session-detail-dark-below-fold-current.png` and `28-session-detail-light-below-fold.png` — intermediate lower content.
- `30-exercise-info-sheet.png` — exercise information sheet opened from the historical thumbnail/card.
- `31-session-edit-entry.png` — edit mode entry, exited without changes.
- `43-session-edit-value-changed.png` — temporary unsaved edit used to verify the back guard.
- `44-session-dirty-back-confirm.png` — unsaved-changes confirmation; Discard was selected, and reopening the workout confirmed its stored values remained 20 lbs.
- `32-session-delete-confirm.png` — delete confirmation, canceled.
- `33-session-save-plan-dialog.png` — Save as Plan dialog, canceled.
- `34-session-repeat-confirm.png` — result of activating “Do workout again”; this starts a new draft workout. The draft was discarded in the isolated preview using the app’s Cancel Workout flow; it was not saved to history.
- `35-preview-session-discard-confirm.png` — discard confirmation for that temporary draft.
- `40-session-detail-320dp-2x-reduced-motion.png` — detail route reached with Reduced Motion on at 320dp/2×; hierarchy is static, but the title and metric labels wrap/truncate awkwardly at this extreme size.

The fixture contains 15 2026 sessions for the 4Y stress case, including 9 generated preview-only history rows. The temporary repeat draft was canceled and does not belong to the 15-session history fixture.

The preview fixture contained only weight exercises. Cardio/stretch detail rows were not reachable in this sample; the current Session Detail source also retains a TODO to restore completed cardio/stretch detail cards, so no cardio/stretch visual was fabricated.

## 4Y stress state

- `41-logbook-4y-dark-stress-top-restored.png` — dark selector geometry, selected 2026 tile, and first stress rows.
- `25-logbook-4y-dark-stress-bottom.png` — dark list end and summary, with bottom navigation clear.
- `42-logbook-4y-light-stress-top.png` and `26-logbook-4y-light-stress.png` — light selector/list and lower summary views.
- `38-logbook-320dp-2x-4y.png` — compact large-text boundary case.

At normal Pixel 7 width, the 15-row region scrolls cleanly to the year summary and the selected period stays obvious. At 320dp/2×, the four year tiles visibly truncate to “20…”, so the unselected years are not visually distinguishable; this is recorded for the final review rather than changed in this narrow Full History pass. At that text scale, the navigation strip scrolls horizontally to reach all five destinations.

## Reduced Motion and restoration

- `36-logbook-reduced-motion-period-switch.png` — period changed to Year with Reduced Motion enabled; the selected period was settled on the first captured frame.
- `40-session-detail-320dp-2x-reduced-motion.png` — Session Detail reached immediately with Reduced Motion on.

After capture, Pixel display size was reset, preview text scaling restored to OS/app default, Reduced Motion turned off, and the app left on the Logbook 4Y view. No sandbox fixture reset was run.

## Validation

- Focused Flutter tests: 19 passed across Full History, Session Detail, and workout-history calendar widgets.
- Scoped Dart analysis: no issues found.
- `git diff --check`: passed (Git printed existing line-ending warnings for unrelated dirty files).
- Full repository suite intentionally deferred for this review pass.
