# E2 And Qualification Execution Guide

This is the implementation companion to [Theming Batch Playbook](theme-batch-playbook.md).
It expands E2 and Q1-Q3; it does not authorize an alternate theme or declare
any prerequisite complete. Use the playbook for batch ordering and this guide
for execution details. When code and historical notes disagree, inspect the
current code and record the discrepancy before changing behavior.

## Current Evidence And Boundaries

- E1 has user-reported clean analysis and 184 passing scoped tests. The pasted
  analyzer command was truncated, so retain that limitation in evidence.
  Device visual and accessibility qualification remains pending.
- E2 and the qualification work below are planned, not implemented by this
  documentation update. Sub-batch IDs here are execution units, not new top-level
  numbered phases. Keep Steps 12E, 18 and 19 aligned with their parent batches.
- Work in E:\projects\env_test. Preserve unrelated working-tree changes.
  Do not run Dart/Flutter verification from Codex; supply exact user-run commands.
- Classic is a compatibility target, not an opportunity to redesign. Do not
  normalize colors, typography, radii or spacing merely because two values
  look similar. Compare resolved light AND dark values, not token names.
- Do not combine migration with data-model, localization, repository, permission,
  navigation, or persistence rewrites. Open a separate issue for unrelated bugs.
  If a migration exposes a real bug, isolate its fix and evidence.

## E2. Remaining Reachable Features

### E2.1 Reachability And Residue Ledger

Start with lib/main.dart tab construction and follow every supported settings
configuration, button, drawer, sheet and Navigator push. Hidden tabs are not
unreachable routes. Inspect lib/screens/catalog_page.dart and
lib/screens/profile/settings/profile_page.dart as additional entry points.

Create a route ledger in the playbook or a linked table. Each row must include:
entry point; destination file/widget; shared widgets; release/debug visibility;
empty/loading/error/populated/editing states; current visual owners; batch ID;
verification evidence; outstanding manual checks or approved exclusion.

Inspect these actual files rather than inferring scope from directory names:

| Group | Initial targets | Required investigation |
| --- | --- | --- |
| Nutrition entry | lib/screens/nutrition/nutrition_page.dart; lib/screens/nutrition_log_page.dart | Distinguish the working feature from the current Nutrition Log placeholder. Establish whether each is reachable through configurable tabs. |
| Food entry | lib/screens/nutrition/food_logging_page.dart; food_customization_page.dart; log_entry_page.dart | Follow selection, portion editing, save/cancel and returned results. |
| Pantry and meals | lib/screens/nutrition/pantry_log_page.dart; plan_meal_page.dart | Follow shared bars/cards, editing and empty states. |
| Scanner | lib/screens/nutrition/barcode_scanner_page.dart | Separate plugin/camera preview from app-owned overlay and permission/error UI. |
| Trends | lib/screens/nutrition/default_trend_page.dart; measured_items_page.dart | Check whether the route already uses D3 consumers; do not repeat or undo D3. |
| Settings residue | lib/screens/profile/settings/ | Audit all reachable pages, not only the last edited page. Include dialogs and nested routes. |

A placeholder is not permission to build a new product feature. Record its
current presentation and reachability. Gating or removing an existing route
requires explicit approval; document unresolved release exposure for Q3.

Search the inventory and code for remaining direct styling, but do not treat
every match as debt. Theme-consuming BoxDecoration and InputDecoration are
legitimate. Classify each candidate as Material-owned, app structure,
domain meaning, fixed media contrast, identity color, or unresolved.

**Exit:** every discovered route and catch-all finding has a specific owner
and next action. Unknown reachability remains unresolved, not excluded.

### E2.2 Nutrition Presentation Migration

Trace the shared consumers before editing: lib/widgets/meal_plan_add_bar.dart,
lib/widgets/nutrition_text_details.dart, and widgets imported by the routes.
Inspect lib/theme/tokens/app_nutrition_tokens.dart first. It currently contains
pantryLogSurface, addMealSurface, planMealSurface and textDetailsBorder; it is
not a complete nutrition chart or category palette.

For each changed expression:
1. Record its old light/dark resolved value and state-dependent behavior.
2. Choose Material components for standard controls, existing focused tokens
   only when their meaning AND values match, or a new domain role when needed.
3. If adding a field, update constructors, Classic/fallback factories, copyWith,
   lerp, both registered themes, custom test fixtures and override tests.
