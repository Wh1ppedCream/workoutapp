# Remaining Localization Inventory

This is the master checklist for user-visible localization work that remains in
Tonos. It is a source audit, implementation plan, and release gate. Update the
checkboxes as each boundary is completed rather than maintaining a separate
informal list.

Audit snapshot: `updates/backlog` at `3283966` with localization changes
uncommitted, reviewed on 2026-09-03.

Current implementation pass: 2026-09-03. Stable Measurements/Health Trends
copy, allocation-source labels, QuickBar labels, weight-unit names, current
measurement cards, and active history/report date and number presentation now
use ARB-backed or shared locale formatting boundaries. ARB message keys,
locale tags, and runtime placeholders are now contract-checked, and active
navigation, shared formatters, and record-badge locale switching have smoke
coverage. The reviewed-identical-English policy is recorded in
`docs/localization-reviewed-english.json`; generated localization output was
regenerated and verified locally on 2026-09-03. The focused verification
passed analyzer and 31 localization/workflow tests, with `git diff --check`
clean apart from expected line-ending warnings.

Supported locales:

- English (`en`)
- Spanish (`es`)
- French (`fr`)
- Canadian French (`fr_CA`), with reviewed regional overrides and `fr` fallback
- Bangla (`bn`)
- Simplified Chinese (`zh`)
- Hindi (`hi`)

## How To Use This File

- `[x]` means the source is localized and protected by an automated contract.
- `[ ]` means user-visible English can still be reached, or the boundary has
  not been proved complete.
- A section is complete only when its implementation, automated checks, device
  review, and native-speaker review are all complete.
- New app-authored text must be added here if it cannot immediately be moved to
  ARB resources or another stable-code localization bundle.
- File and line details may move. The paths and named symbols are the durable
  audit references.

## Content That Must Not Be Translated

The following content should remain exactly as entered or supplied:

- User-created exercise, measurement, plan, gym, profile, recipe, meal, and food
  names.
- Food brands, product names, barcodes, URLs, filenames, and external proper
  names unless the source provides an official localized form.
- Storage keys, catalog IDs, database identifiers, media slugs, wire values,
  analytics codes, and diagnostic-only tokens that are never rendered as UI.
- Scientific unit symbols where the symbol is universal, such as `kg`, `cm`,
  `g`, and `kcal`. Surrounding labels and formatted phrases still require
  localization.
- Imported historical free text and user notes.

Built-in app content must use stable IDs or typed enums for lookup. Visible
English names must never be used as localization identities.

## Completed Baseline

- [x] Every ARB locale contains all 1,933 English resource keys, preserves the
  supported locale tag, and retains every runtime placeholder.
- [x] Active screen and shared-widget literals have a source contract covering
  common text, dialog, empty-state, tooltip, conditional, and semantics forms.
- [x] Safe failure categories resolve to localized user messages rather than
  exposing raw exceptions in supported active flows.
- [x] All 300 built-in exercises have localized display names and setup,
  execution, and tip guidance in `es`, `fr`, `bn`, `zh`, and `hi`.
- [x] `fr_CA` inherits complete French exercise content unless a reviewed
  regional override is supplied.
- [x] Stable-code display localization covers 40 equipment entries, 56 muscle
  entries, 21 direct built-in plan IDs, and four derived one-hour plan rows in
  Spanish, French, Bangla, Simplified Chinese, and Hindi; `fr_CA` falls back to
  French.
- [x] Built-in exercise localization uses `catalogId`; canonical database names,
  media links, history, and user-created exercises remain stable.
- [x] The 13 built-in body-part labels have a stable localized presentation
  helper, while custom body-part names remain unchanged.
- [x] Visual QA has been recorded for Bangla, Simplified Chinese, Hindi, and
  Spanish at the app-shell level.

These checks prove structural coverage, not translation quality. Every
non-English locale still needs the native-speaker sign-off near the end of this
file.

## Rework-Aware Prioritization

Not every localization task has the same rework risk. Complete durable
infrastructure first, and wait to finalize feature copy until the related
product and data models stop changing.

### Durable Work To Do Now

- [x] Keep ARB parity, stable catalog IDs, and shared catalog resolvers as the
  localization identity boundary. These survive display-name edits and UI
  redesigns.
