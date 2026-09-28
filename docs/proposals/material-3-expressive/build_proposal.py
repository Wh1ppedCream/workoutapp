"""Generate the static Tonos Material 3 Expressive visual proposal.

The SVGs are documentation artwork. They are deliberately separate from the
Flutter app and use only production-source-backed screen structure.
"""

from __future__ import annotations

import base64
from html import escape
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent


class Scheme:
    def __init__(self, dark: bool):
        self.dark = dark
        if dark:
            self.bg = "#101514"
            self.surface = "#171E1D"
            self.low = "#1B2322"
            self.container = "#222B29"
            self.high = "#2B3532"
            self.highest = "#35403D"
            self.text = "#E1E8E5"
            self.sub = "#BAC7C2"
            self.muted = "#8F9C97"
            self.outline = "#46524E"
            self.primary = "#62D8CA"
            self.on_primary = "#003731"
            self.primary_container = "#00534C"
            self.on_primary_container = "#A8F2E9"
            self.secondary = "#B4CEC7"
            self.secondary_container = "#304A44"
            self.on_secondary_container = "#D0E9E2"
            self.tertiary = "#C9C0E2"
            self.tertiary_container = "#4A4561"
            self.error = "#FFB4AB"
            self.success = "#A6D8BD"
            self.success_container = "#203D31"
            self.purple = "#BB86FC"
            self.secondary_series = "#42A5F5"
            self.heat_low = "#A1A1A1"
            self.heat_high = "#1565C0"
            self.plan = "#E2A35C"
        else:
            self.bg = "#F3F6F4"
            self.surface = "#FAFCFA"
            self.low = "#EEF3F0"
            self.container = "#E7EEEA"
            self.high = "#DCE6E1"
            self.highest = "#D2DED8"
            self.text = "#191E1C"
            self.sub = "#414A46"
            self.muted = "#69746F"
            self.outline = "#AEBAB4"
            self.primary = "#006B62"
            self.on_primary = "#FFFFFF"
            self.primary_container = "#B8F0E7"
            self.on_primary_container = "#00201C"
            self.secondary = "#49645E"
            self.secondary_container = "#CCE8E1"
            self.on_secondary_container = "#102F29"
            self.tertiary = "#625C7B"
            self.tertiary_container = "#E8DDF8"
            self.error = "#BA1A1A"
            self.success = "#2D7156"
            self.success_container = "#C9EBD8"
            self.purple = "#6200EE"
            self.secondary_series = "#1E88E5"
            self.heat_low = "#9E9E9E"
            self.heat_high = "#1565C0"
            self.plan = "#9A5C21"


class Svg:
    def __init__(self):
        self.parts: list[str] = []

    def add(self, value: str):
        self.parts.append(value)

    def rect(self, x, y, w, h, fill, r=0, stroke=None, sw=1, opacity=None):
        attrs = f'x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" rx="{r}"'
        if stroke:
            attrs += f' stroke="{stroke}" stroke-width="{sw}"'
        if opacity is not None:
            attrs += f' opacity="{opacity}"'
        self.add(f"<rect {attrs}/>")

    def line(self, x1, y1, x2, y2, color, sw=1, opacity=1):
        self.add(
            f'<path d="M{x1} {y1} L{x2} {y2}" fill="none" stroke="{color}" '
            f'stroke-width="{sw}" opacity="{opacity}" stroke-linecap="round"/>'
        )

    def circle(self, cx, cy, r, fill, stroke=None, sw=1):
        attrs = f'cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"'
        if stroke:
            attrs += f' stroke="{stroke}" stroke-width="{sw}"'
        self.add(f"<circle {attrs}/>")

    def text(self, x, y, label, size, fill, weight=400, anchor="start", spacing=0):
        self.add(
            f'<text x="{x}" y="{y}" font-family="sans-serif" '
            f'font-size="{size}" font-weight="{weight}" fill="{fill}" text-anchor="{anchor}" '
            f'letter-spacing="{spacing}">{escape(str(label))}</text>'
        )

    def path(self, d, fill, stroke=None, sw=1, opacity=1):
        attrs = f'd="{d}" fill="{fill}" opacity="{opacity}"'
        if stroke:
            attrs += f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"'
        self.add(f"<path {attrs}/>")

    def icon(self, name, x, y, color, size=22, filled=False):
        paths = {
            "home": "M3 10.5 12 3l9 7.5M5.5 9.5V21h13V9.5M9 21v-6h6v6",
            "catalog": "M4 5c3-1.5 6-1.1 8 1v14c-2-2.1-5-2.5-8-1V5Zm16 0c-3-1.5-6-1.1-8 1v14c2-2.1 5-2.5 8-1V5Z",
            "trend": "M3 17l6-6 4 4 8-9M15 6h6v6",
            "school": "M2 9l10-5 10 5-10 5L2 9Zm4 2.5V16c3.4 2.8 8.6 2.8 12 0v-4.5M22 9v6",
            "history": "M3.5 12a8.5 8.5 0 1 0 2.5-6M3 4v5h5M12 7v5l3.2 2",
            "chart": "M4 19V5M4 19h17M8 16v-4M13 16V8M18 16V5",
            "person": "M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4 21c.6-4 3.3-6 8-6s7.4 2 8 6",
            "menu": "M4 6h16M4 12h16M4 18h16",
            "more": "M5 12h.01M12 12h.01M19 12h.01",
            "edit": "m4 16.5-.8 4.3 4.3-.8L20 7.5 16.5 4 4 16.5ZM14.8 5.7l3.5 3.5",
            "arrow": "M5 12h14M13 5l7 7-7 7",
            "back": "m15 18-6-6 6-6M20 12H9",
            "plus": "M12 5v14M5 12h14",
            "check": "m5 12 4.5 4.5L19 7",
            "settings": "M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7ZM19 13.3l1.8 1.4-1.7 3-2.2-.7a7.6 7.6 0 0 1-1.6.9l-.4 2.3h-3.5l-.4-2.3a7.6 7.6 0 0 1-1.6-.9l-2.2.7-1.7-3 1.8-1.4a7.6 7.6 0 0 1 0-1.8l-1.8-1.4 1.7-3 2.2.7a7.6 7.6 0 0 1 1.6-.9l.4-2.3h3.5l.4 2.3a7.6 7.6 0 0 1 1.6.9l2.2-.7 1.7 3-1.8 1.4a7.6 7.6 0 0 1 0 1.8Z",
            "search": "M10.8 18a7.2 7.2 0 1 0 0-14.4 7.2 7.2 0 0 0 0 14.4ZM16.2 16.2 21 21",
            "tune": "M4 7h9M17 7h3M4 17h3M11 17h9M13 4v6M7 14v6",
            "lock": "M6 10V7a6 6 0 0 1 12 0v3M5 10h14v11H5V10Zm7 4v3",
            "radio": "M12 12m-8 0a8 8 0 1 0 16 0a8 8 0 1 0-16 0M12 12m-3 0a3 3 0 1 0 6 0a3 3 0 1 0-6 0",
            "clock": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM12 7v5l3 2",
            "dumbbell": "M3 9v6M6 7v10M8 10v4M16 10v4M18 7v10M21 9v6M8 12h8",
            "database": "M4 6c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3Zm0 0v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3",
            "palette": "M12 3a9 9 0 1 0 0 18h1.2a2 2 0 0 0 1.2-3.6 1.4 1.4 0 0 1 .8-2.5H17a4 4 0 0 0 4-4c0-4.4-4-7.9-9-7.9ZM7.5 11h.01M10 7.5h.01M15 7.5h.01M17 11h.01",
            "switch": "M7 7h10a5 5 0 0 1 0 10H7A5 5 0 0 1 7 7Zm0 0a5 5 0 1 0 0 10",
            "badge": "M12 3 14.5 5l3.2-.2.8 3 2.5 2-1.4 2.9.4 3.2-3 1-1.8 2.6-3.1-1.1-3.1 1.1-1.8-2.6-3-1 .4-3.2L3 9.8l2.5-2 .8-3 3.2.2L12 3Z",
        }
        d = paths.get(name, paths["person"])
        stroke = color
        fill = color if filled and name in ("home", "person") else "none"
        self.add(
            f'<g transform="translate({x} {y}) scale({size / 24})" fill="{fill}" '
            f'stroke="{stroke}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'
            f'<path d="{d}"/></g>'
        )

    def result(self):
        return "\n".join(self.parts)


