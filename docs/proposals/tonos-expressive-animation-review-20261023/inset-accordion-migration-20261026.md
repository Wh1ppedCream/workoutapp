# Scoped inset-header styling trial

Requested 2026-10-26, after checkpoints `a8dff3e` (source) and `46dc7d1` (before screenshots).

Uses Generate Plans' rounded, outlined inset-header treatment in the following Expressive areas:

| Area | Included | Kept unchanged |
| --- | --- | --- |
| Plan Progression editor | Add a branch; Attach a progression action, through the shared app/gym/plan editor | Graph, fields, actions, Save and progression behavior |
| Workout Progress Rules / Flow Methods | App-wide defaults and outer gym-profile cards; state-correct nested chevrons | Nested card surfaces and content; rule dialogs and menus |
| Workout Progress Flows | App-wide defaults and outer gym-profile cards | Progression entry rows and plan entries |
| Guided tutorials | Main tabs, Workout, Plans & workouts, Catalog & anatomy, Progress & settings; aligned body gutters and inset dividers | Tutorial content and Reset actions; static introduction/control sections |
| Customize Food / Edit Food | Portion Info, Macronutrients, Micronutrients, Additional Components; aligned portion headings and bottom-anchored actions | Portion/nutrient data, field dimensions and Save/Cancel behavior |

The shared `TonosExpressiveInsetAccordion` keeps each existing outer surface, outline and radius owned by its caller. The header moves into a 10dp inset when expanded. Its contents move with it while retaining the caller's normal internal gutters. The inner radius reduces by 8dp, preserving each corner's character, and the header outline uses 72% of its previous opacity so the outer frame remains stronger. A restrained tint distinguishes the header from the body; Ink feedback follows the same changing shape. Collapsed layout and colors remain. No header theme is inherited by nested controls.

### Expanded-content polish after the initial trial

The first migration retained the old body padding, leaving first controls touching their inset headers and some nested cards flush with their parent. The follow-up treats the header and body as one component:

- Progression editor: 12dp header/body gap, 12dp side gutters, 14dp bottom padding, and 12dp spacing between fields, guidance, actions and the two panels.
- Rules: 12dp separation and 10dp side/12dp bottom gutters around the gym-profile body. Nested Profile defaults and plan cards retain their existing appearance. App-default rules use a 4dp added gap because their first rows already have internal padding.
- Flows: 12dp header separation and side/bottom gutters, with 14dp between the gym-default entry and Plans heading.
- Tutorials: 8dp header separation and bottom padding; existing row columns, controls and dividers stay aligned.
- Food: 10dp header separation, slightly wider nutrient-field gutters and 4dp additional bottom padding. Portion Info retains its existing side gutters; nested groups and field dimensions stay unchanged.

Header/body separation is inside the collapsing body, so collapsed cards retain no extra space. This polish is Expressive-only and does not change content, data or actions.

### Geometry and finishing pass after screenshot critique

- Removed the horizontal-padding compensation that left icons, text and trailing controls crowded against the expanded header's inner edges. All header contents now move inward with the shape, with matching smaller inner corners and a quieter visible outline.
- Tutorials' body rows receive matching 10dp side gutters; divider ends align with the trailing controls rather than running into the outer card edge.
- Rules' nested Profile defaults and plan chevrons now rotate according to their own expansion controllers, including initially expanded states and reduced motion. Their card styling is retained.
- Food's portion subgroup headings align with the expanded outer heading. The Expressive floating-action wrapper now sizes to its contents instead of filling the available height, placing Save and Cancel at the bottom above system/keyboard insets. Existing scroll clearance and action behavior are retained.

One native Expansible timeline drives header inset, outline, chevron and disclosure height, using the existing 360ms settling motion and corrected closing curve. Material shape changes do not add a second animation tail. Reduced motion switches immediately. PageStorage expansion behavior, body actions and route-owned field controllers are retained.

Classic/Neo keep their existing rendering branches. Generate Plans itself, Premade Plans, Gym Profile Equipment, exercise cards, Exercise Details and Workout Report are unchanged. The archived [before gallery](accordion-style-baseline-20261026/BASELINE_GALLERY.html) is preserved.

## Focused validation

- **75 focused tests passed** across the shared accordion, progression editor, rules, flows, tutorials and Food presentation/action suites. Covers light/dark, 320dp/411dp widths, 2x text, header gutters and radius, header/body separation and nested-rule gutters, Tutorial column/divider alignment, state-correct nested chevrons, interrupted motion/rebuilds, late collapse frames, body-action isolation, semantics/reduced motion, field retention and Classic/Neo rendering. Food checks also verify bottom anchoring at 320/360/390dp, up to 2x text and keyboard insets, plus existing payload saving/cancellation and validation.
- Scoped analysis: no errors or warnings. Four existing Radio API deprecation infos remain in this finishing pass's changed screens. No Radio controls were changed.
- The exact progression-editor style-ownership guard was updated for its two added, already-owned icon-style occurrences; classification/kind limits remain enforced.
- Changed Dart files formatted. No full test suite, data migration, reset or reseed.

The device check exposed a nutrition theme-scope mismatch in the initial header radius. The Food section builder now receives its local destination context, matching each outer card's existing asymmetric radius. Added a rendered-widget assertion for all four Food sections; all six focused Food checks passed again in Expressive light/dark and Classic/Neo. The new shared accordion and its tests also pass analysis without issues.

## Pixel 7 review

The finishing-pass offline debug build succeeded and was installed over the existing app. Current database/preferences were backed up before installation; all seven archived files matched SHA-256 immediately afterward. Reviewed all five areas in light mode, plus the shared progression editor and Food editing in dark mode. Confirmed the expanded header's contents move inward, Tutorial icon columns and divider ends align, nested Rules chevrons change direction on collapse/reopen, and Food Save/Cancel sit at the bottom instead of mid-screen. The new [finishing-pass captures](accordion-final-polish-20261026/REVIEW.html) supersede the earlier comparison's after design; its original images remain archived.

Restored the original light-mode preference and left **App Default Progression > Attach a progression action expanded**. No rules, graph structure, food/portion values or workout records were edited or saved. The bounded runtime log check found zero Flutter errors, fatal exceptions or overflows. These device spot checks do not claim exhaustive performance or responsive qualification.

## Implementation files

- `lib/theme/widgets/tonos_expressive_inset_accordion.dart`
- `lib/screens/exercise/auto_preset_flow_screen.dart`
- `lib/screens/profile/settings/flow_methods_page.dart`
- `lib/screens/profile/settings/workout_progress_flows_page.dart`
- `lib/screens/profile/settings/tutorials_settings_page.dart`
- `lib/screens/nutrition/food_customization_page.dart`
- `lib/widgets/settings_tiles.dart`

Six focused test files were added/updated for the shared component, editor, rules, tutorials and Food presentation. The existing Workout Progress Flows and nutrition save/cancel/validation suites also passed. Baseline captures and unrelated working-tree artifacts were preserved. `git diff --check` passed.

This is an implementation trial awaiting the user's visual review. Existing page and animation approval classifications/totals are unchanged. No release qualification is implied.