- [x] Provide shared locale-aware date, time, number, percentage, and compact
  number formatters. They preserve canonical storage values and the product's
  Western-digit Bangla policy.
- [x] Route dashboard and database-health timestamps through the shared
  formatter boundary without changing stored timestamps.
- [x] Route native database file-picker titles through existing ARB resources
  and make the hardcoded-copy contract detect literal `dialogTitle` arguments.
- [x] Route active history, calendar, reports, exercise-progress charts,
  onboarding rates and counts, anatomy set summaries, active plan counts and
  previews, automatic set labels, editor allocation previews, and database-cache
  sizes through shared locale-aware presentation helpers without changing stored
  values.
- [x] Add and maintain a machine-readable policy for reviewed identical English
  values; the localization contract rejects copied values outside that policy.
- [x] Finish numeric formatting in remaining active chart and analytics paths,
  excluding canonical input fields whose decimal syntax must remain parseable.
- [x] Localize active calendar weekday headers and dashboard date cells through
  shared locale formatting, including localized spoken date labels.
- [x] Localize preset duration summaries and newly generated optimized-workout
  date/time names through existing ARB/shared formatting; existing persisted
  names are not rewritten.
- [x] Verify shared date, weekday, number, and percentage formatters execute for
  every supported locale.
- [x] Verify active Train, Catalog, Logbook, Progress, and Profile labels stay
  translated when resolving each supported non-English locale.

### Work To Defer Until Product Copy Settles

- [ ] Finalize exercise names and guidance only after the exercise catalog audit
  and current `exercises.json` editing are complete.
- [ ] Finalize Train2 and navigation copy after the Train2 retirement and
  release-navigation decisions.
- [ ] Finalize Exercise Editor copy after its redesign.
- [ ] Finalize generated-plan, progression, plan-copy, measurement, analytics,
  persisted-snapshot, backup, and dynamic-error wording after their related
  models and workflows are complete.
- [ ] Localize Stretch, Nutrition, Cardio, Combined History, and Form and Posing
  only after each feature is either implemented for release or explicitly
  excluded and proven unreachable.

### Final Review Order

- [ ] After active product surfaces stabilize, complete translation review,
  native-speaker review, accessibility review, locale-switch testing, and
  signed-device release checks. These reviews must be repeated after later
  user-visible copy or layout changes.

## 1. Active Release Surfaces

These items can affect screens that are already available in a release build
and should be completed before deferred product areas.

### 1.1 Native File And Platform Prompts

Source: `lib/screens/profile/settings/database_settings_page.dart`

- [x] Localize the file-picker title through the existing import-backup ARB
  resource.
- [x] Localize the save-panel title through the existing export-backup ARB
  resource.
- [x] Localize the pre-import backup save-panel title through the existing
  export-backup ARB resource.
- [ ] Audit every future `FilePicker`, share, open-file, scanner, permission,
  notification, and platform-channel argument for app-authored visible text.
- [x] Pass localized strings into platform APIs; do not localize inside storage
  or repository layers.
- [x] Add a contract that detects literal named arguments such as
  `dialogTitle`, not only Flutter widget constructors.

Done when native chooser and permission surfaces show the selected language on
real Android devices, with a documented note for OS-owned text Tonos cannot
control.

### 1.2 Measurements And Units

Primary source: `lib/widgets/health_trends_section.dart`

- [x] Localize the 11 built-in measurement titles: Weight, Height, Forearm, Arm,
  Neck, Shoulders, Chest, Waist, Hips, Thigh, and Calves.
- [x] Preserve custom measurement names verbatim.
- [x] Localize trend empty states, including `Log entries to build a trend.` and
  `Log one more entry to draw a trend.`.
- [x] Localize delta prose, including `No change yet` and `since last`.
- [x] Localize measurement-context presentation for wake-up, bedtime, overall,
  with-pump, and without-pump values while keeping stored enum/code values
  stable.
- [x] Format measurement dates and times with the selected locale rather than a
  manually assembled English month or AM/PM form.
- [x] Localize spoken semantics for values, deltas, chart points, add/edit/delete
  actions, and empty charts.
- [x] Keep unit storage canonical while presenting locale-appropriate unit
  names, spacing, decimal separators, and height notation.

