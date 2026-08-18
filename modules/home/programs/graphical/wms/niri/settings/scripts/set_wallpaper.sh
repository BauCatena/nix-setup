#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

WALLPAPER="${1:-$HOME/.config/niri/wallpaper/minimal.jpg}"
PERSIST=1

if [ "${1:-}" = "--no-persist" ]; then
    PERSIST=0
    shift
    WALLPAPER="${1:-$HOME/.config/niri/wallpaper/minimal.jpg}"
fi

WALLPAPER="${WALLPAPER/#\~/$HOME}"

export XDG_CACHE_HOME="${XDG_RUNTIME_DIR:-/tmp}/awww-xdg-cache"
export AWWW_CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/awww-cache"
mkdir -p "$XDG_CACHE_HOME" "$AWWW_CACHE_DIR"

persist_wallpaper() {
    local path="$1"
    local theme stored

    theme=$(grep -oE 'switch_theme\.sh \([^)]+\)' "$HOME/.config/niri/theme.kdl" 2>/dev/null \
        | sed -n 's/.*(\(.*\))/\1/p' | head -1)
    theme="${theme% preview}"
    [ -n "$theme" ] || theme="minimal"

    if [[ "$path" == "$HOME/"* ]]; then
        stored="~/${path#$HOME/}"
    else
        stored="$path"
    fi

    for conf in "$HOME/.config/niri/theme.conf" "$HOME/.config/niri/themes/${theme}.conf"; do
        [ -f "$conf" ] || continue
        if grep -q '^\$wallpaper' "$conf"; then
            sed -i "s|^\\$wallpaper =.*|\$wallpaper = ${stored}|" "$conf"
        fi
    done
    echo "$stored" > "$HOME/.config/niri/wallpaper.state"
}

if [ "$WALLPAPER" = "black" ]; then
    WALLPAPER=""
fi

if [ -n "$WALLPAPER" ] && [ ! -f "$WALLPAPER" ]; then
    fallback="$HOME/.config/niri/wallpaper/minimal.jpg"
    if [ -f "$fallback" ]; then
        WALLPAPER="$fallback"
    else
        WALLPAPER=""
    fi
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    if command -v awww >/dev/null 2>&1; then
        pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon --no-cache &
        sleep 0.2
        awww clear 000000 2>/dev/null || true
    fi
    exit 0
fi

if ! command -v awww >/dev/null 2>&1; then
    exit 0
fi

pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon --no-cache &
sleep 0.3
awww img "$WALLPAPER" --transition-type none --no-cache 2>/dev/null \
    || awww img "$WALLPAPER" --transition-type none

if [ "$PERSIST" -eq 1 ]; then
    persist_wallpaper "$WALLPAPER"
fi
