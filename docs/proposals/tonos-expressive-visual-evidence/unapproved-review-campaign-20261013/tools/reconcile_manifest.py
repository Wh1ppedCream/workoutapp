"""Reconcile campaign evidence links and mark unavailable states accurately."""
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "screenshot-manifest.json"
data = json.loads(MANIFEST.read_text(encoding="utf-8"))
screenshots = {item["id"]: item for item in data["screenshots"]}
coverage = {item["id"]: item for item in data["coverage"]}


def mark_unverified(capture_id: str, note: str) -> None:
    item = screenshots[capture_id]
    item["verified"] = False
    item["limitations"] = note


def row(
    coverage_id: str,
    group: str,
    state: str,
    theme: str,
    classification: str,
    status: str,
    route: str,
    screenshot_ids: list[str] | None = None,
    reason: str = "",
) -> None:
    item = coverage.get(coverage_id, {"id": coverage_id})
    item.update(
        {
            "group": group,
            "state": state,
            "theme": theme,
            "classification": classification,
            "status": status,
            "navigationPath": route,
            "screenshotIds": screenshot_ids or [],
        }
    )
    if reason:
        item["reason"] = reason
    else:
        item.pop("reason", None)
    coverage[coverage_id] = item


# These records point at captures whose pixels do not show the claimed state.
for capture_id, note in {
    "03-muscle-biceps-top-light": "Superseded: this file shows a loading spinner, not the Biceps detail. Use 03-muscle-biceps-light-top.",
    "05-premade-top-dark": "Unverified stale capture: the duration selector shows 1 hr. Use 05-premade-top-dark-verified for the settled default screen.",
    "05-premade-expanded-dark": "Unverified stale capture: the expected plan preview is not present. Use 05-premade-plan-previews-dark.",
    "05-premade-two-hour-dark": "Unverified mis-selection: this capture shows 1 hr, not 2 hr. Use 05-premade-two-hour-dark-verified.",
    "05-premade-duration-two-hour-light-campaign": "Unverified mis-selection: this capture shows 1 hr, not 2 hr. Use 05-premade-duration-two-hour-light-settled-campaign.",
    "05-premade-equipment-filter-off-light-campaign": "Unverified transient loading frame. Use 05-premade-equipment-filter-off-light-settled-campaign.",
    "01-browser-muscle-menu-dark-final": "Misidentified state: this menu shows Focus Area values, not Specific Muscle. Use 01-browser-specific-muscle-menu-dark-campaign.",
    "catalog-browser-form-guide-expanded-light-campaign": "Form Guide is collapsed in this capture; use catalog-browser-form-guide-expanded-light-campaign-verified for the expanded state.",
}.items():
    mark_unverified(capture_id, note)

screenshots["02-bodypart-chest-lower-dark-verified"]["limitations"] = (
    "Retained as a distinct associated-muscle view; the newer campaign-final capture shows the lower exercise list."
)
screenshots["health-entry-menu-dark-campaign"]["limitations"] = "Menu dismissed after capture; no action was selected."
screenshots["health-entry-delete-confirm-dark-campaign"]["limitations"] = "Canceled confirmation; measurement record retained."
screenshots["health-entry-edit-dialog-dark-campaign"]["limitations"] = "Dialog canceled without changing or saving the entry."

# Separate two placeholder pages from the unmapped nutrition-route evidence.
renames = {
    "unmapped-todays-records-light": "unmapped-pantry-log-placeholder-light",
    "unmapped-manual-nutrition-goals-light": "unmapped-plan-meal-placeholder-light",
}
for old_id, new_id in renames.items():
    item = screenshots.pop(old_id, screenshots.get(new_id))
    item["id"] = new_id
    item["group"] = "Unmapped Expressive Placeholder Screens"
    item["approvalClassification"] = "unmapped-placeholder"
    if "pantry" in new_id:
        item["state"] = "Pantry Log Page placeholder"
        item["navigationPath"] = "Dashboard → Pantry Log"
        item["png"] = "unmapped-expressive/placeholders/light/01-pantry-log-page.png"
        item["uiHierarchy"] = "unmapped-expressive/placeholders/light/01-pantry-log-page.xml"
    else:
        item["state"] = "Plan Meal placeholder; not a Manual Nutrition Goals editor"
        item["navigationPath"] = "Dashboard → Plan Meal"
        item["png"] = "unmapped-expressive/placeholders/light/02-plan-meal-placeholder.png"
        item["uiHierarchy"] = "unmapped-expressive/placeholders/light/02-plan-meal-placeholder.xml"
    screenshots[new_id] = item

