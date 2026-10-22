"""Build a local HTML review gallery and SVG contact sheets from the manifest.

This intentionally uses only Python's standard library. Run from any directory:
    python tools/generate_gallery.py
"""
from __future__ import annotations

import html
import csv
import json
import pathlib
import re
import xml.etree.ElementTree as ET
from collections import defaultdict
from collections import Counter
from urllib.parse import quote

CAMPAIGN = pathlib.Path(__file__).resolve().parents[1]
MANIFEST = CAMPAIGN / "screenshot-manifest.json"
GALLERY = CAMPAIGN / "REVIEW_GALLERY.html"
CONTACT_DIR = CAMPAIGN / "contact-sheets"
COVERAGE_CSV = CAMPAIGN / "coverage-matrix.csv"

# Exclude approved routes/states and obsolete caller-specific detail captures.
# All Expressive detail callers now resolve to the approved shared sheet.
# The screenshot manifest and local PNG/XML evidence remain preserved.
APPROVED_REVIEW_GROUPS = {
    "nutrition goals",
    "nutrition goals and records",
    "onboarding",
    "dashboard",
    "dashboard configuration",
    "train2",
    "train2 / exercise presets",
    "exercise catalog / exercise browser",
    "exercise catalog filters",
    "analytics dashboard / weekly sets",
    "custom plan generation / preset generation qa",
    "gym profile / equipment",
    "optimized workout settings",
    "health trend entry actions",
    "plan management",
    "plan management actions",
    "train plans card actions",
    "premade plans",
    "premade plan filters",
    "plan-specific flow methods editor",
    "preset / plan detail",
    "preset detail overlays",
    "preset detail actions",
    "plan/preset detail — swap exercise sheet",
    "today's records",
    "today’s records",
    "calendar records",
}

# Closed for this review pass by the user: no implemented content to adapt.
# These remain F placeholders, not A-approved finished pages.
DEFERRED_REVIEW_GROUPS = {"unmapped expressive placeholder screens"}

# Preserve these Premade Plans captures in the manifest and evidence archive,
# but omit stale or duplicate cards from the active review gallery.
EXCLUDED_SCREENSHOT_IDS = {
    "05-premade-top-dark",
    "05-premade-expanded-dark",
    "05-premade-two-hour-dark",
    "05-premade-duration-two-hour-light-campaign",
    "05-premade-equipment-filter-off-light-campaign",
    "05-premade-expanded-light",
    "05-premade-two-hour-dark-second-check",
    # These ten nutrition screenshots were replaced by the current 2026-10-20
    # captures; keep the original records and source files in the archive.
    "unmapped-todays-records-light-top",
    "unmapped-todays-records-light-lower",
    "unmapped-todays-records-dark-top",
    "unmapped-todays-records-dark-lower",
    "unmapped-nutrition-settings-light",
    "unmapped-nutrition-settings-dark",
    "unmapped-manual-goals-light-top",
    "unmapped-manual-goals-light-lower",
    "unmapped-manual-goals-dark-top",
    "unmapped-manual-goals-dark-lower",
}


def excluded_from_unapproved_gallery(item: dict) -> bool:
    if item.get("id") in EXCLUDED_SCREENSHOT_IDS:
        return True
    # Preserve the historical Today's Records aliases in the archive filter.
    if str(item.get("id", "")).startswith((
        "nutrition-todays-records-",
        "unmapped-todays-records-",
        "alternate-nutrition-todays-records-",
    )):
        return True
    group = group_of(item).strip().casefold()
    if group in APPROVED_REVIEW_GROUPS or group in DEFERRED_REVIEW_GROUPS:
        return True
    if group.startswith("train plans") and "archived plan actions" in group:
        return True
    # Older manifest records contain both correctly encoded and mojibake dash
    # variants, so match approved detail groups by their stable name prefix.
    return group.startswith((
        "catalog exercise details sheet",
        "non-catalog exercise details",
        "exercise media viewer",
        "selected bodypart detail",
        "selected muscle detail",
    ))


