# Device, Visual, and Accessibility QA

This is the release-facing complement to automated widget and integration
tests. It is intentionally compact: it protects representative layouts and
critical workflows without requiring every screen to maintain a device-specific
image baseline.

## Automated Matrix

`test/widgets/visual_layout_contract_test.dart` covers the stable Settings
scaffold at these representative configurations:

| Class | Viewport | Locale | Text scale |
| --- | --- | --- | --- |
| Small phone | 320 x 640 | English | 100% |
| Small phone, long Latin copy | 320 x 640 | Spanish | 130% |
| Modern phone, complex script | 430 x 932 | Bangla | 130% |
| Tablet | 800 x 1280 | Hindi | 130% |

The existing responsive and localization tests cover onboarding, tutorials,
settings, and other high-risk component layouts. The Android emulator workflow
runs the real UI core flow weekly; its database is isolated from personal app
data.

These are layout contracts rather than pixel goldens. They intentionally assert
that essential controls render, remain discoverable, and throw no layout
exceptions across stable breakpoints. Introduce pixel baselines only after a
screen has a stable visual design and a reviewed reference capture, otherwise
normal design work becomes noisy CI churn.

## Release Device Pass

Before a release with user-interface, localization, media, import/export, or
navigation changes, run the following on a physical Android device:

1. Test normal font/display size in light and dark themes.
2. Repeat the high-risk path with Android font size and display size increased.
3. Enable TalkBack and confirm that icon-only actions have an accurate name,
   stateful controls announce their state, and focus order follows the screen.
4. Verify a phone portrait flow: onboarding, Train, plan editing, active
   workout, completion, Logbook detail, Measurements, Profile, and Diagnostics.
5. Verify one larger layout (tablet or landscape emulator): Train, catalog,
   Logbook, Measurements, and settings.
6. For media changes, test clean install, first thumbnail sync, airplane mode,
   missing-file recovery, cache clearing, and recovery after reconnecting.
7. For backup/import changes, export, cancel an import, reject a bad file, and
   complete a valid import while confirming the safety backup result.
8. For locale and navigation changes, switch to a non-English locale, relaunch
   the app, and confirm the selected locale plus enabled-tab order persist.

### TalkBack Record

For the manual TalkBack pass, record the following in the release notes or QA
ticket rather than relying on a verbal approval:

| Screen | Required check |
| --- | --- |
| Onboarding welcome | Language selector, Skip, and Next have distinct names and a logical focus order. |
| Train overview and plan | Plan controls, Start workout, Optimize, and overflow actions announce their purpose. |
| Active workout | Each set announces completion state; weight/repetitions fields and add/remove-set actions remain reachable. |
| Measurements | Trend tile, log-entry action, edit/delete entry, and custom-metric action have an accurate name. |
| Import/export | Plaintext-export warning, import confirmation, cancellation, and result close button are all announced. |
| Profile and navigation | Theme switch states, language choices, and tab visibility switches announce their current state. |

Record device model, Android version, locale, font/display setting, theme, and
whether every required check passed. File a defect for duplicate focus targets,
missing state announcements, or a focus jump that skips an actionable control.

Record device model, Android version, display/font setting, locale, affected
screen, reproduction steps, and a screenshot for every defect.

## Screenshot Baselines

When a stable screen merits pixel comparison, use this process:

1. Capture an approved reference from the same emulator API level, viewport,
   locale, theme, font scale, and deterministic fixture data.
2. Store the source test, fixture, and baseline together under a dedicated
   `test/goldens/` directory.
3. Require design review before replacing a baseline; do not update baselines
   merely to make a failing comparison pass.
4. Keep the set small and high-signal: onboarding welcome, Train overview,
   active workout, workout completion, Measurements, catalog, Logbook, and
   Profile settings are sufficient initial candidates.
5. Do not add the golden test or checked-in PNG until product/design has marked
   the screen stable. The review must name the fixture data, emulator image,
   viewport, locale, theme, and text scale used for the baseline.

## Commands

Run the automated layout and semantics contracts:

```powershell
flutter test test\widgets\visual_layout_contract_test.dart `
  test\widgets\responsive_accessibility_test.dart
```

Run the physical-device UI suite against its isolated database:

```powershell
flutter test integration_test\core_flows_test.dart `
  -d <android-device-id> `
  --dart-define=TONOS_INTEGRATION_TEST=true `
  --dart-define=TONOS_DATABASE_NAME=tonos_integration_test.db
```
