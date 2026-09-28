"""Build the revised Tonos Material 3 Expressive visual proposal.

Everything generated here is documentation artwork. The supplied Classic Light
screenshots establish the captured content and states; the M3E phone screens are
static design explorations. No Flutter application files are read or written.
"""

from __future__ import annotations

import base64
from html import escape
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
REF = OUT / "classic-light-reference"
PHONE_W, PHONE_H = 470, 1019


class Palette:
    def __init__(self, dark: bool):
        self.dark = dark
        if dark:
            self.canvas = "#17121D"
            self.surface = "#211A29"
            self.surface1 = "#2A2233"
            self.surface2 = "#352A40"
            self.surface3 = "#43334F"
            self.secondary_subtle = "#342A3A"
            self.tertiary_subtle = "#3A2E28"
            self.primary = "#66E0C1"
            self.on_primary = "#00382D"
            self.primary_container = "#005342"
            self.on_primary_container = "#B7F5DD"
            self.secondary = "#D8B9FF"
            self.on_secondary = "#3B2058"
            self.secondary_container = "#593778"
            self.on_secondary_container = "#F1DFFF"
            self.tertiary = "#FFB68F"
            self.on_tertiary = "#4C1E00"
            self.tertiary_container = "#71300C"
            self.on_tertiary_container = "#FFDDC7"
            self.ink = "#F7F0FA"
            self.sub = "#D2C4D8"
            self.muted = "#AA9CB0"
            self.outline = "#594A63"
            self.nav = "#221B2A"
            self.success = "#A4E7B8"
            self.success_container = "#284438"
            self.success_subtle = "#25362F"
            self.success_ink = "#092D20"
            self.on_success = "#092D20"
            self.error = "#FFB4AB"
            self.error_container = "#601410"
            self.warning = "#F1C06B"
            self.chart = "#BB86FC"
            self.chart_blue = "#42A5F5"
            self.heat_low = "#76727A"
            self.heat_high = "#398AE7"
            self.plan_blue = "#73C5FF"
            self.plan_orange = "#FFB66D"
            self.plan_blue_container = "#193D5A"
            self.plan_orange_container = "#4C2D16"
            self.dim_scrim = "#08060B"
        else:
            self.canvas = "#F4F1EE"
            self.surface = "#FFFCFA"
            self.surface1 = "#F0ECE9"
            self.surface2 = "#E8E2EA"
            self.surface3 = "#DDD5E0"
            self.secondary_subtle = "#F1EBF4"
            self.tertiary_subtle = "#F3EAE3"
            self.primary = "#006B58"
            self.on_primary = "#FFFFFF"
            self.primary_container = "#A8F2D5"
            self.on_primary_container = "#00382C"
            self.secondary = "#694097"
            self.on_secondary = "#FFFFFF"
            self.secondary_container = "#EBD8FF"
            self.on_secondary_container = "#30104D"
            self.tertiary = "#A74717"
            self.on_tertiary = "#FFFFFF"
            self.tertiary_container = "#F3E0D3"
            self.on_tertiary_container = "#371400"
            self.ink = "#211625"
            self.sub = "#584C60"
            self.muted = "#74677B"
            self.outline = "#C9B8D1"
            self.nav = "#F1ECEB"
            self.success = "#2E754C"
            self.success_container = "#D7EBDD"
            self.success_subtle = "#EAF2E9"
            self.success_ink = "#103A25"
            self.on_success = "#FFFFFF"
            self.error = "#B3261E"
            self.error_container = "#F9DEDC"
            self.warning = "#8B5E00"
            self.chart = "#7700E8"
            self.chart_blue = "#268DE0"
            self.heat_low = "#A9A8AD"
            self.heat_high = "#287AD2"
            self.plan_blue = "#087CC4"
            self.plan_orange = "#AD5100"
            self.plan_blue_container = "#D5ECFF"
            self.plan_orange_container = "#FFE0C8"
            self.dim_scrim = "#170D1E"


class Svg:
    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height
        self.parts: list[str] = []
        self.sequence = 0

    def add(self, value: str):
        self.parts.append(value)

    def rect(self, x, y, w, h, fill, r=0, stroke=None, sw=1, opacity=1):
        attrs = f'x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"'
        if stroke:
            attrs += f' stroke="{stroke}" stroke-width="{sw}"'
        if opacity != 1:
            attrs += f' opacity="{opacity}"'
        self.add(f"<rect {attrs}/>")

    def asym(self, x, y, w, h, fill, tl=28, tr=28, br=28, bl=28, stroke=None, sw=1):
        d = (
            f"M{x + tl} {y} H{x + w - tr} Q{x + w} {y} {x + w} {y + tr} "
            f"V{y + h - br} Q{x + w} {y + h} {x + w - br} {y + h} "
            f"H{x + bl} Q{x} {y + h} {x} {y + h - bl} "
            f"V{y + tl} Q{x} {y} {x + tl} {y} Z"
        )
        attr = f'd="{d}" fill="{fill}"'
        if stroke:
            attr += f' stroke="{stroke}" stroke-width="{sw}"'
        self.add(f"<path {attr}/>")

    def circle(self, cx, cy, r, fill, stroke=None, sw=1):
        attr = f'cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"'
        if stroke:
            attr += f' stroke="{stroke}" stroke-width="{sw}"'
        self.add(f"<circle {attr}/>")

    def line(self, x1, y1, x2, y2, color, sw=1, opacity=1, dash=None):
        attr = f'd="M{x1} {y1} L{x2} {y2}" fill="none" stroke="{color}" stroke-width="{sw}" stroke-linecap="round" opacity="{opacity}"'
        if dash:
            attr += f' stroke-dasharray="{dash}"'
        self.add(f"<path {attr}/>")

    def path(self, d, fill="none", stroke=None, sw=1, opacity=1, dash=None):
        attr = f'd="{d}" fill="{fill}" opacity="{opacity}"'
        if stroke:
            attr += f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"'
        if dash:
            attr += f' stroke-dasharray="{dash}"'
        self.add(f"<path {attr}/>")

    def text(self, x, y, value, size, color, weight=500, anchor="start", spacing=0, family="sans-serif"):
        self.add(
            f'<text x="{x}" y="{y}" font-family="{family}" font-size="{size}" '
            f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}" '
            f'letter-spacing="{spacing}">{escape(str(value))}</text>'
        )

    def icon(self, name, x, y, size, color, filled=False, sw=2):
        self.sequence += 1
        paths = {
            "dumbbell": "M3 9v6M6 6v12M8 10v4M16 10v4M18 6v12M21 9v6M8 12h8",
            "book": "M4 5c3-1.5 6-1 8 1v13c-2-2-5-2.4-8-1V5Zm16 0c-3-1.5-6-1-8 1v13c2-2 5-2.4 8-1V5Z",
            "history": "M4 8a8 8 0 1 1-1 5M4 4v5h5M12 7v5l3 2",
            "trend": "M3 18l6-6 4 4 8-9M15 7h6v6",
            "person": "M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4 21c.7-4 3.4-6 8-6s7.3 2 8 6",
            "menu": "M4 6h16M4 12h16M4 18h16",
            "more": "M5 12h.01M12 12h.01M19 12h.01",
            "edit": "m4 16.5-.8 4.3 4.3-.8L20 7.5 16.5 4 4 16.5ZM14.8 5.7l3.5 3.5",
            "settings": "M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7ZM19 13l1.8 1.4-1.7 3-2.2-.7a7 7 0 0 1-1.6.9l-.4 2.3h-3.5l-.4-2.3a7 7 0 0 1-1.6-.9l-2.2.7-1.7-3L7.3 13a7 7 0 0 1 0-2L5.5 9.6l1.7-3 2.2.7A7 7 0 0 1 11 6.4l.4-2.3h3.5l.4 2.3a7 7 0 0 1 1.6.9l2.2-.7 1.7 3L19 11a7 7 0 0 1 0 2Z",
            "plus": "M12 5v14M5 12h14",
            "check": "m5 12 4.5 4.5L19 7",
            "minus": "M5 12h14",
            "back": "m15 18-6-6 6-6M20 12H9",
            "arrow": "M5 12h14M13 5l7 7-7 7",
            "badge": "M12 3 14.5 5l3.2-.2.8 3 2.5 2-1.4 2.9.4 3.2-3 1-1.8 2.6-3.1-1.1-3.1 1.1-1.8-2.6-3-1 .4-3.2L3 9.8l2.5-2 .8-3 3.2.2L12 3Z",
            "palette": "M12 3a9 9 0 1 0 0 18h1.2a2 2 0 0 0 1.2-3.6 1.4 1.4 0 0 1 .8-2.5H17a4 4 0 0 0 4-4c0-4.4-4-7.9-9-7.9ZM7.5 11h.01M10 7.5h.01M15 7.5h.01M17 11h.01",
            "moon": "M19.5 15.2A8.5 8.5 0 0 1 8.8 4.5 8.7 8.7 0 1 0 19.5 15.2Z",
            "spark": "M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3ZM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8L19 16Z",
            "weight": "M5 8h14l1.2 12H3.8L5 8Zm3 0a4 4 0 0 1 8 0M12 12v3",
            "globe": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM3 12h18M12 3c2.3 2.3 3.4 5.3 3.4 9s-1.1 6.7-3.4 9c-2.3-2.3-3.4-5.3-3.4-9S9.7 5.3 12 3Z",
            "database": "M4 6c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3Zm0 0v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3",
            "home": "M3 11 12 4l9 7M5.5 10v10h13V10M9 20v-6h6v6",
            "shield": "M12 3 20 6v5c0 5-3.3 8.2-8 10-4.7-1.8-8-5-8-10V6l8-3Zm-3 9 2 2 4-4",
            "users": "M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7ZM3 20c.5-3.4 2.5-5 6-5s5.5 1.6 6 5M16 5.2a3.5 3.5 0 0 1 0 6.5M17 15c2.4.4 3.7 2 4 5",
            "clock": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM12 7v5l3 2",
        }
        if name == "more":
            for cx in (6, 12, 18):
                self.circle(x + cx * size / 24, y + 12 * size / 24, max(1.5, size / 11), color)
            return
        d = paths.get(name, paths["person"])
        fill = color if filled and name in ("person", "home") else "none"
        self.add(
            f'<g transform="translate({x} {y}) scale({size / 24})" fill="{fill}" '
            f'stroke="{color}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round">'
            f'<path d="{d}"/></g>'
        )

    def embed(self, png_path: Path, x, y, w, h, preserve="xMidYMid meet"):
        payload = base64.b64encode(png_path.read_bytes()).decode("ascii")
        self.add(
            f'<image x="{x}" y="{y}" width="{w}" height="{h}" '
            f'preserveAspectRatio="{preserve}" xlink:href="data:image/png;base64,{payload}"/>'
        )

    def crop(self, png_path: Path, crop_box, x, y, w, h, radius=12):
        cx, cy, cw, ch = crop_box
        payload = base64.b64encode(png_path.read_bytes()).decode("ascii")
        self.sequence += 1
        clip = f"thumbclip{self.sequence}"
        self.add(
            f'<svg x="{x}" y="{y}" width="{w}" height="{h}" '
            f'viewBox="{cx} {cy} {cw} {ch}" preserveAspectRatio="xMidYMid slice" overflow="hidden">'
            f'<defs><clipPath id="{clip}"><rect x="{cx}" y="{cy}" width="{cw}" height="{ch}" rx="{radius}"/></clipPath></defs>'
            f'<image x="0" y="0" width="{self.width}" height="{self.height}" '
            f'clip-path="url(#{clip})" xlink:href="data:image/png;base64,{payload}"/></svg>'
        )

    def finish(self):
        return (
            f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
            f'width="{self.width}" height="{self.height}" viewBox="0 0 {self.width} {self.height}">'
            + "\n".join(self.parts) + "\n</svg>"
        )


