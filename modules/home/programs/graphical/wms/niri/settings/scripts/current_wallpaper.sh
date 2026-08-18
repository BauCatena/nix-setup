#!/usr/bin/env bash
set -euo pipefail
state="${HOME}/.config/niri/wallpaper.state"
if [ -f "$state" ]; then
    wall=$(cat "$state" | xargs)
    wall="${wall/#\~/$HOME}"
    if [ -n "$wall" ] && [ -f "$wall" ]; then
        echo "$wall"
        exit 0
    fi
fi
conf="${HOME}/.config/niri/theme.conf"
if [ -f "$conf" ]; then
    wall=$(grep '^\$wallpaper' "$conf" | awk -F= '{print $2}' | xargs)
    wall="${wall/#\~/$HOME}"
    if [ -n "$wall" ] && [ -f "$wall" ]; then
        echo "$wall"
        exit 0
    fi
fi
echo "${HOME}/.config/niri/wallpaper/minimal.jpg"