def defs(svg: Svg, pair_id: str):
    svg.add(
        f'<defs><filter id="shadow{pair_id}" x="-20%" y="-20%" width="140%" height="150%">'
        '<feGaussianBlur in="SourceAlpha" stdDeviation="8" result="b"/>'
        '<feOffset dy="10" result="o"/><feComponentTransfer><feFuncA type="linear" slope="0.18"/></feComponentTransfer>'
        '<feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>'
        f'<clipPath id="clip{pair_id}L"><rect x="0" y="0" width="390" height="844" rx="38"/></clipPath>'
        f'<clipPath id="clip{pair_id}R"><rect x="0" y="0" width="390" height="844" rx="38"/></clipPath></defs>'
    )


def page_text(s: Svg, x, y, label, size, color, weight=400, anchor="start", spacing=0):
    s.text(x, y, label, size, color, weight, anchor, spacing)


def text_lines(s: Svg, x, y, lines, size, color, weight=400, line_h=None):
    line_h = line_h or size * 1.35
    for i, item in enumerate(lines):
        s.text(x, y + i * line_h, item, size, color, weight)


def status_bar(s: Svg, t: Scheme, label="9:41"):
    s.text(27, 20, label, 12, t.text, 700)
    # restrained, familiar status glyphs
    s.path("M324 17h2v4h-2ZM328 14h2v7h-2ZM332 11h2v10h-2Z", "none", t.text, 1.4)
    s.path("M340 16c4-4 9-4 13 0M343 19c2-2 5-2 7 0", "none", t.text, 1.4)
    s.rect(359, 10, 20, 11, "none", 3, t.text, 1)
    s.rect(361, 12, 14, 7, t.primary, 1)
    s.rect(380, 13, 2, 5, t.text, 1)


def base_phone(s: Svg, x, y, t: Scheme, mode: str, content_fn, clip_id: str, pair_id: str):
    s.rect(x, y, 414, 868, "#111917", 44, "#27312E", 1,)
    s.add(f'<g transform="translate({x + 12} {y + 12})" clip-path="url(#{clip_id})">')
    s.rect(0, 0, 390, 844, t.bg)
    status_bar(s, t)
    content_fn(s, t)
    s.add("</g>")
    s.rect(x + 12, y + 12, 390, 844, "none", 38, "#56615C", 1)


def card(s: Svg, t: Scheme, x, y, w, h, fill=None, r=24, stroke=None):
    s.rect(x, y, w, h, fill or t.surface, r, stroke or None, 1)


def pill(s: Svg, t: Scheme, x, y, w, h, label, fill=None, fg=None, size=12, weight=600, stroke=None):
    s.rect(x, y, w, h, fill or t.container, h / 2, stroke, 1)
    s.text(x + w / 2, y + h / 2 + size * 0.34, label, size, fg or t.text, weight, "middle")


def train_header(s: Svg, t: Scheme, selected="Overview"):
    s.rect(0, 24, 390, 56, t.bg)
    s.rect(72, 32, 246, 40, t.container, 18)
    if selected == "Overview":
        s.rect(75, 35, 119, 34, t.primary_container, 16)
        fg1, fg2 = t.on_primary_container, t.sub
    else:
        s.rect(196, 35, 119, 34, t.primary_container, 16)
        fg1, fg2 = t.sub, t.on_primary_container
    s.text(134, 57, "Overview", 14, fg1, 700, "middle")
    s.text(255, 57, "Plans", 14, fg2, 700, "middle")
    s.circle(354, 52, 18, t.tertiary_container)
    s.text(354, 57, "A", 13, t.tertiary, 800, "middle")


def nav_bar(s: Svg, t: Scheme, selected: str):
    s.rect(0, 748, 390, 96, t.surface)
    s.line(0, 748, 390, 748, t.outline, 0.8, 0.32)
    entries = [
        ("Train", "dumbbell"), ("Catalog", "catalog"), ("Logbook", "history"),
        ("Progress", "trend"), ("Profile", "person"),
    ]
    for i, (name, glyph) in enumerate(entries):
        cx = 39 + i * 78
        col = t.on_primary_container if selected == name else t.muted
        if selected == name:
            s.rect(cx - 27, 756, 54, 30, t.primary_container, 15)
            col = t.on_primary_container
        s.icon(glyph, cx - 11, 760 if selected == name else 760, col, 22, filled=(selected == name and name in ("Train", "Profile")))
        s.text(cx, 809, name, 10.5, t.text if selected == name else t.muted, 700 if selected == name else 500, "middle")


