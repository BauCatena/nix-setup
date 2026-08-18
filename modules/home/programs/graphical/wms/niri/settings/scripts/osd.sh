#!/usr/bin/env bash
# Show volume/brightness OSD via Quickshell or wob (battery mode).
# Usage: osd.sh B|V <percent>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

type="${1:?usage: osd.sh B|V <percent>}"
val="${2:?usage: osd.sh B|V <percent>}"

if pgrep -x quickshell >/dev/null 2>&1 || pgrep -f "[q]uickshell.*shell\\.qml" >/dev/null 2>&1; then
    trigger="${XDG_RUNTIME_DIR:-/tmp}/quickshell.cmd"
    printf 'showOsd\t%s\t%s\n' "$type" "$val" >"$trigger"
    exit 0
fi

fifo="${XDG_RUNTIME_DIR:-/tmp}/wob.fifo"
if [ -p "$fifo" ]; then
    echo "$val" >"$fifo" 2>/dev/null || true
fi
