# Tonos Expressive visual review queue

This queue is for user visual review of the current Expressive candidate. A
queue entry is not an approval or a technical qualification. Keep approved and
frozen routes out of this queue; their shared components may still appear in
unapproved caller-specific states.

**Progress Settings landing page** (Profile → Progress Settings) was approved
in light and dark and has been removed from the pending queue. The Measured
Items Library destination remains independently pending below.

**Diagnostics & Privacy** (Profile → Data → Diagnostics & Privacy) is now
visually approved in light and dark and has been removed from the pending
queue. The Delete Shared Diagnostics confirmation and history expand/collapse
states were not independently visually confirmed; these are evidence limits,
not pending visual approval. The accepted subtitle truncation and failed-sync
missing-value formatting remain nonblocking.

**Nutrition root** (optional bottom-navigation tab) was explicitly approved
on 2026-10-18 after the current root was shown in light mode. The scope includes
Daily Nutrition, Health Trends, Data & records, and Current Metrics. No separate
dark-mode confirmation is claimed. The three Nutrition goal/record destinations
below remain pending; Pantry Log and Plan Meal remain placeholders.

**Train2** (enable the optional tab in Profile → UI & Appearance → Edit Bottom
Tabs, then Bottom navigation → Train2 → Train) was explicitly approved on
2026-10-19. Its reviewed landing presentation is A — Visually Approved / Frozen,
including the compact selector, nested active-presets/header shapes, manage
pencil, centered Add button, and shared workout action bar. The latest refreshed
view is light mode; separate final dark-mode, History, and Add-popup evidence is
not claimed. Its earlier protected-legacy classification is superseded.

## B — implemented pages awaiting visual approval

1. **Selected Bodypart detail** — **Catalog → Target Anatomy → Bodyparts →
   select a bodypart.** This is separate from the approved Target Anatomy
   library.
2. **Selected Muscle detail** — **Catalog → Target Anatomy → Muscles → select a
   muscle.** This is separate from the approved Target Anatomy library.
3. **Preset Detail** — **Train → Plans → open a plan/preset.** Other callers
   include Dashboard and onboarding.
4. **Onboarding** — first-run entry; it can also be replayed from
   **Profile → UI & Appearance → Replay Onboarding**.
5. **Dashboard root** — enable Dashboard at **Profile → UI & Appearance → Edit
   Bottom Tabs**, then select Dashboard from bottom navigation.
6. **Diet & Nutrition Settings** — enable Nutrition at **Profile → UI &
   Appearance → Edit Bottom Tabs**, then open Nutrition → drawer → Nutrition
   Goals.
7. **Manual Nutrition Goals** — **Nutrition → drawer → Nutrition Goals →
   Manually Set Nutrition Goals.**
8. **Today’s Records** — **Nutrition → drawer → Today’s Records**, also opened
   by selecting a date in the Nutrition calendar.

These eight page archetypes are the complete current B list in the route ledger.
Visual approval does not establish responsive, accessibility, behavior,
automated-test, technical, or release qualification.

## B — caller-specific interaction states

The route ledger also tracks Health metric forms/entry actions for unreviewed
caller combinations and Nutrition date/save/record states as B. These are
interaction states within their routes, not extra page archetypes. The
Progress-origin Log Measurement dialog and other specifically approved states
retain their existing boundaries.

## C/D — historical inventory unresolved

The old C10/D1 aggregate cannot be mapped reliably to current route rows: the
historical C table groups states and the D table names three routes while
reporting one. Do not treat those values as the current backlog. The current
master table records route-level A and B candidates; no complete remaining
C/D route list is available without a unique 55-route crosswalk. Previously
identified candidates now appear as B or A above.

## E — no production caller found

- **App Settings** — source residue; no production navigation path was found.
- **Default Trend** — no production caller was found; source retains placeholder
  and sample-data TODOs.
- **Exercise Muscle Percent** — implementation exists but no production
  navigation path was found.

These are not reachable review routes unless product navigation is added.

## F — placeholder surfaces / not yet implemented

- **Nutrition Log** — experimental tab, denied in release; generic placeholder.
- **Combined History** — experimental tab, denied in release; generic
  placeholder.
- **Form and Posing** — experimental tab, denied in release; generic
  placeholder.
- **Pantry Log** — reached from the Nutrition action bar; placeholder page.
- **Plan Meal** — reached from the Nutrition action bar; placeholder page.

## Current counts and boundaries

The master ledger currently contains **41 A / 8 B page archetypes**, excluding
the navigation shell, Ongoing Workout Exit chooser, and separately approved
interaction/component states. The 24-route Profile dossier remains **22
approved / 2 pending** (Selected Bodypart detail and Selected Muscle detail).
Nutrition is still optional/default-off and has no family-wide approval: the
root page is A, while Diet & Nutrition Settings, Manual Nutrition Goals, and
Today’s Records remain B. The unresolved full C/D crosswalk means the historic
55-archetype totals are not a reliable current backlog count.

Visual approval is separate from responsive, accessibility, analyzer,
automated-test, style-inventory/ratchet, and release qualification. A route's
presence in this queue does not itself approve it.