def draw_body_heatmap(s: Svg, t: Scheme, x: float, y: float, w: float, h: float):
    """Reuse the production anatomy SVG with representative, token-owned fills."""
    source = (ROOT / "assets" / "body_heatmap.svg").read_text(encoding="utf-8")
    source = re.sub(r"<\?xml[^>]*\?>", "", source)
    source = re.sub(r"<!--.*?-->", "", source, flags=re.DOTALL)
    prefix = f"heat_{'dark' if t.dark else 'light'}_{int(x)}_{int(y)}"
    source = re.sub(r'id="([^"]+)"', lambda m: f'id="{prefix}_{m.group(1)}"', source)
    source = re.sub(r'url\(#([^\)]+)\)', lambda m: f'url(#{prefix}_{m.group(1)})', source)
    source = re.sub(
        r'(?:xlink:href|href)="#([^"]+)"',
        lambda m: f'{m.group(0).split("=")[0]}="#{prefix}_{m.group(1)}"',
        source,
    )
    source = re.sub(r'width="[^"]+"', f'width="{w}"', source, count=1)
    source = re.sub(r'height="[^"]+"', f'height="{h}"', source, count=1)
    source = source.replace(
        "<svg", f'<svg x="{x}" y="{y}" preserveAspectRatio="xMidYMid meet"', 1
    )
    heat_entries = {
        "Chest_right": 0.92,
        "Chest_left": 0.92,
        "Shoulder_frontal_right": 0.56,
        "Shoulder_frontal_left": 0.56,
        "Upper_Back": 0.7,
    }

    def mix(low: str, high: str, amount: float) -> str:
        a = [int(low[i:i + 2], 16) for i in (1, 3, 5)]
        b = [int(high[i:i + 2], 16) for i in (1, 3, 5)]
        return "#" + "".join(
            f"{round(v1 + (v2 - v1) * amount):02X}" for v1, v2 in zip(a, b)
        )

    def paint_path(match):
        tag = match.group(0)
        id_match = re.search(rf'id="{re.escape(prefix)}_(.+?)"', tag)
        source_id = id_match.group(1) if id_match else ""
        amount = heat_entries.get(source_id, 0.0)
        fill = mix(t.heat_low, t.heat_high, amount) if amount else t.heat_low
        tag = re.sub(r'\sfill="[^"]*"', "", tag)
        style = re.search(r'\sstyle="([^"]*)"', tag)
        if style:
            clean = re.sub(
                r'\bfill\s*:\s*#[0-9a-fA-F]+\s*;?',
                "",
                style.group(1),
                flags=re.IGNORECASE,
            )
            clean = ";".join(part.strip() for part in clean.split(";") if part.strip())
            tag = tag[:style.start()] + (f' style="{clean}"' if clean else "") + tag[style.end():]
        closing = "/>" if tag.endswith("/>") else ">"
        return tag[:-len(closing)] + f' fill="{fill}"{closing}'

    source = re.sub(r'<path\b[^>]*>', paint_path, source, flags=re.IGNORECASE)
    s.add(source)


def draw_overview(s: Svg, t: Scheme):
    train_header(s, t, "Overview")
    # WeeklyOverviewCard is first; fixed side-by-side heatmap and top-three list.
    card(s, t, 16, 96, 358, 290, t.high, 26)
    s.text(32, 126, "Weekly Overview", 21, t.text, 750)
    draw_body_heatmap(s, t, 31, 168, 140, 140)
    s.line(175, 146, 175, 370, t.outline, 1, 0.45)
    s.text(187, 161, "Focused Sets", 14, t.text, 750)
    rows = [("Chest", "12", 0.92), ("Back", "9", 0.68), ("Shoulders", "7", 0.51)]
    for i, (name, value, frac) in enumerate(rows):
        y = 190 + i * 54
        s.text(188, y, name, 11.5, t.sub, 550)
        s.text(352, y, value, 11.5, t.text, 750, "end")
        s.rect(188, y + 10, 164, 6, t.low, 3)
        s.rect(188, y + 10, 164 * frac, 6, t.primary, 3)

    # Active Plans retains its production card location directly below weekly focus.
    card(s, t, 16, 402, 358, 148, t.surface, 24)
    s.text(32, 432, "Active Plans", 20, t.text, 750)
    s.icon("edit", 335, 412, t.muted, 19)
    s.rect(31, 448, 328, 80, t.low, 17)
    s.rect(31, 448, 4, 80, t.plan, 2)
    draw_body_heatmap(s, t, 45, 462, 45, 50)
    s.text(101, 479, "Upper / Lower Split", 13, t.text, 700)
    s.icon("more", 326, 475, t.muted, 22)

    # The actual Overview-only split action bar remains immediately above app navigation.
    s.rect(16, 670, 358, 64, t.surface, 20, t.outline, 0.7)
    s.rect(17, 671, 204, 62, t.primary, 19)
    s.text(119, 710, "Start Workout", 15, t.on_primary, 750, "middle")
    s.rect(221, 671, 152, 62, t.primary_container, 19)
    s.text(279, 710, "Optimize", 14, t.on_primary_container, 700, "middle")
    s.icon("settings", 338, 691, t.on_primary_container, 21)
    nav_bar(s, t, "Train")


def plan_row(s: Svg, t: Scheme, x, y, w, title, accent, secondary=""):
    s.rect(x, y, w, 60, t.low, 16)
    s.rect(x, y, 4, 60, accent, 2)
    # Reuse the app's current two-view heatmap asset as the plan focus cue.
    draw_body_heatmap(s, t, x + 12, y + 5, 46, 50)
    s.text(x + 64, y + 27, title, 12.5, t.text, 700)
    if secondary:
        s.text(x + 64, y + 45, secondary, 10.5, t.muted, 500)
    s.icon("more", x + w - 37, y + 19, t.muted, 21)


def draw_plans(s: Svg, t: Scheme):
    train_header(s, t, "Plans")
    card(s, t, 16, 96, 358, 132, t.surface, 24)
    s.text(32, 125, "Active Plans", 19, t.text, 750)
    s.icon("edit", 335, 105, t.muted, 19)
    plan_row(s, t, 31, 143, 328, "Upper / Lower Split", t.plan, "")

    card(s, t, 16, 242, 358, 127, t.surface, 24)
    s.text(32, 271, "Archived Plans", 19, t.text, 750)
    s.icon("edit", 335, 251, t.muted, 19)
    plan_row(s, t, 31, 289, 328, "Full Body A", t.tertiary, "")

    card(s, t, 16, 383, 358, 151, t.high, 24)
    s.icon("catalog", 32, 398, t.primary, 26)
    s.text(68, 418, "Premade Plans", 18, t.text, 750)
    text_lines(s, 32, 446, ["Browse ready-made exercise plans", "for this gym profile."], 11, t.sub, 450, 15)
    s.rect(31, 478, 328, 42, t.secondary_container, 16)
    s.icon("arrow", 51, 488, t.on_secondary_container, 22)
    s.text(202, 504, "Browse Premade Plans", 12.5, t.on_secondary_container, 700, "middle")

    # GenericBar has no leading/trailing widget in these two current calls.
    generic_fill = "#F2ECF6" if not t.dark else "#25202A"
    for y, label in [(549, "Generate Custom Plans"), (607, "Manually Add Plan")]:
        s.rect(16, y, 358, 50, generic_fill, 15, t.tertiary, 1)
        s.text(28, y + 31, label, 14, t.tertiary, 600)
    nav_bar(s, t, "Train")


