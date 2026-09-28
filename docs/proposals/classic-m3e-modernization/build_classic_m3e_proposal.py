"""Render a selective Material 3 Expressive modernization of Tonos Classic.

This script generates proposal-only SVG/PNG artwork and an HTML review page.
Production Flutter files are not read as output targets or modified.
"""

from __future__ import annotations

import importlib.util
from html import escape
from pathlib import Path
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
REFERENCE = ROOT / "docs" / "proposals" / "material-3-expressive" / "classic-light-reference"
BASE_BUILDER = ROOT / "docs" / "proposals" / "material-3-expressive" / "build_proposal_revision.py"

spec = importlib.util.spec_from_file_location("tonos_m3e_proposal_base", BASE_BUILDER)
if spec is None or spec.loader is None:
    raise RuntimeError(f"Could not load proposal drawing primitives from {BASE_BUILDER}")
base = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = base
spec.loader.exec_module(base)
base.OUT = OUT
base.REF = REFERENCE


class ClassicPalette:
    """Classic deep-purple Material roles with restrained tonal containers."""

    def __init__(self, dark: bool):
        self.dark = dark
        if dark:
            self.canvas = "#141218"
            self.surface = "#1C1B20"
            self.surface1 = "#25232A"
            self.surface2 = "#2C2932"
            self.surface3 = "#36333D"
            self.secondary_subtle = "#292431"
            self.tertiary_subtle = "#30252B"
            self.primary = "#D0BCFF"
            self.on_primary = "#381E72"
            self.primary_container = "#4F378B"
            self.on_primary_container = "#EADDFF"
            self.secondary = "#CCC2DC"
            self.on_secondary = "#332D41"
            self.secondary_container = "#4A4458"
            self.on_secondary_container = "#E8DEF8"
            self.tertiary = "#EFB8C8"
            self.on_tertiary = "#492532"
            self.tertiary_container = "#633B48"
            self.on_tertiary_container = "#FFD8E4"
            self.ink = "#E6E1E5"
            self.sub = "#CAC4D0"
            self.muted = "#938F99"
            self.outline = "#938F99"
            self.nav = "#1C1B20"
            self.success = "#81C784"
            self.success_container = "#315B38"
            self.success_subtle = "#1C3422"
            self.success_ink = "#C7E9C7"
            self.on_success = "#0D2412"
            self.error = "#F2B8B5"
            self.error_container = "#8C1D18"
            self.warning = "#F6BD5A"
            self.chart = "#BB86FC"
            self.chart_blue = "#42A5F5"
            self.heat_low = "#A1A1A1"
            self.heat_high = "#1565C0"
            self.plan_blue = "#90CAF9"
            self.plan_orange = "#FFB74D"
            self.plan_blue_container = "#1F3444"
            self.plan_orange_container = "#3D2C1B"
            self.dim_scrim = "#000000"
            self.profile_account = "#C4B5E2"
            self.profile_appearance = "#D7A5D8"
            self.profile_training = "#80CBC4"
            self.profile_progress = "#A5D6A7"
            self.profile_data = "#90CAF9"
        else:
            self.canvas = "#FFF8FD"
            self.surface = "#FFFBFF"
            self.surface1 = "#F4EDF6"
            self.surface2 = "#ECE5F1"
            self.surface3 = "#E3DCE8"
            self.secondary_subtle = "#F4ECFA"
            self.tertiary_subtle = "#F5EEF1"
            self.primary = "#6750A4"
            self.on_primary = "#FFFFFF"
            self.primary_container = "#EADDFF"
            self.on_primary_container = "#21005D"
            self.secondary = "#625B71"
            self.on_secondary = "#FFFFFF"
            self.secondary_container = "#E8DEF8"
            self.on_secondary_container = "#1D192B"
            self.tertiary = "#7D5260"
            self.on_tertiary = "#FFFFFF"
            self.tertiary_container = "#FFD8E4"
            self.on_tertiary_container = "#31111D"
            self.ink = "#1D1B20"
            self.sub = "#49454F"
            self.muted = "#625B71"
            self.outline = "#79747E"
            self.nav = "#FFFBFF"
            self.success = "#388E3C"
            self.success_container = "#B7E5BE"
            self.success_subtle = "#E8F3E9"
            self.success_ink = "#17441E"
            self.on_success = "#FFFFFF"
            self.error = "#B3261E"
            self.error_container = "#F9DEDC"
            self.warning = "#8B5000"
            self.chart = "#6200EE"
            self.chart_blue = "#1E88E5"
            self.heat_low = "#9E9E9E"
            self.heat_high = "#1565C0"
            self.plan_blue = "#2196F3"
            self.plan_orange = "#FF9800"
            self.plan_blue_container = "#DDEEFF"
            self.plan_orange_container = "#FFF0E0"
            self.dim_scrim = "#17121E"
            self.profile_account = "#B39DDB"
            self.profile_appearance = "#CE93D8"
            self.profile_training = "#4DB6AC"
            self.profile_progress = "#81C784"
            self.profile_data = "#64B5F6"


def phone(t: ClassicPalette, time: str = "11:29"):
    return base.base_screen(t, time)


def card(s, x, y, w, h, fill, radius=20, stroke=None, sw=1):
    s.rect(x, y, w, h, fill, radius, stroke, sw)


def title(s, x, y, text, size=23, color=None, weight=800, anchor="start"):
    s.text(x, y, text, size, color or s.tone.ink, weight, anchor=anchor)


def bottom_nav(s, t: ClassicPalette, selected: str):
    # Keep the present five-destination bar and screen position; add only a
    # compact, tonal selected-icon capsule for clearer wayfinding.
    s.rect(0, 927, 470, 63, t.nav)
    s.line(0, 927, 470, 927, t.outline, 0.8, 0.25)
    items = [
        ("Train", "dumbbell"), ("Catalog", "book"), ("Logbook", "history"),
        ("Progress", "trend"), ("Profile", "person"),
    ]
    for i, (label, glyph) in enumerate(items):
        cx = 47 + 94 * i
        if label == selected:
            card(s, cx - 24, 932, 48, 28, t.primary_container, 14)
            icon_color = t.on_primary_container
            label_color = t.primary
            weight = 700
        else:
            icon_color = "#77747D" if t.dark else "#79747E"
            label_color = icon_color
            weight = 450
        s.icon(glyph, cx - 11, 934, 22, icon_color, filled=(label == selected and label == "Profile"))
        s.text(cx, 978, label, 11.5, label_color, weight, anchor="middle")


def train_tabs(s, t: ClassicPalette, selected: str, avatar="G"):
    card(s, 24, 65, 355, 49, t.surface2, 25)
    if selected == "Overview":
        card(s, 28, 69, 173, 41, t.primary_container, 22)
        left, right = t.on_primary_container, t.sub
        lw, rw = 750, 600
    else:
        card(s, 202, 69, 173, 41, t.primary_container, 22)
        left, right = t.sub, t.on_primary_container
        lw, rw = 600, 750
    s.text(114, 96, "Overview", 15.5, left, lw, anchor="middle")
    s.text(288, 96, "Plans", 15.5, right, rw, anchor="middle")
    s.circle(425, 90, 21, "#8BC34A")
    s.text(425, 96, avatar, 15, "#FFFFFF", 800, anchor="middle")


