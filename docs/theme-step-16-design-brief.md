# Step 16: Third Theme Family Design Brief

## Status

Design exploration and architecture audit only. Step 16 remains unimplemented,
and no third family has been selected. This brief recommends a direction for a
separate product/design decision; it does not record approval to implement it.
Classic and Neo remain accepted baselines.

## Recommendation

Carry forward **Training Instrument** as the leading candidate for product
review. Its proposed identity is a calm, precise training log: cool neutral
surfaces, aligned values, fine separators, and a restrained teal action signal.
It takes its character from Tonos's plan, train, record, and review workflows,
rather than from an unrelated visual trend.

The recommendation depends on showing a structural difference in representative
screens. A palette change alone would make it a Classic colorway. The design
should organize set rows, plan summaries, chart values, and nutrition targets
with a consistent measured hierarchy while preserving readable type and touch
targets.

## Candidate comparison

The names below are working labels for this exploration, not product names or
decisions.

| Candidate | Visual idea | Product and dense-data fit | Main risk |
| --- | --- | --- | --- |
| **Fieldhouse** | Mineral sage, stone, chalk, and clay; soft tactile surfaces and restrained depth. | Comfortable for planning and logging; neutral chart surfaces can keep analytics readable. | Soft rounded geometry can drift toward Classic, while warm paper surfaces can recall Neo. |
| **Tempo** | Cool pearl and blue-gray surfaces, with cobalt or blue-teal actions, coral accents, expressive hierarchy, and controlled motion. | Strong energy for progress and activity; would need restrained chart and status colors on dense screens. | Color and motion can compete with data meanings or approach Neo's vivid color-block character. |
| **Training Instrument** | Cool mist and graphite surfaces, precise row alignment, fine rules, and one teal focus/action signal. | Best fit for set logging, plans, measurements, charts, and target-versus-actual values. | If expressed mainly through color, it will read as a recolored Classic. If expressed through tiny text or excess grid lines, it will hurt legibility. |

All three can support paired light and dark modes. Training Instrument has the
strongest workflow fit and clearest path to a calm dense-data interface, provided
its layout grammar makes it distinct from Classic. Fieldhouse has a warmer,
more tactile personality. Tempo has the most visible energy but carries the
highest risk of competing with chart and status semantics.

The comparison is grounded in the current visual recipes: Classic uses a
Deep Purple seeded Material theme, while Neo uses warm paper, bright yellow and
supporting colors, dark borders, and hard shadows. The current family baselines
are documented in [Classic Theme Baseline](classic-theme-baseline.md) and the
[Neo-Brutalism Plan](theme-neo-brutalism-plan.md).

## Training Instrument: proposed visual contract

### Paired light and dark modes

These are exploratory palette seeds for a Theme Lab mockup. They are not
contrast-qualified or approved values.

| Role | Light direction | Dark direction |
| --- | --- | --- |
| Canvas | Cool mist, for example #F2F5F4 | Deep graphite, for example #101719 |
| Raised surface | White, for example #FFFFFF | Blue-charcoal, for example #1B2427 |
| Main text | Deep blue-gray, for example #172428 | Soft neutral white, for example #E7EFED |
| Secondary text | Muted blue-gray, for example #5F7073 | Light gray-green, for example #ADBAB8 |
| Primary and focus signal | Deep teal, for example #00766D | Pale teal, for example #60D5C5 |

Use separators and outlines only where they remain visible on their actual
surface. A faint divider must not carry focus, selected, error, or disabled
meaning by itself. Positive, warning, error, workout-state, nutrition, and
chart-series colors keep their existing semantic roles; teal must not replace
them. Keep application palette choices separate from entity identity colors.

### Shared visual rules

- Use a small number of neutral surface levels and fine separators to group
  records. Avoid large decorative color panels, textures, and heavy shadows.
- Align loads, reps, counts, units, and targets so users can scan repeated
  values. Do not reduce font size, field size, or tap area to create density.
- Show selection and completion with a visible marker or label as well as
  color. Give focus, disabled, validation, destructive, and confirmation states
  distinct treatments.
- Keep chart series separate from application status colors. Use labels,
  markers, or line patterns where color alone could be ambiguous.
- Begin with existing Material styles and semantic theme extensions. Add a
  token only when a repeated production meaning cannot be expressed through an
  existing role. Do not add a global typography token for one screen.
- Use platform font fallbacks. Treat tabular numerals as an experiment that
  must pass all supported locale and large-text checks before adoption.
- Keep transitions quiet, honor reduced motion, and make effects-disabled
  rendering complete and understandable.

### Representative route treatment

| Route area | Intended treatment |
| --- | --- |
| Train plans and presets | Clear section labels, aligned summaries, fine separators, and an explicit active-plan marker. Preserve the existing plan structure and actions. |
| Live workout | Keep the timer and current exercise easy to find; align load and rep fields; show set completion with a marker and its semantic color. |
| Analytics and health trends | Keep charts on quiet surfaces, use readable grids and labels, and separate totals for sets, duration, volume, and measurements. |
| Nutrition | Present consumed and target values for calories and macros in the same hierarchy while retaining nutrient-specific meaning. Paused Nutrition onboarding remains deferred. |
| Settings, forms, and dialogs | Use consistent section divisions and selected-state markers, with visible focus, validation, and destructive-action treatments in both modes. |