Related source: `lib/models/unit_preference.dart` and
`lib/screens/profile/settings/ui_appearance_settings_page.dart`

- [x] Replace the current Spanish-only Pounds/Kilograms special case with one
  localized resolver for every locale.
- [x] Keep `pounds` and `kilograms` as storage values and `lbs`/`kg` as unit
  symbols; localize their visible long names everywhere.

Done when Measurements, measurement dialogs, charts, and UI Appearance expose
no app-authored English in all supported locales and custom names remain intact.

### 1.3 Exercise Analytics Labels

Sources: `lib/models/exercise_allocation_models.dart` and
`lib/screens/profile/settings/exercise_analytics_screen.dart`

- [x] Localize `Automatic calculation`.
- [x] Localize `Tonos default`.
- [x] Localize `Your custom allocation`.
- [x] Localize `Existing allocation`.
- [x] Remove display labels from the domain enum and resolve its typed values in
  the UI through ARB resources.
- [ ] Audit muscle and body-part allocation summaries, tooltips, and semantics
  for dynamically assembled English.

Done when the analytics and allocation editor screens render only localized
labels while database/source values remain unchanged.

### 1.4 Quick Actions

Source: `lib/widgets/quick_bar.dart`

- [x] Localize `+ Measurement`.
- [x] Localize `+ Food`.
- [x] Localize `+ Workout`.
- [x] Add localized semantic button labels that do not depend on the visual
  plus-sign wording.

This widget currently links to deferred nutrition features. If it is not
reachable in release, prove that in a navigation contract; otherwise localize
it before release.

### 1.5 Navigation Configuration And Drawers

Sources: `lib/providers/nav_bar_config.dart`, `lib/widgets/drawers.dart`, and the
navigation settings surfaces.

- [ ] Replace enum/config display titles for Train, Train2, Catalog, Logbook,
  Progress, Profile, Dashboard, Nutrition, Nutrition Log, Combined History, and
  Form and Posing with stable navigation IDs plus an ARB resolver.
- [ ] Ensure bottom-bar labels, drawer labels, reorder/hide settings, migration
  warnings, and accessibility labels use the same resolver.
- [ ] Verify experimental entries remain unavailable in release even if their
  localized labels exist.
- [x] Preserve stored navigation IDs and migrations; never persist translated
  labels. Current configuration writes stable tab IDs and accepts legacy enum
  strings while stored preferences migrate naturally on the next update.
- [x] Active bottom-bar labels and navigation settings labels use the shared ARB
  resolver; the legacy English title getter is not rendered.

Done when changing locale updates every navigation-management surface without
changing the saved tab configuration.

### 1.6 Persisted Exercise And Plan Snapshots

Sources include `lib/providers/durable_active_session.dart`, workout/session
models, preset models, history screens, and plan editors.

- [ ] Inventory every saved exercise reference that stores only a display name.
- [ ] Carry a built-in exercise `catalogId` through active-workout drafts,
  presets, generated plans, completed sessions, and history snapshots wherever
  identity is available.
- [ ] Resolve built-in names at render time in session cards, completion sheets,
  history, reports, progression, plan editors, and swap flows.
- [ ] Preserve historical and user-created names when no built-in identity is
  available.
- [ ] Test that locale switching changes built-in display names without altering
  saved data, media identity, exercise matching, or workout history.
- [ ] Test old snapshots that contain only canonical names and define their safe
  fallback behavior.

Done when a built-in exercise cannot reappear in English merely because it was
copied into a workout or plan before the locale changed.

### 1.7 Dynamic Error And Result Text

Sources include services, repositories, database maintenance, content sync,
import/export, diagnostics settings, and any UI that consumes their results.

- [ ] Replace user-visible exception messages with typed error/result codes.
- [ ] Localize maintenance, import, export, content-environment, media-sync, and
  validation result prose at the presentation boundary.
- [ ] Confirm raw `FormatException`, `StateError`, HTTP, filesystem, database,
  and plugin text never reaches SnackBars, dialogs, empty states, or semantics.
- [ ] Keep diagnostic logs detailed in English/code form if they are not shown
  as user guidance.
