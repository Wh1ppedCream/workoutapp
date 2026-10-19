"""Small, reversible UI-navigation helper for the isolated Pixel preview."""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ADB = pathlib.Path(r"E:\Android\Sdk\platform-tools\adb.exe")
DEVICE = "28021FDH200228"
PACKAGE = "com.tonos.expressivepreview"
REMOTE_XML = "/sdcard/tonos-expressive-review-current.xml"


def adb(*args: str, input_text: str | None = None) -> str:
    result = subprocess.run(
        [str(ADB), "-s", DEVICE, *args],
        check=True,
        input=input_text,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def hierarchy() -> ET.Element:
    adb("shell", "uiautomator", "dump", REMOTE_XML)
    return ET.fromstring(adb("shell", "cat", REMOTE_XML))


def bounds(node: ET.Element) -> tuple[int, int, int, int] | None:
    match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", node.attrib.get("bounds", ""))
    return tuple(map(int, match.groups())) if match else None


def visible_bounds(node: ET.Element) -> tuple[int, int, int, int] | None:
    rect = bounds(node)
    if not rect:
        return None
    left, top, right, bottom = rect
    left, top, right, bottom = max(0, left), max(0, top), min(1080, right), min(2400, bottom)
    return (left, top, right, bottom) if right > left and bottom > top else None


def list_controls() -> None:
    root = hierarchy()
    for node in root.iter("node"):
        rect = visible_bounds(node)
        if not rect or node.attrib.get("clickable") != "true":
            continue
        label = node.attrib.get("content-desc") or node.attrib.get("text") or node.attrib.get("resource-id") or "<unlabeled>"
        if label == "<unlabeled>" and (rect[2] - rect[0]) * (rect[3] - rect[1]) > 500_000:
            continue
        print(f"{label!r} {rect} enabled={node.attrib.get('enabled')}")


def tap_label(query: str, index: int, exact: bool) -> None:
    root = hierarchy()
    hits: list[tuple[int, int, ET.Element, tuple[int, int, int, int]]] = []
    for node in root.iter("node"):
        rect = visible_bounds(node)
        if not rect or node.attrib.get("enabled") != "true":
            continue
        label = " ".join((node.attrib.get("content-desc", "") + " " + node.attrib.get("text", "")).split())
        matched = label.casefold() == query.casefold() if exact else query.casefold() in label.casefold()
        if not matched:
            continue
        clickable = node.attrib.get("clickable") == "true"
        area = (rect[2] - rect[0]) * (rect[3] - rect[1])
        # Prefer the smallest clickable semantic node, then the smallest visible text node.
        hits.append((0 if clickable else 1, area, node, rect))
    hits.sort(key=lambda item: (item[0], item[1]))
    if not hits or index >= len(hits):
        print(f"No match for {query!r}; available clickable controls:", file=sys.stderr)
        list_controls()
        raise SystemExit(2)
    _, _, node, rect = hits[index]
    if node.attrib.get("clickable") != "true":
        print(f"Matched label is not exposed as clickable: {query!r} {rect}", file=sys.stderr)
        raise SystemExit(3)
    x, y = (rect[0] + rect[2]) // 2, (rect[1] + rect[3]) // 2
    adb("shell", "input", "tap", str(x), str(y))
    print(f"TAPPED {query!r} at {x},{y} bounds={rect}")


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="action", required=True)
    sub.add_parser("list")
    dump = sub.add_parser("dump")
    tap = sub.add_parser("tap")
    tap.add_argument("label")
    tap.add_argument("--index", type=int, default=0)
    tap.add_argument("--exact", action="store_true")
    xy = sub.add_parser("tapxy")
    xy.add_argument("x", type=int)
    xy.add_argument("y", type=int)
    swipe = sub.add_parser("swipe")
    for name in ("x1", "y1", "x2", "y2"):
        swipe.add_argument(name, type=int)
    swipe.add_argument("--duration", type=int, default=450)
    text = sub.add_parser("type")
    text.add_argument("value")
    key = sub.add_parser("key")
    key.add_argument("code")
    args = parser.parse_args()
    if args.action == "list":
        list_controls()
    elif args.action == "dump":
        print(ET.tostring(hierarchy(), encoding="unicode"))
    elif args.action == "tap":
        tap_label(args.label, args.index, args.exact)
    elif args.action == "tapxy":
        adb("shell", "input", "tap", str(args.x), str(args.y))
    elif args.action == "swipe":
        adb("shell", "input", "swipe", str(args.x1), str(args.y1), str(args.x2), str(args.y2), str(args.duration))
    elif args.action == "type":
        adb("shell", "input", "text", args.value.replace(" ", "%s"))
    elif args.action == "key":
        adb("shell", "input", "keyevent", args.code)


if __name__ == "__main__":
    main()