def shape(s: Svg, t: Palette, x, y, w, h, fill=None, r=22, stroke=None, sw=1):
    s.rect(x, y, w, h, fill or t.surface, r, stroke, sw)


def text_lines(s: Svg, x, y, lines, size, color, weight=450, gap=None):
    gap = gap or size * 1.32
    for index, line in enumerate(lines):
        s.text(x, y + index * gap, line, size, color, weight)


def system_bars(s: Svg, t: Palette, time="11:29"):
    s.text(28, 37, time, 16, t.ink, 750)
    s.text(86, 36, "✉", 14, t.ink, 600)
    s.circle(112, 31, 7, t.tertiary)
    s.text(342, 37, "ᛒ", 17, t.ink, 650, anchor="middle")
    s.rect(360, 25, 3, 10, t.muted, 1)
    s.rect(367, 21, 3, 14, t.muted, 1)
    s.rect(374, 18, 3, 17, t.muted, 1)
    s.path("M386 25q10-9 20 0M390 30q6-5 12 0", "none", t.ink, 2)
    s.rect(414, 21, 30, 15, "none", 4, t.ink, 1.2)
    s.rect(417, 24, 21, 9, "#41CA6B", 2)
    s.rect(445, 25, 3, 7, t.ink, 1)
    s.text(427, 32, "80", 10, "#07140B", 800, anchor="middle")


def home_bar(s: Svg, t: Palette):
    s.rect(177, 1002, 116, 5, t.ink if not t.dark else t.sub, 3)


def base_screen(t: Palette, time="11:29") -> Svg:
    s = Svg(PHONE_W, PHONE_H)
    s.rect(0, 0, PHONE_W, PHONE_H, t.canvas)
    system_bars(s, t, time)
    home_bar(s, t)
    return s


def bottom_nav(s: Svg, t: Palette, selected: str):
    s.rect(0, 891, 470, 99, t.nav)
    s.line(0, 891, 470, 891, t.outline, 1, 0.36)
    items = [
        ("Train", "dumbbell"), ("Catalog", "book"), ("Logbook", "history"),
        ("Progress", "trend"), ("Profile", "person"),
    ]
    for i, (label, glyph) in enumerate(items):
        cx = 47 + 94 * i
        if label == selected:
            s.asym(cx - 35, 900, 70, 43, t.secondary_container, 26, 13, 24, 15)
            icon_color = t.on_secondary_container
            weight = 800
        else:
            icon_color = t.muted
            weight = 500
        s.icon(glyph, cx - 13, 909, 26, icon_color, filled=(label == selected and label == "Profile"))
        s.text(cx, 964, label, 12, t.secondary if label == selected else t.muted, weight, anchor="middle")


def train_tabs(s: Svg, t: Palette, selected: str, avatar="G"):
    s.rect(20, 70, 350, 57, t.surface2, 29)
    if selected == "Overview":
        s.asym(24, 74, 174, 49, t.secondary_container, 28, 19, 24, 28)
        selected_fg = t.on_secondary_container
        other_fg = t.sub
        left_weight, right_weight = 800, 550
    else:
        s.asym(192, 74, 174, 49, t.secondary_container, 19, 28, 28, 22)
        selected_fg = t.on_secondary_container
        other_fg = t.sub
        left_weight, right_weight = 550, 800
    s.text(111, 105, "Overview", 16, selected_fg if selected == "Overview" else other_fg, left_weight, anchor="middle")
    s.text(279, 105, "Plans", 16, selected_fg if selected == "Plans" else other_fg, right_weight, anchor="middle")
    s.circle(423, 99, 25, t.tertiary)
    s.text(423, 105, avatar, 15, t.on_tertiary, 850, anchor="middle")


def edit_affordance(s: Svg, x, y, color):
    s.circle(x + 14, y + 14, 18, color, None)
    s.icon("edit", x + 3, y + 3, 23, color)


def make_heatmap_svg(t: Palette):
    src = (ROOT / "assets" / "body_heatmap.svg").read_text(encoding="utf-8")
    src = re.sub(r"<\?xml[^>]*\?>", "", src)
    src = re.sub(r"<!--.*?-->", "", src, flags=re.DOTALL)
    src = re.sub(r"<metadata.*?</metadata>", "", src, flags=re.DOTALL)
    prefix = f"m3e_{'dark' if t.dark else 'light'}"
    src = re.sub(r'id="([^"]+)"', lambda m: f'id="{prefix}_{m.group(1)}"', src)
    src = re.sub(r"url\(#([^\)]+)\)", lambda m: f"url(#{prefix}_{m.group(1)})", src)
    src = re.sub(r'(?:xlink:href|href)="#([^"]+)"', lambda m: f'{m.group(0).split("=")[0]}="#{prefix}_{m.group(1)}"', src)
    src = re.sub(r'width="[^"]+"', 'width="190"', src, count=1)
    src = re.sub(r'height="[^"]+"', 'height="228"', src, count=1)
    src = src.replace("<svg", '<svg x="36" y="218" preserveAspectRatio="xMidYMid meet"', 1)
    values = {
        "Upper_Back": 1.0,
        "Hip_back_left": 18 / 19,
        "hip_right_rear": 18 / 19,
        "Quad_Front_Right": 17 / 19,
        "Quad_Left_front": 17 / 19,
    }

    def blend(a: str, b: str, amount: float) -> str:
        ca = [int(a[k:k + 2], 16) for k in (1, 3, 5)]
        cb = [int(b[k:k + 2], 16) for k in (1, 3, 5)]
        return "#" + "".join(f"{round(x + (y - x) * amount):02X}" for x, y in zip(ca, cb))

    def paint(match):
        tag = match.group(0)
        id_match = re.search(rf'id="{re.escape(prefix)}_(.+?)"', tag)
        source_id = id_match.group(1) if id_match else ""
        amount = values.get(source_id, 0.0)
        fill = blend(t.heat_low, t.heat_high, amount) if amount else t.heat_low
        tag = re.sub(r'\sfill="[^"]*"', "", tag)
        style = re.search(r'\sstyle="([^"]*)"', tag)
        if style:
            clean = re.sub(r"\bfill\s*:\s*#[0-9a-fA-F]+\s*;?", "", style.group(1), flags=re.I)
            clean = ";".join(part.strip() for part in clean.split(";") if part.strip())
            tag = tag[:style.start()] + (f' style="{clean}"' if clean else "") + tag[style.end():]
        closing = "/>" if tag.endswith("/>") else ">"
        return tag[:-len(closing)] + f' fill="{fill}"{closing}'

    return re.sub(r"<path\b[^>]*>", paint, src, flags=re.I)


def render_heatmap(s: Svg, t: Palette):
    s.add(make_heatmap_svg(t))