- [ ] Extend contracts to dynamic result objects, interpolated fallbacks, and
  helper methods that return display prose.

Done when forced failures in each active workflow produce a localized safe
message and no internal exception text.

## 2. Built-In Catalog And Domain Content

### 2.1 Equipment

Source: `assets/equipment.json` (40 built-in entries)

Visible consumers include onboarding, exercise filters, the catalog, exercise
details/editor, gym profiles, plan generation, and analytics.

- [x] Maintain a stable equipment code for every built-in entry in the catalog
  registry and persist it on built-in lookup rows.
- [x] Translate all 40 display names for every supported locale.
- [x] Resolve equipment through the stable code in release-visible lookup
  consumers, including filters, onboarding, profiles, editor, catalog,
  anatomy, dashboard, swap, and premade-plan preview surfaces.
- [x] Preserve custom equipment names verbatim.
- [x] Keep matching, catalog seeding, plan compatibility, and media independent
 from translated names.
- [x] Add count, key-parity, fallback, custom-name, profile-hydration, and
  premade-plan identity tests.
- [ ] Add a stable equipment identity to persisted WeightExercise snapshots
  so historical workout-detail rows can localize built-in equipment without
  guessing from display text.

### 2.2 Muscles

Source: `assets/muscles.json` (56 built-in entries)

Visible consumers include anatomy, exercise detail, catalog filters, analytics,
mapping screens, volume settings, and the exercise editor.

- [x] Add or confirm a stable code for all 56 built-in muscles.
- [x] Translate all 56 display names for every supported locale.
- [x] Replace direct `muscle.name` rendering with one shared resolver in
  anatomy browsing, catalog filters, analytics, mapping, volume settings,
  ranking, percentages, and the exercise editor.
- [x] Preserve custom muscle names verbatim.
- [x] Preserve canonical muscle names for matching, storage, exports, and
  navigation while carrying catalog IDs through all detailed DAO query paths.
- [x] Test registry and locale parity, DAO identity hydration, fallback and
  locale switching, including translated-label search in anatomy browsing;
  device accessibility review remains part of the release QA pass.
- [ ] Complete native-speaker terminology review for all five locales.

### 2.3 Premade Plans

Source: `lib/data/premade_training_plans.dart`

The current catalog contains 17 authored two-hour plans, generated one-hour
counterparts, and four additional two-hour templates. It also contains four
group names, the source label `Homemade`, plan names, and descriptions.

- [x] Give each source, group, and plan a stable localization code.
- [x] Localize the four groups: Full Body, Push Pull Legs, Upper Lower, and Body
  Part (Bro) Split.
- [x] Localize the source label `Homemade`.
- [x] Localize every built-in plan name and authored description.
- [x] Replace the generated one-hour sentence with a parameterized ARB message
  using the localized plan name and locale-aware duration.
- [x] Resolve exercise names inside plan previews through exercise `catalogId`.
  The canonical plan row name remains the fallback and continues to drive
  matching, adaptation, copying, and persistence.
- [x] Resolve built-in equipment names inside plan previews through the shared
  equipment localizer. The canonical plan row value remains the fallback and
  continues to drive matching, adaptation, copying, and persistence.
- [ ] Decide whether a copied built-in plan keeps the localized name as a
  user-editable snapshot or keeps a built-in identity until the user renames it.
- [x] Test plan-bundle parity, resolver fallback, generated one-hour inheritance,
  and localized page grouping/card data.
- [ ] Add page-level tests for grouping, copying, duplicate-name handling, and
  locale switching.

### 2.4 Stretch Catalog

Source: `assets/stretches.json` (137 built-in entries)

- [ ] Add stable IDs for all stretch entries.
- [ ] Translate all 137 names and descriptions.
- [ ] Resolve referenced body parts through the existing body-part localizer.
- [ ] Preserve custom stretches and user notes verbatim.
- [ ] Localize search, add/remove, duration, side, empty, and validation text in
  `lib/widgets/stretch_search_dialog.dart` and `lib/widgets/stretch_card.dart`.
- [ ] Add key-parity, fallback, data-integrity, search, and layout tests.

This section can be completed when the Stretch product stream is restored; it
must be complete before that stream is enabled in release.

### 2.5 Nutrition Catalog And Nutrients

