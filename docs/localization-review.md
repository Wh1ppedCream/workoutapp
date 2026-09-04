# Localization Linguistic Review

Automated checks and visual QA confirm that localized resources compile, render,
and fit the supported layouts. They do not replace a native-speaker review of
meaning, tone, terminology, or regional usage.

## Current status

Visual QA is complete for Bangla, Simplified Chinese, Hindi, and Spanish.
Native-speaker sign-off is pending for every supported non-English locale.
Record the reviewer, date, build version, and disposition below before calling a
locale release-ready.

## Latest automated evidence

On 2026-09-03, all seven ARB resources contained the 1,933 canonical message
keys with aligned runtime placeholders. Generated localization output was
regenerated, the targeted analyzer passed, and the focused localization and
workflow tests passed (`00:09 +31: All tests passed!`). The pass also corrected
Canadian-French placeholder wording in logbook, anatomy, and ranking messages.
This evidence confirms structural and runtime contracts only; it does not
replace the pending native-speaker review recorded below.

| Locale | Reviewer | Build/version | Date | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| French (`fr`) |  |  |  | Pending |  |
| French (Canada) (`fr_CA`) |  |  |  | Pending |  |
| Bangla (`bn`) |  |  |  | Pending |  |
| Simplified Chinese (`zh`) |  |  |  | Pending |  |
| Hindi (`hi`) |  |  |  | Pending |  |
| Spanish (`es`) |  |  |  | Pending |  |

## Review scope

Review onboarding, navigation, plans, workout setup and session completion,
history, records, catalog, measurements, reports, settings, import/export,
diagnostics, empty states, dialogs, validation errors, accessibility labels, and
large text. Check plural forms, interpolated values, units, dates, and domain
terms such as sets, reps, volume, plan, and workout.

## Acceptance criteria

- The translation preserves the feature's intended meaning and action.
- Tone is consistent and appropriate for a fitness application.
- Regional phrasing is correct for the locale, including `fr` versus `fr_CA`.
- No app-authored English fallback is visible except for an approved proper
  name or a deliberately deferred source-owned catalog entry.
- Labels are concise enough for the reviewed layouts and usable at increased
  text scale.
- Every finding is either fixed and rechecked or explicitly accepted with a
  rationale in the review notes.

## Reporting a finding

Include the locale, screen, exact source string, preferred wording, screenshot
if layout is affected, and whether the issue blocks release. Apply wording
changes to every affected ARB file, regenerate localization output, and rerun
the localization smoke and literal-copy contract tests.