def plan_row(s: Svg, t: Palette, name: str, y: int, accent: str, container: str, crop_file: str, crop_box):
    s.asym(37, y, 396, 71, container, 26, 15, 24, 16)
    s.rect(37, y + 8, 6, 55, accent, 3)
    s.crop(REF / crop_file, crop_box, 53, y + 9, 52, 52, 10)
    s.text(123, y + 43, name, 19, accent, 800)
    s.circle(342, y + 35, 12, "#38CE5D")
    s.text(342, y + 39, "A", 11, "#FFFFFF", 850, anchor="middle")
    s.icon("more", 389, y + 25, 20, accent)


def draw_overview(t: Palette):
    s = base_screen(t, "11:29")
    train_tabs(s, t, "Overview")

    # Weekly overview: anatomy and the exact three body-focus values remain the content.
    s.asym(18, 146, 434, 351, t.surface2, 42, 23, 42, 22)
    s.text(39, 190, "Weekly Overview", 27, t.ink, 850)
    s.rect(35, 207, 388, 1.5, t.outline, 1, opacity=0.35)
    render_heatmap(s, t)
    s.text(218, 231, "FOCUSED SETS", 11, t.secondary, 850, spacing=1.4)
    s.asym(210, 246, 216, 78, t.secondary_container, 24, 13, 24, 14)
    s.text(226, 275, "Upper Back", 16, t.on_secondary_container, 750)
    s.text(405, 289, "19", 29, t.on_secondary_container, 900, anchor="end")
    s.rect(226, 303, 160, 7, t.surface, 4, opacity=0.9)
    s.rect(226, 303, 158, 7, t.secondary, 4)
    s.text(226, 352, "Hips", 15, t.ink, 650)
    s.text(405, 352, "18", 17, t.ink, 850, anchor="end")
    s.rect(226, 364, 160, 5, t.surface3, 3)
    s.rect(226, 364, 151, 5, t.secondary, 3)
    s.text(226, 400, "Quads", 15, t.ink, 650)
    s.text(405, 400, "17", 17, t.ink, 850, anchor="end")
    s.rect(226, 412, 160, 5, t.surface3, 3)
    s.rect(226, 412, 143, 5, t.tertiary, 3)
    s.asym(219, 433, 120, 38, t.tertiary_container, 19, 12, 16, 14)
    s.text(279, 458, "···  more", 13, t.on_tertiary_container, 800, anchor="middle")

    # Active plans preserve the user's two named, color-coded cards and quick actions.
    s.text(31, 540, "Active Plans", 26, t.ink, 850)
    s.icon("edit", 412, 516, 26, t.secondary)
    plan_row(s, t, "Full Body", 574, t.plan_blue, t.plan_blue_container, "train-overview.png", (60, 585, 59, 61))
    plan_row(s, t, "Upper 1", 657, t.plan_orange, t.plan_orange_container, "train-overview.png", (60, 687, 59, 61))

    # One large start action outranks Optimize and its settings affordance.
    s.asym(20, 773, 265, 78, t.primary, 34, 18, 28, 40)
    s.icon("dumbbell", 48, 798, 26, t.on_primary)
    s.text(174, 821, "Start Workout", 20, t.on_primary, 850, anchor="middle")
    s.asym(294, 784, 119, 57, t.secondary_container, 28, 17, 26, 18)
    s.text(353, 819, "Optimize", 15, t.on_secondary_container, 800, anchor="middle")
    s.circle(433, 812, 25, t.tertiary_container)
    s.icon("settings", 421, 800, 24, t.on_tertiary_container)
    bottom_nav(s, t, "Train")
    return s


def draw_plans(t: Palette):
    s = base_screen(t, "11:29")
    train_tabs(s, t, "Plans")

    s.text(29, 174, "Active Plans", 27, t.ink, 850)
    s.icon("edit", 412, 146, 26, t.secondary)
    plan_row(s, t, "Full Body", 217, t.plan_blue, t.plan_blue_container, "train-plans.png", (53, 247, 63, 65))
    plan_row(s, t, "Upper 1", 302, t.plan_orange, t.plan_orange_container, "train-plans.png", (53, 359, 63, 65))

    s.asym(20, 397, 430, 153, t.surface1, 33, 18, 34, 18)
    s.text(40, 440, "Archived Plans", 24, t.ink, 850)
    s.icon("edit", 412, 412, 23, t.muted)
    s.circle(62, 494, 17, t.surface3)
    s.icon("history", 50, 482, 24, t.muted)
    s.text(92, 500, "No archived plans.", 16, t.sub, 550)

    # Keep the editorial discovery card inviting while leaving plan state and the CTA ahead of it.
    s.asym(18, 566, 434, 245, t.surface1, 42, 16, 38, 17)
    s.asym(35, 583, 67, 67, t.tertiary_container, 26, 16, 25, 17)
    s.icon("book", 53, 600, 31, t.on_tertiary_container)
    s.text(119, 621, "Premade Plans", 24, t.ink, 800)
    text_lines(s, 40, 676, ["34 curated routines are available to", "copy into your plans."], 15, t.sub, 500, 23)
    s.asym(38, 724, 391, 62, t.surface2, 30, 14, 28, 16)
    s.icon("arrow", 58, 743, 25, t.tertiary, sw=2.2)
    s.text(254, 762, "Browse Premade Plans", 15, t.tertiary, 750, anchor="middle")

    s.asym(19, 818, 432, 58, t.primary_container, 31, 13, 29, 17)
    s.icon("spark", 37, 833, 24, t.on_primary_container)
    s.text(92, 854, "Generate Custom Plans", 16, t.on_primary_container, 850)
    bottom_nav(s, t, "Train")
    return s


def checkbox(s: Svg, x, y, t: Palette, checked: bool, size=22, completed=False):
    fill = (t.success if completed else t.primary) if checked else t.surface
    s.rect(x, y, size, size, fill, 6, None if checked else t.outline, 1.5)
    if checked:
        s.icon("check", x + 3, y + 3, size - 6, t.on_success if completed else t.on_primary, sw=2.5)


def field(s: Svg, t: Palette, x, y, w, label, value, active=False):
    fill = t.surface if not t.dark else t.canvas
    edge = t.primary if active else t.outline
    s.asym(x, y, w, 48, fill, 13, 9, 14, 8, edge, 1.1)
    s.text(x + 9, y + 13, label, 8.5, t.muted, 600)
    s.text(x + 9, y + 36, value, 16, t.ink, 700)


def set_row(s: Svg, t: Palette, x, y, set_label, weight, reps, checked):
    row_fill = t.success_subtle if checked else (t.surface1 if not t.dark else t.surface)
    s.asym(x, y, 401, 58, row_fill, 23, 10, 20, 12)
    checkbox(s, x + 11, y + 17, t, checked, 22, completed=checked)
    s.text(x + 43, y + 37, set_label, 13.5, t.ink, 750)
    field(s, t, x + 116, y + 5, 133, "Weight (lbs)", weight, active=not checked and set_label == "Set 2")
    field(s, t, x + 257, y + 5, 88, "Reps", reps, active=False)
    s.circle(x + 375, y + 29, 13, t.surface if checked else t.surface2, t.outline, 1)
    s.icon("minus", x + 367, y + 21, 16, t.muted, sw=2.2)


def exercise_header(s: Svg, t: Palette, name: str, done: str, y: int, thumb_box, state: str):
    head_fill = t.success_subtle if state == "complete" else t.secondary_container
    s.asym(20, y, 430, 82, head_fill, 37, 13, 31, 16)
    if state == "active":
        s.asym(20, y, 8, 82, t.secondary, 8, 0, 8, 0)
    s.text(43, y + 38, name, 20 if state == "active" else 18, t.secondary if state == "active" else t.ink, 850 if state == "active" else 750)
    if state == "complete":
        s.circle(55, y + 60, 8, t.success)
        s.icon("check", 49, y + 54, 12, t.success_ink, sw=2.7)
    else:
        s.circle(55, y + 60, 8, t.secondary)
        s.circle(55, y + 60, 3, t.on_secondary)
    done_color = t.success if state == "complete" else t.secondary
    s.text(70, y + 66, done, 13, done_color, 700)
    s.crop(REF / "active-workout-session.png", thumb_box, 330, y + 13, 55, 55, 10)
    s.icon("more", 407, y + 28, 23, t.ink)