# Correct previously conflated routes and add the lower views already captured.
row(
    "alternate-nutrition-todays-records-light",
    "Unmapped Expressive Nutrition Routes",
    "Today’s Records page, top and lower views",
    "light",
    "unmapped",
    "CAPTURED",
    "Enable Nutrition tab → Nutrition → Today’s Records",
    ["unmapped-todays-records-light-top", "unmapped-todays-records-light-lower"],
    "Empty local day; route has no recorded visual approval and is outside the verified 13-page B inventory.",
)
row(
    "alternate-nutrition-todays-records-dark",
    "Unmapped Expressive Nutrition Routes",
    "Today’s Records page, top and lower views",
    "dark",
    "unmapped",
    "CAPTURED",
    "Enable Nutrition tab → Nutrition → Today’s Records",
    ["unmapped-todays-records-dark-top", "unmapped-todays-records-dark-lower"],
    "Empty local day; route has no recorded visual approval and is outside the verified 13-page B inventory.",
)
row(
    "alternate-nutrition-manual-goals-light",
    "Unmapped Expressive Nutrition Routes",
    "Manual Nutrition Goals editor, top and lower views",
    "light",
    "unmapped",
    "CAPTURED",
    "Nutrition → Nutrition Goals → Manually Set Nutrition Goals",
    ["unmapped-manual-goals-light-top", "unmapped-manual-goals-light-lower"],
    "No fields changed or saved; route is outside the verified 13-page B inventory.",
)
row(
    "alternate-nutrition-manual-goals-dark",
    "Unmapped Expressive Nutrition Routes",
    "Manual Nutrition Goals editor, top and lower views",
    "dark",
    "unmapped",
    "CAPTURED",
    "Nutrition → Nutrition Goals → Manually Set Nutrition Goals",
    ["unmapped-manual-goals-dark-top", "unmapped-manual-goals-dark-lower"],
    "No fields changed or saved; route is outside the verified 13-page B inventory.",
)
row(
    "unmapped-plan-meal-placeholder-light",
    "Unmapped Expressive Placeholder Screens",
    "Plan Meal placeholder page",
    "light",
    "unmapped-placeholder",
    "CAPTURED",
    "Dashboard → Plan Meal",
    ["unmapped-plan-meal-placeholder-light"],
    "The destination exposes placeholder content, not an editable Manual Nutrition Goals screen.",
)
row(
    "unmapped-pantry-log-placeholder-light",
    "Unmapped Expressive Placeholder Screens",
    "Pantry Log placeholder page",
    "light",
    "unmapped-placeholder",
    "CAPTURED",
    "Dashboard → Pantry Log",
    ["unmapped-pantry-log-placeholder-light"],
    "The destination exposes a placeholder/empty page, not Today’s Records.",
)

# The correct Biceps light capture replaces the stale loading frame.
row(
    "03-muscle-biceps-top-light",
    "Selected Muscle Detail — Biceps Brachii",
    "Biceps detail hero, metrics and first exercise cards, top viewport",
    "light",
    "B",
    "CAPTURED",
    "Catalog → Target Anatomy → Muscles → select Biceps Brachii",
    ["03-muscle-biceps-light-top"],
)
coverage["02-bodypart-chest-lower-dark"]["screenshotIds"] = [
    "02-bodypart-chest-lower-dark-verified",
    "02-bodypart-chest-lower-dark-campaign-final",
]
coverage["02-bodypart-chest-lower-dark"]["reason"] = (
    "The retained associated-muscle view and newer lower exercise-list view are both linked."
)

# Existing detail-sheet tabs were captured but some were not linked in coverage.
row(
    "catalog-details-browser-light",
    "Catalog Exercise Details Sheet — Browser caller",
    "Details, Metrics and Records tabs",
    "light",
    "state-only",
    "CAPTURED",
    "Catalog → Exercise Catalog → exercise information",
    ["catalog-details-browser-light", "catalog-browser-metrics-light", "catalog-browser-records-light"],
)
row(
    "catalog-details-browser-dark",
    "Catalog Exercise Details Sheet — Browser caller",
    "Details, Metrics, Records and expanded Form Guide",
    "dark",
    "state-only",
    "CAPTURED",
    "Catalog → Exercise Catalog → exercise information",
    ["catalog-browser-detail-tab-dark", "catalog-browser-metrics-tab-dark-actual", "catalog-browser-records-tab-dark-actual", "catalog-browser-form-guide-expanded-dark-actual"],
)
for theme in ("light", "dark"):
    base = f"catalog-details-anatomy-{theme}"
    row(
        base,
        "Catalog Exercise Details Sheet — Anatomy caller",
        "Details, Metrics and Records tabs",
        theme,
        "state-only",
        "CAPTURED",
        "Catalog → Target Anatomy → selected detail → exercise information",
        [base, f"catalog-details-anatomy-metrics-{theme}", f"catalog-details-anatomy-records-{theme}"],
    )
