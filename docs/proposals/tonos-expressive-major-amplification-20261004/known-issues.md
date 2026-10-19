# Known issues and evidence gaps

This list is intentionally provisional. It separates source-audit risks from verified failures. Source is frozen and focused validation has run; fresh Pixel 7 evidence for this dated pass is still pending.

## Open review gates

- **Fresh build/device review is pending.** Build/install only the isolated preview identity, then record artifact hash, exact source state, device ID, package, database, date/time, route and UI state with each capture. The capture agent has not yet supplied exact paths/metadata.
- **Analytics route-header accessibility fix is implemented and covered by the current integration validation.** The fixed horizontal title/subtitle truncation was replaced with a narrow/large-text adaptive treatment. Visual confirmation at 320 dp and 1.5×/2× in both brightness modes remains pending.
- **Full History composition update is implemented and included in the frozen-source integration validation.** Date grouping now uses the structural plum-band treatment requested after the marker-only proposal was judged too conservative. Current-device visual review remains pending.
- **Analytics contrast and every route state need visual confirmation.** Source token pairings were inspected, but dark/light contrast, focus, reorder, disabled and validation states require current screenshots and representative interactions.
- **Current route inventory is static.** The 52 release / 55 configurable/debug-route totals are based on route class tracing and policy checks. They do not prove every callback is reachable under every persisted navigation configuration.
- **Existing screenshots are stale for this source checkpoint.** Older proposal folders contain useful historical evidence but do not establish the appearance of current dirty source. They are excluded from the dated evidence table.
- **Formatting follow-up remains.** Check-only Dart formatting identified five task-owned Dart files still needing formatting. No files were auto-formatted in that check.
- **Ratchet enforcement remains pending.** The inventory check passes; enforcement needs an explicit disposition for intentional `exercise_definition_info_tile.dart` fingerprints.
- **No full repository suite was run.** This checkpoint intentionally used the focused integration batch only.

## Deferred or gated destinations

- Dashboard/Analytics Dashboard, Preset Generation QA, Auto Preset Flow/Flow Methods, and onboarding remain meaningful reachable Expressive gaps or partial routes; they are not being broadly redesigned in this pass because of frozen-route overlap and workflow scope.
- Train2 remains a legacy/configurable shell outside this pass.
- Nutrition is default-off and paused; its feature routes remain out of scope. The Profile Nutrition tile remains a disabled placeholder.
- Form and Posing is an experimental placeholder. No destination content should be invented.
- Theme Lab and interaction galleries are debug-only. Unreferenced classes are excluded from route reachability.

## Evidence ledger

| Evidence item | Required state | Status / path |
| --- | --- | --- |
| Focused integration batch | 95 files; exact aggregate result | **529 passed, 0 failed, 0 skipped** |
| Analyzer | Scoped/current integration source | **0 errors, 0 warnings, 54 infos; exit 1 info-only** |
| Formatting | Check-only result | **Five task-owned Dart files pending formatting** |
| `git diff --check` | Frozen source | **Pass** |
| Theme inventory | Frozen source | **Pass** |
| Ratchet enforcement | Intentional fingerprints | **Pending: `exercise_definition_info_tile.dart`** |
| Build metadata | Working-tree commit/hash, SDK, preview flags, APK SHA-256 | Pending |
| Pixel device verification | `28021FDH200228`, runtime model/API, package/database | Pending; exact capture metadata awaited |
| Planning captures | Each route; light/dark; key scroll/selection/dialog; narrow cases | Pending — `captures/planning/` |
| Catalog captures | Browser, Focus Library, both details, sheet; both modes and key states | Pending — `captures/catalog/` |
| Progress captures | Root/report/exercise/health/detail; both modes; date-label narrow check | Pending — `captures/progress/` |
| Logbook captures | Month/3M/Year/4Y, Full History, Session Detail; both modes; 320dp/2x | Pending — `captures/logbook/` |
| Profile/settings captures | Root, changed child routes, dialogs, lower scroll; both modes | Pending — `captures/profile/` |
| Analytics Settings captures | Seven routes; both modes; selected/edit states; 320dp/1.5x and 2x | Pending — `captures/analytics/` |
| Responsive proof | Train/WeightCard narrow gates; planning/analytics width and large text; Logbook 4Y | Pending — `responsive/` |
| Motion proof | Only if motion audit adds/changes interaction; include Reduced Motion comparison | Pending — `motion/` |

No item in this table should be relabeled complete from an earlier dated capture. The review folder should contain evidence only after the current source is validated and freshly installed on the isolated preview package/database.