def draw_session(t: Palette):
    s = base_screen(t, "11:31")
    s.icon("menu", 25, 76, 26, t.ink)
    s.text(235, 96, "Workout Session", 25, t.ink, 800, anchor="middle")

    exercise_header(s, t, "Barbell Squat", "2/2 done", 120, (318, 156, 56, 56), "complete")
    exercise_header(s, t, "Bench Press - Barbell", "1/1 done", 215, (317, 266, 56, 56), "complete")
    s.line(39, 304, 430, 304, t.outline, 1, 0.45)
    s.text(167, 326, "Weight (lbs)", 11, t.muted, 650, anchor="middle")
    s.text(309, 326, "Reps", 11, t.muted, 650, anchor="middle")
    set_row(s, t, 34, 337, "Set 1", "15", "10", True)
    s.asym(280, 405, 138, 37, t.secondary_subtle, 22, 10, 20, 10)
    s.icon("plus", 294, 414, 19, t.secondary)
    s.text(363, 430, "Add Set", 14, t.secondary, 800, anchor="middle")

    exercise_header(s, t, "Arnold Press", "1/2 done", 463, (318, 522, 57, 58), "active")
    s.line(39, 550, 430, 550, t.outline, 1, 0.45)
    s.text(167, 574, "Weight (lbs)", 11, t.muted, 650, anchor="middle")
    s.text(309, 574, "Reps", 11, t.muted, 650, anchor="middle")
    set_row(s, t, 34, 583, "Set 1", "115", "10", True)
    set_row(s, t, 34, 650, "Set 2", "115", "10", False)
    s.asym(280, 719, 138, 37, t.secondary_subtle, 22, 10, 20, 10)
    s.icon("plus", 294, 728, 19, t.secondary)
    s.text(363, 744, "Add Set", 14, t.secondary, 750, anchor="middle")

    # Keep the current add-exercise FAB and pinned finish action.
    s.asym(375, 790, 72, 72, t.secondary, 35, 17, 36, 18)
    s.icon("plus", 398, 813, 27, t.on_secondary, sw=2.2)
    s.asym(18, 901, 434, 70, t.primary, 32, 16, 30, 19)
    s.icon("check", 113, 923, 25, t.on_primary, sw=2.5)
    s.text(260, 946, "Finish Workout", 20, t.on_primary, 850, anchor="middle")
    return s


def metric_tile(s: Svg, t: Palette, x, y, w, h, label, value, delta=None, fill=None, ink=None, focal=False):
    fill = fill or t.surface1
    ink = ink or t.ink
    s.asym(x, y, w, h, fill, 32 if focal else 20, 11, 28 if focal else 18, 13 if focal else 10)
    s.text(x + 15, y + (27 if focal else 19), label, 13 if focal else 11, ink, 750)
    s.text(x + 15, y + (89 if focal else 45), value, 48 if focal else 23, ink, 900)
    if delta:
        if focal:
            s.asym(x + 11, y + h - 32, w - 22, 22, t.error_container, 12, 7, 12, 7)
            s.text(x + 18, y + h - 16, delta, 10, t.error, 750)
        else:
            s.text(x + 15, y + h - 8, delta, 9.5, t.error, 750)


def draw_progress(t: Palette):
    s = base_screen(t, "11:31")
    s.asym(18, 70, 434, 588, t.surface, 42, 18, 38, 18)
    s.text(39, 117, "Workout Report", 27, t.ink, 900)

    metric_tile(s, t, 34, 137, 190, 140, "Workouts", "6", "↓ 6 workouts", t.primary, t.on_primary, True)
    s.text(82, 226, "total", 12, t.on_primary, 550)
    metric_tile(s, t, 237, 137, 195, 80, "Time", "1m 54s", "↓ 1m 54s", t.secondary_subtle, t.secondary)
    metric_tile(s, t, 237, 225, 195, 80, "Volume", "15k lbs", "↓ 15k lbs", t.tertiary_subtle, t.tertiary)

    s.asym(34, 318, 398, 211, t.surface2, 30, 13, 30, 13)
    s.text(52, 349, "Workouts (All)", 18, t.ink, 850)
    chart_x, chart_y, chart_w, chart_h = 79, 376, 326, 104
    for i, value in enumerate((6, 5, 4, 3, 2, 1, 0)):
        gy = chart_y + i * (chart_h / 6)
        s.line(chart_x, gy, chart_x + chart_w, gy, t.outline, 0.8, 0.38, dash="3 5")
        if value in (6, 4, 2, 0):
            s.text(63, gy + 4, str(value), 9.5, t.muted, 500, anchor="end")
    # The report series remains the captured purple data series, including its decline.
    points = [(96, 379), (394, 480)]
    s.path("M96 379 L394 480 L394 480 L96 480 Z", t.chart, opacity=0.13)
    s.path("M96 379 L394 480", "none", t.chart, 4.5)
    s.circle(96, 379, 5, t.chart)
    s.circle(394, 480, 5, t.chart)
    s.text(96, 507, "21 SEP", 10, t.muted, 650, anchor="middle")
    s.text(394, 507, "28 SEP", 10, t.muted, 650, anchor="middle")

    s.asym(34, 542, 398, 49, t.surface1, 25, 12, 25, 12)
    range_labels = ["1W", "1M", "3M", "6M", "1Y", "All"]
    for i, label in enumerate(range_labels):
        cx = 67 + i * 67
        if label == "All":
            s.asym(cx - 30, 546, 61, 41, t.secondary_container, 25, 10, 23, 12)
        s.text(cx, 573, label, 13, t.on_secondary_container if label == "All" else t.ink, 850 if label == "All" else 650, anchor="middle")
    s.text(48, 631, "Additional Details", 15, t.ink, 750)
    s.path("M404 624l7 7 7-7", "none", t.secondary, 2.3)

    # The next current card begins below the report and remains partially visible above nav.
    s.asym(18, 676, 434, 273, t.surface1, 42, 16, 38, 18)
    s.text(40, 720, "Exercise progress", 25, t.ink, 850)
    s.asym(34, 737, 400, 187, t.surface, 27, 13, 28, 13)
    s.text(52, 774, "Barbell Squat", 17, t.ink, 850)
    s.path("M405 761l7 7-7 7", "none", t.muted, 2)
    for gy in (804, 836, 868):
        s.line(56, gy, 255, gy, t.outline, 0.7, 0.36)
    s.path("M61 862 L136 845 L239 803", "none", t.chart_blue, 3, dash="7 6")
    s.circle(136, 845, 4, t.chart_blue)
    s.circle(239, 803, 4, t.chart_blue)
    s.asym(278, 789, 139, 62, t.surface2, 20, 11, 19, 11)
    s.text(291, 811, "1 Rep Max", 10, t.muted, 650)
    s.text(291, 839, "--   --", 16, t.ink, 850)
    s.asym(278, 861, 139, 48, t.surface2, 18, 10, 18, 10)
    s.text(291, 880, "Est. 1RM", 9.5, t.muted, 650)
    s.text(291, 901, "--", 14, t.ink, 850)
    bottom_nav(s, t, "Progress")
    return s


def setting_icon(s: Svg, t: Palette, x, y, name, fill, color):
    s.asym(x, y, 47, 47, fill, 22, 12, 20, 13)
    s.icon(name, x + 11, y + 11, 25, color)


def settings_row(s: Svg, t: Palette, y: int, title: str, subtitle: str, icon_name: str, icon_fill: str, icon_color: str, trailing: str = "arrow", value: str = ""):
    s.text(88, y + 26, title, 16, t.ink, 800)
    text_lines(s, 88, y + 48, subtitle.split("\n"), 12, t.sub, 450, 15)
    setting_icon(s, t, 35, y + 8, icon_name, icon_fill, icon_color)
    if trailing == "arrow":
        s.path(f"M421 {y + 25}l7 7-7 7", "none", t.muted, 2)
    elif trailing == "switch":
        s.asym(372, y + 13, 62, 35, t.surface3, 18, 12, 18, 12)
        s.circle(390, y + 30, 12, t.surface)
    elif trailing == "value":
        s.text(430, y + 35, value, 12.5, t.secondary, 800, anchor="end")
    elif trailing == "plain":
        s.text(430, y + 35, value, 12.5, t.secondary, 800, anchor="end")


def section_title(s: Svg, t: Palette, x, y, title, accent=None):
    s.rect(x + 3, y - 23, 5, 34, accent or t.secondary, 3)
    s.text(x + 24, y, title, 18, t.ink, 850)


def draw_profile(t: Palette):
    s = base_screen(t, "11:32")
    # Profile keeps its Iris focal hero; settings groups use quieter neutral containers.
    s.asym(19, 72, 432, 159, t.secondary, 54, 19, 42, 20)
    s.asym(39, 104, 78, 82, t.tertiary, 40, 19, 42, 20)
    s.icon("person", 64, 127, 31, t.on_tertiary, filled=True)
    s.text(139, 132, "Profile", 38, t.on_secondary, 900)
    text_lines(s, 140, 161, ["Personalize Tonos, manage training", "defaults, and keep your data healthy."], 14, t.on_secondary, 500, 20)

    section_title(s, t, 27, 269, "Account", t.secondary)
    s.text(51, 291, "Your identity and app-level appearance.", 12, t.sub, 450)
    s.asym(20, 306, 430, 204, t.surface1, 38, 14, 36, 17)
    rows = [
        ("User Information", "Name, body details, and activity profile.", "badge", t.surface2, t.secondary),
        ("UI & Appearance", "Theme, onboarding, and bottom tab setup.", "palette", t.surface2, t.secondary),
        ("Guided Tutorials", "Replay walkthroughs and reset guided help.", "users", t.surface2, t.secondary),
    ]
    for i, (title, subtitle, icon, fill, color) in enumerate(rows):
        y = 318 + i * 61
        setting_icon(s, t, 37, y + 1, icon, fill, color)
        s.text(98, y + 22, title, 15.5, t.ink, 800)
        s.text(98, y + 43, subtitle, 11.5, t.sub, 450)
        s.path(f"M420 {y + 16}l7 7-7 7", "none", t.muted, 1.8)
        if i < 2:
            s.line(97, y + 55, 424, y + 55, t.outline, 0.7, 0.35)

    section_title(s, t, 27, 553, "Training", t.secondary)
    s.text(51, 575, "Exercise defaults and progress-related controls.", 12, t.sub, 450)
    s.asym(20, 590, 430, 145, t.surface2, 36, 13, 34, 17)
    settings_row(s, t, 599, "Gym & Workout Settings", "Workout generation, rankings, flows,\nand equipment logic.", "dumbbell", t.surface3, t.secondary)
    s.line(97, 667, 424, 667, t.outline, 0.7, 0.34)
    settings_row(s, t, 672, "Progress Settings", "Measurement and trend tracking setup.", "trend", t.surface3, t.secondary)

    section_title(s, t, 27, 854, "Data", "#2585D0")
    bottom_nav(s, t, "Profile")
    return s


