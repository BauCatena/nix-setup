#!/usr/bin/env bash
# Visual feedback for wallpaper changes (screenshots use island flash + transition).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

title="${1:-Done}"
body="${2:-}"

niri msg action do-screen-transition 2>/dev/null || true

if command -v notify-send >/dev/null 2>&1 && [ -n "$body" ]; then
    notify-send -a niri -t 1200 -i image-x-generic "$title" "$body" 2>/dev/null || true
fi
