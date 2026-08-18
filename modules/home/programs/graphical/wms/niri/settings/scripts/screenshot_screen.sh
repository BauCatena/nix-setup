#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

"$SCRIPT_DIR/qs_open.sh" showScreenshotFlash 2>/dev/null || true
"$SCRIPT_DIR/flash_screen.sh"

if niri msg action screenshot-screen --write-to-disk false 2>/dev/null; then
    "$SCRIPT_DIR/qs_open.sh" showScreenshotFlash 2>/dev/null || true
    "$SCRIPT_DIR/flash_screen.sh"
    notify-send -a niri -t 2000 "Capture taken" "Saved to clipboard" 2>/dev/null || true
    exit 0
fi

if command -v grim >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
    grim - | wl-copy
    "$SCRIPT_DIR/qs_open.sh" showScreenshotFlash 2>/dev/null || true
    "$SCRIPT_DIR/flash_screen.sh"
    notify-send -a niri -t 2000 "Capture taken" "Saved to clipboard" 2>/dev/null || true
    exit 0
fi

notify-send -a niri "Capture" "Could not take screenshot" 2>/dev/null || true
exit 1