def set_row(s: Svg, t: Scheme, index, y, complete, weight, reps):
    x = 24
    s.rect(x, y, 342, 54, t.success_container if complete else t.low, 14)
    # Current row order: checkbox, set label, weight and reps fields, remove action.
    if complete:
        s.rect(32, y + 17, 20, 20, t.success, 5)
        s.icon("check", 33, y + 18, t.on_primary, 18)
    else:
        s.rect(32, y + 17, 20, 20, "none", 5, t.outline, 1.5)
    s.text(57, y + 33, f"Set {index}", 10.5, t.text, 600)
    s.rect(105, y + 7, 111, 40, t.surface, 10, t.outline, 0.9)
    s.text(114, y + 18, "Weight (lbs)", 8.5, t.muted, 500)
    s.text(114, y + 37, weight, 13, t.text, 600)
    s.rect(222, y + 7, 86, 40, t.surface, 10, t.outline, 0.9)
    s.text(230, y + 18, "Reps", 8.5, t.muted, 500)
    s.text(230, y + 37, reps, 13, t.text, 600)
    s.circle(347, y + 27, 12, "none", t.outline, 1)
    s.line(343, y + 27, 351, y + 27, t.muted, 1.6)


def draw_session(s: Svg, t: Scheme):
    s.rect(0, 24, 390, 56, t.bg)
    s.icon("menu", 17, 42, t.text, 24)
    s.text(195, 59, "Workout Session", 17, t.text, 650, "middle")
    s.line(0, 80, 390, 80, t.outline, 0.6, 0.3)

    # WeightCard: dense header, set table/fields and inline Add Set control.
    card(s, t, 14, 96, 362, 391, t.surface, 22)
    s.path("M25 125l7-7 7 7", "none", t.muted, 1.8)
    s.text(52, 129, "Bench Press", 17, t.text, 750)
    s.text(52, 150, "2 of 4 sets complete", 11, t.success if not t.dark else t.success, 600)
    s.circle(326, 124, 17, t.low)
    s.icon("dumbbell", 315, 113, t.primary, 22)
    s.icon("more", 347, 113, t.muted, 22)
    s.line(30, 164, 360, 164, t.outline, 0.8, 0.42)
    for i, (complete, weight, reps) in enumerate([
        (True, "135", "8"), (True, "135", "8"), (False, "135", "8"), (False, "", ""),
    ], start=1):
        set_row(s, t, i, 171 + (i - 1) * 60, complete, weight, reps)
    s.rect(252, 424, 110, 42, t.primary_container, 15)
    s.icon("plus", 265, 434, t.on_primary_container, 20)
    s.text(315, 450, "Add Set", 12, t.on_primary_container, 700, "middle")
    # The source card has no quick-entry chip row.
    s.circle(340, 697, 29, t.primary_container)
    s.circle(340, 697, 26, t.primary)
    s.icon("plus", 329, 686, t.on_primary, 22)
    s.rect(16, 765, 358, 54, t.primary, 18)
    s.text(195, 798, "Finish Workout", 15, t.on_primary, 750, "middle")


def report_stat(s: Svg, t: Scheme, x, y, w, title, value, selected=False):
    fill = t.primary_container if selected else t.low
    fg = t.on_primary_container if selected else t.text
    s.rect(x, y, w, 62, fill, 16)
    s.text(x + w / 2, y + 21, title, 9.5, fg, 650, "middle")
    s.text(x + w / 2, y + 45, value, 15, fg, 750, "middle")


def draw_progress(s: Svg, t: Scheme):
    # The Progress route has no app bar: Workout Report is the first list child.
    card(s, t, 12, 34, 366, 505, t.surface, 24)
    s.text(195, 66, "Workout Report", 20, t.text, 800, "middle")
    report_stat(s, t, 26, 82, 103, "Workouts", "28", True)
    report_stat(s, t, 139, 82, 103, "Time", "16h 20m")
    report_stat(s, t, 252, 82, 103, "Volume", "42.8k")
    # Current chart is a swipeable line chart. Purple series remains data-owned.
    s.rect(26, 158, 338, 224, t.low, 19)
    s.text(42, 182, "Workouts (All)", 13, t.text, 700)
    chart_x, chart_y, chart_w, chart_h = 51, 200, 294, 139
    for i in range(4):
        gy = chart_y + i * 34
        s.line(chart_x, gy, chart_x + chart_w, gy, t.outline, 0.75, 0.38)
    s.text(43, 204, "8", 8.5, t.muted, 500)
    s.text(43, 272, "4", 8.5, t.muted, 500)
    s.text(43, 340, "0", 8.5, t.muted, 500)
    points = [(60, 310), (103, 279), (146, 295), (189, 246), (232, 263), (275, 225), (324, 237)]
    path_d = "M" + " L".join(f"{x} {y}" for x, y in points)
    s.path(path_d, "none", t.purple, 3)
    for x, y in points:
        s.circle(x, y, 4, t.purple, t.low, 2)
    for i, day in enumerate(["Jan", "Mar", "May", "Jul", "Sep", "Nov"]):
        s.text(63 + i * 52, 365, day, 8.5, t.muted, 500, "middle")
    # Existing six-range selector, initially All.
    s.rect(26, 393, 338, 48, t.container, 16)
    labels = ["1W", "1M", "3M", "6M", "1Y", "All"]
    for i, label in enumerate(labels):
        x = 29 + i * 55.5
        if label == "All":
            s.rect(x, 397, 52, 40, t.primary, 13)
        s.text(x + 26, 422, label, 10, t.on_primary if label == "All" else t.text, 700, "middle")
    s.text(42, 474, "Additional Details", 12, t.text, 650)
    s.path("M341 464l6 6 6-6", "none", t.muted, 1.8)
    s.line(28, 488, 362, 488, t.outline, 0.7, 0.28)
    # The next production list child begins with the Exercise Progress card.
    card(s, t, 16, 547, 358, 314, t.high, 22)
    s.text(195, 578, "Exercise Progress", 18, t.text, 800, "middle")
    s.rect(32, 590, 326, 226, t.surface, 18)
    s.text(46, 617, "Bench Press", 14, t.text, 750)
    s.path("M338 607l5 5-5 5", "none", t.muted, 1.6)
    # Hero chart and 1RM stat boxes are the production structure; chart series stay distinct.
    for i in range(3):
        s.line(48, 647 + i * 29, 225, 647 + i * 29, t.outline, 0.65, 0.32)
    s.path("M52 710 L88 691 L125 700 L165 671 L213 659", "none", t.purple, 2.5)
    s.path("M52 716 L88 699 L125 705 L165 680 L213 670", "none", t.secondary_series, 1.8)
    for px, py in [(52, 710), (88, 691), (125, 700), (165, 671), (213, 659)]:
        s.circle(px, py, 3, t.purple)
    s.rect(236, 634, 108, 76, t.low, 13)
    s.text(245, 653, "Actual 1RM", 8.5, t.muted, 600)
    s.text(245, 674, "185 lb", 13, t.text, 750)
    s.text(245, 696, "+5 lb", 8.5, t.success, 700)
    s.rect(236, 718, 108, 76, t.low, 13)
    s.text(245, 737, "Estimated", 8.5, t.muted, 600)
    s.text(245, 758, "197 lb", 13, t.text, 750)
    nav_bar(s, t, "Progress")


