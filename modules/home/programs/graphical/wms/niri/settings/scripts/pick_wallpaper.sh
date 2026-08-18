#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

WALL_DIR="$HOME/.config/niri/wallpaper"
[ -d "$WALL_DIR" ] || { notify-send -a niri "Wallpaper" "Missing $WALL_DIR" 2>/dev/null; exit 1; }

mapfile -t files < <(
    for f in "$WALL_DIR"/*; do
        [ -f "$f" ] || continue
        case "${f,,}" in
            *.jpg|*.jpeg|*.png|*.webp) basename "$f" ;;
        esac
    done | sort
)

[ "${#files[@]}" -gt 0 ] || { notify-send -a niri "Wallpaper" "No images found" 2>/dev/null; exit 0; }

choice=$(printf '%s\n' "${files[@]}" | tofi --prompt-text " Wallpaper: ") || exit 0
[ -n "$choice" ] || exit 0

"$SCRIPT_DIR/set_wallpaper.sh" "$WALL_DIR/$choice"
"$SCRIPT_DIR/flash_feedback.sh" "Wallpaper" "$choice"