Sources include `assets/nutrients_extended.json` (147 nutrient definitions),
`assets/foods.json`, `assets/foods/foods.min.jsonl.gz`, and
`assets/db/app_nutrition_v22.db`.

- [ ] Assign stable codes to nutrient names, nutrient groups, portion types,
  meal categories, and app-owned food categories.
- [ ] Translate all app-owned nutrient and category labels.
- [ ] Define which aliases are search-only per locale and which names are shown.
- [ ] Preserve food/product names and brands from their source unless an
  official localized name is available.
- [ ] Localize generated macro strings, nutrient summaries, portion prose,
  recipe/meal summaries, and empty/error states.
- [ ] Define locale-aware food search across translated labels, source names,
  aliases, accents, and scripts.
- [ ] Add catalog-version, fallback, import, search, and migration tests.

## 3. Deferred And Experimental Product Surfaces

The active literal-copy test intentionally excludes these areas. A deferred
area may be removed instead of translated, but it must not be enabled in a
release until its entire checklist is complete.

### 3.1 Nutrition

Screen sources:

- `lib/screens/nutrition_log_page.dart`
- `lib/screens/nutrition/barcode_scanner_page.dart`
- `lib/screens/nutrition/default_trend_page.dart`
- `lib/screens/nutrition/food_customization_page.dart`
- `lib/screens/nutrition/food_logging_page.dart`
- `lib/screens/nutrition/log_entry_page.dart`
- `lib/screens/nutrition/measured_items_page.dart`
- `lib/screens/nutrition/nutrition_page.dart`
- `lib/screens/nutrition/pantry_log_page.dart`
- `lib/screens/nutrition/plan_meal_page.dart`

Widget sources:

- `lib/widgets/meal_plan_add_bar.dart`
- `lib/widgets/nutrition_bar_details.dart`
- `lib/widgets/nutrition_circle_details.dart`
- `lib/widgets/nutrition_dash.dart`
- `lib/widgets/nutrition_text_details.dart`
- `lib/widgets/quick_bar.dart`

- [ ] Localize placeholder pages: Nutrition Log, Pantry Log, and Plan Meal, or
  remove them if they will not be implemented.
- [ ] Remove or rebuild `default_trend_page.dart`; do not translate obsolete
  sample-data behavior.
- [ ] Localize dashboard/macros: Calories, Protein, Carbs, Fat, Remaining,
  Consumed, Target, units, totals, goals, and summaries.
- [ ] Localize food search, scan, custom food, favorite, recipe, portion,
  quantity, meal, plate, time, and logging controls.
- [ ] Localize tooltips and results such as favorite/unfavorite, customize,
  edit/add, log now, no barcode, custom food saved, and logged/failed messages.
- [ ] Localize barcode permission, camera, torch, unsupported-device, and
  scanner error states.
- [ ] Localize dynamic nutrient-tree and component labels from stable codes.
- [ ] Audit all dialogs, sheets, validation, empty states, semantics, and
  interpolated food/meal messages.
- [ ] Add the nutrition paths to the literal-copy contract only after the full
  surface passes.

### 3.2 Cardio

Primary source: `lib/widgets/cardio_card.dart` plus cardio DAO/model/session
consumers.

- [ ] Localize cardio type names, Remove Cardio, start/stop controls, time,
  distance, pace, intensity, calories, notes, and validation.
- [ ] Localize timer semantics and state announcements.
- [ ] Preserve user-created cardio names and notes.
- [ ] Add the cardio path to literal enforcement after the full vertical slice
  is complete.

### 3.3 Stretch

Primary sources: `lib/widgets/stretch_card.dart` and
`lib/widgets/stretch_search_dialog.dart`.

- [ ] Localize Stretch Search, Cancel, Add, Remove Stretch, Search, Custom, and
  every duration/side/action label.
- [ ] Complete the 137-entry stretch catalog work in section 2.4.
- [ ] Localize timer semantics, validation, empty states, and errors.
- [ ] Add the stretch paths to literal enforcement after completion.

### 3.4 Combined History

Source: `lib/screens/combined_history_page.dart`

- [ ] Decide whether to implement or remove the placeholder.
- [ ] If implemented, localize title, filters, activity types, grouping, dates,
  summaries, empty/error states, actions, and semantics.