def profile_hero(s: Svg, t: Scheme, y, title, subtitle, icon_name="person", back=False):
    if back:
        s.icon("back", 20, y + 6, t.text, 22)
        y += 38
    card(s, t, 16, y, 358, 106, t.high, 24)
    s.rect(30, y + 21, 58, 58, t.tertiary_container, 20)
    s.icon(icon_name, 48, y + 39, t.tertiary, 25)
    s.text(102, y + 43, title, 23, t.text, 750)
    if title == "Profile":
        text_lines(s, 102, y + 64, ["Personalize Tonos, manage training defaults,", "and keep your data healthy."], 9.4, t.sub, 450, 14)
    else:
        s.text(102, y + 66, subtitle, 10.5, t.sub, 450)
    return y + 106


def section_head(s: Svg, t: Scheme, y, title, subtitle, accent):
    s.rect(16, y + 2, 4, 35, accent, 2)
    s.text(30, y + 18, title, 15, t.text, 750)
    s.text(30, y + 35, subtitle, 9.5, t.muted, 450)


def setting_rows(s: Svg, t: Scheme, x, y, w, rows, accents):
    h = len(rows) * 62 + 2
    s.rect(x, y, w, h, t.surface, 22, t.outline, 0.7)
    for i, (icon, title, subtitle, trailing) in enumerate(rows):
        ry = y + i * 62
        if i:
            s.line(x + 70, ry, x + w - 14, ry, t.outline, 0.65, 0.34)
        accent = accents[i % len(accents)]
        s.rect(x + 14, ry + 10, 42, 42, accent + ("" if not t.dark else ""), 14, opacity=0.16)
        s.icon(icon, x + 24, ry + 20, accent, 22)
        s.text(x + 68, ry + 27, title, 11.5, t.text, 700)
        s.text(x + 68, ry + 45, subtitle, 8.5, t.muted, 450)
        if trailing == "switch-on":
            s.rect(x + w - 52, ry + 19, 38, 23, t.primary, 12)
            s.circle(x + w - 26, ry + 30.5, 8.5, t.on_primary)
        elif trailing == "switch-off":
            s.rect(x + w - 52, ry + 19, 38, 23, t.high, 12, t.outline, 0.9)
            s.circle(x + w - 40, ry + 30.5, 7.5, t.surface, t.muted, 0.8)
        elif trailing:
            s.text(x + w - 16, ry + 35, trailing, 8.8 if len(trailing) > 13 else 9.5, t.muted, 500, "end")
        else:
            s.path(f"M{x + w - 26} {ry + 26}l5 5-5 5", "none", t.muted, 1.5)
    return y + h


def draw_profile(s: Svg, t: Scheme):
    y = profile_hero(s, t, 34, "Profile", "Personalize Tonos, manage training defaults, and keep your data healthy.")
    y += 13
    section_head(s, t, y, "Account", "Your identity and app-level appearance.", "#B39DDB")
    y = setting_rows(s, t, 16, y + 47, 358, [
        ("badge", "User Information", "Name, body details, and activity profile.", ""),
        ("palette", "UI & Appearance", "Theme, onboarding, and bottom tab setup.", ""),
        ("school", "Guided Tutorials", "Replay walkthroughs and reset guided help.", ""),
    ], ["#B39DDB", "#CE93D8", "#CE93D8"])
    y += 12
    section_head(s, t, y, "Training", "Exercise defaults and progress-related controls.", "#4DB6AC")
    y = setting_rows(s, t, 16, y + 47, 358, [
        ("dumbbell", "Gym & Workout Settings", "Workout generation, rankings, flows, and equipment logic.", ""),
        ("chart", "Progress Settings", "Measurement and trend tracking setup.", ""),
    ], ["#4DB6AC", "#81C784"])
    y += 12
    section_head(s, t, y, "Data", "Database tools, exports, imports, and maintenance.", "#64B5F6")
    setting_rows(s, t, 16, y + 47, 358, [
        ("database", "Database Settings", "Import, export, health checks, and maintenance tools.", ""),
    ], ["#64B5F6"])
    nav_bar(s, t, "Profile")


def settings_underlay(s: Svg, t: Scheme):
    y = profile_hero(s, t, 34, "UI & Appearance", "Theme, onboarding, and bottom tab setup.", "palette", back=True)
    y += 13
    section_head(s, t, y, "Display", "Quick visual preferences.", "#CE93D8")
    setting_rows(s, t, 16, y + 47, 358, [
        ("palette", "Theme Family", "Choose the visual family.", "M3E"),
        ("switch", "Dark Mode", "Use the darker app theme.", "switch-off"),
        ("chart", "Replay Onboarding", "Open setup again after completion.", "switch-off"),
        ("badge", "Weight Units", "Show workout weights and volume in lb.", "Pounds"),
        ("person", "Language", "Choose the language Tonos uses.", "System"),
    ], ["#CE93D8", "#CE93D8", "#CE93D8", "#81C784", "#CE93D8"])
    y += 374
    section_head(s, t, y, "Navigation", "Choose which tabs are available.", "#64B5F6")
    setting_rows(s, t, 16, y + 47, 358, [
        ("home", "Edit Bottom Tabs", "Reorder your app destinations.", ""),
    ], ["#64B5F6"])