row(
    "catalog-details-browser-form-guide-light",
    "Catalog Exercise Details Sheet — Browser caller",
    "Form Guide expanded",
    "light",
    "state-only",
    "CAPTURED",
    "Catalog → Exercise Catalog → exercise information → Form Guide",
    ["catalog-browser-form-guide-expanded-light-campaign-verified"],
)
row(
    "catalog-details-browser-form-guide-dark",
    "Catalog Exercise Details Sheet — Browser caller",
    "Form Guide expanded",
    "dark",
    "state-only",
    "CAPTURED",
    "Catalog → Exercise Catalog → exercise information → Form Guide",
    ["catalog-browser-form-guide-expanded-dark-actual"],
)

# Filter states: each row points at the exact current capture, not an adjacent menu.
filter_rows = [
    ("focus-area-menu", "Focus Area anchored menu", {"light": "01-browser-focus-menu-light", "dark": "01-browser-focus-area-menu-dark-campaign"}),
    ("specific-muscle-menu", "Specific Muscle anchored menu", {"light": "01-browser-muscle-menu-light", "dark": "01-browser-specific-muscle-menu-dark-campaign"}),
    ("selection", "Selected filter values before Apply", {"light": "01-browser-filter-selected-light", "dark": "01-browser-filter-selected-dark-campaign"}),
    ("applied-results", "Applied Biceps filter results", {"light": "01-browser-filter-applied-results-light", "dark": "01-browser-filter-applied-results-dark-campaign"}),
    ("reset-dialog", "Filter dialog after resetting to defaults", {"light": "01-browser-filter-reset-dialog-light", "dark": "01-browser-filter-reset-dialog-dark-campaign"}),
    ("reset-results", "Default populated results after reset", {"light": "01-browser-filter-reset-results-light", "dark": "01-browser-filter-reset-results-dark-campaign"}),
]
for suffix, state, ids in filter_rows:
    for theme in ("light", "dark"):
        capture_id = ids[theme]
        row(
            f"catalog-filter-{suffix}-{theme}",
            "Exercise Catalog Filters",
            state,
            theme,
            "state-only",
            "CAPTURED",
            "Catalog → Exercise Catalog → Filters",
            [capture_id],
            "Selection/filtering affected in-memory browser state only; no exercise or user records changed.",
        )
for theme, capture_id, status, reason in (
    ("light", "01-browser-filter-empty-light-campaign", "CAPTURED", "In-memory filters only; Reset filters restores the default list."),
    ("dark", "01-browser-filter-empty-dark-campaign", "CAPTURED", "In-memory filters only; Reset filters restores the default list."),
):
    row(
        f"catalog-filter-no-results-{theme}",
        "Exercise Catalog Filters",
        "No results after applying a filter combination",
        theme,
        "state-only",
        status,
        "Catalog → Exercise Catalog → Filters → apply a no-match combination",
        [capture_id] if capture_id else [],
        reason,
    )
row(
    "catalog-filter-contradictory-selection-dark",
    "Exercise Catalog Filters",
    "Contradictory Chest + Biceps filter selection before Apply",
    "dark",
    "state-only",
    "CAPTURED",
    "Catalog → Exercise Catalog → Filters",
    ["01-browser-filter-no-match-pending-dark"],
    "This is the selected filter dialog, not the resulting empty list.",
)

# Plan Management has inline Archive/Activate actions, not a row menu/delete flow.
for theme in ("light", "dark"):
    for kind, state in (("menu", "Plan action menu"), ("delete-confirm", "Delete confirmation")):
        row(
            f"04-plan-management-{kind}-{theme}",
            "Plan Management Actions",
            state,
            theme,
            "state-only",
            "NOT APPLICABLE",
            "Train → Plans → Manage plans",
            [],
            "Current Plan Management implementation exposes inline Archive/Activate actions; it has no plan overflow menu or delete confirmation.",
        )
    row(
        f"04-plan-management-empty-{theme}",
        "Plan Management",
        "No active or archived plans empty state",
        theme,
        "B",
        "BLOCKED",
        "Train → Plans → Manage plans",
        [],
        "The retained preview contains plans. Emptying it would require persistent deletes or replacing the protected preview data.",
    )
    row(
        f"04-plan-management-restore-{theme}",
        "Plan Management Actions",
        "Restore plan action",
        theme,
        "state-only",
        "NOT APPLICABLE",
        "Train → Plans → Manage plans",
        [],
        "No restore action exists on this page; current rows expose Archive or Activate.",
    )

