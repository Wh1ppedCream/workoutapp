# Current route ledger and conservative-expression audit

This is a source reachability inventory for the current candidate, not a claim that every page has been tested or visually qualified. The underlying 55-route ledger was checked against the current `NavBarConfig` and `MainScreen` dispatch: the three policy-gated tabs are still `nutritionLog`, `combinedHistory`, and `formAndPosing`. The count breakdown comes from the source-traced ledger at `docs/proposals/tonos-expressive-next-pages-review-20261004/routes-and-review-states.md`.

## Counting rule

Count a distinct production page class once, even if multiple callers reach it. Count five default-enabled tabs, six additional configurable tabs, onboarding, 15 other exercise/catalog/logbook routes, 17 Profile/settings routes, two nested detail pages, and nine optional Nutrition subroutes: **55 source-reachable page archetypes**. In normal release navigation, three unfinished tabs are denied by `NavigationBuildPolicy`, giving **52 release-reachable archetypes**. Dialogs, sheets, overlays, and state variants are review states rather than extra page archetypes in this count; this differs from older candidate ledgers that separately count the Exercise Details sheet. Debug-only Theme Lab/galleries and unreferenced classes are excluded.

The 52/55 totals are a static source audit, not device traversal. Nutrition pages can be reached only after enabling the default-off Nutrition tab. “Default-off” is not synonymous with unreachable. The disabled Nutrition tile in Profile is a placeholder state, not a route.

## Classification scale

- **A — Strongly Expressive:** coherent composition, meaningful chromatic surface area, role-specific shapes/hierarchy; current approved reference or adequately established candidate.
- **B — Expressive but conservative:** Expressive identity exists, but structure/composition or lower-page states still need review/amplification.
- **C — Mostly Classic with Expressive decoration:** color/tokens appear, but the page largely retains Classic grouping and presentation.
- **D — Generic Material / needs full adaptation:** no convincing destination-specific Expressive treatment.
- **Gated / placeholder / deferred:** not an invitation to invent or expand the product; preserve current availability and record follow-up.

Current ratings are working hypotheses from source and prior reviews. Fresh screenshots are required before raising a candidate rating.

## Major families

| Family / routes | Source reachability | Starting audit and current pass disposition |
| --- | --- | --- |
| Train Overview, Train Plans, navigation shell | Default Train tab | **A, frozen reference.** Preserve current composition, hierarchy, identity colors, shell destinations, and ordinary-width appearance. Only inspect specified narrow/large-text regression states. |
| Active Workout / Session | Train and several workout entry points | **A, frozen reference.** Preserve ordinary-width card/set workflow and style; inspect only responsive/large-text/keyboard states. |
| Planning: Preset Detail, Gym Profile, Optimized Workout Settings, Plan Management, Premade Plans | Train/planning/onboarding callers | Previously **B/C** in several routes. Current tree has route-local planning treatments with stronger focal/section composition and role-based tones. Treat all as unapproved candidates pending paired device review, including lower sections and dialogs. |
| Catalog: root, browser, Exercise Focus Library, bodypart detail, muscle detail, Exercise Details sheet | Catalog and shared callers | Root/reference **A/B**; drilldowns previously **B/C**. Drilldown owners now have expanded canvas/surface hierarchy and selected-state foreground corrections. Keep shared picker behavior scoped; inspect fallback media, long names, filters, dark mode, scroll and sheet states. |
| Progress: root, Workout Report, Exercise Progress, Health Trends, 1RM detail, measurement detail | Progress and nested chart/detail calls | **B** before this pass; responsive tick-label collision and generic health-card role were flagged. Current changes address axis-label spacing, health surface ownership, and originating destination identity. Chart semantics/colors remain protected. Device review pending. |
| Logbook: month/3M/year/4Y, Full History, Session Detail, editable history cards/dialogs | Logbook and nested history callers | Root/calendar was **B**; Full History/Session Detail conservative. Current candidate improves large-period 4Y selection and high text scale. Full History date grouping now uses the structural plum-band treatment while preserving row chronology/content. Session Detail keeps adaptive metric wrapping. Integration validation is complete; fresh device evidence is pending. |
| Profile/settings: Profile root and Account, Training, Data, Navigation, Tutorials, User Information, Appearance, workout-flow and progress settings, measurement/data/privacy tools, dialogs | Profile and nested settings routes | **B/C** in the source audit; selected settings still read as preference forms/lists. Current candidate improves selected icon contrast, User Information grouping, and selected Appearance/Navigation/Tutorial routes. Other child settings/dialogs must still be judged individually; do not infer all Profile routes are complete from the root. |
| Analytics Settings: Analytics Settings, Body Part Ranking, Muscle Ranking, Volume Boundaries, Anatomy Mapping, Exercise Set Allocation, Exercise Editor | Profile → Gym & Workout → Analytics Settings | Seven-route family previously **B/C/D**. Current candidate uses dedicated analytics destination surfaces/tokens and expressive route headers. The narrow/large-text header wrapping fix is implemented and included in integration validation; Pixel visual confirmation is pending. |

## Other currently reachable gaps and scope decisions

The wider source audit identifies meaningful routes beyond this pass. The classifications below are intentionally candid and should remain in the review record.

| Route/family | Classification/status | Decision for this pass |
| --- | --- | --- |
| Dashboard root and analytics dashboard | **B/C or partial** | Reachable/configurable, but not a target for redesign; protect overlap with frozen references and data visualization. List as follow-up. |
| Train2 | Legacy configurable tab; frozen/blocked | Preserve existing route, do not redesign as part of this candidate. |
| Preset Generation QA / generator | **D, follow-up candidate** despite its class name; it is user-facing | Keep workflow untouched; report as an important next gap. |
| Auto Preset Flow editor / Flow Methods | **C/D, follow-up candidate** | Reachable from settings and preset detail. Dirty shared work; defer separate review rather than collateral editing. |
| Onboarding | **C/D, follow-up candidate** | No Expressive route treatment verified; overlaps Gym Profile/Premade flows. Do not alter onboarding in this batch. |
| Combined History | **Partial/protected** | Optional tab; shares Logbook surfaces. No broad styling change. |
| Nutrition and nine subroutes | **Gated/out of scope** | Nutrition tab is default-off/configurable; feature family paused. Preserve data and availability. Profile’s Nutrition tile remains a disabled placeholder. |
| Form and Posing | **Placeholder** | Experimental tab; current placeholder only. Do not invent feature UI. |
| Theme Lab, Neo pilot gallery, interaction labs | **Debug-only** | Excluded from production route count and this visual candidate. |
| `AppSettingsPage`, `ExerciseMusclePercentScreen`, `DefaultTrendPage` | **Unreferenced** | No production caller found in the source audit; excluded rather than treated as reachable destinations. |

The seven Analytics Settings routes are included within the wider 17-route Profile/settings group, not added on top of the 55. Several other named pages in this task are likewise part of the 15 exercise/catalog/logbook routes. Route count measures distinct page classes, not number of visual states or implementation files.

## Fresh review requirement

For each changed family, record paired light/dark screenshots from the current preview build, key scroll and selected/expanded states, and narrow/large-text captures where called out in [visual-review-list.md](visual-review-list.md). A source classification is not visual approval.