def draw_units_dialog(s: Svg, t: Scheme):
    settings_underlay(s, t)
    # Modal scrim only covers the current route; its dim level keeps layout visible.
    s.rect(0, 0, 390, 844, "#000000", 0, opacity=0.38)
    s.rect(21, 312, 348, 226, t.high, 28)
    s.text(45, 355, "Weight Units", 22, t.text, 750)
    s.rect(36, 374, 318, 67, t.primary_container, 18)
    s.circle(61, 407, 10, "none", t.primary, 2)
    s.circle(61, 407, 5, t.primary)
    s.text(87, 405, "Pounds", 14, t.text, 700)
    s.text(87, 424, "lbs", 11, t.sub, 450)
    s.circle(61, 475, 10, "none", t.outline, 1.6)
    s.text(87, 473, "Kilograms", 14, t.text, 600)
    s.text(87, 492, "kg", 11, t.sub, 450)


def draw_appearance_settings(s: Svg, t: Scheme):
    # The actual pushed Profile child containing the visible switches and unit row.
    settings_underlay(s, t)


SCREEN_DRAWERS = {
    "train-overview": draw_overview,
    "train-plans": draw_plans,
    "active-workout": draw_session,
    "progress": draw_progress,
    "profile": draw_profile,
    "appearance-settings": draw_appearance_settings,
    "weight-units": draw_units_dialog,
}

TITLES = {
    "train-overview": "Train / Overview",
    "train-plans": "Train / Plans",
    "active-workout": "Active Workout / Session",
    "progress": "Progress",
    "profile": "Profile / Settings",
    "appearance-settings": "Profile / UI & Appearance",
    "weight-units": "Weight Units dialog",
}


def make_pair(name: str):
    s = Svg()
    pair_id = name.replace("-", "")
    defs(s, pair_id)
    s.add('<rect width="1320" height="1020" fill="#E8EDEA"/>')
    s.text(54, 43, "TONOS  /  MATERIAL 3 EXPRESSIVE", 11, "#47605A", 700, spacing=1.35)
    s.text(54, 78, TITLES[name], 27, "#17201D", 750)
    s.text(1266, 75, "SAME CONTENT  ·  LIGHT / DARK", 10, "#60716B", 600, "end", 0.45)
    s.text(365, 111, "LIGHT", 10, "#4F625B", 800, "middle", 1)
    s.text(955, 111, "DARK", 10, "#4F625B", 800, "middle", 1)
    base_phone(s, 158, 126, Scheme(False), "light", SCREEN_DRAWERS[name], f"clip{pair_id}L", pair_id)
    base_phone(s, 748, 126, Scheme(True), "dark", SCREEN_DRAWERS[name], f"clip{pair_id}R", pair_id)
    s.text(660, 1004, "Illustrative content values; current production hierarchy preserved.", 9.5, "#60716B", 500, "middle")
    svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" width="1320" height="1020" viewBox="0 0 1320 1020">\n'
        + s.result() + "\n</svg>"
    )
    svg_path = OUT / f"{name}.svg"
    svg_path.write_text(svg, encoding="utf-8")
    subprocess.run(
        ["magick", "-background", "none", str(svg_path), "-strip", str(OUT / f"{name}.png")],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def make_board_svg():
    s = Svg()
    s.add('<rect width="1900" height="3540" fill="#EFF3F1"/>')
    s.text(66, 60, "TONOS  /  MATERIAL 3 EXPRESSIVE", 12, "#47605A", 700, spacing=1.45)
    s.text(66, 111, "A tonal third theme for the Tonos you already know.", 30, "#17201D", 750)
    s.text(66, 146, "Current layouts, routes, controls, and scroll order; one recommended teal-led palette in paired light and dark.", 14, "#53625D", 450)
    # Palette strips: one recommendation, role relationships, semantic data kept separate.
    cards = [
        (66, "PRIMARY", "#006B62", "#62D8CA"),
        (365, "SECONDARY", "#49645E", "#B4CEC7"),
        (664, "TERTIARY", "#625C7B", "#C9C0E2"),
        (963, "CHART SERIES", "#6200EE", "#BB86FC"),
        (1262, "HEATMAP DATA", "#1565C0", "#1565C0"),
        (1561, "ERROR", "#BA1A1A", "#FFB4AB"),
    ]
    for x, label, light, dark in cards:
        s.rect(x, 177, 267, 91, "#FAFCFA", 18, "#D9E2DE", 1)
        s.text(x + 16, 201, label, 9, "#687670", 750, spacing=0.7)
        s.rect(x + 16, 214, 102, 24, light, 8)
        s.rect(x + 126, 214, 102, 24, dark, 8)
        s.text(x + 16, 256, light, 9, "#44514C", 550)
        s.text(x + 126, 256, dark, 9, "#44514C", 550)
    s.text(66, 303, "CURRENT TONOS EXPERIENCES  ·  SETTINGS DETAIL", 10, "#49635B", 750, spacing=1.2)
    names = ["train-overview", "train-plans", "active-workout", "progress", "profile", "appearance-settings", "weight-units"]
    labels = ["Train · Overview", "Train · Plans", "Active Workout · Session", "Progress", "Profile · Settings", "Profile · UI & Appearance", "Weight Units dialog"]
    positions = [(56, 324), (982, 324), (56, 1125), (982, 1125), (56, 1926), (982, 1926), (519, 2727)]
    for name, label, (x, y) in zip(names, labels, positions):
        s.text(x + 10, y + 22, label, 17, "#17201D", 700)
        image_data = base64.b64encode((OUT / f"{name}.png").read_bytes()).decode("ascii")
        s.add(
            f'<image xlink:href="data:image/png;base64,{image_data}" x="{x}" y="{y + 32}" width="862" height="666" preserveAspectRatio="xMidYMid meet"/>'
        )
    s.rect(56, 3490, 1788, 1, "#CED8D3")
    s.text(66, 3518, "Standard Material 3 controls  ·  expressive Tonos color / shape / hierarchy  ·  advanced morphing deferred", 11, "#53625D", 550)
    (OUT / "overview-board.svg").write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1900" height="3540" viewBox="0 0 1900 3540">\n'
        + s.result() + "\n</svg>", encoding="utf-8"
    )