def draw_appearance(t: Palette):
    s = base_screen(t, "11:32")
    s.icon("back", 30, 72, 27, t.ink)
    s.asym(20, 114, 430, 129, t.secondary, 50, 17, 40, 18)
    s.asym(38, 138, 67, 68, t.tertiary, 34, 17, 35, 18)
    s.icon("palette", 58, 157, 28, t.on_tertiary)
    s.text(122, 164, "UI & Appearance", 28, t.on_secondary, 900)
    text_lines(s, 123, 190, ["Control the way Tonos looks and", "how the bottom tabs behave."], 12.5, t.on_secondary, 500, 18)

    section_title(s, t, 27, 275, "Display", t.secondary)
    s.text(51, 297, "Quick visual preferences.", 12, t.sub, 450)
    s.asym(20, 313, 430, 428, t.surface1, 38, 14, 36, 17)

    settings_row(s, t, 319, "Theme family", "Choose the visual family\nindependently of light or dark mode.", "palette", t.surface2, t.secondary, "value", "Classic")
    s.line(98, 386, 424, 386, t.outline, 0.7, 0.35)
    settings_row(s, t, 391, "Dark Mode", "Use the darker app theme.", "moon", t.surface2, t.secondary, "switch")
    s.line(98, 449, 424, 449, t.outline, 0.7, 0.35)
    settings_row(s, t, 454, "Replay Onboarding", "Turn this on to open setup again.\nIt turns off after completion.", "spark", t.surface2, t.secondary, "switch")
    s.line(98, 520, 424, 520, t.outline, 0.7, 0.35)
    settings_row(s, t, 525, "Weight Units", "Show workout weights and\nvolume in lbs.", "weight", t.surface2, t.secondary, "value", "Pounds")
    s.line(98, 591, 424, 591, t.outline, 0.7, 0.35)
    settings_row(s, t, 596, "Language", "Choose the language\nTonos uses.", "globe", t.surface2, t.secondary, "value", "System default")

    section_title(s, t, 27, 785, "Navigation", "#2486D1")
    s.text(51, 807, "Choose which bottom tabs show up and in what order.", 11.5, t.sub, 450)
    s.asym(20, 822, 430, 87, "#D8EDFF" if not t.dark else "#183653", 30, 14, 31, 15)
    setting_icon(s, t, 36, 841, "home", "#B9E0FF" if not t.dark else "#214A6B", "#1687CF" if not t.dark else "#71C3FF")
    s.text(98, 857, "Edit Bottom Tabs", 16, t.ink, 800)
    s.text(98, 879, "Reorder your app destinations.", 12, t.sub, 450)
    s.path("M420 851l7 7-7 7", "none", t.muted, 2)
    home_bar(s, t)
    return s


def draw_units_dialog(t: Palette):
    s = draw_appearance(t)
    s.rect(0, 0, PHONE_W, PHONE_H, t.dim_scrim, 0, opacity=0.50)
    # Lifted neutral modal with Iris selection and an unselected neutral option.
    s.asym(37, 363, 396, 300, t.surface, 52, 17, 48, 21)
    s.text(69, 415, "Weight Units", 29, t.ink, 850)
    s.asym(55, 461, 360, 83, t.secondary_container, 36, 14, 32, 16)
    s.circle(86, 502, 12, "none", t.secondary, 2)
    s.circle(86, 502, 6, t.secondary)
    s.text(118, 496, "Pounds", 18, t.on_secondary_container, 800)
    s.text(118, 521, "lbs", 12.5, t.on_secondary_container, 600)
    s.asym(58, 557, 354, 75, t.surface1, 25, 11, 24, 13)
    s.circle(87, 594, 11, "none", t.muted, 1.8)
    s.text(119, 590, "Kilograms", 17, t.ink, 700)
    s.text(119, 612, "kg", 12, t.sub, 500)
    return s


def screens(t: Palette):
    return {
        "train-overview": draw_overview(t),
        "train-plans": draw_plans(t),
        "active-workout": draw_session(t),
        "progress": draw_progress(t),
        "profile": draw_profile(t),
        "ui-appearance": draw_appearance(t),
        "weight-units": draw_units_dialog(t),
    }


def write_svg(name: str, svg: str):
    path = OUT / f"{name}.svg"
    path.write_text(svg, encoding="utf-8")
    return path


def render(svg_path: Path, png_path: Path):
    subprocess.run(
        ["magick", "-background", "none", str(svg_path), "-strip", str(png_path)],
        check=True,
        stdout=subprocess.DEVNULL,
    )


SCREEN_META = [
    ("train-overview", "Train / Overview", "Train and selected Overview", "Full Body, Upper 1; Focused Sets: Upper Back 19, Hips 18, Quads 17; Start Workout, Optimize, settings."),
    ("train-plans", "Train / Plans", "Train and selected Plans", "Full Body and Upper 1; empty Archived Plans; 34 Premade Plans; Browse and visible Generate Custom Plans action."),
    ("active-workout", "Active Workout / Session", "Workout Session", "Barbell Squat 2/2 complete and collapsed; Bench Press - Barbell 1/1 complete and open; Arnold Press 1/2 complete and open."),
    ("progress", "Progress", "Progress selected", "Workout Report 6, 1m 54s, 15k lbs with the displayed negative deltas; Sep 21–28 report; All selected; Barbell Squat progress starts below."),
    ("profile", "Profile", "Profile selected", "Profile hero; Account and Training groups; Data heading and the next settings card beginning at the bottom."),
    ("ui-appearance", "Profile / UI & Appearance", "UI & Appearance", "Classic family value; Dark Mode off; Replay Onboarding off; Pounds; System default; Edit Bottom Tabs."),
    ("weight-units", "Weight Units dialog", "UI & Appearance with Weight Units open", "Pounds selected; Kilograms available; current Appearance screen remains visible under the scrim."),
]


def make_comparison(key: str, title: str, state: str, reference_png: Path):
    s = Svg(2200, 1310)
    s.rect(0, 0, 2200, 1310, "#E7E2DF")
    s.text(52, 61, title, 35, "#22172B", 850)
    s.text(54, 91, "Same captured Tonos content and state · expressive light and dark theme directions", 15, "#5B4D62", 500)
    s.asym(1780, 29, 365, 54, "#F7F1F8", 27, 12, 27, 12)
    nav_label = "FIVE-DESTINATION APP NAV" if key in {"train-overview", "train-plans", "progress", "profile"} else "CURRENT ROUTE · NO APP NAV"
    s.text(1963, 63, nav_label, 12, "#5B4D62", 800, anchor="middle", spacing=0.6)
    xcols = [26, 760, 1494]
    colw = 680
    images = [reference_png, OUT / f"{key}-m3e-light.png", OUT / f"{key}-m3e-dark.png"]
    labels = ["CLASSIC LIGHT · SUPPLIED REFERENCE", "MATERIAL 3 EXPRESSIVE · LIGHT", "MATERIAL 3 EXPRESSIVE · DARK"]
    for i, x in enumerate(xcols):
        s.asym(x, 117, colw, 1170, "#F8F4F2" if i < 2 else "#251E2C", 38, 16, 38, 16)
        label_color = "#615466" if i < 2 else "#D5C8DA"
        s.text(x + colw / 2, 160, labels[i], 12, label_color, 850, anchor="middle", spacing=0.8)
        s.embed(images[i], x + 92, 178, 496, 1075)
    s.text(1100, 1292, "Classic Light captures are preserved verbatim; M3E geometry is a design exploration of the same Tonos workflow.", 11, "#625569", 500, anchor="middle")
    return s.finish()


def panel(s: Svg, x, y, w, h, fill, title, title_color="#33233E"):
    s.asym(x, y, w, h, fill, 36, 15, 35, 16)
    s.text(x + 24, y + 38, title, 18, title_color, 850)


