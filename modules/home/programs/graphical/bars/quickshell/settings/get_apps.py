#!/usr/bin/env python3
import os
import json
import sys
import configparser
from pathlib import Path

RESOLVE_ICONS = "--no-icons" not in sys.argv


def icon_paths():
    dirs = [
        Path("/run/current-system/sw/share/icons/hicolor"),
        Path("/run/current-system/sw/share/pixmaps"),
        Path.home() / ".local/share/icons/hicolor",
        Path("/usr/share/icons/hicolor"),
        Path("/usr/share/pixmaps"),
    ]
    xdg = os.environ.get("XDG_DATA_DIRS", "")
    for base in xdg.split(":"):
        if base:
            dirs.append(Path(base) / "icons/hicolor")
            dirs.append(Path(base) / "pixmaps")
    return dirs


def resolve_icon(icon_name: str) -> str:
    if not icon_name:
        return ""
    p = Path(icon_name)
    if p.is_absolute() and p.exists():
        return str(p)
    if icon_name.endswith((".png", ".svg", ".xpm")):
        for d in icon_paths():
            for sub in ("256x256/apps", "128x128/apps", "64x64/apps", "48x48/apps", "32x32/apps", "scalable/apps"):
                cand = d / sub / icon_name
                if cand.exists():
                    return str(cand)
            cand = d / icon_name
            if cand.exists():
                return str(cand)
    sizes = ("256x256", "128x128", "64x64", "48x48", "32x32", "scalable")
    for d in icon_paths():
        for size in sizes:
            for sub in ("apps", "applications"):
                for ext in (".png", ".svg"):
                    cand = d / size / sub / f"{icon_name}{ext}"
                    if cand.exists():
                        return str(cand)
        for ext in (".png", ".svg", ".xpm"):
            cand = d / f"{icon_name}{ext}"
            if cand.exists():
                return str(cand)
    return ""


def get_apps():
    xdg_data_dirs = os.environ.get("XDG_DATA_DIRS", "/usr/share")
    dirs = [
        Path("/run/current-system/sw/share/applications"),
        Path.home() / ".nix-profile/share/applications",
        Path.home() / ".local/share/applications",
    ] + [Path(d) / "applications" for d in xdg_data_dirs.split(":") if d]
    apps = []
    seen = set()

    for d in dirs:
        if not d.exists():
            continue
        for f in d.glob("*.desktop"):
            if f.name in seen:
                continue
            seen.add(f.name)

            config = configparser.ConfigParser(interpolation=None)
            try:
                with open(f, "r", encoding="utf-8") as file:
                    content = "[Desktop Entry]\n"
                    in_desktop_entry = False
                    for line in file:
                        if line.strip() == "[Desktop Entry]":
                            in_desktop_entry = True
                            continue
                        elif line.startswith("[") and in_desktop_entry:
                            in_desktop_entry = False
                            continue
                        if in_desktop_entry and "=" in line:
                            content += line

                config.read_string(content)
                if not config.has_section("Desktop Entry"):
                    continue

                entry = config["Desktop Entry"]
                if entry.get("NoDisplay", "false").lower() == "true":
                    continue
                if entry.get("Type", "") != "Application":
                    continue

                name = entry.get("Name")
                exec_cmd = entry.get("Exec")
                icon = entry.get("Icon", "")

                if name and exec_cmd:
                    exec_cmd = " ".join([p for p in exec_cmd.split() if not p.startswith("%")])
                    apps.append({
                        "name": name,
                        "cmd": exec_cmd,
                        "icon": icon,
                        "iconPath": resolve_icon(icon) if RESOLVE_ICONS else "",
                    })
            except Exception:
                pass

    apps.sort(key=lambda x: x["name"].lower())
    print(json.dumps(apps))


if __name__ == "__main__":
    get_apps()
