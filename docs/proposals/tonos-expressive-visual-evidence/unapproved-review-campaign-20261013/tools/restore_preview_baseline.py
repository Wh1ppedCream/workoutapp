"""Restore and verify only the saved preview DB/WAL/SHM and preference files."""
from __future__ import annotations

import hashlib
import json
import shlex
import shutil
import subprocess
from pathlib import Path


DEVICE = "28021FDH200228"
PACKAGE = "com.tonos.expressivepreview"
APP_DATA = f"/data/user/0/{PACKAGE}"
BASELINE = Path(
    r"C:\Users\talh7\AppData\Local\Temp\tonos-expressive-review-campaign-baseline-20261013T012550"
)
BASELINE_MANIFEST = BASELINE / "manifest.json"
OUTPUT = Path(__file__).resolve().parents[1] / "preview-restore-verification.json"


def adb(*args: str, input_bytes: bytes | None = None) -> bytes:
    executable = shutil.which("adb")
    if not executable:
        raise SystemExit("adb was not found on PATH.")
    result = subprocess.run(
        [executable, "-s", DEVICE, *args],
        input=input_bytes,
        capture_output=True,
        check=False,
    )
    no_pid_is_expected = args[:2] == ("shell", "pidof") and result.returncode == 1
    if result.returncode and not no_pid_is_expected:
        raise subprocess.CalledProcessError(
            result.returncode,
            result.args,
            output=result.stdout,
            stderr=result.stderr,
        )
    return result.stdout


manifest = json.loads(BASELINE_MANIFEST.read_text(encoding="utf-8"))
devices = adb("devices", "-l").decode("utf-8", errors="replace")
connected = any(
    len(parts := line.split()) >= 2 and parts[0] == DEVICE and parts[1] == "device"
    for line in devices.splitlines()
)
if not connected:
    raise SystemExit(f"Expected connected device {DEVICE}; refusing restore.\n{devices}")

# Only the SQLite shared-memory sidecar has a recorded-hash discrepancy. It is
# volatile; retain the saved bytes, report both digests, and verify the restored
# file against the bytes actually present in this baseline folder.
prepared: list[tuple[dict[str, object], Path, bytes, str, str]] = []
for item in manifest:
    relative = Path(str(item["path"]))
    if relative.parts[0] not in {"databases", "shared_prefs"}:
        raise SystemExit(f"Refusing path outside approved restore scope: {relative}")
    local = BASELINE / relative
    payload = local.read_bytes()
    actual_source = hashlib.sha256(payload).hexdigest()
    expected = str(item["sha256"])
    if actual_source != expected and relative.as_posix() != "databases/tonos_expressive_preview.db-shm":
        raise SystemExit(f"Saved baseline hash mismatch before restore: {relative}")
    if len(payload) != int(item["bytes"]):
        raise SystemExit(f"Saved baseline size mismatch before restore: {relative}")
    prepared.append((item, relative, payload, expected, actual_source))

adb("shell", "am", "force-stop", PACKAGE)
running = adb("shell", "pidof", PACKAGE).decode("utf-8", errors="replace").strip()
if running:
    raise SystemExit(f"Preview process is still running after force-stop (pid {running}); refusing restore.")
adb("shell", "run-as", PACKAGE, "mkdir", "-p", "databases", "shared_prefs")

verified: list[dict[str, object]] = []
for item, relative, payload, expected, actual_source in prepared:
    remote = f"{APP_DATA}/{relative.as_posix()}"
    command = f"cat > {shlex.quote(remote)} && chmod 600 {shlex.quote(remote)}"
    adb("exec-in", "run-as", PACKAGE, "sh", "-c", command, input_bytes=payload)
    restored = adb("exec-out", "run-as", PACKAGE, "cat", remote)
    actual = hashlib.sha256(restored).hexdigest()
    if actual != actual_source:
        raise SystemExit(f"Restored bytes differ from saved snapshot: {relative} source={actual_source} actual={actual}")
    if actual_source != expected:
        print(f"WARNING recorded baseline hash differs for {relative.as_posix()}: recorded={expected} saved/restored={actual}")
    verified.append(
        {
            "path": relative.as_posix(),
            "recordedBaselineSha256": expected,
            "savedAndRestoredSha256": actual,
            "matchesRecordedBaseline": actual == expected,
            "bytes": len(restored),
        }
    )

# run-as never launches the app; enforce the stopped state once more and report exact hashes.
adb("shell", "am", "force-stop", PACKAGE)
if adb("shell", "pidof", PACKAGE).decode("utf-8", errors="replace").strip():
    raise SystemExit("Preview process unexpectedly running after restore.")
OUTPUT.write_text(
    json.dumps(
        {
            "deviceId": DEVICE,
            "package": PACKAGE,
            "database": "tonos_expressive_preview.db",
            "restoreSource": str(BASELINE),
            "appLaunched": False,
            "processState": "force-stopped",
            "files": verified,
        },
        ensure_ascii=False,
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)
for item in verified:
    print(f"RESTORED {item['path']} sha256={item['savedAndRestoredSha256']} matchesRecorded={item['matchesRecordedBaseline']}")
print(f"Verified {len(verified)} baseline files; preview package remains force-stopped. Report: {OUTPUT}")