def make_design_board():
    s = Svg(2200, 1820)
    s.rect(0, 0, 2200, 1820, "#E7E2DF")
    s.text(54, 68, "Tonos · Material 3 Expressive", 40, "#20162B", 900)
    s.text(58, 104, "Visual implementation contract · Training Jade / Iris / Apricot · system font · data semantics remain independent", 16, "#5B4D62", 500)

    # Theme accents, semantic states, and Tonos data colors have separate owners.
    panel(s, 34, 132, 2132, 365, "#F8F5F2", "01   Color ownership · theme accents do not replace meaning")
    role_cards = [
        ("JADE · PRIMARY / ACTION", "#006B58", "#66E0C1", "Primary actions and limited focal emphasis"),
        ("IRIS · STRUCTURE / SELECTION", "#694097", "#D8B9FF", "Hierarchy, selection, focused context"),
        ("APRICOT · TERTIARY", "#A74717", "#FFB68F", "Sparse warm accent and tertiary distinction"),
        ("SEMANTIC STATES", "#2E754C", "#A4E7B8", "Success ≠ Jade · errors and warnings stay separate."),
    ]
    for i, (label, light, dark, detail) in enumerate(role_cards):
        x = 58 + i * 520
        s.asym(x, 192, 490, 76, "#FFFCFA", 22, 11, 20, 12, "#D8CFCC", 0.8)
        s.circle(x + 23, 216, 8, light)
        s.circle(x + 44, 216, 8, dark)
        s.text(x + 62, 219, label, 12, "#33263D", 850)
        s.text(x + 62, 244, f"L {light}   ·   D {dark}", 11.5, "#6A5D70", 650)
        s.text(x + 252, 244, detail, 10.5, "#6A5D70", 550)

    data_cards = [
        ("CHART SERIES", "#7700E8", "#268DE0", "A #7700E8 / B #268DE0", "Purple + blue remain chart-owned."),
        ("BODY HEATMAP", "#287AD2", "#398AE7", "#287AD2 → #398AE7", "Blue activity scale stays data-owned."),
        ("PLAN IDENTITIES", "#087CC4", "#AD5100", "Blue #087CC4 / orange #AD5100", "Full Body blue · Upper 1 orange."),
        ("PROFILE / GYM / NUTRITION", None, None, "Domain-owned colors", "No theme color substitution."),
    ]
    for i, (label, light, dark, values, detail) in enumerate(data_cards):
        x = 58 + i * 520
        s.asym(x, 280, 490, 76, "#F0ECE9", 21, 10, 21, 11)
        if light and dark:
            s.circle(x + 23, 304, 8, light)
            s.circle(x + 44, 304, 8, dark)
        else:
            s.circle(x + 23, 304, 8, "none", "#74677B", 1.5)
            s.circle(x + 44, 304, 8, "none", "#74677B", 1.5)
        s.text(x + 62, 307, label, 12, "#33263D", 850)
        s.text(x + 62, 332, values, 10.5, "#6A5D70", 650)
        s.text(x + 252, 332, detail, 10.5, "#6A5D70", 550)
    s.text(58, 406, "OWNERSHIP RULE", 11, "#694097", 850, spacing=0.7)
    s.text(58, 432, "Theme color supports hierarchy; success, error, warning, chart, heatmap, plan, profile, gym, and nutrition colors retain their domain meaning.", 15, "#4F4552", 650)

    # Exact light and dark surface ladders used to ground the route mockups.
    panel(s, 34, 510, 2132, 312, "#F8F5F2", "02   Surface ladders · light relationships stay neutral; dark relationships stay plum / iris")
    s.text(58, 575, "LIGHT", 13, "#694097", 850, spacing=0.8)
    light_roles = [
        ("Canvas", "#F4F1EE"), ("Low container", "#F0ECE9"), ("Section container", "#E8E2EA"),
        ("Selected container", "#EBD8FF"), ("Lifted / modal", "#FFFCFA"),
    ]
    for i, (label, color) in enumerate(light_roles):
        x = 58 + i * 198
        s.asym(x, 591, 178, 78, color, 25, 11, 24, 12, "#D7CECC", 0.8)
        s.text(x + 89, 638, label, 13, "#30253A", 750, anchor="middle")
        s.text(x + 89, 657, color, 11, "#62566A", 550, anchor="middle")

    s.text(1100, 575, "DARK", 13, "#694097", 850, spacing=0.8)
    dark_roles = [
        ("Canvas", "#17121D", "#F7EFFA"), ("Surface", "#211A29", "#F7EFFA"),
        ("Container", "#352A40", "#F7EFFA"), ("Selected", "#593778", "#F1DFFF"),
        ("Primary action", "#66E0C1", "#00382D"), ("Tertiary signal", "#FFB68F", "#4C1E00"),
    ]
    for i, (label, color, ink) in enumerate(dark_roles):
        x = 1100 + i * 174
        s.asym(x, 591, 154, 78, color, 25, 11, 24, 12)
        s.text(x + 77, 638, label, 12, ink, 750, anchor="middle")
        s.text(x + 77, 657, color, 11, ink, 550, anchor="middle")
    s.text(58, 704, "Light: warm tonal canvas → low group → section → Iris selection → lifted surface.", 14, "#5E535F", 650)
    s.text(1100, 704, "Dark: deep plum-black canvas → lifted plum surfaces → Iris selection; Jade and Apricot stay role-specific.", 14, "#5E535F", 650)

    # Shape and type roles use the same family with different component jobs.
    panel(s, 34, 839, 1018, 353, "#F8F5F2", "03   Shape roles · visible on the route mockups")
    shape_specs = [
        ("Hero", "#694097", (42, 17, 38, 19)),
        ("Section", "#E8E2EA", (36, 14, 34, 17)),
        ("Metric", "#EBD8FF", (32, 11, 28, 13)),
        ("Action", "#006B58", (36, 14, 31, 19)),
        ("Selection", "#593778", (27, 10, 24, 13)),
        ("Status", "#EAF2E9", (21, 9, 19, 10)),
    ]
    for i, (label, fill, radii) in enumerate(shape_specs):
        x = 58 + i * 158
        tl, tr, br, bl = radii
        s.asym(x, 908, 132, 94, fill, tl, tr, br, bl)
        ink = "#FFFFFF" if fill in ("#694097", "#006B58", "#593778") else "#33243D"
        s.text(x + 66, 963, label, 14, ink, 800, anchor="middle")
        s.text(x + 66, 1024, f"{tl} / {tr} / {br} / {bl}", 11, "#6B5B72", 600, anchor="middle")
    s.asym(58, 1061, 969, 84, "#E8E2EA", 36, 14, 34, 17)
    s.text(82, 1097, "Hero scale stays rare; repeated rows and controls stay compact.", 15, "#36263E", 700)
    s.text(82, 1123, "Shape signals role, not decoration. No universal capsule rule.", 13, "#6A5D70", 550)

    panel(s, 1070, 839, 1096, 353, "#30253A", "04   Typography roles · current/system sans", "#F7EFFA")
    type_roles = [
        ("HERO · 30 / 850", "Profile", 30, "#F7EFFA", 850),
        ("SECTION · 20 / 750", "Active Plans", 20, "#D8B9FF", 750),
        ("CARD · 17 / 700", "Bench Press", 17, "#F7EFFA", 700),
        ("METRIC · 44 / 900", "6", 44, "#66E0C1", 900),
        ("BODY · 14 / 500", "Weight · 115", 14, "#D2C4D8", 500),
        ("METADATA · 13 / 500", "1/2 done · today", 13, "#AA9CB0", 500),
    ]
    for i, (label, sample, size, ink, weight) in enumerate(type_roles):
        col, row = i % 3, i // 3
        x = 1094 + col * 346
        y = 902 + row * 117
        s.asym(x, y, 322, 98, "#3B2F45", 22, 10, 21, 11)
        s.text(x + 17, y + 25, label, 11.5, "#D2C4D8", 750)
        s.text(x + 17, y + 68, sample, size, ink, weight)
    s.text(1094, 1148, "Scale and color share the hierarchy; weight alone does not.", 14, "#E4D9E8", 550)

    # Route-relevant action and workout states, plus the actual dialog selection pattern.
    panel(s, 34, 1208, 652, 570, "#F8F5F2", "05   Action hierarchy")
    s.text(58, 1270, "PRIMARY · JADE", 12, "#6B5B72", 800, spacing=0.8)
    s.asym(58, 1284, 600, 68, "#006B58", 36, 14, 31, 18)
    s.icon("dumbbell", 83, 1306, 25, "#FFFFFF")
    s.text(361, 1327, "Start / Finish Workout", 18, "#FFFFFF", 850, anchor="middle")
    s.text(58, 1382, "SECONDARY · IRIS", 12, "#6B5B72", 800, spacing=0.8)
    s.asym(58, 1394, 258, 53, "#EBD8FF", 26, 11, 24, 12)
    s.text(187, 1428, "Optimize", 15, "#30104D", 800, anchor="middle")
    s.text(331, 1428, "Lower-priority action stays quieter.", 13, "#62566A", 550)
    s.text(58, 1476, "TERTIARY / SUPPORTING · APRICOT", 12, "#6B5B72", 800, spacing=0.8)
    s.asym(58, 1488, 300, 50, "#F0ECE9", 22, 10, 20, 11, "#A74717", 1.2)
    s.icon("arrow", 78, 1502, 21, "#A74717", sw=2)
    s.text(226, 1520, "Browse Premade Plans", 13, "#8F421C", 700, anchor="middle")
    s.text(58, 1575, "FIVE-DESTINATION NAVIGATION · TRAIN SELECTED", 12, "#D2C4D8", 750, spacing=0.5)
    s.rect(58, 1589, 600, 150, "#352A40", 26)
    navitems = [("Train", "dumbbell"), ("Catalog", "book"), ("Logbook", "history"), ("Progress", "trend"), ("Profile", "person")]
    for i, (label, icon_name) in enumerate(navitems):
        cx = 118 + i * 119
        if i == 0:
            s.asym(cx - 34, 1604, 68, 53, "#593778", 26, 12, 23, 14)
            icon_color = "#F1DFFF"
            label_color = "#F1DFFF"
            weight = 800
        else:
            icon_color = "#D2C4D8"
            label_color = "#AA9CB0"
            weight = 500
        s.icon(icon_name, cx - 12, 1616, 24, icon_color)
        s.text(cx, 1684, label, 13, label_color, weight, anchor="middle")
    s.text(58, 1760, "Default five shown · destination count remains configurable.", 12.5, "#62566A", 500)

    panel(s, 704, 1208, 786, 570, "#F8F5F2", "06   Workout state hierarchy")
    s.asym(730, 1274, 734, 73, "#EBD8FF", 38, 13, 31, 16)
    s.asym(730, 1274, 8, 73, "#694097", 8, 0, 8, 0)
    s.text(757, 1305, "Arnold Press · active", 17, "#694097", 850)
    s.text(757, 1332, "1/2 done · Iris edge marks current work", 13, "#4F3B5B", 600)
    s.asym(730, 1358, 734, 68, "#EAF2E9", 24, 11, 22, 12)
    s.circle(757, 1392, 11, "#2E754C")
    s.icon("check", 750, 1385, 14, "#FFFFFF", sw=2.5)
    s.text(779, 1398, "Barbell Squat · completed · 2/2", 14, "#254E35", 750)
    s.asym(730, 1437, 734, 53, "#EAF2E9", 22, 10, 20, 11)
    checkbox(s, 751, 1452, Palette(False), True, 22, completed=True)
    s.text(790, 1472, "Set 1 · 115 lb × 10 · completed", 13, "#254E35", 700)
    s.asym(730, 1501, 734, 55, "#F0ECE9", 22, 10, 20, 11)
    s.rect(751, 1517, 22, 22, "#FFFCFA", 6, "#74677B", 1.4)
    s.text(790, 1537, "Set 2 · 115 lb × 10 · incomplete", 13, "#33263D", 650)
    s.asym(730, 1567, 734, 67, "#006B58", 35, 14, 31, 18)
    s.icon("check", 947, 1589, 22, "#FFFFFF", sw=2.4)
    s.text(1125, 1612, "Finish Workout", 18, "#FFFFFF", 850, anchor="middle")
    s.text(730, 1666, "Completed surfaces are quieter than the active exercise and page action.", 14, "#62566A", 600)
    s.text(730, 1692, "Set completion stays compact and semantically green, separate from Jade.", 13, "#6A5D70", 500)

    panel(s, 1508, 1208, 658, 570, "#F8F5F2", "07   Weight Units · modal selection")
    s.asym(1534, 1279, 606, 421, "#E8E2EA", 36, 14, 34, 16)
    s.asym(1577, 1322, 520, 330, "#FFFCFA", 43, 15, 41, 17, "#D8CFCC", 0.9)
    s.text(1610, 1370, "Weight Units", 26, "#211625", 850)
    s.asym(1598, 1392, 478, 91, "#EBD8FF", 32, 12, 29, 15)
    s.circle(1630, 1437, 12, "none", "#694097", 2)
    s.circle(1630, 1437, 6, "#694097")
    s.text(1660, 1434, "Pounds", 17, "#30104D", 800)
    s.text(1660, 1457, "lbs · selected", 13, "#4F3B5B", 550)
    s.asym(1602, 1495, 470, 78, "#F0ECE9", 24, 10, 22, 12)
    s.circle(1631, 1534, 11, "none", "#74677B", 1.6)
    s.text(1660, 1531, "Kilograms", 16, "#30253A", 700)
    s.text(1660, 1553, "kg · available", 13, "#62566A", 500)
    s.text(1534, 1736, "Iris selection · warm lifted surface · neutral alternative.", 13, "#62566A", 550)

    s.text(58, 1802, "Tonos M3E uses hierarchy, role-owned color, scale and geometry to clarify the existing workflow.", 15, "#4E4352", 700)
    return s.finish()