- [ ] Remove its deferred literal-test exclusion before release enablement.

### 3.5 Form And Posing

Source: `lib/screens/form_posing_page.dart`

- [ ] Decide whether to implement or remove the placeholder.
- [ ] If implemented, localize title, pose/form categories, capture guidance,
  media/permission states, comparisons, actions, empty/error states, and
  semantics.
- [ ] Remove its deferred literal-test exclusion before release enablement.

### 3.6 Alternative Train Hub

Source: `lib/screens/exercise/train2_page.dart`

- [ ] Retire `Train2Page` as planned, or explicitly retain and fully audit it.
- [ ] If retained, verify every visible branch uses existing ARB resources and
  localize any remaining generated plan, filter, settings, history, rest,
  dialog, error, tooltip, and semantics text.
- [ ] Remove its deferred literal-test exclusion after the decision.

## 4. Existing ARB Translation Review

All locale files have complete key parity, but identical English values can be
either valid loanwords/symbols or untranslated copy. The current same-as-English
counts are:

- Bangla: 17 keys
- Spanish: 41 keys
- Canadian French: 72 keys
- French: 69 keys
- Hindi: 13 keys
- Simplified Chinese: 10 keys

- [ ] Review every same-as-English value and mark it translated or intentionally
  identical with a reason.
- [ ] Review app name, language names, unit abbreviations, proper names, common
  technical terms, and placeholders separately rather than bulk-replacing them.
- [ ] Verify every plural/select message has correct locale grammar.
- [ ] Verify interpolated word order does not assume English.
- [ ] Check capitalization, punctuation, quote style, spacing, and script-specific
  digits according to the product language policy.
- [x] Add a machine-readable policy for intentionally identical values so the
  localization contract detects newly copied English.

The exact keys should be regenerated from the ARB files during each review;
counts in this snapshot are tracking aids, not permanent allowlists. The current
policy is maintained in `docs/localization-reviewed-english.json` and enforced
by `test/localization/reviewed_english_values_contract_test.dart`; it separates
values explicitly approved after review from values still awaiting linguistic
review.

## 5. Locale-Aware Formatting

- [ ] Audit every user-visible date and time through the shared temporal
  presentation helpers.
- [x] Migrate active history, calendar, report, session, diagnostics, onboarding,
  and exercise-progress date/time output to the shared temporal helpers.
- [x] Migrate dashboard calendar weekday/date cells, preset duration summaries,
  and newly generated optimized-workout date/time text to locale-aware
  presentation without rewriting existing stored values.
- [ ] Audit relative dates, calendar headings, weekday/month labels, and AM/PM
  behavior in history, reports, measurements, sessions, and nutrition.
- [ ] Format decimal values, percentages, volume, weight, distance, calories,
  and nutrient quantities with locale-aware separators.
- [ ] Use plural/select ARB messages for exercise, set, rep, session, minute,
  hour, day, meal, item, and record counts.
- [ ] Audit compact labels and chart axes so abbreviations are reviewed per
  locale rather than assembled from English fragments.
- [ ] Audit list joining and range formatting instead of hardcoded commas,
  ampersands, hyphens, and `x`/multiplication prose.
- [ ] Verify locale switching refreshes already-open screens and cached display
  models without requiring data rewrites.
- [x] Verify active Train, Catalog, Logbook, Progress, and Profile labels remain
  translated when resolving each supported non-English locale.

## 6. Accessibility And Semantics

- [ ] Audit all icon-only actions for localized tooltips and semantic labels.
- [x] Add localized tooltips to the audited active info, close, delete, edit,
  session-timer, catalog-add, ongoing-session, change-set removal, and
  body-part removal controls.
- [ ] Audit charts, heatmaps, progress bars, record badges, media controls, and
  retry states for complete localized spoken descriptions.
- [x] Give active exercise and shared catalog media loading, Wi-Fi-only, and
  retry states localized spoken labels.
- [ ] Ensure visual labels are not incorrectly reused as spoken labels when the
  wording contains symbols or abbreviations.
- [ ] Test text scaling, truncation, focus order, and tap actions in every
  supported locale.
- [ ] Record Android TalkBack review for all supported locales or an approved
  representative matrix with the highest-risk long/script variants.