def make_html():
    title_rows = [
        ("train-overview", "Train — Overview", "TrainPage · SevenDayFocusCard · FocusedSetsList · _ActivePresetsCard · _SplitWorkoutBar · TonosBottomNavigationBar", "Top scroll position: Weekly Overview, Active Plans, current split action, and all five destinations."),
        ("train-plans", "Train — Plans", "TrainPage / _PlansTab · _PresetSectionCard · PresetsLoaded · _PremadePlansCard · GenericBar", "Top scroll position, selected Plans tab, source order, supporting actions, and global navigation."),
        ("active-workout", "Active Workout / Session", "SessionScreen · ExerciseCard · WeightCard · AddExerciseFab · WorkoutFinishAction", "One weight exercise, two completed sets, two editable sets, Add Set, add-exercise FAB, and Finish Workout."),
        ("progress", "Progress", "MeasurementsTrendsPage · WorkoutMetricChartCard · ExerciseProgressSection", "Top scroll position: Workouts and All selected; original purple and blue chart series retained."),
        ("profile", "Profile / Settings", "ProfilePage · SettingsPageScaffold · SettingsHeroCard · SettingsSection · SettingsActionTile", "Initial scroll position; Account, Training, and Data. Lower Data and paused Nutrition continue below the viewport."),
        ("appearance-settings", "Profile — UI & Appearance", "UIAppearanceSettingsPage · Display Settings · SettingsSwitchTile · SettingsActionTile", "Real nested settings route showing the proposed M3E family value, Dark Mode and Replay Onboarding switches, units, language, and navigation group. M3E abbreviates Material 3 Expressive to fit the existing trailing-value slot; this family is not available in production yet."),
        ("weight-units", "Weight Units dialog", "UIAppearanceSettingsPage · TonosChoiceDialog<WeightUnit> · RadioListTile", "Pounds selected. The background M3E family value is a proposal state and is not available in production yet."),
    ]
    cards = []
    for i, (name, label, source, caption) in enumerate(title_rows, 1):
        cards.append(f'''<section class="study" id="screen-{i}">
  <div class="study-heading"><span class="index">0{i}</span><div><h2>{escape(label)}</h2><p>{escape(source)}</p></div></div>
  <a class="image-link" href="proposals/material-3-expressive/{name}.png"><img src="proposals/material-3-expressive/{name}.png" alt="{escape(label)} current Tonos layout in paired Material 3 Expressive light and dark treatments"></a>
  <p class="caption">{escape(caption)} Numbers and example plan names are illustrative; chart colors and screen structure stay source-owned.</p>
</section>''')
    html = '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Material 3 Expressive — Tonos Theme Proposal</title>
