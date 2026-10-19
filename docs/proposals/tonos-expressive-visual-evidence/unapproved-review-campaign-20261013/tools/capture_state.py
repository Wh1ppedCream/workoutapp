"""Capture a screenshot and UI hierarchy from the isolated Tonos preview."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib
import struct
import subprocess


CAMPAIGN = pathlib.Path(__file__).resolve().parents[1]
ADB = pathlib.Path(r"E:\Android\Sdk\platform-tools\adb.exe")
DEVICE = "28021FDH200228"
PACKAGE = "com.tonos.expressivepreview"
MANIFEST = CAMPAIGN / "screenshot-manifest.json"


def adb(*args: str) -> bytes:
    result = subprocess.run(
        [str(ADB), "-s", DEVICE, *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", required=True)
    parser.add_argument("--group", required=True, help="Page or overlay group")
    parser.add_argument("--approval", required=True, help="B, unmapped, or state-only")
    parser.add_argument("--theme", required=True, choices=("light", "dark"))
    parser.add_argument("--state", required=True)
    parser.add_argument("--route", required=True)
    parser.add_argument("--png", required=True, help="Path relative to campaign root")
    parser.add_argument("--coverage-id", help="Coverage row ID to mark captured")
    parser.add_argument("--limitations", default="")
    args = parser.parse_args()

    relative_png = pathlib.PurePosixPath(args.png.replace("\\", "/"))
    if relative_png.is_absolute() or ".." in relative_png.parts:
        raise SystemExit("PNG path must remain inside the evidence campaign.")
    png_path = CAMPAIGN.joinpath(*relative_png.parts)
    xml_path = png_path.with_suffix(".xml")
    if png_path.exists() or xml_path.exists():
        raise SystemExit(f"Refusing to overwrite existing capture: {relative_png}")

    screenshot = adb("exec-out", "screencap", "-p")
    if not screenshot.startswith(b"\x89PNG\r\n\x1a\n"):
        raise SystemExit("Device did not return a PNG screenshot.")
    width, height = struct.unpack(">II", screenshot[16:24])
    png_path.parent.mkdir(parents=True, exist_ok=True)
    png_path.write_bytes(screenshot)
    captured_at = dt.datetime.now().astimezone().isoformat(timespec="seconds")

    remote_xml = f"/sdcard/tonos-review-{args.id}.xml"
    adb("shell", "uiautomator", "dump", remote_xml)
    hierarchy = adb("shell", "cat", remote_xml).decode("utf-8", errors="replace")
    if "<hierarchy" not in hierarchy:
        png_path.unlink(missing_ok=True)
        raise SystemExit("UI hierarchy capture was incomplete; removed this screenshot.")
    xml_path.write_text(hierarchy, encoding="utf-8")

    manifest = {"campaign": {}, "screenshots": [], "coverage": []}
    if MANIFEST.exists():
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        manifest.setdefault("screenshots", [])
        manifest.setdefault("coverage", [])
    if any(entry.get("id") == args.id for entry in manifest["screenshots"]):
        png_path.unlink(missing_ok=True)
        xml_path.unlink(missing_ok=True)
        raise SystemExit(f"Screenshot id already exists: {args.id}")

    manifest["screenshots"].append(
        {
            "id": args.id,
            "group": args.group,
            "approvalClassification": args.approval,
            "theme": args.theme,
            "state": args.state,
            "navigationPath": args.route,
            "png": relative_png.as_posix(),
            "uiHierarchy": xml_path.relative_to(CAMPAIGN).as_posix(),
            "capturedAt": captured_at,
            "sourceRevision": subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=CAMPAIGN.parents[3], text=True
            ).strip(),
            "sourceProvenance": "See build-provenance.json; installed isolated preview APK.",
            "deviceId": DEVICE,
            "package": PACKAGE,
            "fresh": True,
            "verified": True,
            "imageWidth": width,
            "imageHeight": height,
            "limitations": args.limitations,
        }
    )
    if args.coverage_id:
        coverage_row = next(
            (
                item
                for item in manifest["coverage"]
                if isinstance(item, dict) and item.get("id") == args.coverage_id
            ),
            None,
        )
        if coverage_row is None:
            png_path.unlink(missing_ok=True)
            xml_path.unlink(missing_ok=True)
            manifest["screenshots"].pop()
            raise SystemExit(f"Unknown coverage row ID: {args.coverage_id}")
        coverage_row["status"] = "CAPTURED"
        coverage_row["screenshotIds"] = [
            *coverage_row.get("screenshotIds", []),
            args.id,
        ]
    temporary = MANIFEST.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(MANIFEST)
    print(f"CAPTURED {args.id} {args.theme} {width}x{height} {relative_png.as_posix()}")


if __name__ == "__main__":
    main()
