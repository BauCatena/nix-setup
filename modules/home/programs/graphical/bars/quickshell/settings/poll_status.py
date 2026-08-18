#!/usr/bin/env python3
"""Status poller for Quickshell. Use --once from a QML timer (no persistent process)."""
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

HOME = Path.home()
CONFIG = HOME / ".config"
NIX_PATH = f"/run/wrappers/bin:/run/current-system/sw/bin:{HOME}/.local/bin"
ENV = {
    **os.environ,
    "PATH": NIX_PATH + os.pathsep + os.environ.get("PATH", ""),
    "LC_ALL": "C",
}

CACHE_FILE = CONFIG / "quickshell" / ".updates_cache.json"
UPDATE_INTERVAL = 3600.0

IGNORED_AUDIO = re.compile(
    r"^(pipewire|WirePlumber|wireplumber|xdg-desktop-portal|Quickshell|quickshell|Electron)$"
)
IGNORED_PROC = re.compile(r"^(pipewire|wireplumber|pw-)")


def run(cmd, timeout=2.0):
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=ENV,
        )
        return result.stdout.strip()
    except (subprocess.SubprocessError, OSError):
        return ""


def read_int(path: Path, default=0) -> int:
    try:
        return int(path.read_text().strip())
    except (OSError, ValueError):
        return default


def parse_volume(raw: str):
    muted = "[MUTED]" in raw
    match = re.search(r"[0-9.]+", raw)
    pct = f"{round(float(match.group()) * 100)}%" if match else "0%"
    return pct, muted


def power_draw() -> str:
    current = read_int(Path("/sys/class/power_supply/BAT1/current_now"))
    voltage = read_int(Path("/sys/class/power_supply/BAT1/voltage_now"))
    if current and voltage:
        return f"{(current * voltage) / 1_000_000_000_000:.1f}"
    return "0.0"


def battery_state():
    cap = read_int(Path("/sys/class/power_supply/BAT0/capacity"))
    ac = read_int(Path("/sys/class/power_supply/ACAD/online"))
    return str(cap), ac == 1


def wifi_signal():
    raw = run(["nmcli", "-t", "-f", "active,signal", "dev", "wifi"])
    for line in raw.splitlines():
        if line.startswith("yes:"):
            return line.split(":", 1)[1]
    return "disc"


def mic_in_use() -> bool:
    if shutil.which("pactl") is None:
        return False
    raw = run(["pactl", "list", "source-outputs"], timeout=2.5)
    if not raw:
        return False

    state = ""
    app = ""
    for line in raw.splitlines():
        if line.startswith("Source Output #"):
            if state == "RUNNING" and app and not IGNORED_AUDIO.match(app):
                return True
            state = ""
            app = ""
        elif "State:" in line:
            state = line.split()[1]
        elif 'application.name = "' in line:
            app = line.split('"')[1]
    return bool(state == "RUNNING" and app and not IGNORED_AUDIO.match(app))


def camera_in_use() -> bool:
    for dev in Path("/dev").glob("video*"):
        pids = run(["fuser", str(dev)], timeout=1.0)
        for pid in pids.split():
            if not pid.isdigit():
                continue
            comm = run(["ps", "-p", pid, "-o", "comm="], timeout=0.5)
            if comm and not IGNORED_PROC.match(comm):
                return True
    return False


def load_updates_count() -> str:
    try:
        data = json.loads(CACHE_FILE.read_text())
        return str(data.get("count", "0"))
    except (OSError, json.JSONDecodeError, TypeError):
        return "0"


def refresh_updates_count(force: bool = False) -> str:
    count = load_updates_count()
    stale = True
    try:
        data = json.loads(CACHE_FILE.read_text())
        stale = (time.time() - float(data.get("ts", 0))) >= UPDATE_INTERVAL
        count = str(data.get("count", "0"))
    except (OSError, json.JSONDecodeError, TypeError, ValueError):
        pass

    if force or stale:
        updates = run(["checkupdates"], timeout=120.0)
        count = str(len([line for line in updates.splitlines() if line.strip()]))
        try:
            CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
            CACHE_FILE.write_text(json.dumps({"count": count, "ts": time.time()}))
        except OSError:
            pass
    return count


def battery_mode() -> bool:
    return (CONFIG / "niri" / ".battery_mode").is_file()


def emit(updates_count: str) -> None:
    sink_raw = run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
    src_raw = run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"])
    vol_out, vol_muted = parse_volume(sink_raw)
    vol_mic, mic_muted = parse_volume(src_raw)
    batt_cap, batt_charging = battery_state()
    bt_on = "Powered: yes" in run(["bluetoothctl", "show"], timeout=2.5)

    payload = {
        "powerDraw": power_draw(),
        "temperature": str(read_int(Path("/sys/class/thermal/thermal_zone0/temp")) // 1000),
        "updates": updates_count,
        "batteryCap": batt_cap,
        "batteryCharging": batt_charging,
        "volumeOut": vol_out,
        "volumeMuted": vol_muted,
        "volumeMic": vol_mic,
        "micMuted": mic_muted,
        "bluetoothStatus": "on" if bt_on else "off",
        "wifiSignal": wifi_signal(),
        "micInUse": mic_in_use(),
        "cameraInUse": camera_in_use(),
        "brightnessLevel": run(["bash", "-c", "brightnessctl -m | awk -F, '{print $4}'"]) or "100%",
        "batteryMode": battery_mode(),
    }
    print(json.dumps(payload), flush=True)


def main():
    once = "--once" in sys.argv
    updates_count = refresh_updates_count(force=once)
    emit(updates_count)
    if once:
        return

    while True:
        time.sleep(2.0)
        updates_count = refresh_updates_count()
        emit(updates_count)


if __name__ == "__main__":
    main()
