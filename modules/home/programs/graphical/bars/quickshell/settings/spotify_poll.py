#!/usr/bin/env python3
"""Poll MPRIS (spotify / spotify-player) for island UI."""
import json
import os
import subprocess
import sys
from pathlib import Path

NIX_PATH = f"/run/wrappers/bin:/run/current-system/sw/bin:{Path.home()}/.local/bin"
ENV = {**os.environ, "PATH": NIX_PATH + os.pathsep + os.environ.get("PATH", "")}
BARS_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "spotify.bars"
PLAYERS = ("spotify_player", "spotify-player", "spotify")


def run(args: list[str], timeout: float = 3.0) -> str:
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=timeout, env=ENV)
        if result.returncode != 0:
            return ""
        return result.stdout.strip()
    except (subprocess.SubprocessError, OSError):
        return ""


def detect_player() -> str:
    listed = [line.strip() for line in run(["playerctl", "-l"]).splitlines() if line.strip()]
    for candidate in PLAYERS:
        if candidate in listed:
            return candidate
    for name in listed:
        if "spotify" in name.lower():
            return name
    return ""


def parse_int(value: str) -> int:
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return 0


def read_bars() -> list[int]:
    if os.environ.get("SPOTIFY_CAVA", "0") not in ("1", "true", "yes"):
        return []
    if not BARS_FILE.is_file():
        return []
    try:
        raw = BARS_FILE.read_text().strip()
        if not raw:
            return []
        return [max(2, min(100, int(x))) for x in raw.split(",")[:5]]
    except (OSError, ValueError):
        return []


def fetch_state() -> dict:
    player = detect_player()
    if not player:
        return {"active": False, "status": "offline"}

    status = run(["playerctl", "--player", player, "status"]) or "offline"
    fmt = "{{title}}\t{{artist}}\t{{album}}\t{{mpris:artUrl}}\t{{mpris:length}}\t{{mpris:trackid}}"
    meta = run(["playerctl", "--player", player, "metadata", "--format", fmt])
    parts = meta.split("\t") if meta else ["", "", "", "", "", ""]
    while len(parts) < 6:
        parts.append("")

    position_raw = run(["playerctl", "--player", player, "position"])
    position_ms = int(float(position_raw) * 1000) if position_raw else 0
    duration_ms = parse_int(parts[4])

    title = parts[0] or ""
    artist = parts[1] or ""
    album = parts[2] or ""
    art = parts[3] or ""
    track_id = parts[6 - 1] if len(parts) >= 6 else ""

    active = status.lower() in ("playing", "paused") and bool(title or artist)
    return {
        "active": active,
        "status": status,
        "player": player,
        "title": title,
        "artist": artist,
        "album": album,
        "artUrl": art,
        "trackId": track_id,
        "positionMs": position_ms,
        "durationMs": duration_ms,
        "text": f"{title} - {artist}".strip(" -"),
        "bars": read_bars(),
    }


def main():
    print(json.dumps(fetch_state()), flush=True)


if __name__ == "__main__":
    main()