def value(item: dict, *keys: str, default: str = "Not recorded") -> str:
    for key in keys:
        found = item.get(key)
        if found is not None and str(found).strip():
            return str(found)
    return default


def safe_file(relative: object) -> pathlib.Path | None:
    """Resolve a manifest path only when it stays within this campaign folder."""
    if not relative:
        return None
    candidate = (CAMPAIGN / pathlib.Path(str(relative).replace("\\", "/"))).resolve()
    try:
        candidate.relative_to(CAMPAIGN.resolve())
    except ValueError:
        return None
    return candidate if candidate.is_file() else None


def relative_href(base: pathlib.Path, target: pathlib.Path | None) -> str | None:
    if target is None:
        return None
    import os
    return quote(pathlib.Path(os.path.relpath(target, base)).as_posix(), safe="/.-_~")


def slug(raw: str) -> str:
    result = re.sub(r"[^a-zA-Z0-9_-]+", "-", raw.strip().lower()).strip("-")
    return result[:72] or "ungrouped"


def group_of(record: dict) -> str:
    group = value(record, "group", "page", "route", default="Unmapped")
    # The active group now contains only the two goals pages. Keep the original
    # capture-time group name unchanged in the source manifest.
    return "Nutrition Goals" if group == "Nutrition Goals and Records" else group


def theme_of(record: dict) -> str:
    return value(record, "theme", default="unspecified").lower()


def state_of(record: dict) -> str:
    return value(record, "state", "name", "id", default="Unspecified state")


def coverage_status(item: dict) -> str:
    raw = value(item, "status", "result", "coverageStatus", default="").lower()
    if any(term in raw for term in ("blocked", "unavailable", "deferred", "not captured", "missing")):
        return raw
    return raw or "listed"


def list_value(item: dict, *keys: str) -> list[str]:
    for key in keys:
        raw = item.get(key)
        if raw is None:
            continue
        if isinstance(raw, (list, tuple, set)):
            return [str(entry) for entry in raw if entry is not None]
        return [str(raw)]
    return []