def overview_board(comparison_paths: list[Path]):
    width, height = 2220, 2870
    s = Svg(width, height)
    s.rect(0, 0, width, height, "#E7E2DF")
    s.text(48, 65, "Tonos × Material 3 Expressive", 38, "#20162B", 900)
    s.text(50, 98, "Seven captured Classic Light states · seven expressive light/dark comparisons · same Tonos content and actions", 15, "#5B4D62", 550)
    s.asym(46, 124, 2128, 84, "#30253A", 34, 14, 35, 14)
    s.text(70, 160, "TRAINING JADE", 12, "#66E0C1", 850, spacing=1)
    s.text(70, 184, "Primary action · limited focal emphasis", 14, "#F7EFFA", 650)
    s.text(510, 160, "IRIS", 12, "#D8B9FF", 850, spacing=1)
    s.text(510, 184, "Structure · selection · hierarchy", 14, "#F7EFFA", 650)
    s.text(930, 160, "APRICOT", 12, "#FFB68F", 850, spacing=1)
    s.text(930, 184, "Sparse tertiary warmth", 14, "#F7EFFA", 650)
    s.text(1320, 160, "SEMANTIC / DATA COLORS", 12, "#73C5FF", 850, spacing=1)
    s.text(1320, 184, "Completion, errors, charts, heatmap, plans stay distinct", 14, "#F7EFFA", 650)
    positions = [(40, 230), (1125, 230), (40, 884), (1125, 884), (40, 1538), (1125, 1538), (582, 2192)]
    labels = [meta[1] for meta in SCREEN_META]
    for idx, (path, (x, y), label) in enumerate(zip(comparison_paths, positions, labels), start=1):
        s.asym(x, y, 1055, 620, "#F8F4F2", 34, 13, 34, 14)
        s.text(x + 23, y + 34, f"0{idx}  {label}", 19, "#32243B", 850)
        s.embed(path, x + 16, y + 47, 1023, 563)
    return s.finish()


