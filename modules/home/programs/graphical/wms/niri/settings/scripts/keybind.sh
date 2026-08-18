#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

cmd="${1:?usage: keybind.sh <command> [args...]}"
shift || true

case "$cmd" in
    clipboard|v) exec "$HOME/.local/bin/smart_clipboard.sh" ;;
    menu|r|d) exec "$SCRIPT_DIR/menu.sh" ;;
    pack|a) exec "$SCRIPT_DIR/pack_workspaces.sh" ;;
    control|z) exec "$HOME/.local/bin/smart_controlcenter.sh" ;;
    power|n) exec "$HOME/.local/bin/smart_powermenu.sh" ;;
    theme) exec "$HOME/.local/bin/smart_theme.sh" ;;
    foot|t) exec "$SCRIPT_DIR/foot.sh" ;;
    yazi|e) exec "$SCRIPT_DIR/yazi.sh" ;;
    firefox|b) exec "$SCRIPT_DIR/run.sh" firefox ;;
    obsidian|o) exec "$SCRIPT_DIR/run.sh" obsidian ;;
    pick-wallpaper) exec "$SCRIPT_DIR/pick_wallpaper.sh" ;;
    switch-theme) exec "$SCRIPT_DIR/switch_theme.sh" ;;
    screenshot) exec "$SCRIPT_DIR/screenshot_screen.sh" ;;
    wallpaper-region) exec "$SCRIPT_DIR/wallpaper_region.sh" ;;
    screenshot-region) exec "$SCRIPT_DIR/screenshot_region.sh" ;;
    battery) exec "$HOME/.local/bin/battery_mode.sh" ;;
    lock) exec "$SCRIPT_DIR/run.sh" swaylock -c "$HOME/.config/niri/swaylock.conf" ;;
    brightness) exec "$HOME/.local/bin/smart_brightness.sh" "$@" ;;
    volume) exec "$HOME/.local/bin/smart_volume.sh" "$@" ;;
    mic) exec "$HOME/.local/bin/smart_mic.sh" ;;
    float) exec "$SCRIPT_DIR/float_center.sh" ;;
    airplane) exec "$SCRIPT_DIR/airplane_mode.sh" ;;
    player) exec "$SCRIPT_DIR/run.sh" playerctl "$@" ;;
    spotify-restart) exec "$HOME/.local/bin/spotify_restart.sh" ;;
    *) echo "unknown keybind command: $cmd" >&2; exit 1 ;;
esac