def coverage_matrix_rows(coverage: list[dict], screenshots: list[dict]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for item in coverage:
        if not isinstance(item, dict):
            item = {"name": str(item)}
        screenshot_ids = list_value(item, "screenshotIds", "screenshot_ids", "screenshotId")
        screenshot_ids += [
            str(entry.get("id"))
            for entry in item.get("screenshots", [])
            if isinstance(entry, dict) and entry.get("id")
        ]

        # If a coverage entry does not name captures directly, associate exact id or
        # page/state/theme matches. Keep the resulting IDs explicit in the CSV.
        if not screenshot_ids:
            target_id = value(item, "id", "coverageId", default="")
            target_group = value(item, "group", "page", "name", default="")
            target_state = value(item, "state", default="")
            target_theme = value(item, "theme", default="")
            for capture in screenshots:
                exact_id = bool(target_id and target_id == str(capture.get("id", "")))
                same_group = bool(target_group and target_group == group_of(capture))
                same_state = not target_state or target_state == state_of(capture)
                same_theme = not target_theme or target_theme.lower() == theme_of(capture)
                if exact_id or (same_group and same_state and same_theme):
                    capture_id = capture.get("id")
                    if capture_id:
                        screenshot_ids.append(str(capture_id))

        rows.append({
            "id": value(item, "id", "coverageId", default=""),
            "group": value(item, "group", "page", "name", "route", default=""),
            "state": value(item, "state", default=""),
            "theme": value(item, "theme", default=""),
            "classification": value(item, "approvalClassification", "classification", default=""),
            "status": coverage_status(item),
            "screenshot IDs": "; ".join(dict.fromkeys(screenshot_ids)),
            "navigationPath": value(item, "navigationPath", "route", "path", default=""),
            "reason/notes": value(item, "reason", "notes", "limitations", default=""),
        })
    return rows


def write_coverage_matrix(coverage: list[dict], screenshots: list[dict]) -> int:
    fields = (
        "id", "group", "state", "theme", "classification", "status",
        "screenshot IDs", "navigationPath", "reason/notes",
    )
    rows = coverage_matrix_rows(coverage, screenshots)
    with COVERAGE_CSV.open("w", newline="", encoding="utf-8") as output:
        writer = csv.DictWriter(output, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    return len(rows)


def render_gallery(manifest: dict, records: list[dict], coverage: list[dict]) -> str:
    grouped: dict[str, list[dict]] = defaultdict(list)
    for record in records:
        grouped[group_of(record)].append(record)
    coverage_by_group: dict[str, list[dict]] = defaultdict(list)
    for item in coverage:
        if isinstance(item, dict):
            coverage_by_group[value(item, "group", "page", "name", default="Unmapped")].append(item)

    sections: list[str] = []
    for group, items in sorted(grouped.items(), key=lambda pair: pair[0].casefold()):
        group_coverage = coverage_by_group.get(group, [])
        status_counts = Counter(coverage_status(item).upper() for item in group_coverage)
        summary = (
            " · ".join(f"{status.lower()}: {count}" for status, count in sorted(status_counts.items()))
            if status_counts else "Coverage rows are recorded under related interaction groups."
        )
        cards: list[str] = []
        for item in sorted(items, key=lambda r: (state_of(r).casefold(), theme_of(r))):
            image = safe_file(item.get("png"))
            hierarchy = safe_file(item.get("uiHierarchy"))
            image_href = relative_href(CAMPAIGN, image)
            classification = value(item, "approvalClassification")
            verified = "verified" if item.get("verified") is True else "verification not recorded"
            fresh = "fresh capture" if item.get("fresh") is True else "freshness not confirmed"
            if image_href:
                visual = (
                    f'<a class="image-link" href="{html.escape(image_href, quote=True)}" target="_blank">'
                    f'<img loading="lazy" src="{html.escape(image_href, quote=True)}" '
                    f'alt="{html.escape(group + " — " + state_of(item), quote=True)}"></a>'
                )
            else:
                visual = '<div class="placeholder">Screenshot missing</div>'
            hierarchy_href = relative_href(CAMPAIGN, hierarchy)
            hierarchy_link = (
                f'<a href="{html.escape(hierarchy_href, quote=True)}">UI hierarchy</a>'
                if hierarchy_href else '<span class="muted">UI hierarchy missing</span>'
            )
            cards.append(
                '<article class="shot">'
                f'<h3>{html.escape(state_of(item))}</h3>'
                f'<p class="meta"><b>{html.escape(theme_of(item).upper())}</b> · '
                f'{html.escape(classification)} · {html.escape(fresh)} · {html.escape(verified)}</p>'
                f'{visual}'
                f'<p class="route"><b>Path:</b> {html.escape(value(item, "navigationPath"))}</p>'
                f'<p><b>Captured:</b> {html.escape(value(item, "capturedAt"))} · {hierarchy_link}</p>'
                f'<p><b>Source:</b> {html.escape(value(item, "sourceRevision"))}; '
                f'{html.escape(value(item, "package"))} on {html.escape(value(item, "deviceId"))}</p>'
                f'<p><b>Limitations:</b> {html.escape(value(item, "limitations", default="None recorded"))}</p>'
                '</article>'
            )
        sections.append(
            f'<section id="{html.escape(slug(group), quote=True)}"><h2>{html.escape(group)} '
            f'<span class="section-count">({len(items)} screenshots)</span></h2>'
            f'<p class="group-summary">Coverage: {html.escape(summary)}</p>'
            f'<div class="shots">{"".join(cards)}</div></section>'
        )

    coverage_rows: list[str] = []
    for item in coverage:
        if not isinstance(item, dict):
            coverage_rows.append(
                f'<li class="coverage-item"><b>{html.escape(str(item))}</b> — status not structured</li>'
            )
            continue
        label = value(item, "group", "page", "name", "id", default="Unnamed coverage item")
        route = item.get("navigationPath") or item.get("route") or item.get("path")
        detail = item.get("reason") or item.get("notes") or item.get("limitations")
        route_html = f'<div>{html.escape(str(route))}</div>' if route else ""
        detail_html = f'<div class="muted">{html.escape(str(detail))}</div>' if detail else ""
        coverage_rows.append(
            f'<li class="coverage-item"><b>{html.escape(label)}</b> '
            f'<span class="badge">{html.escape(coverage_status(item))}</span>'
            f'{route_html}{detail_html}</li>'
        )
    if not coverage_rows:
        coverage_rows.append(
            "<li>No missing or blocked coverage entries are currently recorded in the manifest.</li>"
        )

    toc = "".join(
        f'<a href="#{html.escape(slug(group), quote=True)}">{html.escape(group)}</a>'
        for group in sorted(grouped, key=str.casefold)
    ) or '<span class="muted">No pending page screenshots.</span>'
    if not sections:
        sections.append(
            '<section class="coverage-panel" id="page-review-complete">'
            '<h2>No pending page screenshots</h2>'
            '<p>Approved page screenshots remain archived. Current page approval status and '
            'shared/caller-specific interaction reviews are recorded in '
            '<a href="navigation-index.md#related-shared-states">the navigation index</a>.</p><p>'
            'This does not establish technical or release qualification.</p></section>'
        )
    campaign = manifest.get("campaign") or {}
    metadata = " · ".join(
        f"{html.escape(str(key))}: {html.escape(str(val))}" for key, val in campaign.items()
    ) or "Campaign provenance is not yet recorded."
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tonos Expressive — Visual Review Gallery</title>
<style>
:root{{--color-scheme:light dark;--bg:#f6f1f8;--surface:#fff;--ink:#251b2d;--muted:#685e70;--accent:#53237a;--line:#d9cfe0;--warn:#8a4b00}}
@media(prefers-color-scheme:dark){{:root{{--bg:#18131d;--surface:#28202f;--ink:#f3eafa;--muted:#c0b2ca;--accent:#d2a9ef;--line:#4c3c58;--warn:#ffc278}}}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font:16px/1.5 system-ui,sans-serif}}main{{max-width:1440px;margin:auto;padding:24px}}
header{{padding:24px;border-radius:24px 40px 24px 40px;background:var(--accent);color:#fff}}header p{{margin:.5rem 0 0}}h1{{margin:0;font-size:clamp(1.7rem,4vw,2.5rem)}}
h2{{margin:34px 0 14px;padding-left:12px;border-left:5px solid var(--accent)}}h3{{margin:0 0 4px;font-size:1.1rem}}
nav{{display:flex;gap:8px;flex-wrap:wrap;margin:18px 0}}nav a{{padding:7px 12px;border-radius:999px;background:var(--surface);color:var(--ink);border:1px solid var(--line);text-decoration:none}}
.shots{{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,420px),1fr));gap:16px}}.shot,.coverage-panel{{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:16px;min-width:0}}
.image-link{{display:block}}img{{display:block;width:100%;height:auto;max-height:780px;object-fit:contain;background:#100d13;border-radius:12px}}.meta,.muted{{color:var(--muted)}}.meta{{margin:4px 0 10px}}
.route{{overflow-wrap:anywhere}}.placeholder{{min-height:250px;display:grid;place-items:center;border:1px dashed var(--line);border-radius:12px;color:var(--muted)}}
.badge{{display:inline-block;margin-left:8px;padding:1px 8px;border-radius:999px;border:1px solid var(--line);color:var(--warn);font-size:.85em}}.coverage-panel li{{margin:10px 0}}
.section-count,.group-summary{{color:var(--muted);font-size:.88rem;font-weight:400}}.group-summary{{margin:-8px 0 12px 18px}}
.footer{{color:var(--muted);font-size:.9rem;margin-top:24px}}a{{color:var(--accent)}}
</style></head><body><main>
<header><h1>Tonos Expressive — visual review evidence</h1>
<p>Evidence gallery only. This document does not grant visual approval or technical qualification.</p><p>{metadata}</p></header>
<nav aria-label="Screenshots by page">{toc}</nav>
{"".join(sections)}
<section class="coverage-panel"><h2>Missing, blocked, or deferred coverage</h2><ul>{"".join(coverage_rows)}</ul></section>
<p class="footer">Manifest records: {len(records)} screenshots · {len(coverage)} coverage notes. Images and hierarchies are linked as local files.</p>
</main></body></html>"""


def svg_contact_sheet(group: str, records: list[dict]) -> str:
    width, col_width, thumb_height, label_height = 960, 460, 590, 190
    rows = max(1, (len(records) + 1) // 2)
    height = 74 + rows * (thumb_height + label_height + 18)
    root = ET.Element("svg", {
        "xmlns": "http://www.w3.org/2000/svg", "width": str(width), "height": str(height),
        "viewBox": f"0 0 {width} {height}",
    })
    ET.SubElement(root, "rect", {"width": "100%", "height": "100%", "fill": "#f6f1f8"})

    def add_text(x: int, y: int, content: str, size: int = 18,
                 color: str = "#251b2d", weight: str = "normal") -> None:
        node = ET.SubElement(root, "text", {
            "x": str(x), "y": str(y), "font-family": "system-ui,sans-serif",
            "font-size": str(size), "font-weight": weight, "fill": color,
        })
        node.text = content

    add_text(24, 42, group, 25, "#53237a", "bold")
    for index, record in enumerate(records):
        row, col = divmod(index, 2)
        x, y = 18 + col * (col_width + 10), 58 + row * (thumb_height + label_height + 18)
        ET.SubElement(root, "rect", {
            "x": str(x), "y": str(y), "width": str(col_width),
            "height": str(thumb_height + label_height), "rx": "18", "fill": "#ffffff", "stroke": "#d9cfe0",
        })
        add_text(x + 14, y + 28, f"{theme_of(record).upper()} · {state_of(record)}"[:100], 16, "#53237a", "bold")
        image = safe_file(record.get("png"))
        if image:
            href = relative_href(CONTACT_DIR, image) or ""
            anchor = ET.SubElement(root, "a", {"href": href, "target": "_blank"})
            ET.SubElement(anchor, "image", {
                "x": str(x + 12), "y": str(y + 42), "width": str(col_width - 24),
                "height": str(thumb_height - 48), "preserveAspectRatio": "xMidYMid meet", "href": href,
            })
        else:
            ET.SubElement(root, "rect", {
                "x": str(x + 12), "y": str(y + 42), "width": str(col_width - 24),
                "height": str(thumb_height - 48), "rx": "10", "fill": "#e7e0eb",
            })
            add_text(x + 145, y + thumb_height // 2, "Screenshot missing", 18, "#685e70")
        details = (
            f"Path: {value(record, 'navigationPath')}",
            f"Class: {value(record, 'approvalClassification')} | Fresh: {record.get('fresh', 'unknown')} | Verified: {record.get('verified', 'unknown')}",
            f"Captured: {value(record, 'capturedAt')}",
            f"Limitations: {value(record, 'limitations', default='None recorded')}",
        )
        for line_no, line in enumerate(details):
            add_text(x + 14, y + thumb_height + 22 + line_no * 24, line[:112], 13, "#554b5e")
    return ET.tostring(root, encoding="unicode", xml_declaration=True)


def main() -> None:
    if not MANIFEST.is_file():
        raise SystemExit(f"Manifest not found: {MANIFEST}")
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    records = manifest.get("screenshots") or []
    coverage = manifest.get("coverage") or []
    if not isinstance(records, list) or not isinstance(coverage, list):
        raise SystemExit("Manifest screenshots and coverage entries must be arrays.")
    records = [
        record
        for record in records
        if isinstance(record, dict) and not excluded_from_unapproved_gallery(record)
    ]
    coverage = [
        item
        for item in coverage
        if not isinstance(item, dict) or not excluded_from_unapproved_gallery(item)
    ]
    grouped: dict[str, list[dict]] = defaultdict(list)
    for record in records:
        grouped[group_of(record)].append(record)

    CONTACT_DIR.mkdir(parents=True, exist_ok=True)
    # Remove generated sheets for approved, superseded, or deferred review groups.
    # Keep the original PNG/XML captures and manifest entries as local evidence.
    excluded_contact_sheets = {
        "nutrition-goals.svg",
        "onboarding.svg",
        "dashboard.svg",
        "dashboard-configuration.svg",
        "train2.svg",
        "train2-exercise-presets.svg",
        "analytics-dashboard-weekly-sets.svg",
        "custom-plan-generation-preset-generation-qa.svg",
        "gym-profile-equipment.svg",
        "optimized-workout-settings.svg",
        "plan-management.svg",
        "plan-management-actions.svg",
        "premade-plans.svg",
        "premade-plan-filters.svg",
        "plan-specific-flow-methods-editor.svg",
        "train-plans-archived-plan-actions.svg",
        "health-trend-entry-actions.svg",
        "exercise-catalog-exercise-browser.svg",
        "exercise-catalog-filters.svg",
        "catalog-exercise-details-sheet-browser-caller.svg",
        "exercise-media-viewer-catalog-caller.svg",
        "catalog-exercise-details-sheet-anatomy-caller.svg",
        "non-catalog-exercise-details-plan-detail-caller.svg",
        "selected-bodypart-detail-chest.svg",
        "selected-muscle-detail-adductor-brevis.svg",
        "selected-muscle-detail-biceps-brachii.svg",
        "selected-muscle-detail-biceps.svg",
        "unmapped-expressive-placeholder-screens.svg",
        "preset-plan-detail.svg",
        "preset-detail-overlays.svg",
        "preset-detail-actions.svg",
        "plan-preset-detail-swap-exercise-sheet.svg",
        "unmapped-expressive-nutrition-routes.svg",
        "nutrition-goals-and-records.svg",
    }
    for filename in excluded_contact_sheets:
        (CONTACT_DIR / filename).unlink(missing_ok=True)
    GALLERY.write_text(render_gallery(manifest, records, coverage), encoding="utf-8")
    matrix_count = write_coverage_matrix(coverage, records)
    (CONTACT_DIR / "overview.svg").unlink(missing_ok=True)
    if not grouped:
        (CONTACT_DIR / "overview.svg").write_text(
            svg_contact_sheet("No pending page screenshots", []), encoding="utf-8"
        )
    else:
        for group, items in grouped.items():
            (CONTACT_DIR / f"{slug(group)}.svg").write_text(
                svg_contact_sheet(group, items), encoding="utf-8"
            )

    # Verify local HTML and XML output, and preserve explicit missing-state display.
    gallery = GALLERY.read_text(encoding="utf-8")
    if "Missing, blocked, or deferred coverage" not in gallery:
        raise SystemExit("Gallery validation failed: coverage section missing.")
    sheets = sorted(CONTACT_DIR.glob("*.svg"))
    if not sheets:
        raise SystemExit("Gallery validation failed: no SVG contact sheets generated.")
    for sheet in sheets:
        ET.parse(sheet)
    with COVERAGE_CSV.open("r", newline="", encoding="utf-8") as matrix_file:
        reader = csv.DictReader(matrix_file)
        matrix_fields = set(reader.fieldnames or [])
        matrix = list(reader)
    if len(matrix) != matrix_count:
        raise SystemExit("Coverage matrix validation failed: row count mismatch.")
    expected_fields = {
        "id", "group", "state", "theme", "classification", "status",
        "screenshot IDs", "navigationPath", "reason/notes",
    }
    if not expected_fields.issubset(matrix_fields):
        raise SystemExit("Coverage matrix validation failed: required columns missing.")
    theme_counts = Counter(theme_of(record) for record in records)
    print(f"Generated {GALLERY.relative_to(CAMPAIGN)} ({len(records)} screenshots: {theme_counts['light']} light, {theme_counts['dark']} dark; {len(coverage)} coverage notes)")
    print(f"Generated {len(sheets)} valid SVG contact sheet(s) in {CONTACT_DIR.relative_to(CAMPAIGN)}")
    print(f"Generated {COVERAGE_CSV.relative_to(CAMPAIGN)} ({matrix_count} coverage rows)")


if __name__ == "__main__":
    main()