4. Replace consumers without changing callbacks, validation or return values.
5. Add a rendered consumer test using a visibly different injected value.
6. Compare Classic expectations against the old recipe, not the new factory
   under test. A factory compared with itself proves nothing.

Do not turn nutrient categories, user-picked identity colors or success/error
meaning into generic primary color. Conversely, do not hardcode category
colors in widgets when an actual domain palette should own them.
Keep calorie/portion arithmetic, date windows, IDs, rounding, units, search
queries and repository writes unchanged.

Preserve image fit and crop, empty-media behavior, keyboard focus, text editing,
disabled/busy button states, sheet return values and dismissal. Scanner
permission prompts and camera imagery are platform/content-owned. Test app
overlay behavior with a fake or injectable boundary; do not require real camera
hardware in the ordinary widget suite. Physical scanner evidence is separate.

Split implementation by food entry, pantry/meals and scanner/trends as necessary.
Each slice must pass before expanding into another feature. There is no minimum
file count; a small coherent batch is preferable to an unverified broad rewrite.

**Exit:** all ledger routes in this slice have resolved visual ownership,
Classic value checks, injected-token coverage and relevant behavioral tests.

### E2.3 Settings Residue

Inspect diagnostics_settings_page.dart, database_settings_page.dart,
diet_nutrition_settings_page.dart, gym_exercise_settings_page.dart,
analytics_setting_screen.dart, app_settings_page.dart and any residue in the
previously migrated editors, ranking, flow, appearance and tutorial pages.

Use lib/widgets/settings_tiles.dart where the existing recipe genuinely
matches. Do not replace a control with a shared tile if doing so changes
padding, focus, semantics, validation, expansion state or interaction targets.
Do not add a large collection of raw styling arguments to bypass ownership.

For special controls, isolate a named recipe or narrow shared component.
Retain all confirmation dialogs and destructive-action safeguards.
Database diagnostics, import/export, preferences and tutorial reset must
retain their exact data behavior. Theme changes must not initiate those actions.

Add tests for disabled controls, expansion/reorder state where present, and
save/cancel behavior around a rebuild. Existing source contracts are adoption
checks only; they are not substitutes for exercising the actual widgets.

**Exit:** every settings residue entry is migrated, intentionally Material-owned,
or individually documented with rationale and approval where deferral is needed.

### E2.4 Closeout

Re-run the route audit after edits. Shared widgets can affect callers outside
the batch; include those in analysis and regression selection. Record exact
commands, counts and tree identity. Do not claim full E2 completion from only
the theme suite. If no feature tests exist, add focused tests rather than silently
omitting that feature from verification. Keep manual checks explicitly pending.

## Q1. Inventory Enforcement

Current status (2026-09-09): the separate `tools/theme_style_ratchet.dart`
enforcer has user-run fixture verification, and
`docs/theme-style-ratchet.json` protects the exact
`lib/theme/widgets/tonos_surface.dart` production scope. CI runs that enforcer
after the report-only inventory check. The latest user-run theme/configuration
suite passed 200 tests. The inventory remains report-only; this does not qualify
other production files or replace manual/device review.

### Q1.1 Define The Contract Before Changing The Tool

Current facts in tools/theme_style_inventory.dart:
- The scanner uses regular-expression candidates, not a complete Dart parser.
- Rules are first-match ordered through ruleFor.
- Manifest validation accepts only report-only mode.
- Report serialization currently emits report-only.
- --check rejects unassigned findings; it does not reject all pending styling.

Therefore, changing a JSON status or running --check cannot establish a ratchet.
Implement enforcement deliberately in validation, classification, reporting,
CLI failure behavior and tests together. Keep backward-compatible report-only
behavior for existing callers. Names for any new mode/options are proposals
until implemented and documented; do not publish imaginary runnable flags.

Use a versioned enforcement schema or a separate qualified-scope baseline.
Define exact qualified paths/regions, approved exceptions, and explicit owner
and rationale for each retained expression. A broad path rule must not
automatically bless new literals anywhere in that path.

### Q1.2 Stable Findings And Narrow Exceptions

Line numbers are navigation aids, not identities. Design finding identity from
normalized relative path, enclosing declaration/context, candidate kind and
normalized expression. Preserve literal values and operators when normalizing.
Whitespace/comment edits should not create new debt. Changed numeric values
must not disappear through overly aggressive normalization.