def edit_icon(s, x, y, color):
    s.icon("edit", x, y, 24, color, sw=2.1)


def body_heatmap(s, t, x=42, y=226, w=170, h=190):
    svg = base.make_heatmap_svg(t)
    svg = svg.replace('x="36" y="218"', f'x="{x}" y="{y}"', 1)
    svg = svg.replace('width="190"', f'width="{w}"', 1)
    svg = svg.replace('height="228"', f'height="{h}"', 1)
    s.add(svg)


def focus_bar(s, t, x, y, label, value, width, fill=None):
    s.text(x, y, label, 14, t.ink, 550)
    s.text(x + width, y, value, 14, t.ink, 750, anchor="end")
    s.rect(x, y + 10, width, 6, t.surface3, 3)
    s.rect(x, y + 10, width * float(value) / 20, 6, fill or t.primary, 3)


def plan_card(s, t, y, name, accent, container, crop_name):
    card(s, 46, y, 376, 96, container, 12, accent, 1.2)
    crop_box = (60, 585, 59, 61) if crop_name == "train-overview.png" else (53, 247, 63, 65)
    s.crop(REFERENCE / crop_name, crop_box, 59, y + 15, 62, 62, 9)
    s.text(132, y + 54, name, 18, accent, 750)
    s.circle(335, y + 48, 10, "#38CE5D")
    s.text(335, y + 52, "A", 10, "#FFFFFF", 800, anchor="middle")
    s.icon("more", 377, y + 38, 20, accent)


def draw_overview(t: ClassicPalette):
    s = phone(t, "11:29")
    train_tabs(s, t, "Overview")

    card(s, 27, 142, 415, 311, t.surface1, 18, t.surface3, 0.9)
    s.text(47, 187, "Weekly Overview", 25, t.ink, 800)
    body_heatmap(s, t, 39, 228, 175, 188)
    s.text(230, 242, "Focused Sets", 15, t.ink, 750)
    focus_bar(s, t, 230, 277, "Upper Back", "19", 186, t.primary)
    focus_bar(s, t, 230, 326, "Hips", "18", 186, t.primary)
    s.rect(230, 336, 186, 6, t.surface3, 3)
    s.rect(230, 336, 167, 6, t.primary, 3)
    s.text(230, 377, "Quads", 14, t.ink, 550)
    s.text(416, 377, "17", 14, t.ink, 750, anchor="end")
    s.rect(230, 387, 186, 6, t.surface3, 3)
    s.rect(230, 387, 158, 6, t.primary, 3)
    s.text(230, 426, "···  more", 13, t.primary, 700)

    card(s, 27, 478, 415, 316, t.surface1, 18, t.surface3, 0.9)
    s.text(47, 535, "Active Plans", 25, t.ink, 800)
    edit_icon(s, 392, 502, t.sub)
    plan_card(s, t, 565, "Full Body", t.plan_blue, t.plan_blue_container, "train-overview.png")
    plan_card(s, t, 674, "Upper 1", t.plan_orange, t.plan_orange_container, "train-overview.png")

    # Material primary owns general actions; semantic green remains reserved
    # for success and completion states.
    s.rect(24, 837, 252, 72, t.primary, 28)
    s.rect(276, 837, 170, 72, t.primary_container, 28)
    s.rect(268, 837, 8, 72, t.primary)
    s.text(150, 880, "Start Workout", 17, t.on_primary, 800, anchor="middle")
    s.text(341, 879, "Optimize", 15, t.on_primary_container, 750, anchor="middle")
    s.icon("settings", 415, 861, 22, t.on_primary_container, sw=1.8)
    bottom_nav(s, t, "Train")
    return s


def draw_plans(t: ClassicPalette):
    s = phone(t, "11:29")
    train_tabs(s, t, "Plans")

    card(s, 23, 143, 414, 326, t.surface1, 18, t.surface3, 0.9)
    s.text(42, 198, "Active Plans", 25, t.ink, 800)
    edit_icon(s, 387, 174, t.sub)
    plan_card(s, t, 230, "Full Body", t.plan_blue, t.plan_blue_container, "train-plans.png")
    plan_card(s, t, 343, "Upper 1", t.plan_orange, t.plan_orange_container, "train-plans.png")

    card(s, 23, 495, 414, 158, t.surface1, 18, t.surface3, 0.9)
    s.text(42, 550, "Archived Plans", 25, t.ink, 800)
    edit_icon(s, 387, 526, t.sub)
    s.text(59, 612, "No archived plans.", 15, t.ink, 450)

    card(s, 23, 678, 414, 201, t.surface1, 18, t.surface3, 0.9)
    s.icon("book", 42, 704, 29, t.primary, sw=2)
    s.text(82, 729, "Premade Plans", 23, t.ink, 800)
    base.text_lines(s, 42, 762, ["34 curated routines are available to copy", "into your plans."], 14, t.sub, 450, 21)
    card(s, 41, 809, 378, 45, t.primary_container, 23)
    s.icon("arrow", 121, 819, 23, t.on_primary_container, sw=2.1)
    s.text(268, 838, "Browse Premade Plans", 14.5, t.on_primary_container, 700, anchor="middle")

    # The next existing action section begins at the same point as the capture
    # and remains partly covered by the bottom bar at this scroll position.
    card(s, 20, 898, 430, 86, t.secondary_subtle, 12, t.primary, 1)
    s.text(41, 927, "Generate Custom Plans", 16, t.primary, 750)
    bottom_nav(s, t, "Train")
    return s


def setting_icon(s, x, y, icon, fill, color, size=44):
    s.rect(x, y, size, size, fill, 16)
    s.icon(icon, x + (size - 25) / 2, y + (size - 25) / 2, 25, color)


def workout_header(s, t, y, name, done, thumbnail, completed=False, active=False, expanded=False):
    fill = t.success_subtle if completed else (t.primary_container if active else t.surface1)
    card(s, 22, y, 421, 82, fill, 13, t.surface3 if not completed else None, 0.8)
    chevron = f"M54 {y + 38} L60 {y + 32} L66 {y + 38}" if expanded else f"M54 {y + 32} L60 {y + 38} L66 {y + 32}"
    s.path(chevron, "none", t.sub, 2)
    # The production card uses an expand/collapse caret before the exercise name.
    s.text(92, y + 44, name, 16.5, t.ink, 700)
    if completed:
        s.circle(101, y + 63, 7.5, t.success)
        s.icon("check", 96, y + 58, 10, t.on_success, sw=2.5)
    elif active:
        s.circle(101, y + 63, 7.5, t.primary)
        s.circle(101, y + 63, 3, t.on_primary)
    s.text(119, y + 68, done, 13.5, t.success_ink if completed else t.primary, 600)
    s.crop(REFERENCE / "active-workout-session.png", thumbnail, 319, y + 15, 55, 55, 8)
    s.icon("more", 390, y + 29, 20, t.ink)