# Premade Plans uses a profile-equipment toggle, not an equipment selector menu.
for theme, top_id, duration_id, equipment_id, preview_id in (
    ("light", "05-premade-top-light", "05-premade-duration-two-hour-light-settled-campaign", "05-premade-equipment-filter-off-light-settled-campaign", "05-premade-plan-previews-light-campaign"),
    ("dark", "05-premade-top-dark-verified", "05-premade-two-hour-dark-verified", "05-premade-profile-equipment-filter-off-dark", "05-premade-plan-previews-dark"),
):
    top_row = coverage[f"05-premade-top-{theme}"]
    top_row["screenshotIds"] = [top_id]
    top_row["status"] = "CAPTURED"
    expanded = coverage[f"05-premade-expanded-{theme}"]
    expanded["screenshotIds"] = [preview_id]
    expanded["status"] = "CAPTURED"
    expanded["state"] = "Homemade Full Body category expanded with plan preview cards"
    row(
        f"premade-duration-two-hour-{theme}",
        "Premade Plans",
        "Two-hour duration selection and filtered previews",
        theme,
        "B",
        "CAPTURED",
        "Train → Plans → Browse Premade Plans → choose 2 hr",
        [duration_id],
        "Duration is a reversible in-page filter; no plan was added.",
    )
    row(
        f"premade-profile-equipment-off-{theme}",
        "Premade Plans",
        "Filter for profile equipment switched off",
        theme,
        "B",
        "CAPTURED",
        "Train → Plans → Browse Premade Plans → Filter for profile equipment off",
        [equipment_id],
        "Reversible filter state; no plan was added.",
    )
    row(
        f"premade-plan-previews-{theme}",
        "Premade Plans",
        "Expanded Homemade Full Body plan previews and Add actions",
        theme,
        "B",
        "CAPTURED",
        "Train → Plans → Browse Premade Plans → Homemade → Full Body",
        [preview_id],
        "Add actions were not activated to preserve retained plans.",
    )
    row(
        f"05-premade-equipment-menu-{theme}",
        "Premade Plan Filters",
        "Equipment selection menu",
        theme,
        "state-only",
        "NOT APPLICABLE",
        "Train → Plans → Browse Premade Plans",
        [],
        "The page has a Filter for profile equipment switch. Equipment is derived from the selected gym profile; there is no equipment selector menu.",
    )
for theme in ("light", "dark"):
    row(
        f"premade-empty-state-{theme}",
        "Premade Plans",
        "Empty or no-match plan list state",
        theme,
        "B",
        "MISSING",
        "Train → Plans → Browse Premade Plans",
        [],
        "No verified empty-list screenshot was captured; filters were kept in a useful populated state and no plans were added or removed.",
    )

# Preset detail actions and non-Catalog exercise detail callers.
for theme in ("light", "dark"):
    row(
        f"preset-delete-confirm-{theme}",
        "Preset Detail Actions",
        "Delete preset confirmation; canceled",
        theme,
        "state-only",
        "CAPTURED",
        "Train → Overview → select active plan → menu → Delete Preset",
        [f"preset-delete-confirm-{theme}-campaign"],
        "Confirmation was canceled; preset retained.",
    )
    row(
        f"preset-add-exercise-picker-{theme}",
        "Preset Detail Actions",
        "Add Exercise picker open; no exercise selected",
        theme,
        "state-only",
        "CAPTURED",
        "Train → Overview → select plan → Edit → Add exercise",
        [f"preset-add-exercise-picker-{theme}"],
        "Picker was closed without adding an exercise; edit draft was discarded.",
    )
    for tab, state, suffix in (
        ("details", "Details tab", "details"),
        ("metrics", "Metrics tab", "metrics"),
        ("records", "Records tab", "records"),
    ):
        capture_id = f"noncatalog-plan-exercise-{suffix}-{theme}"
        row(
            f"noncatalog-exercise-{suffix}-{theme}",
            "Non-Catalog Exercise Details — Plan Detail caller",
            state,
            theme,
            "state-only",
            "CAPTURED",
            "Train → Overview → plan exercise → exercise information",
            [capture_id],
            "Read-only sheet; values reflect the retained preview data.",
        )
    for kind, state, capture_suffix in (
        ("menu", "Archived plan card action menu", "menu"),
        ("delete-confirm", "Archived plan delete confirmation; canceled", "delete-confirm"),
    ):
        row(
            f"train-plan-card-{kind}-{theme}",
            "Train Plans Card Actions",
            state,
            theme,
            "state-only",
            "CAPTURED",
            "Train → Plans → archived plan card → actions",
            [f"plan-card-{capture_suffix}-{theme}-campaign"],
            "Delete confirmation was canceled; no plan was deleted.",
        )