Account for duplicate expressions with multiplicity or context, so adding a
second hardcoded expression cannot hide behind an existing fingerprint.
Do not use only a set of expression strings. File moves and declaration renames
need an explicit reviewed baseline migration, not an automatic approval.

Avoid scanning comments/strings as executable styling when producing blocking
findings. If using a lexical pass, handle raw/multiline strings and interpolation
correctly and document unsupported syntax. Consider a Dart AST only after
checking available dependencies; adding a parser dependency needs justification.
Retain a report path for uncertain candidates rather than silently ignoring them.

An exception must identify the narrow expression/context, its purpose, owner,
and review condition. Examples: image-viewer black scrim, user identity colors,
generated source. Never allow all Colors.* or every BoxDecoration in a feature.
Theme recipe files can legitimately own constants; their allowlist must not
extend accidentally to ordinary feature consumers.

### Q1.3 Fixtures And CI

Add fixtures in or alongside test/theme/theme_style_inventory_contract_test.dart:
- New unapproved literal in a qualified scope fails with useful location/reason.
- Existing approved expression passes; changing its value fails.
- Duplicating an approved expression is detected.
- Formatting/comments do not change identity.
- Specific rules beat catch-all rules according to documented ordering.
- Pending scopes remain visible without blocking unrelated work.
- Missing files, malformed schema, duplicate IDs and invalid exception references
  fail clearly, rather than silently weakening enforcement.
- Windows separators normalize consistently; repeated scans serialize in a stable order.
- Fixed-media/domain exceptions pass only in their intended context.
- Theme-token-consuming decoration remains legal.

Inspect .github/workflows/ci.yml and test/github_workflow_contract_test.dart
before integration. Preserve unrelated jobs and existing workflow contracts.
The passing and deliberate-failure fixture proof and the initial scoped CI
enforcement are now recorded. For future scopes, repeat that proof before
enrollment and never regenerate the baseline automatically as part of CI or
auto-accept all findings to make the check green.

**Exit:** a demonstrated ratchet protects only evidence-qualified scopes;
report-only coverage continues elsewhere. Record test scope and actual CLI
exit behavior, not just a snapshot of generated JSON.

## Q2. Runtime And Accessibility Qualification

### Q2.1 Extension And State Matrix

Use injected test themes, not an unfinished alternate family. Start with the
complete Classic theme, replace one extension by type and preserve all others.
Change colors AND geometry/effects enough to make fallback mistakes visible.
Cover AppProgressColors, AppMediaTokens and AppTutorialTokens as well as older
surface, shape, motion, semantic, nutrition and effect extensions.

Audit lib/theme/theme_lab_page.dart for every newly introduced duration/effect
field. Existing overrides for some fields do not prove all consumers respond.
In particular, verify exerciseDetailSelection, specialized sheet elevation,
media shadows and tutorial durations/effects. Fix omissions with consumer
tests; do not conflate readiness delays with animation durations.

For each representative route, establish user state, switch the theme in place,
then assert the SAME state remains:
- Train tab/selection and scroll position.
- Active session values and ongoing-session navigation.
- Open sheet or dialog and its return result.
- Focused text field, selection/cursor, unsaved text and validation state.
- Expanded settings sections, chart selection/range and list position.
- Tutorial step, confirmation state and completion result.

Do not force recreation with a theme-dependent key, clear a controller, reload a
repository or trigger persistence in build. Rebuild styling through inherited
theme dependencies; retain business state and repaint when paint inputs change.

### Q2.2 Persistence And Capabilities

Inspect lib/providers/theme_provider.dart, app_theme_preferences.dart,
app_theme_capabilities.dart, app_theme_factory.dart and lib/main.dart.
Preserve the existing _mutationQueue ordering and failed-write behavior.
Tests must cover rapid successive updates, a failed write followed by a successful
one, startup loading, unknown/unavailable persisted selection and Classic fallback.
Do not silently overwrite unsupported saved values unless that is the existing,
explicitly tested contract.

Keep Theme Lab development-only. Check both navigation exposure and capability
resolution; hiding a link alone is not a release gate. Lab experimentation must
not write production preferences. Do not add enum entries for a fake release
theme just to test switching.

### Q2.3 Responsive And Motion Tests