## Architecture and feasibility findings

### Systems that already generalize

- Family and brightness are stored independently. AppThemeSelection, the
  theme-family preference key, and ThemeProvider can carry another stable family
  code without a preference-format redesign. Unknown persisted codes already
  fall back safely while remaining preserved for a newer version.
- The capability boundary returns available families as a list, and Theme Lab
  consumes that list. Shared ThemeExtensions already cover semantic colors,
  surfaces, shapes, effects, motion, visualization, flows, generation, and
  nutrition.
- AppMaterialTheme starts from Flutter's Material recipe for a ColorScheme.
  Ordinary controls can remain Material-owned unless a rendered design
  requirement calls for a targeted override.
- TonosSurface and the other shared recipes resolve from semantic surface,
  shape, and effect roles. This is the preferred integration boundary; route
  widgets should not branch on the new family name.

### Current two-family assumptions to review

- AppThemeFamily and AppThemeFactory have exhaustive two-family registrations.
  A new stable code, complete light/dark builders, and cached ThemeData entries
  would be required after the product decision.
- AppThemeCapabilities explicitly treats Classic and Neo differently and has
  a Neo-specific release opt-in. Product policy must decide the new family's
  development and release gates; a development preview does not imply release
  availability.
- UI Appearance and debug selectors have exhaustive labels. The user-facing
  family name and description need localization in every supported locale.
  The settings preview currently treats Neo specially and renders the Classic
  preview recipe for other values. Theme Lab also displays a Neo-specific pilot
  gallery.
- Several extension accessors fall back to Classic recipes. A family builder
  must attach a complete and intentional set of theme extensions rather than
  relying on fallback values.
- The current usesClassicPresentation helper is inferred from whether the
  panel is outlined. A source count found 31 uses of that helper and 164
  references to the panel-outline trait. These are not 195 family checks:
  many are intentional surface-style decisions. They do show that choosing
  outlined or unoutlined surfaces can route consumers into assumptions
  associated with Classic or Neo. Classify those consumers by purpose and
  qualify only the affected owners; do not mechanically rewrite them all.
- The surface-foreground helper also uses the outline recipe to select Neo's
  contrast handling. Dialog framing and some route geometry use related
  presentation traits. Decide whether the proposed family can use each
  existing behavior or needs a narrowly generalized semantic boundary.

The stored family code is a compatibility value, so its spelling must be
chosen only after the product decision and kept stable. The source owners are
[AppThemeFamily](../lib/theme/app_theme_family.dart),
[AppThemeCapabilities](../lib/theme/app_theme_capabilities.dart),
[AppThemeFactory](../lib/theme/app_theme_factory.dart),
[theme preferences](../lib/theme/app_theme_preferences.dart),
[theme extensions](../lib/theme/theme_extensions.dart),
[surface decoration roles](../lib/theme/tokens/app_surface_decoration_tokens.dart),
[UI Appearance](../lib/screens/profile/settings/ui_appearance_settings_page.dart),
and [Theme Lab](../lib/theme/theme_lab_page.dart).

## Implementation sequence after a separate product decision

1. **Approve the family identity.** Select or revise one candidate, agree on
   its product role beside Classic and Neo, and review paired light/dark
   mockups before registering an enum value.
2. **Map the architecture.** Audit the 164 outline-trait references and the 31
   Classic-presentation references by behavior. Record which existing
   semantic roles fit and the exact consumers that need a generalized role.
   Keep unrelated route-owned styles and deferred features out of scope.
3. **Build the complete recipe.** Add the chosen stable family identity,
   light/dark ThemeData definitions, factory registration, explicit extension
   values, and a capability policy. Generalize only proven shared constraints;
   preserve accepted Classic and Neo behavior.
4. **Add preview and selection presentation.** Give Theme Lab and UI Appearance
   accurate family previews, labels, descriptions, and locale coverage. Keep
   the family development-only until its qualification gate passes.
5. **Qualify in representative workflows.** Start with Train planning, a
   dense live workout, analytics or health trends, nutrition logging, and
   settings/forms/dialogs. Expand from specific evidence rather than
   reclassifying the whole inventory.
6. **Complete the family matrix and review.** Check all six family/brightness
   combinations for paired mode intent; run automated contracts and render
   review for affected routes; record human visual acceptance separately.
   Keep the current inventory and ratchet policy narrow and evidence-based.

## Qualification gates

For the new family, check at minimum:

- Light and dark contrast on actual surfaces, including focus, disabled,
  error, destructive, selected, and completed states.
- Dense set-entry rows and numeric forms at narrow widths and large text,
  without clipped labels or reduced touch targets.
- Charts, heatmaps, measurement trends, and macro summaries with distinct
  series and semantic statuses.
- Screen-reader labels and state changes, keyboard focus visibility where
  applicable, reduced-motion behavior, and effects-disabled rendering.
- Long localized labels in the family selector and representative settings
  routes.
- Human review of the same production routes in Classic and Neo to catch
  unintended baseline changes.

The current roadmap keeps family selection as a separate product/design
decision and requires the new family to reuse the established architecture
while preserving Classic and Neo. See
[Step 16 in the consolidated roadmap](theme-consolidated-roadmap.md#step-16-add-later-families).