# Flow Methods Add Rule menus are available; editing an existing rule is not safe/reachable.
for theme in ("light", "dark"):
    row(
        f"flow-methods-rule-type-menu-{theme}",
        "Plan-Specific Flow Methods Editor",
        "Add Rule dialog, anchored Rule type menu",
        theme,
        "state-only",
        "CAPTURED",
        "Profile → Training → Gym & Workout Settings → Workout Progress Rules → plan → Add Rule",
        [f"13-flow-methods-type-menu-{theme}"],
        "Menu closed without changing a rule.",
    )
    row(
        f"flow-methods-operation-menu-{theme}",
        "Plan-Specific Flow Methods Editor",
        "Add Rule dialog, anchored Operation menu",
        theme,
        "state-only",
        "CAPTURED",
        "Profile → Training → Gym & Workout Settings → Workout Progress Rules → plan → Add Rule",
        [f"13-flow-methods-operation-menu-{theme}"],
        "Menu closed without changing a rule.",
    )
    row(
        f"13-flow-methods-edit-{theme}",
        "Plan-Specific Flow Methods Editor",
        "Edit an existing plan rule and its menus",
        theme,
        "B",
        "BLOCKED",
        "Profile → Training → Gym & Workout Settings → Workout Progress Rules → plan rule → Edit",
        [],
        "No existing plan rule is present in the retained data. Creating and saving a rule only to enable editing would mutate protected preview state.",
    )

# Source-verified interaction differences or previously approved combinations.
for theme in ("light", "dark"):
    row(
        f"dashboard-restore-confirm-{theme}",
        "Dashboard Configuration",
        "Restore defaults confirmation dialog",
        theme,
        "state-only",
        "NOT APPLICABLE",
        "Dashboard → Restore defaults",
        [],
        "Current action calls DashboardConfig.restoreDefaults() immediately; no confirmation dialog is implemented. It was not activated because it persists configuration.",
    )
    row(
        f"measurement-library-alternate-caller-{theme}",
        "Measurement Library Alternate Callers",
        "Nutrition/Dashboard caller-specific presentation",
        theme,
        "state-only",
        "NOT APPLICABLE",
        "Nutrition or Dashboard → Measurements / Measurement Library",
        [],
        "Source call sites instantiate the same MeasuredItemsPage widget; no distinct caller-specific presentation branch was found. The Profile route is already separately approved.",
    )
    row(
        f"workout-session-unapproved-overlays-{theme}",
        "Workout and Session Overlays",
        "Additional unapproved workout/session overlay combinations",
        theme,
        "state-only",
        "NOT APPLICABLE",
        "Train → Active Workout / Logbook → Session Detail",
        [],
        "The applicable current workout and session overlay combinations are already covered by prior visual approvals; this campaign did not duplicate those approved states.",
    )
    row(
        f"09-onboarding-welcome-{theme}",
        "Onboarding",
        "Welcome step and first-run actions",
        theme,
        "B",
        "BLOCKED",
        "Profile → UI & Appearance → Replay Onboarding",
        [],
        "Installed isolated preview entrypoint bypasses first-run onboarding. Replaying would affect persisted onboarding/profile preferences, so it was not triggered against retained data.",
    )
    row(
        f"09-onboarding-selection-{theme}",
        "Onboarding",
        "Gym/equipment selection step",
        theme,
        "B",
        "BLOCKED",
        "Profile → UI & Appearance → Replay Onboarding → selection step",
        [],
        "The installed isolated preview entrypoint bypasses first-run onboarding. Replaying would affect persisted onboarding/profile preferences, so it was not triggered against retained data.",
    )
for theme in ("light", "dark"):
    coverage.pop(f"onboarding-welcome-{theme}", None)

# Update top-level order with the final reconciled records.
data["screenshots"] = list(screenshots.values())
data["coverage"] = list(coverage.values())
MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Reconciled {len(data['screenshots'])} screenshots and {len(data['coverage'])} coverage rows.")
