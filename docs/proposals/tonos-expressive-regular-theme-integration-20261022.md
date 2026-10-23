# Tonos Expressive — Regular Theme Integration

Date: 2026-10-22. Requested by the owner after approval of all 49 tracked implemented page archetypes.

## Product behavior

- **Profile → UI & Appearance → Theme family → Expressive** selects the approved theme through the regular `ThemeProvider` and `AppThemePreferences` flow.
- The stable preference code is `expressive`. It is available in ordinary debug, profile and release configurations, independently of the existing Neo eligibility policy. Classic remains the normal new-install default.
- The factory returns the same cached curated Expressive light/dark definitions used for visual approval. Theme choice, dark mode and language are handled by regular settings and persist normally.
- Expressive has a localized name/description and a distinct preview swatch in the existing theme picker. No approved page was redesigned for this integration.
- The historical internal `expressivePreview` identity is deliberately retained so every approved shared/caller-specific presentation continues to match without a broad source rename.

## Existing installation and data

- The existing device installation is updated in place, retaining its package identity and isolated database. Its launcher name is now **Tonos**.
- `expressive_review_main.dart` starts the regular app UI with no `TonosPreviewPresentation`, temporary top strip, palette override, review-only accessibility/locale override, or fixture preparation.
- A one-time migration selects Expressive for that existing installation because the former review theme was never stored as its theme family. Subsequent selections, including Classic or Neo, are honored; the saved dark/light mode and other preferences are retained.
- The old `expressive_preview_main.dart` entrypoint delegates to the same non-seeding startup. The existing runner targets it safely through `expressive_review_main.dart` with review controls disabled.
- Historical preview fixtures/controllers remain available as development evidence/utilities, but neither shipped entrypoint launches them. No uninstall, database reset, reseed, preference wipe, staging, commit or push accompanies this integration.

## Changed areas

- Theme registry, capabilities and cached factory.
- UI & Appearance labels/swatch; debug control and Theme Lab family labels.
- Seven localization resources and generated localization output.
- Existing isolated startup entrypoints, Android launcher label and runner target.
- Existing architecture/capability/selector assertions updated for the newly registered family; no new automated test cases or test-suite run in this task.
- Current approval documentation receives an integration note; approval classifications and historical gallery captures remain unchanged.

## Checks

- Localization generation completed.
- Modified Dart code formatted, with unrelated legacy formatting preserved.
- `dart analyze --format machine lib`: **0 errors, 0 warnings, 51 existing informational notices**, exit 0.
- `git diff --check` and runner PowerShell syntax parsing passed.
- Pixel 7 debug APK rebuilt successfully and installed **in place** with `adb install -r`. Manifest identity was checked before installation; the launcher label is **Tonos**. Only the existing Tonos package is installed.
- The initial online build waited on Android test-runner version metadata. The successful local build used Gradle offline mode and an ignored, build-only init script resolving the SDK integration-test plugin's `1.2+` runner to its already-cached matching `1.2.0` version. No tracked dependency configuration or SDK source was changed; no automated tests were run.
- Manually opened Profile → UI & Appearance → Theme family; selected Classic, cold-launched the app and confirmed Classic stayed selected, then selected Expressive again through the same picker. This confirms the one-time adoption does not override later user choices.
- Restored the pre-existing onboarding replay setting after navigating through setup. Dark/light preference and language selection were retained. The device is left on the **Theme family dialog with Expressive selected**, in dark mode, without the temporary preview controls or reserved top strip. Current-process Flutter/Android error logs were empty during this check.
- Before/after read-only database snapshots cover **85 tables**. Workout, preset, gym/equipment, diary, goals and active-draft records retained their contents. Changes were confined to normal day-total cache creation, media/content access/check timestamps and the selected-profile metadata timestamp; the selected profile ID remained the same. No original records were removed or reseeded. Snapshots/comparison and local checks are under `.build/codex_expressive_regular_appearance_20261022/`.

## Completion boundary

All tracked implemented page archetypes remain **A49 / B0** for visual approval. This makes Expressive a normal theme option; it does not assert exhaustive responsive/accessibility, automated-test, technical, store or release qualification. The separate gaps documented in the full review and its repair follow-up remain visible.