def set_row(s, t, y, label, weight, reps, checked):
    fill = t.success_container if checked else t.surface
    card(s, 40, y, 385, 83, fill, 14, "#85BA90" if checked and not t.dark else t.surface3, 0.8)
    s.rect(62, y + 30, 20, 20, t.success if checked else t.surface, 3, t.success if checked else t.outline, 1.5)
    if checked:
        s.icon("check", 65, y + 33, 14, t.on_success, sw=2.6)
    s.text(91, y + 51, label, 13.5, t.ink, 500)
    s.text(154, y + 27, "Weight (lbs)", 12.5, t.sub, 450)
    s.text(154, y + 60, weight, 19, t.ink, 500)
    s.line(153, y + 70, 255, y + 70, t.outline, 1)
    s.text(268, y + 27, "Reps", 12.5, t.sub, 450)
    s.text(268, y + 60, reps, 19, t.ink, 500)
    s.line(268, y + 70, 368, y + 70, t.outline, 1)
    s.circle(392, y + 42, 11, t.surface, t.outline, 1.7)
    s.icon("minus", 386, y + 36, 12, t.sub, sw=2)


def add_set(s, t, y):
    s.icon("plus", 321, y, 17, t.primary, sw=2)
    s.text(346, y + 16, "Add Set", 14, t.primary, 650)


def draw_session(t: ClassicPalette):
    s = phone(t, "11:31")
    s.icon("menu", 24, 77, 22, t.ink)
    s.text(235, 98, "Workout Session", 24, t.ink, 500, anchor="middle")

    # Same three-exercise state and same set-entry controls as the current
    # SessionScreen/WeightCard composition.
    workout_header(s, t, 137, "Barbell Squat", "2/2 done", (318, 156, 56, 56), completed=True)
    card(s, 22, 247, 421, 260, t.success_subtle, 15, t.surface3, 0.8)
    workout_header(s, t, 247, "Bench Press - Barbell", "1/1 done", (317, 266, 56, 56), completed=True, expanded=True)
    s.line(40, 328, 425, 328, t.outline, 0.8, 0.45)
    set_row(s, t, 346, "Set 1", "15", "10", True)
    add_set(s, t, 446)

    card(s, 22, 526, 421, 357, t.surface1, 15, t.surface3, 0.8)
    workout_header(s, t, 526, "Arnold Press", "1/2 done", (318, 522, 57, 58), active=True, expanded=True)
    s.line(40, 608, 425, 608, t.outline, 0.8, 0.45)
    set_row(s, t, 624, "Set 1", "115", "10", True)
    set_row(s, t, 722, "Set 2", "115", "10", False)
    add_set(s, t, 818)

    card(s, 381, 840, 62, 62, t.primary_container, 20)
    s.icon("plus", 399, 858, 27, t.on_primary_container, sw=2.2)
    # The pinned final action gets primary contrast while retaining its
    # existing footprint and position.
    card(s, 21, 933, 422, 46, t.primary, 20)
    s.text(232, 963, "Finish Workout", 16, t.on_primary, 750, anchor="middle")
    return s


def metric(s, t, x, label, value, delta, selected=False):
    fill = t.primary_container if selected else t.surface1
    edge = t.primary if selected else t.surface3
    card(s, x, 146, 124, 117, fill, 21 if selected else 18, edge, 1.6 if selected else 0.8)
    label_color = t.on_primary_container if selected else t.ink
    s.text(x + 14, 177, label, 14.5 if selected else 14, label_color, 800 if selected else 650)
    s.text(x + 14, 218, value, 30 if selected else 23, label_color, 850 if selected else 750)
    if label == "Workouts":
        s.text(x + 73, 218, "total", 10, label_color, 450)
    s.text(x + 14, 247, delta, 10.5, t.error, 650)


def draw_progress(t: ClassicPalette):
    s = phone(t, "11:31")
    card(s, 20, 78, 430, 586, t.surface, 18, t.surface3, 0.8)
    s.text(235, 123, "Workout Report", 25, t.ink, 800, anchor="middle")
    metric(s, t, 39, "Workouts", "6", "↓ 6 workouts", selected=True)
    metric(s, t, 174, "Time", "1m 54s", "↓ 1m 54s")
    metric(s, t, 309, "Volume", "15k lbs", "↓ 15k lbs")

    card(s, 39, 281, 395, 245, t.surface2, 22)
    s.text(57, 314, "Workouts (All)", 17, t.ink, 750)
    chart_x, chart_y, chart_w, chart_h = 94, 346, 320, 135
    for i, value in enumerate((6, 5, 4, 3, 2, 1, 0)):
        gy = chart_y + i * (chart_h / 6)
        s.line(chart_x, gy, chart_x + chart_w, gy, t.outline, 0.8, 0.28, dash="4 7")
        if value in (6, 5, 4, 2, 1, 0):
            s.text(79, gy + 4, str(value), 10, t.muted, 450, anchor="end")
    s.path(f"M{chart_x} {chart_y} L{chart_x + chart_w} {chart_y + chart_h} L{chart_x + chart_w} {chart_y + chart_h} L{chart_x} {chart_y + chart_h} Z", t.chart, opacity=0.10)
    s.path(f"M{chart_x} {chart_y} L{chart_x + chart_w} {chart_y + chart_h}", "none", t.chart, 3.6)
    s.circle(chart_x, chart_y, 4.5, t.chart)
    s.circle(chart_x + chart_w, chart_y + chart_h, 4.5, t.chart)
    s.text(chart_x - 19, chart_y - 10, "6", 10, t.ink, 600, anchor="middle")
    s.text(chart_x - 19, chart_y + chart_h + 3, "0", 10, t.ink, 500, anchor="middle")
    s.text(chart_x, 507, "21", 10, t.sub, 550, anchor="middle")
    s.text(chart_x + chart_w, 507, "28", 10, t.sub, 550, anchor="middle")
    s.text(chart_x, 520, "SEP", 9, t.sub, 500, anchor="middle")
    s.text(chart_x + chart_w, 520, "SEP", 9, t.sub, 500, anchor="middle")

    card(s, 39, 539, 395, 47, t.surface2, 22)
    for i, label in enumerate(("1W", "1M", "3M", "6M", "1Y", "All")):
        cx = 70 + i * 67
        if label == "All":
            card(s, cx - 29, 543, 59, 39, t.primary, 18)
        s.text(cx, 569, label, 12.5, t.on_primary if label == "All" else t.ink, 750 if label == "All" else 650, anchor="middle")
    card(s, 39, 594, 395, 51, t.surface1, 17, t.surface3, 0.8)
    s.text(54, 625, "Additional Details", 14, t.ink, 700)
    s.path("M407 615l7 7 7-7", "none", t.sub, 2)

    card(s, 20, 685, 430, 265, t.surface1, 18)
    s.text(235, 729, "Exercise progress", 24, t.ink, 800, anchor="middle")
    card(s, 40, 752, 390, 188, t.surface, 20)
    s.text(58, 786, "Barbell Squat", 17, t.ink, 750)
    s.path("M404 772l7 7-7 7", "none", t.sub, 2)
    for gy in (822, 854, 886):
        s.line(88, gy, 277, gy, t.outline, 0.8, 0.28)
    s.path("M156 908 L226 876 L295 822", "none", t.chart_blue, 2.5, dash="6 5")
    s.circle(156, 908, 3.5, t.chart_blue)
    s.circle(295, 822, 3.5, t.chart_blue)
    card(s, 308, 765, 106, 68, t.surface1, 17)
    s.text(321, 791, "1 Rep Max", 10, t.muted, 550)
    s.text(321, 816, "--", 17, t.ink, 750)
    card(s, 308, 842, 106, 69, t.surface1, 17)
    s.text(321, 869, "Est. 1RM", 10, t.muted, 550)
    s.text(321, 894, "--", 17, t.ink, 750)
    bottom_nav(s, t, "Progress")
    return s


