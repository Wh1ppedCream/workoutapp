# Expressive Next Pages — Review Batch

**Status: unapproved review candidate.** The five selected route treatments and paired light/dark screenshots are ready for user review; this does not approve broader Expressive rollout.

## Review targets and preview paths

| Target | Path from the preview root |
| --- | --- |
| Plan Management | Train → Plans → Edit in Active Plans or Archived Plans. |
| Premade Plans | Train → Plans → scroll below Active and Archived Plans → Premade Plans. |
| Preset Detail | Train → Plans → tap a seeded plan row. |
| Optimized Workout Settings | Train → Overview → Optimize action group → settings gear. |
| Gym Profile | Train → Overview → top-right gym avatar → edit the selected gym profile. The drawer also offers a new-space route. |

The preview starts at `MainScreen`, so onboarding-only entry variants for Premade Plans, Preset Detail, and Gym Profile are not directly reachable there. Each target has the Train entry path above; onboarding-specific return and draft behavior remains outside this review path.

## Device and isolated preview

Captured on Pixel 7 (`28021FDH200228`, Android 16/API 36) using only the isolated preview identity:

- Package: `com.tonos.expressivepreview`
- Database: `tonos_expressive_preview.db`
- Preview entry point: `lib/expressive_preview_main.dart`

The profile APK was built with Flutter 3.47.5 / Dart 3.13.4 using `tools/run_expressive_preview.ps1 -BuildMode profile`, `--target lib/expressive_preview_main.dart`, and the explicit preview/database Dart defines. The runner verified package `com.tonos.expressivepreview` and database `tonos_expressive_preview.db`. The APK was installed as an update to that preview package only; normal Tonos packages and databases were left alone.

## Planned evidence layout

Captured route pairs are under [`review-batch-20261004/`](review-batch-20261004/README.md), with each route’s matching light and dark stills together:

- `plan-management/expressive-light.png` and `expressive-dark.png`
- `premade-plans/expressive-light.png` and `expressive-dark.png`
- `preset-detail/expressive-light.png` and `expressive-dark.png`
- `optimized-workout-settings/expressive-light.png` and `expressive-dark.png`
- `gym-profile/expressive-light.png` and `expressive-dark.png`
- `README.md` as an index for captured states and any accompanying hierarchy files

The captures use the populated preview fixtures. Route-specific state, prior/current presentation, dark-mode mapping, preserved behavior, test scope, and visual QA notes are in the batch index. Empty, dialog, validation, and return states remain outside this capture set.

## Preview controls and reset

At a root page, open the top-strip tune control to select Expressive/Classic, palette, Light/Dark, motion, effects, locale, and text scale. The control entry is hidden while a child route is open, so return to Train before changing brightness. **Reset review controls** restores the preview’s in-memory Expressive/Curated/Light defaults; it does not reset fixture data.

**Reset sandbox fixtures** removes only rows tracked by the isolated preview manifest, then reseeds the preview profile, plans, and workout history. It is not a database wipe and can leave unrelated, untracked preview rows intact. Reset is unavailable while a workout is finishing or pending workout progressions remain. The fixture reset does not reset persisted navigation-tab choices.

For this batch, **Reset review controls** and **Reset sandbox fixtures** were both invoked from the preview control dialog. Controls were then set to Expressive / Curated / Light for light captures and Expressive / Curated / Dark for dark captures. The same seeded profile and plans were used in each pair. No plan action, preset save/start, optimized-settings save/start, or gym-profile save was performed.

## Review boundary

These five routes are candidate review targets only. This batch does not change Train Overview/Plans layouts, active-workout layouts or behavior, route semantics, data/generation behavior, or production theme-family, fallback, identity, or shared destination-color architecture. Existing route ledger: [`routes-and-review-states.md`](routes-and-review-states.md).