<style>
:root{color-scheme:light;--ink:#18211e;--sub:#596760;--paper:#f1f5f2;--card:#fbfdfb;--line:#dbe4df;--teal:#006b62;--teal-soft:#b8f0e7;--plum:#6750a4}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.5 Roboto,"Segoe UI",Arial,sans-serif}
.wrap{max-width:1320px;margin:auto;padding:36px 32px 72px}.hero{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:26px;align-items:end;padding:28px 0 30px;border-bottom:1px solid var(--line)}
.eyebrow{font-size:12px;letter-spacing:.14em;font-weight:800;color:#49635b;text-transform:uppercase}.hero h1{font-size:clamp(34px,5vw,60px);line-height:1.02;letter-spacing:-.04em;margin:14px 0 15px;max-width:850px}.hero p{max-width:760px;margin:0;color:var(--sub);font-size:17px}.tag{align-self:center;border-radius:18px;background:#dceee8;color:#124a42;padding:12px 16px;font-size:13px;font-weight:750;white-space:nowrap}
.intro-grid{display:grid;grid-template-columns:1fr 1.05fr;gap:18px;margin:24px 0 46px}.panel{background:var(--card);border:1px solid var(--line);border-radius:26px;padding:22px}.panel h2,.section-title{font-size:22px;line-height:1.2;letter-spacing:-.02em;margin:0 0 8px}.panel p{color:var(--sub);margin:0 0 17px;font-size:14px}.swatches{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}.swatch{border:1px solid var(--line);border-radius:17px;padding:11px}.swatch .chips{display:flex;gap:7px;margin:7px 0}.chip{height:21px;flex:1;border-radius:8px}.swatch b{font-size:10px;letter-spacing:.07em}.hex{font-size:10px;color:var(--sub);display:flex;justify-content:space-between}
.roles{display:grid;grid-template-columns:1fr 1fr;gap:10px}.role{display:flex;gap:11px;align-items:center;background:#f4f7f5;border-radius:16px;padding:11px}.role i{width:24px;height:24px;border-radius:8px;display:block;flex:none}.role strong{display:block;font-size:12px}.role small{display:block;color:var(--sub);font-size:10px}.principles{display:flex;flex-wrap:wrap;gap:8px;margin-top:15px}.principles span{border-radius:12px;background:#e8eeeb;padding:6px 10px;color:#3e4e47;font-size:11px;font-weight:650}
.section-intro{margin:48px 0 18px;display:flex;justify-content:space-between;align-items:end;gap:16px}.section-intro h2{font-size:30px;letter-spacing:-.03em;margin:0}.section-intro p{margin:4px 0 0;color:var(--sub);font-size:14px}.study{margin:24px 0 42px;padding:20px;background:var(--card);border:1px solid var(--line);border-radius:28px;box-shadow:0 5px 22px #17241d0a}.study-heading{display:flex;gap:14px;align-items:start;margin:0 0 14px}.index{display:grid;place-items:center;width:36px;height:36px;border-radius:13px;background:#dceee8;color:#00534c;font-size:12px;font-weight:800;flex:none}.study h2{font-size:21px;line-height:1.2;margin:2px 0 4px}.study-heading p{margin:0;color:var(--sub);font:11px/1.4 ui-monospace,Consolas,monospace}.image-link{display:block;border-radius:18px;overflow:hidden;background:#e8edea}.image-link img{display:block;width:100%;height:auto}.caption{color:var(--sub);font-size:12px;margin:11px 2px 0}.board-link{display:inline-flex;align-items:center;margin:16px 0 4px;border-radius:17px;padding:11px 15px;background:var(--teal);color:white;text-decoration:none;font-weight:700;font-size:13px}
.mode-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}.mode{padding:16px;border-radius:18px;background:#f2f6f3;border:1px solid var(--line)}.mode strong{display:block;margin-bottom:5px;font-size:13px}.mode p{margin:0;color:var(--sub);font-size:12px}.sources{display:grid;grid-template-columns:repeat(2,1fr);gap:8px 24px;margin-top:12px}.sources a{color:#245d53;text-decoration-thickness:1px;text-underline-offset:3px;font-size:12px}.foot{margin-top:42px;color:#68756f;font-size:12px;border-top:1px solid var(--line);padding-top:16px}
@media(max-width:800px){.wrap{padding:20px 15px 48px}.hero{grid-template-columns:1fr}.tag{justify-self:start}.intro-grid{grid-template-columns:1fr}.mode-grid{grid-template-columns:1fr}.study{padding:12px;border-radius:22px}.study-heading p{font-size:10px}.section-intro h2{font-size:25px}}
</style>
</head><body><main class="wrap">
<header class="hero"><div><div class="eyebrow">Theme proposal · Step 16 direction</div><h1>Material 3 Expressive,<br>inside current Tonos.</h1><p>A tonal, modern treatment for the production app’s existing screens. Expressiveness comes through color, containment, shape, size, and hierarchy; navigation, information order, control placement, workout flow, and data density remain Tonos.</p></div><div class="tag">One recommended palette · Light + Dark</div></header>
<div class="intro-grid">
<section class="panel"><h2>Primary proposal · Field Teal</h2><p>Ground the primary action in Tonos’s training focus, then use secondary and tertiary roles to create deliberate separation. Chart, heatmap, plan, and status colors keep their own meaning.</p>
<div class="swatches">
<div class="swatch"><b>PRIMARY</b><div class="chips"><i class="chip" style="background:#006B62"></i><i class="chip" style="background:#62D8CA"></i></div><div class="hex"><span>light #006B62</span><span>dark #62D8CA</span></div></div>
<div class="swatch"><b>SECONDARY</b><div class="chips"><i class="chip" style="background:#49645E"></i><i class="chip" style="background:#B4CEC7"></i></div><div class="hex"><span>#49645E</span><span>#B4CEC7</span></div></div>
<div class="swatch"><b>TERTIARY</b><div class="chips"><i class="chip" style="background:#625C7B"></i><i class="chip" style="background:#C9C0E2"></i></div><div class="hex"><span>#625C7B</span><span>#C9C0E2</span></div></div>
</div><div class="principles"><span>System font stack</span><span>Cool surface containers</span><span>Purposeful emphasis</span><span>Same data state</span></div></section>
<section class="panel"><h2>Keep semantic color ownership</h2><p>Theme color frames Tonos data. It does not overwrite what an existing color represents.</p><div class="roles">
<div class="role"><i style="background:#6200EE"></i><div><strong>Workout charts</strong><small>Existing purple series stay purple</small></div></div>
<div class="role"><i style="background:#1565C0"></i><div><strong>Weekly heatmap</strong><small>Existing blue intensity scale stays data-led</small></div></div>
<div class="role"><i style="background:#4DB6AC"></i><div><strong>Plan / identity</strong><small>Existing plan colors remain distinct</small></div></div>
<div class="role"><i style="background:#2D7156"></i><div><strong>Completed set</strong><small>Success remains semantic</small></div></div>
</div><div class="principles"><span>Teal-led ColorScheme</span><span>Secondary + tertiary roles</span><span>Light/dark pairings</span></div></section>
</div>
<section class="panel"><h2>Implementation realism</h2><p>Visible changes stay within ordinary Material 3 theming and components.</p><div class="mode-grid">
<div class="mode"><strong>Standard M3 component</strong><p>NavigationBar, segmented selection, filled and tonal actions, fields, switches, checkboxes, cards, dialogs, and sheets.</p></div>
<div class="mode"><strong>M3E-inspired theme treatment</strong><p>Color-role contrast, surface-container depth, selected-state emphasis, restrained shape variety, and selective type hierarchy.</p></div>
<div class="mode"><strong>Deferred behavior</strong><p>No shape morphing, wavy progress, spring physics, FAB menu, or exotic adaptive navigation is implied.</p></div>
</div></section>
<div class="section-intro"><div><div class="eyebrow">Matched component states</div><h2>Current Tonos, light and dark</h2><p>Same screen and representative data in each pair; only theme treatment changes.</p></div><a class="board-link" href="proposals/material-3-expressive/overview-board.png">Open rendered overview board</a></div>
''' + "\n".join(cards) + '''
<section class="panel"><h2>Reconstruction sources</h2><p>Screen geometry follows current production routes and shared widgets. Example plan names, measurements, and chart values are illustrative content because those values come from local user data.</p><div class="sources">
<a href="../lib/screens/exercise/train_page.dart">TrainPage · current Overview / Plans route</a>
<a href="../lib/main.dart">MainScreen · current route mapping</a>
<a href="../lib/providers/nav_bar_config.dart">Default five-destination navigation</a>
<a href="../lib/widgets/seven_day_focus_card.dart">Weekly overview / Focused Sets</a>
<a href="../lib/widgets/preset_bar.dart">Plan row / identity cue</a>
<a href="../lib/screens/exercise/session_screen.dart">SessionScreen</a>
<a href="../lib/widgets/weight_card.dart">WeightCard set controls</a>
<a href="../lib/screens/measurement_trends_page.dart">Progress route order</a>
<a href="../lib/widgets/workout_metric_chart_card.dart">Workout report, chart, range</a>
<a href="../lib/screens/profile/settings/profile_page.dart">Profile route and section order</a>
<a href="../lib/screens/profile/settings/ui_appearance_settings_page.dart">UI & Appearance route, switches, and Weight Units dialog trigger</a>
<a href="../lib/widgets/settings_tiles.dart">Settings sections and tiles</a>
<a href="../lib/theme/widgets/tonos_dialog.dart">Choice dialog / RadioListTile</a>
<a href="https://design.google/library/expressive-material-design-google-research">Google Design · Material 3 Expressive principles</a>
<a href="https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html">Flutter · Material 3 component foundation</a>
</div><p class="foot">Proposal artwork is stored under <code>docs/proposals/material-3-expressive/</code>. No production Dart code or Step 16.2 implementation was changed.</p></section>
</main></body></html>'''
    (ROOT / "docs" / "theme-m3-proposals.html").write_text(html, encoding="utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name in SCREEN_DRAWERS:
        make_pair(name)
    make_board_svg()
    subprocess.run(
        ["magick", "-background", "none", str(OUT / "overview-board.svg"), "-strip", str(OUT / "overview-board.png")],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    make_html()
    print(f"Generated proposal sources in {OUT}")


if __name__ == "__main__":
    main()