def section_label(s, t, y, label, description, accent):
    s.rect(27, y - 23, 5, 38, accent, 3)
    s.text(42, y, label, 18, accent, 800)
    s.text(41, y + 25, description, 12, t.muted, 450)


def setting_group(s, t, x, y, w, h):
    card(s, x, y, w, h, t.surface1, 20, t.surface3, 0.8)


def setting_row(s, t, y, h, name, subtitle, icon, icon_fill, icon_color, value=None, switch=False, divider=True):
    setting_icon(s, 38, y + (h - 46) / 2, icon, icon_fill, icon_color, 46)
    s.text(103, y + 30, name, 16.5, t.ink, 800)
    lines = subtitle.split("\n")
    base.text_lines(s, 103, y + 52, lines, 12.5, t.muted, 450, 16)
    if switch:
        card(s, 368, y + (h - 34) / 2, 58, 34, t.surface2, 18, t.outline, 1.3)
        s.circle(385, y + h / 2, 11, t.muted)
    elif value:
        s.text(430, y + h / 2 + 5, value, 12.5, icon_color, 700, anchor="end")
    if divider:
        s.line(102, y + h, 424, y + h, t.outline, 0.7, 0.25)


def profile_page(t: ClassicPalette):
    s = phone(t, "11:32")
    card(s, 22, 74, 421, 140, t.secondary_subtle, 42)
    s.circle(72, 144, 30, t.primary_container)
    s.icon("person", 59, 131, 26, t.primary, filled=True)
    s.text(118, 130, "Profile", 31, t.ink, 900)
    base.text_lines(s, 119, 161, ["Personalize Tonos, manage training", "defaults, and keep your data healthy."], 14, t.sub, 450, 20)

    section_label(s, t, 254, "Account", "Your identity and app-level appearance.", t.profile_account)
    setting_group(s, t, 22, 295, 421, 301)
    rows = [
        ("User Information", "Name, body details, and activity\nprofile.", "badge", t.profile_account),
        ("UI & Appearance", "Theme, onboarding, and bottom tab\nsetup.", "palette", t.profile_appearance),
        ("Guided Tutorials", "Replay walkthroughs and reset guided\nhelp.", "users", t.profile_appearance),
    ]
    for i, (name, subtitle, icon, accent) in enumerate(rows):
        y = 304 + i * 94
        setting_row(s, t, y, 93, name, subtitle, icon, t.secondary_subtle, accent, divider=i < 2)
        s.path(f"M416 {y + 37}l6 6-6 6", "none", t.sub, 1.8)

    section_label(s, t, 629, "Training", "Exercise defaults and progress-related controls.", t.profile_training)
    setting_group(s, t, 22, 678, 421, 199)
    setting_row(s, t, 685, 96, "Gym & Workout Settings", "Workout generation, rankings, flows,\nand equipment logic.", "dumbbell", "#E0F2F1" if not t.dark else "#203D3A", t.profile_training)
    s.path("M416 723l6 6-6 6", "none", t.sub, 1.8)
    setting_row(s, t, 781, 89, "Progress Settings", "Measurement and trend tracking\nsetup.", "trend", "#E8F5E9" if not t.dark else "#263B2B", t.profile_progress, divider=False)
    s.path("M416 816l6 6-6 6", "none", t.sub, 1.8)
    section_label(s, t, 908, "Data", "Storage, privacy, and export controls.", t.profile_data)
    bottom_nav(s, t, "Profile")
    return s


def appearance_page(t: ClassicPalette):
    s = phone(t, "11:32")
    s.icon("back", 36, 86, 25, t.ink, sw=1.8)
    card(s, 23, 131, 421, 140, t.secondary_subtle, 40)
    s.circle(73, 201, 30, t.primary_container)
    s.icon("palette", 59, 187, 27, t.primary, sw=1.8)
    s.text(121, 186, "UI & Appearance", 27, t.ink, 900)
    base.text_lines(s, 121, 216, ["Control the way Tonos looks and", "how the bottom tabs behave."], 14, t.sub, 450, 20)

    section_label(s, t, 317, "Display", "Quick visual preferences.", t.profile_appearance)
    setting_group(s, t, 24, 352, 420, 519)
    setting_row(s, t, 358, 118, "Theme family", "Choose the visual family\nindependently of light or dark mode.", "palette", t.secondary_subtle, t.profile_appearance, "Classic")
    setting_row(s, t, 476, 94, "Dark Mode", "Use the darker app theme.", "moon", t.secondary_subtle, t.profile_appearance, switch=True)
    setting_row(s, t, 570, 101, "Replay Onboarding", "Turn this on to open setup again.\nIt turns off after completion.", "spark", t.secondary_subtle, t.profile_appearance, switch=True)
    setting_row(s, t, 671, 98, "Weight Units", "Show workout weights and\nvolume in lbs.", "weight", "#E8F5E9" if not t.dark else "#263B2B", t.profile_progress, "Pounds")
    setting_row(s, t, 769, 96, "Language", "Choose the language\nTonos uses.", "globe", t.secondary_subtle, t.profile_appearance, "System default", divider=False)

    section_label(s, t, 908, "Navigation", "Choose which bottom tabs show up and in what order.", t.profile_data)
    card(s, 24, 951, 420, 68, t.secondary_subtle, 20, t.surface3, 0.8)
    setting_icon(s, 39, 961, "home", t.primary_container, t.profile_data)
    s.text(101, 982, "Edit Bottom Tabs", 15.5, t.ink, 750)
    s.path("M413 975l6 6-6 6", "none", t.sub, 1.8)
    return s


