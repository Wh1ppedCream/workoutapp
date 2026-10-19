# Exercise Details Pixel 7 evidence

Captured 2026-10-06, 03:06–03:18 America/Toronto (07:06–07:18 UTC), from the current working tree.

## Build and source

- Source HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea` (`feature/classic-m3e`).
- The working tree was already dirty before this evidence pass; production source was not edited here.
- Preview built with `tools\run_expressive_preview.ps1 -BuildMode debug` using Flutter 3.47.5 / Dart 3.13.4. The runner confirmed the APK manifest package `com.tonos.expressivepreview` and the database define `tonos_expressive_preview.db`; only this preview package was updated/launched. The installed `com.tonos` package was not touched.
- Focused validation reported by the lead before capture: responsive + scope + detail-contract 14/14; Classic 7/7; Neo 7/7; scoped analyze, format, and diff checks passed.

## Device and route

- Pixel 7, device ID `28021FDH200228`; `adb shell wm size` reported `1080x2400`, density `420`.
- Route: preview Train overview → Catalog tab → Exercise Catalog → Ab Wheel media thumbnail → Exercise Details sheet.
- Fixture choice: seeded `Ab Wheel` (Ab Roller). It has form guidance, equipment, target anatomy, metrics, and populated history. Records showed dates including Oct 5, 2026, with multiple sets; metrics showed 84 lbs top estimated 1RM and 1.9k lbs volume best.
- Preview controls selected the Expressive recipe with curated palette; light/dark and 2× scale were set through the preview UI. The 2× samples below are dark-mode samples.

## Requested captures

| File | Mode / state |
| --- | --- |
| `03-ab-wheel-detail.png` | Light, Details top/media and title/tabs |
| `light-form-guide.png` | Light, lower Details with expanded Form guide |
| `light-equipment-anatomy.png` | Light, expanded Equipment and Target Anatomy |
| `light-metrics.png` | Light, Metrics |
| `light-records-chart.png` | Light, Records chart and start of populated history |
| `light-records-chart-final.png` | Light, Performance trend chart and compact Monthly / All Time history rail, 04:05:47 |
| `light-records-history.png` | Light, populated Records history scrolled to three session cards |
| `dark-details-top-media.png` | Dark, Details top/media and title/tabs |
| `dark-form-guide.png` | Dark, lower Details with expanded Form guide |
| `dark-equipment-anatomy.png` | Dark, expanded Equipment and Target Anatomy |
| `dark-metrics.png` | Dark, Metrics |
| `dark-records-chart.png` | Dark, Records chart |
| `dark-records-chart-final.png` | Dark, Performance trend chart and compact Monthly / All Time history rail, 04:07:44 |
| `dark-records-history.png` | Dark, populated Records history, scrolled to multiple sessions |
| `dark-2x-details.png` | Dark 2×, Details title/tabs/media and anatomy inset |
| `dark-2x-metrics.png` | Dark 2×, Metrics |
| `dark-2x-records.png` | Dark 2×, Records |
| `dark-2x-details-final.png` | Final rebuild capture: dark 2× Details with the vertically stacked tab labels and media |

## Navigation notes and incidental captures

The media thumbnail on the Exercise Catalog row opens the detail sheet. The sheet keeps its tab bar pinned while its content scrolls. Form Guide is expanded by default; Equipment and Target Anatomy were expanded for their captures. The preview seeded usable records without extra manual data entry.

All incidental screenshots from route discovery and control setup were retained as requested. `00-preview-start.png`, `01-catalog.png`, `02-ab-wheel-detail.png`, `tmp-back.png`, `tmp-controls.png`, `tmp-dark-catalog.png`, `tmp-controls-scrolled.png`, `tmp-scale-options.png`, `tmp-2x-catalog.png`, `tmp-2x-list.png`, `tmp-current.png`, `tmp-after-close.png`, `tmp-after-back.png`, `tmp-control-dialog.png`, `tmp-light-overview.png`, `tmp-light-sheet.png`, `tmp-light-chart-top.png`, `tmp-light-records-chart.png`, `tmp-light-chart-legend.png`, `tmp-close-chart.png`, `tmp-light-controls.png`, `tmp-dark-chart-top.png`, and `tmp-dark-chart-legend.png` are navigation/control context, not review evidence. No route/state was unreachable.

## Final updated-source capture

At 2026-10-06 03:29 America/Toronto (07:29 UTC), rebuilt from HEAD `ab18ed8cab5582c8449e13724afae3c4b74ebeea` with `tools\run_expressive_preview.ps1 -BuildMode debug`. The APK manifest again verified `com.tonos.expressivepreview`, and the runner again confirmed the isolated database define `tonos_expressive_preview.db`. Updated/restarted only that package on Pixel 7 `28021FDH200228`; `com.tonos` was not touched. Reinstallation returned preview controls to OS/default brightness and text scale, so dark and 2× were selected again in the preview controls before capturing `dark-2x-details-final.png`. The final image visibly shows the tab labels stacked vertically above the exercise media.

At 2026-10-06 03:34 America/Toronto (07:34 UTC), replaced `light-records-history.png` with a genuine light-mode capture from the same updated preview on Pixel 7 `28021FDH200228`. The view shows three populated Ab Wheel session cards dated Oct 5, 2026 at 6:00 PM, Oct 5 at 2:06 AM, and Oct 4 at 12:58 AM. The capture uses only the preview package/database; the normal Tonos package was not touched.

At 2026-10-06 03:51 America/Toronto (07:51 UTC), rebuilt and reinstalled the latest working-tree source after the compact tab-rail threshold fix. The debug runner verified package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`; only the preview package was updated on Pixel 7 `28021FDH200228`. Captured `dark-records-history-final.png` at 03:57:02 and recaptured `light-records-history-final.png` at 04:01:32 America/Toronto, both from this post-fix install and the Ab Wheel Records tab. Both images show the compact Monthly/All Time badge legend rail above three populated session cards. No normal Tonos package or database was accessed.

From the same latest installed preview, captured `light-records-chart-final.png` at 04:05:47 and `dark-records-chart-final.png` at 04:07:44 America/Toronto on 2026-10-06. Both show the Performance trend heading, the full populated chart, and the compact Monthly / All Time rail below the All sessions divider. The route was Train → Catalog → Exercise Catalog → Ab Wheel media → Records; chart and rail were framed together with a short content scroll.
