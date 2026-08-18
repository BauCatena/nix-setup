#!/usr/bin/env bash
# Copy verification code to clipboard (+ cliphist history).
set -euo pipefail
code="${1:-}"
[ -n "$code" ] || exit 0
export PATH="/run/wrappers/bin:/run/current-system/sw/bin:$HOME/.local/bin:$PATH"
printf '%s' "$code" | wl-copy
printf '%s' "$code" | cliphist store 2>/dev/null || true