def weight_dialog(t: ClassicPalette):
    s = appearance_page(t)
    s.rect(0, 0, base.PHONE_W, base.PHONE_H, t.dim_scrim, 0, opacity=0.52 if not t.dark else 0.60)
    card(s, 80, 389, 312, 270, t.surface, 30)
    s.text(106, 444, "Weight Units", 27, t.ink, 500)
    card(s, 98, 467, 276, 76, t.primary_container, 20)
    s.circle(126, 505, 10, "none", t.primary, 2)
    s.circle(126, 505, 5, t.primary)
    s.text(161, 500, "Pounds", 17, t.ink, 500)
    s.text(161, 522, "lbs", 12, t.sub, 450)
    card(s, 98, 551, 276, 76, t.surface, 20)
    s.circle(126, 589, 10, "none", t.muted, 1.8)
    s.text(161, 584, "Kilograms", 17, t.ink, 500)
    s.text(161, 606, "kg", 12, t.sub, 450)
    return s


def generated_screens(t: ClassicPalette):
    return {
        "train-overview": draw_overview(t),
        "train-plans": draw_plans(t),
        "active-workout": draw_session(t),
        "progress": draw_progress(t),
        "profile": profile_page(t),
        "ui-appearance": appearance_page(t),
        "weight-units": weight_dialog(t),
    }


SCREEN_META = [
    ("train-overview", "Train · Overview", "train-overview.png", "Overview selected; Weekly Overview, Focused Sets, Full Body and Upper 1, segmented Start Workout / Optimize action, and Train selected in the five-tab bar."),
    ("train-plans", "Train · Plans", "train-plans.png", "Plans selected; Active Plans, empty Archived Plans, Premade Plans, and the next Generate Custom Plans section beginning below the fold."),
    ("active-workout", "Active Workout · Session", "active-workout-session.png", "Barbell Squat 2/2 complete and collapsed; Bench Press - Barbell 1/1 complete with its set visible; Arnold Press 1/2 with two sets; pinned Finish Workout and add-exercise action."),
    ("progress", "Progress", "progress.png", "Workout Report metrics 6, 1m 54s, 15k lbs; Sep 21–28 chart; All range selected; Additional Details; beginning of Exercise progress with Barbell Squat."),
    ("profile", "Profile", "profile.png", "Profile hero; Account and Training groups; first Data heading; Profile selected in the five-tab bar."),
    ("ui-appearance", "Profile · UI & Appearance", "ui-appearance.png", "Classic value; Dark Mode and Replay Onboarding off; Pounds; System default; Navigation section beginning below the fold."),
    ("weight-units", "Weight Units dialog", "weight-units-dialog.png", "UI & Appearance under the modal scrim; Pounds selected, Kilograms available."),
]


def render_svg(name: str, source: str):
    path = OUT / f"{name}.svg"
    path.write_text(source, encoding="utf-8")
    png_path = OUT / f"{name}.png"
    for attempt in range(3):
        try:
            base.render(path, png_path)
            break
        except subprocess.CalledProcessError:
            if attempt == 2:
                raise
            time.sleep(0.4)
    return OUT / f"{name}.png"


def comparison_board(key: str, heading: str, reference: Path):
    s = base.Svg(2200, 1340)
    s.rect(0, 0, 2200, 1340, "#EAE6EE")
    s.text(52, 61, heading, 34, "#24202B", 800)
    s.text(54, 92, "Same Tonos content and state · theme treatment changes, workflow stays familiar", 15, "#625B69", 500)
    labels = ["CLASSIC TODAY · SUPPLIED CAPTURE", "CLASSIC REFINED · LIGHT", "CLASSIC REFINED · DARK"]
    paths = [reference, OUT / f"{key}-classic-m3e-light.png", OUT / f"{key}-classic-m3e-dark.png"]
    xcols = [26, 760, 1494]
    for i, x in enumerate(xcols):
        panel = "#F9F6FA" if i < 2 else "#28242D"
        s.rect(x, 116, 680, 1172, panel, 24, "#D8D2DD", 0.8)
        label_color = "#5D5665" if i < 2 else "#DCD6E1"
        s.text(x + 340, 155, labels[i], 12, label_color, 750, anchor="middle", spacing=0.5)
        s.embed(paths[i], x + 92, 170, 496, 1075)
    s.text(1100, 1318, "Classic Light baseline is preserved verbatim; updated light/dark screens retain this capture’s content and structure.", 11, "#625B69", 500, anchor="middle")
    return s.finish()


def overview_board():
    s = base.Svg(2200, 1490)
    s.rect(0, 0, 2200, 1490, "#EAE6EE")
    s.text(54, 68, "Tonos · Classic, carefully modernized", 40, "#24202B", 850)
    s.text(58, 105, "A selective Material 3 Expressive update · same Tonos, same Classic family", 17, "#625B69", 500)
    cards = [
        ("KEEP", "Current routes, density, content order,\nsemantic colors, and Classic purple."),
        ("REFINE", "Primary-action clarity, tonal selection,\nsurface grouping, and focal metric emphasis."),
        ("LEAVE OUT", "New navigation, decorative shape variety,\nextra palettes, and behavior-heavy motion."),
    ]
    for i, (label, copy) in enumerate(cards):
        x = 54 + i * 706
        s.rect(x, 139, 670, 112, "#FBF8FC", 22, "#D8D2DD", 0.8)
        accent = "#6750A4" if i < 2 else "#625B71"
        s.text(x + 22, 175, label, 13, accent, 800, spacing=0.8)
        base.text_lines(s, x + 22, 207, copy.split("\n"), 15, "#39343F", 550, 20)

    s.rect(54, 277, 2092, 93, "#302B36", 20)
    swatches = [
        ("Material primary · actions", "#6750A4", "#D0BCFF"),
        ("Selected container", "#EADDFF", "#4F378B"),
        ("Success / completion", "#388E3C", "#81C784"),
        ("Chart series · retained", "#6200EE", "#BB86FC"),
    ]
    for i, (label, light, dark) in enumerate(swatches):
        x = 76 + i * 512
        s.circle(x + 12, 312, 10, light)
        s.circle(x + 38, 312, 10, dark)
        s.text(x + 61, 309, label, 13, "#F4EFF8", 650)
        s.text(x + 61, 333, f"Light {light}   ·   Dark {dark}", 11, "#D2CBD8", 500)

    mini = [
        ("01 · TRAIN OVERVIEW", OUT / "train-overview-classic-m3e-light.png", 55),
        ("02 · ACTIVE SESSION", OUT / "active-workout-classic-m3e-light.png", 594),
        ("03 · PROGRESS", OUT / "progress-classic-m3e-light.png", 1133),
        ("04 · WEIGHT UNITS", OUT / "weight-units-classic-m3e-light.png", 1672),
    ]
    for label, path, x in mini:
        s.rect(x, 398, 473, 1015, "#F8F5FA", 22, "#D8D2DD", 0.8)
        s.text(x + 236, 432, label, 12, "#625B69", 750, anchor="middle", spacing=0.5)
        s.embed(path, x + 19, 449, 435, 943)
    return s.finish()