- [ ] Record iOS VoiceOver review before iOS is a supported release platform.

## 7. Native-Speaker And Content Review

Record reviewers and findings in `docs/localization-review.md`.

- [ ] French (`fr`) app UI review.
- [ ] Canadian French (`fr_CA`) regional review.
- [ ] Spanish (`es`) app UI review.
- [ ] Bangla (`bn`) app UI review.
- [ ] Simplified Chinese (`zh`) app UI review.
- [ ] Hindi (`hi`) app UI review.
- [ ] Exercise-name and exercise-guidance review in every non-English locale.
- [ ] Equipment, muscle, plan, stretch, and nutrition terminology review after
  those catalogs are localized.
- [ ] Maintain a terminology glossary per locale for recurring fitness and
  nutrition terms.
- [ ] Recheck every reported correction on a physical device and at large text.

## 8. Enforcement And Release Proof

Primary source: `test/localization/hardcoded_ui_copy_contract_test.dart`

- [ ] Expand scanning to helper methods and model extensions that return visible
  prose, not only strings passed directly into recognized widget arguments.
- [x] Detect direct helper methods that return user-facing label, title, message,
  description, status, or empty-state literals in active screen/widget sources.
- [ ] Scan plugin/native arguments such as file-picker dialog titles.
- [x] Active file-picker dialog-title literals are included in the copy
  contract; broader plugin/native argument coverage remains open.
- [x] Detect hardcoded weekday-label arrays in the active literal-copy
  contract.
- [ ] Scan dynamic empty/result models, semantics wrappers, menu definitions,
  navigation metadata, and deferred route registrations.
- [x] Enforce ARB message-key parity, locale tags, non-empty values, and runtime
  placeholder retention in CI.
- [ ] Add stable-code coverage contracts for equipment, muscles, plans,
  stretches, nutrients, and built-in measurements as each bundle is created.
- [x] Stable-code coverage contracts exist for equipment, muscles, stretches,
  exercises, and built-in plans; nutrients and measurements remain open.
- [x] Existing localizer contracts prove custom exercise, catalog, and
  measurement names remain verbatim.
- [ ] Add locale-switch tests for active workouts, history, plans, measurements,
  catalog search, filters, and settings.
- [x] Keep a locale-switch regression test for built-in exercise names so an
  already-open catalog surface refreshes without rewriting stored data.
- [x] Keep locale-switch regression coverage for built-in plan data and visible
  record-badge labels without rewriting stored data.
- [ ] Add release-route smoke tests that visit every selectable screen in every
  supported locale and fail on known English sentinels.
- [ ] Add screenshot/golden coverage for stable high-risk layouts and long text.
- [ ] Remove each deferred path exclusion immediately when its product surface
  is completed.
- [x] Make CI fail on missing ARB message keys, wrong locale tags, and dropped
  runtime placeholders.
- [ ] Make CI fail on missing catalog IDs, partial locale bundles,
  unapproved identical-English values, generated-source drift, and detected
  hardcoded release copy.
- [x] Run the hardcoded-copy, reviewed-English, and localization smoke contracts
  as an explicit CI step.
- [x] Regenerate localization sources and run the deterministic ARB structure,
  reviewed-English, locale smoke, formatter, record-badge, premade-plan, and
  workflow contracts. The 2026-09-03 recorded focused result was 31 passing
  tests; native-speaker and signed-device review remain open.
- [ ] Run a signed release build on a clean install, switch through every locale,
  and record the final route/device/accessibility matrix.

## Release Completion Gate

Localization is release-complete only when all of the following are true:

- [ ] Sections 1, 2, 4, 5, 6, 7, and 8 are complete for every feature reachable
  in the release build.
- [ ] Every enabled deferred feature has completed its section 3 checklist and
  no longer has a literal-test exclusion.
- [ ] Every intentionally disabled feature is inaccessible through navigation,
  deep links, restored configuration, and migrations.
- [ ] No app-authored English fallback is visible in a supported non-English
  locale unless its exact value is reviewed and allowlisted.
- [ ] User-authored and source-owned proper names remain unchanged.
- [ ] Native-speaker sign-off and signed-device smoke evidence are recorded.