Use deterministic viewport sizes including approximately 360px wide phones,
a wider phone, and a constrained-height/keyboard case. Test 1.0, 1.3, 1.6 and 2.0
text scales. Use actual supported locales for long labels and RTL where available;
do not claim RTL coverage merely by testing another left-to-right language.

Fix overflow through wrapping, flexible layout, bounded scrolling and reachable
actions, not by shrinking accessible text, disabling scaling or clipping labels.
Preserve normal-scale Classic layout; isolate accessibility adaptations.

Inspect guided_tutorial_overlay.dart's locale-dependent reflow condition:
English large text must not be assumed safe simply because translated text has
a stacked path. Check coach card height after text-scale/locale changes,
small-height layouts, keyboard opening and rotation. Test real constraints.

System reduced motion and injected reduced tokens must suppress visual animation.
Zero-duration PageController navigation must jump rather than animate.
Readiness polling remains active. Effects-off must remove optional shadows/blur
while retaining essential focus indication, contrast and instructional scrims.
Test painter invalidation when colors/radii change without data changing.

### Q2.4 Evidence And Limits

Use test/theme/theme_lab_page_test.dart, token tests, real consumer tests and
test/widgets/responsive_accessibility_test.dart as starting points. Expand them
rather than relying only on source searches. Golden baselines need stable fonts,
platform, size, locale and data; never approve new goldens merely to hide drift.

Compare matched captures with docs/classic-theme-baseline.md. If no reliable
pre-migration capture exists, label the gap; do not invent parity evidence.
Record light/dark, device/OS, text scale, route/state and any accepted difference.

Human evidence still required: TalkBack traversal/announcements, keyboard focus,
screen-reader dismissal behavior, real camera permissions where applicable,
and physical-device animation/scroll performance. Automated semantics checks
support but do not replace these. Record the tester and result or leave pending.

**Exit:** automated failures are fixed; every required manual check has evidence
or an explicit approved exception. Q2 is not qualified while silent gaps remain.

## Q3. Readiness Decision

### Q3.1 Reconcile Evidence

Update docs/theme-design-plan.md, docs/classic-theme-baseline.md,
docs/theme-style-inventory.md and the playbook ledger together.
For each prerequisite in Steps 2, 3, 12A-E, 17 and 18, link:
implementation paths; scoped verification; qualification evidence; unresolved
exceptions; next action. Do not infer status from chronological test counts.

Record HEAD plus dirty-working-tree identity. With uncommitted work, a commit
hash alone is insufficient: include a patch/artifact identifier or content hashes
for reviewed files, command scope and date. Never discard or commit unrelated
changes solely to create a clean evidence record. Revalidate affected evidence
after subsequent edits; old passing tests do not cover new code automatically.

### Q3.2 Explicit Gate

Produce a readiness table with one row per prerequisite and these columns:
requirement; status; evidence; remaining risk; approver/exception; decision.
Use planned, implemented-awaiting-verification, scoped-verified and qualified
consistently. A known untested route is not qualified.

Block readiness for unresolved runtime errors, Classic regressions, inaccessible
core controls, missing extension support, state loss, persistence faults, or
unreviewed reachable migration debt. A narrowly accepted exclusion must say
why it is safe, who approved it and what future event reopens it. The implementer
cannot grant themselves a product-risk exception.

If blocked, list the exact follow-up code/test/evidence work and owning batch.
If ready, state precisely that prerequisites for Step 13 are satisfied.
That is NOT permission to ship an alternate theme, expose incomplete selections,
or bypass Steps 14-16. Alternate-theme design and release remain separate work.

### Q3.3 Handoff

Provide a concise user-facing status summary linked to the detailed table,
the last successful command scopes, pending manual decisions and the next
authorized action. Do not replace evidence with a percentage-complete estimate.
No new runtime code is expected in Q3 unless a discovered gap is explicitly
sent back to its implementation batch and reverified.

## Per-Slice Verification Rule

Before handing off commands, enumerate every changed consumer and its callers.
Give exact existing paths for formatting/analysis and the relevant feature tests,
plus the theme suite. For new tests, create them before naming them in commands.
Include inventory tooling tests for Q1 and workflow tests if CI changed.

Use explicit LASTEXITCODE guards when supplying a stop-on-failure PowerShell
script. ErrorActionPreference alone does not stop native commands. Respect
AGENTS.md: Codex does not execute Dart/Flutter verification. Record user output
verbatim enough to establish scope and success; line-ending warnings alone do
not require a repository-wide normalization.