def modernization_board():
    s = base.Svg(2200, 1600)
    s.rect(0, 0, 2200, 1600, "#EAE6EE")
    s.text(52, 65, "Tonos Classic · visual contract", 39, "#24202B", 850)
    s.text(56, 100, "Classic remains Tonos’s Material theme, refined selectively with useful Material 3 Expressive ideas.", 16, "#625B69", 500)

    principles = [
        ("CLASSIC IDENTITY", "Deep-purple Material, familiar Tonos\nsurfaces, and the current light/dark\ncharacter remain the foundation."),
        ("TONOS STRUCTURE", "Current screens, controls, navigation,\nworkout density, and information order\nremain in place."),
        ("SEMANTIC OWNERSHIP", "Green means success and completion.\nPlan, chart, heatmap, and settings\ncolors keep their existing owners."),
        ("EXPRESSIVE, RESTRAINED", "Strengthen useful hierarchy and selection.\nEvaluate morphs and motion separately\nduring implementation prototyping."),
    ]
    for i, (label, copy) in enumerate(principles):
        x = 52 + i * 528
        s.rect(x, 126, 500, 124, "#FBF8FC", 20, "#D8D2DD", 0.8)
        s.text(x + 20, 158, label, 12.5, "#6750A4", 800, spacing=0.5)
        base.text_lines(s, x + 20, 188, copy.split("\n"), 13, "#39343F", 500, 18)

    # Final light and dark surface ladder, in app-role order.
    s.rect(52, 270, 2096, 202, "#FBF8FC", 20, "#D8D2DD", 0.8)
    s.text(76, 303, "LIGHT · warm near-white with clearer tonal steps", 15, "#39343F", 750)
    s.text(1120, 303, "DARK · familiar deep surfaces, unchanged", 15, "#39343F", 750)
    light_roles = [
        ("Canvas", "#FFF8FD"), ("Grouped", "#ECE5F1"), ("Card", "#F4EDF6"),
        ("Selected", "#EADDFF"), ("Raised / dialog", "#FFFBFF"),
    ]
    dark_roles = [
        ("Canvas", "#141218"), ("Grouped", "#2C2932"), ("Card", "#25232A"),
        ("Selected", "#4F378B"), ("Raised / dialog", "#1C1B20"),
    ]
    for roles, start, text_color in ((light_roles, 76, "#29252E"), (dark_roles, 1120, "#F2EDF6")):
        for i, (label, fill) in enumerate(roles):
            x = start + i * 198
            s.rect(x, 322, 178, 94, fill, 16, "#D8D2DD" if start == 76 else "#4C4652", 0.8)
            s.text(x + 89, 359, label, 11.5, text_color, 650, anchor="middle")
            s.text(x + 89, 389, fill, 10.5, text_color, 500, anchor="middle")
    s.text(76, 447, "Only light-mode steps were separated slightly; the established dark palette is preserved.", 11, "#625B69", 500)

    # Action roles: primary purple, tonal support, compact utility, semantic green.
    s.rect(52, 492, 690, 372, "#FBF8FC", 20, "#D8D2DD", 0.8)
    s.text(76, 530, "Action hierarchy · placement stays current", 17, "#39343F", 750)
    s.text(76, 559, "PRIMARY · CLASSIC MATERIAL PURPLE", 10.5, "#625B69", 750, spacing=0.4)
    s.rect(76, 572, 246, 48, "#6750A4", 18)
    s.text(199, 602, "Start Workout", 14, "#FFFFFF", 750, anchor="middle")
    s.rect(336, 572, 376, 48, "#6750A4", 18)
    s.text(524, 602, "Finish Workout", 14, "#FFFFFF", 750, anchor="middle")
    s.text(76, 649, "SUPPORTING", 10.5, "#625B69", 750, spacing=0.4)
    s.rect(76, 661, 164, 42, "#EADDFF", 17)
    s.text(158, 687, "Optimize", 13, "#21005D", 700, anchor="middle")
    s.icon("plus", 273, 672, 16, "#6750A4", sw=2)
    s.text(296, 688, "Add Set", 12.5, "#6750A4", 650)
    s.text(436, 649, "UTILITY", 10.5, "#625B69", 750, spacing=0.4)
    s.rect(436, 661, 42, 42, "#EADDFF", 15)
    s.icon("plus", 446, 671, 22, "#21005D", sw=2)
    s.text(490, 687, "Add exercise", 12.5, "#625B69", 550)
    s.text(76, 733, "SEMANTIC COMPLETION · GREEN", 10.5, "#625B69", 750, spacing=0.4)
    s.rect(76, 745, 636, 61, "#E8F3E9", 15)
    s.circle(101, 775, 9, "#388E3C")
    s.icon("check", 94, 768, 14, "#FFFFFF", sw=2.5)
    s.text(123, 781, "Set 1 complete · 1/1 done", 14, "#17441E", 700)
    s.text(76, 837, "Start/Finish use primary; success green is reserved for completed work.", 11, "#625B69", 500)

    # Selected states from the current screens, without changing navigation.
    s.rect(765, 492, 680, 372, "#FBF8FC", 20, "#D8D2DD", 0.8)
    s.text(789, 530, "Selection · clear, calm, and familiar", 17, "#39343F", 750)
    s.text(789, 558, "TRAIN TABS", 10, "#625B69", 750, spacing=0.4)
    s.rect(789, 570, 632, 40, "#ECE5F1", 20)
    s.rect(793, 574, 306, 32, "#EADDFF", 16)
    s.text(946, 595, "Overview", 12.5, "#21005D", 700, anchor="middle")
    s.text(1262, 595, "Plans", 12.5, "#49454F", 550, anchor="middle")
    s.text(789, 636, "PROGRESS RANGE", 10, "#625B69", 750, spacing=0.4)
    for i, label in enumerate(("1W", "1M", "3M", "6M", "1Y", "All")):
        x = 790 + i * 103
        if label == "All":
            s.rect(x, 646, 76, 34, "#6750A4", 17)
        s.text(x + 38, 668, label, 11.5, "#FFFFFF" if label == "All" else "#39343F", 700 if label == "All" else 550, anchor="middle")
    s.text(789, 708, "FIVE-DESTINATION NAVIGATION", 10, "#625B69", 750, spacing=0.4)
    s.rect(789, 718, 632, 55, "#FFFBFF", 14, "#E3DCE8", 0.8)
    nav_items = [("Train", "dumbbell"), ("Catalog", "book"), ("Logbook", "history"), ("Progress", "trend"), ("Profile", "person")]
    for i, (label, glyph) in enumerate(nav_items):
        cx = 850 + i * 119
        if label == "Progress":
            s.rect(cx - 23, 723, 46, 25, "#EADDFF", 13)
            icon_color, label_color, weight = "#21005D", "#6750A4", 650
        else:
            icon_color, label_color, weight = "#79747E", "#79747E", 450
        s.icon(glyph, cx - 9, 725, 18, icon_color)
        s.text(cx, 764, label, 9.5, label_color, weight, anchor="middle")
    s.text(789, 801, "DIALOG ROW", 10, "#625B69", 750, spacing=0.4)
    s.rect(789, 811, 632, 42, "#EADDFF", 14)
    s.circle(812, 832, 7.5, "none", "#6750A4", 1.8)
    s.circle(812, 832, 3.6, "#6750A4")
    s.text(832, 836, "Pounds", 12.5, "#1D1B20", 650)
    s.text(1389, 836, "lbs", 10.5, "#49454F", 450, anchor="end")

    # Explicitly keep Tonos semantic and data colors out of primary recoloring.
    s.rect(1468, 492, 680, 372, "#FBF8FC", 20, "#D8D2DD", 0.8)
    s.text(1492, 530, "Semantic color ownership", 17, "#39343F", 750)
    ownership = [
        ("Material primary", "General Start / Finish actions", ["#6750A4"]),
        ("Success / completion", "Completed exercises and sets", ["#388E3C", "#81C784"]),
        ("Plan identity", "Full Body blue · Upper 1 orange", ["#2196F3", "#FF9800"]),
        ("Chart / heatmap data", "Series and training intensity stay owned", ["#6200EE", "#1E88E5", "#1565C0"]),
        ("Settings categories", "Account · Training · Progress · Data", ["#B39DDB", "#4DB6AC", "#81C784", "#64B5F6"]),
    ]
    for i, (label, detail, colors) in enumerate(ownership):
        y = 550 + i * 57
        s.rect(1492, y, 632, 50, "#F4EDF6", 12)
        s.text(1508, y + 21, label, 12.5, "#29252E", 700)
        s.text(1508, y + 39, detail, 9.5, "#625B69", 450)
        for j, color in enumerate(colors):
            s.circle(2055 + j * 18, y + 25, 6.5, color)
    s.text(1492, 846, "Only general actions move to purple; semantic and data meanings do not.", 10.5, "#625B69", 500)

    # A modest type ladder and implementation guardrails close the contract.
    s.rect(52, 884, 1004, 640, "#FBF8FC", 20, "#D8D2DD", 0.8)
    s.text(76, 922, "Typography · easier scanning, not louder", 17, "#39343F", 750)
    type_rows = [
        ("PAGE TITLE", "Workout Report", 25, "#1D1B20", 800),
        ("SECTION", "Exercise progress", 20, "#1D1B20", 750),
        ("ROW TITLE", "Gym & Workout Settings", 16.5, "#1D1B20", 800),
        ("SUPPORTING", "Measurement and trend tracking setup.", 12.5, "#625B71", 450),
    ]
    row_y = [981, 1045, 1106, 1160]
    for (label, sample, size, color, weight), y in zip(type_rows, row_y):
        s.text(78, y, label, 10, "#6750A4", 750, spacing=0.4)
        s.text(275, y + 3, sample, size, color, weight)
        s.line(78, y + 22, 1028, y + 22, "#E3DCE8", 0.8)
    s.text(78, 1243, "METRIC", 10, "#6750A4", 750, spacing=0.4)
    s.text(275, 1273, "6", 39, "#6750A4", 900)
    s.text(316, 1271, "Workouts", 13, "#49454F", 550)
    s.text(78, 1330, "System sans; larger type is reserved for page titles and focal metrics.", 12, "#625B69", 500)
    s.text(78, 1360, "Settings row titles gain a little weight; supporting copy stays compact and muted.", 12, "#625B69", 500)
    s.rect(78, 1400, 950, 79, "#F4EDF6", 14)
    s.circle(108, 1439, 20, "#F4ECFA")
    s.icon("palette", 96, 1427, 24, "#CE93D8", sw=1.8)
    s.text(143, 1434, "UI & Appearance", 15, "#1D1B20", 800)
    s.text(143, 1457, "Theme, onboarding, and bottom tab setup.", 11.5, "#625B71", 450)
    s.text(1005, 1447, "Classic", 11.5, "#CE93D8", 700, anchor="end")

    s.rect(1080, 884, 1068, 640, "#302B36", 20)
    s.text(1104, 922, "Tonos boundaries · no layout redesign", 17, "#F4EFF8", 750)
    contract = [
        ("Deep-purple Material identity", "retained"),
        ("Current screens, order, controls, and five destinations", "retained"),
        ("Dense workout logging and Progress data colors", "retained"),
        ("Plan, completion, heatmap, and settings accents", "retain ownership"),
        ("Material 3 themeable controls", "near-term foundation"),
        ("Shape morphs, spring motion, and transitions", "prototype later"),
    ]
    for i, (left, right) in enumerate(contract):
        y = 984 + i * 60
        if i % 2 == 0:
            s.rect(1104, y - 27, 1019, 48, "#3A3541", 12)
        s.text(1122, y, left, 12.5, "#F4EFF8", 550)
        s.text(2100, y, right, 11.5, "#D0BCFF", 650, anchor="end")
    s.rect(1104, 1376, 1019, 72, "#4F378B", 18)
    s.text(1130, 1408, "CLASSIC, REFINED", 11, "#EADDFF", 800, spacing=0.6)
    s.text(1130, 1431, "A single existing family, made clearer through theme roles and measured emphasis.", 12.5, "#F4EFF8", 500)
    s.text(1104, 1490, "Interaction behavior is evaluated during Flutter / material_ui prototyping, not implied here.", 11, "#D7D0DC", 500)
    return s.finish()