def make_html():
    screen_sections = []
    for i, (key, title, state, content) in enumerate(SCREEN_META, 1):
        cap = escape(f"Captured state: {state}. Preserved content: {content}")
        screen_sections.append(
            f'''<section class="screen" id="{key}">
  <div class="screen-heading"><span class="number">{i:02}</span><div><h2>{escape(title)}</h2><p>{cap}</p></div></div>
  <a href="proposals/material-3-expressive/{key}-comparison.png"><img src="proposals/material-3-expressive/{key}-comparison.png" alt="Classic Light reference, Material 3 Expressive Light, and Material 3 Expressive Dark for {escape(title)}"></a>
  <p class="links"><a href="proposals/material-3-expressive/classic-light-reference/{'active-workout-session' if key == 'active-workout' else 'ui-appearance' if key == 'ui-appearance' else 'weight-units-dialog' if key == 'weight-units' else key}.png">Open supplied Classic Light screenshot</a> · <a href="proposals/material-3-expressive/{key}-m3e-light.png">M3E Light render</a> · <a href="proposals/material-3-expressive/{key}-m3e-dark.png">M3E Dark render</a></p>
</section>'''
        )

    html = '''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tonos · Material 3 Expressive visual proposal</title>
<style>
:root{color-scheme:light;--ink:#211625;--sub:#62556b;--paper:#f4f1ee;--card:#fffcfa;--line:#d8cfcc;--jade:#006b58;--iris:#694097;--apricot:#a74717}
*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.48 Roboto,"Segoe UI",Arial,sans-serif}.wrap{max-width:1540px;margin:auto;padding:30px 28px 72px}
.hero{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:22px;align-items:end;padding:22px 0 28px;border-bottom:1px solid var(--line)}.eyebrow{text-transform:uppercase;letter-spacing:.14em;color:#694097;font-weight:850;font-size:11px}.hero h1{font-size:clamp(36px,5vw,64px);line-height:.98;letter-spacing:-.045em;margin:14px 0 14px;max-width:880px}.hero p{max-width:900px;color:var(--sub);margin:0;font-size:17px}.tag{border-radius:18px 12px 20px 12px;background:#33263d;color:#fff;padding:14px 18px;font-weight:750;font-size:13px;white-space:nowrap}
.intro{display:grid;grid-template-columns:1.08fr .92fr;gap:16px;margin:24px 0 36px}.card{background:var(--card);border:1px solid var(--line);border-radius:25px 14px 27px 15px;padding:20px}.card h2{font-size:21px;margin:0 0 6px}.card p{font-size:13px;color:var(--sub);margin:0 0 14px}.chips{display:flex;gap:9px;flex-wrap:wrap}.chip{min-width:122px;flex:1;border-radius:15px 9px 15px 9px;padding:10px 11px;color:#fff}.chip b{display:block;font-size:10px;letter-spacing:.07em}.chip span{display:block;font-size:11px;margin-top:7px;font-weight:600}.role-note{margin-top:12px;background:#f0ece9;border-radius:13px;padding:10px 12px;color:#4e4255;font-size:12px}
.principles{display:flex;flex-wrap:wrap;gap:7px;margin-top:13px}.principles span{background:#ebe0f1;color:#45364e;border-radius:13px;padding:6px 10px;font-size:11px;font-weight:700}.board{display:block;margin:18px 0 38px;border-radius:23px;overflow:hidden;background:#eae4ed;border:1px solid var(--line)}.board img{display:block;width:100%;height:auto}
.section{margin:42px 0 14px}.section h2{font-size:32px;line-height:1.1;letter-spacing:-.03em;margin:0}.section p{margin:7px 0 0;color:var(--sub);font-size:14px}.screen{margin:20px 0 30px;padding:20px;background:var(--card);border:1px solid var(--line);border-radius:28px 15px 30px 16px;box-shadow:0 5px 20px #24162b0b}.screen-heading{display:flex;gap:13px;align-items:start;margin-bottom:12px}.number{display:grid;place-items:center;width:38px;height:38px;flex:none;background:#33263d;color:#d8b9ff;border-radius:14px 9px 14px 9px;font-weight:850;font-size:12px}.screen h2{font-size:21px;margin:2px 0 4px}.screen-heading p{font:11px/1.4 ui-monospace,Consolas,monospace;color:var(--sub);margin:0}.screen>a{display:block;border-radius:17px;overflow:hidden;background:#eae4ed}.screen img{display:block;width:100%;height:auto}.links{font-size:12px;color:var(--sub);margin:10px 2px 0}.links a,.sources a{color:#5b3781;text-underline-offset:3px}
.feasibility{display:grid;grid-template-columns:repeat(2,1fr);gap:11px;margin:14px 0 26px}.feasibility article{background:#f8f3f9;border:1px solid var(--line);border-radius:18px;padding:15px}.feasibility strong{display:block;font-size:13px;margin-bottom:5px}.feasibility p{margin:0;color:var(--sub);font-size:12px}.src{display:grid;grid-template-columns:repeat(2,1fr);gap:8px 24px}.sources{margin-top:12px}.footer{border-top:1px solid var(--line);margin-top:38px;padding-top:14px;color:var(--sub);font-size:12px}
@media(max-width:850px){.wrap{padding:18px 12px 44px}.hero{grid-template-columns:1fr}.tag{justify-self:start}.intro{grid-template-columns:1fr}.feasibility,.src{grid-template-columns:1fr}.screen{padding:12px}.section h2{font-size:26px}}
</style></head><body><main class="wrap">
<header class="hero"><div><div class="eyebrow">Theme family proposal · visual direction</div><h1>Tonos, expressed through Material 3.</h1><p>One bold, usable direction: training jade, iris, and apricot; purposeful scale and shape; and tonal groupings that make actions and workout states easier to scan. The supplied screenshots define the content and state. M3 Expressive defines the visual language.</p></div><div class="tag">One palette · seven matched states</div></header>
<div class="intro">
<section class="card"><h2>Training Jade / Iris / Apricot</h2><p>Jade owns primary actions; Iris owns structure and selection; Apricot is a sparse warm accent. Success, errors, warnings, chart series, body heatmap values, plan identities, and category colors keep their own meaning.</p><div class="chips">
<div class="chip" style="background:#006b58"><b>PRIMARY · LIGHT</b><span>#006B58</span></div><div class="chip" style="background:#694097"><b>SECONDARY · LIGHT</b><span>#694097</span></div><div class="chip" style="background:#a74717"><b>TERTIARY · LIGHT</b><span>#A74717</span></div><div class="chip" style="background:#33263d"><b>DARK CANVAS</b><span>#17121D base</span></div>
</div><div class="role-note">Light uses a warm neutral canvas with distinct container levels. Dark keeps the plum-black canvas, violet structural surfaces, mint Jade action, and Apricot contrast. Completion and report data use separate semantic colors.</div><div class="principles"><span>System font stack</span><span>Focal metric scale</span><span>Asymmetric role-based shapes</span><span>Five-destination default shown</span></div></section>
<section class="card"><h2>Material 3 Expressive, for Tonos</h2><p>Google describes its creative drivers as color, shape, size, motion, and containment, and frames expression as useful hierarchy that respects familiar interaction patterns. Tonos keeps its workout workflow and data semantics while using those drivers more assertively.</p><div class="principles"><span>Hierarchy that points to action</span><span>Scale rhythm in dense content</span><span>Contrasting—not random—color</span><span>Geometry tied to component role</span></div><div class="role-note">The supplied Classic Light screenshots are embedded verbatim at the left of every comparison. Example states and visible values carry across both M3E variants.</div></section>
</div>
<a class="board" href="proposals/material-3-expressive/overview-board.png"><img src="proposals/material-3-expressive/overview-board.png" alt="Overview board of seven Classic Light, M3 Expressive light, and M3 Expressive dark screen comparisons"></a>
<section class="section"><h2>M3E design-system board</h2><p>The visual implementation contract: owned color roles and light/dark surface ladders; six shape roles; six typography roles; three action levels; workout states; five-destination navigation; and Weight Units selection.</p></section>
<a class="board" href="proposals/material-3-expressive/m3e-design-system-board.png"><img src="proposals/material-3-expressive/m3e-design-system-board.png" alt="Tonos Material 3 Expressive design system board"></a>
<section class="section"><h2>Screen comparisons</h2><p>Each board shows the supplied Classic Light capture, then M3E Light and M3E Dark with matching content and state. Session remains a focused logger without app bottom navigation; other boards use the five-destination configuration in the screenshots.</p></section>
''' + "\n".join(screen_sections) + '''
<section class="card"><h2>Implementation feasibility · after the visual target</h2><p>These categories describe the static visual treatments, not a Step 16.2 implementation decision.</p><div class="feasibility">
<article><strong>A · Standard Material 3 foundation</strong><p>ColorScheme roles; the light/dark surface ladder; system-font hierarchy; ordinary button, tab, navigation bar, field, switch, checkbox, radio, card, and dialog themes. The screen treatment relies mainly on these built-in capabilities.</p></article>
<article><strong>B · Optional package capability to investigate</strong><p><code>m3_expressive</code> 1.0.0 declares Flutter 3.10 / Dart 3.0 minimums, so its small set of loading, shape, and list interactions fits the current SDK. It is a third-party candidate for a narrow later review. <code>material_3_expressive</code> 1.1.3 has a broader widget set but requires Flutter 3.47 / Dart 3.13 and migrates Material imports to <code>material_ui</code>; it is not compatible with this workspace today.</p></article>
<article><strong>C · Small Tonos compatibility layer</strong><p>Use a few static role shapes and state adapters where Flutter’s standard theme slots cannot express the desired corners or workout completion tint. Route layouts, selection geometry, and the dialog remain ordinary Material-compatible surfaces.</p></article>
<article><strong>D · Deferred expressive behavior</strong><p>Spring-driven press feedback, state-to-state shape morphing, advanced animated navigation, and other M3E-only motion stay outside this visual target. The static proposal does not depend on them.</p></article>
</div><div class="role-note">Workspace SDK verified: Flutter 3.29.3 / Dart 3.7.2. No package was added, no SDK changed, and Step 16.2 did not begin.</div></section>
<section class="card sources"><h2>Design and implementation references</h2><div class="src">
<a href="https://design.google/library/expressive-material-design-google-research">Google Design · M3 Expressive research</a>
<a href="https://design.google/library/material-design-eras">Google Design · scale, space, shape, color, type</a>
<a href="https://m3.material.io/">Material Design · current M3 Expressive overview</a>
<a href="https://developer.android.com/design/ui/mobile/guides/styles/color">Android Developers · roles, surfaces, contrast</a>
<a href="https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-and-nav-patterns">Android Developers · navigation patterns</a>
<a href="https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html">Flutter · Material 3 foundation</a>
<a href="https://pub.dev/packages/m3_expressive">pub.dev · compatible M3E component candidate</a>
<a href="https://pub.dev/packages/material_3_expressive">pub.dev · broader M3E component set and SDK requirements</a>
<a href="proposals/material-3-expressive/classic-light-reference/README.md">Supplied Classic Light reference set</a>
</div><p class="footer">Documentation artwork only. Production Dart, theme architecture, Step 16.1 files, dependencies, tests, inventory, ratchet, and roadmap were not changed. No commit or push.</p></section>
</main></body></html>'''
    (ROOT / "docs" / "theme-m3-proposals.html").write_text(html, encoding="utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    light = screens(Palette(False))
    dark = screens(Palette(True))
    for key, *_ in SCREEN_META:
        for mode, source in (("m3e-light", light[key]), ("m3e-dark", dark[key])):
            svg_path = write_svg(f"{key}-{mode}", source.finish())
            render(svg_path, OUT / f"{key}-{mode}.png")

    comparison_paths = []
    for key, title, state, _ in SCREEN_META:
        ref_name = {
            "active-workout": "active-workout-session.png",
            "ui-appearance": "ui-appearance.png",
            "weight-units": "weight-units-dialog.png",
        }.get(key, f"{key}.png")
        svg_path = write_svg(
            f"{key}-comparison",
            make_comparison(key, title, state, REF / ref_name),
        )
        png_path = OUT / f"{key}-comparison.png"
        render(svg_path, png_path)
        comparison_paths.append(png_path)

    design_path = write_svg("m3e-design-system-board", make_design_board())
    render(design_path, OUT / "m3e-design-system-board.png")
    overview_path = write_svg("overview-board", overview_board(comparison_paths))
    render(overview_path, OUT / "overview-board.png")
    make_html()
    print(f"Rendered seven three-way comparison boards and two system boards in {OUT}")


if __name__ == "__main__":
    main()
