#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if ! command -v slurp >/dev/null 2>&1 || ! command -v grim >/dev/null 2>&1; then
    notify-send -a niri "Capture" "slurp/grim not found" 2>/dev/null || true
    exit 1
fi

geom=$(slurp) || exit 0
grim -g "$geom" - | wl-copy

"$SCRIPT_DIR/qs_open.sh" showScreenshotFlash 2>/dev/null || true
"$SCRIPT_DIR/flash_screen.sh"
notify-send -a niri -t 2000 "Capture taken" "Saved to clipboard" 2>/dev/null || true