def html_page():
    screen_sections = []
    for i, (key, heading, ref_name, state) in enumerate(SCREEN_META, 1):
        current_ref = f"proposals/material-3-expressive/classic-light-reference/{ref_name}"
        comparison = f"proposals/classic-m3e-modernization/{key}-comparison.png"
        light = f"proposals/classic-m3e-modernization/{key}-classic-m3e-light.png"
        dark = f"proposals/classic-m3e-modernization/{key}-classic-m3e-dark.png"
        screen_sections.append(f"""
<section class="screen" id="{key}">
  <div class="screen-heading"><span class="number">{i:02}</span><div><h2>{escape(heading)}</h2><p>{escape(state)}</p></div></div>
  <a class="comparison" href="{comparison}"><img src="{comparison}" alt="Current Classic, refined Classic light, and refined Classic dark for {escape(heading)}"></a>
  <div class="links"><a href="{current_ref}">Current Classic Light capture</a><a href="{light}">Updated Light render</a><a href="{dark}">Updated Dark render</a></div>
</section>""")
    html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Tonos · Classic modernization proposal</title>
<style>
:root{{--paper:#f4f1f7;--card:#fff;--ink:#24202b;--sub:#625b69;--line:#d8d2dd;--purple:#6750a4;--lav:#eaddff;--dark:#302b36}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--paper);color:var(--ink);font-family:Roboto,"Segoe UI",Arial,sans-serif}}.wrap{{max-width:1460px;margin:auto;padding:34px 36px 70px}}
.hero{{padding:28px 32px 30px;background:#fff;border:1px solid var(--line);border-radius:24px;display:grid;grid-template-columns:1fr auto;gap:24px;align-items:end}}.eyebrow{{color:var(--purple);font-size:12px;font-weight:750;letter-spacing:.1em;text-transform:uppercase}}h1{{font-size:clamp(34px,5vw,58px);letter-spacing:-.045em;line-height:1.02;margin:12px 0 12px}}.hero p{{max-width:850px;color:var(--sub);font-size:16px;line-height:1.55;margin:0}}.tag{{background:var(--lav);color:#38246b;border-radius:18px;padding:12px 16px;font-size:13px;font-weight:750;white-space:nowrap}}
.intro{{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin:18px 0 30px}}.card{{background:var(--card);border:1px solid var(--line);border-radius:20px;padding:20px}}.card h2{{font-size:20px;margin:0 0 8px}}.card p{{font-size:13px;line-height:1.5;color:var(--sub);margin:0}}.chips{{display:flex;gap:8px;flex-wrap:wrap;margin-top:15px}}.chip{{padding:9px 11px;border-radius:12px;background:#f4eff8;font-size:11px;font-weight:700;color:#40384a}}.chip strong{{display:block;font-size:10px;margin-bottom:4px;color:var(--purple)}}
.board{{display:block;margin:18px 0 34px;background:#fff;border:1px solid var(--line);border-radius:20px;overflow:hidden}}.board img{{display:block;width:100%;height:auto}}.section{{margin:42px 0 14px}}.section h2{{font-size:30px;letter-spacing:-.025em;margin:0 0 7px}}.section p{{color:var(--sub);font-size:14px;margin:0;line-height:1.5}}
.screen{{margin:18px 0 28px;padding:18px;background:#fff;border:1px solid var(--line);border-radius:20px}}.screen-heading{{display:flex;gap:13px;align-items:start;margin-bottom:14px}}.number{{display:grid;place-items:center;width:38px;height:38px;flex:none;background:var(--lav);color:#38246b;border-radius:13px;font-weight:800;font-size:12px}}.screen h2{{font-size:21px;margin:2px 0 5px}}.screen-heading p{{font-size:12px;line-height:1.45;color:var(--sub);margin:0}}.comparison{{display:block;background:#eeebf1;border-radius:15px;overflow:hidden}}.comparison img{{display:block;width:100%;height:auto}}.links{{display:flex;flex-wrap:wrap;gap:9px 18px;padding:12px 3px 0;font-size:12px}}a{{color:#59438d;text-underline-offset:3px}}
.notes{{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}}.notes article{{padding:16px;background:#f8f5fa;border:1px solid var(--line);border-radius:15px}}.notes h3{{font-size:13px;margin:0 0 5px}}.notes p{{font-size:12px;color:var(--sub);line-height:1.5;margin:0}}.footer{{border-top:1px solid var(--line);padding-top:14px;margin-top:32px;color:var(--sub);font-size:12px}}
@media(max-width:850px){{.wrap{{padding:14px 10px 44px}}.hero{{grid-template-columns:1fr;padding:20px}}.tag{{justify-self:start}}.intro,.notes{{grid-template-columns:1fr}}.screen{{padding:10px}}.links{{gap:8px 12px}}}}
@media print{{body{{background:#fff}}.wrap{{max-width:none;padding:16px}}.screen,.hero,.card{{break-inside:avoid}}}}
</style></head><body><main class="wrap">
<header class="hero"><div><div class="eyebrow">Classic modernization · visual proposal</div><h1>Classic, carefully modernized.</h1><p>What would today’s Tonos Classic look like with the useful parts of Material 3 Expressive? These boards keep the current navigation, content order, and screen density. Classic purple owns general actions; semantic green stays with successful and completed work.</p></div><div class="tag">Same Tonos · selective change</div></header>
<div class="intro">
  <section class="card"><h2>Keep the Classic foundation</h2><p>Deep-purple Material stays the interface accent. Current screen structure, five bottom destinations, workout logging, section order, and data meaning stay familiar.</p><div class="chips"><span class="chip"><strong>PRIMARY</strong>#6750A4</span><span class="chip"><strong>SELECTED</strong>#EADDFF</span><span class="chip"><strong>SUCCESS</strong>semantic green</span><span class="chip"><strong>DATA</strong>chart colors unchanged</span></div></section>
  <section class="card"><h2>Modernize where it helps</h2><p>Purple primary actions are distinct from green completion states. Selected Workouts gets a clearer focal role, settings typography scans more easily, and light surfaces separate slightly better. The dense session logger stays efficient.</p><div class="chips"><span class="chip">No new navigation</span><span class="chip">No new palette family</span><span class="chip">No decorative morphs</span></div></section>
</div>
<a class="board" href="proposals/classic-m3e-modernization/overview-board.png"><img src="proposals/classic-m3e-modernization/overview-board.png" alt="Overview board for Tonos Classic modernization"></a>
<section class="section"><h2>Modernization rules</h2><p>A compact visual contract for what remains Classic, where expressive emphasis is useful, and which semantic and data colors remain independently owned.</p></section>
<a class="board" href="proposals/classic-m3e-modernization/classic-modernization-board.png"><img src="proposals/classic-m3e-modernization/classic-modernization-board.png" alt="Classic modernization design system board"></a>
<section class="section"><h2>Current Classic beside the refined proposal</h2><p>Each board uses the supplied Classic Light screenshot verbatim, next to a matching updated Light and Dark render. Screen state and visible content are held constant. Dark Mode remains off in the paired Appearance previews so its control state matches the supplied capture.</p></section>
{''.join(screen_sections)}
<section class="card"><h2>Implementation realism</h2><div class="notes"><article><h3>Standard Material 3</h3><p>Colors, surface roles, selected states, buttons, cards, fields, switches, navigation, typography, and dialogs are standard themeable Material components.</p></article><article><h3>Small Tonos styling choices</h3><p>Use Classic purple for Start/Finish actions. Preserve semantic completion green, plan identity, profile-category, chart, and heatmap ownership while refining light surface steps.</p></article><article><h3>Left for later</h3><p>State-to-state shape morphing, spring-driven interaction, and new navigation patterns are not implied by these static mockups.</p></article></div></section>
<p class="footer">Proposal artwork only. The older separate-family M3E work remains at <a href="theme-m3-proposals.html">theme-m3-proposals.html</a>. Production Dart, tests, theme architecture, dependency files, inventory, ratchet, and roadmap were not changed. No commit or push.</p>
</main></body></html>"""
    (ROOT / "docs" / "theme-classic-m3e-proposals.html").write_text(html, encoding="utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    light = generated_screens(ClassicPalette(False))
    dark = generated_screens(ClassicPalette(True))
    for key, *_ in SCREEN_META:
        for suffix, source in (("classic-m3e-light", light[key]), ("classic-m3e-dark", dark[key])):
            render_svg(f"{key}-{suffix}", source.finish())

    comparison_paths = []
    for key, heading, reference_name, _ in SCREEN_META:
        ref = REFERENCE / reference_name
        if not ref.is_file():
            raise FileNotFoundError(ref)
        comparison_paths.append(render_svg(f"{key}-comparison", comparison_board(key, heading, ref)))

    render_svg("classic-modernization-board", modernization_board())
    render_svg("overview-board", overview_board())
    html_page()
    print(f"Rendered 14 screen mockups, seven comparison boards, two review boards, and the HTML proposal in {OUT}")


if __name__ == "__main__":
    main()
